# HR_C7000 register cross-check — DM32.NRF.01.049

Static analysis, 2026-10-14 (fifth pass, unattended). No serial port, no radio access, no image built. Nothing
here is hardware-verified.

Purpose: confirm or refute, with the baseband datasheet, the register meanings that earlier passes inferred from
code (`MONITOR_ANALYSIS.md`, `TS_ANALYSIS.md` §7, `CC_MATCH_ANALYSIS.md`, `RX_CALL_PATH_ANALYSIS.md`,
`SETTINGS_CPS_ANALYSIS.md` §5), and decide whether the chip filters Colour Code or time slot in hardware.
`EXTERNAL_RESOURCES.md` already lists `WORK_MODE`, `LOCAL_CC` and `RX_TYPE_INFO`; this file adds the remaining
registers, the interrupt list, the receive RAM map and the firmware evidence for each claim.

## 0. Inputs and method

| Item | Value |
|---|---|
| Datasheet | `docs/HR_C7000 Document 2.pdf`, SHA-256 `d60f652e114d5103b2252be604089528775dffa263c703545d7cfed9fe490253` (Chinese, 412 pages, 2017 revision). Text extracted with `pdftotext -layout` (poppler); page numbers are the printed "第 N 页" footers |
| Stock image | `analysis/inputs/stock_progmem_1MiB.bin`, `de7dbcbc…` (checked) |
| Installed image | `analysis/inputs/current_scan_tick_fix.progmem.bin`, `156a4872…` (checked; all sites below are stock code outside the Scan Zone patch) |
| GZF | `analysis/archives/DM32_NRF_049_correct_base.gzf`, `354f9324…` (checked); re-export 2171 functions, 0 failures |
| Tools | Ghidra 12.1.4 + legacy CSKY v0.2 + `32b_data.fixed.sinc` (fix 3), GNU binutils 2.42 `csky-elfabiv2`, `tools/dm32` |

Register access lists come from `python3 tools/dm32 acc <addr> --len 4` (constant tracker over flash and IRAM,
`DM32RE_TOOLS.md`); each important site was then read in `flash.asm`/`iram.asm` from
`tools/static/objdump_image.sh`. The tracker misses addresses built through pointers, so "no other writer" below
means "none found by the tracker and by a text search of the export" (inferred).

```sh
source /opt/dm32-tools.env
pdftotext -layout "docs/HR_C7000 Document 2.pdf" c7000.txt
python3 tools/dm32 acc 11000384 --len 4      # likewise 11000100/104/390/394/398/39C/3A0/400/404/408/418/000/05C
python3 tools/dm32 fn 0301E580               # RX mode setup
tools/static/objdump_image.sh analysis/inputs/stock_progmem_1MiB.bin $ASM
```

Label used in the tables: **datasheet + code** = the register field is documented in the datasheet and the
firmware access is code-verified at instruction level; the behaviour on the radio is still not hardware-verified.

## 1. Register table

Base `0x1100_0000` (memory map p. 89: Modem 64 KB).

