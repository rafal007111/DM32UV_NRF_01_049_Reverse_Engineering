# Reverse engineering notes: DM32.NRF.01.049

## Target and evidence

Radio: Baofeng DM32UV, firmware DM32.NRF.01.049. Official wrapper SHA-256: aff6b4dc09dcce45847173defba26e94157cc628af86826e21e5af227bdc52dd. Stock program backup SHA-256: de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0. The code is C-SKY CK803S/HR-C7000, not ARM. Application VA starts at 0300C000; program-flash offset is VA minus 03000000.

Use confidence labels: hardware-verified means owner observed it on the radio and readback matched; code-verified means supported by instructions/literals/call flow; inferred means likely but not proven; unreviewed means catalog-only. The C-like output is not original source and cannot reproduce the vendor binary exactly.

## Menu and UI

Scene object begins at RAM 320C8; current scene byte +3, pending callback +4. UI mutex at 3E4E0. Current menu count/items/index at 3E618, 3E61A, 3E5EC; saved indices at 3E508; main physical map at 3E65F; Scan map at 3E682. Main physical ID 1 is Scan. Scan scene 0E; Scan List child scene 15.

Dispatch/confirmation/key routines: 03038500, 0303B6AC, 03048F50, 0304D07C, 03013078. Recovered tables and evidence are in analysis/ghidra_scripts and analysis/reference.

## Scan Zone

Stock scan state begins at RAM 3E160. Mode getter/setter: 0302ECE0/0302ECA0. Stop/start: 0302F388/0302F418. Scan List record loader: 0302E1A4. Native list renderer: 0302E820. Zone locator/current-channel lookup: 03055C90/0305660C.

The home source label is the 11-byte field at 3E196 with a terminator at 3E1A1. Channel/TX name is separate at 3E1A2. Native Scan List checkmark draws are at 0302E8C6 and 0302E952 via 03018D78 using bitmap 03082BE0. Generic marker helper 03039E34 does not cover that path. Scan Zone uses the same checkmark bitmap and the bridge suppresses native list ticks when zone source is selected. Owner reports the latest image works.

Current image SHA-256: 156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53. Full readback result is analysis/inputs/latest_install_result.json. Mod uses 32 bytes of reserved RAM at 4BFC0..4BFE0 and candidate code area beginning 030DFCEC. Stock prefix, startup and heap invariants were checked for each image.

## TS/CC receive investigation

CC setter path 0305CCF0 -> 0301EC40. The setter changes receiver software state and bit 8 of hardware register 11000384 based on argument bit 0. This setter behavior is code-verified; matched/mismatched packet acceptance remains untested end-to-end.

TS candidate 0301ECC0 writes receiver state bits but is not itself proof of dual-slot monitoring. DMR candidates 030239D4, 03028644 and 03028BE4 require deeper trace. Nearby receive code extracts CC from bits 7:4 of a decoded word, but the earliest TS/CC accept/drop point is not yet established.

Next trace: sync acquisition -> slot decode -> CC/TS comparisons -> RX accept/drop. Find callers of stock setters and their persistent setting fields. Compare matched/mismatched CC and slot on radio. Keep TX/PTT behavior unchanged as requested.

## Boundaries

Keep full program/data-flash backups and dated install logs. Do not write radio from an unattended agent. Image builds must use exact known baseline, guarded patch bytes and full-image comparison. The latest verified feature does not establish correctness of untested scanner modes or receive behavior.

### Offline reproducibility recovery (2026-10-13)

Code-verified: the current scanner module rebuilt with T-HEAD C-SKY Tools V3.10.29 / GCC 6.3.0 is 4458 bytes (SHA-256 b66ca0640d5aa8878ce0fc85aa3fceaac0133f86fa92a8b6fa4747d90fd4a7a1) and exactly matches installed image 156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53 at VA 030DFCEC. Stock image de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0, T-HEAD objdump 2.27 BSR boundaries and rebuilt symbols recover 55 installed call redirects. The installed-reference profile guards 58 changes and reproduces the complete installed image in memory, preserving the stock boot prefix. The generic candidate additionally changes 0303E24C and the Other descriptor at 030B9700; those remain stock in the installed reference. Historical intermediate baseline 568cb4e37a14104702c3c0deaa92f57086159fcddcfa3d5f53646db4aeecd819 and original installer remain unavailable. Recovered JSON evidence, direct endpoint delta and exact commands are documented in REPRODUCIBILITY.md. All 11 host tests passed under MSVC, including the private DMR1 fixture. Prior owner verification remains historical evidence; no new hardware test or serial access occurred.

