# Prompt: matching-decompilation pilot (vendor compiler search, oracle, 20–30 functions)

Written 2026-10-18. Agent-driven matching decompilation (rewrite a function in C, compile it with the original
compiler, require byte-identical output) has worked on large game binaries in 2026, but every success relied on two
things: the **exact original compiler** and a **deterministic PASS/FAIL oracle**. For DM32.NRF.01.049 we have neither
yet: the vendor code was **not** built with our pinned T-HEAD V3.10.29 (`LIBRARY_SIGNATURES.md` §3, §9), and objdiff /
decomp-permuter have no C-SKY backend. This pilot answers, at small cost, whether matching is feasible here.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything; record owner decisions as open questions and continue.

## 0. Before you start

1. Follow section 0 of `docs/NEXT_AGENT_PROMPT_TARGETED.md` (documents to read, input hashes, tooling with
   `bash tools/setup_cloud.sh --with-thead`). Baseline tests: firmware 10 passed / 1 skipped, tools **35** tests with
   only the 2 GCC-13-corpus tests skipped. Also read `docs/LIBRARY_SIGNATURES.md` (all, especially §3 "vendor used a
   different toolchain release" and §9 `libsig --norm`), `docs/REPRODUCIBILITY.md` "Linux build", `docs/TOOLS.md`,
   `docs/DM32RE_TOOLS.md`, `tools/dm32re/libsig.py`.
2. Section 1 (hard rules) of `docs/NEXT_AGENT_PROMPT_TARGETED.md` applies unchanged: static analysis only, never open
   a serial port, send CPS words or write the radio, never write a firmware image file; catalog edits keep BOM/CRLF;
   label every finding; no GPL code copied; no model identifiers in commits or docs.
3. Downloads are untrusted: put each archive in its own new directory outside the repository (e.g. under
   `build/` or `/opt`), record source URL, size and SHA-256, never execute anything from inside the extracted tree
   except the compiler/binutils binaries themselves, and never commit toolchains or their libraries.
4. Reconstructed C stays private research material: commit only the pilot functions (small, under
   `analysis/matching/`), never a bulk decompilation (`AGENTS.md`, README "do not publish full decompilation").

## 1. Known fingerprint of the vendor toolchain (do not re-derive; re-check only if a tool disagrees)

- Stock application code contains 16-bit three-operand `addu`/`subu` with `rz == rx` (580 `addu`, 229 `subu`; boot
  prefix 16); T-HEAD V3.10.29 never emits that form (0 in our module and in its own `libc.a`).
- The vendor minilibc differs from V3.10.29's: `memset`/`isspace` lack the leading `zextb`; `malloc`, `strtol`,
  `strtoul` differ only in encodings; `vsprintf` has a different instruction order. Exact-matching libc functions
  (`memcpy`, `memcmp`, `strcpy`, `strlen`, `free`, `rand`, …) are mostly hand-written assembly or trivial.
- So the strongest compiler test is: **does a candidate toolchain's own `libc.a`/`libgcc.a` match the vendor libc
  functions exactly** (`tools/dm32 libsig --toolchain <root>`; the near/norm rows of `libsig_thead_matches.csv` should
  become `exact`)? A toolchain whose libraries match is very likely the vendor's release.

## 2. Work item M1 — find candidate compilers

1. Collect every C-SKY ABIv2 bare-metal toolchain build you can reach (proxy limits apply: GitHub release downloads
   work; many vendor sites are blocked; record every attempt and its result). Starting points: the Taixin-Semiconductor
   `XuanTie-CSKY-Toolchains` GitHub repository (e.g. `csky-elfabiv2-tools-x86_64-minilibc-20250328`), SDKs that bundle
   C-SKY toolchains (WinnerMicro W80x/W806 SDKs, OpenW800, wm-sdk-w806, OpenHarmony device_soc_winnermicro, other
   CK80x vendors), Arch AUR packages, and older T-HEAD/C-SKY CDK releases mirrored on GitHub. Prefer Linux x86_64
   builds; a Windows-only build may be tried under Wine only if no Linux build of that release exists (record it).
2. For each candidate: version string (`gcc --version`, `objdump --version`), build date, libc flavour
   (minilibc/newlib), archive hash.
3. Score each candidate:
   - `tools/dm32 libsig --toolchain <root>` (and `--norm`): count exact matches against the vendor libc block
     `0306F97C–03072800` and the fdlibm/fp block `0306D800–0306F97C`; compare with V3.10.29;
   - compile a small probe file (a few functions with `a = a + b`-style code, a `char` parameter, a switch, a loop)
     with `-mcpu=ck803 -Os` and `-O2` and check whether the output uses the 16-bit three-operand `addu/subu rz,rz,ry`
     form and drops leading `zextb` the way the vendor code does.
4. Record the result in a table (candidate, source, hash, version, libsig exact/norm counts, fingerprint yes/no). If
   none matches, say so clearly and continue with M2/M3 using the best candidate, labelling every result accordingly.

## 3. Work item M2 — the oracle `tools/dm32 match`

Add a read-only command (module `tools/dm32re/match.py`, tests in `tools/tests`):
`python3 tools/dm32 match <ADDR> <file.c> [--toolchain DIR] [--cflags "..."] [--func NAME]` that compiles the C file
to an object with the given compiler/flags, extracts the named function (with its literal pool), masks relocation
bytes exactly as `libsig` does, compares it with the firmware bytes at `ADDR` (catalog size, extended over the pool),
and prints **PASS** or **FAIL** with a per-instruction diff (both sides disassembled with the candidate's objdump,
relocation targets resolved against the firmware: a `bsr` to the right catalog function counts as equal). Exit code
0 on PASS. Reuse `libsig` helpers; stdlib only beyond binutils. Add host tests with a tiny function compiled by the
pinned toolchain against a synthetic "firmware" buffer (PASS and FAIL cases).

## 4. Work item M3 — pilot on 20–30 functions

1. Pick 20–30 functions that are already reviewed with `high` confidence and well understood, spread over sizes:
   about 10 tiny leaves (getters/setters, GPIO set/clear `0002C504`/`0002C548`, LCD command/data `0002C1D0`/`0002C1DC`,
   small kernel helpers), about 10 small functions with branches or loops (8–40 instructions), and up to 10 medium
   ones (40–120 instructions, e.g. a data-flash helper, `0301EC40`, a menu getter). Avoid assembly routines and
   library code that `libsig` already matches.
2. For each: write readable C (no inline assembly, no `register` tricks, no meaningless code just to force the match
   — "fake matching" is a failure), declare external RAM/MMIO as plausible globals/structs, iterate with the oracle
   over flags (`-Os`, `-O2`, `-O1`, `-mcpu=ck803`/`ck803s`, `-fno-inline`, function/data sections) and source
   variations. Cap the effort per function (e.g. 20 oracle runs) and record the attempts.
3. Report per function: PASS / near (instruction diff count) / FAIL, flags that worked, what blocked the rest
   (register allocation, instruction selection, block order, unknown types). Derive the vendor's likely flags from
   the PASS set.
4. Commit the pilot C files under `analysis/matching/` (one file per function, header comment with address, result,
   toolchain, flags, oracle command).

## 5. Deliverables and reporting

- New doc `docs/MATCHING_PILOT.md`: M1 candidate table and verdict on the vendor compiler; M2 oracle usage; M3 per-
  function results with success rates by size class, best flags, failure causes; an **estimate** of what a larger
  agent-driven effort could achieve on this firmware (which function classes, rough cost) and a clear go/no-go
  recommendation; open questions. Update `docs/TOOLS.md` / `docs/DM32RE_TOOLS.md` (new command, any new toolchain),
  `RE_NOTES.md` (dated entry), `PROJECT_STATUS.md`. If a candidate toolchain is adopted, add an optional install path to
  `tools/setup_cloud.sh` with its SHA-256 (as `--with-thead` does) and keep V3.10.29 as the pinned build toolchain for
  our own modules.
- Catalog: only if a PASS gives new evidence for a row (e.g. a type or bit width), update that row's evidence; no
  other catalog changes are expected.
- Commit in logical steps (M1, M2, M3, docs), push to the branch you were assigned (or create `claude/<topic>` from
  master if none is named), do not open a pull request, do not push to master.
- Final message: candidate toolchains tried (with sources and hashes) and which, if any, matches the vendor; oracle
  status and tests; pilot results (PASS/near/FAIL counts by size class, best flags); go/no-go recommendation with the
  estimate; test results of both suites; commits pushed. State explicitly that no image file was written and no radio
  was accessed. If a step cannot be completed (e.g. no toolchain reachable), say exactly why and what was tried, and
  still deliver the oracle and a pilot with the best available compiler.
