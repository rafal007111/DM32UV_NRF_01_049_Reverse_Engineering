# Transmissions started without the PTT key — DM32.NRF.01.049 (summary, 2026-10-17)

Collected from the static analyses in this repository (no new code analysis; nothing hardware-verified). Each row
links the document with the code-verified evidence. TX is inferred where the path ends in a known TX routine
(`030294C8` TX queue, `0301EAC8` call start, `03029C3C` repeater wake-up, alarm start `0305DD38`). Purpose: show the
owner which stock features can key the transmitter on their own, so that RX-only tests can avoid them. This project
changes none of them.

| Trigger | What is sent | Gate / condition | Evidence |
|---|---|---|---|
| Confirmed data or text addressed to the own ID | link ACK/NACK/SACK, application reply | same CC; not on Rx Only channels for some types | `DATA_PATH_ANALYSIS.md` §6 |
| Text `"WLT CMD "` + `'1'` | GPS position message to the requester | any matching sender (same CC) | `DATA_PATH_ANALYSIS.md` §6, `GNSS_ANALYSIS.md` |
| CSBK Radio Check / Call Alert / Remote Monitor / Disable / Enable / `0x27` | ACK or NACK CSBK; Remote Monitor then **opens a transmission** to the requester | decode flags block 4 `0x65`; Rx Only channels: no ACK, but Disable/Enable/Call Alert still act | `DATA_PATH_ANALYSIS.md` §4.4, §8a |
| `UU_V_Req` (private call request) | `UU_Ans_Rsp` CSBK | to own ID | `DATA_PATH_ANALYSIS.md` §4.5 |
| FID `0x10` opcode `0x1E` | queued burst (`030297A4`) | to own ID | `DATA_PATH_ANALYSIS.md` §4.5 |
| **Roaming search** (periodic or requested) | up to 3 repeater **wake-ups** per roaming candidate whose downlink is not already received | Auto Roaming / interval (zone header), not on Rx Only channels, not while scanning | `RX_CALL_PATH_ANALYSIS.md` §17 |
| **Lone Worker timer expiry** | **emergency alarm** (same entry as the `Alarm` side key, source 3) | Lone Worker enabled (area `0x10` `0xB00`), channel record `+0x08` bit 0, alarm configured, no key press for the response time | `ALARM_ANALYSIS.md` §3 |
| Alarm in progress | alarm transmissions; channel reloaded with TX power bits forced to 2 | started by the `Alarm` side key or Lone Worker | `RX_CALL_PATH_ANALYSIS.md` §16.2, `ALARM_ANALYSIS.md` §2 |
| **GPS/APRS position beacon** (periodic) | position text message to the configured ID (`400A4`), optionally on a dedicated beacon channel | interval block 4 `0x301` × 30 ticks (≥ 30), GNSS fix or the `0x302` option, not on Rx Only channels, not while scanning | `GNSS_ANALYSIS.md` §3b |
| **VOX** (voice-operated TX) | normal voice transmission, as if PTT were pressed | Other Func VOX on (`3E9D4+0x30` bit 0), radio idle (`0305DF8C`), see below | this file §1 |
| TX admit before an own call (repeater mode) | repeater wake-up | only after PTT (listed for completeness) | `MATCH_OPTIONS_DESIGN.md` §3.6 |

Safe test practice (owner): for RX-only tests use an Rx Only channel where possible, disable Lone Worker, Auto
Roaming, VOX and the GPS beacon interval in CPS, do not send texts/CSBKs to the radio's own ID from another radio unless a reply transmission is
acceptable, and do not press `Alarm`.

Not reviewed: the DTMF/TBST paths, Remote Monitor duration (`3FD78`).

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
