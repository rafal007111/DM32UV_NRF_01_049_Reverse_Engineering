"""Subsystem tags for unreviewed catalog functions (2026-10-17, docs/SUBSYSTEM_TAGS.md).

A tag is a navigation lead, not a name: the catalog row stays `unreviewed`. Evidence per function:

- task reachability: forward reachability from every task entry and ISR (TASKS) over direct calls, tail
  calls and function-pointer edges (a literal that is a catalog start, or a table of catalog starts the
  function points to). Entries of other tasks are never crossed, and reviewed library rows (RTOS, C runtime,
  uC/LIB) are not expanded. A function reached from one task subsystem only gets that subsystem; reached
  from several, it is `shared` unless other evidence decides;
- strings it loads (STRINGS keyword table);
- memory-mapped I/O it touches (MMIO, bases documented in SUBSYSTEM_TAGS.md);
- RAM regions with a documented owner it touches (RAM);
- reviewed callees and callers (their catalog subsystem, canonicalised by CANON);
- decided tags of callees and callers from the previous pass (weaker than reviewed rows, ROUNDS passes);
- address neighbourhood (reviewed or decided tags of the previous/next catalog function) as a tie-breaker.

Scores add up per tag; the result is the best tag, its score and the margin to the second. Read-only.
"""

from __future__ import annotations

import csv
import re
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

from .catalog import CATALOG

# --- seeds ---------------------------------------------------------------------------------------------
# (entry, name, tag). Task list from LIBRARY_SIGNATURES.md 6; ISRs and callbacks from DECOMPILED_MODULES.md.
TASKS = [
    (0x030206D0, "rxvoice", "Digital RX/DMR"),
    (0x030209E4, "rxcsbk", "Digital RX/DMR"),
    (0x0302386C, "rxslot", "Digital RX/DMR"),
    (0x0301FF9C, "rxmsg", "Digital RX/DMR data"),
    (0x0301FDD8, "txmsg", "Digital TX/DMR data"),
    (0x0002D620, "txslot", "Digital TX/DMR"),
    (0x030293C8, "SlotTimer", "Digital TX/DMR"),
    (0x0301E924, "CclTraffic", "Digital RX/DMR"),
    (0x0002D770, "sysint", "Baseband registers"),
    (0x0002C458, "baseband ISR", "Baseband registers"),
    (0x0305F234, "psint", "UI/status"),
    (0x0302B340, "usb", "CPS/USB"),
    (0x0302124C, "record", "Recording/privacy"),
    (0x0002D324, "decrypt", "Recording/privacy"),
    (0x0002D2F0, "encrypt", "Recording/privacy"),
    (0x0002E5BC, "encoder", "Audio/vocoder"),
    (0x0002EC4C, "decoder", "Audio/vocoder"),
    (0x03011A80, "gps", "GNSS/NMEA"),
    (0x0002CCE4, "GNSS UART ISR", "GNSS/NMEA"),
    (0x0305490C, "ScanDisp", "Periodic (ScanDisp)"),
    (0x03023B3C, "cpchanscan", "Scanning"),
    (0x03013940, "main loop step", "Main loop"),
    (0x03068E54, "task init (startup)", "Startup/init"),  # weak: see WEAK
    (0x03040A38, "task menu", "Menu/input"),
    (0x0305AA50, "task InputAlter", "Menu/input"),
    (0x03012D2C, "keys", "Keys/PTT"),
    (0x030151D0, "keyTime", "Keys/PTT"),
    (0x0300DC94, "task rf", "RF"),
    (0x03060F18, "task SqlCheck", "RF/squelch"),
    (0x03022FB0, "task sound", "Audio/tones"),
    (0x0302DF18, "task CallDisp", "UI/call display"),
    (0x030323C8, "task CodeSw", "Channel knob (CodeSw)"),
    (0x0300E49C, "task cds", "RF (cds task)"),
    (0x030614D8, "Led Manage", "LED"),
    (0x03055918, "task TmrHnd", "Timers (TmrHnd)"),
    (0x0301B784, "task ShutDown", "Power/shutdown"),
    (0x0002CABC, "periodic IRAM callback", "Periodic (IRAM callback)"),
]

# Startup code runs once before the main loop; reaching a function from it never makes the function shared.
WEAK = {"Startup/init"}
# Roots whose reach misled in the spot check (SUBSYSTEM_TAGS.md 4): they vote with W_TASK_WEAK only, so that
# strings, I/O, RAM and callee evidence decide (the keys task dispatches menu scenes; startup calls the init
# function of every subsystem).
WEAK_VOTE = {"Keys/PTT", "Startup/init"}

