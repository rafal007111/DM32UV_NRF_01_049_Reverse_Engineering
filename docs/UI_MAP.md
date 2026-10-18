# UI map: scenes, menus, keys and soft keys (DM32.NRF.01.049)

Pass 3, work item P3 (2026-10-18). Static analysis only (`tools/dm32` fn/callers/callees over the pinned Ghidra
export, raw word reads of the stock image `de7dbcbc…`). No image written, no radio accessed. Labels: **code-verified**
= read in the listing; **inferred** = from table position, strings or naming only; **unreviewed** = not read.

## 1. Method

Every catalog row without a direct caller was walked up to the nearest literal pointer user and task entry
(a throw-away script in the session scratchpad, not checked in). The pointer words found that way were grouped into the
tables of §2. A handler is named **medium** in the catalog when the table entry, the string it is paired with and
the body agree; **low** when only the table position is known (most scene handlers). Scene bodies were not reviewed
beyond confirming their role (prompt rule).

## 2. Pointer tables

| Table (flash → SRAM) | Entries × size | Layout | User(s) | Status |
|---|---|---|---|---|
| `030727D0` → `18000800` | block | SRAM copy of the key/permission/side-key tables below (start-up copy) | start-up copy loop | code-verified |
| `030727D4` → `18000804` | 12 × 4 | permission callbacks, `bool f(id)` | `030140E4` (permission check used by every side key) | code-verified |
| `03072808` → `18000838` | 26 × 4 | key **press** handlers by physical key index | key task (`Keys/input`) | code-verified |
| `03072874` → `180008A4` | 24 × 4 | key **release** handlers (keys 0..23) | key task | code-verified |
| `030728DC` → `1800090C` | 43 × 4 | **side-key functions** by Key Func value; names at `030BB424` (same order as the CPS list) | `03016CF0`, `030173D4/030173E8` | code-verified |
| `030B1184` | 126 × 12 | **scene table** `{handler, 8 parameter bytes}`, index = scene number in `320CB` | task menu body `0303F9BC` | code-verified |
| `030B0C8C` | switch | list renderer `03038500` case table, index = scene − 7 (levels 7/14/21/28/35/42 draw lists) | `03038500` | code-verified |
| `030B22F0` | switch | Other Func confirm cases (`0304FBDC`, bound `cmphsi r2,22` at `0304FF9E`) | `0304FBDC` | code-verified |
| `030B8B48` … `030BCC..` | descriptors | menu list descriptor `{ptr to string array, count byte, 0x02}`; Chinese list at X, English at X+8 | renderer, list builders | code-verified (layout), strings verbatim |
| `030BA698` | 8 × 2 × 8 | soft-key label pairs (CN/EN), base + 8·language | `03019BD4` and popups | code-verified (RX_CALL_PATH §softkeys) |
| `180009B8` … | pointers | image/bitmap pointer table (status icons) | drawing layer | inferred |
| `030B237C` … | pointers | message-box handlers | popup code | inferred |
| `030594D4` | pointers | small handler table on the call-end/popup path | — | inferred, unreviewed beyond position |

## 3. Scene model

`320CB` holds the current scene; scene = 7 · screen + event. The task menu body `0303F9BC` (task entry `03040A38`)
dequeues UI key codes (`03013078`), maps them to an event of the current screen and calls the scene table handler.
Events (code-verified for the cases named, the rest inferred by column):

| Event | Meaning | Evidence |
|---|---|---|
| k0 | draw / enter the screen | column 0 handlers draw (e.g. `0303B374` home, `0303DD68` main menu) |
| k1 | up | levels 2..6 use thin wrappers to `03040B20` (list up) |
| k2 | down | levels 2..6 use thin wrappers to `03040F68` (list down) |
| k3, k4 | return to the stack top (short tail handlers) | body read for several |
| k5 | confirm / OK | L1 k5 = `scene_set(14)` |
| k6 | back | column 6 handlers pop the level |

Screens (role inferred from the k0 body and the strings it draws): L0 home, L1 main menu, L2–L9 menu levels 1..8,
L10 message/call information, L11 missed call, L12 single-handler screen (all events `0303606C`), L13 second home
variant, L14 factory/PC test, L15 info, L16 number/DTMF entry, L17 editor/list popup.

