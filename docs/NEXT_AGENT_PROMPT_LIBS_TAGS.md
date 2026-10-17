# Prompt: finish library naming and tag subsystems

Written 2026-10-17 after the library-signature and kernel-review passes (`LIBRARY_SIGNATURES.md` §1–§5). It covers two
work items: (A) finish naming the library code and (B) tag every remaining function with its subsystem. The TS/CC
Match candidate (`NEXT_AGENT_PROMPT.md` items 2–4) is **not** part of this prompt.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything. When a decision is genuinely the owner's, record it as an open question
and continue.

## 0. Before you start

1. Read `AGENTS.md`, `README.md`, `docs/RE_NOTES.md` (later entries win), `docs/DECOMPILED_MODULES.md`,
   `docs/LIBRARY_SIGNATURES.md` (all of it; §5 lists the kernel leads you continue), `docs/DM32RE_TOOLS.md`,
   `docs/TOOLS.md`, `docs/REPRODUCIBILITY.md` ("Linux build"). Do not re-derive documented facts.
2. Verify input hashes; if any differs, stop and report:
   - `analysis/inputs/stock_progmem_1MiB.bin` — `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0`
   - `analysis/inputs/current_scan_tick_fix.progmem.bin` — `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53`
   - `analysis/archives/DM32_NRF_049_correct_base.gzf` — `354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d`
3. Tooling: `bash tools/setup_cloud.sh --with-thead` (binutils 2.42, Ghidra 12.1.4 + CSKY module with the sinc
   fix, pinned T-HEAD V3.10.29 B20210423 toolchain), then `source /opt/dm32-tools.env`. Upstream GCC 13 is not needed.
   Rebuild the ignored reference corpus:
   ```sh
   mkdir -p build/src && cd build/src
   for r in uC-OS3 uC-CPU uC-LIB; do git clone -q https://github.com/weston-embedded/$r.git; done
   (cd uC-OS3 && git checkout -q 9a3fc5f45d75c0b4c3b6eaecf903720c74329747)
   (cd uC-CPU && git checkout -q ae5796e2049b043f69ef4f29fc330f29217b6344)
   (cd uC-LIB && git checkout -q 71b5f65da27859028a89c4ceac1df53c880916dc)
   cd ../..
   CC=$DM32_CSKY_TOOLCHAIN/bin/csky-elfabiv2-gcc bash tools/libref/build_ucos3.sh build/src build/dm32re/libref_thead
   ```
   Older uC/OS-III releases (V3.03–V3.07, which still have the ISR post queue the firmware uses) are a better
   reference if you can find them from a trustworthy public source; record source URL, version and hash. Do not use
   leaked or proprietary code.
4. Baseline tests before any change and before every commit; they must not regress:
   `python3 firmware/tests/run_tests.py` (10 passed, 1 skipped) and `python3 -m unittest discover -s tools/tests`
   (21 tests; only the 2 tests that need the GCC 13 corpus may skip).
5. Use `tools/dm32` (`fn`, `callers`, `callees`, `tree`, `acc`, `refs`, `str`, `info`, `similar`, `decomp`,
   `libid`, `libsig`) and the `tools/static` helpers. Do not use `objdump -b binary` on the image.

## 1. Hard rules (AGENTS.md; they override everything below)

- Static analysis only. Never open a serial/COM port, talk to the radio, or write/flash anything. Never write a
  firmware image file. This work changes no firmware and needs no hardware test.
- Decompiler output can be wrong; confirm names in the listing (constants, object tags, call positions, control
  structure). Label every finding hardware-verified / code-verified / inferred / unreviewed and record the evidence.
