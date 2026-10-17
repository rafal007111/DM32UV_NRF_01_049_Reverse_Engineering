# Prompt for the next unattended reverse-engineering agent

Updated 2026-10-15 after the fifth pass (all six work items of the previous prompt are done: HR_C7000 cross-check,
TS Match off design closure, CC Match off completeness, settings storage, remaining internals, catalog hygiene).
Copy everything below the line into a new agent session on this repository.

For finishing the library names and tagging subsystems (no TS/CC Match work) use [NEXT_AGENT_PROMPT_LIBS_TAGS.md](NEXT_AGENT_PROMPT_LIBS_TAGS.md) (done 2026-10-17); for the targeted review of TX/PTT, CPS/codeplug and baseband code use [NEXT_AGENT_PROMPT_TARGETED.md](NEXT_AGENT_PROMPT_TARGETED.md) (done 2026-10-17, T2 partial); to finish T2 and the `keys` stack question use [NEXT_AGENT_PROMPT_T2.md](NEXT_AGENT_PROMPT_T2.md) (done 2026-10-17); to name the hub functions and display primitives use [NEXT_AGENT_PROMPT_HUBS.md](NEXT_AGENT_PROMPT_HUBS.md) (done 2026-10-17); for the last naming pass (TS/CC Match–relevant code, second-tier hubs, table-called handlers / UI map) use [NEXT_AGENT_PROMPT_PASS3.md](NEXT_AGENT_PROMPT_PASS3.md).

---

Continue the work on the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000, application VA
0300C000, flash offset = VA − 03000000). Work **unattended**: do not ask the user anything. When a decision is
genuinely the owner's, use the default stated below or in the docs, record it as an open question, and continue.

The static analysis for TS Match off and CC Match off is closed at design level. This pass turns the design into
a **host-tested candidate module and an in-memory guarded patch plan**, consolidates the design documents, and
then continues static review of subsystems that are still unreviewed.

## 0. Before you start

1. Read: `AGENTS.md`, `README.md` (documentation map at the end), `docs/RE_NOTES.md` (all dated entries; later
   entries win), `docs/DECOMPILED_MODULES.md`, `docs/PROJECT_STATUS.md`, `docs/REPRODUCIBILITY.md`, `docs/TOOLS.md`,
   `docs/DM32RE_TOOLS.md`, then `docs/HR_C7000_CROSSCHECK.md`, `docs/MATCH_OPTIONS_DESIGN.md` (§3.7–§3.9 supersede
   §3.1–§3.6), `docs/CC_MATCH_DESIGN.md`, `docs/SETTINGS_CPS_ANALYSIS.md` §9, `docs/RX_CALL_PATH_ANALYSIS.md`
   (§0.1, §13–§15 correct earlier sections), `docs/DATA_PATH_ANALYSIS.md`, `docs/CHANNEL_RECORD.md`. Do not re-derive
   documented facts; re-check only what your work depends on.
2. Verify input hashes. If any differs, stop and report:
   - stock `analysis/inputs/stock_progmem_1MiB.bin` — `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0`
   - installed `analysis/inputs/current_scan_tick_fix.progmem.bin` — `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53`
   - Ghidra database `analysis/archives/DM32_NRF_049_correct_base.gzf` — `354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d`
   - datasheet `docs/HR_C7000 Document 2.pdf` — `d60f652e…` (full hash in `HR_C7000_CROSSCHECK.md` §0)
3. Tooling: `bash tools/setup_cloud.sh --with-gcc` (JDK 25, binutils 2.42 for csky-elfabiv2, Ghidra 12.1.4 + legacy
   CSKY v0.2 module + `analysis/ghidra_scripts/32b_data.fixed.sinc` with fix 3 for `zext`/`sext` — never analyse with
   the unfixed SLEIGH; upstream GCC 13.3 for compile/size checks). Then `source /opt/dm32-tools.env`.
   Upstream GCC is **not** the pinned T-HEAD GCC 6.3.0: its output is for size/link checks only and never byte-exact.
   Since 2026-10-17 `--with-thead` installs the pinned T-HEAD V3.10.29 B20210423 x86_64 Linux build and
   `firmware/build_csky.sh --scan` rebuilds the installed module byte for byte (`REPRODUCIBILITY.md`); use it for
   target builds.
4. Use `tools/dm32` (`fn`, `callers`, `acc`, `refs`, `decomp`, …; `docs/DM32RE_TOOLS.md`) and the `tools/static`
   helpers; working-set commands are in `RX_CALL_PATH_ANALYSIS.md` §0. Do not use `objdump -b binary` (it does not
   decode 32-bit C-SKY instructions); use `tools/static/objdump_image.sh`.
5. Baseline tests, before any change and before every commit — they must not regress:
   `python3 firmware/tests/run_tests.py` (currently 10 passed, 1 skipped) and
   `python3 -m unittest discover -s tools/tests -v` (15 tests; skips must drop once binutils/Ghidra are installed).

## 1. Hard rules (AGENTS.md and the owner; they override everything below)

