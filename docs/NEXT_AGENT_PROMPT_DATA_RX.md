# Prompt: complete receive path for DMR data and text messages (why does nothing arrive?)

Written 2026-10-18. The owner has never received a data packet or a text message on the radio and asks whether
messages are accepted only when the DMR ID matches. `DATA_PATH_ANALYSIS.md` already shows (code-verified) that the
data header filter `0302768C(6, …)` accepts group data only for the channel contact `33CF4` or the 32 RX group list
IDs `33CF8…`, individual data only for the own ID `33CEC`, and that CC and slot must match with no Monitor bypass.
What is missing is the **complete** list of conditions between a received data burst and a message shown in the
Inbox, which message formats are understood, and which CPS settings matter.
Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse engineering of the Baofeng DM32UV, firmware DM32.NRF.01.049 (C-SKY CK803S / HR-C7000,
application VA 0300C000, flash offset = VA − 03000000, IRAM 00010000–0002F0B4 copied from 030C0C38). Work
**unattended**: do not ask the user anything; record owner decisions as open questions and continue.

## 0. Before you start

1. Follow section 0 of `docs/NEXT_AGENT_PROMPT_TARGETED.md` (documents to read, input hashes, tooling with
   `bash tools/setup_cloud.sh --with-thead`). Baseline tests: firmware 10 passed / 1 skipped, tools **45** tests with
   only the 2 GCC-13-corpus tests skipped. Read especially `docs/DATA_PATH_ANALYSIS.md` (all), `docs/RX_CALL_PATH_ANALYSIS.md`
   (§0.1, §2, §13 onwards), `docs/TS_ANALYSIS.md`, `docs/CC_MATCH_ANALYSIS.md`, `docs/CHANNEL_RECORD.md`,
   `docs/SETTINGS_CPS_ANALYSIS.md`, `docs/CPS_PROTOCOL.md`, `docs/UI_MAP.md`, `docs/HUB_FUNCTIONS.md`,
   `docs/TX_PATHS.md`, `docs/AUTONOMOUS_TX.md`. Do not re-derive documented facts; extend them.
2. Section 1 (hard rules) of `docs/NEXT_AGENT_PROMPT_TARGETED.md` applies unchanged: static analysis only, never open
   a serial port, send CPS words or write the radio, never write a firmware image file; catalog edits keep BOM/CRLF
   and touch only rows you read; label every finding; no GPL code copied (OpenGD77, MMDVM, DMRGateway, SDRTrunk,
   qdmr and the ETSI/Motorola/Hytera documents are design references only); no model identifiers.
3. Receiving an individually addressed message makes this radio **transmit** (link ACK and an application reply,
   `DATA_PATH_ANALYSIS.md` §6). Every owner test you propose must say whether it can cause a transmission, and prefer
   tests that cannot (group messages to a talkgroup in the RX group list).

## 1. Work item D1 — the complete receive chain

Trace, with addresses and the exact condition at each step, everything between a data burst at the baseband and a
message visible to the user:

1. Baseband and slot level: data sync / burst types reaching the data handlers (`030239D4` dispatch, `03028644`
   slot gate and data-type table, `03028BE4`), CC check (`3C61A == 33CCD`), per-slot state `3C622`, CRC and FEC
   failures, the DCDM/Double Slot mode, scanning and channel-change effects, timeouts that drop a partial transfer.
2. Data header `03024E7C`: every header class (DPF values: unconfirmed, confirmed, response, defined short data,
   raw/status short data, proprietary, UDT), SAP, blocks-to-follow limits, the destination filter `0302768C(6, …)`
   (own ID / channel contact / RX group list / source ≠ own), anything that depends on GCall/PCall Match, Monitor,
   Rx Only or encryption/privacy (data encryption, `03027628` late-entry decrypt), and the effect of the channel's
   **RX Group List** being empty or not containing the sender's talkgroup.