| Register (offset) | Datasheet (page) | Firmware evidence (code-verified) | Earlier inference | Verdict |
|---|---|---|---|---|
| `SYS_SOFT_RSTN` (`0x000`) | p. 55: bit 8 `cpu_soft_rstn`, 7 `sys_soft_rstn`, 6 ADC ctrl, 5 baseband ADC, 4 codec, 3 audio, 2 FM, 1 PHY, 0 protocol; all **active low**, default 1 | `0305F2F4` writes `0xFFFFFE7F` (bits 8 and 7 = 0); `030234E8` (DMR reset) writes `0x1FC` (bits 1:0 = 0); `03023574` (DMR init) `0x190`; `030215C8`/`03021710` `0xFFFFFFFC`; `03021AF8` and IRAM `000169D8` clear bits 3/4 | `0305F2F4` = restart (strong inference) | **datasheet + code**: `0305F2F4` asserts the CPU and system soft reset → restart. The PHY/protocol writes (`0x1FC`, `0xFFFFFFFC`) leave bits 1:0 at 0 with no later write of 1 found, which does not fit a level-held reset; the exact reset semantics of bits 1:0 are **unresolved** |
| `QUAD_ENABLE` (`0x05C`) | p. 68: bits 31:24 `sys_sample_delay`, bit 0 `quad_enable` (LCSFC SPI four-wire) | boot IRAM `0002BB9C` writes `0x01000001`; `0305F2F4` writes `0x01000000` just before the reset | "restart hypothesis" | **datasheet + code**: `0305F2F4` switches the SPI flash controller back to single-wire mode, then resets — consistent with a clean reboot from flash |
| `AUDIO_CONTROL` (`0x080`) | p. 96: bit 7 ring (prompt) path, **bit 6 `fm_play_ctrl`** (FM play path), 5/4 AHB voice read/write, 3 FM side-tone, 0 voice source | `0300C2DC(on)` sets/clears bit 6 (analog Monitor `03060398`, squelch open `0300E2C0`); IRAM `00016088`…`00016120` (vocoder-related, roles inferred) | "analog audio path" (inferred) | **datasheet + code**: analog Monitor/squelch open select the FM playback path |
| `AUDIO_BUFFER_CLR` (`0x084`) | p. 96–97: bit 1 clear vocoder **decode** buffer, bit 0 clear **encode** buffer (write-1, self-clearing) | `030218B0` (RX audio open) `|= 3`; `0302197C` (RX audio close) `|= 2`; `03023574` writes 3 | "audio open/close" | **datasheet + code**: buffer flushes around a received call |
| `WORK_MODE` (`0x100`) | pp. 97, 298: bit 8 digital/analog auto-detect, 7 FM, 6 Tier II, 5 time-slot mode, 4:3 layer (1 = layer 2), 2 `is_repeater`, 1 `is_aligned`, **0 `work_slot_sel`** (0 TS1, 1 TS2; "must be 1 in layer-3 non-repeater mode") | DMR init `03023574` writes `0x6E` (Tier II, TDMA, layer 2, bit 2, aligned, TS1); `0301E580` read-modify-writes it: bit 2 set for every digital mode, bit 0 = slot (modes 1/4, else 0), bit 7 for analog; `0301ECC0` bit 0; `030215C8` test modes `0x13`/`0x02`/`0x22`/`0x80`; IRAM `000169D8`/`00016AD0` save/restore | OpenGD77 C6000 reg `0x10` analogy | **datasheet + code** for the field names. `work_slot_sel` names the radio's own working slot; it is **not** a receive filter (see §3). Bit 2 (`is_repeater`) is set on simplex channels too; its effect in layer 2 is not described (unreviewed) |
| `RF_MODE` (`0x104`) | pp. 98–99, 279–280: **bit 12 `adjustsyncmax`** (default 1; "must be 0 when `LOCAL_CC.cc_opt` = 1"), **bit 11 `use_dual_phy`** (two receiver channels, for repeater RX and DCDM), bits 14:13 RX mode, 6:5 TX mode | `0301E580` sets bit 11 for RX mode 4 and clears it otherwise; `03023574` sets bits 15, 14:13, 6:5, 25/24 by RF type; **no writer of bit 12 found** (writers: `03023574`, `0301E580`, IRAM `000169D8`/`00016AD0` restore) | — | **datasheet + code**: mode 4 enables the dual receiver as the DCDM appendix requires. **New finding:** firmware sets `cc_opt = 1` (Monitor, mode 4) without clearing `adjustsyncmax`, contrary to the datasheet note (effect unknown; absence of a writer is inferred) |
| `RECV_MS/BS/TDMA1/TDMA2_SYNC_H/L` (`0x13C`…`0x158`), `SEND_DATA_SYNC_H/L` (`0x12C/0x130`), RC sync (`0x134/0x138`, `0x15C/0x160`) | p. 278 (table 27), p. 284: bit 31 of each `_H` = detection enable, bits 23:0 = 48-bit sync pattern | `03023574`/`0301E580` write the ETSI patterns: MS data `D5D7F77FD757`, BS data `DFF57D75DF5D`, TDMA1 data `F7FDD5DDFD55`, TDMA2 data `D7557F5FF7F5`, RC `77D55F7DFD77`; `0301E580` then sets bit 31 of **MS and BS** (`0x13C`, `0x144`) in modes 0/1, of **TDMA1 and TDMA2** (`0x14C`, `0x154`) in mode 4; `SEND_DATA_SYNC` from tables `030B0424`/`030B042C`/`030B0434` by mode and slot | — | **datasheet + code**. Mode 4 exactly follows datasheet §18.3.5.1 (DCDM: MS/BS detection off, TDMA1/2 on, dual PHY on) → **mode 4 = ETSI DCDM ("Double Slot") is now datasheet-confirmed** (was inferred from CT_CSBK fields) |
| `LOCAL_CC` (`0x384`) | p. 301: bit 16 `encryption_type` (0 basic, 1 enhanced), **bits 9:8 `cc_opt`** (0 decode only frames whose CC is correct and equal to the local CC; 1 decode any correctly received CC; 2/3 decode nothing), bits 3:0 local CC; p. 411: DCDM needs `cc_opt = 1` and CC `0xF` while sending CT_CSBK | `0301E7BC` bits 3:0; `0301E580` clears 9:8, sets bit 8 for mode 4 or Monitor (`0301E73C`); `0301EC40` clears 9:8, sets bit 8 when on; IRAM `0002D7C8` bits 3:0 (CC 15 for CT_CSBK in mode 4). **No writer of bit 16 found** | bit 8 = "accept any CC" (inferred) | **datasheet + code**: a **hardware CC filter exists**; Monitor and mode 4 switch it to "any CC". Enhanced privacy is not selected through bit 16 (stays 0); the firmware decrypts in software (`RX_CALL_PATH_ANALYSIS.md` §13) |
| `VOICE_EMB_CTRL` (`0x388`) | p. 301: bit 1 burst-F EMB from internal RC encoder, bit 0 PI bit for bursts B–E | `03023574` writes 0; `0002D7C8` sets bit 1 when it queues voice burst F | — | **datasheet + code** (TX side) |
| `SCRAMBLE_REG` (`0x38C`) | p. 301–302: basic voice scrambling keys (RX 31:16, TX 15:0) | `03023574` writes 0, no other writer | — | datasheet + code: hardware basic scrambling unused |
| `RX_TYPE_INFO` (`0x390`) | pp. 302–303: 30 CRC8 err, 29 Golay err, 28 QR err, 27 checksum err, **26 CRC16 err**, **25 RS24 err**, 24 data-block err, **23 CACH AT**, **22 CACH TC**, 21:20 CACH LCSS, **19 `current_rx_slot`**, 18 soft-info done, **17 PI**, 16:15 LCSS, **14:12 voice burst 1–6 = A–F**, **11:8 data type**, **7:4 received CC**, **3:2 sync type 00 MS / 01 BS / 10 TDMA1 / 11 TDMA2**, **1:0 sync 00 none / 01 voice / 10 data / 11 RC** | copied to `3BECC` by the ISR `0002C458`; `03028644` extracts 1:0, 11:8, 14:12, 17, 7:4, **19**, 3:2; CSBK/PI/data header test 26, LC header/terminator/late entry test 25; `0002D500`/`0002D6C0` read 22, 23, 21:20; `03024868` reads 3:2 in mode 4 | earlier docs: "sync class", "sync source", "embedded privacy" | **datasheet + code** for every field earlier docs used. Corrections: bits 3:2 are the **sync pattern type** (MS/BS for modes 0/1, TDMA1/TDMA2 in DCDM) — matches the "sync source" reading; bits 1:0 value 3 is **RC** (reverse channel), not an unknown class; bit 17 is the **PI (privacy) flag** of the EMB |
| `RX_INFO` (`0x394`) | p. 303: bits 24:16 `tdma_slot_num` (trunking), **bits 10:0 `rc_info`** (11-bit RC / burst-F embedded info). Table 28 on p. 297 lists `RX_INFO` at `0x39C`, which collides with `SYS_INTERP_MASK`; the firmware writes the interrupt mask to `0x39C` and reads RX data from `0x394`, so `0x39C` in table 28 is a datasheet typo | ISR copies it to `3BEA4` (no reader of `3BEA4` found); `03027628` (late entry privacy) reads bits 2:0 = algorithm and bits 10:3 = key id and compares them with `3F720`/`3F721` | "privacy alg/key" (code-verified use) | **datasheet + code**: the 11 RC-info bits carry the burst-F embedded field, which the datasheet's encryption appendix (p. 373–374, table 73) defines as KeyID + 3-bit algorithm id. The firmware's split (alg 2:0, key 10:3) is consistent; the exact bit order is code-verified only |
| `SYS_INTERP_LIST` (`0x398`) / `_MASK` (`0x39C`) / `_CLEAR` (`0x3A0`) | pp. 99–102: **bit 0 `dll_rdy_interp_tx`, 1 `dll_rdy_interp_rx`, 2 `dll_latelc_rx_interp` (late entry), 3 `dll_frame_rx_interp` (frame received), 4 `dll_shortlc_rx_interp` (CACH short LC), 5/6 TX/RX slot abnormal**, 11 `phy_rx_interp`, 12 `phy_rdy_interp`, 16 PHY RX slot abnormal | ISR `0002C458` loops `list = 0x398; clear 0x3A0` until the list is empty, ORs the bits into `3BEA0`, copies `0x390` → `3BECC` and `0x394` → `3BEA4`; `03023574` writes mask `0x1187F` (bits 0–6, 11, 12, 16). Dispatcher `030239D4`: bit 6 → `03023880`, bit 4 → `03027388`, **bit 3 → `03028644`**, **bit 2 → `03028BE4`**, bit 1 → `0002D6C0`, bit 11 → `030239C4` | "status bits" (unnamed) | **datasheet + code**: `03028644` is the **frame-received** handler, `03028BE4` the **late-entry** handler, `03027388` the **short-LC (CACH)** handler, `0002D6C0` the layer-2 RX-ready handler, `03023880` the RX slot abnormal handler |
| `LAYER2_CONTROL` (`0x400`) | p. 303: 7 `txen`, 6 `rxen`, 5 `layer2slot`, 4 TX temp master, 3 RX auto update, 2 TX slave auto, 1 TX master, 0 RX master | `030231C0` (`0xCB` / `0xD3|8` by entry argument), `03023258` (`0xC4`), `03023A88`/`03023AD8` (bit 4), `03024908` (DCDM leader), `030215C8` test modes, `030231A8` clears | — | **datasheet + code**: TX slot establishment (active/passive) and DCDM leader timing; RX enable (`rxen`) is set in every digital configuration. No access depends on the programmed slot `33CCC` |
| `LAYER2_SLOTON` (`0x404`) | pp. 304–305: TX/RX slot-on enables and status bits 31:27 | `030231C0`, `03023258` (`|= 5`: TX and RX slot on), `03023A88`/`03023AD8` (temporary slot), `03023394` (reset), `03023574` (`0x11`) | — | **datasheet + code**: slot timing establishment; not a slot selector |
| `LAYER2_TXRX_CTRL` (`0x408`) | p. 305: 31 TX complete, 23/22 sync-fail release, **15 `begin_v_layer2`** ("voice access success; software writes 1 to start voice access, and must write 0 in the slot that does not receive voice"), **7 `txnextsloten`**, **6 `rxnextsloten`** (receive in the coming slot), 0 PHY test | IRAM `0002D7C8` (called once per 30 ms tick for the current burst slot): sets bits 7:6 = `10` when it loads a TX burst, otherwise `01` (receive) — independent of slot number; **`03023828`** (per tick) sets bit 15 when `3C620[3BEA8]` (voice call accepted on the current burst slot) else clears it; `03023394`, `030231C0`, `03023258`, `03029C78` | "re-arm bits 7:6", "bit 15 from 3C620" | **datasheet + code**: the radio receives **every** slot in which it does not transmit, and opens voice delivery per slot in software from `3C620[slot]` |
| `LAYER2_SEND_TYPE` (`0x418`) | pp. 307–308: 31:22 encode type for data types 11–15, 12/11 RC embedding, 7:4 `localdatatype`, 3 `localvod` (1 voice/RC), 1:0 LCSS; table 55 p. 328 | `0002D7C8`: data/CSBK = `type << 4` (vod 0), types 11–15 add the encode-type field; voice burst F = `0x58`, RC = `0x68`; `03029C78` (direct CSBK) | "TX burst type" | **datasheet + code** (TX, read-only subject) |
| `LAYER2_STATUS` (`0x41C`) | p. 309: 31 TX slot, 30 RX slot, 29 temp TX slot, bit counters | `03023880` (RX slot abnormal), `030231C0`, `03023290`, `03023A88` (`3BEB7` = bit 29 xor `3BEA8`) | — | datasheet + code |

