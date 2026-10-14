"""Cross references over the cached disassembly.

- calls: bsr/br/jsri/jmpi targets (direct), per reachable instruction;
- literals: lrw/jsri pool words (value and pool address);
- words: any aligned 32-bit word in flash/IRAM/SRAM-init equal to a value (tables, handler arrays);
- memory accesses: ld/st whose base register holds a constant tracked linearly through a function
  (movi, movih, ori, lsli, addi, subi, bseti, bclri, lrw, mov). The tracker is intentionally simple:
  register state resets at every branch target and after calls clobber r0-r3/r12/r13, so a reported
  access is code-verified only after reading the listing; missing accesses are possible.
"""

from __future__ import annotations

import re
from collections import defaultdict
from dataclasses import dataclass
from functools import cached_property

from .disasm import Disassembly, Insn, successors

_REG = r"r\d+"
_LDST = re.compile(r"^(ld|st)\.(b|h|w|bs|hs)$")
_MEM = re.compile(rf"^({_REG}),\s*\(({_REG}),\s*(-?(?:0x[0-9a-f]+|\d+))\)$")
_TWO = re.compile(rf"^({_REG}),\s*({_REG})$")
_RRI = re.compile(rf"^({_REG}),\s*({_REG}),\s*(-?(?:0x[0-9a-f]+|\d+))$")
_RI = re.compile(rf"^({_REG}),\s*(-?(?:0x[0-9a-f]+|\d+))$")
_CLOBBER = {"r0", "r1", "r2", "r3", "r12", "r13", "r15"}
_WIDTH = {"b": 1, "bs": 1, "h": 2, "hs": 2, "w": 4}


def _num(s: str) -> int:
    return int(s, 0)


@dataclass(frozen=True)
class Access:
    site: int  # instruction address
    func: int  # catalog function containing it (or nearest preceding)
    kind: str  # "ld" / "st"
    width: int
    addr: int  # effective address
    text: str


