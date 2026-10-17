# Prompt: targeted review of TX/PTT, CPS/codeplug and baseband code

Written 2026-10-17 after the library pass and the subsystem tagging (`LIBRARY_SIGNATURES.md` §1–§9,
`SUBSYSTEM_TAGS.md`). The library code is finished (15 small unreviewed functions left); the remaining ~1650
unreviewed functions are vendor code. This prompt does **not** ask for a full review: it covers only the three areas
that matter for safety and for the planned TS/CC Match work. The TS/CC Match candidate itself (`NEXT_AGENT_PROMPT.md`
items 2–4) is not part of it.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything. When a decision is genuinely the owner's, record it as an open question
and continue.

## 0. Before you start

1. Read `AGENTS.md`, `README.md`, `docs/RE_NOTES.md` (later entries win), `docs/DECOMPILED_MODULES.md`,
   `docs/SUBSYSTEM_TAGS.md`, `docs/LIBRARY_SIGNATURES.md` (§6 task list), `docs/AUTONOMOUS_TX.md`,
   `docs/SETTINGS_CPS_ANALYSIS.md`, `docs/CHANNEL_RECORD.md`, `docs/DATA_PATH_ANALYSIS.md`,
   `docs/RX_CALL_PATH_ANALYSIS.md` (§0.1 and §13 onwards correct earlier sections), `docs/HR_C7000_CROSSCHECK.md`,
   `docs/MATCH_OPTIONS_DESIGN.md` (§3.7–§3.9 supersede §3.1–§3.6), `docs/DM32RE_TOOLS.md`. Do not re-derive
   documented facts; re-check only what your work depends on.
2. Verify input hashes; if any differs, stop and report:
   - `analysis/inputs/stock_progmem_1MiB.bin` — `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0`
   - `analysis/inputs/current_scan_tick_fix.progmem.bin` — `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53`
   - `analysis/archives/DM32_NRF_049_correct_base.gzf` — `354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d`
   - `docs/HR_C7000 Document 2.pdf` — full hash in `HR_C7000_CROSSCHECK.md` §0
3. Tooling: `bash tools/setup_cloud.sh --with-thead`, then `source /opt/dm32-tools.env`. Use `tools/dm32` (`fn`,
   `callers`, `callees`, `tree --up`, `acc`, `refs`, `str`, `info`, `similar`, `decomp`, `tag`) and the
   `tools/static` helpers; datasheet text via `pdftotext -layout`. Do not use `objdump -b binary` on the image.
4. Baseline tests before any change and before every commit; they must not regress:
   `python3 firmware/tests/run_tests.py` (10 passed, 1 skipped) and `python3 -m unittest discover -s tools/tests`
   (31 tests; only the 2 tests that need the GCC 13 corpus may skip).

## 1. Hard rules (AGENTS.md; they override everything below)

- Static analysis only. Never open a serial/COM port, talk to the radio, send CPS words, or write/flash anything.
  Never write a firmware image file. Hardware tests belong to the owner; write them as **RX-only** proposals and say
  which stock features must be disabled first (`AUTONOMOUS_TX.md` "Safe test practice").
- Decompiler output can be wrong; confirm claims in the listing, literal pools and call sites. Label every finding
  hardware-verified / datasheet-verified / code-verified / inferred / unreviewed with addresses and evidence. An
  absence result ("no other caller") is inferred unless the search covers bsr, tail calls, function pointers,
  handler tables (also the SRAM copies) and `jsri`; state the method.
- Catalog edits (`analysis/decompiled_modules/function_catalog.csv`): keep the UTF-8 BOM and CRLF, change only rows
  you actually read, leave every other line byte-identical. Keep `current_name` (`FUN_…`); put the role in
  `documented_role`, replace an `auto:` subsystem by the reviewed one, and set `confidence` (`high` = code-verified
  by structure/unique constants, `medium` = consistent evidence, `low` = single weak signal) and `evidence` (tools,
  date, doc section). If a reviewed function disagrees with its `auto:` tag, record that in `SUBSYSTEM_TAGS.md`
  (it measures the tagger).
- Do not copy code from GPL projects (OpenGD77, qdmr, …); use them as design references only. Do not commit
  firmware binaries or full decompilation output. No model identifiers in commits or docs.

## 2. Work items (priority order; finish, document and commit each before moving on)

### T1 — Completeness of the transmit paths (highest priority)

Goal: a defensible answer to "which code paths can key the transmitter, and under which conditions".

1. Start from the known TX sinks: TX queue `030294C8`, call start `0301EAC8`, repeater wake-up `03029C3C`, burst
   loader / TX slot handling (`0002D7C8`, `0302768C`), TX admit `0301DF8C`, alarm start `0305DD38`, the PTT key
   events `03014DD8(4/8)`, Remote Monitor transmission, and the analog TX enable in the RF chip (find the register
   writes that switch the BK4819-style transceiver to TX and the PA/TX GPIO; `SETTINGS_CPS_ANALYSIS.md` RF map,
   `0002C2F8`/`0002C340`). Add any sink you find.
2. Walk **backwards** (`tools/dm32 tree --up`, plus function pointers and handler tables) from every sink to its
   roots (tasks, ISRs, key handlers, timers, received-frame handlers). Review every unreviewed function on these
   paths (tags `Digital TX/DMR`, `Digital TX/DMR data`, `RF`, `RF/squelch`, `RF (cds task)`, `shared (DMR tasks)`,
   `Main loop`, and whatever the walk reaches).