# Task tags grouped into families: a function reached from several tasks of one family is "shared (<family>)".
FAMILY = {
    "UI tasks": {"Main loop", "Menu/input", "Keys/PTT", "UI/status", "UI/call display", "LED", "Timers (TmrHnd)",
                 "Periodic (ScanDisp)", "Power/shutdown", "Scanning", "Periodic (IRAM callback)", "Channel knob (CodeSw)"},
    "DMR tasks": {"Digital RX/DMR", "Digital RX/DMR data", "Digital TX/DMR", "Digital TX/DMR data",
                  "Baseband registers"},
    "audio tasks": {"Audio/tones", "Audio/vocoder", "Recording/privacy"},
    "RF tasks": {"RF", "RF/squelch", "RF (cds task)"},
}


def family(tags) -> str | None:
    fams = {next((k for k, v in FAMILY.items() if t in v), t) for t in tags}
    return fams.pop() if len(fams) == 1 else None


# (lo, hi, tag, weight, what). Bases with evidence in SUBSYSTEM_TAGS.md.
MMIO = [
    (0x11000000, 0x11010000, "Baseband registers", 3.0, "HR_C7000 baseband"),
    (0x140D0000, 0x140E0000, "ADC", 3.0, "SAR ADC"),
    (0x14040000, 0x14050000, "GNSS/NMEA", 3.0, "GNSS UART"),
    (0x14000000, 0x14010000, "Hardware timers", 2.0, "timer block (timer 0 = OS tick)"),
    (0x17000000, 0x17010000, "Interrupt controller", 2.0, "interrupt controller"),
    (0x16000000, 0x16010000, "Audio", 2.0, "audio/codec byte registers"),
    (0x14020000, 0x14030000, "GPIO", 1.0, "GPIO port (RF 3-wire bit-bang)"),
    (0x14100000, 0x14120000, "GPIO", 1.0, "GPIO ports (same layout as 0x14020000)"),
    (0x14030000, 0x14040000, "UART (second)", 1.0, "UART (same layout as the GNSS UART)"),
]

# (lo, hi, tag, what). Owners documented in the analysis notes.
RAM = [
    (0x33CC8, 0x33D90, "Digital RX/DMR settings", "channel DMR runtime block 33CC8 (CC, slot, contacts)"),
    (0x3658C, 0x36590, "Digital RX/DMR", "rxvoice/rxcsbk event group"),
    (0x38330, 0x38334, "Digital RX/DMR data", "RX data event group"),
    (0x3835C, 0x38360, "UI/status", "psint event group"),
    (0x386C0, 0x38AC0, "GNSS/NMEA", "NMEA ring"),
    (0x38B28, 0x38C20, "GNSS/NMEA", "GNSS UART line buffer"),
    (0x38C88, 0x38DA0, "GNSS/NMEA", "GNSS fix state"),
    (0x3BA54, 0x3BA70, "Digital RX/DMR", "DMR RX/Monitor flags 3BA54"),
    (0x3BD48, 0x3BD70, "Digital RX/DMR", "call descriptor 3BD48"),
    (0x3BEA0, 0x3BED0, "Baseband registers", "baseband interrupt copies"),
    (0x3C61C, 0x3C628, "Digital RX/DMR", "per-slot RX state"),
    (0x3E160, 0x3E1F8, "Scanning", "scan state 3E160"),
    (0x3E1F8, 0x3E230, "Codeplug/channels", "current channel copy 3E1F8"),
    (0x3E9D4, 0x3EA40, "Settings", "settings block 3E9D4"),
    (0x3FD4C, 0x3FD50, "Emergency alarm", "alarm stage 3FD4C"),
]