| Screen | Scenes | k0 | k1 | k2 | k3 | k4 | k5 | k6 |
|---|---|---|---|---|---|---|---|---|
| 0 | 0–6 | `0303B374` | `030394E8` | `030395C4` | `030368F4` | `030368DC` | `0303654C` | `03039A0C` |
| 1 | 7–13 | `0303DD68` | `03040F3C` | `030413A0` | `03036534` | `0303651C` | `03036510` | `030373EC` |
| 2 | 14–20 | `0303D880` | `03040F34` | `03041398` | `030364F8` | `030364E0` | `0303AB30` | `030373E4` |
| 3 | 21–27 | `0303CDA8` | `03040F00` | `03041360` | `030364C8` | `030364B0` | `0303A748` | `03037674` |
| 4 | 28–34 | `0303CB78` | `03040EF8` | `03041358` | `03036498` | `03036480` | `0303A54C` | `03037658` |
| 5 | 35–41 | `0303CB04` | `03040EF0` | `03041350` | `03036468` | `03036440` | `030363C4` | `03037628` |
| 6 | 42–48 | `0303CAB4` | `03040D7C` | `030411DC` | `030363AC` | `03036394` | `03035B8C` | `030375D0` |
| 7 | 49–55 | `0303CA54` | `03040D74` | `030411D4` | `0303637C` | `03036364` | `0303631C` | `030375B4` |
| 8 | 56–62 | `0303CA34` | `03040D6C` | `030411CC` | `030362EC` | `030362D4` | `030362A8` | `03037598` |
| 9 | 63–69 | `0303CA00` | `03040D64` | `030411C4` | `03036290` | `03036278` | `0303624C` | `030373D0` |
| 10 | 70–76 | `0303989C` | `0303737C` | `03037328` | `03036240` | `03036234` | `030370C0` | `03037078` |
| 11 | 77–83 | `03035D2C` | `03036228` | `0303621C` | `03036210` | `03036204` | `03036A20` | `03035B74` |
| 12 | 84–90 | `03036078` | `0303606C` | `0303606C` | `0303606C` | `0303606C` | `0303606C` | `03036FD0` |
| 13 | 91–97 | `030361C8` | `030394CC` | `030395A8` | `03036198` | `03036180` | `03036168` | `030360C0` |
| 14 | 98–104 | `03038034` | `03037F70` | `03037EC4` | `030360A8` | `03036090` | `03037DB0` | `03037020` |
| 15 | 105–111 | `0303C9C4` | `03036058` | `03036044` | `03036030` | `0303601C` | `03036008` | `03036FB8` |
| 16 | 112–118 | `0303C90C` | `03035FC8` | `03035F88` | `03035F7C` | `03035F70` | `03035F30` | `03035EF0` |
| 17 | 119–125 | `0303C82C` | `03035EE4` | `03035ED8` | `03035ECC` | `03035EC0` | `03036CCC` | `03036C58` |

## 4. Menu tree (English list descriptors)

Main menu `030B8DB0` (11): Talk Group | Scan | Zone | SMS | Call Log | Settings | Record | Roaming | GNSS | APRS | Bluetooth

- **Talk Group** `030B8E80`: Contact List | New Contact | Manual Dial | CSV Contacts | Talker Alias
  - Talker Alias `030B8EA0`: Alias Tx Set | Alias Rx Display; Tx `030B8EC0`: Tx With Alias | Tx Alias Form
