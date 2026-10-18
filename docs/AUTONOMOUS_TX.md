# Transmissions started without the PTT key — DM32.NRF.01.049 (summary, 2026-10-17; complete path review in `TX_PATHS.md`)

Collected from the static analyses in this repository (no new code analysis; nothing hardware-verified). Each row
links the document with the code-verified evidence. TX is inferred where the path ends in a known TX routine
(`030294C8` TX queue, `0301EAC8` call start, `03029C3C` repeater wake-up, alarm start `0305DD38`). Purpose: show the
owner which stock features can key the transmitter on their own, so that RX-only tests can avoid them. This project
changes none of them.

| Trigger | What is sent | Gate / condition | Evidence |
|---|---|---|---|
| Data or text addressed to the own ID (channel Radio ID) | link ACK/NACK/SACK (confirmed data), application reply (every individual text in the format selected by SMS Format, and the `0x44` format) | same CC and slot; **no Rx Only test on this path** (corrected 2026-10-18; Rx Only only blocks the CSBK ACKs) | `DATA_PATH_ANALYSIS.md` §6, `DATA_RX_PATH.md` §6 R1 |
| Text `"WLT CMD "` + `'1'` | GPS position message to the requester | any matching sender (same CC) | `DATA_PATH_ANALYSIS.md` §6, `GNSS_ANALYSIS.md` |
| CSBK Radio Check / Call Alert / Remote Monitor / Disable / Enable / `0x27` | ACK or NACK CSBK; Remote Monitor then **opens a transmission** to the requester | decode flags block 4 `0x65`; Rx Only channels: no ACK, but Disable/Enable/Call Alert still act | `DATA_PATH_ANALYSIS.md` §4.4, §8a |
| `UU_V_Req` (private call request) | `UU_Ans_Rsp` CSBK | to own ID | `DATA_PATH_ANALYSIS.md` §4.5 |
| FID `0x10` opcode `0x1E` | queued burst (`030297A4`) | to own ID | `DATA_PATH_ANALYSIS.md` §4.5 |
| **Roaming search** (periodic or requested) | up to 3 repeater **wake-ups** per roaming candidate whose downlink is not already received | Auto Roaming / interval (zone header), not on Rx Only channels, not while scanning | `RX_CALL_PATH_ANALYSIS.md` §17 |
| **Lone Worker timer expiry** | **emergency alarm** (same entry as the `Alarm` side key, source 3) | Lone Worker enabled (area `0x10` `0xB00`), channel record `+0x08` bit 0, alarm configured, no key press for the response time | `ALARM_ANALYSIS.md` §3 |
| Alarm in progress | alarm CSBK (request type 9, **queued even when the TX admit policy refuses**, repeated by `0300D284`), then a group voice call; channel reloaded with TX power bits forced to 2 | started by the `Alarm` side key or Lone Worker; alarm type ≠ 1; no Rx Only test found (`TX_PATHS.md` §3) | `RX_CALL_PATH_ANALYSIS.md` §16.2, `ALARM_ANALYSIS.md` §2 |
| **GPS/APRS position beacon** (periodic) | position text message to the configured ID (`400A4`), optionally on a dedicated beacon channel | interval block 4 `0x301` × 30 ticks (≥ 30), GNSS fix or the `0x302` option, not on Rx Only channels, not while scanning | `GNSS_ANALYSIS.md` §3b |
| **VOX** (voice-operated TX) | normal voice transmission, as if PTT were pressed | Other Func VOX on (`3E9D4+0x30` bit 0), radio idle (`0305DF8C`), see below | this file §1 |
| **Analog selective-call decode** (DTMF / 2-tone / 5-tone, 2026-10-17) | acknowledgement tones (`03068D04` → `03068B4C`/`03068C1C`) | analog channel whose signalling system (channel `+0x16` bits 3:1 = 2/4/6) decodes a matching code with response type 2; **no Rx Only test found**; the same decoders can stun (`0xA6`), kill (`0xA5`) or revive (`0xA0`) the radio persistently and restart it | `TX_PATHS.md` §3 |
| **DCDM channel timing** (2026-10-18) | CT_CSBK channel-timing bursts about 270 s after a "Double Slot" (DCDM) channel is selected when no timing leader is heard, then every 120 s, after a random backoff (`03024120` → `030243A0` → `03024224`) | channel DCDM bit (record `0x1D` bit 5, RX mode 4); carrier/queue check only; **no Rx Only test found** | `TX_PATHS.md` §9 |
| TX admit before an own call (repeater mode) | repeater wake-up | only after PTT (listed for completeness) | `MATCH_OPTIONS_DESIGN.md` §3.6 |

Safe test practice (owner, revised 2026-10-17 from `TX_PATHS.md`): for RX-only tests use an Rx Only channel where
possible (it blocks PTT, VOX, TBST, the beacon, roaming and the CSBK replies, but **not** the alarm, the analog
decode acknowledgement, the DCDM CT_CSBK or the replies to private texts — 2026-10-18, `DATA_RX_PATH.md` §6), disable Lone Worker, Auto Roaming, VOX, the GPS beacon interval and the emergency alarm in
CPS, do not use DCDM ("Double Slot") channels (2026-10-18: they send CT_CSBKs on their own, Rx Only does not block them), set the analog signalling system of test channels to none (or disable decode responses), do not send private texts (group texts to a talkgroup in the RX group list cause no reply),
CSBKs or DTMF/2-tone/5-tone codes to the radio from another radio unless a reply transmission is acceptable, and do
not press `Alarm` or the TBST/Sub PTT side keys.

