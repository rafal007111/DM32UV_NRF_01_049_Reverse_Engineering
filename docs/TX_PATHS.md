# Transmit paths — which code can key the transmitter, and when (DM32.NRF.01.049)

Static analysis, 2026-10-17 (targeted review T1). No serial port was opened, no radio was accessed and no image
file was written. Nothing in this file is hardware-verified.

| Item | Value |
|---|---|
| Stock image | `analysis/inputs/stock_progmem_1MiB.bin`, SHA-256 `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0` (checked) |
| Installed image | `analysis/inputs/current_scan_tick_fix.progmem.bin`, `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53` (checked; every site below is stock code outside the Scan Zone patch) |
| GZF | `analysis/archives/DM32_NRF_049_correct_base.gzf`, `354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d` (checked) |
| Datasheet | `docs/HR_C7000 Document 2.pdf`, `d60f652e…` (checked), text via `pdftotext -layout` (poppler) |
| Tools | GNU binutils 2.42 `csky-elfabiv2`, Ghidra 12.1.4 + CSKY v0.2 + sinc fix 3 (`tools/dm32 decomp`), `tools/dm32 fn/callers/acc/refs` |

Labels: **datasheet + code** (register documented, access read at instruction level), **code-verified**
(instructions, literal pools and call sites read), **inferred** (reasoning beyond what the code shows, including every
absence claim), **unreviewed**. RF-transceiver register meanings follow the Beken BK4819 map as used by open UV-K5
firmware (design reference only, no code taken) and are therefore **inferred**.

**Method.** (1) Every sink below was located by register (`tools/dm32 acc` on `0x11000560`, RF register 0x30 writes by
a constant scan of all `0002C2F8(reg, val)` calls) or by function. (2) A backward call graph was built from the
`tools/dm32 tag` edge set — `bsr`, `jsri`, tail calls, `lrw` of a catalog start (function pointer) and `lrw` of a table
of ≥ 2 catalog starts (handler tables, also their SRAM copies) — and walked from each sink to the 37 task/ISR roots of
`SUBSYSTEM_TAGS.md` §1 (153 functions above the TX queue alone). (3) Because the transmit path is split by RTOS events
(PTT → `keyTime` → `keys` → `CclTraffic`), every post to the relevant event groups (`3A50C`, `36F4C`, `385AC`) was listed
with a constant back-tracker over all `0300C494`/`0300C53C` call sites. (4) Every function named in the tables below was
read in the disassembly and the decompiler output (literal pools resolved to their RAM targets). An absence statement
("no Rx Only test") is **inferred** with this method: it covers direct and indirect calls and handler tables, not
values passed through untracked pointers.

## 1. Sinks — the code that actually keys the transmitter

