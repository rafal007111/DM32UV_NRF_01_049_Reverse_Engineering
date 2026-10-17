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
    start: int = 0  # offset in its section (pool alignment depends on it)

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
            out.append(RefFn(names, origin, code, mask, rel, strings, labels, lo))
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


# ---- normalised comparison (2026-10-17) ---------------------------------------------------------------
# The vendor toolchain release encodes some instructions differently from V3.10.29 (LIBRARY_SIGNATURES.md 3).
# norm_tokens() turns a code blob into instruction tokens that are equal for both encodings:
# - 16-bit three-operand addu/subu (0x58xx..0x5Fxx, r0-r7) with rz == rx (or rz == ry for addu) becomes the
#   two-operand form 0x6000 | rz << 6 | rx << 2 (addu) / | 2 (subu), the only form V3.10.29 emits;
# - a run of self-extensions zextb/zexth/sextb/sexth rx, rx (16-bit 0x74xx) at the function start is dropped;
# - PC-relative fields are masked (br/bt/bf 16 and 32 bit, bez..bhsz, bsr32, lrw16/32, jsri/jmpi), so a
#   removed instruction or a moved literal pool does not change the other tokens;
# - literal-pool words (found from the lrw/jsri/jmpi pool addresses) become data tokens, and a nop/zero
#   halfword that only aligns a pool is dropped.
# Register allocation is not normalised: a function that differs in register choice stays a near row.
NORM_NEAR = 0.90  # difflib ratio on normalised tokens for a "norm-near" row
NORM_RANGE = (0x0306D7E0, 0x03072800)  # application library block (libm, soft-float, libc) compared by --norm


def _is32(h: int) -> bool:
    return h & 0xC000 == 0xC000


def norm_insn(h: int, lo: int | None = None) -> tuple:
    """Normalised token of one instruction: (size, value with PC-relative bits cleared)."""
    if lo is not None:  # 32-bit: first halfword is the high part
        w = h << 16 | lo
        if w >> 26 == 0x38:  # bsr32
            return (4, w & ~0x3FFFFFF)
        if h & 0xFF9F in (0xE800, 0xE840, 0xE860) or 0xE900 <= h <= 0xE9BF:  # br/bf/bt, bez..bhsz
            return (4, w & ~0xFFFF)
        if h & 0xFFE0 in (0xEA80, 0xEAC0, 0xEAE0):  # lrw32 rz, jmpi32, jsri32
            return (4, w & ~0xFFFF)
        return (4, w)
    top = h & 0xFC00
    if top in (0x0400, 0x0800, 0x0C00):  # br16 / bt16 / bf16
        return (2, h & ~0x03FF)
    if top == 0x1000 or (top == 0x0000 and h != 0):  # lrw16 / extended lrw16: keep rz (bits 7:5)
        return (2, h & ~0x031F)
    if h & 0xF800 == 0x5800 and h & 3 in (0, 1):  # addu16/subu16 rz, rx, ry (three-operand)
        rx, rz, ry, sub = h >> 8 & 7, h >> 5 & 7, h >> 2 & 7, h & 1
        if rz == rx:
            return (2, 0x6000 | rz << 6 | ry << 2 | sub << 1)
        if rz == ry and not sub:
            return (2, 0x6000 | rz << 6 | rx << 2)
    return (2, h)


def _pool_target(addr: int, h: int, lo: int | None) -> int | None:
    if lo is None:
        top = h & 0xFC00
        if top == 0x1000 or (top == 0x0000 and h != 0):
            imm = (h & 0x1F) | ((h >> 8) & 3) << 5
            off = imm << 2 if top == 0x1000 else (0x80 + ((~imm) & 0x7F)) << 2
            return (addr + off) & ~3
        return None
    if h & 0xFFE0 in (0xEA80, 0xEAC0, 0xEAE0):
        return (addr + (lo << 2)) & ~3
    return None