### Stock Monitor key and the CC setter (2026-10-13, cloud Ghidra 12.1.4 + legacy CSKY v0.2 module, GZF `354f9324…`)

- **code-verified:** `0301EC40(arg)` sets bit 3 of byte `0003BA6C` (`0003BA54+0x18`) from `arg&1`, clears bits 8–9 of `11000384`, then sets bit 8 and writes `8` to `0003C61B` (`0003C614+7`) when `arg&1`, else writes `0`. `0305CCF0(on)` calls it with 1/0 and mirrors the state in bit 1 of `0003E341` (`0003E334+0xD`).
- **code-verified:** callers by BSR scan of the stock image: `0305CCF0` from `03017526`/`03017534` (inside `030174E0`) and `0305E198`/`0305E2B4` (inside `0305E134`); `0301EC40` directly from `0303209C`/`0303233E` (inside `03031FD4`) besides `0305CCFA`/`0305CD0E`.
- **code-verified:** `030174E0` toggles that state: bit 1 of `0003E341` clear → `0305CCF0(1)` and prompt `0x18`, set → `0305CCF0(0)` and prompt `0x19`. It is reached only from `03017560` (BSR at `030175E8`), which calls `0301742C` instead when the channel-type value is 0.
- **code-verified:** `03017560` has no direct callers; its address is the word at `03072940`, entry 25 of a 43-entry handler table starting at `030728DC`. The side-key function name table at `030BB424` also has 43 entries and entry 25 is `Monitor` (`030BB488`).
- **code-verified:** `03031FD4` (channel/mode change path) clears bit 1 of `0003E341` and calls `0301EC40(0)` when it was set, so the state does not persist across channel changes. `0305E134` also calls `0305CCF0(0)`.
- **inferred:** the stock **Monitor** side-key function on a digital channel enables a temporary receive mode through `11000384` bit 8, and on an analog channel opens squelch (`0301742C`, not reviewed). Whether bit 8 disables Color Code filtering, talkgroup filtering or both is **not established**. If it disables CC filtering, CC Match may reduce to persisting this existing state instead of new receive code.
- **owner test proposal (no patch, RX only):** assign Monitor to a side key in the official CPS, program a DMR channel for the local repeater with a deliberately wrong Color Code, press Monitor and listen for repeater traffic; repeat with the correct CC as control. A positive result would make the hypothesis hardware-verified.
- `0301ECC0` writes bit 0 of `11000100` and four RAM bytes; its caller `0304B158` is reached from many menu/settings routines. Its relation to the `Time Slot`/`Double Slot` menu strings at `030BE52C`/`030BE558` is unreviewed.

`analysis/ghidra_scripts/DecompAt.java` decompiles functions by address in a read-only headless run and creates a temporary function where Ghidra has none.

Detailed Monitor analysis (dispatch, setter state, RX data-type table, talkgroup filter bypass, lifetime and owner test): `docs/MONITOR_ANALYSIS.md`. It supersedes the "inferred" bullet above: Monitor is a temporary promiscuous **voice** mode (CC and talkgroup filtering bypassed for voice LC header/terminator/late entry), while PI header and packet data still require a matching CC.

Time slot analysis (channel fields, RX modes, per-burst CACH TC slot tracking, receive slot gates, existing PCall/GCall Match options): `docs/TS_ANALYSIS.md`. Summary: the firmware labels every burst with its slot in software and drops the non-programmed slot in `03028644`/`03028BE4`; whether `11000100` bit 0 also filters in hardware is not established.

2026-10-14 follow-up: `11000100` matches the HR-C6000 register `0x10` model (strong inference, OpenGD77 comparison), so the slot filter is software-only; voice from any active slot shares one buffer, so TS Match off needs single-slot capture; full CC comparison table with the TX-only site `03027334` to leave untouched: `docs/TS_ANALYSIS.md` §7–8 and `docs/CC_MATCH_ANALYSIS.md`.