| # | Sink | Kind | Evidence | Label |
|---|---|---|---|---|
| S1 | `0300C304(on)` → `0x11000560` | HR_C7000 **`FM_PTT`** bit 0 "FM transmit PTT, active high" (datasheet §11.2.2.25, p. 338) | only writer besides IRAM save/restore `000169D8`/`00016AD0`; callers `0305BE64`, `030601CC`, `03059904`, `03061648`, `03068A88`, `03068D04`, `03055600`, `030215C8` (PCTESTM), `0301EAE8` (off) | datasheet + code |
| S2 | RF register 0x30 = `0xC1FE` (`0002B5B8`) or `0xC3FA` (`0300E8EC`, `03068494`) after `0x30 = 0` | RF transceiver transmit-link enable (0x37 = `0x1D0F`, 0x52 = `0x028F` set first); RX enable is `0xBFF1` (`0002B5E4`, `03054DC8`); 0x30 = `0x0302` (`03068B4C`/`03068C1C`) is local tone playback | constant scan of all `0002C2F8` calls (`rfregs` list in this pass) | code-verified writes; meaning inferred (BK4819 map) |
| S3 | `0002C83C(on)` | PA enable: GPIO 35 or 55 high by band (`3E337` bit 4), both low for off | callers: `0002B440` (digital TX on), `0300E40C` (analog TX on), `0002B4A0`/`030601CC`/`03068A88`/`03068D04`/`03055600` (off), CPS/PCTESTM paths | code-verified GPIO writes; "PA" inferred |
| S4 | `0002B364(1, 1, power)` → `0002C3B8` | power-control ramp (interpolated table, serial DAC channel 2); `power` = `3848C+0x28` from channel `+0x08` bits 2:1 via `0300DB48` | callers `0002B440`, `0300E40C`, `0002B4A0` (ramp down), PCTESTM | code-verified; "APC" inferred |
| S5 | `0002B440` / `0002B4A0` | **digital RF transmit on/off**: LNA off, settle 800–1200 delay by power, TX frequency (`0002B678`), S2, S3, S4, `3E1DC` bit 0 | only caller: task `rf` `0300DC94`, which pends on semaphore `385AC` and switches on `38480` = 1 / `38481` = 2 for digital channels (`3E200` nibble 1) | code-verified |
| S6 | ISRs `0002C404` (vector 64) / `0002C3D8` (vector 65) | HR_C7000 **`RF_TX_INTERP`** / **`RF_RX_INTERP`** ("RF switch interrupt, RF transmit/receive start", interrupt table p. 92; cleared through `INTERP_CLEAR` bits 2/3, p. 105): set `38480`/`38481`, post `385AC` — unless `3FDD8` bit 1 (PCTESTM test mode) | registered by `0301D080` (`0306D73C(handler, 64/65)`) | datasheet + code |
| S7 | TX queue `030294C8` → IRAM `0002D7C8` (task `txslot`) | every digital burst (voice LC headers, voice, terminators, CSBKs, data) is queued and loaded per 30 ms slot; loading sets `LAYER2_TXRX_CTRL.txnextsloten` (`HR_C7000_CROSSCHECK.md` §1), which makes the chip raise S6 | `RX_CALL_PATH_ANALYSIS.md` §4 | datasheet + code |
| S8 | `03023290(mode, 2)` → `030231C0` | `LAYER2_CONTROL` TX enable / TX slot establishment before a digital transmission | callers `0301DF8C` (admit), `0301FE28` (roaming) | datasheet + code (existing rows, medium) |
| S9 | `03029C78` | CSBK written directly to `0x11000418` without the queue | only armed by `3C7A4`, which nothing writes (`RX_CALL_PATH_ANALYSIS.md` §13) | code-verified; **dormant** (inferred) |

So: **digital** TX = something queued in S7 → chip interrupt S6 → task `rf` → S5 (S2+S3+S4). **Analog** TX = S1 plus
`0300E40C` (S2+S3+S4, CTCSS/DCS encoder `0300E10C`, deviation register 0x40 `0300DE60`) or the tone senders below,
which call S1/S2/S3 themselves.

## 2. Request funnel (code-verified)

```
PTT key (handler table 03072780 / SRAM 18000838)       side keys 30 TBST Send (03015A7C), 38 Sub PTT (03015AC8)
   03014E38 press / 03014DEC release                     VOX 030624C0 (main loop)
        \______________________ 03014DD8(4 | 8): key-event block 307B8, event 2 on 3FDB0 ___/
                                   |
                     task keyTime 030151D0: bit 2 → 03014C38 → event 8 on 3A50C
                                     bit 3 → 03014F54 (analog EOT signalling) → event 0x10 on 3A50C
                                   |                         TOT 03055A70 → event 0x10 on 3A50C
                     task keys 03012D2C: event 8 → 0305C334 (PTT handler, gates §3)
                                         event 0x10 → 0305BE18 → 0301EAE8(1) (TX end)
                                   |
             0305C1E0(type, id): digital → 0301EAC8(0..3, id); analog → 0305BE64 (analog TX on) + 0301EAC8(10)
                                   |
   other requesters of 0301EAC8: alarm 0305DD38 (9), 0305E030 (2), CSBK Remote Monitor 0305EB8C (1),
   Hot Key 0306574C / menu 03065934 (4..8), menu call screens 0304EE0C/030507BC/0305182C
                                   |
        0301EAC8 stores type/ID in 3BAB8 and posts event 1 on 36F4C (0300C7C0)
                                   |
        task CclTraffic 0301E924, table 030AEB34[type]:
            0,1 private voice → 03020FE4(0) ; 2,3 group/all voice → 03020FE4(1)
            4..9 CSBK command → 03020DC8(5,6,2,1,3,4) (codes 1..6 in 3BD5B)        10 analog → 3BA59 = 4 only
                                   |
        03020FE4 / 03020DC8 → TX admit 0301DF8C (repeater wake-up 03029C3C, slot lock, policies)
                            → 03029674 (voice) / 03029D08 (UU_V_Req) / 03029D3C (CSBK) → TX queue 030294C8
```