3. For each root, state the trigger and every gate (Rx Only channel, TX inhibit/busy lock, TOT, settings, CC/slot
   checks) with addresses. Compare with `AUTONOMOUS_TX.md`: confirm or correct each row, add missing triggers, and
   make the "Safe test practice" paragraph match the result. Include the analog side (CTCSS/DCS tail, roger beep,
   DTMF/TBST were found key-initiated: re-confirm).
4. Record which of these paths the TS/CC Match design (`MATCH_OPTIONS_DESIGN.md` §3.8–§3.9) touches and confirm
   that its read-only subjects (`03027334`, `0301DE64`, `0301DF0C`, `0301DF8C`, `0002D7C8`, `0002D6C0`, …) are the
   complete set of TX-relevant code it must not change.
5. Deliverable: `docs/TX_PATHS.md` (sink table, root table with gates, call graph summary, what changed in
   `AUTONOMOUS_TX.md`), updated `AUTONOMOUS_TX.md`, catalog rows.

### T2 — CPS/USB protocol and codeplug compatibility

Goal: know exactly what the official CPS reads and writes, so that new settings (e.g. block 4 `0x60` bits 2/3 for
TS/CC Match) survive a CPS write, and nothing a mod does breaks CPS compatibility.

1. Review the `CPS/USB` (≈ 43) and `Codeplug/channels` (≈ 24) tagged functions and the reviewed task `usb`
   (`0302B340`, frame loop `0302A448`): every frame/command type, address/sector range checks, the write path to
   SPI flash (erase/program granularity, verification), what is reloaded after a write, `SYSINFO`, `PROGRAM`,
   `DEL-RCD`, `RTCITEM`, `PCTESTM` sub-commands (`RX_CALL_PATH_ANALYSIS.md` §15.3).
2. Map which flash sectors / data-flash areas the radio lets the CPS read and write, and whether a CPS write
   replaces whole sectors (then unknown bits survive only if the PC software preserves them) or patches fields.
   Block 4 (`0x60`, `0x85`, `0xA0`, …), the channel records and the zone/scan areas are the priority.
3. State what can be answered statically from the firmware and what depends on the PC CPS software (which is not in
   this repository). Write the owner test proposal for "does a CPS read → write round trip preserve block 4 `0x60`
   bits 2–7" as a **read-only comparison** procedure (CPS read, save, write back unchanged, read again, compare the
   files offline) and mark that it writes the radio, so the owner decides.
4. Deliverable: `docs/CPS_PROTOCOL.md` (command table, address map, write semantics, compatibility rules for mods,
   open questions), updated `SETTINGS_CPS_ANALYSIS.md` and `MATCH_OPTIONS_DESIGN.md` §2 (storage choice), catalog rows.

### T3 — Baseband and DMR task code around the TS/CC Match sites

Goal: close `NEXT_AGENT_PROMPT.md` item 5 statically, so the later candidate build starts from verified facts.

1. Review the `Baseband registers` (≈ 54), `shared (DMR tasks)` (≈ 33) and `Digital RX/DMR` (≈ 14) tagged
   functions that are on the paths of the sites T1–T10 / C1–C7 (`MATCH_OPTIONS_DESIGN.md` §3.8–§3.9), using the
   HR_C7000 datasheet for every register they touch.
2. For each site: execution context (ISR `0002C458`, task `sysint` `0002D770`, `txslot` `0002D620`, `rxvoice`,
   `rxcsbk`, …, with priorities from `LIBRARY_SIGNATURES.md` §6), the stack budget of that task, reentrancy and
   shared-variable access (which tasks/ISRs write `3BEAA`, `3BEAB`, `3BEBD`, `3C61A`, `3BEB8`), interaction with the
   global burst-loss timer `3BEB8`, scanner busy/stop logic, recording and Call Log with a B-slot call, and the CPU
   load path with `cc_opt = 1` (IRAM `0002D7C8`).
3. Mark each item resolved (code-verified) or as an owner RX-only test with expected result.
4. Deliverable: a new section in `MATCH_OPTIONS_DESIGN.md` ("§3.10 Static review of new risks"), updates to
   `HR_C7000_CROSSCHECK.md` for newly identified registers, catalog rows.

## 3. Scope limits

- Do not start a general review of UI, menus, vocoder or other subsystems; touch them only where a T1–T3 path goes
  through them, and then only the functions on the path.
- Prefer depth over breadth: a smaller set of functions reviewed with evidence is worth more than many guesses.
- After each work item update `DECOMPILED_MODULES.md` (cluster table), `RE_NOTES.md` (dated entry),
  `PROJECT_STATUS.md`, and regenerate nothing else.

## 4. Deliverables and reporting

- Commit in logical steps (T1, T2, T3, docs) with clear messages, push to the branch you were assigned, do not open a
  pull request, do not push to master.
- Each doc ends with: open questions for the owner, RX-only hardware test proposals with expected results and the
  features to disable first, and the list of items left unreviewed.
- Final message: per work item what was done with confidence labels, the TX sink/root summary and every correction
  to `AUTONOMOUS_TX.md`, the CPS write semantics and the storage recommendation for TS/CC Match, the resolved/open
  risk list for the TS/CC Match sites, catalog counts before/after (high/medium/low/unreviewed/`auto:`), test
  results of both suites, commits pushed. State explicitly that no image file was written and no radio was accessed.
- If a step cannot be completed, record the partial result and the exact blocker and continue with the next step
  that does not depend on it.