## 2. Receive RAM and the per-slot voice buffers

Datasheet table 53 (pp. 313–314), receive RAM base `0x160004B0`: frame payloads at `0x00…0x17`, EMB of slot 0 at
`0x1F…0x24` and of slot 1 at `0x25…0x2A`, CACH short LC at `0x2B…0x2F`, **216-bit voice of slot 0 at `0x36…0x50`
(time-slot mode) or `0x39…0x53` (continuous mode), of slot 1 at `0x66…0x80` / `0x69…0x83`**, RX key at `0x495`.

Firmware (code-verified, `03028644` at `03028902…0302897C`): the voice copy reads 27 bytes with `0300D41C(off, …)`.
In RX mode 4 `off` = `0x66` if status bit 19 (`current_rx_slot`) is 1, else `0x36`; in all other modes `0x69` /
`0x39`. (The datasheet labels `0x36`/`0x66` "time-slot receive mode" and `0x39`/`0x69` "continuous receive mode";
the firmware uses the latter pair on normal TDMA channels — why is not established, but the per-slot split is the
same.) So the chip keeps **separate voice buffers per slot** and the firmware picks the buffer by the hardware
slot bit, not by the software slot `3BEA8`. The destination ping-pong buffer `3C69C` is
still shared (`TS_ANALYSIS.md` §8), so the one-captured-slot rule for TS Match off is still required.