- Catalog edits (`analysis/decompiled_modules/function_catalog.csv`): keep the UTF-8 BOM and CRLF, change only the
  rows you reviewed, leave every other line byte-identical (see the one-off update scripts described in
  `LIBRARY_SIGNATURES.md`; parse and rewrite line by line). Keep `current_name` (`FUN_…`) unchanged; put the name in
  `documented_role`, and fill `subsystem`, `confidence` (`high` = code-verified by structure/unique constants,
  `medium` = consistent callee sequence plus constants or a near byte match, `low` = single weak signal) and
  `evidence` (tool, date, what matched, doc section). Never downgrade a row someone already reviewed without
  writing down why.
- Do not copy code from GPL projects; uC/OS-III, uC/CPU, uC/LIB (Apache-2.0) are reference material only.
- Do not commit firmware binaries, full decompilation, or the `build/` corpus. No model identifiers in commits or
  docs.

## 2. Work item A — finish naming the library code

Scope: about 190 unreviewed functions (≈ 29 KB) in IRAM `00010000–00014200` (kernel), flash `03068E00–0306D800`
(kernel, uC/LIB), the unidentified block `0306D800–0306F97C`, and the C-runtime block `0306F97C–03072800`.

1. **Kernel.** Continue from `LIBRARY_SIGNATURES.md` §5 "Not named": the `OSInit` callees in call order
   (`OSInitHook`, `OS_PrioInit`, `OS_RdyListInit`, `OS_FlagInit`, `OS_MemInit`, `OS_MsgPoolInit`, `OS_QInit`,
   `OS_SemInit`, `OS_TaskInit`, `OS_IntQTaskInit`, `OS_TickTaskInit`, …), then the remaining files: os_tick,
   os_time (`OSTimeDly`, `OSTimeDlyHMSM` lead `00013D60`), os_task (`OS_TaskBlock`, `OS_TaskRdy`, `OSTaskDel`,
   `OSTaskSuspend/Resume`, task Q/Sem post), os_int (ISR queue task, `OSIntEnter` lead `00010894`, `OSIntExit`),
   os_core (`OS_RdyList*`, `OS_PendList*`, `OS_Post`, `OS_PendObjDel`, `OS_PendAbort`, idle and stat tasks), os_flag,
   os_q, os_msg, os_mem, os_mutex (check whether mutexes exist at all), os_tmr (timer task, `OSTmrRemainGet`), the
   port (`OSCtxSw`, `OSIntCtxSw`, `OSStartHighRdy`; assembly, no reference — identify by PSR/stack handling and
   callers) and hooks. Use the already named functions as anchors and propagate through call positions; resolve every
   shared claim the way §5 did. Write down the kernel configuration you can prove (hooks, measurements, ISR post
   queue, tick rate if derivable, task list with priorities and stack sizes from the `OSTaskCreate` call sites).
2. **uC/LIB and uC/CPU.** Name the remaining `Str_*`, `Mem_*`, `Math_*`, `ASCII_*` and `CPU_*` functions only on
   real evidence (callee structure, constants); short functions that match by accident must stay unnamed
   (`LIBRARY_SIGNATURES.md` §4 shows two such false hits).
3. **Block `0306D800–0306F97C`** (29 functions, 7.2 KB, no hits yet): identify what library or module it is
   (strings, callers, constants, look-alikes); name it if the evidence allows, otherwise describe it.
4. **C runtime leftovers.** Extend `tools/dm32re/libsig.py` with a **normalised** comparison that tolerates the
   vendor toolchain's encodings (16-bit three-operand `addu/subu rz, rz, ry` versus two-operand form; a dropped
   leading `zextb`/`zexth`; register renaming if needed) and use it for the unmatched functions in §2 of
   `LIBRARY_SIGNATURES.md`: printf core `03070EF0`, `strtod` candidate `030706E4`, soft-float helpers
   `0306F97C…0306FF5C` and `03070000`, 64-bit helpers `03070474`/`0307049C`/`03071FE0`/`030723BC`, `__dtostr`/
   `__ltostr`-like `03071950`/`03071DE4`/`03071EA4`. Add host tests for the normaliser (pure encodings) and pin
   two or three results in `LibSigStock`.