- Never open a serial/COM port, talk to the radio, send CPS words (`PROGRAM`, `SYSINFO`, `DEL-RCD`, `RTCITEM`,
  `PCTESTM`, …), or write/flash anything. Hardware tests belong to the owner; write them as RX-only proposals.
- **Never write a firmware image file** (no `.bin`/`.hex`/`.progmem` output, no "ready to install" artefact). Patch
  plans are applied **in memory only** and reported as JSON/Markdown (hashes, guarded bytes, diffs), as
  `firmware/plan_integration.py` already does. A module build is not a firmware image; say so in every report.
- Baseline is always stock `de7dbcbc…` with the installed Scan Zone delta (`156a4872…`) preserved: the new work
  must replay on top of the installed-reference profile without touching any of its 58 guarded changes.
- Guard every patch byte (stock bytes are in `MATCH_OPTIONS_DESIGN.md` §3.8.5 and §3.9 — re-read them from both
  images before use), check every branch target and `bsr` range, keep module placement inside the 1686-byte tail
  `030E0E56..030E14EC` of the existing window (do not use `030E14EC..03100000`; its boot/updater treatment is
  unreviewed), preserve boot prefix, startup and heap invariants, and compare the complete in-memory image.
- TX/PTT behaviour and CPS/codeplug compatibility must stay unchanged. Read-only subjects: `03027334`, `0301DE64`,
  `0301DF0C`, `0301DF8C`, `0002D7C8`, `0002D6C0`, `3BEAA`/`3BEAC`, `33CCB`, `11000100` bit 0, the PI-header,
  data-header, packet-data and CSBK CC checks (`03027584`, `03024E7C`, `03025480`, `03027B9C`).
- With both new options at 0 the patched code must behave exactly like the installed image (stock defaults).
- Decompiler output can be wrong; confirm important claims in the disassembly, literal pools and call sites. Keep
  `FUN_xxxxxxxx` names until evidence supports more. Label every finding hardware-verified / datasheet-verified /
  code-verified / inferred / unreviewed, with addresses, evidence, tool versions and input hashes. Absence results
  ("no reader found") are inferred; state the search method.
- Do not copy code from OpenGD77, qdmr, NeonPlug or other GPL projects; use them as design references only.
- Do not commit firmware binaries or full decompilation output. Do not include model identifiers in commits or docs.

## 2. Owner decisions: defaults to use (record each as still open)

| Question (source) | Default for this pass |
|---|---|
| Runtime flag storage: `3BA6D` bits 5/6 vs. mod block `4BFC0` (`SETTINGS_CPS_ANALYSIS.md` §9.3) | `3BA6D` bit 5 = CC Match off, bit 6 = TS Match off; keep the choice behind one header so it can be switched |
| Persistent storage (`MATCH_OPTIONS_DESIGN.md` §2) | block 4 `0x60` bit 2 (CC off), bit 3 (TS off); 0 = stock; CPS preservation still unverified |
| TS capture rule (§3.8.6 q1) | first-come capture until terminator/timeout |
| PTT during an other-slot call (§3.8.6 q2) | channel contact on the programmed slot (T9 guard) |
| Home screen slot display (T10) | not implemented (optional site left stock) |
| Encrypted other-slot / foreign-CC calls (§3.8.6 q5, `CC_MATCH_DESIGN.md` §4) | PI-header checks stay strict |
| Foreign-CC traffic and TX admit (§3.9 Correction 2, open q1) | invisible to TX: wrapper restores `3BEAB` and `3C61A` |
| Foreign-CC Idle bursts (§3.9 Correction 1, open q2) | gate bypass only for data types 1 and 2 |
| `RF_MODE.adjustsyncmax` with `cc_opt = 1` (`HR_C7000_CROSSCHECK.md` §5 q1) | not written (stock Monitor behaviour) |
| Menu placement | Other Func entries 22/23 after `MOTO` |

## 3. Work items (priority order; finish, test and document each before moving on)

1. **Consolidate the design documents.** `MATCH_OPTIONS_DESIGN.md` is the single authoritative design; turn
   `CC_MATCH_DESIGN.md` into a short pointer page (keep its CSBK decode-flag safety finding, §5, or move it into
   `DATA_PATH_ANALYSIS.md`), resolve the storage contradiction with the defaults above, and add at the top of
   `MATCH_OPTIONS_DESIGN.md` one table: site id, VA, stock bytes (re-read from both images), change, option,
   rationale link. Keep superseded text visibly marked, do not silently delete history.
2. **Candidate sources and host tests.** Following the existing style in `firmware/source` and `firmware/tests`,
   add C (and `.S` where register-exact caves need it) for: `cc_bypass` / `cc_bypass_dt` (C1–C5), the `cc_opt`
   setup changes (C6/C7), the dispatcher wrapper (T5/T6, `3BEAB`/`3C61A` restore), the TS gates (T1–T4) with the
   captured-slot byte `3BEBD`, `slot_of_call` (T7), `follow_guard` (T8), `talkback_guard` (T9), the boot-load
   extension in `0304B010` and the two Other Func menu items (strings, entries 22/23, cases, setting ids in
   `0304B158`, getter in `0304C434`). Every cave must honour the register contract written in the design (e.g. T3/T4
   preserve `r3`, C1 preserves `r0`, clobber only what the stock code clobbered). Host tests must model the stock
   decision for each site and show: options 0 → identical decision to stock in all cases; CC off → only the listed
   voice cases change; TS off → capture/release, timeout and B-Idle rules; TX inputs unchanged. Add them to
   `firmware/tests/run_tests.py`.
