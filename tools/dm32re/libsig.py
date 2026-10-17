"""Exact library signatures from the pinned T-HEAD toolchain (V3.10.29 B20210423).

The vendor linked (a build of) the same minilibc/libgcc as the toolchain ships, so library functions can be
found byte for byte instead of by similarity (libid.py). For every function in the toolchain's ck803
little-endian archives and crt objects:

- bytes covered by a relocation (R_CKCORE_PCREL_IMM26BY2 = bsr32, R_CKCORE_ADDR32 = pool word) are masked;
- the longest unmasked run is searched in the whole program image (boot prefix, application, IRAM copy)
  and every hit is checked over the full function;
- for each hit the relocations are read back from the firmware: bsr32 targets and pool words. A call from a
  matched function to a symbol that also matched must land on that match (agree/disagree counts), a pool
  word that points at a string literal must hold the same string;
- relocation targets that did not match by bytes are named from the relocation (method "call-target"
  or "data-ref"); the library bytes of a call target are then compared at that address, which also settles
  functions that occur several times;
- uniqueness is counted per program: the boot prefix (03000000..0300C000) and the application (flash + IRAM)
  each link their own copy (e.g. strlen);
- "near": call targets and functions inside the library block that did not match exactly are compared with
  every reference function of similar length (difflib ratio on bytes, relocation bytes zeroed). The vendor
  libc was built by a different toolchain release (2026-10-17: the vendor code uses 16-bit three-operand
  addu/subu with rz == rx, which V3.10.29 never emits), so several functions differ only in encoding or in a
  dropped zextb. A near row is a lead (inferred), not a match.

Results are evidence for names, not for behaviour: a byte-identical library function is the library
function, but the vendor may call it differently. Pure Python, no binutils needed. Read-only.
"""

from __future__ import annotations

import csv
import struct
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

from .image import FLASH_BASE, Image

R_NONE, R_ADDR32, R_PCREL26 = 0, 1, 0x13
STT_NOTYPE, STT_FUNC, STT_SECTION = 0, 2, 3
SHF_EXECINSTR = 4
NEAR_MIN = 0.88  # difflib ratio for a near row
MIN_ANCHOR = 8  # shortest unmasked run used to search
STRONG = 24  # unmasked bytes needed for a single hit to count as an exact match
# Archive and crt directories relative to the toolchain root (little endian ck803 only; no C++ runtime).
LIB_DIRS = ["lib/gcc/csky-elfabiv2/6.3.0/ck803", "csky-elfabiv2/lib/ck803"]
VARIANTS = ["", "soft-fp", "hard-fp"]
SKIP_ARCHIVES = ("libstdc++.a", "libsupc++.a", "libgcov.a")


# ---- archive and ELF32 parsing (stdlib only) -----------------------------------------------------------
def ar_members(path: Path):
    """(name, bytes) of every object in a System V / GNU archive."""
    data = path.read_bytes()
    if not data.startswith(b"!<arch>\n"):
        raise ValueError(f"{path} is not an ar archive")
    pos, longnames = 8, b""
    while pos + 60 <= len(data):
        hdr = data[pos:pos + 60]
        name = hdr[:16].decode("latin-1").rstrip()
        size = int(hdr[48:58].decode().strip())
        body = data[pos + 60:pos + 60 + size]
        pos += 60 + size + (size & 1)
        if name == "//":
            longnames = body
        elif name in ("/", "/SYM64/"):
            continue
        else:
            if name.startswith("/") and name[1:].isdigit():
                off = int(name[1:])
                name = longnames[off:longnames.index(b"/\n", off)].decode("latin-1")
            yield name.rstrip("/"), body


@dataclass
class Section:
    name: str
    type: int
    flags: int
    data: bytes
    link: int
    info: int


@dataclass
class Symbol:
    name: str
    value: int
    size: int
    type: int
    bind: int
    shndx: int


@dataclass
class Reloc:
    off: int
    type: int
    sym: Symbol
    addend: int