def norm_tokens(code: bytes, mask: bytes | bytearray | None = None, limit: int | None = None,
                with_end: bool = False, base: int = 0):
    """Normalised tokens of a function starting at code[0] (see the comment above).

    mask (reference side): 0 bytes are relocations; a pool word under a relocation becomes ("D", None).
    limit: stop after this many tokens (firmware side, where the function length is not known exactly);
    with_end: also return the number of bytes consumed;
    base: address (or section offset) of code[0]; literal pools are 4-aligned absolutely."""
    out: list[tuple] = []
    pools: set[int] = set()
    i, start = 0, True
    n = len(code)
    while i + 2 <= n and (limit is None or len(out) < limit):
        if i in pools and i + 4 <= n:
            word = struct.unpack_from("<I", code, i)[0]
            reloc = mask is not None and not all(mask[i:i + 4])
            out.append(("D", None if reloc else word))
            i += 4
            continue
        h = struct.unpack_from("<H", code, i)[0]
        if (i + 2) in pools and h in (0x6C03, 0x0000):  # alignment filler before a pool
            i += 2
            continue
        if _is32(h) and i + 4 <= n:
            lo = struct.unpack_from("<H", code, i + 2)[0]
            t = norm_insn(h, lo)
            p = _pool_target(base + i, h, lo)
            size = 4
        else:
            lo = None
            t = norm_insn(h)
            p = _pool_target(base + i, h, None)
            size = 2
        if p is not None and p - base > i:
            pools.add(p - base)
        if start and lo is None and h & 0xFC00 == 0x7400 and (h >> 6 & 15) == (h >> 2 & 15):
            i += 2  # leading self-extension zextb/zexth/sextb/sexth rx, rx
            continue
        start = False
        out.append(("I",) + t)
        i += size
    return (out, i) if with_end else out


# Register fields per instruction format, cleared by blind() for a register-blind ratio (heuristic, lead
# quality only): 16-bit formats by their top bits, 32-bit formats keep the major opcode and sub-opcode bits.
_REG16 = [(0xF800, 0x5800, 0x07FC), (0xC000, 0x4000, 0x07E0 & 0xFFFF), (0xC000, 0x8000, 0x07E0),
          (0xE000, 0x2000, 0x0700), (0xFC00, 0x1800, 0x0700), (0xF000, 0x6000, 0x03FC), (0xF000, 0x7000, 0x03FC)]


def blind(t: tuple) -> tuple:
    """Token with register fields cleared (see _REG16); data tokens lose their value."""
    if t[0] == "D":
        return ("D",)
    _, size, v = t
    if size == 4:
        return ("I", 4, v & ~(0x3FF << 16) & ~0x1F if v >> 26 != 0x38 else v)
    for m, val, regs in _REG16:
        if v & m == val:
            return ("I", 2, v & ~regs)
    return t


def norm_compare(ref: list[tuple], fw: list[tuple], regs_blind: bool = False) -> tuple[bool, float]:
    """(identical after normalisation, difflib ratio). Relocated pool words (None) match any word.
    regs_blind: the ratio ignores register fields (blind()); identity is always register-exact."""
    import difflib
    same = len(ref) == len(fw) and all(a == b or (a[0] == b[0] == "D" and None in (a[1], b[1]))
                                       for a, b in zip(ref, fw))
    key = blind if regs_blind else (lambda t: ("D",) if t[0] == "D" else t)  # ratio ignores pool values
    ratio = difflib.SequenceMatcher(None, [key(t) for t in ref], [key(t) for t in fw], autojunk=False).ratio()
    return same, ratio


NORM_LEAD = 0.25  # register-blind ratio for a "norm-lead" row (rank-1 candidate only, never a name by itself)
NORM_LEAD_MARGIN = 0.03  # ... and this far ahead of the best candidate with another name


