"""Identify library functions (uC/OS-III kernel, uC/LIB, libc) by comparing reference objects
built with csky-elfabiv2-gcc (tools/libref/build_ucos3.sh) against firmware functions.

Signals, combined into one score:
- mnemonic sequence ratio (difflib) of reachable firmware code vs. the reference function;
- distinctive constants: immediates >= 256 and non-address literals (uC/OS-III error codes such as
  24001 and object type tags such as 0x414D4553 'SEMA' are stable across kernel versions);
- call-graph agreement: how many of the reference function's callees are matched by functions the
  firmware candidate actually calls.
Every result is a lead (inferred), never a code-verified name: the firmware has an older uC/OS-III
and a different compiler than the reference objects.
"""

from __future__ import annotations

import csv
import math
import re
import subprocess
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from difflib import SequenceMatcher
from pathlib import Path

from .disasm import Insn, parse_objdump, tool

_FUNC_HDR = re.compile(r"^[0-9a-f]+ <([^>]+)>:$")
_RELOC = re.compile(r"^\s+([0-9a-f]+): (R_CKCORE_\S+)\s+(\S+)")
_IMM = re.compile(r"(?<![\w(])(-?(?:0x[0-9a-f]+|\d+))(?![\w)])")


@dataclass
class Fn:
    key: str  # reference: "opt/name"; firmware: address hex
    name: str
    mnems: list[str]
    consts: set[int]
    callees: set = field(default_factory=set)
    calls: list = field(default_factory=list)  # callee sequence in address order
    hist: Counter = field(default_factory=Counter)

    def __post_init__(self):
        self.hist = Counter(self.mnems)


def _consts(insns: list[Insn], literal_of) -> set[int]:
    out = set()
    for i in insns:
        if i.data or i.target is not None:
            continue
        lit = literal_of(i)
        if lit is not None:
            out.add(lit)
            continue
        if i.mnem.startswith(("ld", "st", "push", "pop", "ldr", "str")):
            continue  # offsets and register lists
        for m in _IMM.findall(i.ops.split("//")[0]):
            v = int(m, 0)
            if v >= 256:
                out.add(v & 0xFFFFFFFF)
    return out


def load_reference(objects: list[str]) -> list[Fn]:
    fns = []
    for obj in objects:
        opt = Path(obj).parent.name
        text = subprocess.run([tool("objdump"), "-dr", obj], capture_output=True, text=True, check=True).stdout
        cur, lines, relocs = None, [], {}
        blocks = []
        for line in text.splitlines():
            m = _FUNC_HDR.match(line)
            if m:
                if cur:
                    blocks.append((cur, lines, relocs))
                cur, lines, relocs = m.group(1), [], {}
                continue
            r = _RELOC.match(line)
            if r and cur:
                relocs[int(r.group(1), 16)] = (r.group(2), r.group(3))
                continue
            if cur:
                lines.append(line)
        if cur:
            blocks.append((cur, lines, relocs))
        for name, lines, relocs in blocks:
            insns = parse_objdump("\n".join(lines))
            addr_lits = {off for off, (t, _) in relocs.items() if "ADDR32" in t}
            pools = {i.addr: i.pool for i in insns if i.pool is not None}

            def lit(i, insns=insns, addr_lits=addr_lits):
                if i.pool is None or i.pool in addr_lits:
                    return None
                m = re.match(r"^r\d+,\s*(0x[0-9a-f]+)", i.ops)
                return int(m.group(1), 16) if m and i.mnem == "lrw" else None

            # cut the trailing literal pool: code ends where data starts
            code = [i for i in insns if not i.data]
            calls = [relocs[i.addr][1] for i in code if i.mnem == "bsr" and i.addr in relocs]
            fns.append(Fn(f"{opt}/{name}", name, [i.mnem for i in code], _consts(code, lit), set(calls), calls))
    return fns


