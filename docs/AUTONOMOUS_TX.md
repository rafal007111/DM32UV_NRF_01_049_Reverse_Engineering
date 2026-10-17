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
| TX admit before an own call (repeater mode) | repeater wake-up | only after PTT (listed for completeness) | `MATCH_OPTIONS_DESIGN.md` §3.6 |

Safe test practice (owner): for RX-only tests use an Rx Only channel where possible, disable Lone Worker and Auto
Roaming in CPS, do not send texts/CSBKs to the radio's own ID from another radio unless a reply transmission is
acceptable, and do not press `Alarm`.

Not reviewed: VOX (voice-operated TX), the DTMF/TBST paths, APRS/GPS beacon timers (`GPS Beacon` string, no timer
traced), Remote Monitor duration (`3FD78`).
