"""Matching-decompilation oracle: compile one C function and compare it with the firmware (read-only).

    python3 tools/dm32 match <ADDR> <file.c> [--toolchain DIR] [--cflags "..."] [--func NAME] [--sym NAME=ADDR]

`// @func NAME` and `// @sym NAME=ADDR` lines in the C file are read as if given on the command line.

The C file is compiled to an object with the candidate compiler (default $DM32_CSKY_TOOLCHAIN, the pinned
T-HEAD V3.10.29). The function is read from the object with its literal pool exactly as libsig reads library
functions (relocation bytes masked, `libsig._functions`). Both sides are then decoded into instructions and
pool words and compared item by item:

- an instruction without a PC-relative field must have identical bits;
- a PC-relative instruction (br/bt/bf 16/32, bez..bhsz, lrw 16/32, jmpi, jsri, bsr) must have identical
  non-offset bits and point at the same item (same instruction index or same pool-word index), so a pool that
  sits two bytes further because of the absolute 4-byte alignment does not count as a difference;
- a relocation on the object side is resolved against the firmware: a symbol whose name ends in an 8-digit hex
  address (`FUN_0002c504`, `DAT_0003bea8`, `gpio_set_0002C504`) or one given with `--sym NAME=ADDR` names that
  address (plus the addend); a section-relative pool word that points at a string literal matches when the
  firmware word points at the same NUL-terminated string. A bsr to the right catalog function is equal.

Verdicts (exit code): PASS (0) = identical; PASS-ENC (3) = identical except for the documented assembler
re-encoding of 16-bit addu/subu (vendor three-operand `rz == rx` form versus the two-operand form every reachable
GNU assembler emits, LIBRARY_SIGNATURES.md 3 and 9; same size, same semantics); UNRESOLVED (4) = equal where it
could be checked, but a relocation names no firmware address; FAIL (1) = anything else, with the number of
differing items ("near" count); 2 = error. The extent check compares the catalog size with the bytes covered.

Nothing is written except the temporary object under build/dm32re/match. No serial port, no image output.
"""

from __future__ import annotations

import difflib
import os
import re
import shlex
import struct
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path

from . import libsig
from .image import BUILD

PASS, PASS_ENC, FAIL, UNRESOLVED = "PASS", "PASS-ENC", "FAIL", "UNRESOLVED"
EXIT = {PASS: 0, FAIL: 1, PASS_ENC: 3, UNRESOLVED: 4}
DEFAULT_CFLAGS = "-mcpu=ck803 -Os"
_ADDR_SUFFIX = re.compile(r"(?:^|_)([0-9A-Fa-f]{8})$")


# ---- decoding ----------------------------------------------------------------------------------------
def _sext(v: int, bits: int) -> int:
    return v - (1 << bits) if v & (1 << (bits - 1)) else v


def pcrel(h: int, lo: int | None) -> tuple[str, int, int] | None:
    """(kind, bits with the PC-relative field cleared, field value) of a PC-relative instruction, else None.
    kind 'b' = branch (value = byte offset from the instruction), 'p' = pool load (value = pool address
    computed for address 0, i.e. the caller adds the instruction address and aligns)."""
    if lo is None:
        top = h & 0xFC00
        if top in (0x0400, 0x0800, 0x0C00):  # br16 / bt16 / bf16
            return "b", h & ~0x03FF, _sext(h & 0x3FF, 10) << 1
        if top == 0x1000 or (top == 0x0000 and h != 0):  # lrw16 / extended lrw16
            return "p", h & ~0x031F, 0
        return None
    w = h << 16 | lo
    if w >> 26 == 0x38:  # bsr32
        return "b", w & ~0x3FFFFFF, _sext(w & 0x3FFFFFF, 26) << 1
    if h & 0xFF9F in (0xE800, 0xE840, 0xE860) or 0xE900 <= h <= 0xE9BF:  # br/bf/bt 32, bez..bhsz
        return "b", w & ~0xFFFF, _sext(lo, 16) << 1
    if h & 0xFFE0 in (0xEA80, 0xEAC0, 0xEAE0):  # lrw32, jmpi32, jsri32
        return "p", w & ~0xFFFF, 0
    return None