def load_firmware(ctx) -> list[Fn]:
    d, x = ctx.d, ctx.x
    out = []

    def lit(i):
        v = d.literal(i)
        if v is None:
            return None
        if d.img.region(v) is not None or 0x10000 <= v < 0x60000 or 0x11000000 <= v < 0x12000000:
            return None  # addresses are not portable signals
        return v

    for f, insns in x.reachable.items():
        if len(insns) < 4:
            continue
        calls = [t for _, t, k in sorted(x.callees_of.get(f, [])) if k == "bsr"]
        out.append(Fn(f"{f:08X}", ctx.name(f), [i.mnem for i in insns], _consts(insns, lit), set(calls), calls))
    return out


def _cos(a: Counter, b: Counter) -> float:
    dot = sum(v * b.get(k, 0) for k, v in a.items())
    na = math.sqrt(sum(v * v for v in a.values()))
    nb = math.sqrt(sum(v * v for v in b.values()))
    return dot / (na * nb) if na and nb else 0.0


def score(r: Fn, f: Fn) -> tuple[float, float, float]:
    ratio = SequenceMatcher(None, r.mnems, f.mnems, autojunk=False).ratio()
    if r.consts or f.consts:
        cj = len(r.consts & f.consts) / max(1, len(r.consts | f.consts))
        s = 0.6 * ratio + 0.4 * cj if r.consts else ratio
    else:
        cj = 0.0
        s = ratio
    return s, ratio, cj


def match(ref: list[Fn], fw: list[Fn], shortlist: int = 25) -> dict[str, list[tuple[float, float, float, Fn]]]:
    """reference key -> best firmware candidates [(score, ratio, const jaccard, fn)]."""
    by_const = defaultdict(set)
    for f in fw:
        for c in f.consts:
            by_const[c].add(f.key)
    fw_by_key = {f.key: f for f in fw}
    out = {}
    for r in ref:
        if len(r.mnems) < 6:
            continue
        lr = len(r.mnems)
        pool = [f for f in fw if 0.4 <= len(f.mnems) / lr <= 2.5]
        ranked = sorted(pool, key=lambda f: -_cos(r.hist, f.hist))[:shortlist]
        extra = {k for c in r.consts for k in by_const.get(c, ())} - {f.key for f in ranked}
        ranked += [fw_by_key[k] for k in extra if 0.3 <= len(fw_by_key[k].mnems) / lr <= 3]
        res = sorted(((*score(r, f), f) for f in ranked), key=lambda t: -t[0])
        out[r.key] = res[:3]
    return out


# runtime helpers the reference port calls but whose firmware counterparts are port-specific
_PORT = {"CPU_SR_Save", "CPU_SR_Restore", "CPU_IntDis", "CPU_IntEn", "CPU_CntLeadZeros", "CPU_CntTrailZeros",
         "OSCtxSw", "OSIntCtxSw", "OSStartHighRdy", "memset", "memcpy"}


def strength(ratio: float, cj: float, nconst: int, ref_len: int, margin: float) -> str:
    if nconst >= 3 and cj >= 0.5 and ratio >= 0.4:
        return "strong"
    if ref_len >= 20 and ratio >= 0.85 and margin >= 0.1:
        return "strong"
    if ref_len >= 12 and ratio >= 0.7 and margin >= 0.05:
        return "medium"
    return "weak"


def propagate(anchors: dict[str, int], ref_by_name: dict[str, Fn], fw_by_addr: dict[int, Fn]) -> dict[str, tuple]:
    """Callee positions: when a matched pair calls the same number of non-port functions, the k-th
    reference callee is proposed for the k-th firmware callee. Iterates to a fixpoint."""
    found: dict[str, tuple] = {}
    changed = True
    while changed:
        changed = False
        for name, fa in list(anchors.items()) + [(n, v[0]) for n, v in found.items()]:
            r, f = ref_by_name.get(name), fw_by_addr.get(fa)
            if r is None or f is None:
                continue
            rc = [c for c in r.calls if c not in _PORT]
            # drop the firmware's critical-section helpers: callees also called around every rc call
            fc = [c for c in f.calls]
            if len(fc) != len(r.calls):
                continue
            pairs = [(rn, fx) for rn, fx in zip(r.calls, fc) if rn not in _PORT]
            if len(pairs) != len(rc):
                continue
            for rn, fx in pairs:
                if rn in anchors or rn in found:
                    continue
                found[rn] = (fx, name)
                changed = True
    return found