Independent producers of queue entries (no `CclTraffic` request): received-traffic replies in `rxcsbk` `030209E4`,
`rxvoice` `030206D0` and `rxmsg` `0301FF9C` (`DATA_PATH_ANALYSIS.md` §6), SMS/data sends of task `txmsg` `0301FDD8`
(`0301F118`), the roaming test `0301FE28` (`03029C3C` directly), the main-loop retry step `0300D284` (below) and the
dormant `cpchanscan` `03023B3C` (created only for RX mode 2, which this build never selects — `MATCH_OPTIONS_DESIGN.md`
§3.9, inferred).

## 3. Roots, triggers and gates

Gate names: **Rx Only** = channel `+0x08` bit 3 (`3E200` bit 3 / `3BA6C` bit 1); **CPS** = session flag `3FDD8` bit 6;
**test** = PCTESTM flag `3FDD8` bit 1; **stun** = `3FD4C` bit 1 (`0305DF8C`); **voltage** = `3E33B` bit 6 `High
Voltage!` / bit 5 `Low Voltage!`; **band** = `3E337` bit 5 `Tx Limit!`; **TOT** = `03055A70` (`AUTONOMOUS_TX.md` §3).

| Root (task / trigger) | Path to the sink | Gates found (addresses) | Label |
|---|---|---|---|
| **PTT key** (`keys`/`keyTime` tasks) | §2 | `03014E38`: not already transmitting (`3FDEC` bit 3), not in RX call display `3FDEC` bit 1 unless Remote Monitor, `030149E8(0)`, `3FDD8` bit 4; `030149E8`: CPS, `3FDDB` bit 1, stun, voltage, alarm-state rules; `03014C38`: test; `0305C334`: voltage (`0305C342`), Rx Only and `3FDDC` bit 6 (`0305C5A2`, prompt `Rx Only`/table `030BB218`), band (`3E337` bit 5 at `0305C650`, `Tx Limit!`), **analog busy lock**: channel `+0x0A` bits 6:4 = 1 refuses while carrier `3FDD8` bit 5, = 2/3 by tone match `3FE25` bit 1 (`0305C6D0…0305C758`); digital admit `0301DF8C` (`MATCH_OPTIONS_DESIGN.md` §3.6); TOT | code-verified |
| **VOX** (main loop, `030624C0`) | `03014DD8(4/8)` → as PTT | VOX on, idle (`AUTONOMOUS_TX.md` §1) **plus every PTT gate** (same handler `0305C334`) | code-verified |
| **TBST Send** (side key 30, `03015A7C`) | sets `3E344` bit 4, `03014DD8(4)` → `0305BE64` tone branch: RF 0x70 = `0xC000`, tone `030B8320[(3EA41 >> 3) & 3]`, S1 | `030140E4(0x1C)`, not while scanning (`0302E0CC`), analog only (tone `0x21` on digital), `030149E8`, then the PTT gates | code-verified; key-initiated |
| **Sub PTT** (side key 38, `03015AC8`) | sets `3FDDD` bit 0, `03014DD8(4)` | Dual Watch on (`3EA40`), `030149E8`, PTT gates | code-verified |
| **Analog BOT/EOT signalling** (inside PTT) | `0305BE64` at TX start: channel `+0x16` bits 3:1 = 2 → DTMF ID `0306160C(0)` → task `sound` `03061648`; = 8 → FSK ID `03068494(0x180)`; = 6 → 5-tone `03065114(1)`. `03014F54` at release: same systems with the EOT entries, then event `0x10` | only during a PTT transmission | code-verified; system names inferred (DTMF from the digit table `0x30..0x44` → 0..15, FSK from RF registers 0x58–0x5F) |
| **Roger beep** (inside PTT) | `030601CC` (analog TX end): `3EA18` (Voice Func `Ana Roger`) bits 3:2 = 1 → two tones 1000/735 (`0300DF5C`) on the TX link, = 2 → FSK `03068494(0x100)` | only at the end of a transmission | code-verified; key-initiated |
| **DTMF keypad / manual DTMF** (menu scenes) | `03059904` (one digit per key, TX link + S1), `03061648` mode 2 (string `3FF60`) | menu scene must be open; no Rx Only test found in `03059904` (inferred) | code-verified; key-initiated |
| **Signalling calls** (Hot Key 1–5, menu) | `0306574C(param)` / `03065934`: analog type 1 → `03065718(n)` → block 4 `(n + 0x8F)·2` → `03068A88` (DTMF `030644B8` / 2-tone `03065290` / 5-tone `03067764`, S1 + S2 + S3); digital types 4–8 → CSBK requests `0301EAC8(4..8)`; type 3 → SMS `0305CD20` | `0306574C`: Rx Only (`0306583C`, digital commands); `03068A88`: voltage; `03065934`: channel type only — **no Rx Only test found** (inferred) | code-verified |
| **Analog selective-call decode → automatic acknowledgement** (main loop `03013940`, **new**) | on an analog channel (`3E200` nibble 0) with signalling system `+0x16` bits 3:1 = 2 (DTMF: `0306461C`, `03064830`), 6 (5-tone: `03064DBC`, list area 3 `0x750..0x7D0`) or 4 (2-tone: `03067A5C`): a matching code sets `4025C[3]` (response) and, for response type 2, `4025C` bit 4 with the delay `40278[4]`. `03068D04` (main-loop step, `030130F0`) then sets `3E34A` bit 5 and transmits the acknowledgement tones (`03068B4C` 333/625/833 Hz or `03068C1C` 800 Hz) with S1 + S2 + S3; response type 1 plays the same tones locally (RF 0x30 = `0x0302`) | decoding is skipped while `3FDDB` bit 1 is set (`030139C2`); the local response in `030130F0` waits while transmitting (`3FDEC` bit 3); `03068D04` waits for its countdown `40278[5]` and `3E336` bit 4; **no Rx Only, stun or CPS test in `03068D04`/`03068B4C`/`03068C1C`** (inferred) | code-verified flow; tone/system names inferred |
| **Analog stun / kill / revive by code** (same decoders, **new**) | `03064830` / `03064DBC`: decoded function 2 → `0305DFA4(0xA6)` (stun), 4 → `0xA5` (kill), 1/3 → `0xA0` (revive) — the persistent block-4 `0xF00` marker of `DATA_PATH_ANALYSIS.md` §4.4 — then restart `0305F2F4` or acknowledgement + restart | analog channel with the matching system; no Rx Only test | code-verified writes; "stun/kill" from the marker readers |
| **Received digital traffic** (`rxcsbk`, `rxvoice`, `rxmsg`) | `03029878`/`03026518`/`03026A14`/`030297A4` → queue | `DATA_PATH_ANALYSIS.md` §4–§6, §8a (Rx Only blocks Radio Check / Call Alert / Remote Monitor / Disable / Enable ACKs in `rxcsbk`); no Rx Only test inside `03026518` (link ACK builder; caller `rxmsg` not re-checked, unreviewed) | code-verified (earlier docs) |
| **Remote Monitor** (CSBK `0x10/0x1D`) | `rxcsbk` ACK → `0305EB8C` → `0301EAC8(1, requester)` → private voice call | decode flag block 4 `0x65` bit 7; not on Rx Only (`rxcsbk`); Remote Monitor length `3FD78` | code-verified (`DATA_PATH_ANALYSIS.md` §4.4) |
| **Emergency alarm** (side key `Alarm`, Lone Worker) | `0305E134` → `0305DD38`: alarm type `3FD4C+0x32` 1 = local only; otherwise channel reload reason 4 (power 2) and `0301EAC8(9)` → `03020DC8(4)` = CSBK code 6, **queued even when TX admit refuses** (refusal branch at `03020E74`); repeated by `0300D284` every `0x76` main-loop steps up to `3BA54+0x17` times; alarm stage step `0305E030` then starts a group voice call `0301EAC8(2, 3FD4C+0x28)` and ends it with `0301EAE8(1)` | `0305E134`: not on RX-only frequencies (`3E337` bit 6), not during a type-4 call display with alarm state 1, `030140E4(7)` permission callbacks (table `*18000804`, unreviewed); **no Rx Only test found** in `0305E134`, `0305DD38`, `03020DC8`, `0301DF8C` (inferred) | code-verified |
| **Retries** (main loop, `0300D284`, **new**) | private-call setup `03029D08` (UU_V_Req) repeated every `33CC8[0x22]·6 + 0x2D` steps up to `33CC8[0x16]` times while `3BA43` bit 0 and `3BA59 == 5`; CSBK commands `03029D3C` repeated while `3BD58` bit 6 | only after a user/alarm request started them | code-verified |
| **Roaming search** (`ScanDisp`) | `03066608` → `0301FE28` → `03029C3C` (CSBK opcode `0x38`, repeater wake-up) + `03023290(1, 2)` — bypasses `0301DF8C` | Rx Only and scanning (`03066824`), `3BA6D` bit 0, `3FDD8` bit 2 (`RX_CALL_PATH_ANALYSIS.md` §17) | code-verified |
| **GPS/APRS beacon** (`ScanDisp`), `WLT CMD` reply | `03062D80` → `03062A54` → `0305CD88` → `0305D200` → `txmsg` | Rx Only checked in `03062D80` (`03062DC2`) and `0305D200` (`0305D23A`) | code-verified |
| **Lone Worker** (`ScanDisp`, `030654F8`) | `03016EAC(3)` → alarm row | as alarm | code-verified (`ALARM_ANALYSIS.md` §3) |
| **RF sweep test** (`ScanDisp`, `03055600`, **new**) | steps RX/TX frequency by 5 MHz every 16 ticks and toggles S1 + `0300E40C` | only when `3FDD8` bit 1 (PCTESTM test mode) and `32AD0 == 18` (`0305499C`) — reachable only after the `PCTESTM` USB word | code-verified; "factory sweep" inferred |
| **PCTESTM** (task `usb`, `0302AA58`/`030215C8`) | direct S1/S3/S4 writes | only after the `PCTESTM` USB handshake (`SETTINGS_CPS_ANALYSIS.md` §3.1) | code-verified entry; sub-commands unreviewed |

