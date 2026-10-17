# Subsystem tags for unreviewed functions — DM32.NRF.01.049 (2026-10-17)

Static only. Inputs: stock `stock_progmem_1MiB.bin` (`de7dbcbc…`, verified on load), the function catalog after the
library pass ([LIBRARY_SIGNATURES.md](LIBRARY_SIGNATURES.md) §6–§9), GNU binutils 2.42 for C-SKY, Python 3.13. No radio
access, no image written; this work changes no firmware and needs no hardware test.

```sh
source /opt/dm32-tools.env
python3 tools/dm32 tag                                   # counts per tag
python3 tools/dm32 tag 0302225C                          # evidence for one function
python3 tools/dm32 tag --csv analysis/decompiled_modules/subsystem_tags.csv --write-catalog
```

A tag is a **navigation lead, not a name**: tagged rows keep `confidence = unreviewed` and their `FUN_…` name; only
the `subsystem` column becomes `auto: <tag>`. Every tag must be read as "inferred".

## 1. Evidence (`tools/dm32re/tag.py`)

| Signal | Weight | Notes |
|---|---:|---|
| Task reachability | 3.0 (1.5 for the keys tasks and startup) | Forward reachability from 37 roots (`TASKS`: every `OSTaskCreate` entry of §6 of LIBRARY_SIGNATURES.md, the main-loop step `03013940` separated from the startup calls of the main task `03068E54`, ISRs `0002C458`/`0002CCE4`, the periodic callback `0002CABC`). Edges: `bsr`, `jsri`, tail calls, `lrw` of a catalog start (function pointer) and `lrw` of a table of ≥ 2 consecutive catalog starts (handler tables, also in initialised SRAM). Other task entries are not crossed; reviewed library rows (RTOS, C runtime, uC/LIB) are not expanded. Reach from one task subsystem only votes; reach from several makes the function `shared` unless other evidence decides (score ≥ 3.0, margin ≥ 1.0) |
| Strings | 1.5 each, cap 3.0 | Keyword table `STRINGS` on loaded C strings (`$G`/`KM/H` → GNSS, `Scan`, `Zone/Channel/VFO`, `ALARM`, `NOAA/Seek`, `PTT ID/WLT CMD`, time formats, …). Only 103 unreviewed functions load strings directly (menu texts are reached through tables) |
| Memory-mapped I/O | 1.0–3.0 per base | Table below |
| RAM owners | 1.5 per region, cap 3.0 | `RAM` table: channel DMR block `33CC8`, event groups `3658C`/`38330`/`3835C`, GNSS ring/line/fix `386C0`/`38B28`/`38C88`, DMR flags `3BA54`, call descriptor `3BD48`, baseband copies `3BEA0`, per-slot RX `3C61C`, scan state `3E160`, channel copy `3E1F8`, settings `3E9D4…3EA40`, alarm stage `3FD4C` (owners from the analysis notes) |
| Reviewed callees / callers | 1.0 / 0.75 each, caps 3.0 / 2.25 | Catalog subsystem of reviewed rows, canonicalised (`CANON`, e.g. `Digital RX/DMR CSBK` → `Digital RX/DMR`); library and unclassified subsystems do not vote |
| Propagated tags | 0.75 each, cap 2.25 per direction | Decided tags of callees and callers from the previous pass, 3 passes |
| Neighbourhood | 0.5 per side | Reviewed or decided tag of the previous and next catalog function (tie-breaker; one source file is usually contiguous) |

Scores add per tag. **Threshold:** a tag is written to the catalog when its score is ≥ 3.0 and ahead of the second tag
by ≥ 1.0 (`THRESHOLD`, `MARGIN`), or when the function is reached from several tasks that all belong to one family
(`shared (UI tasks)`, `shared (DMR tasks)`, `shared (audio tasks)`, `shared (RF tasks)`; `FAMILY`). `shared` across
families and `none` (no evidence: not reached, no strings/I/O/RAM/reviewed neighbours) are never written.