## 3. Decisions

### 3.1 Hardware Colour Code filter: **exists** (datasheet + code)

With `cc_opt = 0` the chip decodes only frames whose CC is correct and equal to `LOCAL_CC[3:0]`. The stock
firmware uses `cc_opt = 0` on normal channels and `cc_opt = 1` only while Monitor is on (`0301EC40`, re-applied by
`0301E580`) or in RX mode 4 (DCDM, where the datasheet requires it for the CC 15 CT_CSBK). With `cc_opt = 1` the
software comparisons listed in `CC_MATCH_ANALYSIS.md` are the only CC filter.

Consequences:

- **CC Match off needs `cc_opt = 1`** in addition to the voice-site software bypasses. Patching only the software
  comparisons would change nothing on a normal channel, because foreign-CC frames would not raise a frame interrupt
  (inferred from the datasheet text; not hardware-verified). This confirms `CC_MATCH_DESIGN.md` §1 and corrects
  `MATCH_OPTIONS_DESIGN.md` §3.1, which listed only software sites (see that file, §3.7).
- With `cc_opt = 1` every software CC gate that has no Monitor bypass (CSBK, data header, packet data, PI header)
  remains the only protection — exactly the stock Monitor situation. The stock Monitor already runs this way.
- Not established: whether `cc_opt = 0` also filters **voice bursts B–F by their EMB CC**, or only frames with a
  slot type (data sync). The software counter `3C626` (embedded CC mismatch) suggests that mismatching EMB CCs can
  reach software at least with `cc_opt = 1` (inferred).