- **Scan** `030B90B0` (9): Scan Switch | Scan List | VFO ScanRange(V) | VFO ScanRange(U) | VFO Scan Mode | Scan CTCSS | Scan DCS | Scan Memory | Hang Time
- **SMS** `030B9028`: InBox | New Msg | Quick Text | OutBox | DraftBox
- **Call Log** `030B9058`: Missed | Answered | Sent | Delete
- **GNSS** `030B8E20`: GNSS On/Off | GNSS Info | Time Zone | Disp Format | GNSS Mode (`030B8E48`: GPS | BDS | GPS + BDS)
- **Settings** `030B9120` (7): Radio Settings | Channel Set | Device Info | DTMF | BDC1200 | TWO TONE | FIVE TONE
  - **Radio Settings** `030B9480`: Voice Func | Key Func | Display Func | Other Func
    - Voice Func `030B9510` (11): Radio Silent | Battery Low | Key Tone | SMS Prompt | Group Call | Private Call | Call End | Talk Permit | StartUp Sound | Voice Prompt | Ana Roger
    - Key Func `030B95A8` (12): Key Lock | Press SK1 Short | Press SK1 Long | Press SK2 Short | Press SK2 Long | Press TK Short | Press TK Long | Press P1 Short | Press P1 Long | Press P2 Short | Press P2 Long | Long Press Time (values = side-key names of §5)
    - Display Func `030B9648` (18): Back Light | Light Time | Start Display | Start Character Edit | CallSign Color | CHG Font Color | CH Color A | CH Color B | Zone Color A | Zone Color B | Display CHL Num | CH Mode Display | Dual Watch | Language | Display DIR | LED Indicator | Menu Exit Time | Time Set
    - **Other Func** `030B9700` (CN) / `030B9708` (EN), count byte `0x16` = 22: Auto PowerOff | TX Timer | TOT Predict | VOX | VOX Delay | Talk Around | Ana MIC Gain | Digi MIC Gain | Freq Step | PowerSave | Lone Worker | Man Down | FM Radio | FM Radio Moni | Weather Alarm | TBST Sel | Tail | Ana SQL Level | SMS Format | PCall Match | GCall Match | MOTO
  - **Channel Set** `030B99A0` (22): Rx Frequency | Tx Frequency | TX Power | CTC/DCS | Tx Contact | Color Code | Time Slot | DMR ID | VFO Save To CH | Channel Type | Double Slot | Channel Name | Rx Group List | New Chan | Bandwidth | Digit Encrypt | Optional Signal | PTT ID | Rx Squelch Mode | SFT-D | Freq Offset | APRS Receive
  - Device Info `030B98E0`: Device Info | VerSions; `030B9A28`: Radio ID | Group ID | Firmware Ver: | CPS Ver: | Model Number

Zone, Record, Roaming, APRS and Bluetooth open their own list screens (data lists, not fixed descriptors). The
factory/test menu (Chinese only, `030B8B58` … `030B8D30`: power, deviation, squelch, BER, battery calibration) is
reached from L14. All 315 descriptors are listed in the session scratchpad `menus.txt`; the strings are verbatim
from the image.

## 5. Side keys (Key Func values, table `030728DC` → `1800090C`, names `030BB424`)

Every handler starts with the permission check `030140E4(id)` (callbacks of §6) and ends with `03021C1C` (redraw) or a
refusal tone. Handler role from the name + body agreement (medium) or name only (low); see the catalog.