**MMIO bases (evidence):**

| Base | Tag | Weight | Evidence |
|---|---|---:|---|
| `0x11000000` | Baseband registers | 3.0 | HR_C7000 register map (HR_C7000_CROSSCHECK.md); 78 functions |
| `0x140D0000` | ADC | 3.0 | SAR ADC reader `0301CA8C` (catalog high) |
| `0x14040000` | GNSS/NMEA | 3.0 | GNSS UART ISR `0002CCE4` (GNSS_ANALYSIS.md §1) |
| `0x14000000` | Hardware timers | 2.0 | timer 0 = OS tick (`0306D6C0`, LIBRARY_SIGNATURES.md §6) |
| `0x17000000` | Interrupt controller | 2.0 | `0306D794`/`0306D73C`, interrupt entry `0001064A` |
| `0x16000000` | Audio | 2.0 | byte registers `160009xx`, catalog row `0301E558` (Audio) |
| `0x14020000`, `0x14100000`, `0x14110000` | GPIO | 1.0 | identical register layout (+0/+4/+30…+3C/+48/+50/+78); `0x14020000` carries the RF 3-wire bit-bang (`0002C2F8`/`0002C340`); inferred GPIO ports |
| `0x14030000` | UART (second) | 1.0 | same register layout as the GNSS UART (+0/+4/+8/+C/+14); inferred |
| `0x12000000`, `0x14080000`, `0x140A0000`, `0x140F0000`, `0x14150000` | — | — | not identified; recorded in no tag (2026-10-17 hub pass: `0x12000000` = LCD bus, `0x140A0000`/`0x14150000` = SPI ports 0/3; [HUB_FUNCTIONS.md](HUB_FUNCTIONS.md) §2.3, §3.1; the tagger itself is unchanged) |

New tag names (not in the catalog before): `Main loop` (reached only from `03013940`), `Startup/init`, `Baseband
registers`, `Periodic (ScanDisp)`, `Periodic (IRAM callback)`, `Channel knob (CodeSw)` (task `CodeSw` calls the
channel apply `03031FD4`; "code switch" read as the channel knob, inferred), `RF (cds task)` (task `cds` uses the
RF transceiver registers), `UI/call display` (task `CallDisp`), `Timers (TmrHnd)`, `LED`, `Power/shutdown`,
`Hardware timers`, `Interrupt controller`, `GPIO`, `UART (second)`, `Contacts/calls`, `FM radio/NOAA`,
`UI/clock/time`, `Power/battery`, and the `shared (…)` marks.

## 2. Result (2026-10-17)

1669 unreviewed rows tagged; **898 written** to the catalog as `auto: <tag>` (`analysis/decompiled_modules/
subsystem_tags.csv` holds all 1669 with score, margin, tasks and reasons). IRAM: 361 rows, 235 written; application
flash: 1308 rows, 663 written.