@dataclass
class Item:
    off: int  # byte offset from the function start
    size: int  # 2 or 4
    kind: str  # "I" instruction, "D" pool word
    raw: int  # instruction bits (32-bit: first halfword high) or the pool word
    pc: tuple | None = None  # pcrel() result
    tgt: int | None = None  # function-relative byte offset of the branch target / pool word
    reloc: libsig.Reloc | None = None  # object side only
    filler: int = 0  # alignment bytes skipped before this item


def decode(code: bytes, base: int, limit: int | None = None, relocs: dict[int, libsig.Reloc] | None = None,
           stop: int | None = None) -> tuple[list[Item], int]:
    """Instructions and pool words of a function starting at code[0] (address or section offset `base`;
    pools are 4-aligned absolutely). Stops at the end of `code`, after `limit` items, or at byte `stop`
    (then only the pool words referenced from before `stop` are still read). Returns (items, bytes)."""
    relocs = relocs or {}
    items: list[Item] = []
    pools: set[int] = set()
    i, n, skip = 0, len(code), 0
    while i + 2 <= n and (limit is None or len(items) < limit):
        if stop is not None and i >= stop and not any(p >= i for p in pools):
            break
        if stop is not None and i >= stop and i not in pools:
            # past the end of the code only referenced pool words are read: the vendor toolchain places one
            # literal pool behind several functions (e.g. 0300C3AC uses the word at 0300C408)
            i += 2
            continue
        if i in pools and i + 4 <= n:
            items.append(Item(i, 4, "D", struct.unpack_from("<I", code, i)[0], reloc=relocs.get(i), filler=skip))
            i, skip = i + 4, 0
            continue
        h = struct.unpack_from("<H", code, i)[0]
        if (i + 2) in pools and h in (0x6C03, 0x0000):  # alignment filler in front of a pool word
            i, skip = i + 2, 2
            continue
        lo = struct.unpack_from("<H", code, i + 2)[0] if h & 0xC000 == 0xC000 and i + 4 <= n else None
        size = 4 if lo is not None else 2
        raw = h << 16 | lo if lo is not None else h
        pc = pcrel(h, lo)
        tgt = None
        if pc is not None:
            if pc[0] == "b":
                tgt = i + pc[2]
            else:
                p = libsig._pool_target(base + i, h, lo)
                tgt = p - base if p is not None else None
                if tgt is not None and tgt > i:
                    pools.add(tgt)
        items.append(Item(i, size, "I", raw, pc, tgt, relocs.get(i), skip))
        i, skip = i + size, 0
    return items, i


# ---- firmware view -----------------------------------------------------------------------------------
class FwView:
    """What the oracle needs from the firmware: bytes at an address, catalog extent and names, strings."""

    def __init__(self, image: str = "stock"):
        from . import catalog
        from .image import Image
        self.img = Image(image)
        self.sp = libsig.Space(self.img)
        self.cat = catalog.load()

    def read(self, va: int, n: int) -> bytes:
        o = self.sp.off(va)
        if o is None:
            raise ValueError(f"{va:08X} is not in the image")
        return self.img.data[o:o + n]

    def size(self, va: int) -> int | None:
        f = self.cat.by_addr.get(va)
        return f.size if f and f.size else None

    def name(self, va: int) -> str:
        f = self.cat.by_addr.get(va)
        return f.name if f else ""

    def cstring(self, va: int) -> bytes | None:
        o = self.sp.off(va)
        if o is None:
            return None
        end = self.img.data.find(b"\0", o, o + 4096)
        return self.img.data[o:end + 1] if end >= 0 else None


class BufferView(FwView):
    """A synthetic firmware (tests): {address: bytes} segments plus optional catalog sizes and names."""

    def __init__(self, segments: dict[int, bytes], sizes: dict[int, int] | None = None,
                 names: dict[int, str] | None = None):
        self.segments, self.sizes, self.names = segments, sizes or {}, names or {}

    def read(self, va: int, n: int) -> bytes:
        for a, b in self.segments.items():
            if a <= va < a + len(b):
                return b[va - a:va - a + n]
        raise ValueError(f"{va:08X} is not in the buffer")

    def size(self, va: int) -> int | None:
        return self.sizes.get(va)

    def name(self, va: int) -> str:
        return self.names.get(va, "")

    def cstring(self, va: int) -> bytes | None:
        try:
            b = self.read(va, 4096)
        except ValueError:
            return None
        end = b.find(b"\0")
        return b[:end + 1] if end >= 0 else None