3. Packet data `03025480`, reassembly in `3C278` (block counts, rate ½ / ¾ / 1, last-block CRC-32, sequence numbers,
   selective ACK, retries), and the classifier `0302530C`: which payload formats are recognised as **text** —
   ETSI TS 102 361-4 short data, IPv4/UDP (which ports, e.g. Motorola TMS 4007/5016-style, LRRP 4001), Hytera, the
   SAP-3 `0x8000` and `0x44` formats in `DATA_PATH_ANALYSIS.md` §6 — character encodings (UTF-16LE, ISO-8859-1,
   GB2312, 7-bit), maximum length, and what happens to unrecognised payloads (silently dropped?).
4. Task `rxmsg` `0301FF9C` → Inbox storage (`0302DF18` / `03053D74`, data-flash area 7, 100-entry ring) → popup /
   tone / Message alert (`AUDIO_TONES.md`, `UI_MAP.md`): conditions that suppress storing or showing (Inbox full,
   menu scene open, Radio Silent, call in progress, settings bits).
5. CSBK short messages / status / call alert (`rxcsbk` `030209E4`), in case "messages" arrive as CSBK.
6. GNSS/APRS position messages (`GNSS_ANALYSIS.md`) only as far as they share the path.

## 2. Work item D2 — settings that gate reception

Find every codeplug or menu setting read on the D1 chain: per channel (`CHANNEL_RECORD.md`: CC, TS, Double Slot,
RX group list `+0x0F`, contact, privacy, Rx Only, data/SMS options if any) and global (block 4: SMS format or
"data type" options, message alert, own ID, "Data Ack"/"SMS ACK", decode flags `0x65`, GCall/PCall Match). Map
each to its CPS field name where the menu or `SETTINGS_CPS_ANALYSIS.md` gives it.

## 3. Work item D3 — "why nothing arrives" checklist and owner tests

1. Write a checklist ordered from most to least likely: each item names the condition, the code site, the CPS field
   to check and the expected symptom. Include the network side as **inferred** context (repeaters and hotspots that
   do not forward data, Brandmeister/other networks sending SMS as individual data to the DMR ID in a specific format,
   the sender radio's SMS format setting, private vs group addressing, slot and CC of the repeater).
2. Propose owner tests, cheapest and safest first, each marked "can transmit: yes/no": e.g. a group text from a
   second radio on simplex to a talkgroup in the channel's RX group list (no ACK/reply expected); an individual text
   to the own ID (the radio will transmit an ACK and a reply — state it); a text in each sender format if the second
   radio supports several. Give the expected result for each format the firmware accepts.
3. If the owner can provide a CPS codeplug file later, list exactly which bytes to check offline.

## 4. Deliverables and reporting

- New doc `docs/DATA_RX_PATH.md` (chain diagram/table with every gate, formats table, settings table, checklist,
  owner tests, open questions, items left unreviewed); updates to `DATA_PATH_ANALYSIS.md` (corrections, pointer),
  `SETTINGS_CPS_ANALYSIS.md`, `CHANNEL_RECORD.md` as needed; `DECOMPILED_MODULES.md`, `RE_NOTES.md` (dated entry),
  `PROJECT_STATUS.md`; catalog rows for the functions you read (replace `auto:` tags you review).
- Add regression tests in `tools/tests/test_dm32re.py` for two or three code-verified gates (e.g. the destination
  filter's own-ID comparison, a classifier format constant).
- Commit in logical steps (D1, D2, D3, docs), push to the branch you were assigned (or create `claude/<topic>` from
  master if none is named), do not open a pull request, do not push to master.
- Final message: the receive chain summary with every gate, the accepted message formats and encodings, the
  settings that gate reception, the checklist (top items) and owner tests with their TX implications, catalog counts
  before/after, test results of both suites, commits pushed. State explicitly that no image file was written and no
  radio was accessed. If a step cannot be completed, say exactly why and continue with the next one.