| Tag | Rows | Written |
|---|---:|---:|
| shared | 248 | 0 |
| shared (UI tasks) | 240 | 240 |
| Audio/vocoder | 182 | 173 |
| Menu/input | 160 | 78 |
| none | 114 | 0 |
| Startup/init | 87 | 0 |
| Baseband registers | 69 | 54 |
| Codeplug/channels | 61 | 24 |
| Main loop | 58 | 57 |
| CPS/USB | 52 | 43 |
| UI/call display | 46 | 39 |
| Settings | 45 | 2 |
| Keys/PTT | 40 | 0 |
| Scanning | 36 | 14 |
| shared (DMR tasks) | 33 | 33 |
| UI/status | 29 | 28 |
| GNSS/NMEA | 17 | 9 |
| Recording/privacy | 17 | 14 |
| Audio/tones | 15 | 15 |
| Digital RX/DMR | 15 | 14 |
| Digital TX/DMR | 12 | 12 |
| RF/squelch | 11 | 10 |
| Periodic (ScanDisp) | 9 | 9 |
| GPIO | 8 | 0 |
| Storage | 8 | 0 |
| Digital RX/DMR settings | 6 | 0 |
| RF (cds task) | 6 | 6 |
| Audio | 4 | 2 |
| Channel knob (CodeSw) | 4 | 4 |
| Emergency alarm | 4 | 2 |
| UI/clock/time | 4 | 2 |
| Contacts/calls | 3 | 0 |
| Digital TX/DMR data | 3 | 3 |
| RF | 3 | 2 |
| ADC | 2 | 0 |
| FM radio/NOAA | 2 | 2 |
| LED | 2 | 2 |
| Remote control/stun | 2 | 1 |
| Roaming | 2 | 0 |
| UI | 2 | 0 |
| Core/system | 1 | 0 |
| Hardware timers | 1 | 0 |
| Periodic (IRAM callback) | 1 | 1 |
| Power/battery | 1 | 0 |
| Power/shutdown | 1 | 1 |
| Tasks | 1 | 1 |
| Timers (TmrHnd) | 1 | 1 |
| UI/messages | 1 | 0 |

## 3. Spot check (by hand, `tools/dm32 fn/callers/callees`)

Two random samples stratified by tag (Python `random`, seeds 20261017 and 4242), each function read for callers, callees,
strings, RAM and I/O accesses and judged against the tag. `shared` marks are excluded (they are true by construction).

- **Round 1** (first configuration, 36 decided tags): 28 agree (78 %). Wrong: three `Keys/PTT` rows that are menu
  helpers (the keys task dispatches menu scenes, so its reach is not specific), two `Startup/init` rows that are the
  init functions of the keys and audio subsystems, `0305FD34` (`Main loop`; empty stub called by the NMEA parser),
  `00015EA0` (`UI/status`; vocoder IRAM code reached through `030219E8`), `03054B44` (`GNSS/NMEA`; power-mode switch
  that also reconfigures the GNSS UART).
- **Signal change:** the keys-task and startup reach now vote 1.5 instead of 3.0, so they no longer decide alone
  (`WEAK_VOTE`); the five rows above drop below the threshold.
- **Round 2** (final configuration, fresh sample of 44 decided tags, at least one per tag): 40 agree (91 %). Wrong:
  `0300FA28` (`Codeplug/channels`; generic data-flash read with a critical section, better `Storage`), `03029D3C`
  (`Digital RX/DMR`; builds outgoing preamble CSBKs, TX), `030309B8` (`FM radio/NOAA`; home display that prints the
  NOAA label), `0302FC84` (`Main loop`; FM seek display).
- **Final configuration on both samples:** 67 of 74 decided tags agree (**90.5 %**); round-1 rows re-judged under the
  final rules: 27 of 30 still written agree.

Weak spots: `Main loop` and `UI/status` include library code reached through UI helpers; `Codeplug/channels` and
`GNSS/NMEA` attract shared storage and power code through RAM evidence; DMR RX/TX is not separated when both paths
reach a helper. Pinned in `TagStock` (`tools/tests`).

## 4. Open questions for the owner

- None blocking. The task names `CodeSw` and `cds` are vendor abbreviations; "channel knob" and "RF" are readings of
  their code, not confirmed meanings.

## 5. Left unreviewed

All 1669 tagged rows remain `unreviewed`; 248 `shared` rows across task families and 114 rows without evidence
(`none`, mostly code reached only through untracked pointers) carry no tag. The unidentified MMIO bases above and
the six IRAM rows `00014164…000141C8` after the kernel (two `Audio/vocoder`, one `Baseband registers`, three below
the threshold) are leads for later reviews. No hardware test is
needed for this work.

## 6. Tag check from the targeted TX review (2026-10-17, `TX_PATHS.md`)