2026-10-14 received data paths: data header `03024E7C`, packet data `03025480`, CSBK `03027B9C` and PI header `03027584` each require a CC match with no Monitor bypass (code-verified). Payloads are reassembled in `3C278` and classified by `0302530C` for task `rxmsg` (`0301FF9C`), which transmits link ACK/NACK/SACK and application replies for individually addressed texts; texts go to the data-flash Inbox via `0302DF18`/`03053D74`; a text `"WLT CMD "` + `'1'` makes the radio send its GPS position. Task `rxcsbk` (`030209E4`) transmits ACK/NACK CSBKs for Radio Check, Call Alert, Remote Monitor, Disable and Enable, and Disable stuns the radio persistently (data flash area 4 offset `0xF00`); on Rx Only channels the action runs without an ACK. Recommendation: keep the CC check for CSBKs and individual data; at most accept foreign-CC group text with replies suppressed. Details, event maps and risk table: [DATA_PATH_ANALYSIS.md](DATA_PATH_ANALYSIS.md). No hardware test performed.

### Received call path, per-slot state and open internals (2026-10-14)

Ghidra 12.1.4 + legacy CSKY v0.2 with a new SLEIGH fix (`zext`/`sext` were one bit short; 156 functions changed), GNU objdump 2.42; inputs hash-checked (stock `de7dbcbc…`, installed `156a4872…`, GZF `354f9324…`). No radio access.
- code-verified: event 2 is consumed by task `rxvoice` (`030206D0`, mask `0x40006807`), which fills `3BD48`, notifies task `psint` (`0305F234` → `0305E3F0` call display/tones) and opens audio (`030218B0`, amp `0301D624`). Event `0x8000000` = slot sync lock from `0002D500`, consumed only by TX admit `0301DF8C`.
- code-verified: `3C620` voice, `3C622` data, `3C624` terminator-seen, `3C626` embedded-CC mismatch counter (ends a call after 7, no Monitor bypass). No per-slot hang timer; global burst-loss timer `3BEB8` resets both slots after 13 ticks. An existing MS-sourced single-slot rule can serve as the model for TS Match off (inferred design).
- code-verified: CSBK `03027B9C` has a single CC gate (full opcode table); `0002D7C8` sets CC 15 only while transmitting a CT_CSBK in mode 4; channel-menu `Time Slot`/`Double Slot` map to settings 5/'F' and channel byte `+0x0D` bits 4/5; analog Monitor forces audio open.
- Details, data-path internals, settings map, CPS command words, owner questions and RX-only tests: [RX_CALL_PATH_ANALYSIS.md](RX_CALL_PATH_ANALYSIS.md).

### Settings menus, CPS framing and RF chip (2026-10-14, second pass)

Same inputs/tools as the entry above; static only. code-verified: Radio Settings menus (Voice/Key/Display/Other Func) mapped item by item to setting ids and block-4 storage; Voice Func `Group Call`/`Private Call` are the call-start tone options; Other Func `MOTO` is stored but never read. Block 4 `0x60` bits 2–7 and RAM `3BA6D` bits 5–7 have no reader (candidate storage for TS/CC Match, CPS behaviour to be checked). CPS session framing (`V`/`C`/`S`/`G` frames, sector addresses, raw SPI-flash writes) documented. Strong inference: the RF chip uses the BK4819 register map (AM airband path via AF type 7) and `0305F2F4` is a system restart. Details: [SETTINGS_CPS_ANALYSIS.md](SETTINGS_CPS_ANALYSIS.md).

### TS/CC Match patch-site inventory (2026-10-14, design only)

No image built. [MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) lists the four Monitor-style CC gates (same `andi r,r,8` idiom on `3BA6C`), the embedded-CC counter and the four BS slot gates with stock bytes (identical in the installed image), proposed flag bits (`3BA6D` bits 5/6, block 4 `0x60` bits 2/3), and a placement constraint: the Scan Zone window ends exactly at the official payload end `030E14EC`, leaving 1686 zero bytes; space beyond lies outside the updater payload and is unreviewed. All inferred.