| Value | Name | Handler | Main callees |
|---|---|---|---|
| 0 | None | `03015538` | `03021C1C` |
| 1 | Tx Power | `030162D0` | `030140E4`, `030603DC`, `0304C434` |
| 2 | BATT Indicator | `03015C58` | `030140E4`, `03065FF0`, `03021C60` |
| 3 | Talk Around | `030161A0` | `0002DF30`, `030140E4`, `03064C9C` |
| 4 | Digital Encrypt | `03015E08` | `0002DED4`, `0002DED4`, `03021C1C` |
| 5 | Call | `0301552C` | `03021C1C` |
| 6 | Vox | `03015D78` | `030140E4`, `030603DC`, `03021C1C` |
| 7 | VFO/MR | `03016734` | `030140E4`, `0301340C`, `0304B158` |
| 8 | Alarm | `03016EB8` | `0305E314` |
| 9 | Hot Key 1 | `03017170` | `03017084` |
| 10 | Hot Key 2 | `03017164` | `03017084` |
| 11 | Hot Key 3 | `03017158` | `03017084` |
| 12 | Hot Key 4 | `0301714C` | `03017084` |
| 13 | Hot Key 5 | `03017140` | `03017084` |
| 14 | Message | `03015880` | `030140E4`, `030130AC`, `03021C1C` |
| 15 | Contact | `03017074` |  |
| 16 | Zone Up | `03017250` | `03017188` |
| 17 | Zone Down | `03017244` | `03017188` |
| 18 | Scan | `03016FCC` | `03016EDC` |
| 19 | Record Switch | `03015B70` | `030140E4`, `03021C1C`, `0306224C` |
| 20 | Previous Record | `030173AC` | `03017278`, `03021C1C` |
| 21 | Next Record | `03017370` | `03017278`, `03021C1C` |
| 22 | FM Radio | `03016440` | `030140E4`, `03064C9C`, `03021C1C` |
| 23 | FM Search | `030163BC` | `030140E4`, `03021C1C` |
| 24 | GPS Info | `030157B8` | `030140E4`, `0300F780`, `030130AC` |
| 25 | Monitor | `03017560` | `03064C9C`, `0302ED04`, `030649A8` |
| 26 | A/B Switch | `03015544` | `03021C1C`, `030130AC` |
| 27 | Work Alone | `03015FD4` | `0002DED4`, `0002DED4`, `03021C1C` |
| 28 | KeyPad Lock | `03016224` | `030140E4`, `030603DC`, `03021C1C` |
| 29 | Nuisance Delete | `03015A38` | `030140E4`, `0302ECE0`, `0302F2F8` |
| 30 | TBST Send | `03015A7C` | `030140E4`, `0302E0CC`, `03064C9C` |
| 31 | APRS Send | `0301571C` | `0302ED04`, `0302ECE0`, `03021C1C` |
| 32 | Switch ChType | `03015CC0` | `0301ED00`, `0302E0CC`, `030140E4` |
| 33 | Wait Mode | `03016688` | `030140E4`, `0301340C`, `0300F780` |
| 34 | CTC/DCS Scan | `03016580` | `030140E4`, `0300E3B4`, `03021C1C` |
| 35 | CTC/DCS Set | `03015900` | `030140E4`, `030130AC`, `03021C1C` |
| 36 | Mute | `03016354` | `030140E4`, `030603DC`, `0304C434` |
| 37 | Roaming | `0301560C` | `0302ED04`, `0302ECE0`, `03021C1C` |
| 38 | Sub PTT | `03015AC8` | `030140E4`, `03021C1C`, `0304735C` |
| 39 | Scramb | `03015520` | `03021C1C` |
| 40 | Freq Search | `030164BC` | `0302ECE0`, `03021C1C`, `0002DED4` |
| 41 | Flashlight | `03015514` | `03021C1C` |
| 42 | ManDown | `0301596C` | `030140E4`, `03021C1C`, `030603DC` |

## 6. Physical keys, programmable keys and permission callbacks

Press table `03072808` → `18000838` (26) and release table `03072874` → `180008A4` (24). UI codes are posted with
`post_key(2, code)` into the queue read by `0303F9BC`.

| Key | Press | Release | Role |
|---|---|---|---|
| 0 | `03014E38` | `03014DEC` | PTT (press `03014E38` = PTT gates of TX_PATHS.md; release `03014DEC` → `03014DD8(…)`) |
| 1 | `03014184` | `03014314` | posts UI code 1 (OK/Menu key, inferred) |
| 2 | `03014958` | `03014450` | programmable key (release via `03016CF0`); the press handler also holds the factory-reset key combination (`030323F4`) and posts UI code 5 |
| 3 | `03014870` | `03014588` | programmable key (side-key wrapper `030173D4`/`030173E8`, Keypad-Lock guard `03035B54`) |
| 4 | `03014178` | `030142F0` | posts a UI code (`03014178`) |
| 5 | `03014904` | `03014264` | restart/power key (`0305F2F4` when allowed), UI code 6 |
| 6 | `030147DC` | `03014514` | programmable key |
| 7 | `030149A4` | `030142CC` | beep, tone and UI code 1 (`030149A4`) |
| 8 | `030146C4` | `030143D4` | programmable key |
| 9 | `0301473C` | `03014488` | programmable key (no long-press table entry used) |
| 10 | `03014190` | `030142A8` | posts UI codes incl. 24 |
| 11 | `0301464C` | `03014338` | programmable key |
| 12 | `03014160` | `03014210` | UI code 18 (up, inferred) |
| 13 | `03014148` | `030141D8` | UI code 19 (down, inferred) |
| 14 | `03014D20` | `03014DCC` | digit key, UI code 5 (`03014CA8`) |
| 15 | `03014D14` | `03014DC0` | digit key, UI code 6 (`03014CA8`) |
| 16 | `03014D08` | `03014DB4` | digit key, UI code 7 (`03014CA8`) |
| 17 | `03014CFC` | `03014DA8` | digit key, UI code 8 (`03014CA8`) |
| 18 | `03014CF0` | `03014D9C` | digit key, UI code 9 (`03014CA8`) |
| 19 | `03014CE4` | `03014D90` | digit key, UI code 10 (`03014CA8`) |
| 20 | `03014CD8` | `03014D84` | digit key, UI code 11 (`03014CA8`) |
| 21 | `03014CCC` | `03014D78` | digit key, UI code 12 (`03014CA8`) |
| 22 | `03014CC0` | `03014D6C` | digit key, UI code 13 (`03014CA8`) |
| 23 | `03014CB4` | `03014D50` | digit key, UI code 14 (`03014CA8`) |
| 24 | `03014130` | — | UI code 23 |
| 25 | `030145FC` | — | UI codes 6/1 by call display (`030145FC`) |

