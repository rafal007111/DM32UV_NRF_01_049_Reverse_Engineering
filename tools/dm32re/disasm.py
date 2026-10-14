"""Whole-image disassembly with GNU binutils for csky-elfabiv2, cached as JSON.

`objdump -b binary` mis-decodes 32-bit C-SKY instructions (it prints them as two `.long` halves) and
computes wrong `lrw` pool addresses, so the image regions are wrapped in an ELF with `.incbin`:
- a function symbol at every catalog entry (objdump re-synchronises at each symbol);
- `$d`/`$t` mapping symbols around literal-pool words, found iteratively from the `lrw` pool
  addresses of the previous pass, so pools are printed as data and do not desynchronise decoding.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from . import catalog as catmod
from .image import BUILD, Image, Region

TOOL_DIRS = [Path(os.environ.get("DM32_CSKY_BINUTILS", "/opt/csky-binutils/bin"))]
CACHE_VERSION = 6


def tool(name: str) -> str:
    exe = f"csky-elfabiv2-{name}"
    for d in TOOL_DIRS:
        if (d / exe).exists():
            return str(d / exe)
    found = shutil.which(exe)
    if not found:
        raise FileNotFoundError(f"{exe} not found; run tools/setup_cloud.sh or set DM32_CSKY_BINUTILS")
    return found


@dataclass
class Insn:
    addr: int
    size: int
    mnem: str
    ops: str
    target: int | None = None  # branch/call destination printed by objdump
    pool: int | None = None  # lrw literal-pool address
    data: bool = False  # literal-pool word printed as .long/.short

    def to_list(self) -> list:
        return [self.addr, self.size, self.mnem, self.ops, self.target, self.pool, self.data]

    @staticmethod
    def from_list(v: list) -> "Insn":
        return Insn(*v)

    def text(self) -> str:
        return f"{self.mnem} {self.ops}".strip()


_LINE = re.compile(r"^\s*([0-9a-f]+):\t([0-9a-f]+)\s*\t(\S+)\s*(?:\t(.*))?$")
_POOL = re.compile(r"from address pool at ([0-9a-f]+)")
_TGT = re.compile(r"//\s*([0-9a-f]+)\b")
_BRANCHY = re.compile(r"^(b|j)")  # br, bsr, bt, bf, bez, bnez, jmp, jsr, jmpi, jsri ...


def pool_address(addr: int, raw: int, size: int, mnem: str) -> int | None:
    """Literal-pool address of a PC-relative load (CK803 encodings from binutils csky-opc.h)."""
    if size == 2 and mnem == "lrw":
        imm = (raw & 0x1F) | (((raw >> 8) & 3) << 5)
        if raw & 0xFC00 == 0x1000:  # lrw16
            off = imm << 2
        elif raw & 0xFC00 == 0x0000:  # extended lrw16 (ELRW_CONSTANT)
            off = (0x80 + ((~imm) & 0x7F)) << 2
        else:
            return None
        return (addr + off) & ~3
    if size == 4 and mnem in ("lrw", "jsri", "jmpi") and raw >> 21 in (0xEA8 >> 1, 0xEAE >> 1, 0xEAC >> 1):
        return (addr + ((raw & 0xFFFF) << 2)) & ~3
    return None


def parse_objdump(text: str) -> list[Insn]:
    out = []
    for line in text.splitlines():
        m = _LINE.match(line)
        if not m:
            continue
        addr = int(m.group(1), 16)
        size = len(m.group(2)) // 2
        mnem = m.group(3)
        rest = (m.group(4) or "").strip()
        ops, _, comment = rest.partition("//")
        ops = ops.strip()
        ins = Insn(addr, size, mnem, ops, data=mnem.startswith((".long", ".short", ".byte")))
        pm = _POOL.search(rest)
        if pm:
            ins.pool = int(pm.group(1), 16)
        elif not ins.data:
            ins.pool = pool_address(addr, int(m.group(2), 16), size, mnem)
        if ins.pool is None and comment and _BRANCHY.match(mnem):
            tm = _TGT.search(rest)
            if tm:
                ins.target = int(tm.group(1), 16)
        out.append(ins)
    return out


def _region_asm(reg: Region, bin_path: Path, labels: dict[int, str]) -> str:
    """Assembly that .incbin's the region with a function symbol at every catalog start."""
    lines = [f'.section .r_{reg.name},"ax"']
    pos = reg.va
    for a in sorted(x for x in labels if reg.va <= x < reg.end):
        if a > pos:
            lines.append(f'.incbin "{bin_path}", {reg.file_off + pos - reg.va:#x}, {a - pos:#x}')
            pos = a
        lines.append(f".type {labels[a]},@function\n{labels[a]}:")
    if reg.end > pos:
        lines.append(f'.incbin "{bin_path}", {reg.file_off + pos - reg.va:#x}, {reg.end - pos:#x}')
    return "\n".join(lines) + "\n"