def parse_elf(blob: bytes):
    if blob[:4] != b"\x7fELF" or blob[4] != 1 or blob[5] != 1:
        raise ValueError("not a little-endian ELF32 object")
    shoff, = struct.unpack_from("<I", blob, 0x20)
    shentsize, shnum, shstrndx = struct.unpack_from("<HHH", blob, 0x2E)
    raw = [struct.unpack_from("<IIIIIIIIII", blob, shoff + i * shentsize) for i in range(shnum)]
    names = raw[shstrndx]
    nm = lambda strtab, o: blob[strtab + o:blob.index(b"\0", strtab + o)].decode("latin-1")
    secs = [Section(nm(names[4], s[0]), s[1], s[2], blob[s[4]:s[4] + s[5]] if s[1] != 8 else b"", s[6], s[7])
            for s in raw]
    syms: list[Symbol] = []
    for i, s in enumerate(raw):
        if s[1] == 2:  # SHT_SYMTAB
            strtab = raw[s[6]][4]
            for k in range(s[5] // 16):
                n, v, sz, info, _, shndx = struct.unpack_from("<IIIBBH", blob, s[4] + k * 16)
                syms.append(Symbol(nm(strtab, n), v, sz, info & 15, info >> 4, shndx))
    for s in syms:
        if s.type == STT_SECTION and 0 < s.shndx < len(secs):
            s.name = secs[s.shndx].name
    relocs: dict[int, list[Reloc]] = defaultdict(list)
    for s in raw:
        if s[1] == 4:  # SHT_RELA
            for k in range(s[5] // 12):
                off, info, add = struct.unpack_from("<IIi", blob, s[4] + k * 12)
                relocs[s[7]].append(Reloc(off, info & 0xFF, syms[info >> 8], add))
    return secs, syms, relocs


# ---- reference functions -----------------------------------------------------------------------------
@dataclass
class RefFn:
    names: list[str]
    lib: str  # e.g. "soft-fp/libc.a:memcpy.o"
    code: bytes
    mask: bytearray  # 1 = must match
    relocs: list[Reloc]  # offsets relative to the function start
    strings: dict[int, bytes] = field(default_factory=dict)  # reloc offset -> referenced NUL-terminated string
    labels: dict[int, str] = field(default_factory=dict)  # reloc offset -> local data label ("malloc.o:F")

    @property
    def key(self) -> str:
        return self.names[0]

    @property
    def fixed(self) -> int:
        return sum(self.mask)


def _functions(obj: bytes, origin: str) -> list[RefFn]:
    secs, syms, relocs = parse_elf(obj)
    out = []
    for idx, sec in enumerate(secs):
        if not (sec.flags & SHF_EXECINSTR) or not sec.data:
            continue
        starts: dict[int, list[Symbol]] = defaultdict(list)
        for s in syms:
            if s.shndx == idx and s.type in (STT_FUNC, STT_NOTYPE) and s.name and not s.name.startswith(("$", ".L")):
                starts[s.value].append(s)
        order = sorted(starts)
        for k, lo in enumerate(order):
            nxt = order[k + 1] if k + 1 < len(order) else len(sec.data)
            sized = [s.size for s in starts[lo] if s.size]
            hi = lo + max(sized) if sized else nxt
            # the literal pool may follow .size: extend over relocations before the next symbol
            for r in relocs.get(idx, []):
                if hi <= r.off < nxt and r.type != R_NONE:
                    hi = max(hi, r.off + 4)
            hi = min(hi, len(sec.data))
            if hi - lo < 4:
                continue
            code = sec.data[lo:hi]
            mask = bytearray(b"\x01" * len(code))
            rel, strings, labels = [], {}, {}
            for r in relocs.get(idx, []):
                if lo <= r.off < hi and r.type != R_NONE:
                    o = r.off - lo
                    for b in range(o, min(o + 4, len(code))):
                        mask[b] = 0
                    rel.append(Reloc(o, r.type, r.sym, r.addend))
                    tgt = secs[r.sym.shndx] if 0 < r.sym.shndx < len(secs) else None
                    if (r.type == R_ADDR32 and r.sym.type == STT_SECTION and tgt is not None
                            and tgt.name.startswith(".rodata.str")):
                        end = tgt.data.find(b"\0", r.addend)
                        strings[o] = tgt.data[r.addend:end + 1]
                    elif r.sym.type == STT_SECTION and tgt is not None and not (tgt.flags & SHF_EXECINSTR):
                        obj = next((s.name for s in syms if s.shndx == r.sym.shndx and s.value == r.addend
                                    and s.type == 1), f"{tgt.name}+{r.addend:#x}")  # STT_OBJECT
                        labels[o] = f"{origin.rsplit(':', 1)[-1]}:{obj}"
            names = sorted({s.name for s in starts[lo]}, key=lambda n: (n.startswith("_"), n))
            out.append(RefFn(names, origin, code, mask, rel, strings, labels))
    return out


def load_reference(toolchain: Path) -> list[RefFn]:
    """All functions of the ck803 little-endian archives/crt objects, first variant wins per byte pattern."""
    refs, seen = [], set()
    for var in VARIANTS:
        for d in LIB_DIRS:
            base = toolchain / d / var if var else toolchain / d
            for p in sorted(base.glob("*.a")) + sorted(base.glob("crt*.o")):
                if p.name in SKIP_ARCHIVES:
                    continue
                members = ar_members(p) if p.suffix == ".a" else [(p.name, p.read_bytes())]
                for mname, blob in members:
                    try:
                        fns = _functions(blob, f"{var + '/' if var else ''}{p.name}:{mname}")
                    except ValueError:
                        continue
                    for f in fns:
                        sig = (f.code, bytes(f.mask), tuple(f.names))
                        if sig not in seen:
                            seen.add(sig)
                            refs.append(f)
    return refs


# ---- firmware side -----------------------------------------------------------------------------------
def bsr32_target(img_data: bytes, off: int, va: int) -> int | None:
    hi, lo = struct.unpack_from("<HH", img_data, off)
    w = hi << 16 | lo
    if w >> 26 != 0x38:
        return None
    imm = w & 0x3FFFFFF
    if imm & 0x2000000:
        imm -= 0x4000000
    return (va + (imm << 1)) & 0xFFFFFFFF


class Space:
    """File offset <-> VA for the whole 1 MiB image: the IRAM copy is reported at its run address."""

    def __init__(self, img: Image):
        self.img = img
        self.iram = next(r for r in img.regions if r.name == "IRAM")
        self.used = len(img.data.rstrip(b"\xff"))

    @staticmethod
    def program(off: int) -> str:
        return "boot" if off < 0xC000 else "app"

    def va(self, off: int) -> tuple[int, str]:
        r = self.iram
        if r.file_off <= off < r.file_off + (r.end - r.va):
            return r.va + off - r.file_off, "IRAM"
        return FLASH_BASE + off, "BOOT" if off < 0xC000 else "FLASH"

    def off(self, va: int) -> int | None:
        r = self.iram
        if r.va <= va < r.end:
            return r.file_off + va - r.va
        if FLASH_BASE <= va < FLASH_BASE + len(self.img.data):
            return va - FLASH_BASE
        try:
            return self.img.file_offset(va)  # SRAM initialised data
        except Exception:
            return None


def _longest_run(mask: bytearray) -> tuple[int, int]:
    best, start = (0, 0), None
    for i, m in enumerate(list(mask) + [0]):
        if m and start is None:
            start = i
        elif not m and start is not None:
            if i - start > best[1] - best[0]:
                best = (start, i)
            start = None
    return best


def _matches_at(data: bytes, off: int, f: RefFn) -> bool:
    if off < 0 or off + len(f.code) > len(data):
        return False
    seg = data[off:off + len(f.code)]
    return all(not m or a == b for a, b, m in zip(seg, f.code, f.mask))


def find(data: bytes, f: RefFn) -> list[int]:
    lo, hi = _longest_run(f.mask)
    if hi - lo < MIN_ANCHOR:
        return []
    anchor, hits, i = f.code[lo:hi], [], data.find(f.code[lo:hi])
    while i != -1:
        st = i - lo
        if st % 2 == 0 and _matches_at(data, st, f):
            hits.append(st)
        i = data.find(anchor, i + 1)
    return hits


@dataclass
class Match:
    va: int
    region: str
    names: set
    libs: set
    size: int
    fixed: int
    method: str
    hits: int = 1
    ratio: float = 1.0
    agree: int = 0
    disagree: int = 0
    str_ok: int = 0
    str_bad: int = 0
    callers: set = field(default_factory=set)
    calls: list = field(default_factory=list)  # near rows: (target, symbol) read through the alignment


def run_match(img: Image, refs: list[RefFn]):
    sp = Space(img)
    data = img.data[:sp.used]
    found: dict[int, list[tuple[RefFn, list[int]]]] = defaultdict(list)
    by_name: dict[str, list[RefFn]] = defaultdict(list)
    for f in refs:
        for n in f.names:
            by_name[n].append(f)
        hits = find(data, f)
        if hits:
            found[id(f)].append((f, hits))

    matches: dict[int, Match] = {}

    def add(off: int, f: RefFn, method: str, hits: int):
        va, region = sp.va(off)
        m = matches.get(va)
        if m is None:
            m = matches[va] = Match(va, region, set(), set(), len(f.code), f.fixed, method, hits)
        m.names.update(f.names)
        m.libs.add(f.lib)
        if f.fixed > m.fixed:
            m.size, m.fixed = len(f.code), f.fixed
        if method == "bytes" and m.method != "bytes":
            m.method = "bytes"
        m.hits = min(m.hits, hits)
        return m

    unique = []
    for lst in found.values():
        for f, hits in lst:
            for prog in ("boot", "app"):
                mine = [h for h in hits if sp.program(h) == prog]
                if len(mine) == 1:
                    unique.append((f, mine[0]))
                    add(mine[0], f, "bytes", 1)

    # Read relocations back from the firmware for every unique hit; propagate names to targets.
    edges: dict[int, dict[str, set]] = defaultdict(lambda: defaultdict(set))
    multi = {f.key: (f, hits) for lst in found.values() for f, hits in lst
             if max(sum(sp.program(h) == p for h in hits) for p in ("boot", "app")) > 1}
    for f, off in unique:
        va, _ = sp.va(off)
        m = matches[va]
        for r in f.relocs:
            if r.type == R_PCREL26:
                tgt = bsr32_target(img.data, off + r.off, sp.va(off + r.off)[0])
            else:
                tgt = struct.unpack_from("<I", img.data, off + r.off)[0] - r.addend
            if tgt is None:
                m.disagree += 1
                continue
            if r.off in f.strings:
                to = sp.off(tgt + r.addend)
                want = f.strings[r.off]
                ok = to is not None and img.data[to:to + len(want)] == want
                m.str_ok += ok
                m.str_bad += not ok
                continue
            if r.sym.type == STT_SECTION:
                if r.off in f.labels:
                    edges[tgt + r.addend][f.labels[r.off]].add(va)
                continue  # other local section references (code, unknown) are not named
            edges[tgt][r.sym.name].add(va)
    for tgt, names in edges.items():
        for name, sites in names.items():
            known = matches.get(tgt)
            if known is not None:
                if name in known.names:
                    known.agree += len(sites)
                    known.callers |= sites
                continue
            to = sp.off(tgt)
            # library bytes at the call target settle duplicates and short functions
            cand = [f for f in by_name.get(name, []) if to is not None and _matches_at(img.data, to, f)]
            if cand:
                f = max(cand, key=lambda f: f.fixed)
                m = add(to, f, "bytes+call", len(multi.get(f.key, (f, [0]))[1]))
                m.names.add(name)
                m.agree += len(sites)
                m.callers |= sites
            else:
                va_kind = "call-target" if name in by_name else "data-ref"
                m = matches.get(tgt)
                if m is None:
                    region = "FLASH" if FLASH_BASE <= tgt < FLASH_BASE + len(img.data) else (
                        "IRAM" if tgt in sp.iram else "RAM")
                    m = matches[tgt] = Match(tgt, region, set(), set(), 0, 0, va_kind, 0)
                m.names.add(name)
                m.callers |= sites
                m.agree += len(sites)
    # Calls from matched functions that land elsewhere than the matched copy of the callee
    for tgt, names in edges.items():
        for name in names:
            for m in matches.values():
                if name in m.names and m.va != tgt and m.method.startswith("bytes") and tgt not in matches:
                    m.disagree += 1
    return sorted(matches.values(), key=lambda m: m.va), {k: len(v[1]) for k, v in multi.items()}


def near(img: Image, refs: list[RefFn], rows: list[Match], cat, margin: int = 0x1000) -> list[Match]:
    """Near rows for unmatched call targets and catalog functions around the exact application matches."""
    import difflib
    sp = Space(img)
    exact = {m.va for m in rows if m.method.startswith("bytes")}
    app = [va for va in exact if va >= FLASH_BASE + 0xC000 and sp.off(va) is not None and va < FLASH_BASE + 0x100000]
    todo = {}
    if app:
        lo, hi = min(app) - margin, max(app) + margin
        for f in cat.funcs:
            if lo <= f.addr < hi and f.addr not in exact and f.size >= 16:
                todo[f.addr] = f.size
    for m in rows:
        if m.method == "call-target" and m.va not in exact:
            f = cat.by_addr.get(m.va)
            if f and f.size >= 16:
                todo[m.va] = f.size
    pool = [(f, bytes(b if k else 0 for b, k in zip(f.code, f.mask))) for f in refs
            if len(f.code) >= 16 and f.fixed * 2 >= len(f.code)]  # skip tables made of relocations
    out = []
    for va, size in sorted(todo.items()):
        o = sp.off(va)
        best = (0.0, None)
        for f, mb in pool:
            # the reference includes its literal pool; Ghidra's body usually does not
            if not size - 8 <= len(mb) <= size + max(24, size // 4):
                continue
            fw = bytes(b if k else 0 for b, k in zip(img.data[o:o + len(mb)], f.mask))  # same positions zeroed
            sm = difflib.SequenceMatcher(None, fw, mb, autojunk=False)
            if sm.real_quick_ratio() < NEAR_MIN or sm.quick_ratio() < NEAR_MIN:
                continue
            r = sm.ratio()
            if r > best[0]:
                best = (r, f)
        r, f = best
        if f is not None and r >= NEAR_MIN:
            m = Match(va, sp.va(o)[1], set(f.names), {f.lib}, size, 0, "near", 1, ratio=round(r, 3))
            fw = bytes(b if k else 0 for b, k in zip(img.data[o:o + len(f.code)], f.mask))
            ops = difflib.SequenceMatcher(None, fw, bytes(b if k else 0 for b, k in zip(f.code, f.mask)),
                                          autojunk=False).get_opcodes()
            for rl in f.relocs:
                if rl.type != R_PCREL26 or rl.sym.type == STT_SECTION:
                    continue
                for tag, i1, i2, j1, j2 in ops:  # map the reference offset into the firmware copy
                    if j1 <= rl.off < j2 and (tag == "equal" or i2 - i1 == j2 - j1):
                        fo = i1 + rl.off - j1
                        if fo + 4 <= len(fw):
                            tgt = bsr32_target(img.data, o + fo, va + fo)
                            if tgt is not None:
                                m.calls.append((tgt, rl.sym.name))
                        break
            out.append(m)
    return out


def strength(m: Match) -> str:
    if m.method in ("call-target", "data-ref"):
        return "lead"
    if m.method == "near":
        return "near-conflict" if m.disagree else "near"
    if m.disagree or m.str_bad:
        return "conflict"
    if m.fixed >= STRONG and m.hits == 1:
        return "exact"
    if m.method == "bytes+call" or m.agree:  # short, but a matched (or near) caller calls it here
        return "exact-short"
    return "short"


def write_csv(path: Path, rows: list[Match], cat) -> None:
    with open(path, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh, lineterminator="\n")
        w.writerow(["address", "region", "symbols", "library_objects", "size", "fixed_bytes", "method", "strength",
                    "hits", "near_ratio", "call_agree", "call_disagree", "strings_ok", "strings_bad", "catalog_name",
                    "catalog_confidence"])
        for m in rows:
            c = cat.by_addr.get(m.va) if cat else None
            w.writerow([f"{m.va:08X}", m.region, ";".join(sorted(m.names)), ";".join(sorted(m.libs)[:3]),
                        m.size, m.fixed, m.method, strength(m), m.hits, m.ratio if m.method == "near" else "", m.agree, m.disagree, m.str_ok,
                        m.str_bad, c.name if c else "", c.confidence if c else ""])


def run(args) -> int:
    from . import catalog
    img = Image(args.image)
    refs = load_reference(Path(args.toolchain))
    rows, multi = run_match(img, refs)
    cat = catalog.load()
    if not args.no_near:
        extra = {m.va: m for m in near(img, refs, rows, cat)}
        for i, m in enumerate(rows):  # a near row upgrades a lead at the same address, keeping its call evidence
            if m.va in extra:
                e = extra.pop(m.va)
                e.agree, e.callers, e.names = m.agree, m.callers, m.names | e.names
                rows[i] = e
        rows = sorted(rows + list(extra.values()), key=lambda m: m.va)
        at = {m.va: m for m in rows}
        for m in [m for m in rows if m.method == "near"]:
            for tgt, name in m.calls:  # calls read from near copies corroborate (or name) their targets
                t = at.get(tgt)
                if t is None:
                    t = at[tgt] = Match(tgt, m.region, {name}, set(), 0, 0, "call-target", 0)
                    rows.append(t)
                if name in t.names:
                    t.agree += 1
                    t.callers.add(m.va)
                else:
                    m.disagree += 1
        rows.sort(key=lambda m: m.va)
    kinds = defaultdict(int)
    for m in rows:
        kinds[strength(m)] += 1
    print(f"reference functions: {len(refs)}; firmware rows: {len(rows)} " +
          " ".join(f"{k}={v}" for k, v in sorted(kinds.items())))
    for m in rows:
        if args.all or strength(m) in ("exact", "exact-short", "near", "near-conflict", "conflict"):
            c = cat.by_addr.get(m.va)
            print(f"{m.va:08X} {m.region:<5} {strength(m):<11} {m.method:<11} {m.fixed:>5} "
                  f"{'r=%.2f' % m.ratio if m.method == 'near' else 'agree=%d' % m.agree} str={m.str_ok}/{m.str_ok + m.str_bad} {','.join(sorted(m.names))[:60]:<60} "
                  f"{c.name + ' ' + c.confidence if c else '(no catalog row)'}")
    if args.csv:
        write_csv(Path(args.csv), rows, cat)
    return 0