## 4. Corrections and additions to `AUTONOMOUS_TX.md`

| Row | Change |
|---|---|
| (new) Analog selective-call decode | **Added**: a received DTMF / 2-tone / 5-tone code that matches a decode entry with response type 2 makes the radio transmit acknowledgement tones by itself (`03068D04`), on analog channels with that signalling system; no Rx Only test was found on this path |
| (new) Analog stun/kill/revive by code | **Added**: the same decoders write the persistent stun (`0xA6`) / kill (`0xA5`) / revive (`0xA0`) marker and restart the radio |
| Alarm in progress | **Corrected**: the alarm CSBK is queued even when the TX admit policy refuses (`03020DC8`, request type 9) and is repeated by `0300D284`; no Rx Only test was found on the alarm path |
| VOX | confirmed; additionally subject to every PTT gate of `0305C334` (Rx Only, voltage, TX band, analog busy lock) |
| TBST, DTMF PTT-ID, roger beep | confirmed **key-initiated**: TBST from side key 30 through the PTT handler, DTMF/FSK/5-tone IDs and the roger beep only at the start/end of a PTT transmission, DTMF keypad only in a menu scene |
| CTCSS/DCS tail | still unreviewed (`0300DD94` at TX end is the candidate); it only extends a PTT transmission |
| RF sweep test | added as not reachable without the `PCTESTM` USB word |
| Safe test practice | adds: on analog channels set the signalling system (`+0x16` bits 3:1) to none or disable decode responses, and do not send DTMF/2-tone/5-tone codes to the radio |