def _merge(words: set[int]) -> list[tuple[int, int]]:
    out: list[tuple[int, int]] = []
    for a in sorted(words):
        if out and out[-1][1] >= a:
            out[-1] = (out[-1][0], max(out[-1][1], a + 4))
        else:
            out.append((a, a + 4))
    return out


def _assemble(img: Image, work: Path, labels: dict[int, str]) -> Path:
    bin_path = work / "image.bin"
    bin_path.write_bytes(img.data)
    asm = "".join(_region_asm(r, bin_path, labels) for r in img.regions if r.code)
    (work / "image.S").write_text(asm)
    obj = work / "image.o"
    subprocess.run([tool("as"), "-mcpu=ck803", "-o", str(obj), str(work / "image.S")], check=True)
    return obj


def _run_pass(img: Image, work: Path, obj: Path, pools: set[int], resync: set[int]) -> list[Insn]:
    """Mark pool words with $d/$t mapping symbols (objcopy allows duplicate names), link, disassemble."""
    rsp = []
    for lo, hi in _merge(pools):
        reg = img.region(lo)
        if reg is None or not reg.code:
            continue
        rsp.append(f"--add-symbol $d=.r_{reg.name}:{lo - reg.va:#x},local")
        rsp.append(f"--add-symbol $t=.r_{reg.name}:{hi - reg.va:#x},local")
    for a in sorted(resync):
        reg = img.region(a)
        if reg is not None and reg.code:
            rsp.append(f"--add-symbol L_{a:08x}=.r_{reg.name}:{a - reg.va:#x},local,function")
    (work / "mapping.rsp").write_text("\n".join(rsp) + "\n")
    marked = work / "image.marked.o"
    subprocess.run([tool("objcopy"), f"@{work / 'mapping.rsp'}", str(obj), str(marked)], check=True)
    elf = work / "image.elf"
    sects = [f"--section-start=.r_{r.name}={r.va:#x}" for r in img.regions if r.code]
    subprocess.run([tool("ld"), "-e", "0", *sects, "-o", str(elf), str(marked)], check=True, capture_output=True)
    text = subprocess.run([tool("objdump"), "-d", str(elf)], check=True, capture_output=True, text=True).stdout
    return parse_objdump(text)


_COND = {"bt", "bf", "bez", "bnez", "bhz", "blsz", "blz", "bhsz"}
_STOP = {"rts", "br", "jmp", "jmpi", "rte", "rfi", "bkpt"}


def successors(ins: Insn) -> tuple[list[int], bool]:
    """(branch targets, falls through) for one instruction."""
    m = ins.mnem
    if ins.data:
        return [], False
    if m in _COND:
        return ([ins.target] if ins.target is not None else []), True
    if m == "br":
        return ([ins.target] if ins.target is not None else []), False
    if m in _STOP:
        return [], False
    if m == "pop" and "r15" in ins.ops:  # v2 pop with r15 returns
        return [], False
    return [], True


_LDR_IDX = re.compile(r"^(r\d+),\s*\((r\d+),\s*(r\d+)\s*<<\s*2\)$")


