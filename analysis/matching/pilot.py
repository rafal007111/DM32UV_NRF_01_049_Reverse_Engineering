"""Run the matching pilot: every analysis/matching/*.c through the oracle over a fixed flag matrix.

    source /opt/dm32-tools.env && python3 analysis/matching/pilot.py [--csv out.csv] [files...]

Each C file names its firmware address in a header line `// @addr 0300C3AC` and may add `// @sym NAME=ADDR`
and `// @func NAME` lines. For every file the oracle (tools/dm32re/match.py) runs once per flag set below
(13 compiles; with at most one source variant this stays within the pilot's cap of about 25 runs) and the best verdict is reported:
PASS < PASS-ENC < UNRESOLVED < FAIL (by number of differing items). Read-only; objects go to build/dm32re/match.
"""

from __future__ import annotations

import argparse
import csv
import os
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1] / "tools"))

from dm32re import match  # noqa: E402

FLAGS = [
    "-mcpu=ck803 -Os", "-mcpu=ck803 -O1", "-mcpu=ck803 -O2",
    "-mcpu=ck803s -Os", "-mcpu=ck803s -O1", "-mcpu=ck803s -O2",
    "-mcpu=ck803 -Os -fno-optimize-sibling-calls", "-mcpu=ck803 -O2 -fno-optimize-sibling-calls",
    "-mcpu=ck803 -Os -fno-reorder-blocks", "-mcpu=ck803 -O2 -fno-reorder-blocks",
    "-mcpu=ck803 -Os -fno-reorder-blocks -fno-crossjumping", "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping",
    "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2",  # best single set (pilot result)
]
RANK = {match.PASS: 0, match.PASS_ENC: 1, match.UNRESOLVED: 2, match.FAIL: 3}


def header(src: Path) -> tuple[int, str | None, dict[str, int]]:
    text = src.read_text()
    addr = int(re.search(r"@addr\s+([0-9A-Fa-f]{8})", text).group(1), 16)
    func, syms = match.source_hints(text)
    return addr, func, syms


def run_one(src: Path, fw: match.FwView, toolchain: Path) -> list[tuple]:
    addr, func, syms = header(src)
    out = []
    for flags in FLAGS:
        try:
            ref = match.pick(match.compile_c(src, toolchain, flags), func, addr)
            r = match.compare(ref, fw, addr, syms)
            out.append((RANK[r.verdict], r.differing, flags, r))
        except (RuntimeError, LookupError, ValueError) as e:
            out.append((9, 0, flags, str(e)))
    return out


def main(argv=None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("files", nargs="*")
    p.add_argument("--toolchain", default=os.environ.get("DM32_CSKY_TOOLCHAIN", "/opt/thead-csky-v3.10.29-b20210423"))
    p.add_argument("--csv")
    a = p.parse_args(argv)
    files = [Path(f) for f in a.files] or sorted(HERE.glob("*.c"))
    fw = match.FwView("stock")
    rows = []
    for src in files:
        results = run_one(src, fw, Path(a.toolchain))
        best = min(results, key=lambda t: (t[0], t[1]))
        winners = [t[2] for t in results if (t[0], t[1]) == (best[0], best[1])]
        r = best[3]
        if isinstance(r, str):
            print(f"{src.name:<44} ERROR {r}")
            continue
        items = sum(1 for row in r.rows if row.fw is not None and row.fw.kind == "I")
        size_class = "tiny" if items <= 7 else "small" if items <= 40 else "medium"
        print(f"{src.name:<44} {r.verdict:<10} diff={r.differing:<3} enc={r.enc:<2} fw_items={items:<4} "
              f"flags: {winners[0]}" + (f" (+{len(winners) - 1} more)" if len(winners) > 1 else ""))
        rows.append([src.name, f"{header(src)[0]:08X}", size_class, r.verdict, r.differing, r.enc, r.unresolved, items,
                     r.fw_bytes, " | ".join(winners),
                     " ".join(f"{t[2].split(' ', 1)[1]}={t[3].verdict if not isinstance(t[3], str) else 'ERR'}"
                              f"/{t[1]}" for t in results if not t[2].startswith("-mcpu=ck803s"))])
    if a.csv:
        with open(a.csv, "w", newline="") as fh:
            w = csv.writer(fh, lineterminator="\n")
            w.writerow(["file", "address", "size_class", "best_verdict", "differing_items", "encoding_only",
                        "unresolved", "firmware_instructions", "firmware_bytes", "best_flags", "per_flag_ck803"])
            w.writerows(rows)
    return 0


if __name__ == "__main__":
    sys.exit(main())