class Xrefs:
    def __init__(self, d: Disassembly):
        self.d = d

    # ---- reachable instructions per function -------------------------------------------------
    @cached_property
    def reachable(self) -> dict[int, list[Insn]]:
        """catalog function -> its reachable instructions (address order)."""
        out = {}
        by = self.d.by_addr
        for f in self.d.cat.funcs:
            reg = self.d.img.region(f.addr)
            if reg is None or not reg.code:
                continue
            limit = max(f.end, self.d.cat.next_start(f.addr) or f.end)
            seen, work = set(), [f.addr]
            while work:
                a = work.pop()
                if a in seen:
                    continue
                ins = by.get(a)
                if ins is None or ins.data:
                    continue
                seen.add(a)
                t, falls = successors(ins)
                work += [x for x in t + self.d.jump_tables.get(a, []) if f.addr <= x < limit]
                if falls and a + ins.size < limit:
                    work.append(a + ins.size)
            out[f.addr] = [by[a] for a in sorted(seen)]
        return out

    @cached_property
    def owner(self) -> dict[int, int]:
        """instruction address -> function that reaches it (first by address if shared)."""
        o = {}
        for f, insns in self.reachable.items():
            for i in insns:
                o.setdefault(i.addr, f)
        return o

    def func_of(self, va: int) -> int | None:
        if va in self.owner:
            return self.owner[va]
        f = self.d.cat.containing(va) or self.d.cat.preceding(va)
        return f.addr if f else None

    # ---- calls --------------------------------------------------------------------------------
    @cached_property
    def call_edges(self) -> list[tuple[int, int, int, str]]:
        """(site, caller function, callee, mnemonic) for bsr/jsri/jmpi and tail-call br out of the body."""
        edges = []
        for f, insns in self.reachable.items():
            fn = self.d.cat.by_addr[f]
            limit = max(fn.end, self.d.cat.next_start(f) or fn.end)
            for i in insns:
                if i.mnem == "bsr" and i.target is not None:
                    edges.append((i.addr, f, i.target, "bsr"))
                elif i.mnem in ("jsri", "jmpi") and i.pool is not None:
                    try:
                        edges.append((i.addr, f, self.d.img.u32(i.pool), i.mnem))
                    except Exception:
                        pass
                elif i.mnem == "br" and i.target is not None and not (f <= i.target < limit):
                    edges.append((i.addr, f, i.target, "br(tail)"))
        return edges

    @cached_property
    def callers_of(self) -> dict[int, list[tuple[int, int, str]]]:
        m = defaultdict(list)
        for site, f, t, k in self.call_edges:
            m[t].append((site, f, k))
        return m

    @cached_property
    def callees_of(self) -> dict[int, list[tuple[int, int, str]]]:
        m = defaultdict(list)
        for site, f, t, k in self.call_edges:
            m[f].append((site, t, k))
        return m

    def raw_bsr_sites(self, target: int) -> list[int]:
        """Every bsr32 encoding anywhere in the code regions that lands on target (catches code
        outside catalog bodies, e.g. task entries without a Ghidra function)."""
        out = []
        for i in self.d.insns:
            if i.mnem == "bsr" and i.target == target:
                out.append(i.addr)
        return out

    # ---- literals and words -------------------------------------------------------------------
    @cached_property
    def literal_uses(self) -> dict[int, list[tuple[int, int]]]:
        """literal value -> [(site, pool address)] for reachable lrw/jsri/jmpi."""
        m = defaultdict(list)
        for insns in self.reachable.values():
            for i in insns:
                v = self.d.literal(i)
                if v is not None:
                    m[v].append((i.addr, i.pool))
        return m

    def literals_in(self, lo: int, hi: int) -> list[tuple[int, int, int]]:
        """(site, pool, value) for literals with lo <= value < hi."""
        return sorted((s, p, v) for v, uses in self.literal_uses.items() if lo <= v < hi for s, p in uses)

    def words_equal(self, value: int) -> list[int]:
        """Aligned words equal to value anywhere in the loaded regions, excluding reachable code."""
        out = []
        code_words = self._code_addrs
        for r in self.d.img.regions:
            for va, w in self.d.img.words(r):
                if w == value and va not in code_words:
                    out.append(va)
        return out

    @cached_property
    def _code_addrs(self) -> set[int]:
        s = set()
        for insns in self.reachable.values():
            for i in insns:
                s.update(range(i.addr, i.addr + i.size))
        return s

    # ---- constant tracking --------------------------------------------------------------------
    @cached_property
    def accesses(self) -> list[Access]:
        out = []
        for f, insns in self.reachable.items():
            targets = {t for i in insns for t in successors(i)[0] + self.d.jump_tables.get(i.addr, [])}
            regs: dict[str, int] = {}
            prev_end = None
            for i in insns:
                if i.addr in targets or (prev_end is not None and i.addr != prev_end):
                    regs = {}
                prev_end = i.addr + i.size
                self._step(i, regs, f, out)
        return out

    def _step(self, i: Insn, regs: dict[str, int], f: int, out: list[Access]):
        m, ops = i.mnem, i.ops
        lit = self.d.literal(i)
        if m == "lrw":
            r = ops.split(",")[0].strip()
            if lit is not None:
                regs[r] = lit
            else:
                regs.pop(r, None)
            return
        lm = _LDST.match(m)
        if lm:
            mm = _MEM.match(ops)
            if mm:
                rd, rb, off = mm.group(1), mm.group(2), _num(mm.group(3))
                if rb in regs:
                    out.append(Access(i.addr, f, lm.group(1), _WIDTH[lm.group(2)], (regs[rb] + off) & 0xFFFFFFFF,
                                      i.text()))
                if lm.group(1) == "ld":
                    regs.pop(rd, None)
            return
        if m in ("bsr", "jsr", "jsri"):
            for r in _CLOBBER:
                regs.pop(r, None)
            return
        mm = _RI.match(ops)
        if m in ("movi", "movih") and mm:
            v = _num(mm.group(2))
            regs[mm.group(1)] = (v << 16) if m == "movih" else v
            return
        if m in ("bseti", "bclri") and mm and mm.group(1) in regs:
            b = _num(mm.group(2))
            r = mm.group(1)
            regs[r] = regs[r] | (1 << b) if m == "bseti" else regs[r] & ~(1 << b)
            return
        if m in ("addi", "subi") and mm and mm.group(1) in regs:  # 16-bit two-operand forms
            v = _num(mm.group(2))
            regs[mm.group(1)] = (regs[mm.group(1)] + (v if m == "addi" else -v)) & 0xFFFFFFFF
            return
        mm = _RRI.match(ops)
        if mm and m in ("lsli", "ori", "addi", "subi", "lsri", "andi"):
            rd, rs, v = mm.group(1), mm.group(2), _num(mm.group(3))
            if rs in regs:
                x = regs[rs]
                regs[rd] = {"lsli": lambda: x << v, "ori": lambda: x | v, "addi": lambda: x + v,
                            "subi": lambda: x - v, "lsri": lambda: x >> v, "andi": lambda: x & v}[m]() & 0xFFFFFFFF
            else:
                regs.pop(rd, None)
            return
        mm = _TWO.match(ops)
        if m == "mov" and mm:
            if mm.group(2) in regs:
                regs[mm.group(1)] = regs[mm.group(2)]
            else:
                regs.pop(mm.group(1), None)
            return
        # anything else writing its first register operand invalidates it
        first = ops.split(",")[0].strip() if ops else ""
        if re.fullmatch(_REG, first) and not m.startswith(("cmp", "st", "b", "tst", "j")):
            regs.pop(first, None)

    def accesses_in(self, lo: int, hi: int) -> list[Access]:
        return sorted((a for a in self.accesses if lo <= a.addr < hi), key=lambda a: a.site)