Programmable keys: press `03016CD4` stores the assigned side-key value in `3931D`, sets state `3931E = 3` and starts
the long-press timer `39328`; release `03016CF0` stops the timer and, for a short press, runs table `1800090C`
entry `3931D`. Long press runs the long assignment from the timer callback (inferred). The Key Func menu names five keys
(SK1, SK2, TK, P1, P2) with short/long entries; six key indices (2, 3, 6, 8, 9, 11) use the programmable path, key 9
without a long-press entry. Which physical key is which name is **inferred only** — owner observation needed.

Owner report (2026-10-18, hardware-verified by the owner, names only): **SK1** and **SK2** are the programmable
side keys; **P1** and **P2** are the programmable left and right keys of the main D-pad, whose up and down
positions are the navigation keys (consistent with keys 12/13 = UI codes 18/19, still inferred). Each of these four
keys can be assigned a short-press and a separate long-press function in CPS. The owner does not know what **TK**
is. The owner had P1 short = Zone Down and P2 short = Zone Up assigned in CPS (values 17 and 16 of §5); not
compared with the owner's codeplug bytes, which are not in the repository.

**Key index → name (2026-10-18, code-verified).** The press handlers pass a key code to `03016CD4`, which stores it
in `3931D`; the short-press release `03016CF0` and the long-press timer callback `03016864` map that code to a slot
of `392F4`, and the slots are filled from block 4 by `030168CC` (boot) and `0304B158` (menu save):

| Key index | Press handler | Key code | Name | Short slot / block 4 | Long slot / block 4 |
|---|---|---|---|---|---|
| 3 | `03014870` | 30 | SK1 (side key) | `392F4+0x14` / `0x87` (setting `0x47`) | `392F4+0x00` / `0x88` (`0x4C`) |
| 6 | `030147DC` | 29 | SK2 (side key) | `+0x18` / `0x89` (`0x48`) | `+0x04` / `0x8A` (`0x4D`) |
| 9 | `0301473C` | 31 | TK | `+0x1C` / `0x8B` (`0x4B`) | `+0x08` / `0x8C` (`0x50`) |
| 8 | `030146C4` | 21 | P1 (D-pad left) | `+0x20` / `0x8D` (`0x49`) | `+0x0C` / `0x8E` (`0x4E`) |
| 11 | `0301464C` | 22 | P2 (D-pad right) | `+0x24` / `0x8F` (`0x4A`) | `+0x10` / `0x90` (`0x4F`) |
| 2 | `03014958` | 5 | not programmable | fixed `030155EC` (UI code 5, or factory reset `030323F4` when `3FDDA` bit 2) | fixed `03015570` |

So the long-press slots 0–4 and short-press slots 5–9 are both in the order SK1, SK2, TK, P1, P2. Key 9 is **TK**:
the firmware reads a key input for it and has short/long slots, but the owner does not know a TK key on this radio
(possibly a key that only some hardware variants have; not established). The earlier note that key 9 uses no
long-press entry is superseded: TK has a long-press slot like the others. The physical side (left/right, which
side key is SK1) of the names comes from the owner report above; the index mapping is code-verified.

Owner photo (2026-10-18, hardware-verified by the owner): the front panel has OK/menu, a D-pad (up, P1 = left,
P2 = right, down), Home/back, digits 0–9, `*` (lock) and `#`; together with PTT and the side keys SK1/SK2 there is
**no top key and no other key that could be TK** on the owner's DM32UV. Key index 9 (TK) is firmware support for a
hardware variant; a TK assignment in CPS has no physical key on this radio (inferred from the photo plus the code).
Which index is Home/back, `*` and `#` is not established (candidates: keys 2, 4, 10, 24, 25).

