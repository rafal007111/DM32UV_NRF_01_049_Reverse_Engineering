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

## 3. Lone Worker

Other Func item 10 (`Lone Worker`) opens a submenu (`SETTINGS_CPS_ANALYSIS.md` §1.4); strings `Lone Work ON/OFF`
(`030B9440/44`) and the softkey `Work Alone` (`030BB490`). Storage and timer logic **not reviewed** in this pass.

## 4. Open questions (owner) and checks without transmitting

1. Does the radio have a tilt/motion sensor at all? Code: no sensor read tied to the Man Down setting was found.
2. In CPS, which emergency-system field selects alarm type 5 ("Man Down")? (PC-only.)
3. Do not trigger the Alarm side key for testing: an alarm transmits (channel reloaded with power level 2,
   `RX_CALL_PATH_ANALYSIS.md` §16.2).

## 5. Not reviewed

`0305DA8C` field layout beyond `+0x3F`, the stage-1…6 actions (`0305E030`, `0305E0F4`, `0305E2C0`, `0305E314`,
`0305E6DC`), alarm TX content, Lone Worker.