- Datasheet note not followed by the firmware: `RF_MODE.adjustsyncmax` (bit 12) should be 0 when `cc_opt = 1`; no
  writer of bit 12 was found, so Monitor and DCDM run with the reset value 1. A CC Match off design should **not**
  add a new `RF_MODE` write without owner tests (the stock Monitor behaviour is the reference); recorded as an open
  question.

### 3.2 Hardware time-slot filter: **does not exist in the stock configuration** (datasheet + code)

Evidence chain, each link code-verified at instruction level:

1. `0002D7C8` sets `rxnextsloten` for every tick in which no TX burst is loaded, for both slots alike.
2. Frames from both slots raise `dll_frame_rx_interp`; the ISR `0002C458` hands them to `03028644` with
   `RX_TYPE_INFO`, which carries `current_rx_slot` (bit 19) and the CACH TC (bit 22).
3. The slot gates that drop the other slot are software (`TS_ANALYSIS.md` §4) and compare `3BEA8` (from the TC
   history in `0002D500`) with `33CCC`.
4. Voice delivery is opened per slot by software (`03023828` → `begin_v_layer2` from `3C620[slot]`), and the chip
   keeps one voice buffer per slot (§2).
5. `WORK_MODE.work_slot_sel` and the `LAYER2_*` slot registers only set up TX/RX slot timing; no access depends on
   `33CCC` or `3BEAA`.

So the earlier strong inference (`TS_ANALYSIS.md` §7, OpenGD77 analogy) is now **datasheet + code**: a TS Match off
change only needs the software gates and the capture rule. Status bit 19 is a hardware slot label that the
firmware already uses for the voice buffer; the gates use the TC-derived `3BEA8` (both should agree after slot
lock; not verified on air).

## 4. Updates to earlier documents