5. Update `LIBRARY_SIGNATURES.md` (new section per step, with counts and the remaining leads), the cluster table in
   `DECOMPILED_MODULES.md`, `RE_NOTES.md`, `PROJECT_STATUS.md`, and regenerate
   `analysis/decompiled_modules/libsig_thead_matches.csv` if libsig changes.

## 3. Work item B — tag every remaining function with its subsystem

Goal: after A, about 1650 functions (IRAM 355, application 1299) stay `unreviewed`. Give each a **subsystem tag**,
not a name, so that the catalog can be navigated. Confidence stays `unreviewed`; the tag is a lead.

1. Add a read-only tool `tools/dm32 tag` (module `tools/dm32re/tag.py`, tests in `tools/tests`) that derives, per
   function, evidence from:
   - **task reachability:** forward call reachability from each task entry (table in `DECOMPILED_MODULES.md`
     "Reviewed entries without a catalog row": `rxvoice`, `rxcsbk`, `rxmsg`, `txmsg`, `psint`, `usb`, `record`,
     `txslot`, `sysint`, `gps`, `ScanDisp`, main task `03068E54`, the ISRs, plus every task you find from the
     `OSTaskCreate` call sites in work item A); a function reached only from one task inherits that task;
   - **strings** used by the function (UI scene names, menu texts, `sprintf` formats, CPS words);
   - **memory-mapped I/O** ranges it touches (`0x11000000` HR_C7000 baseband, `0x140D0000` SAR ADC, `0x14040000`
     GNSS UART, and others you identify; document each base with evidence);
   - **calls to named functions** (kernel, libc, already reviewed subsystems in the catalog) and RAM regions whose
     owner is documented (scan state `3E160`, settings `3E9D4`, channel copy `3E1F8`, …);
   - **address neighbourhood** (functions of one source file are usually contiguous) only as a tie-breaker.
2. Combine the evidence into one subsystem per function with a short reason and a score; mark conflicts
   (e.g. reached from two tasks) as `shared` instead of guessing. Use the subsystem names already in the catalog
   and docs (e.g. `Menu/input`, `Scanner`, `DMR RX`, `Settings/CPS`, `GNSS`, `Audio/tones`, `Alarm`, `Roaming`,
   `Recording/privacy`, `Baseband registers`, `RTOS (uC/OS-III …)`, `C runtime (…)`) and add new ones only when
   needed (document them).
3. Write the result to `analysis/decompiled_modules/subsystem_tags.csv` (address, tag, score, reasons) and, for
   tags above a documented threshold, write `subsystem` = `auto: <tag>` in the catalog rows that are still
   `unreviewed` (no other column changes; BOM/CRLF rules above). Spot-check at least 30 tagged functions by hand
   across subsystems and report the agreement rate; lower the threshold or drop a signal if it misleads.
4. Document method, thresholds, spot-check results and per-subsystem counts in a new
   `docs/SUBSYSTEM_TAGS.md`; add the command to `DM32RE_TOOLS.md`; summarise in `DECOMPILED_MODULES.md`,
   `RE_NOTES.md` and `PROJECT_STATUS.md`.

## 4. Deliverables and reporting

- Commit in logical steps (A1 kernel, A2/A3 libraries, A4 normaliser, B tool, B catalog tags, docs) with clear
  messages, push to the branch you were assigned, do not open a pull request.
- Each doc ends with open questions for the owner and the list of items left unreviewed. No hardware tests are
  needed for this work; say so.
- Final message: per work item what was done, catalog counts before/after (high/medium/low/unreviewed, and how many
  rows carry an `auto:` tag), new tools and tests, test results of both suites, spot-check agreement, remaining
  leads, commits pushed. State explicitly that no image file was written and no radio was accessed.
- If a step cannot be completed, record the partial result and the exact blocker and continue with the next step
  that does not depend on it.