STRINGS = [
    (r"\$G|GPS|GNSS|NMEA|KM/H|Distance|Course|Lat|Lon|APRS|%dM\b", "GNSS/NMEA"),
    (r"Scan|SCAN", "Scanning"),
    (r"Zone|Channel|VFO|Chan\b", "Codeplug/channels"),
    (r"Contact|Member|Group|Call [12]|All Call|Tx Contact", "Contacts/calls"),
    (r"Message|SMS|Inbox|Outbox|Draft", "UI/messages"),
    (r"ALARM|Alarm|Emergency|Man down|Lone|Work Alone", "Emergency alarm"),
    (r"Roam", "Roaming"),
    (r"Record|RIFF|enrec|decrec|play_sem", "Recording/privacy"),
    (r"enIV|Encrypt|Privacy|AES|ARC4|Key ", "Recording/privacy"),
    (r"FM\b|Seek|SEEK|NOAA|MHz|\.%05d", "FM radio/NOAA"),
    (r"SQL|RSSI", "RF/squelch"),
    (r"PTT ID|DTMF|WLT CMD|Kill|Stun", "Remote control/stun"),
    (r"\d{1,2}\.\d{2}V|%01d\.%02dV|Battery", "Power/battery"),
    (r"%0\.2d:%0\.2d|20%0\.2d|20%02d|\(Min\)|\(S\)|\(ms\)", "UI/clock/time"),
    (r"^task |^uC/OS-III", "Tasks"),
]

# Catalog subsystems that do not vote (library or unclassified) and canonical names for the rest.
GENERIC = re.compile(r"^(NRF application; subsystem not classified|IRAM/runtime region; subsystem not classified|"
                     r"RTOS|C runtime|uC/LIB|Core/RTOS|Tasks)")
CANON = {
    "Digital RX/DMR CSBK": "Digital RX/DMR", "Scanning/codeplug": "Scanning", "UI/scanning": "Scanning",
    "UI/menu/input": "Menu/input", "UI/menu": "Menu/input", "UI/input": "Menu/input", "UI/settings": "Settings",
    "Codeplug/zones": "Codeplug/channels", "Channel/codeplug": "Codeplug/channels",
    "Voice privacy": "Recording/privacy", "Privacy": "Recording/privacy", "Recording": "Recording/privacy",
    "Emergency alarm / Lone Worker": "Emergency alarm", "RF/BK4819": "RF", "RF/bands": "RF",
    "GNSS/APRS beacon": "GNSS/NMEA", "GNSS/APRS position log": "GNSS/NMEA", "UI/PTT": "Keys/PTT",
    "TX/PTT timers": "Keys/PTT", "RTOS events": "RTOS", "Audio/squelch": "Audio", "RF/squelch": "RF/squelch",
}

W_TASK, W_STR, W_CALLEE, W_CALLER, W_RAM, W_NEIGH = 3.0, 1.5, 1.0, 0.75, 1.5, 0.5
W_TASK_WEAK = 1.5
W_PROP, CAP_PROP, ROUNDS = 0.75, 2.25, 3  # votes from neighbours tagged in the previous pass
CAP_STR, CAP_CALLEE, CAP_CALLER, CAP_RAM = 3.0, 3.0, 2.25, 3.0
THRESHOLD, MARGIN = 3.0, 1.0  # written to the catalog as "auto: <tag>" when score >= THRESHOLD and margin >= MARGIN


def canon(sub: str) -> str | None:
    if not sub or GENERIC.match(sub):
        return None
    return CANON.get(sub, sub)


@dataclass
class Tag:
    addr: int
    tag: str
    score: float
    margin: float
    tasks: list[str] = field(default_factory=list)
    reasons: list[str] = field(default_factory=list)

    @property
    def confident(self) -> bool:
        """Written to the catalog: a decided tag above the threshold, or a shared mark within one family."""
        if self.tag.startswith("shared ("):
            return True
        return self.tag not in ("shared", "none") and self.score >= THRESHOLD and self.margin >= MARGIN


def catalog_rows(path: Path = CATALOG) -> dict[int, dict]:
    with open(path, encoding="utf-8-sig", newline="") as f:
        return {int(r["address"], 16): r for r in csv.DictReader(f)}