| Document | Statement | New label |
|---|---|---|
| `MONITOR_ANALYSIS.md` §3 | `11000384` bit 8 = "accept any CC" | datasheet + code (`cc_opt = 1`) |
| `TS_ANALYSIS.md` §7 | `11000100` bit 0 is not a receive slot filter | datasheet + code (§3.2) |
| `TS_ANALYSIS.md` §3, `RX_CALL_PATH_ANALYSIS.md` §0.1 | bits 3:2 "sync source" | datasheet: sync pattern type MS/BS/TDMA1/TDMA2 |
| `RX_CALL_PATH_ANALYSIS.md` §4, §6 | mode 4 = DCDM (inferred) | datasheet + code (sync registers and `use_dual_phy`) |
| `SETTINGS_CPS_ANALYSIS.md` §5, `RX_CALL_PATH_ANALYSIS.md` §7.9 | `0305F2F4` restart (strong inference) | datasheet + code (CPU + system soft reset after leaving quad SPI mode) |
| `SETTINGS_CPS_ANALYSIS.md` §5 | status bit 17 = embedded privacy parameters (inferred) | datasheet: bit 17 = received EMB PI flag |
| `CC_MATCH_ANALYSIS.md` | hardware role of bit 8 inferred | datasheet + code: hardware CC filter exists, CC Match off needs `cc_opt = 1` |

## 5. Open questions for the owner

1. Monitor runs with `cc_opt = 1` and `adjustsyncmax = 1` (datasheet says 0). Does stock Monitor reception on a
   wrong-CC repeater sound as reliable as normal reception (§3.1)? This decides whether a CC Match off design must
   also write `RF_MODE` bit 12 — a change the owner should approve only after this test.
2. Is a voice call with a foreign **embedded** CC but matching header CC realistic on the owner's repeaters? (Only
   relevant to the `3C626` counter.)

## 6. RX-only hardware test proposals (stock firmware)

| Finding | Test | Expected if correct |
|---|---|---|
| §3.1 hardware CC filter | Repeater channel with a wrong CC, Monitor **off**: watch the radio during repeater traffic (RSSI bar, green LED, no audio) | No call display and no audio; only the RF carrier is detected |
| §3.1 `cc_opt = 1` | Same channel, Monitor **on** | Voice audible, call display shows the source, SMS/data still ignored (`MONITOR_ANALYSIS.md` §7) |
| §3.2 no hardware slot filter | Not observable without a firmware change; stock behaviour stays "programmed slot only". Use an SDR (dsd-fme) to confirm both slots are active while the radio stays silent on the other slot | Radio silent for other-slot traffic, SDR shows it |
| §1 `0305F2F4` | After a CPS write, observe the radio | Radio reboots by itself (boot screen) without a power-key press |

## 7. Not reviewed

*Updated 2026-10-17: the items struck through below are answered in §8.*

~~Exact meaning of `WORK_MODE` bit 2 in layer 2~~ (partly, §8.4); ~~reset semantics of `SYS_SOFT_RSTN` bits 1:0 as used by
`030234E8`~~ (§8.1); ~~`LAYER2_SLOTON` value `0x11` written at init~~ (§8.4); ~~the test-mode setup `030215C8` (caller and purpose)~~
(§8.2); the trunking `tdma_slot_num` field (no reader); ~~the physical-layer FIR/threshold registers (`0x120`, `0x168`,
`0x1B4`)~~ (§8.3; `0x168` is undocumented).

Still open after §8: the layer-2 effect of `is_repeater` on a simplex channel; the meaning of the undocumented
register `0x168`; why `rf_recv_delay` is 14000 (1.4 ms) where the AF-mode note asks for 2000; register `0x560`
(`0300C304`, not in the register tables found); `tdma_slot_num`.

## 8. Remaining register leads (2026-10-17)

Inputs, tools and method as in §0 (all four input hashes re-checked on 2026-10-15). Static only; no radio access.

### 8.1 `SYS_SOFT_RSTN` bits are self-releasing pulses (datasheet + code)

Datasheet p. 54, §4.1.2.2: "the CPU generates a soft reset by configuring the soft-reset register; writing 0 makes the
reset active, and the register value is **released to 1 automatically**". So a 0 bit is a one-shot reset pulse, not a
level held by software. This resolves the §1 puzzle ("bits 1:0 stay 0 with no later write of 1"):