### CPS handshake and TS-off receive consumers (2026-10-14, third pass)

code-verified: task `usb` entry is `0302B340` (not `03029FB0`); `PROGRAM` runs the `02`/8×`FF`/`06` exchange and the frame loop (`0302A448`) and always restarts, `SYSINFO` opens the same frame loop without restart, `DEL-RCD` erases recording sectors and restarts ([SETTINGS_CPS_ANALYSIS.md](SETTINGS_CPS_ANALYSIS.md) §3.1). For TS Match off, `rxvoice` indexes the call descriptor and PI header by the TX slot `3BEAA` at `03020714`/`030207AA`/`030208FA`, and the `03028644` slot gate precedes the data-type table, so a bypass must be limited to voice bursts; `3BEBD..3BECB` appears unreferenced (inferred) ([MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) §3.3–3.4).

### Channel record and TX admit inputs (2026-10-14, fourth pass)

code-verified from the channel loader `03057790`: channel record bytes `+0x08` (type, Rx Only), `+0x0A` (TX admit policy bits 6:4, talkaround/simplex bits), `+0x0B` (emergency alarm accept/ACK/system index), `+0x0C`/`+0x10` (privacy key), `+0x0D` (CC/TS/Double Slot), `+0x16`, `+0x1B`; AM-window channels are forced to analog Rx Only. TX admit uses the RF carrier and last RX CC in modes 0/4 and slot state only in mode 1, so TS Match off could affect PTT only on repeater channels. See [SETTINGS_CPS_ANALYSIS.md](SETTINGS_CPS_ANALYSIS.md) §3.2 and [MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) §3.6.

2026-10-14 tooling: `tools/dm32` (static only) adds whole-image C-SKY disassembly with literal pools and switch tables, call graph including 289 entries Ghidra lacks, RAM/MMIO access search, look-alike search, cached GZF decompilation and uC/OS-III identification (inferred: kernel mainly in IRAM, e.g. `00011A58` ≈ `OSSemPend`, `000120DC` ≈ `OSSemPost`). See [DM32RE_TOOLS.md](DM32RE_TOOLS.md) and `analysis/decompiled_modules/libid_ucos3_candidates.csv`. No hardware test performed.

2026-10-14 HR_C7000 datasheet ([`HR_C7000 Document 2.pdf`](HR_C7000%20Document%202.pdf) pp. 97 and 301–302, see [EXTERNAL_RESOURCES.md](EXTERNAL_RESOURCES.md)): `0x11000384` is `LOCAL_CC`, bits 9:8 `cc_opt` (0 = only local CC decoded, 1 = any valid CC decoded), so Monitor's bit 8 selects hardware "any CC" (datasheet + code-verified sites; not hardware-verified). `0x11000100` is `WORK_MODE`, bit 0 `work_slot_sel` (0 = TS1, 1 = TS2). `0x11000390` is `RX_TYPE_INFO` (CC [7:4], data type [11:8], RX slot [19]); `0002C458` copies it to RAM `3BECC`, the word `03028644` decodes.

2026-10-14 channel record vs qdmr: `3E1F8` is the current-channel copy of codeplug record body bytes `0x10–0x2F` (BCD frequencies converted) plus the name at `+0x20`; addressing in `03055CCC` matches qdmr exactly (block `0x12`, 84 + 85-per-block records of `0x30`). `0x1D` bit 5 is qdmr's DCDM (Double Slot). qdmr disagrees on the scan-list field (6:2 vs firmware 5:0). Details: [CHANNEL_RECORD.md](CHANNEL_RECORD.md). No hardware test.

2026-10-14 CC Match design ([CC_MATCH_DESIGN.md](CC_MATCH_DESIGN.md)): foreign-CC voice needs `cc_opt=1` (`11000384` bit 8, writers `0301E580`/`0301EC40`) plus the voice-site bypass; all CSBK processing is guarded by a CC equality test. Proposed storage: block 4 `0x60` bits 2/3 (0 = stock). Safety: CPS decode flags (block 4 `0x65`) are ignored on Rx Only channels for Disable/Enable/Call Alert (code-verified, not hardware-verified).

### HR_C7000 register cross-check (2026-10-14, fifth pass)