class Tagger:
    def __init__(self, ctx, rows: dict[int, dict] | None = None):
        self.c = ctx
        self.rows = rows if rows is not None else catalog_rows()
        self.funcs = [f.addr for f in ctx.cat.funcs if f.addr in ctx.x.reachable]
        self.roots = {a: (n, t) for a, n, t in TASKS}

    # ---- graph -------------------------------------------------------------------------------------
    def _is_library(self, va: int) -> bool:
        r = self.rows.get(va)
        return bool(r and r["confidence"] != "unreviewed" and re.match(r"^(RTOS|C runtime|uC/LIB)", r["subsystem"]))

    def _table_targets(self, va: int, limit: int = 512) -> list[int]:
        """Catalog starts in consecutive words at va (a handler table), at least two."""
        img, out = self.c.d.img, []
        try:
            while len(out) < limit:
                w = img.u32(va + 4 * len(out))
                if w not in self.c.cat.by_addr:
                    break
                out.append(w)
        except Exception:
            pass
        return out if len(out) >= 2 else []

    def edges(self) -> dict[int, set[int]]:
        x, cat = self.c.x, self.c.cat
        g: dict[int, set[int]] = defaultdict(set)
        for site, f, t, k in x.call_edges:
            if t in cat.by_addr:
                g[f].add(t)
            else:
                h = cat.containing(t)
                if h:
                    g[f].add(h.addr)
        for f, insns in x.reachable.items():
            for i in insns:
                v = self.c.d.literal(i)
                if v is None or i.mnem != "lrw":
                    continue
                if v in cat.by_addr and v != f:
                    g[f].add(v)  # function pointer
                elif self.c.d.img.region(v) is not None:
                    g[f].update(self._table_targets(v))
        return g

    def reach(self, g: dict[int, set[int]]) -> dict[int, set[str]]:
        """function -> names of the roots that reach it (roots reach themselves)."""
        out: dict[int, set[str]] = defaultdict(set)
        for root, (name, _) in self.roots.items():
            seen, work = {root}, [root]
            while work:
                f = work.pop()
                out[f].add(name)
                for t in g.get(f, ()):
                    if t in seen or (t in self.roots and t != root) or self._is_library(t):
                        continue
                    seen.add(t)
                    work.append(t)
        return out

    # ---- evidence ----------------------------------------------------------------------------------
    def run(self) -> dict[int, Tag]:
        c, x = self.c, self.c.x
        g = self.edges()
        callers: dict[int, set[int]] = defaultdict(set)
        for f, ts in g.items():
            for t in ts:
                callers[t].add(f)
        reached = self.reach(g)
        root_tag = {n: t for _, n, t in TASKS}
        acc_by_func: dict[int, set[int]] = defaultdict(set)
        for a in x.accesses:
            acc_by_func[a.func].add(a.addr)
        lits: dict[int, list[int]] = defaultdict(list)
        for f, insns in x.reachable.items():
            for i in insns:
                v = c.d.literal(i)
                if v is not None:
                    lits[f].append(v)
        strs = [(re.compile(p), t) for p, t in STRINGS]

        def reviewed(va):
            r = self.rows.get(va)
            return canon(r["subsystem"]) if r and r["confidence"] != "unreviewed" else None

        first: dict[int, Tag] = {}
        for f in self.funcs:
            r = self.rows.get(f)
            if r is None or r["confidence"] != "unreviewed":
                continue
            sc: dict[str, float] = defaultdict(float)
            why: dict[str, list[str]] = defaultdict(list)

            def add(tag, w, reason, cap=None, key=None):
                if cap is not None:
                    k = (key or "") + tag
                    used = capped.get(k, 0.0)
                    w = min(w, cap - used)
                    if w <= 0:
                        return
                    capped[k] = used + w
                sc[tag] += w
                why[tag].append(reason)
            capped: dict[str, float] = {}

            names = sorted(reached.get(f, ()))
            ttags = sorted({root_tag[n] for n in names})
            if len(ttags) > 1:
                ttags = [t for t in ttags if t not in WEAK]
            if len(ttags) == 1:
                add(ttags[0], W_TASK_WEAK if ttags[0] in WEAK_VOTE else W_TASK, "task " + "/".join(names))
            for v in lits[f]:
                s = c.d.img.cstring(v)
                if s:
                    for rx, t in strs:
                        if rx.search(s):
                            add(t, W_STR, f'str "{s[:24]}"', CAP_STR, "s")
            touched = acc_by_func[f] | {v for v in lits[f] if 0x10000000 <= v < 0x18000000}
            for lo, hi, t, w, what in MMIO:
                if any(lo <= a < hi for a in touched):
                    add(t, w, f"mmio {lo:08X} {what}")
            ram_touched = acc_by_func[f] | set(lits[f])
            for lo, hi, t, what in RAM:
                if any(lo <= a < hi for a in ram_touched):
                    add(t, W_RAM, f"ram {what}", CAP_RAM, "r")
            for t in sorted(g.get(f, ())):
                s = reviewed(t)
                if s:
                    add(s, W_CALLEE, f"calls {t:08X}", CAP_CALLEE, "c")
            for t in sorted(callers.get(f, ())):
                s = reviewed(t)
                if s:
                    add(s, W_CALLER, f"called by {t:08X}", CAP_CALLER, "k")
            first[f] = self._decide(f, sc, why, names, ttags)

        # later passes: propagate decided tags along call edges (weaker than reviewed rows), then the
        # neighbourhood tie-break; ROUNDS passes, each from the previous result
        order = [f.addr for f in c.cat.funcs]
        pos = {a: i for i, a in enumerate(order)}
        cur = first

        def decided(n):
            t = cur.get(n)
            return t.tag if t is not None and t.confident and not t.tag.startswith("shared") else None

        for _ in range(ROUNDS):
            out: dict[int, Tag] = {}
            for f, t0 in first.items():
                sc = defaultdict(float, t0._scores)
                why = defaultdict(list, {k: list(v) for k, v in t0._why.items()})
                used: dict[str, float] = defaultdict(float)
                for kind, others, w, cap in (("calls", g.get(f, ()), W_PROP, CAP_PROP),
                                             ("called by", callers.get(f, ()), W_PROP, CAP_PROP)):
                    for n in sorted(others):
                        s = decided(n) if reviewed(n) is None else None
                        if s and used[kind + s] < cap:
                            sc[s] += w
                            used[kind + s] += w
                            why[s].append(f"{kind} {n:08X} (auto)")
                i = pos[f]
                for j in (i - 1, i + 1):
                    if 0 <= j < len(order):
                        n = order[j]
                        s = reviewed(n) or decided(n)
                        if s:
                            sc[s] += W_NEIGH
                            why[s].append(f"next to {n:08X}")
                out[f] = self._decide(f, sc, why, t0.tasks, t0._ttags)
            cur = out
        return cur

    @staticmethod
    def _decide(f, sc, why, names, ttags) -> Tag:
        ranked = sorted(sc.items(), key=lambda kv: (-kv[1], kv[0]))
        fam = family(ttags) if len(ttags) > 1 else None
        shared = f"shared ({fam})" if fam else "shared"
        if not ranked:
            t = Tag(f, shared if len(ttags) > 1 else "none", 0.0, 0.0, names,
                    [f"reached from {'/'.join(ttags)}"] if len(ttags) > 1 else [])
        else:
            best, s = ranked[0]
            second = ranked[1][1] if len(ranked) > 1 else 0.0
            tag = best
            if len(ttags) > 1 and (s < THRESHOLD or s - second < MARGIN):
                tag = shared  # several tasks reach it and the other evidence does not decide
            reasons = list(why.get(best, []))[:6]
            if len(ttags) > 1:
                reasons = [f"reached from {'/'.join(ttags)}"] + reasons
            t = Tag(f, tag, round(s, 2), round(s - second, 2), names, reasons)
        t._scores, t._why, t._ttags = dict(sc), {k: list(v) for k, v in why.items()}, ttags
        return t