## 5. TS/CC Match design and the TX paths

The design sites of `MATCH_OPTIONS_DESIGN.md` §3.8–§3.9 touch these TX-relevant places (code-verified site addresses;
consequences inferred):

| Site | TX relevance | Assessment |
|---|---|---|
| T5/T6 wrappers in `030239D4` | restore `3BEAB` / `3C61A`, the inputs of `030272EC` and `03027334` | intended to keep TX admit stock; must not change `3BEAA`/`3BEAC` |
| T8 `030284D4` (`030282A4` FID `0x10` follow) | the branch rewrites `33CCB`/`33CCC`/`3BEAA`/`3BEAC` (TX slot) and may retune | guard keeps TX slot stock for B bursts |
| T9 `0305CB6C` (inside the PTT handler `0305C334`) | changes the PTT **target** during a B-slot call display | the only design site inside a TX root; must leave every gate of §3 untouched |
| C6/C7 (`0301E73C`, `0301EC40`) | write `LOCAL_CC` bits 9:8 only; TX CC uses bits 3:0 (`0002D7C8` in mode 4) | no TX change if bits 3:0 stay as written |
| T1–T4, C1–C5, T7, T10 | receive gates / display | no TX code |

**Read-only TX subjects (complete list from this review):** `03027334`, `030272EC`, `030272D4`, `03027320`, `03023AFC`,
`0301DE64`, `0301DF0C`, `0301DF8C`, `03023290`/`030231C0`/`03023258`, `030237B8`, `0002D7C8`, `0002D6C0`, `0002D500`,
`030294C8`, `03029674`, `030297A4`, `03029878`, `03029C3C`, `03029D08`, `03029D3C`, `03020FE4`, `03020DC8`,
`0301E924` (`CclTraffic`), `0301EAC8`, `0301EAE8`, `0300D284`, `0300DC94` (`rf`), `0002C404`/`0002C3D8`, `0002B440`,
`0002B4A0`, `0300E40C`, `0002C83C`, `0002B364`, `0300C304`, `0305C1E0`, `0305BE64`, `030601CC`, the PTT gates in
`0305C334` (all but the T9 byte), `030149E8`, `03014C38`, `03014E38`, `03014DEC`, `03014F54`, `03055A70`. The design's
earlier list (`03027334`, `0301DE64`, `0301DF0C`, `0301DF8C`, `0002D7C8`, `0002D6C0`) is a correct subset for the
**admit** decision; the request funnel, RF keying and PTT gates above are additionally TX-relevant and must not be
patched. Shared RAM the caves may read but must not write: `3BEAA`, `3BEAC`, `33CCB`, `33CCC`, `3BEBB`, `3C624`,
`3BA55`, `3BA59`, `3BA68`, `3BAB8`, `38480`/`38481`, `3FDEC` bit 3.