# ---- compile and extract -----------------------------------------------------------------------------
PREFIXES = ("csky-elfabiv2-", "csky-abiv2-elf-")  # V3.x toolchains / older C-SKY Tools V2.x releases


def tool(toolchain: Path, name: str) -> Path:
    for prefix in PREFIXES:
        exe = toolchain / "bin" / f"{prefix}{name}"
        if exe.exists():
            return exe
    raise FileNotFoundError(f"{toolchain / 'bin'}/{{{','.join(PREFIXES)}}}{name} missing")


def compile_c(src: Path, toolchain: Path, cflags: str, out_dir: Path | None = None) -> bytes:
    out_dir = out_dir or BUILD / "match"
    out_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=out_dir) as tmp:
        obj = Path(tmp) / "f.o"
        cmd = [str(tool(toolchain, "gcc")), "-c", *shlex.split(cflags), str(src), "-o", str(obj)]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError(f"compile failed: {' '.join(cmd)}\n{r.stderr}")
        return obj.read_bytes()


def pick(obj: bytes, func: str | None, addr: int) -> libsig.RefFn:
    fns = [f for f in libsig._functions(obj, "match") if not f.names[0].startswith(".")]
    if func:
        hit = [f for f in fns if func in f.names]
        if not hit:
            raise LookupError(f"function {func} not in the object ({', '.join(f.names[0] for f in fns)})")
        return hit[0]
    tagged = [f for f in fns if any(_ADDR_SUFFIX.search(n) and int(_ADDR_SUFFIX.search(n).group(1), 16) == addr
                                    for n in f.names)]
    if tagged:
        return tagged[0]
    if len(fns) == 1:
        return fns[0]
    raise LookupError("several functions in the object; name one with --func or put the address in its name")


def symbol_address(r: libsig.Reloc, syms: dict[str, int]) -> int | None:
    name = r.sym.name
    if name in syms:
        return (syms[name] + r.addend) & 0xFFFFFFFF
    m = _ADDR_SUFFIX.search(name)
    if m and r.sym.type != libsig.STT_SECTION:
        return (int(m.group(1), 16) + r.addend) & 0xFFFFFFFF
    return None


# ---- comparison --------------------------------------------------------------------------------------
@dataclass
class Row:
    ref: Item | None
    fw: Item | None
    mark: str  # "=" equal, "~" encoding-only, "?" unresolved, "!" differs
    note: str = ""


@dataclass
class Result:
    verdict: str
    rows: list[Row]
    ref_bytes: int
    fw_bytes: int
    cat_size: int | None
    differing: int
    unresolved: int
    enc: int
    func: str


def _index(items: list[Item]) -> dict[int, int]:
    return {it.off: k for k, it in enumerate(items)}


def _enc_equal(a: int, b: int) -> bool:
    return a <= 0xFFFF and b <= 0xFFFF and libsig.norm_insn(a) == libsig.norm_insn(b)


def _key(it: Item, idx: dict[int, int], absolute: int | None) -> tuple:
    """Side-independent key for alignment (encoding-normalised, targets as item indices or addresses)."""
    if it.kind == "D":
        return ("D", absolute if absolute is not None else it.raw)
    if it.pc is None:
        return ("I", libsig.norm_insn(it.raw) if it.size == 2 else it.raw)
    if absolute is not None:
        return ("I", it.pc[1], "abs", absolute)
    return ("I", it.pc[1], idx.get(it.tgt, ("out", it.tgt)))