def write_csv(path: Path, tags: dict[int, Tag]) -> None:
    with open(path, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh, lineterminator="\r\n")
        w.writerow(["address", "tag", "score", "margin", "confident", "tasks", "reasons"])
        for a in sorted(tags):
            t = tags[a]
            w.writerow([f"{a:08X}", t.tag, t.score, t.margin, "yes" if t.confident else "no",
                        ";".join(t.tasks), "; ".join(t.reasons)])


def run(ctx, args) -> int:
    tg = Tagger(ctx)
    tags = tg.run()
    counts: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    for t in tags.values():
        counts[t.tag][0] += 1
        counts[t.tag][1] += t.confident
    if args.addr is not None:
        t = tags.get(args.addr)
        if t is None:
            print(f"{args.addr:08X}: not an unreviewed catalog function")
            return 1
        print(f"{t.addr:08X} {t.tag} score={t.score} margin={t.margin} confident={t.confident}")
        print("  tasks: " + (", ".join(t.tasks) or "-"))
        for k, v in sorted(t._scores.items(), key=lambda kv: -kv[1]):
            print(f"  {v:5.2f} {k}: " + "; ".join(t._why[k][:8]))
        return 0
    print(f"unreviewed functions tagged: {len(tags)}; confident (score >= {THRESHOLD}, margin >= {MARGIN}): "
          f"{sum(t.confident for t in tags.values())}")
    for tag, (n, k) in sorted(counts.items(), key=lambda kv: -kv[1][0]):
        print(f"  {n:5d} {k:5d}  {tag}")
    if args.csv:
        write_csv(Path(args.csv), tags)
    if args.write_catalog:
        from . import catalog
        upd = {a: {"subsystem": f"auto: {t.tag}"} for a, t in tags.items() if t.confident}
        print(f"catalog rows updated: {catalog.update_rows(upd)}")
    return 0