Datasheet `HR_C7000 Document 2.pdf` (`d60f652e…`) against the stock image (`de7dbcbc…`; installed `156a4872…` and GZF `354f9324…` hash-checked), Ghidra 12.1.4 + CSKY v0.2 + sinc fix 3, binutils 2.42, `tools/dm32`. Static only.
- datasheet + code: a **hardware CC filter exists** (`LOCAL_CC.cc_opt`, `11000384` bits 9:8); Monitor and RX mode 4 set "any CC". CC Match off needs `cc_opt = 1` plus the voice-site bypasses. The firmware never clears `RF_MODE.adjustsyncmax` (bit 12) although the datasheet asks for it with `cc_opt = 1` (open question).
- datasheet + code: **no hardware slot filter** is used — reception is enabled for every slot (`0002D7C8` → `rxnextsloten`), voice delivery is opened per slot from `3C620` (`03023828` → `begin_v_layer2`), and the chip keeps one voice buffer per slot (selected by status bit 19).
- datasheet + code: the ISR `0002C458` drains `SYS_INTERP_LIST`; `03028644` = frame-received, `03028BE4` = late-entry, `03027388` = CACH short-LC handler. Mode 4 = DCDM (TDMA1/2 sync + dual PHY). `0305F2F4` = CPU/system soft reset. `11000394` = `RX_INFO.rc_info` (burst-F KeyID/algorithm).
- Details, page references, open questions and RX-only tests: [HR_C7000_CROSSCHECK.md](HR_C7000_CROSSCHECK.md); hardware-CC design correction in [MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) §3.7.

### TS Match off design closure (2026-10-14, fifth pass, design only)

Same inputs/tools as the entry above; no image built. code-verified: every receive-path consumer of the burst slot vs. the TX slot `3BEAA` (voice copy, `begin_v_layer2`, per-slot LC stores, global `3C61C..3C61F`, talker alias `3BA70`, `rxvoice` `3BA60/3BA64` and `3BD48`, UI `0305E3F0`, PTT talk-back in `0305C334` → `0305C1E0`, home `T1/T2`, scanner busy, recording) and every writer of `3BEAB`, `3BA55`, `3BEAA/3BEAC` reachable by an other-slot burst — including a Capacity-Plus-style FID `0x10` follow branch in `030282A4` that rewrites all slot bytes. `3BEBD..3BECB` is in the boot-zeroed BSS (`0x2F0B4..0x4A7E0`) and has no access (inferred, register-tracking scan). Inferred design: first-come capture limited to BS-sourced voice bursts, other-slot Idle ends a captured call, a dispatcher wrapper keeps `3BEAB` stock, talk-back guard; ten sites with guard bytes in [MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) §3.8, owner questions there.

### CC Match off completeness (2026-10-14, fifth pass, design only)

code-verified: the readers of the configured CC `33CCD` are the four Monitor-idiom voice sites, the `3C626` counter, PI/data/CSBK handlers, TX admit `03027334` and the mode-4 TX loader — nothing else in flash, IRAM or the task entries (completeness inferred from two trackers and a `zext 7,4` census). Corrections: the data-sync gate is the only CC filter for Idle bursts, so a bypass there must be limited to data types 1/2; with `cc_opt = 1` foreign frames update `3C61A`/`3BEAB` and so TX admission, exactly like stock Monitor, unless a dispatcher wrapper restores them. Burst-F late-entry decryption (`03027628`) has no CC test; mode 2 is never set in this build. Site list C1–C7 in [MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) §3.9.

### Settings storage for new options (2026-10-14, fifth pass)

Manual vs. firmware menus: Voice Func matches item for item; Display/Other Func have firmware-only items (MOTO, Lone Worker, Man Down, four display items). code-verified: block 4 `0x60` is read only by `0304B010` (bits 0/1) and the read-modify-write of settings 9/10, `0x85` bit 4 and `3EA05` bit 6 (MOTO) only by their own menu, `3BA6D` bits 5–7 by nothing; boot path `0305F674` → `0304A45C` … `0300C904` → `0304B010`. New risk (unreviewed bound): `030610D8` writes an editor text of variable length to block 4 `0x50`. Details: [SETTINGS_CPS_ANALYSIS.md](SETTINGS_CPS_ANALYSIS.md) §9.