def compare(ref: libsig.RefFn, fw: FwView, addr: int, syms: dict[str, int] | None = None) -> Result:
    syms = syms or {}
    rel = {r.off: r for r in ref.relocs}
    ri, rend = decode(ref.code, ref.start, relocs=rel)
    cat = fw.size(addr)
    fcode = fw.read(addr, max(len(ref.code), cat or 0) + 0x10000)  # far shared pools (lrw32 reach)
    fi, fend = decode(fcode, addr, stop=cat) if cat else decode(fcode, addr, limit=len(ri))
    r_idx, f_idx = _index(ri), _index(fi)

    def fw_abs(it: Item) -> int | None:  # absolute call target of a firmware bsr (or other branch leaving)
        if it.kind == "I" and it.pc and it.pc[0] == "b" and it.tgt is not None and it.tgt not in f_idx:
            return (addr + it.tgt) & 0xFFFFFFFF
        return None

    def ref_abs(it: Item) -> tuple[int | None, str]:
        """(firmware address the relocation names, note); note 'unresolved' when it names none."""
        r = it.reloc
        if r is None:
            return None, ""
        a = symbol_address(r, syms)
        if a is not None:
            return a, r.sym.name
        if it.kind == "D" and (it.off in ref.strings):
            return None, "string"
        return None, "unresolved " + r.sym.name + (f"+{r.addend:#x}" if r.addend else "")

    ref_keys, notes = [], []
    for it in ri:
        a, note = ref_abs(it)
        notes.append((a, note))
        if it.kind == "D" and note == "string":
            ref_keys.append(("S", ref.strings[it.off]))
        elif note.startswith("unresolved"):
            ref_keys.append(("U", it.kind, it.pc[1] if it.pc else None))
        else:
            ref_keys.append(_key(it, r_idx, a))
    fw_keys = []
    for k, it in enumerate(fi):
        want = ref_keys[k] if k < len(ref_keys) else None
        if it.kind == "D" and want and want[0] == "S":
            s = fw.cstring(it.raw)
            fw_keys.append(("S", s) if s == want[1] else ("D", it.raw))
        elif want and want[0] == "U" and want[1] == it.kind and (it.pc[1] if it.pc else None) == want[2]:
            fw_keys.append(want)  # unresolved relocation: the fixed bits agree, the target is not checked
        else:
            fw_keys.append(_key(it, f_idx, it.raw if it.kind == "D" and want and want[0] == "D" and
                                ri[k].reloc is not None else fw_abs(it)))

    rows: list[Row] = []
    differing = unresolved = enc = 0
    sm = difflib.SequenceMatcher(None, ref_keys, fw_keys, autojunk=False)
    for op, a0, a1, b0, b1 in sm.get_opcodes():
        if op == "equal":
            for a, b in zip(range(a0, a1), range(b0, b1)):
                r_it, f_it = ri[a], fi[b]
                if ref_keys[a][0] == "U":
                    rows.append(Row(r_it, f_it, "?", notes[a][1]))
                    unresolved += 1
                elif r_it.kind == "I" and r_it.pc is None and r_it.raw != f_it.raw:
                    rows.append(Row(r_it, f_it, "~", "assembler re-encoding"))
                    enc += 1
                else:
                    rows.append(Row(r_it, f_it, "=", notes[a][1] if notes[a][1] not in ("",) else ""))
            continue
        span = max(a1 - a0, b1 - b0)
        differing += span
        for k in range(span):
            r_it = ri[a0 + k] if a0 + k < a1 else None
            f_it = fi[b0 + k] if b0 + k < b1 else None
            note = notes[a0 + k][1] if r_it is not None else ""
            rows.append(Row(r_it, f_it, "!", note))
    if differing:
        verdict = FAIL
    elif unresolved:
        verdict = UNRESOLVED
    elif enc:
        verdict = PASS_ENC
    else:
        verdict = PASS
    return Result(verdict, rows, len(ref.code), fend, cat, differing, unresolved, enc, ref.names[0])