Permission callbacks (`030727D4` → `18000804`, called by `030140E4`):

| Index | Handler |
|---|---|
| 0 | `03013E78` |
| 1 | `03013E9C` |
| 2 | `03013EC0` |
| 3 | `03014030` |
| 4 | `03013F00` |
| 5 | `03013F18` |
| 6 | `03013FAC` |
| 7 | `03013F40` |
| 8 | `03013F54` |
| 9 | `03013F58` |
| 10 | `03013F64` |
| 11 | `03013FD0` |

Callback 0 (`03013E78`) refuses ids 7/8 by the alarm state `3FD4D` bits 1:0 (code-verified); the rest are low.

## 7. Soft keys

`03019BD4` draws the soft-key bar: left label at x 12 from the pair table `030BA698` (OK, CANCEL, Del, Option, Send;
base + 8 · language), right label `"BACK"` at x 180 (`03019C60`). The `Digit Monitor` and `Ignore?` pairs have no
reference in this build (RX_CALL_PATH_ANALYSIS.md). Soft-key presses arrive as ordinary UI codes (keys 1 and 7 →
code 1 = OK/Menu, k6 = back); there is no separate soft-key handler table. Code-verified for the drawing, inferred
for the key binding.

## 8. TS/CC Match insertion points (Other Func entries 22/23, after MOTO)

The new items are indices 22 (`TS Match`) and 23 (`CC Match`); MOTO stays at 21. Every place that knows the
Other Func count or index must move together:

| Site | What it does | Change needed |
|---|---|---|
| `030B9700` / `030B9708` | CN / EN descriptor, count byte `0x16` (`030B9704`, `030B970C`) | point to arrays with 24 entries, count `0x18` (the `other_cn`/`other_en` arrays in `firmware/source/menu_tables.c` already append `ts_match_label`/`cc_match_label`) |
| `03038500` + 0x544 | list renderer case for the Other Func level (switch `030B0C8C`) | reads the descriptor; value column for 22/23 must be added |
| `03043164` + 0xEA | descriptor user (list position/scroll) | follows the count byte |
| `03048F50` + 0x10C / + 0x14C / + 0x2BC | descriptor users (value text per item) | add value text for 22/23 |
| `03049498` | visible-list builder (hides items by model/setting) | include 22/23 |
| `0304B158` | setting id table/getter per item; `0304C434` getter | map 22/23 to the new setting bytes |
| `0304FBDC` | confirm handler, case table `030B22F0`, bound `cmphsi r2,22` at `0304FF9E` | bound 24 and two new cases (or a hook before the bound check) |

Everything here is code-verified as a user of the descriptor or of the bound; the exact change per site is a design
proposal for MATCH_OPTIONS_DESIGN.md and has not been built or tested. No image was written.

## 9. Catalog rows named in P3

181 rows (1 high, 25 medium, 155 low): 87 menu/UI scene handlers, 3 menu framework, 10 key input, 6 side-key
workers, 10 interrupt handlers, 16 unreached code, 6 start-up, and smaller groups (recording/privacy, periodic,
call display, LED, RF, SD card). The SD-card write `030674F0` is the only high row (dormant). Evidence string:
"manual review 2026-10-18 (pass 3 P3, handler tables)".

## 10. Open questions and owner observations (screen-only, no TX)

1. Names answered by the owner on 2026-10-18 (§6): SK1/SK2 = side keys, P1/P2 = D-pad left/right, each with short
   and long press; TK unknown to the owner. Key indices resolved statically the same day (§6 table: SK1 = 3,
   SK2 = 6, TK = 9, P1 = 8, P2 = 11; key 2 is a fixed key). Still open: whether a physical TK key exists on this
   model: the owner's photo shows none (§6), so TK (key 9) has no physical key on this radio. Still open: the
   indices of Home/back, `*` and `#` (candidates 2, 4, 10, 24, 25). No CPS write is needed for the mapping.
2. Screen roles L12, L13, L15, L17 are inferred; open each screen and note its title.
3. Keys 4, 10, 24, 25 post UI codes whose meaning is inferred.
4. Left unreviewed: scene handler bodies (by rule), the image pointer table at `180009B8`, `030594D4`.