def jump_tables(insns: list[Insn], img: Image) -> dict[int, list[int]]:
    """jmp site -> targets for the GCC switch pattern
    `cmphsi rI, N; bt default; ...; lrw rT, table; ldr.w rJ, (rT, rI << 2); jmp rJ` (absolute tables)."""
    out: dict[int, list[int]] = {}
    for k, i in enumerate(insns):
        if i.mnem != "jmp":
            continue
        reg = i.ops.strip()
        table = count = None
        idx = None
        for j in range(k - 1, max(-1, k - 10), -1):
            p = insns[j]
            m = _LDR_IDX.match(p.ops) if p.mnem == "ldr.w" else None
            if m and m.group(1) == reg and table is None:
                base_reg, idx = m.group(2), m.group(3)
                for q in range(j - 1, max(-1, j - 6), -1):
                    if insns[q].mnem == "lrw" and insns[q].ops.startswith(base_reg + ",") and insns[q].pool is not None:
                        try:
                            table = img.u32(insns[q].pool)
                        except Exception:
                            table = None
                        break
            if p.mnem == "mov" and idx is not None and p.ops.replace(" ", "").startswith(idx + ","):
                idx = p.ops.replace(" ", "").split(",")[1]  # follow `mov rIdx, rCmp`
                continue
            if p.mnem == "cmphsi" and idx is not None and p.ops.startswith(idx + ","):
                count = int(p.ops.split(",")[1], 0)
                break
        if table is None or count is None or not 1 <= count <= 512:
            continue
        targets = []
        try:
            for n in range(count):
                t = img.u32(table + 4 * n)
                if t & 1 == 0 and img.region(t) is img.region(i.addr):
                    targets.append(t)
        except Exception:
            continue
        if targets:
            out[i.addr] = targets
    return out


def _reachable_facts(insns: list[Insn], cat: catmod.Catalog, img: Image, reached: set[int] | None = None
                     ) -> tuple[set[int], set[int]]:
    """Pool words used by reachable lrw/jsri, and branch targets that fall mid-instruction (resync points)."""
    by_addr = {i.addr: i for i in insns}
    jt = jump_tables(insns, img)
    pools: set[int] = set()
    resync: set[int] = set()
    for f in cat.funcs:
        reg = img.region(f.addr)
        if reg is None or not reg.code:
            continue
        limit = max(f.end, cat.next_start(f.addr) or f.end)
        work, seen = [f.addr], set()
        while work:
            a = work.pop()
            if a in seen or not (reg.va <= a < reg.end):
                continue
            seen.add(a)
            ins = by_addr.get(a)
            if reached is not None and ins is not None and not ins.data:
                reached.add(a)
            if ins is None or ins.data:
                if a not in by_addr or (ins is not None and ins.data and a not in pools):
                    resync.add(a)
                continue
            if ins.pool is not None and img.region(ins.pool) is reg and ins.pool > a:
                pools.add(ins.pool)
            targets, falls = successors(ins)
            for t in targets + jt.get(a, []):
                if f.addr <= t < limit:
                    work.append(t)
            if falls and a + ins.size < limit:
                work.append(a + ins.size)
    return pools, resync


class Disassembly:
    """All instructions of the code regions, by address, with per-function slices."""

    def __init__(self, insns: list[Insn], img: Image, cat: catmod.Catalog):
        self.img, self.cat = img, cat
        self.insns = sorted(insns, key=lambda i: i.addr)
        self.by_addr = {i.addr: i for i in self.insns}
        self._addrs = [i.addr for i in self.insns]
        self.pools = {i.pool for i in self.insns if i.pool is not None}
        self.jump_tables = jump_tables(self.insns, img)

    def range(self, lo: int, hi: int) -> list[Insn]:
        import bisect
        a = bisect.bisect_left(self._addrs, lo)
        b = bisect.bisect_left(self._addrs, hi)
        return self.insns[a:b]

    def function(self, addr: int, extent: str = "catalog") -> list[Insn]:
        """Instructions of a function: its catalog body, or up to the next catalog start ('gap')."""
        f = self.cat.by_addr.get(addr)
        if f is None or extent == "gap":
            end = self.cat.next_start(addr) or addr + 0x400
            if f is not None:
                end = max(end, f.end)
        else:
            end = f.end
        return self.range(addr, end)

    def code(self, addr: int) -> list[Insn]:
        return [i for i in self.function(addr) if not i.data]

    def literal(self, ins: Insn) -> int | None:
        if ins.pool is None:
            return None
        try:
            return self.img.u32(ins.pool)
        except Exception:
            return None


