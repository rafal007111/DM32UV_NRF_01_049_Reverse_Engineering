# Emergency alarm, Man Down and Lone Worker — DM32.NRF.01.049

Static analysis, 2026-10-17 (sixth pass). No radio access, no image built, nothing hardware-verified. Inputs, hashes and
tools as in `HR_C7000_CROSSCHECK.md` §0. TX behaviour is only documented here; nothing in this project changes it.

## 1. Settings (code-verified)

| Item | Storage | Writers / readers |
|---|---|---|
| Other Func **Man Down** (setting `0x38`) | block 4 `0xA4` bit 3, RAM `3E9D4+0x31` bit 7 (`3EA05` bit 7) | `0304B158` (`0304B504…0304B54A`), boot `0304A45C`, menus `03044248`/`0304FBDC`/`03050F78`, side-key function 42 **`ManDown`** `0301596C` (toggles the setting, tones `0x18`/`0x19`, prompt) |
| Emergency system of the channel | channel `+0x0B` bits 4:0 (`SETTINGS_CPS_ANALYSIS.md` §3.2) → `0305DA8C` → alarm parameters in `3FD4C` (`+0x3F` alarm type, `+0x33`, …) | `0305DA8C`, `030149E8` |

`tools/dm32 acc 3EA05` lists every load of `3EA05`; besides the toggle, boot load and menus, the only functional readers
use bits 0–3 (light time `03013D6C`/`03054EE2`, bit 3 `0301B5F0`/`03046064`, bit 2 `0305F4D4`). **No reader of bit 7
(Man Down) drives an alarm** — no tilt/motion sensor code was found that checks the setting (inferred absence, same
method as for MOTO in `SETTINGS_CPS_ANALYSIS.md` §9.2).

## 2. Alarm state machine (code-verified writes; stage names inferred)

`3FD4C+0x1F` bits 6:3 is the alarm stage; writers: `0305DD38` (alarm start from side-key `Alarm`, reason 4,
`RX_CALL_PATH_ANALYSIS.md` §16.2: stages 3, 5, 8), `0302D148`/`0302D178` (UI loop step from `0302DBEC`: stages 4, 5, 8),
`0302CCD0`, `0305E030`/`0305E0F4`/`0305E2C0`/`0305E314`/`0305E6DC` (stages 5, 6, ending), `0305EB8C` (received-CSBK
alarm actions: stages 1, 2, 3). `0302D178` advances the stage when it differs from `+0x20` and:

- stage 2 or 3 with alarm type `+0x3F == 5` → **stage 8**, which `0302CFA0` displays as **`Man down alarm!`**
  (string pair `030BC900`: GBK `倒地报警` / English);
- otherwise by `+0x33`: 1 → sets `3FD4C` bit 7 and `+0x30` bit 0; 2 → `+0x30` bit 3 and resets `+0x31`;
- `+0x30` bit 3 counts `+0x31` up to 5 ticks, then stage 5 (`0x28`) or `0302D148`;
- stage 4 (`0x20`) counts `+6` of `3FD80` (PTR `0302D484`) to 10, then `0305E030`.

So "Man down" in this build is an **alarm type selected by the emergency system** (`+0x3F == 5`), shown when an alarm
reaches stage 2 or 3 — stages that both the alarm start `0305DD38` and the received-CSBK alarm actions `0305EB8C` write —
not an automatic fall detection.

## 3. Lone Worker (code-verified flow; field names inferred)

| Item | Evidence |
|---|---|
| Global configuration | `03065478` (boot, from `0304AFE8`; also re-run by the CPS task `0302B340`, the stun entry `0305DFDC` and key handlers `03012F74`, `03013640`, `030151D0`) reads 4 bytes of data-flash area `0x10` at offset `0xB00`: byte 0 = 1 → `40110` bit 0 (enabled); byte 1 × 60 → `40112` (response time; minutes if the tick is 1 s, inferred); byte 2 → `40116` (reminder lead time); byte 3 bits 2:0 → `40110` bits 5:3 (mode) |
| Per-channel flag | channel record `+0x08` **bit 0** (RAM `3E200` bit 0); side-key function 27 **`Work Alone`** (`03015FD4`, uncatalogued) toggles it in RAM **and in the stored channel record** (`0300F780`/`0300F878` at the record offset `+8`, or the VFO record in area `0x41`), with prompts `Lone Work ON`/`OFF` (descriptor pair `030B9448`) and tones `0x18`/`0x19`; refused (`0x21`) unless `40110` bit 0 is set and the channel is digital or mixed (`0002DED4` 1/3) |
| User activity | `030654D8` clears the counter `40114` and bits 1/2 of `40110`; called from the key handlers above |
| Timer | `030654F8`, called from the same periodic handler `0305490C` as the roaming trigger (`RX_CALL_PATH_ANALYSIS.md` §17) |

`030654F8` runs only when the current channel (or the scanned channel during scan) has the Lone Worker bit, the
feature is enabled, the radio is not stunned (`3BD6C` bit 0), no alarm is active (`3FD4C+1` bits 1:0), `0305DF8C()`
is non-zero and `3FDD9` bit 0 is clear; otherwise it resets the counter. For digital/mixed channels it increments
`40114` once per call and:

- when `40114 ≥ 40112 − 40116` (mode 0) → tone `0x25` once (reminder);
- when `40114 ≥ 40112` (mode 0): if the alarm is configured (`3FD4C+0x32 ≠ 0`) → **`03016EAC(3)`** → `0305E134(3)` → `0305DD38`, the entry
  the side-key `Alarm` uses with source 1 (`03016EB8` → `03016EAC(1)`; it cancels a running alarm via `0305E314(1)` instead), i.e. **an emergency alarm is started
  automatically** — an alarm transmits (§4, `RX_CALL_PATH_ANALYSIS.md` §16.2); otherwise tone `0x1B`;
- mode 1 (`40110` bits 5:3 = 1): after expiry, every 5 calls `03065FF0` and the siren tones `0x2E`/`0x2F` (by
  `40110` bits 7:6), until activity (inferred: local alert only).

**TX relevance:** with Lone Worker enabled on a channel and an alarm configured, the radio can start an emergency
alarm transmission by itself after the response time without a key press. Stock behaviour, documented only.

## 4. Open questions (owner) and checks without transmitting

1. Does the radio have a tilt/motion sensor at all? Code: no sensor read tied to the Man Down setting was found.
2. In CPS, which emergency-system field selects alarm type 5 ("Man Down")? (PC-only.)
3. Do not trigger the Alarm side key, and do not let a Lone Worker timer expire, for testing: an alarm transmits (channel reloaded with power level 2,
   `RX_CALL_PATH_ANALYSIS.md` §16.2).

## 5. Not reviewed

`0305DA8C` field layout beyond `+0x3F`, the stage-1…6 actions (`0305E030`, `0305E0F4`, `0305E2C0`, `0305E314`,
`0305E6DC`), alarm TX content, the Lone Worker tick period and `03065FF0`, `0305DF8C`.