## 6. Open questions for the owner

1. Is any analog signalling system (DTMF / 2-tone / 5-tone) enabled on your analog channels in CPS, with a decode
   response? If yes, the radio can answer a matching code by transmitting (§3).
2. Which CPS option corresponds to the decode response types 1 (local tone) and 2 (transmitted acknowledgement)?
3. Is the emergency alarm configured (alarm type ≠ 1) on any channel? Its CSBK is sent even when the channel is busy.

## 7. RX-only hardware test proposals (stock firmware)

Disable first: Lone Worker, Auto Roaming, VOX, GPS beacon interval, emergency alarm, analog signalling decode
responses; use an Rx Only channel where possible; do not send DTMF/2-tone/5-tone codes, texts or CSBKs to the radio.

| Finding | Test (no transmission) | Expected |
|---|---|---|
| `Tx Limit!` gate | Tune a VFO receive frequency outside the TX bands (e.g. airband), press PTT once | `Tx Limit!` prompt, no TX indicator |
| Voltage gate | Observation only when the battery is low | `Low Voltage!` on PTT, no TX |
| Rx Only gate | On an Rx Only channel press PTT | `Rx Only` prompt and tone, no TX indicator |
| Decode list content | CPS (read only): note the 2-tone/5-tone/DTMF decode entries and their response options | lets the owner judge §3 risk without transmitting |

