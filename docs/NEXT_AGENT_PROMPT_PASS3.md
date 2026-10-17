# Prompt: TS/CC Match–relevant code, second-tier hubs and table-called handlers

Written 2026-10-17 after the hub/display pass (`master` `81d3dff`: 703 of 2171 catalog rows reviewed, 1468
unreviewed, 795 with an `auto:` tag; `docs/HUB_FUNCTIONS.md`). Remaining unreviewed rows by direct callers: 774 with
one, 409 with 2–4, 81 with 5–9, 204 with none (called through pointer tables). This is the last planned naming pass;
after it the project moves to the TS/CC Match candidate. It covers three groups only.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything; record owner decisions as open questions and continue.

## 0. Before you start

1. Follow section 0 of `docs/NEXT_AGENT_PROMPT_TARGETED.md` (documents to read, input hashes, tooling with
   `bash tools/setup_cloud.sh --with-thead`). Baseline tests now: firmware 10 passed / 1 skipped, tools **33** tests
   with only the 2 GCC-13-corpus tests skipped. Also read `docs/HUB_FUNCTIONS.md`, `docs/CPS_PROTOCOL.md`,
   `docs/TX_PATHS.md`, `docs/MATCH_OPTIONS_DESIGN.md` §3.8–§3.10, `docs/SUBSYSTEM_TAGS.md`. Do not re-derive
   documented facts.
2. Section 1 (hard rules) of `docs/NEXT_AGENT_PROMPT_TARGETED.md` applies unchanged: static analysis only, never open
   a serial port, send CPS words or write the radio, never write a firmware image file; catalog edits keep the UTF-8
   BOM and CRLF, touch only rows you read and keep `current_name` (`FUN_…`); label every finding (`high` only with
   structural evidence); replace `auto:` tags you review and record tagger disagreements in `SUBSYSTEM_TAGS.md`; no
   GPL code; no model identifiers in commits or docs.

## 1. Work item P1 — code relevant to TS/CC Match and CPS compatibility

Review every unreviewed function tagged `auto: Codeplug/channels` (≈ 20), `auto: Baseband registers` (≈ 48),
`auto: shared (DMR tasks)` (≈ 28), `auto: CPS/USB` (≈ 37) and `auto: Digital RX/DMR`, `auto: Digital TX/DMR`,
`auto: Digital TX/DMR data` (whatever is left). For each: role, arguments/return, RAM/MMIO touched (registers checked
against the HR_C7000 datasheet, `HR_C7000_CROSSCHECK.md`), callers. Flag anything that changes the TS/CC Match design
or its read-only subject list (`MATCH_OPTIONS_DESIGN.md` §1/§3.10) or the CPS compatibility rules
(`CPS_PROTOCOL.md`), and update those docs if needed. Close the open `PCTESTM` sub-command table of
`CPS_PROTOCOL.md` only as far as these functions require.

## 2. Work item P2 — second-tier hubs

Review every unreviewed function with **5–9** direct callers (≈ 81; e.g. `03059D5C` scene-state gate, `0300F5B4`,
`0300F52C` next to the data-flash helpers, `0301B5F0`, `0304A39C`, `03064C9C`), the same way as `HUB_FUNCTIONS.md` H1:
role, arguments, return, side effects, RAM/MMIO; name API pairs together and check their call sites pair up. Skip
rows already reviewed by P1.

## 3. Work item P3 — table-called handlers (UI map)

1. Find the pointer tables that dispatch the 204 functions with no direct callers (and table-called functions that
   have callers): side-key function table (43 entries at `030728DC`, names at `030BB424`), menu/scene tables
   (`RE_NOTES.md` "Menu and UI", menu dispatch `03038500`/`0303B6AC`/`03048F50`, menu tables in
   `firmware/source/menu_tables.c` and `firmware/menu_tables_audit.json`), soft-key tables, scene callback tables, and
   any table in the initialised SRAM copy (`030727D0` → `18000800`). `tools/dm32 callers` already lists table words.
2. For each table: address, entry count, entry layout, the menu string or key name of each entry (via the string
   tables) and the handler. Name each handler from its entry ("scene: Other Func list", "side key 25: Monitor", …) and
   read enough of it to confirm the role (`medium` when the entry–string link and the body agree, `low` when only the
   table position is known).
3. Produce the UI map: menu tree (main menu → sub-menus → items with scene ids and handlers), side-key functions,
   soft keys. Mark where the planned TS/CC Match items go (Other Func entries 22/23 after `MOTO`,
   `MATCH_OPTIONS_DESIGN.md`) and which tables and handlers that change touches.
4. Do not review the bodies of individual scenes beyond confirming their role.

## 4. Deliverables and reporting

- New doc `docs/UI_MAP.md` (P3: tables, menu tree, side keys, soft keys, the TS/CC Match insertion points); a new
  section per work item in `docs/HUB_FUNCTIONS.md` for P2; P1 results in the existing docs it touches
  (`HR_C7000_CROSSCHECK.md`, `CPS_PROTOCOL.md`, `MATCH_OPTIONS_DESIGN.md`, `CHANNEL_RECORD.md` as needed) plus a
  short summary section in `HUB_FUNCTIONS.md`. Update `DECOMPILED_MODULES.md`, `RE_NOTES.md` (dated entry),
  `PROJECT_STATUS.md`, `SUBSYSTEM_TAGS.md` (tagger agreement on the rows you reviewed), catalog rows.
- Add regression tests in `tools/tests/test_dm32re.py` for two or three code-verified facts (e.g. one table layout
  and entry, one P1 register fact).
- Commit in logical steps (P1, P2, P3, docs) with clear messages, push to the branch you were assigned (or create
  `claude/<topic>` from master if none is named), do not open a pull request, do not push to master.
- No hardware test is needed for naming; screen-only owner observations are allowed, never TX tests.
- Final message: per work item what was done (counts and confidence), anything that changes the TS/CC Match design
  or CPS rules, the UI map summary and TS/CC Match insertion points, catalog counts before/after
  (high/medium/low/unreviewed/`auto:`), test results of both suites, commits pushed, items left. State explicitly
  that no image file was written and no radio was accessed. If a step cannot be completed, say exactly why and
  continue with the next one.