| Writer | Value | Modules pulsed (bit = 0) | Context (code-verified) |
|---|---|---|---|
| `03023574` (DMR init) | `0x190` | ADC ctrl (6), baseband ADC (5), audio (3), FM (2), PHY (1), protocol (0); CPU, system and codec kept | first store after `03029438`/`03024E6C`, before the sync-pattern writes |
| `030234E8` (DMR reset) | `0x1FC` | PHY (1), protocol (0) | drains TX queues and clears `3C620..3C627` |
| `030215C8` (test-mode setup, §8.2), `03021710` | `0xFFFFFFFC` | PHY (1), protocol (0) | factory test entry |
| `0305F2F4` | `0xFFFFFE7F` | CPU (8), system (7) | restart (§1) |

`03021AF8` and IRAM `000169D8` clear bits 3/4 with read-modify-write (audio/codec pulse; context unreviewed).

### 8.2 `030215C8(n)` — baseband factory test-mode setup (code-verified writes; test names inferred)

Callers (BSR scan): the `PCTESTM` loop `0302AA58` (`0302AFB8`, `0302AFE8` with `n = 3E5F4`, `0302B036` with `n = 9`) and
`03038034` (`03038460`, `03038492`, `030384E0`), a UI handler reached only through the code-pointer table at `030B161C`
that repeats the same three call sequences (an on-radio test scene; inferred). It is not on the normal receive path.

| `n` | Writes (stock bytes read in `flash.asm`) | Reading (datasheet fields) |
|---|---|---|
| all | `SYS_SOFT_RSTN = 0xFFFFFFFC` | PHY + protocol reset pulse (§8.1) |
| 1, 3 | `LAYER2_CONTROL = 0x82`, `LAYER2_TXRX_CTRL = 0x81`, `WORK_MODE = 0x02`; 36 bytes `0x5F` written twice through `0300D3EC` (offsets 0 and 36) | physical-layer mode (layermode 0), aligned, continuous; TX enable + TX master; `txnextsloten` + PHY test; fixed TX payload pattern |
| 2 | as 1 but payload `0x55`, then `0300C304(0)` | alternating-bit TX pattern |
| 4 | `LAYER2_TXRX_CTRL = 0`, `LAYER2_CONTROL = 0`, `WORK_MODE = 0x13` | layermode 2 (layer 3), aligned, `work_slot_sel = 1` (the datasheet requires 1 in layer-3 non-repeater mode) |
| 5…10 | `0x168 = 152`, `RF_RECV_DELAY = 0`, `WORK_MODE = 0x22`, `LAYER2_CONTROL = 0x40` (`rxen`), `LAYER2_TXRX_CTRL = 0xC1`, MS and BS sync detection enable (bit 31 of `0x144`, `0x13C`) | physical-layer receive test in time-slot mode |
| 5…7 | then `WORK_MODE = 0x80`, `0300C304(1)` | FM (analog) mode |
| 8…10 | `0300C304(0)`; for `n = 9` also `0301E580(0, 0, 1)` (analog RX setup) | |
| > 10 | `WORK_MODE = 0x80` | FM mode |

`0300C304(on)` writes `on` to `0x11000560`, which the register tables found in the datasheet do not list (other writers:
IRAM `000169D8`/`00016AD0` save/restore). Unresolved.

### 8.3 `THRESHOLD_VALUE` (`0x120`), `0x168`, `RF_RECV_DELAY` (`0x1B4`) (datasheet + code)

| Register | Datasheet | Firmware |
|---|---|---|
| `0x120` `THRESHOLD_VALUE` (p. 282) | 28:24 `sync_real_limit` (default 9), 23:16 `maxvalue_low_limit` (0x64), 15:8 `maxvalue` (0x78), 7:0 `sig_cor_value` (0x67): sync-word detection thresholds | only writer `03023574`: `0x0978786F` → ratio 9 (default), low limit **0x78** (default 0x64), high limit 0x78 (default), arrival threshold **0x6F** (default 0x67). Low and high limit are equal, so the ratio test between them (used only when a value lies between the limits) never applies; the firmware uses one fixed sync threshold. With `adjustsyncmax = 1` (never cleared, §1) the chip may still adapt it |
| `0x168` | **not listed**: the receive register table (p. 278) goes from `0x164` `RECV_INFO_COUNT` to `0x16C` `RECVFIR_COEF1` | `03023574`: 20 when the RX RF type is 4, else 152; `030215C8`: 152 in test modes 5…10. Meaning unknown |
| `0x1B4` `RF_RECV_DELAY` (p. 290–291) | 18:0 receive-path delay compensation in 100 ns steps; "AF receive mode requires 2000, other schemes default 0". (The datasheet prints the next register, `MODEM_AK_CLK_CALB`, also at `0x1B4`; by the table on p. 278 it is `0x1B8` — datasheet typo) | `03023574`: **14000** (1.4 ms) when the RX RF type is 4, else 0; `030215C8`: 0 |

