# Prompt: finish T2 (CPS protocol table) and the `keys` stack question

Written 2026-10-17 after the targeted review (`TX_PATHS.md`, `MATCH_OPTIONS_DESIGN.md` §3.10, merged in `0337279`).
T2 of `NEXT_AGENT_PROMPT_TARGETED.md` was left partial: the storage decision is made, but the CPS command table and
`docs/CPS_PROTOCOL.md` were not produced. One T3 item is open: a stock static path in task `keys` exceeds its stack.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything; record owner decisions as open questions and continue.

## 0. Before you start

1. Follow section 0 of `docs/NEXT_AGENT_PROMPT_TARGETED.md` (documents to read, input hashes, tooling with
   `bash tools/setup_cloud.sh --with-thead`, baseline tests: firmware 10 passed / 1 skipped, tools 31 tests with only
   the 2 GCC-13-corpus tests skipped). Additionally read `docs/TX_PATHS.md`, `docs/SETTINGS_CPS_ANALYSIS.md` §3 and
   §11, `docs/MATCH_OPTIONS_DESIGN.md` §3.10, and the git log of the targeted review (`b785d47`, `6aa901d`,
   `527e368`) to see why T2 stopped. Do not re-derive documented facts.
2. Section 1 (hard rules) of `docs/NEXT_AGENT_PROMPT_TARGETED.md` applies unchanged: static analysis only, never open
   a serial port, send CPS words or write the radio, never write a firmware image file, catalog edits keep BOM/CRLF
   and touch only rows you read, label every finding, no GPL code, no model identifiers.

## 1. Work item T2b — CPS protocol table (`docs/CPS_PROTOCOL.md`)

1. Complete the frame/command table of the USB CPS protocol: the handshake words (`PROGRAM`, `PON-PIC`, `SYSINFO`,
   `DEL-RCD`, `RTCITEM`, `PCTESTM` and any other word compared in task `usb` `0302B340`), and inside the frame loop
   `0302A448`/`03029FB0` every frame type (`V`, `C`, `S`, `G`, and any other): byte layout, length, checksum,
   address/sector arguments, range checks, replies and error paths. For `PCTESTM` list the sub-commands
   (`RX_CALL_PATH_ANALYSIS.md` §15.3) and state which of them can key the transmitter (cross-check `TX_PATHS.md`).
2. Write semantics: which address ranges the CPS can read and write (program flash vs SPI data flash), erase/program
   granularity, whether any verification or read-back happens, what is reloaded after a session, and whether the
   firmware itself ever rewrites a sector the CPS wrote (e.g. block 4 on boot or on menu save).
3. Address map: link each CPS-visible range to the known data-flash areas (block 4 settings, channel records, zones,
   scan lists, contacts, roaming areas `0x65`/`0x66`, Call Log `0x0C`–`0x0E`, Inbox/OutBox, recordings
   `0x6DC…0xFFF`, Lone Worker `0x10`/`0xB00`, stun flag area 4 `0xF00`), with evidence.
4. Compatibility rules for mods: what a modded firmware must keep stable so the official CPS still reads and writes
   the codeplug correctly, and what is unknown without the PC software. Keep the block 4 `0x60` bits 2/3 decision of
   `SETTINGS_CPS_ANALYSIS.md` §11 unless the new evidence contradicts it (then say why).
5. Deliverables: `docs/CPS_PROTOCOL.md`, a short update of `SETTINGS_CPS_ANALYSIS.md` §3 pointing to it, catalog rows
   for the functions you read (`auto: CPS/USB` and others), `DECOMPILED_MODULES.md`, `RE_NOTES.md`,
   `PROJECT_STATUS.md`.

## 2. Work item S — the `keys` task stack (`MATCH_OPTIONS_DESIGN.md` §3.10, row T9)

The stock worst static path from task `keys` (`03012D2C`, 192 words = 768 B) through the PTT handler `0305C334` →
menu redraw `0303B6AC` → `sprintf` `030704C4` is about 1224 B. Decide statically whether that path is feasible
(conditions on the way, scene state when the PTT handler runs) or infeasible; if feasible, estimate the real depth
with the actual frame sizes (prologue `subi sp`/`push` amounts, `sprintf`/formatter usage) and check whether the
stock firmware has stack checking (`OSTaskStkChk`, stack limit 12 words, `OSTaskSwHook`) that would catch it.
Record the result in `MATCH_OPTIONS_DESIGN.md` §3.10 (resolved or open, with the RX-only owner test if one helps) and
state the consequence for the T9 site (it must stay a frameless leaf in any case).

## 3. Deliverables and reporting

- Commit in logical steps (T2b, S, docs) with clear messages, push to the branch you were assigned, do not open a
  pull request, do not push to master.
- Each doc ends with open questions for the owner, RX-only hardware test proposals (state when a proposal writes the
  radio, like a CPS round trip, and leave that decision to the owner), and the items left unreviewed.
- Final message: what was done per item with confidence labels, the CPS command table summary and write semantics,
  the `keys` stack verdict, catalog counts before/after, test results of both suites, commits pushed. State
  explicitly that no image file was written and no radio was accessed. If a step cannot be completed, say exactly
  why and what is missing, and continue with the next one.