def run(ctx, args) -> int:
    objs = []
    for o in args.objects:
        p = Path(o)
        objs += [str(q) for q in sorted(p.rglob("*.o"))] if p.is_dir() else [o]
    ref = load_reference(objs)
    fw = load_firmware(ctx)
    res = match(ref, fw)
    best: dict[str, tuple] = {}
    for key, cands in res.items():
        if not cands:
            continue
        name = key.split("/", 1)[1]
        top = cands[0]
        margin = top[0] - (cands[1][0] if len(cands) > 1 else 0.0)
        if name not in best or top[0] > best[name][1][0]:
            best[name] = (key, top, margin)
    ref_by_key = {r.key: r for r in ref}
    rows = []
    for name, (key, (s, ratio, cj, f), margin) in best.items():
        r = ref_by_key[key]
        st = strength(ratio, cj, len(r.consts), len(r.mnems), margin)
        rows.append({"name": name, "ref": key, "firmware": f.key, "method": "similarity", "strength": st,
                     "score": f"{s:.3f}", "ratio": f"{ratio:.3f}", "const_jaccard": f"{cj:.3f}",
                     "margin": f"{margin:.3f}", "ref_insns": len(r.mnems), "fw_insns": len(f.mnems),
                     "catalog": f.name[:80], "confidence": "inferred"})
    anchors = {r["name"]: int(r["firmware"], 16) for r in rows if r["strength"] == "strong"}
    ref_by_name = {}
    for r in ref:  # Os objects as the canonical call order
        if r.key.startswith("Os/") or r.name not in ref_by_name:
            ref_by_name[r.name] = r
    fw_by_addr = {int(f.key, 16): f for f in fw}
    prop = propagate(anchors, ref_by_name, fw_by_addr)
    by_name = {r["name"]: r for r in rows}
    for name, (fa, via) in prop.items():
        row = by_name.get(name)
        agrees = row is not None and int(row["firmware"], 16) == fa
        if row is not None and agrees:
            row["method"] = "similarity+callgraph"
            if row["strength"] != "strong":
                row["strength"] = "medium" if row["strength"] == "weak" else "strong"
        else:
            f = fw_by_addr.get(fa)
            r = ref_by_name.get(name)
            s, ratio, cj = score(r, f) if r and f and r.mnems and f.mnems else (0, 0, 0)
            new = {"name": name, "ref": f"call position in {via}", "firmware": f"{fa:08X}", "method": "callgraph",
                   "strength": "medium" if ratio >= 0.5 else "weak", "score": f"{s:.3f}", "ratio": f"{ratio:.3f}",
                   "const_jaccard": f"{cj:.3f}", "margin": "", "ref_insns": len(r.mnems) if r else 0,
                   "fw_insns": len(f.mnems) if f else 0, "catalog": ctx.name(fa)[:80], "confidence": "inferred"}
            if row is None or float(row["score"]) < 0.6 or row["strength"] == "weak":
                by_name[name] = new
    rows = [r for r in by_name.values() if float(r["score"] or 0) >= args.min or r["method"] != "similarity"]
    order = {"strong": 0, "medium": 1, "weak": 2}
    rows.sort(key=lambda r: (order[r["strength"]], -float(r["score"] or 0)))
    claims = Counter(r["firmware"] for r in rows if r["strength"] != "weak")
    for r in rows:
        r["shared"] = claims[r["firmware"]] > 1
    if args.csv and rows:
        with open(args.csv, "w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
    for r in rows:
        if r["strength"] == "weak" and not args.all:
            continue
        print(f"{r['firmware']} {r['strength']:<6} {r['method']:<20} score={r['score']} ratio={r['ratio']} "
              f"const={r['const_jaccard']}{' SHARED' if r['shared'] else ''}  {r['name']}  ({r['ref']})")
    n = Counter(r["strength"] for r in rows)
    print(f"; strong={n['strong']} medium={n['medium']} weak={n['weak']} from {len(ref)} reference functions "
          f"({len({r.name for r in ref})} names), {len(fw)} firmware functions")
    return 0