RF type: `0300C2C4` returns the constant 4 (RX type) and `0300C2C8` the constant 3 (TX type), so in this build
`03023574` always takes the type-4 branch: it sets `RF_MODE` bits 25 (`phase_avg_en`) and 24 (`af_mode`, AF receive
enable) and `af_recv_ctrl` (bits 23:16) `= 0x26` (from `152 << 14`), and `rf_trans_mode` (bits 6:5) `= 3` (two-point modulation,
the datasheet default). So the baseband runs in **AF receive mode** with an external FM receiver feeding it
(consistent with the BK4819-style RF chip in `SETTINGS_CPS_ANALYSIS.md` §4; inferred). The `0x168 = 152` /
`RF_RECV_DELAY = 0` branch at `03023720` is dead code in this build. Why the delay is 14000 rather than the
datasheet's 2000 is not established (it may compensate the RF chip's audio path; inferred).

### 8.4 `WORK_MODE.is_repeater` and `LAYER2_SLOTON = 0x11` (datasheet + code; effect partly inferred)

- `WORK_MODE` (p. 279): bit 2 `is_repeater`: 0 = non-repeater mode, 1 = repeater mode. The datasheet gives no further
  layer-2 description. `03023574` writes `0x6E` and `0301E580` sets bit 2 for every digital mode (§1). Bit 6 is
  `is_tier1_mode` (0 = Tier I, 1 = Tier II) and bit 5 `is_continuemode` (1 = time-slot mode), matching the §1 reading.
- `LAYER2_SLOTON` (p. 304): `03023574` writes `0x11` = bit 4 `bs_rx_slot_on` ("repeater-chip active receive mode:
  establish receive slot") + bit 0 `dll_tx_slot_on` (establish the TX slot in normal layer-2 mode). `03023258` later
  ORs in 5 (bits 0 and 2 `dll_rx_slot_on`).
- Together these show that the firmware puts the chip into its **repeater-style receive configuration**, which
  matches the §3.2 finding that every slot is received. Whether `is_repeater` changes anything else on a simplex
  channel is not described in the datasheet (open).

## 9. Registers identified in the targeted review (2026-10-17)

Inputs as in §0; details in `TX_PATHS.md` §1 and `MATCH_OPTIONS_DESIGN.md` §3.10.

| Register / area | Datasheet | Firmware (code-verified) | Verdict |
|---|---|---|---|
| `FM_PTT` (`0x560`) bit 0 | §11.2.2.25, p. 338: "FM transmit PTT, active high" | `0300C304(on)` is the only writer (plus IRAM save/restore `000169D8`/`00016AD0`); called by the analog TX start/end and tone senders | datasheet + code: analog transmit key |
| `INTERP_CLEAR` (`0x3B0`) bits 2/3 | §4.6.5.15, p. 105: clear RF transmit-start / RF receive-start interrupt (bits 0/1 TX/RX 30 ms slot, 4/5 PCM) | ISRs `0002C404` (vector 64) and `0002C3D8` (vector 65) set bits 2/3, then post task `rf` | datasheet + code: `RF_TX_INTERP` / `RF_RX_INTERP` (interrupt table 28, p. 92) switch the external RF stage for digital TX |
| Link-layer TX RAM `0x16000000` | table 52, p. 312 | `0300D3EC(off, src, n)` byte copy into it (TX burst loader, direct CSBK) | datasheet + code |
| Link-layer RX RAM `0x160004B0` | table 53, p. 313 | `0300D41C(off, dst, n)` byte copy from it (all RX handlers) | datasheet + code |
| `LAYER2_STATUS` (`0x41C`) | p. 309 | `03023880` (RX slot abnormal, dispatcher bit 6) reads it three times and returns | datasheet + code (read to acknowledge, inferred) |