3. **Target build and placement check.** Compile and link the new module with upstream GCC 13.3 and the
   `build_csky.ps1` flags (`-mcpu=ck803`, `-Werror`), report section sizes and confirm it fits after the Scan Zone
   module in `030E0E56..030E14EC` with alignment; disassemble the result with binutils 2.42 and check every cave's
   prologue/epilogue and register use against its contract. (2026-10-17: build with the pinned T-HEAD toolchain via
   `firmware/build_csky.sh` instead; the owner's Windows build becomes a cross-check of the same bytes.)
4. **In-memory guarded patch plan.** Add a new profile (e.g. `--profile match-options`) to
   `firmware/plan_integration.py`, or a separate planner in the same style, that: starts from stock, replays the
   installed-reference profile and checks `156a4872…`, verifies every new site's guard bytes, encodes each `bsr`
   and checks its range/target, places the module, and reports the full diff (count of changed bytes and 4 KiB
   chunks, every changed range with old/new bytes, the SHA-256 of the in-memory result) without writing the image.
   Add a host test that runs the planner and asserts: all installed-reference bytes unchanged, all guards matched,
   no change outside the declared sites and the module window, boot prefix/startup/heap invariants intact.
5. **Static review of new risks.** For the patched paths re-check: interrupt/task context of each cave (ISR
   `0002C458` vs task), stack depth, reentrancy, CPU load with `cc_opt = 1` (`CC_MATCH_DESIGN.md` §4, IRAM
   `0002D7C8` path), timer `3BEB8` interaction with the captured slot, scanner busy/stop logic, recording and call
   log with a B-slot call. Record each as resolved or as an owner RX-only test.
6. **Remaining static leads** (only after 1–5): `HR_C7000_CROSSCHECK.md` §7 (`WORK_MODE` bit 2 in layer 2,
   `SYS_SOFT_RSTN` bits 1:0 in `030234E8`, `LAYER2_SLOTON = 0x11`, `030215C8` caller/purpose, FIR/threshold
   registers `0x120`/`0x168`/`0x1B4`); `RX_CALL_PATH_ANALYSIS.md` §15.3 (`0001D3E0`/`0001D4C4`, `0001620C`/`0002E398`,
   `03010BD4`, `PCTESTM` sub-commands, load mode 4 of `03057790`, the `Call Log` writer); `SETTINGS_CPS_ANALYSIS.md`
   §9.5 (`0x50` editor length bound, Display Func storage of the four undocumented items, `3EA06` bits 0/1/7);
   the boot/updater treatment of `030E14EC..03100000` (would give more code space).
7. **Unreviewed subsystems** (`DECOMPILED_MODULES.md`: ~2080 catalog rows still unreviewed): GNSS/APRS/roaming,
   audio/tones, CPS frame handlers beyond the handshake, settings persistence outside block 4, UI scenes. Work
   cluster by cluster, update the catalog rows you actually read (keep UTF-8 BOM and CRLF, change only those rows)
   and the cluster table in `DECOMPILED_MODULES.md`.

## 4. Deliverables

- Code under `firmware/source` and `firmware/tests`, planner changes under `firmware/`, helpers under
  `tools/static` or `tools/dm32re` with tests in `tools/tests`; exact command lines in the doc that uses them.
- Docs: updated `MATCH_OPTIONS_DESIGN.md`; a new `docs/MATCH_OPTIONS_CANDIDATE.md` with the build report (tool
  versions, sizes, placement), the patch-plan summary (sites, guards, diff counts, in-memory SHA-256), register
  contracts per cave, test results, the owner decisions table with defaults used, and the owner's remaining steps
  (pinned T-HEAD build, full-image comparison, backups, RX-only tests from `MATCH_OPTIONS_DESIGN.md` §5).
- A short dated entry in `docs/RE_NOTES.md` per pass and an update of `docs/PROJECT_STATUS.md`.
- Each doc ends with: open questions for the owner, RX-only hardware test proposals with expected results, and
  the list of items left unreviewed.
- Commit in logical steps with clear messages and push to the designated branch. Do not open a pull request.
- If a step cannot be completed (tool missing, guard mismatch, no space), record the partial result and the exact
  blocker, and move on to the next item that does not depend on it.

## 5. Final report (last message)

Per work item: what was done, confidence labels, files changed, commits pushed, test results (both suites), module
size and placement, patch-plan diff counts and in-memory SHA-256, open owner decisions with the defaults used, and
the RX-only hardware tests the owner should run next. State explicitly that no image file was written and no radio
was accessed.