## 8. Left unreviewed

`030140E4` permission callback table (`*18000804`, 12 entries, used by alarm id 7 and TBST id `0x1C`); CTCSS/DCS tail
(`0300DD94`); `030644B8`, `03065290`, `03067764` encoders (read only for their S1/S2/S3 calls); PCTESTM sub-commands;
`03026518` callers' Rx Only handling in `rxmsg`; IRAM `000169D8`/`00016AD0` register save/restore; the `0306054C` TX
indicator (draws the bar only, no RF access).

## 9. Additions from pass 3 (2026-10-18, `HUB_FUNCTIONS.md` §8)

**New root: DCDM channel timing (task context: OS timer task; code-verified flow, emission inferred from the TX
queue).** On a channel with the DCDM bit (record `0x1D` bit 5, CPS "Double Slot"; RX mode 4 in `0301E580`):

| Step | Function | Condition |
|---|---|---|
| mode-4 set-up arms the 270 s timer `36490` | `0301E580` → `03024120` → `0300C690` | every load of a DCDM channel |
| no leader heard: become leader, random backoff | timer → `0300C424` → `030243A0` → `030241A4` (`rand()`, timer `3548C`) | state `3BED8` = 3 |
| **queue CT_CSBK bursts** | timer → `0300C414` → **`03024224`** → `03029464`/`030294C8`, direction `03023290(4, 2)` | CT_CSBK state `3BEDC` 3/4, carrier flag `0300C3AC` clear or own TX-slot queue empty; else re-backoff |
| repeat every 120 s; follow a received leader | `0300C6AC(120000)`; `03024908` → `03024418`/`030244B8`/`03024614`/`03024678` | received CT_CSBK (CC 15) |
| CT_CSBK before own data/CSBKs in mode 4 | `03024794` from the data senders | own transmission only |

Gates found: carrier/queue only. **No Rx Only, CPS-session, test-mode or stun test** in `03024120…03024794` or the
timer callbacks (inferred: direct calls, the three timer callbacks and the queue path read). The burst goes through
the normal TX queue → `RF_TX_INTERP` → task `rf` → S5, so it keys the transmitter like any queued burst.

**Boot-time `FM_PTT`.** `000169D8`/`00016AD0` (left unreviewed in §8) are called once at boot through `00015D8C`: FM
mode and `FM_PTT = 1` during the vocoder/codec start-up, then everything is restored. No PA (`0002C83C`), RF-chip
(`0002C2F8`) or power-ramp call is on that path and `0301D550` drives both PA GPIOs (35, 55) low at boot, so no
RF emission is expected (inferred). Not a TX root.

**Corrections to §8 (left unreviewed):** `000169D8`/`00016AD0` reviewed (above); PCTESTM `W` parameters named
(`CPS_PROTOCOL.md` §8a).

**Safe test practice (addition):** for RX-only tests also avoid DCDM ("Double Slot") channels, or use them only with
Rx Only set and still expect a CT_CSBK transmission (the Rx Only bit is not checked on that path).