# ---- disassembly for the report ----------------------------------------------------------------------
def disassemble(items: list[Item], toolchain: Path | None) -> dict[int, str]:
    """Item offset -> mnemonic and operands from the candidate's objdump (instructions only, assembled as
    .short halfwords at their own offsets so PC-relative operands print as function-relative offsets)."""
    text: dict[int, str] = {}
    insns = [it for it in items if it.kind == "I"]
    if not insns or toolchain is None:
        return text
    try:
        asm, objdump = tool(toolchain, "as"), tool(toolchain, "objdump")
    except FileNotFoundError:
        return text
    lines, pos = [".text"], 0
    for it in insns:
        if it.off > pos:
            lines.append(f".skip {it.off - pos}")
        halves = [it.raw >> 16, it.raw & 0xFFFF] if it.size == 4 else [it.raw]
        lines.append(".short " + ", ".join(f"{h:#06x}" for h in halves))
        pos = it.off + it.size
    BUILD.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=BUILD) as tmp:
        s, o = Path(tmp) / "d.s", Path(tmp) / "d.o"
        s.write_text("\n".join(lines) + "\n")
        if subprocess.run([str(asm), "-mcpu=ck803", str(s), "-o", str(o)], capture_output=True).returncode:
            return text
        out = subprocess.run([str(objdump), "-d", str(o)], capture_output=True, text=True).stdout
    want = {it.off for it in insns}
    for line in out.splitlines():
        m = re.match(r"^\s*([0-9a-f]+):\t[0-9a-f]+\s*\t(\S+)\s*(?:\t(.*))?$", line)
        if m and int(m.group(1), 16) in want:
            ops = (m.group(3) or "").split("//")[0].strip()
            text[int(m.group(1), 16)] = f"{m.group(2)} {ops}".strip()
    return text


def _cell(it: Item | None, base: int, dis: dict[int, str]) -> str:
    if it is None:
        return ""
    if it.kind == "D":
        return f"{base + it.off:08X} {it.raw:08X}  .long"
    t = dis.get(it.off, "")
    if it.pc is not None and it.tgt is not None:
        t = re.sub(r"0x[0-9a-f]+$|\[pc, \d+\]", "", t).strip(" ,")
        t += f" ->{base + it.tgt:X}"
    width = 8 if it.size == 4 else 4
    return f"{base + it.off:08X} {it.raw:0{width}X}{' ' * (9 - width)}{t}"


def report(res: Result, addr: int, ref_items: list[Item], toolchain: Path | None, fw: FwView,
           all_rows: bool = True) -> str:
    fdis = disassemble([r.fw for r in res.rows if r.fw], toolchain)
    rdis = disassemble(ref_items, toolchain)
    out = [f"{res.verdict}  {addr:08X} {fw.name(addr)} vs {res.func}: compiled {res.ref_bytes} bytes, "
           f"firmware compared {res.fw_bytes} bytes (catalog size {res.cat_size}); "
           f"differing items {res.differing}, encoding-only {res.enc}, unresolved {res.unresolved}"]
    out.append(f"{'firmware':<44} {'':1} {'compiled (object offsets)':<44} note")
    for r in res.rows:
        if not all_rows and r.mark == "=":
            continue
        fdis_cell = _cell(r.fw, addr, fdis)
        rdis_cell = _cell(r.ref, 0, rdis)
        out.append(f"{fdis_cell:<44} {r.mark} {rdis_cell:<44} {r.note}")
    return "\n".join(out)


def source_hints(text: str) -> tuple[str | None, dict[str, int]]:
    """`// @func NAME` and `// @sym NAME=ADDR` lines of a pilot C file (analysis/matching)."""
    func = re.search(r"@func\s+(\w+)", text)
    syms = {m.group(1): int(m.group(2), 16) for m in re.finditer(r"@sym\s+(\w+)=([0-9A-Fa-f]+)", text)}
    return (func.group(1) if func else None), syms


def run(args) -> int:
    toolchain = Path(args.toolchain)
    try:
        hint_func, syms = source_hints(Path(args.file).read_text(errors="replace"))
    except OSError as e:
        print(f"error: {e}")
        return 2
    args.func = args.func or hint_func
    for s in args.sym or []:
        k, _, v = s.partition("=")
        syms[k] = int(v, 16)
    try:
        obj = compile_c(Path(args.file), toolchain, args.cflags)
        ref = pick(obj, args.func, args.addr)
        fw = FwView(args.image)
        res = compare(ref, fw, args.addr, syms)
    except (RuntimeError, LookupError, ValueError, FileNotFoundError) as e:
        print(f"error: {e}")
        return 2
    ri, _ = decode(ref.code, ref.start, relocs={r.off: r for r in ref.relocs})
    print(report(res, args.addr, ri, toolchain, fw, all_rows=not args.diff_only))
    return EXIT[res.verdict]