### Remaining internals (2026-10-14, fifth pass)

code-verified: `030562C4` loads the RX group list (channel `+0x0F`) to `33CF4..33D73`, the TX contact sits at `33D74` (labels in earlier docs were shifted by one entry, filter unchanged); channel `+0x08` bits 2:1 = TX power; `RTCITEM` sets the clock and restarts; `PCTESTM` is a factory test loop; the recording task `0302124C` takes caller IDs from the call descriptor `3BD48` and uses flash sectors `0x6DC..0xFFF`; privacy alg 1 = RC4 (KSA/PRGA structure), 4/5 = AES-128/256 key expansion, alg 2 key schedule is an empty function; the `Digit Monitor` softkey label is unreferenced. Details: [RX_CALL_PATH_ANALYSIS.md](RX_CALL_PATH_ANALYSIS.md) §15.

### Catalog hygiene (2026-10-14, fifth pass)

34 reviewed rows of `analysis/decompiled_modules/function_catalog.csv` updated (role, confidence, evidence; UTF-8 BOM and CRLF kept, other rows byte-identical, `tools/tests` 15/15 pass). Task entries and ISRs that Ghidra has no function for are listed in [DECOMPILED_MODULES.md](DECOMPILED_MODULES.md) instead of new rows.

### Sixth pass: register leads, data-flash areas, settings risks (2026-10-17)

Static only (stock `de7dbcbc…`, installed `156a4872…`, GZF `354f9324…`, datasheet `d60f652e…` re-checked; binutils 2.42,
Ghidra 12.1.4 + CSKY v0.2 + sinc fix 3, `tools/dm32`). No radio access, no image written.
- datasheet + code: `SYS_SOFT_RSTN` bits are self-releasing reset pulses (p. 54), resolving the bits 1:0 question;
  `030215C8` is the `PCTESTM`/test-scene baseband test configuration; `03023574` always selects AF receive mode
  (RX RF type is the constant 4), with a fixed sync threshold and `rf_recv_delay = 14000`; `LAYER2_SLOTON = 0x11`
  includes the repeater-chip receive-slot bit. Details: [HR_C7000_CROSSCHECK.md](HR_C7000_CROSSCHECK.md) §8.
- code-verified: data-flash area map (11 = contacts, 16 = per-channel privacy key list selected by channel `+0x0E`/
  `+0x0F` bit 6, 18 offset 0 = current channel, …); `3E335` is the channel reload reason passed to `03057790`, and the
  side-key `Alarm` sets reason 4, which forces TX power bits to 2; the Call Log writer was searched and not found.
  Details: [RX_CALL_PATH_ANALYSIS.md](RX_CALL_PATH_ANALYSIS.md) §16.
- code-verified: the block-4 `0x50` writer `030610D8` is unreachable (its only caller tests `r3 == 8` on paths where
  `r3` is 3 or ≥ 22), so it cannot overwrite `0x60`; `3EA06` bits 0/1/7 unused and bits 3:2 never written.
  Details: [SETTINGS_CPS_ANALYSIS.md](SETTINGS_CPS_ANALYSIS.md) §10.
- Docs: `CC_MATCH_DESIGN.md` is now a pointer page; its CSBK decode-flag finding moved to `DATA_PATH_ANALYSIS.md` §8a.
  The TS/CC Match candidate module, build and in-memory patch plan (work items 2–4 of `NEXT_AGENT_PROMPT.md`) were
  **not** produced in this pass; only the flag-storage header `firmware/source/match_flags.h` and the interface
  header `match_options.h` exist.

2026-10-17 GNSS input (static, same inputs/tools): code-verified UART ISR `0002CCE4` → task `gps` `03011A80` → 1 KiB
ring `386C0` → RMC/GGA parser `03012774` in the main loop (GP/BD/GN talkers, checksum, fix, lat/lon, speed, course,
satellites, altitude); GNSS power is GPIO `0x2C` (`03011914`); RMC time sets the RTC (`03012678`); the periodic
callback `0002CABC` also restarts the radio when a CPS session stays open for 800 slow ticks. 11 catalog rows updated.
Details: [GNSS_ANALYSIS.md](GNSS_ANALYSIS.md).

