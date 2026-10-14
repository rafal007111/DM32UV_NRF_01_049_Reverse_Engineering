"""The checked-in function catalog (analysis/decompiled_modules/function_catalog.csv)."""

from __future__ import annotations

import bisect
import csv
from dataclasses import dataclass
from functools import lru_cache

from .image import REPO

CATALOG = REPO / "analysis" / "decompiled_modules" / "function_catalog.csv"


@dataclass(frozen=True)
class Function:
    addr: int
    name: str
    size: int
    status: str
    role: str
    confidence: str

    @property
    def end(self) -> int:
        return self.addr + self.size

    def label(self) -> str:
        if self.name.startswith("FUN_"):
            return f"{self.addr:08X}"
        if self.name.startswith("SUB_"):
            return f"{self.addr:08X}(new)"
        return self.name


class Catalog:
    def __init__(self, rows: list[Function]):
        self.funcs = sorted(rows, key=lambda f: f.addr)
        self._starts = [f.addr for f in self.funcs]
        self.by_addr = {f.addr: f for f in self.funcs}

    def containing(self, va: int) -> Function | None:
        """The catalog function whose body covers va (Ghidra body size; literal pools may fall outside)."""
        i = bisect.bisect_right(self._starts, va) - 1
        if i < 0:
            return None
        f = self.funcs[i]
        if va < f.end:
            return f
        if f.size == 0 and (i + 1 == len(self.funcs) or va < self._starts[i + 1]):
            return f  # discovered entry: extent is the gap to the next start
        # a smaller entry may start inside a larger earlier body
        for j in range(i - 1, max(-1, i - 8), -1):
            if self.funcs[j].addr <= va < self.funcs[j].end:
                return self.funcs[j]
        return None

    def preceding(self, va: int) -> Function | None:
        """The nearest catalog function starting at or before va (useful for pools and gaps)."""
        i = bisect.bisect_right(self._starts, va) - 1
        return self.funcs[i] if i >= 0 else None

    def next_start(self, va: int) -> int | None:
        i = bisect.bisect_right(self._starts, va)
        return self._starts[i] if i < len(self._starts) else None

    def where(self, va: int) -> str:
        f = self.containing(va)
        if f:
            return f"{f.label()}+{va - f.addr:X}"
        p = self.preceding(va)
        return f"(after {p.label()}+{va - p.addr:X})" if p else "?"


@lru_cache(maxsize=1)
def load() -> Catalog:
    rows = []
    with open(CATALOG, encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f):
            rows.append(Function(int(r["address"], 16), r["current_name"], int(r["size_bytes"] or 0),
                                 r["decompiler_status"], r["documented_role"], r["confidence"]))
    return Catalog(rows)