36 of the 65 rows reviewed for T1 carried an `auto:` tag; the 12 `shared (…)` rows are true by construction and are not
counted. Of the 24 decided tags, **5 agree** with the reviewed subsystem (`0002B440`, `0002B4A0` RF; `0300C304`
Baseband registers — it is the `FM_PTT` register; `030130F0` Main loop; `0305BE0C` Audio) and **19 disagree**:

| Auto tag | Reviewed | Rows | Cause |
|---|---|---|---|
| `Digital RX/DMR` | `Digital TX/DMR` | `0300D0A4`, `0300D284`, `0301EAE8`, `03020DC8`, `03020FBC`, `03020FE4`, `03029D3C` | reached from `CclTraffic`/`rxvoice`, which the tagger files as RX tasks; RX and TX are not separated (known weak spot, §3) |
| `Main loop` | `Analog TX/signalling` | `0306461C`, `03064830`, `03064DBC`, `03067A5C`, `03068B4C`, `03068C1C`, `03068D04` | reach is correct (main-loop step), the subsystem is the analog signalling decoder/responder |
| `Menu/input` | `Analog TX/signalling` / `TX/PTT` | `03059904`, `03065934` | called from menu scenes |
| `Audio`, `Audio/tones` | `Analog TX/signalling` | `030601CC`, `03061648` | tone generation on the transmitter |
| `Scanning` | `Emergency alarm` | `0305E134` | stops the scanner first |

So the tags are a weak lead for transmit code: on TX paths only 5 of 24 (21 %) agree, against 90.5 % in the random
spot check. The tagger is unchanged; the reviewed rows now carry their own subsystem.

T3 rows (`MATCH_OPTIONS_DESIGN.md` §3.10): of 5 decided `auto:` tags, 4 agree (`Baseband registers`: `0300C0E4`,
`0300C0E8`, `03023880`, `030239C4`) and 1 disagrees (`0300C4BC`, tagged `Digital TX/DMR`, is a millisecond-delay
wrapper of `OSTimeDly`); 3 `shared (DMR tasks)` rows were not counted.

## 7. Tag check from the hub pass (2026-10-17, `HUB_FUNCTIONS.md`)

116 rows were reviewed for H1/H2; 53 carried an `auto:` tag, 28 of them `shared (UI tasks)` (true by construction, not
counted). Of the 25 decided tags **10 agree** (40 %) and **15 disagree**:

| Auto tag | Reviewed | Rows | Agree | Cause of the disagreements |
|---|---|---|---:|---|
| `Menu/input` (16) | Menu/UI framework, Text input editor | `03035E68`, `03036BB0`, `0304A1E8`, `03049498`, `03059A64`, `0305AE28`, `03059F08` | 7 | — |
| `Menu/input` | Display (drawing/fonts/UI widgets) | `03017BE8`, `03018AF4`, `03019BD4`, `03019B80`, `0301AB40`, `0303A4F4`, `0303A4AC` | 0 | no display tag exists; drawing code called from menu scenes |
| `Menu/input` | Codeplug/channels | `03030560`, `0002DED4` | 0 | called from menu/side-key handlers |
| `Codeplug/channels` (4) | Codeplug/channels | `03030370`, `0305660C` | 2 | — |
| `Codeplug/channels` | Storage (data flash), Roaming | `0300FA28`, `03066884` | 0 | RAM evidence (known weak spot, §3) |
| `Audio/vocoder` (1) | Audio/vocoder | `00018EF4` | 1 | — |
| `Audio/tones`, `Main loop`, `Recording/privacy`, `Baseband registers` (1 each) | Storage, GPIO, Utility, Display (LCD driver) | `0002BA14`, `0301D0DC`, `0002F088`, `03017CE4` | 0 | shared low-level helpers; `03017CE4` clears bits of `0x1100003C` and so scored `Baseband registers` |

So for low-level hubs the tag is a weak lead; the LCD base `0x12000000` and the SPI bases are now identified but the
tagger (`tools/dm32re/tag.py`) was not changed in this pass. The reviewed rows carry their own subsystem.