def norm_pass(img: Image, refs: list[RefFn], cat, lo: int, hi: int, skip: set) -> list[Match]:
    """Compare every catalog function in [lo, hi) not in skip with every reference of similar size.

    norm: identical after normalisation; norm-near: register-exact ratio >= NORM_NEAR; norm-lead: otherwise
    the best register-blind candidate if its ratio is >= NORM_LEAD and clearly ahead of other names."""
    sp = Space(img)
    pool = []
    for f in refs:
        if len(f.code) >= 12 and f.fixed * 2 >= len(f.code):
            pool.append((f, norm_tokens(f.code, f.mask, base=f.start)))
    out = []
    for fn in cat.funcs:
        if not lo <= fn.addr < hi or fn.addr in skip or fn.size < 8:
            continue
        o = sp.off(fn.addr)
        best = (False, 0.0, None)
        blind_rank: list[tuple[float, str, RefFn]] = []
        cache: dict[int, tuple[list[tuple], int]] = {}
        for f, rt in pool:
            if abs(fn.size - len(f.code)) > max(32, len(f.code) // 3):
                continue
            nlen = len(rt)
            # firmware tokens: as many as the reference has, read from enough bytes to cover them
            if nlen not in cache:
                cache[nlen] = norm_tokens(img.data[o:o + 4 * nlen + 64], None, limit=nlen, with_end=True,
                                          base=fn.addr)
            fw, end = cache[nlen]
            if len(fw) < nlen:
                continue
            same, r = norm_compare(rt, fw)
            same = same and end >= fn.size - 2  # a prefix of a longer function is not a match
            if (same, r) > best[:2]:
                best = (same, r, f)
            blind_rank.append((norm_compare(rt, fw, regs_blind=True)[1], f.key, f))
        same, r, f = best
        if f is not None and (same or r >= NORM_NEAR):
            out.append(Match(fn.addr, sp.va(o)[1], set(f.names), {f.lib}, fn.size, 0,
                             "norm" if same else "norm-near", 1, ratio=round(r, 3)))
        elif blind_rank:
            blind_rank.sort(key=lambda x: -x[0])
            rb, key, fb = blind_rank[0]
            other = next((x[0] for x in blind_rank if x[1] != key and not set(x[2].names) & set(fb.names)), 0.0)
            if rb >= NORM_LEAD and rb - other >= NORM_LEAD_MARGIN:
                out.append(Match(fn.addr, sp.va(o)[1], set(fb.names), {fb.lib}, fn.size, 0, "norm-lead", 1,
                                 ratio=round(rb, 3)))
    return out


def strength(m: Match) -> str:
    if m.method in ("call-target", "data-ref", "norm-lead"):
        return "lead"
    if m.method == "norm":
        return "norm"
    if m.method in ("near", "norm-near"):
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
                        m.size, m.fixed, m.method, strength(m), m.hits, m.ratio if m.method in ("near", "norm", "norm-near", "norm-lead") else "", m.agree, m.disagree, m.str_ok,
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
    if getattr(args, "norm", False):
        done = {m.va for m in rows if m.method.startswith("bytes")}
        at = {m.va: i for i, m in enumerate(rows)}
        for m in norm_pass(img, refs, cat, NORM_RANGE[0], NORM_RANGE[1], done):
            i = at.get(m.va)
            if i is None:
                rows.append(m)
            elif m.method == "norm-lead":
                continue  # an existing row (exact, near or a relocation lead) is better evidence
            elif rows[i].method in ("call-target", "data-ref", "near") and (m.method == "norm" or m.ratio > rows[i].ratio):
                m.agree, m.callers, m.names = rows[i].agree, rows[i].callers, m.names | rows[i].names
                rows[i] = m
        rows.sort(key=lambda m: m.va)
    kinds = defaultdict(int)
    for m in rows:
        kinds[strength(m)] += 1
    print(f"reference functions: {len(refs)}; firmware rows: {len(rows)} " +
          " ".join(f"{k}={v}" for k, v in sorted(kinds.items())))
    for m in rows:
        if args.all or strength(m) in ("exact", "exact-short", "norm", "near", "near-conflict", "conflict"):
            c = cat.by_addr.get(m.va)
            print(f"{m.va:08X} {m.region:<5} {strength(m):<11} {m.method:<11} {m.fixed:>5} "
                  f"{'r=%.2f' % m.ratio if m.method in ('near', 'norm', 'norm-near', 'norm-lead') else 'agree=%d' % m.agree} str={m.str_ok}/{m.str_ok + m.str_bad} {','.join(sorted(m.names))[:60]:<60} "
                  f"{c.name + ' ' + c.confidence if c else '(no catalog row)'}")
    if args.csv:
        write_csv(Path(args.csv), rows, cat)
    return 0
