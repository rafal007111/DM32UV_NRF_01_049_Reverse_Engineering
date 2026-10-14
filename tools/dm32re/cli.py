"""dm32re command line. Run from the repository root:  python3 tools/dm32 <command> ...

All commands are read-only static analysis of the private stock image (or --image installed).
"""

from __future__ import annotations

import argparse
import re
import sys
from functools import cached_property

from . import disasm, similar, xrefs


def addr(s: str) -> int:
    return int(s, 16)


class Ctx:
    def __init__(self, image: str, refresh: bool):
        self.d = disasm.load(image, refresh=refresh)
        self.x = xrefs.Xrefs(self.d)
        self.cat = self.d.cat

    @cached_property
    def acc_by_site(self):
        return {a.site: a for a in self.x.accesses}

    def name(self, va: int) -> str:
        f = self.cat.by_addr.get(va)
        if f:
            role = f" [{f.confidence}] {f.role[:70]}" if f.confidence != "unreviewed" else ""
            return f"{f.label()}{role}"
        return self.cat.where(va)

    def describe_value(self, v: int) -> str:
        if v in self.cat.by_addr:
            return "-> " + self.name(v)
        r = self.d.img.region(v)
        if r is not None:
            s = self.d.img.cstring(v)
            if s:
                return f'-> "{s[:60]}"'
            return f"-> {r.name} {self.cat.where(v) if r.code else ''}".rstrip()
        return ""


def cmd_fn(c: Ctx, a):
    f = c.cat.containing(a.addr) or c.cat.by_addr.get(a.addr)
    start = f.addr if f and not a.raw else a.addr
    print(f"; {c.name(start)}")
    reach = {i.addr for i in c.x.reachable.get(start, [])}
    insns = c.d.function(start, "gap" if a.gap else "catalog") if not a.raw else c.d.range(a.addr, a.addr + a.raw)
    targets = {i.target for i in insns if i.target is not None}
    for i in insns:
        if i.addr in targets:
            print(f"L_{i.addr:08x}:")
        note = []
        lit = c.d.literal(i)
        if lit is not None:
            note.append(f"={lit:#x} {c.describe_value(lit)}".rstrip())
        if i.mnem in ("bsr", "jsri") or (i.target is not None and i.target not in range(start, start + 0x100000)
                                         and i.mnem == "br"):
            t = i.target if i.target is not None else lit
            if t is not None:
                note.append("call " + c.name(t))
        acc = c.acc_by_site.get(i.addr)
        if acc:
            note.append(f"{acc.kind}{acc.width} [{acc.addr:#x}]")
        flag = " " if i.addr in reach or a.raw else "?"
        print(f"{flag}{i.addr:08x}: {i.mnem:<8} {i.ops:<28} {'; ' + ' | '.join(note) if note else ''}".rstrip())


def cmd_callers(c: Ctx, a):
    seen = set()
    for site, f, k in sorted(c.x.callers_of.get(a.addr, [])):
        seen.add(site)
        print(f"{k:<9} {site:08x} in {c.name(f)}")
    for site in c.x.raw_bsr_sites(a.addr):
        if site not in seen:
            print(f"bsr(raw) {site:08x} near {c.cat.where(site)}  (not reachable from a catalog entry)")
    for site, pool in c.x.literal_uses.get(a.addr, []):
        print(f"literal   {site:08x} in {c.name(c.x.func_of(site))} (pool {pool:08x})")
    for w in c.x.words_equal(a.addr):
        print(f"word      {w:08x} {c.d.img.region(w).name} {c.cat.where(w) if c.d.img.region(w).code else ''}")


def cmd_callees(c: Ctx, a):
    for site, t, k in sorted(c.x.callees_of.get(a.addr, [])):
        print(f"{k:<9} {site:08x} -> {c.name(t)}")


def cmd_tree(c: Ctx, a):
    edges = c.x.callers_of if a.up else c.x.callees_of

    def walk(f, depth, path):
        if depth > a.depth:
            return
        seen_here = set()
        for e in sorted(edges.get(f, [])):
            nxt = e[1]
            if nxt in seen_here:
                continue
            seen_here.add(nxt)
            loop = " (recursion)" if nxt in path else ""
            print("  " * depth + f"{'<-' if a.up else '->'} {c.name(nxt)}{loop}")
            if not loop:
                walk(nxt, depth + 1, path | {nxt})

    print(c.name(a.addr))
    walk(a.addr, 1, {a.addr})


def cmd_acc(c: Ctx, a):
    for x in c.x.accesses_in(a.addr, a.addr + a.len):
        print(f"{x.kind}{x.width} [{x.addr:#010x}] {x.site:08x} in {c.name(x.func)[:60]:<60} {x.text}")
    for site, pool, v in c.x.literals_in(a.addr, a.addr + a.len):
        print(f"lit [{v:#010x}] {site:08x} in {c.name(c.x.func_of(site))[:60]}")


def cmd_refs(c: Ctx, a):
    cmd_acc(c, a)
    if a.len == 1:
        for w in c.x.words_equal(a.addr):
            print(f"word {w:08x} ({c.d.img.region(w).name})")


