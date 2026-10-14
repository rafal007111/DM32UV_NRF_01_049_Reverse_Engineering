"""Look-alike functions (idea from coddog / decomp.wtf similarity.py, reimplemented for C-SKY).

Each function becomes a token stream of its reachable instructions:
- `mnem` tokens: mnemonic only (robust to register allocation and constants);
- `shape` tokens: mnemonic + operand shape with registers kept, immediates kept, branch targets
  relative to the function, call targets and literals abstracted (detects near-copies).
Ranking: 3-gram Jaccard for candidate generation, then difflib ratio on the mnemonic stream.
"""

from __future__ import annotations

import re
from collections import Counter, defaultdict
from difflib import SequenceMatcher

from .xrefs import Xrefs

MAX_TOKENS = 1500


def mnem_tokens(x: Xrefs, f: int) -> list[str]:
    return [i.mnem for i in x.reachable.get(f, [])][:MAX_TOKENS]


_HEX = re.compile(r"0x[0-9a-f]+")


def shape_tokens(x: Xrefs, f: int) -> list[str]:
    out = []
    for i in x.reachable.get(f, [])[:MAX_TOKENS]:
        if i.mnem in ("bsr", "jsri", "jmpi"):
            out.append(i.mnem + " CALL")
        elif i.target is not None:
            out.append(f"{i.mnem} {i.ops.split(',')[0] if ',' in i.ops else ''} @{i.target - f:x}")
        elif i.pool is not None:
            out.append(f"{i.mnem} {i.ops.split(',')[0]} LIT")
        else:
            out.append(f"{i.mnem} {i.ops}")
    return out


def ngrams(tokens: list[str], n: int = 3) -> set[tuple[str, ...]]:
    if len(tokens) < n:
        return {tuple(tokens)} if tokens else set()
    return {tuple(tokens[k:k + n]) for k in range(len(tokens) - n + 1)}


class Index:
    def __init__(self, x: Xrefs, min_len: int = 6):
        self.x = x
        self.tok = {f: mnem_tokens(x, f) for f in x.reachable}
        self.tok = {f: t for f, t in self.tok.items() if len(t) >= min_len}
        self.grams = {f: ngrams(t) for f, t in self.tok.items()}
        self.df = Counter(g for gs in self.grams.values() for g in gs)
        self.inv: dict[tuple, list[int]] = defaultdict(list)
        n = len(self.grams)
        for f, gs in self.grams.items():
            for g in gs:
                if self.df[g] <= max(20, n // 50):  # skip ubiquitous grams (prologue/epilogue)
                    self.inv[g].append(f)

    def score(self, a: int, b: int) -> tuple[float, float]:
        ga, gb = self.grams[a], self.grams[b]
        jac = len(ga & gb) / max(1, len(ga | gb))
        ratio = SequenceMatcher(None, self.tok[a], self.tok[b], autojunk=False).ratio()
        return jac, ratio

    def query(self, f: int, top: int = 10, min_ratio: float = 0.5) -> list[tuple[int, float, float, bool]]:
        """[(function, jaccard, sequence ratio, identical shape)] best first."""
        if f not in self.tok:
            return []
        cand = Counter()
        for g in self.grams[f]:
            for o in self.inv.get(g, ()):
                if o != f:
                    cand[o] += 1
        la = len(self.tok[f])
        res = []
        for o, _ in cand.most_common(200):
            lb = len(self.tok[o])
            if min(la, lb) / max(la, lb) < 0.5:
                continue
            sm = SequenceMatcher(None, self.tok[f], self.tok[o], autojunk=False)
            if sm.real_quick_ratio() < min_ratio or sm.quick_ratio() < min_ratio:
                continue
            ratio = sm.ratio()
            if ratio >= min_ratio:
                ga, gb = self.grams[f], self.grams[o]
                jac = len(ga & gb) / max(1, len(ga | gb))
                same = shape_tokens(self.x, f) == shape_tokens(self.x, o)
                res.append((o, jac, ratio, same))
        res.sort(key=lambda r: (-r[2], -r[1]))
        return res[:top]

    def clusters(self, min_ratio: float = 0.9) -> list[list[int]]:
        """Connected groups of functions with pairwise sequence ratio >= min_ratio (union-find)."""
        parent = {f: f for f in self.tok}

        def find(a):
            while parent[a] != a:
                parent[a] = parent[parent[a]]
                a = parent[a]
            return a

        for f in self.tok:
            for o, _, ratio, _ in self.query(f, top=50, min_ratio=min_ratio):
                ra, rb = find(f), find(o)
                if ra != rb:
                    parent[ra] = rb
        groups = defaultdict(list)
        for f in self.tok:
            groups[find(f)].append(f)
        return sorted((sorted(g) for g in groups.values() if len(g) > 1), key=lambda g: (-len(g), g[0]))