2026-10-17 alert tones (static): code-verified tone engine `03021C1C` → task `03022FB0` → `03022410`; Radio Silent lets
only the power-on melody `0x0F` and the looped sample sound `0x16` through; key/refusal beeps are dropped during a
received-call display; tone id table with callers. 5 catalog rows updated. Details: [AUDIO_TONES.md](AUDIO_TONES.md).

2026-10-17 roaming storage (static): data-flash area `0x65` holds the roaming zones (header, current zone, 0x21-byte
zone records) and `0x66` the roaming channels (0x1A-byte records), loaded at boot by `03066424`, which reformats them
with `Roam Zone 1`/`Roam Channel 1` defaults; `3E9D4+0x30` bit 6 selects English (1) vs Chinese (0). The roaming
decision logic is unreviewed. Details: [RX_CALL_PATH_ANALYSIS.md](RX_CALL_PATH_ANALYSIS.md) §16.1.

2026-10-17 roaming search (static): code-verified periodic trigger `03066824` (interval = zone header byte 2 × 60
ticks, skipped on Rx Only channels and while scanning) and search `03066608`; each candidate is tested by `0301FE28`,
which accepts it at once when the repeater downlink is already received and otherwise sends up to three repeater
wake-ups (`03029C3C`, a transmission) waiting 300 ms each for the downlink event. Details:
[RX_CALL_PATH_ANALYSIS.md](RX_CALL_PATH_ANALYSIS.md) §17.

2026-10-17 correction: the Call Log **is** stored in data flash. The UI task `0302DF18` logs calls with `03058B34(kind)`
into areas `0x0C`/`0x0D`/`0x0E` (area id from the table `030B24F0`, missed by the constant search), 20 × 14-byte records
(ID, RTC time, duration) per kind; mapping of kinds to Missed/Answered/Sent inferred. Supersedes "searched, not found"
earlier today. Details: [RX_CALL_PATH_ANALYSIS.md](RX_CALL_PATH_ANALYSIS.md) §16.3.

2026-10-17 alarm / Man Down (static): the Other Func Man Down setting (block 4 `0xA4` bit 3, `3EA05` bit 7) is only
read by its toggle (side-key `ManDown`), boot load and menus — no sensor logic found (inferred). The `Man down alarm!`
screen is alarm stage 8, reached when the channel's emergency system has alarm type 5 when an alarm (user-started or received) reaches stage 2/3.
Details: [ALARM_ANALYSIS.md](ALARM_ANALYSIS.md).

2026-10-17 Lone Worker (static): configuration in data-flash area `0x10` offset `0xB00` (enable, response time,
reminder, mode), per-channel flag = channel record `+0x08` bit 0 (toggled and stored by side-key `Work Alone`
`03015FD4`); the timer `030654F8` counts inactivity, plays a reminder tone and on expiry calls the same alarm entry as
the side-key `Alarm`, i.e. it can start an emergency alarm transmission without a key press (code-verified call;
TX inferred from the alarm path). Details: [ALARM_ANALYSIS.md](ALARM_ANALYSIS.md) §3.

2026-10-17 summary of every stock path that can transmit without PTT (CSBK/data replies, roaming wake-ups, Lone Worker alarm, alarm): [AUTONOMOUS_TX.md](AUTONOMOUS_TX.md).

2026-10-17 VOX (static): `030624C0` compares ADC channel 1 (`0301CA8C`, MMIO `0x140D0000`) with a 9-level threshold table and synthesizes PTT press/release events (`03014DD8(4/8)`), release after VOX Delay (`3EA33`). Added to [AUTONOMOUS_TX.md](AUTONOMOUS_TX.md) §1.

2026-10-17 GPS/APRS beacon (static): `03062D80` (periodic handler `0305490C`) sends the position via `03062CD4` → `03062A54` every block-4 `0x301` × 30 ticks when a fix is valid (or the `0x302` option), not on Rx Only channels; side key `APRS Send` sends once. Details: [GNSS_ANALYSIS.md](GNSS_ANALYSIS.md) §3b; added to [AUTONOMOUS_TX.md](AUTONOMOUS_TX.md).