def _discover(insns: list[Insn], cat: catmod.Catalog, img: Image) -> dict[int, str]:
    """Function entries Ghidra's catalog lacks: bsr targets from reachable code, and words in
    flash/SRAM tables pointing at a `push` prologue in a code region."""
    by_addr = {i.addr: i for i in insns}
    found: dict[int, str] = {}
    reached: set[int] = set()
    _reachable_facts(insns, cat, img, reached)
    code_regions = [r for r in img.regions if r.code]
    for i in insns:
        if i.mnem == "bsr" and i.target is not None and i.target not in cat.by_addr:
            if i.addr in reached and any(i.target in r for r in code_regions):
                t = by_addr.get(i.target)
                if t is not None and not t.data:
                    found.setdefault(i.target, f"bsr target from {i.addr:08X}")
    for r in img.regions:
        for va, w in img.words(r):
            if w in cat.by_addr or w in found or w & 1:
                continue
            if any(w in cr for cr in code_regions):
                t = by_addr.get(w)
                if t is not None and t.mnem in ("push", "subi") and (t.mnem == "push" or "sp" in t.ops):
                    found.setdefault(w, f"code pointer at {va:08X}")
    return found


def load(which: str = "stock", refresh: bool = False) -> Disassembly:
    img = Image(which)
    base_cat = catmod.load()
    catsum = hashlib.sha256(catmod.CATALOG.read_bytes()).hexdigest()[:16]
    key = f"{which}-{img.sha256[:16]}-{catsum}-v{CACHE_VERSION}"
    BUILD.mkdir(parents=True, exist_ok=True)
    cache = BUILD / f"disasm-{key}.json"
    if cache.exists() and not refresh:
        blob = json.loads(cache.read_text())
        cat = _with_extra(base_cat, {int(k): v for k, v in blob["extra"].items()})
        return Disassembly([Insn.from_list(v) for v in blob["insns"]], img, cat)
    work = BUILD / f"work-{which}"
    work.mkdir(parents=True, exist_ok=True)
    extra: dict[int, str] = {}
    cat = base_cat
    for _round in range(4):
        labels = {f.addr: f"FUN_{f.addr:08x}" for f in cat.funcs if img.region(f.addr) and img.region(f.addr).code}
        obj = _assemble(img, work, labels)
        pools: set[int] = set()
        resync: set[int] = set()
        insns: list[Insn] = []
        for _ in range(8):  # converges in a few passes
            insns = _run_pass(img, work, obj, pools, resync)
            new_pools, new_resync = _reachable_facts(insns, cat, img)
            if new_pools <= pools and new_resync <= resync:
                break
            pools |= new_pools
            resync |= new_resync
        found = _discover(insns, cat, img)
        if not found:
            break
        extra.update(found)
        cat = _with_extra(base_cat, extra)
    cache.write_text(json.dumps({"extra": {str(k): v for k, v in extra.items()},
                                 "insns": [i.to_list() for i in insns]}))
    return Disassembly(insns, img, cat)


def _with_extra(base: catmod.Catalog, extra: dict[int, str]) -> catmod.Catalog:
    """Catalog plus discovered entries (size 0: their extent is the gap to the next start)."""
    rows = list(base.funcs) + [catmod.Function(a, f"SUB_{a:08x}", 0, "discovered", why, "discovered")
                               for a, why in extra.items() if a not in base.by_addr]
    return catmod.Catalog(rows)