Reviewed 2026-10-17 (`TX_PATHS.md` §3, code-verified): TBST (side key 30 → PTT handler), DTMF/FSK/5-tone PTT IDs
(start and end of a PTT transmission), the roger beep (end of transmission, `3EA18`) and the DTMF keypad (menu scene)
are all key-initiated. The CTCSS/DCS tail is still unreviewed. `0301AC98` is the
**receive** side: an analog call screen that shows a decoded `PTT ID` (name looked up with `03068780`) and plays tone
`0x16` once when `3FD4C+1` bit 3 is set. Remote Monitor duration: §3.

## 1. VOX (2026-10-17, code-verified flow; signal names inferred)

`030624C0` is called on every main-loop step (`03013940` → `030130F0` (call at `030132BA`)). After 10 warm-up calls
(`3E3A8+6`), and only when VOX is on (`3E9D4+0x30` bit 0), `40110` bit 2 is clear, `0305DF8C() ≠ 0` and `3FDD9` bit 1 is
clear (with extra conditions on `3FDEC` bits 1/3 and `40001` bit 1), it reads **ADC channel 1** with `0301CA8C(1)` (SAR
ADC block at MMIO `0x140D0000`, 10-bit result from `0x140D0030` bits 25:16; microphone level, inferred) and compares it
with the threshold `030B84F0[3E9D4+0x5E]` (9 levels: 114, 134, 152, 159, 162, 165, 168, 171, 174):

- above the threshold on two consecutive calls → if `030149E8(1)` allows it, sets `40001` bit 1 and calls
  `03014DD8(4)` (sets bit 2 in `+4` of the key-event block and posts event 2) — a **PTT-press event** (inferred);
- below the threshold for `3E9D4+0x5F` (= `3EA33`, Other Func **VOX Delay**) calls → `03014DD8(8)` — the PTT-release
  event, unless an alarm with `3FD4C+0x20` bit 4 is active.

So VOX transmits whenever the microphone level exceeds the selected threshold while the radio is idle.

## 2. Tick chain of the periodic features (2026-10-17, code-verified; period inferred)

```
IRAM periodic callback 0002CABC          — every 10th call: event bit 0 on 3FDB0     (GNSS_ANALYSIS.md §3)
  → main task 03068E54 loop → 03013940    — one main-loop step per event bit 0
      → 03054878 (at 03013E4C)            — every 100th step: event 0x20000 on 3FDB0
          → task "ScanDisp" 0305490C      — created by 030545FC (priority 0x26, 0x600-byte stack buffer 3EB20)
              → 03062D80 GPS/APRS beacon  (when 3FDE0 bit 2, 4009C bit 0, fix or 4009C bit 2)
              → 03066824 roaming trigger  (when 40144 bit 0 or request 40142, zone count ≠ 0)
              → 030654F8 Lone Worker      (when 0305DF8C() ≠ 0)
              → also 030689F0, 03068CC0, 0301BCC4, 0301B924, 03035864, 0301B5F0, 0305463C, 0305489C (unreviewed)
```

So one ScanDisp tick = 1000 calls of `0002CABC`. The beacon interval (`× 30`), the roaming interval (`× 60`) and the
Lone Worker response time (`× 60`) are counted in ScanDisp ticks, which fits a 1-second tick with intervals in units
of 30 s / 1 min / 1 min **if** `0002CABC` runs every millisecond (period of the timer not established).
The ScanDisp task skips the beacon and roaming steps while `3E172` (scan state `3E160+0x12`) is non-zero, `3FDD9` bit 1 or `3E338` bit 2 is
set, a menu scene (`320CB` 1…`0x3F`) is open, or `030649A8()` is neither 0 nor 1.

## 3. TX timeout timer and Remote Monitor duration (2026-10-17, code-verified flow; units inferred)

`03055A70` runs on every main-loop step (`03013940`, call at `03013C68`) while a transmission is active (`3ECE6`
bit 0) or a Remote Monitor is running (`3FD4C` bit 0). On start it loads the limit into `3ECE0+4`:

| Case | Limit (`3ECE0+4`) |
|---|---|
| normal TX | `(TX Timer − 1) × 5 + 15` from `3E9D4+0x35` (`3EA09`, Other Func **TX Timer**, block 4 `0xA0`); TX Timer 0 → no limit (bit cleared, return) |
| Remote Monitor | `3FD78` (`(block 4 0x66 + 1) × 10`, 0 → 120, `SETTINGS_CPS_ANALYSIS.md` §2), reduced to the TX Timer limit when that is set (values 1–22) and smaller |

Every 100 steps it increments `3ECE0+2`; at `limit − 3E9D4+0x37` (`3EA0B`, Other Func **TOT Predict**) it plays tone
`0x15` (the four-times repeated pattern of `AUDIO_TONES.md`); at the limit it sets `3ECE6` bit 1 (normal TX), shows popup
100 (`030130AC(1, 100)`) when `320CB` is non-zero and the channel type nibble is 0, and posts event `0x10` on `3A50C`, which ends the
transmission (inferred from the event's use as the TX stop request).

So a Remote Monitor transmission lasts at most 10–120 counts, and every transmission is cut at the TX Timer limit.
With the main-loop step at 10 ms (§2, inferred), one count is 1 s: TX Timer values give 15 s, 20 s, … and Remote
Monitor 10–120 s — consistent with the usual CPS ranges, which supports the 1 ms / 10 ms / 1 s reading of §2 (still
inferred; the timer period of `0002CABC` is not established).
