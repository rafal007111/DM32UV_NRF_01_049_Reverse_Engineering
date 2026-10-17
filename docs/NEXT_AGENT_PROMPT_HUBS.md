# Prompt: name the hub functions and the display primitives

Written 2026-10-17 after the CPS/keys-stack pass (`master` `9c9c7ac`: 587 of 2171 catalog rows reviewed, 1584
unreviewed, 848 of them with an `auto:` subsystem tag). The libraries are named; what remains is vendor code. Many
unreviewed functions are small helpers called from dozens of places: 34 have ≥ 20 direct callers and 76 have ≥ 10
(e.g. `0300F780` 118 callers, `0300C500` 107, `0300C53C` 102, `03017BE8` 87, `03018AF4` 77, `0300F71C` 68). Naming
them makes every listing that calls them readable. This prompt covers only those hubs and the display/menu drawing
primitives; it is not a general review.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything; record owner decisions as open questions and continue.

## 0. Before you start

1. Follow section 0 of `docs/NEXT_AGENT_PROMPT_TARGETED.md` (documents to read, input hashes, tooling with
   `bash tools/setup_cloud.sh --with-thead`, baseline tests: firmware 10 passed / 1 skipped, tools 31 tests with only
   the 2 GCC-13-corpus tests skipped). Also read `docs/SUBSYSTEM_TAGS.md`, `docs/LIBRARY_SIGNATURES.md` §6 (task
   list) and `docs/CPS_PROTOCOL.md` (flash helpers already named). Do not re-derive documented facts.
2. Section 1 (hard rules) of `docs/NEXT_AGENT_PROMPT_TARGETED.md` applies unchanged: static analysis only, never open
   a serial port, send CPS words or write the radio, never write a firmware image file; catalog edits keep the UTF-8
   BOM and CRLF, touch only rows you read and keep `current_name` (`FUN_…`); label every finding; no GPL code; no model
   identifiers in commits or docs.

## 1. Work item H1 — hub functions

1. Build the work list: every catalog row with `confidence = unreviewed` and at least **10** direct callers
   (`known_direct_callers`), sorted by caller count (about 76 rows). Add unreviewed functions with fewer direct callers
   but ≥ 10 call sites through tail calls, function pointers or `jsri` if `tools/dm32 callers` shows them. Save the
   list (address, callers, size, tag) in the new doc.
2. For each hub: read the listing (`tools/dm32 fn`), the RAM/MMIO accesses (`acc`), a sample of call sites (argument
   values set before the call, what is done with the result) and, where useful, `decomp`. Give it a descriptive role
   (what it does, arguments, return value, side effects, RAM/MMIO it touches). Typical expected groups (verify, do not
   assume): flash/mutex lock and unlock, delays, GPIO set/clear (`0002C504`/`0002C548`), data-flash/codeplug record
   access (`0300F71C`, `0300FA28`, `0002B9A0`, `0002B904`), event-group/semaphore wrappers around the named kernel
   calls, UI popup/prompt (`030130AC`), settings getters.
3. Where several hubs form one API (e.g. a lock/unlock pair, a get/set pair), name them together and cross-check
   that their call sites pair up.
4. Confidence: `high` only with structural evidence (body read completely, MMIO/RAM meaning established, call sites
   consistent); `medium` for consistent but partly inferred roles; `low` otherwise. Replace an `auto:` subsystem by
   the reviewed one and record disagreements with the tagger in `SUBSYSTEM_TAGS.md`.

## 2. Work item H2 — display and menu drawing primitives

1. Identify the LCD/display driver and the drawing layer: the hardware interface (SPI/parallel bus, GPIO lines,
   MMIO base; check the bases still unidentified in `SUBSYSTEM_TAGS.md`), frame-buffer or direct-write model,
   screen size and colour format, and the primitives (clear, fill rectangle, draw pixel/line, draw bitmap — the Scan
   List checkmark draws `03018D78` with bitmap `03082BE0` are a known anchor, `RE_NOTES.md` "Scan Zone" — draw
   character/string with font tables, number formatting helpers, highlight/selection bar, scroll lists, popups).
2. Start from the hubs tagged `auto: Menu/input` and `auto: shared (UI tasks)` with many callers (`03017BE8`,
   `03018AF4`, `0304A1E8`, `03035E68`, `03036BB0`, `03018930`, `0303A4F4`, `03030560`, `03018C70`, `0301340C`,
   `0303900C`) and follow their callees down to the hardware.
3. Document fonts and bitmaps you find (table addresses, glyph size, character set, how Chinese/English text is
   selected — `3E9D4+0x30` bit 6 is the language flag), without exporting bitmap data.
4. Do not review individual menu scenes; only the shared drawing layer. Name a scene function only when it is on
   the path you are following anyway.

## 3. Deliverables and reporting

- New doc `docs/HUB_FUNCTIONS.md`: work list, per-group sections (API tables with address, name/role, arguments,
  return, confidence), the display architecture (hardware interface, drawing primitives, fonts/bitmaps), open
  questions, items left unreviewed. Update `DECOMPILED_MODULES.md` (cluster rows), `RE_NOTES.md` (dated entry),
  `PROJECT_STATUS.md`, `SUBSYSTEM_TAGS.md` (tagger agreement on the reviewed rows), catalog rows.
- Add a regression test in `tools/tests/test_dm32re.py` (class `Analysis` style) that pins two or three
  code-verified facts you rely on (e.g. a lock/unlock pairing or an MMIO register write of the display driver).
- Commit in logical steps (H1, H2, docs) with clear messages, push to the branch you were assigned, do not open a
  pull request, do not push to master.
- No hardware test is needed for naming; if a display fact can only be confirmed on the radio, write it as an
  owner observation that does not transmit (e.g. what a screen shows), never as a TX test.
- Final message: per work item what was done, how many of the work-list hubs were named and with which confidence,
  the display architecture summary, catalog counts before/after (high/medium/low/unreviewed/`auto:`), test results of
  both suites, commits pushed, items left. State explicitly that no image file was written and no radio was accessed.
  If a step cannot be completed, say exactly why and continue with the next one.