def cmd_str(c: Ctx, a):
    pat = re.compile(a.pattern, re.I)
    img = c.d.img
    for r in img.regions:
        data = img.data[r.file_off:r.file_off + (r.end - r.va)]
        for m in re.finditer(rb"[\x20-\x7e]{%d,}\x00" % a.min, data):
            s = m.group()[:-1].decode()
            if pat.search(s):
                va = r.va + m.start()
                uses = c.x.literal_uses.get(va, [])
                where = ", ".join(f"{site:08x}({c.cat.where(site)})" for site, _ in uses[:6]) or "no lrw use"
                words = c.x.words_equal(va) if not uses else []
                if words:
                    where += "; tables " + ", ".join(f"{w:08x}" for w in words[:6])
                print(f'{va:08x} "{s}"  <- {where}')


def cmd_similar(c: Ctx, a):
    ix = similar.Index(c.x)
    print(f"; {c.name(a.addr)} ({len(ix.tok.get(a.addr, []))} instructions)")
    for o, jac, ratio, same in ix.query(a.addr, a.top, a.min):
        print(f"{ratio:5.2f} jac={jac:4.2f} {'SAME-SHAPE ' if same else ''}{c.name(o)} ({len(ix.tok[o])} insns)")


def cmd_clusters(c: Ctx, a):
    ix = similar.Index(c.x)
    for g in ix.clusters(a.min):
        known = [c.name(f) for f in g if c.cat.by_addr[f].confidence != "unreviewed"]
        print(f"{len(g):3d}: " + " ".join(f"{f:08x}" for f in g) + (f"   known: {'; '.join(known)}" if known else ""))


def cmd_info(c: Ctx, a):
    r = c.d.img.region(a.addr)
    print(f"region: {r.name if r else 'unmapped'}  where: {c.cat.where(a.addr)}")
    f = c.cat.containing(a.addr)
    if f:
        print(f"catalog: {f}")
        print(f"reachable instructions: {len(c.x.reachable.get(f.addr, []))}")
    if r:
        print(f"word: {c.d.img.u32(a.addr & ~3):#010x}  string: {c.d.img.cstring(a.addr)!r}")


def cmd_decomp(c, a):
    from . import ghidra
    res = ghidra.decompile(a.addrs, refresh=a.refresh_decomp)
    for x in a.addrs:
        print(res.get(x, f"/* {x:08X}: no output */"))


def main(argv=None):
    import signal
    if hasattr(signal, "SIGPIPE"):
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    p = argparse.ArgumentParser(prog="dm32", description=__doc__)
    p.add_argument("--image", default="stock", choices=["stock", "installed"])
    p.add_argument("--refresh", action="store_true", help="rebuild the disassembly cache")
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("fn", help="annotated listing of a function")
    s.add_argument("addr", type=addr)
    s.add_argument("--gap", action="store_true", help="list up to the next catalog function")
    s.add_argument("--raw", type=lambda v: int(v, 0), default=0, help="list N bytes from addr, ignoring the catalog")
    for name, h in (("callers", "direct calls, literal uses and table words naming the address"),
                    ("callees", "direct calls made by a function")):
        s = sub.add_parser(name, help=h)
        s.add_argument("addr", type=addr)
    s = sub.add_parser("tree", help="call tree")
    s.add_argument("addr", type=addr)
    s.add_argument("--up", action="store_true", help="callers instead of callees")
    s.add_argument("--depth", type=int, default=3)
    for name, h in (("acc", "loads/stores and literals for an address range (RAM, MMIO)"),
                    ("refs", "acc plus raw table words")):
        s = sub.add_parser(name, help=h)
        s.add_argument("addr", type=addr)
        s.add_argument("--len", type=lambda v: int(v, 0), default=1)
    s = sub.add_parser("str", help="strings matching a regex and where they are used")
    s.add_argument("pattern")
    s.add_argument("--min", type=int, default=4)
    s = sub.add_parser("similar", help="look-alike functions")
    s.add_argument("addr", type=addr)
    s.add_argument("--top", type=int, default=10)
    s.add_argument("--min", type=float, default=0.6)
    s = sub.add_parser("clusters", help="groups of near-identical functions")
    s.add_argument("--min", type=float, default=0.9)
    s = sub.add_parser("info", help="what is at an address")
    s.add_argument("addr", type=addr)
    s = sub.add_parser("decomp", help="Ghidra decompilation from the GZF (cached, read-only)")
    s.add_argument("addrs", type=addr, nargs="+")
    s.add_argument("--refresh-decomp", action="store_true")
    s = sub.add_parser("libid", help="match reference library objects (see libid.py)")
    s.add_argument("objects", nargs="+", help="csky ELF objects/archives built from reference sources")
    s.add_argument("--min", type=float, default=0.75)
    s.add_argument("--csv", help="write candidates to this CSV")
    s.add_argument("--all", action="store_true", help="also print weak candidates")
    a = p.parse_args(argv)
    if a.cmd == "decomp":
        cmd_decomp(None, a)
        return 0
    c = Ctx(a.image, a.refresh)
    if a.cmd == "libid":
        from . import libid
        return libid.run(c, a)
    globals()[f"cmd_{a.cmd}"](c, a)
    return 0


if __name__ == "__main__":
    sys.exit(main())
