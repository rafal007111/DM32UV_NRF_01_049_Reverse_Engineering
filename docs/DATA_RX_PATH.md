# Receive path for DMR data and text messages — DM32.NRF.01.049

Static analysis, 2026-10-18 (unattended). Stock image `analysis/inputs/stock_progmem_1MiB.bin`
(SHA-256 `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0`, checked), GZF
`354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d` (checked), GNU objdump 2.42 for `csky-elfabiv2`,
`tools/dm32` (`fn`, `acc`, `callers`, `decomp` = Ghidra 12.1.4 + legacy CSKY v0.2 with sinc fix 3), literal pools
read from the image. No serial port was opened, no radio was accessed, no CPS word was sent and no image file was
written. **Nothing in this file is hardware-verified.** Labels: code-verified / inferred / unreviewed as in
`RE_NOTES.md`; "absence" results are from `tools/dm32 acc` constant tracking plus reading the named functions, so
they are inferred unless stated otherwise.

Question from the owner: "I have never received a data packet or a text message. Are messages accepted only when the
DMR ID matches?" Short answer: **yes for private messages** (destination must be the channel's selected Radio ID),
**and group messages are accepted only for the talkgroups in the channel's RX group list (or its TX contact)** —
GCall Match off does not open the group filter for data. In addition the **SMS Format** menu item (H-SMS / M-SMS /
D-SMS) decides which one of three wire formats is shown at all; a message in another format is dropped silently
(an individually addressed one is still answered in two of the formats). This file builds on
`DATA_PATH_ANALYSIS.md` (§1–§6 are not repeated) and corrects it in §7.

## 1. The chain, gate by gate (D1)

Channel offsets `+0xNN` are offsets into the channel **body** = the RAM working copy `3E1F8` (record byte `0x10 + NN`,
`CHANNEL_RECORD.md` §1).

Every gate below must pass. "Drop" means the message is lost without any indication on the radio.

| # | Stage / site | Exact condition (code-verified unless marked) | On failure |
|---|---|---|---|
| G1 | Channel is digital | channel byte `+0x08` bits 7:4 = 1 (`03056330`); `sysint` calls `030239D4` only while `33CC8[0] == 0` (digital) | no DMR reception at all |
| G2 | DMR RX not suspended | `3BA6D` bits 0/4 clear (`03028644`/`03028BE4` return otherwise; bit 0 set during channel load `030584E4`) | burst ignored |
| G3 | Baseband frame interrupt | `SYS_INTERP_LIST` bit 3 → `03028644` (`HR_C7000_CROSSCHECK.md` §1) | — |
| G4 | Slot gates in `03028644` (`TS_ANALYSIS.md` §4) | **repeater / BS-sourced** bursts (status bits 3:2 = 1): only the programmed slot (`3BEA8 == 33CCC`, channel `+0x0D` bit 4) after slot lock; **simplex / MS-sourced** (bits 3:2 = 0): any slot unless the other slot has a voice call or data transfer active (`3C620`/`3C622[other]`); DCDM (mode 4): `3BEA8 == 3BEAA` | drop |
| G5 | Colour Code | dispatcher: `3C61A` (received CC) `== 33CCD` (channel `+0x0D` bits 3:0) **or** Monitor `3BA6C` bit 3; then the data header `03024E7C` and the block handler `03025480` compare `3C61A == 33CCD` again **without** Monitor bypass | drop |
| G6 | Data type | type 6 (data header) → `03024E7C`; types 7/8/10 (rate ½ / ¾ / 1 blocks) → `03025480(type)`; 4/5 (MBC) ignored; type > 10 rejected (`030B0548` table) | drop |
| G7 | Header error bit | `03024E7C`: `3BECC` bit 26 clear (no Monitor bypass); the block handler has no error-bit test | drop |
| G8 | Header class (DPF, octet 0 bits 3:0) | DPF `0xF` (proprietary) is parsed but never opens a transfer; DPF 0 UDT, 1 Response, 2 Unconfirmed, 3 Confirmed, `0xD` Defined short data, `0xE` Raw/status short data are decoded into `3C278`; other DPF values reach the classifier with an unset context and produce no event | DPF 0, 4–12, `0xF`: no text |
| G9 | **Destination filter** `0302768C(6, …)` (listing `030277F2…03027860`) | **group** (octet 0 bit 7 = 1): destination ∈ the 33 words `33CF4…33D77` = the channel's **RX group list** (32 entries, area `0xF`, channel `+0x0F` bits 5:0) **plus the TX contact** `33D74`, **and** source ≠ own ID. **individual**: destination == own ID `33CEC`; if also source == own ID it is dropped only in mode 1 (repeater). No test of GCall/PCall Match (`3BA6D` bits 1/2), Monitor (`3BA6C` bit 3), all-call IDs (`FFFFFx`) or Rx Only | drop |
| G10 | Transfer opens | `3C622[slot] = 1` only when blocks-to-follow ≠ 0; reassembly counters reset; F = 1 clears the SACK bitmap | — |
| G11 | Blocks | `03025480`: same CC (G5) and `3C622[slot] == 1` (header accepted on the same slot); no destination test of its own. Unconfirmed: blocks are appended in arrival order (no sequence check); confirmed: per-block DBSN + CRC-9 (`0300C154`), bad block → selective-ACK state | — |
| G12 | Partial transfer timeout | the global burst-loss timer `3BEB8` (`RX_CALL_PATH_ANALYSIS.md` §2): ≥ 13 TDMA ticks (≈ 390 ms, inferred tick) without any accepted burst → `03023394` full reset including `3C622`; also cleared by a data terminator (`03028180`), DCDM timing (`03024908`), a rest-channel change (`03027388`), channel change (`03029318`) | transfer lost, no indication |
| G13 | Last block CRC-32 (`0300C224`) | unconfirmed: mismatch → `+0x394` bit 1 and **return without event** (silent drop); confirmed: mismatch → event `0x800` → `rxmsg` **transmits** NACK / SACK | unconfirmed: silent drop |
| G14 | Length | payload length `3C5F4` = bytes − 4 − pad (pad by DPF: `+0x0A`, `+0x1A`>>3, `+0x1D`>>1); unconfirmed path caps it at 600; no bound on the **write** offset (see §6, risk R3) | — |
| G15 | **Classifier** `0302530C` (§2) | payload format → one event bit on group `38330`; unknown format → 0 (no event) | silent drop |
| G16 | **SMS Format** in `rxmsg` `0301FF9C` | `3E343` = block 4 `0x65` bits 2:1 (0 H-SMS, 1 M-SMS, 2 D-SMS; §3): event `1` (IPv4) only with M-SMS, `0x8000` (SAP-3) only with D-SMS, `0x10` (DPF `0xD`) only with H-SMS; `0x2000` (position) and `4` (`0x44` format) in every format | text not shown; see G19 for replies |
| G17 | Text length / duplicate | events `1`/`0x8000`: shown only when `3C5F4 ≤ 600` and the message id (`+0x34`) differs from the last one (`+0x36`); event `0x10`: shown when length < 600 and (first payload halfword = 0 **or** the flag `30E0E` is clear; `30E0E` is set by the shown message and cleared after 250 main-loop steps by `0300D284`) | text dropped (but G19 still runs) |
| G18 | UI reader `0305EF88` (task `psint`, status `2F0B4+0x60C` bit 1) | not stunned (`0305DF8C`); copy ≤ 600 bytes to `3FAE8` (M-SMS from `3C2F4` = payload + 34, others from `3C2D2`); prefix `"WLT CMD "` after the format header (offset 2 / 4 / 5 for H / M / D) → command, **not stored** (`'1'` + GPS → position reply, **transmits**) | stunned: ignored; `WLT CMD`: not stored |
| G19 | Automatic replies in `rxmsg` | individual (G/I = 0) messages of an accepted format: link ACK if A = 1 (`03026518`), then **application reply always** for events `1`/`0x8000`/`4` (`03026A14` / `03026E78`); event `0x10`: link ACK only. **No Rx Only test** on this path (§6) | — (these transmit) |
| G20 | CallDisp task `0302DF18` | waits for `3FDB0` bit 12; processing is **deferred** while `3E33B` bit 7 is set (cleared by the tone engine `03022410`, set elsewhere; inferred "tone/prompt active"); new-message bit `3E0E8` bit 6 → backlight on (`0304A3FC`), FM radio paused (`03065FD8`), `0305D764` formats, `03053D74(rec, len, 1, fmt = 3E1DC bits 7:6)` **stores in the Inbox** (area 7), key code `0x2E` → menu task | — |
| G21 | Inbox store `03053D74` | 100-slot ring: when full the **oldest record is replaced** and the "InBox full" flag (`+1` bit 5 of the message status byte) is set; no condition prevents storing | never drops |
| G22 | Notification (menu task `0303F9BC`, key code `0x2E` → `030408CC`) | no call display (`3E0E5 == 0`): popup scene 70 **"Msg Received"** (`0303989C`) and the SMS tone; during a call display: tone only, no popup. Tone = `030397E0(33)` → tone `0x26` with parameter `3EA1D`, only if **SMS Prompt** (`3EA17` bit 0) and `40110` bit 2 clear (no writer of that bit found); the tone engine drops it under **Radio Silent** (`AUDIO_TONES.md` §1) | message stored silently |

Diagram (simplified):

```
HR_C7000 frame IRQ ─► 030239D4 ─► 03028644 ─(G4 slot, G5 CC/Monitor)─► type table 030B0548
   type 6 ─► 03024E7C (G5 CC, G7 err bit, G9 dst filter 0302768C(6)) ─► 3C278 + 3C622[slot]=1
   type 7/8/10 ─► 03025480 (G5 CC, G11 3C622) ─► last block: CRC-32 (G13) ─► 0302530C (G15) ─► event 38330
                                                                     timeout 3BEB8 ≥ 13 ticks (G12) ─► reset
 rxmsg 0301FF9C: SMS Format 3E343 (G16), len/dup (G17) ─► 0300D028(2,1) ──► psint 0305EF88 (G18 stun, WLT CMD)
        └─ individual: link ACK 03026518 + reply 03026A14/03026E78 (G19, TRANSMITS)
 CallDisp 0302DF18 (G20) ─► 0305D764 ─► 03053D74 Inbox area 7 (G21) ─► key 0x2E ─► "Msg Received" + tone (G22)
```

## 2. Payload formats the classifier recognises (`0302530C`, code-verified tests; names inferred)

Payload byte `p[i]` = `3C2D2 + i` (= RX context `+0x5A`).

| Event | DPF / SAP | Test | Message id / extra | Meaning (inferred) | Shown with |
|---|---|---|---|---|---|
| `0x800` | any | `+0x394` bit 1 (CRC-32 error, confirmed only reaches here) | — | error → NACK/SACK | — |
| `0x1` | DPF 2/3, any SAP | `p[0] = 0x45` and IPv4 total length `p[2..3]` ≥ 34 | id = IPv4 identification `p[4..5]`; `+0x38` = `p[31..32]` | **Motorola TMS over IPv4/UDP** — the radio's own sender (`03025BC0`) uses UDP ports 4007/4007 (`0x0FA7`), IP `12.x.x.x` / `225.x.x.x`; the receiver checks **no** IP address, protocol or port, so any IPv4 datagram ≥ 34 bytes (e.g. LRRP/ARS) is treated as text | M-SMS |
| `0x2` | DPF 2/3 | `p[0] = 0x45`, total length = 33 (5-byte UDP payload) | as above | TMS acknowledgement → `0x200` to the own send transaction | — |
| `0x4` | DPF 2/3 | `p[0] = 0x44`, `p[3..4]` ≥ 4 | id `p[2]` | vendor `0x44` message (`RX_CALL_PATH_ANALYSIS.md` §7.6) | **never shown** (no UI notify in `rxmsg`); replied to if individual |
| `0x8` | DPF 2/3 | `p[0] = 0x44`, `p[3..4]` = 3 | — | `0x44` acknowledgement | — |
| `0x2000` | DPF 2/3, SAP 3 | `p[0] = 0`, `p[5..6] = 27 7E` (`'~`) | — | position / APRS-style record | all formats; display needs channel `+0x1A` bit 2 (DMR APRS RX) and `3FDE0` bit 2 |
| `0x8000` | DPF 2/3, SAP 3 | `p[2] ∈ {0, 2}`, `p[3] = 1`, `p[4] = 1` | id `p[0..1]` | **ETSI TS 102 361-3 UDP/IPv4 header compression** (DMR Association standard text) | D-SMS |
| `0x10` | DPF `0xD` | none (SAP and the Defined-Data format field `+0x1B` are **never read**) | id `p[4..5]` | defined short data | H-SMS |
| `0x20` | DPF `0xE` | none | — | raw/status short data | no waiter (dropped) |
| `0x80` | DPF 1 | — | — | response packet (own send) | — |
| 0 | DPF 0 (UDT), 4–12, `0xF`; DPF 2/3 with an unknown first byte or SAP ≠ 3; `0x44` with length 0–2; IPv4 shorter than 33 | — | — | — | silently dropped |

### 2.1 Text layout and encodings (code-verified in `0305D764`, `03054564`, `03020684`; RX and the radio's own TX builder `0305D39C` agree)

| SMS Format | Wire header before the text | Text encoding read | Text offset |
|---|---|---|---|
| H-SMS (0) | `00 00` (skipped only if `p[0] = 0`) | UTF-16 **little-endian** | 2 |
| M-SMS (1) | after IPv4 (20) + UDP (8) + 6 bytes: `0D 00 0A 00` (CR LF in UTF-16LE; skipped only if present) | UTF-16 **little-endian** | 34 + 4 |
| D-SMS (2) | 5 bytes: message id (2), `02` or `00`, `01`, `01` | UTF-16 **big-endian** | 5 |

- A code unit with a zero high byte is stored as one byte (ASCII, and also `0x80–0xFF`, which the GB2312 display then
  pairs with the next byte — inferred mojibake for ISO-8859-1 accents).
- Other code units are converted **Unicode → GB2312** by `0301104C` (two-level table at `03079278`/`030793A4`,
  binary search `03010FF4`); an unmapped character becomes `00 00`, which **terminates the stored text** there
  (code-verified write of two zero bytes; truncation of the display inferred from the NUL).
- There is no UTF-8, 7-bit packed, BCD or ISO-8859 decoder on this path; the ETSI Defined-Data format field is ignored.
- Length: at most 600 payload bytes reach the UI (≈ 300 UTF-16 characters; the manual's 128-character limit is the
  editor's). The Inbox record is `0x110` bytes with a one-byte length (§6, R4).

## 3. SMS Format mapping (code-verified; resolves the open item of `DATA_PATH_ANALYSIS.md` §9)

- Menu Other Func item 18 `SMS Format` uses the list descriptor `030BC8A8` = `{030BC89C, 3 items}` with the strings
  `H-SMS` (`030C06B8`), `M-SMS` (`030C06C0`), `D-SMS` (`030C06C8`) in that order; the submenu opener preselects
  index = `3E343` (`03044F30…03044F50`), and the apply case `0x45` in `0304B158` stores index 0 → 0, 1 → 1, else 2.
- Boot `0305D8C0`: `3E343 = (block 4 0x65 >> 1) & 3`, value 3 is forced to 2 (D-SMS); also copied to `33CEB` by
  `0301E82C`.
- **Block 4 `0x65` bits 2:1: 0 = H-SMS, 1 = M-SMS, 2 (and 3) = D-SMS.** Labels from the menu strings; the protocol
  names (Hytera / Motorola / DMR Association) are the manual's (§7.6, "SMS Format").
- The same value selects the **send** format (`03026BB8`: M-SMS → DPF 3/2 with IPv4/UDP, SAP 4; D-SMS → SAP 3 with
  the 5-byte header; H-SMS → DPF `0xD`, SAP 10), so two DM32UVs exchange texts only with the same SMS Format.

## 4. Other message kinds

- **CSBK** (`rxcsbk` `030209E4`, `DATA_PATH_ANALYSIS.md` §2.4, §4.4): no text or status message is carried by CSBK in
  this firmware. Call Alert is the only CSBK the user sees as a "message" (alert screen `030611F4`), gated by the
  Call Alert decode flag (block 4 `0x65` bit 3) — and on Rx Only channels executed regardless. A Call Alert to the
  own ID is answered with an ACK CSBK (transmits) on normal channels.
- **GNSS/APRS positions**: same data chain up to the classifier (event `0x2000`, SAP 3, `'~` marker); displayed by
  `030485B8` when the channel's DMR-APRS-RX bit (`+0x1A` bit 2) is set and `3FDE0` bit 2 is set; while an own
  position request is pending (`3E345` bit 2, set by the user request paths `0304EE0C`/`030507BC`/`0305182C`) the
  record goes to `3E940` instead (`0305EF88`). `GNSS_ANALYSIS.md` covers the rest.

## 5. Settings that gate reception (D2)

| Setting | Storage | CPS / menu name | Effect on data RX | Confidence |
|---|---|---|---|---|
| Channel type | channel `+0x08` bits 7:4 | Channel Type (Digital) | G1 | code-verified |
| Colour Code | channel `+0x0D` bits 3:0 → `33CCD` | Color Code | G5 (Monitor helps only the dispatcher gate, not the data handlers) | code-verified |
| Time Slot | channel `+0x0D` bit 4 → `33CCC` | Time Slot | G4 for repeater (BS-sourced) traffic only | code-verified |
| Double Slot (DCDM) | channel `+0x0D` bit 5 → mode 4 | Double Slot | G4 (mode-4 slot rule); also sends CT_CSBKs by itself (`AUTONOMOUS_TX.md`) | code-verified |
| RX Group List | channel `+0x0F` bits 5:0 → area `0xF` → `33CF4…33D73` | RX Group List | **G9 for group data**: 0 = no list (only the TX contact is accepted) | code-verified |
| TX contact | contact number of channel n: 2 bytes at `(n−1)·2` of area `0x42` (n < 2048, else area `0x43`), value `(b0 >> 4) << 8 | b1` (`030565F4` → `03056410`, working copy `+0x31`) → 24-byte contact record (`030332E0`); its ID is copied to `3F020` → `33D74` **only when the contact record byte `+0x16` = 4**, else 0 (`03058240…03058264`, digital channels) | Contact / TX Contact | G9 (accepted as an extra group destination) | code-verified condition; meaning of type 4 not established |
| Radio ID | channel `+0x1B` (record byte `0x2B`, DMR ID index n) → area `0x67` offset `(n+1)·0x10`, 3 bytes LE → `33CEC`; 0 or > `0xFFFCDF` → **ID 1** (`03057654`) | Radio ID (per channel) | **G9 for private data**: the own ID is per channel | code-verified |
| Rx Only | channel `+0x08` bit 3 → `3BA6C` bit 1 | Rx Only | **no effect on data RX and does not stop the ACK/reply transmissions of G19** (inferred absence) | inferred |
| Privacy / encryption | channel `+0x0F` bit 6, `+0x0E`, `+0x0C` | Encryption | no effect on data (no data decryption; encrypted payloads would be unrecognised) | inferred (absence: no `3F72x` access on the data path) |
| Data ACK / Private Call ACK | channel `+0x1D` bits 6/7 (qdmr names) | Data ACK, Private Call ACK (if CPS shows them) | **no reader in the firmware**: replies are not configurable | inferred (absence) |
| DMR APRS RX | channel `+0x1A` bit 2 | APRS receive (qdmr `rxDMRAPRS`) | position records only | code-verified |
| SMS Format | block 4 `0x65` bits 2:1 → `3E343` | SMS Format (H/M/D-SMS); NeonPlug calls the field "Data Service" | **G16** | code-verified |
| SMS Prompt | block 4 `0x20` bit 5 → `3EA17` bit 0 | SMS Prompt | tone only (G22) | code-verified |
| Radio Silent | block 4 `0x20` bit 7 | Radio Silent | tone only | code-verified (`AUDIO_TONES.md`) |
| GCall Match / PCall Match | block 4 `0x60` bits 1/0 → `3BA6D` bits 2/1 | GroupCall / PrivateCall Match | **no effect on data** (voice only) | code-verified |
| Monitor (digital) | `3BA6C` bit 3 | Monitor key | dispatcher CC gate only; not the data handlers or the filter | code-verified |
| Decode flags | block 4 `0x65` bits 7:3 | Remote Monitor / Disable / Radio Check / Enable / Call Alert Decode | CSBK only | code-verified |
| Power Save | block 4 `0xA4` (setting `0x5A`) | PowerSave | the manual warns messages may be missed; effect on the DMR receiver not traced | unreviewed |
| Scan | — | — | a data header must pass G4–G9 on the channel the scanner is parked on; once `3C622` is set the scanner busy test `0302ED04` → `0301ED00` holds the channel | code-verified call; behaviour inferred |

Reply-related state (not gates): `33CE3` (confirmed replies) follows the own last send (`0301EBB0` from `0305D200`);
`33CDE` = 3 retries; `33CEA` = preamble CSBK count (`0301E824`, boot).

## 6. Findings and risks (code-verified unless marked)

- R1 — **Private messages make the radio transmit even on an Rx Only channel**: `rxmsg` and its TX builders
  (`03026518`, `03026A14`, `03026E78`, `03025DAC`, `030260C4`, `030294C8`) read no Rx Only flag (constant tracking:
  no access to `3BA6C`/`3E200`); retries go through the TX admit `0301DF8C`, which has no Rx Only test
  (`TX_PATHS.md`). Inferred absence; closes the `TX_PATHS.md` §7 open item "callers' Rx Only handling in `rxmsg`".
- R2 — Under M-SMS any IPv4 datagram ≥ 34 bytes is a "text" (no port test), and an individual one is answered with a
  TMS-style reply; LRRP/ARS traffic addressed to the radio would appear as garbage text.
- R3 — `03025480` appends blocks at `+0x5A + offset` without bounding the offset against the 802-byte area
  (`+0x5A…+0x37B`); a header announcing many blocks (up to 127 for DPF 2/3) can write past the payload buffer into
  `+0x37C…` and beyond (length, CRC and error fields, then other RAM). Same-CC, correctly addressed traffic is
  needed. Effect beyond the context not traced (inferred risk).
- R4 — Inbox records are `0x110` bytes with a one-byte length; `0305D764` can return up to ~604 bytes for a 600-byte
  payload; whether `030100A8` writes past the record for long texts was not traced (unreviewed risk).
- R5 — The UI copies the text from the live RX context (`3C2D2`/`3C2F4`), not from the `rxmsg` copy `3BAD8`; a new
  transfer that starts before `psint` runs can overwrite it (inferred race).
- Correction to `DATA_PATH_ANALYSIS.md` §2.1: an individually addressed header whose source is the own ID is
  dropped **only in mode 1** and accepted otherwise (listing `03027834…0302783E`, `mvcv`), not "accepted only in mode 1".

## 7. "Why does nothing arrive?" checklist (D3), most likely first

| # | Condition | Code site | What to check | Symptom |
|---|---|---|---|---|
| 1 | **SMS Format does not match the sender's format** | G16 `rxmsg` `0301FF9C` | radio menu Settings → Radio Settings → Other Func → SMS Format (block 4 `0x65` bits 2:1); match the sender (Motorola-style IPv4/TMS → M-SMS; DMR-standard compressed UDP → D-SMS; defined short data → H-SMS) | nothing at all (private: the sender may even get no reply) |
| 2 | **Group text to a talkgroup that is not in the channel's RX Group List** (and not the TX contact) | G9 `0302768C(6)` | channel's RX Group List (`+0x0F`) contains the TG; GCall Match off does **not** help | nothing |
| 3 | **Private text addressed to a different ID than the channel's Radio ID** | G9, `03057654` | channel's Radio ID (`+0x1B` → area `0x67`); an empty or invalid entry makes the ID **1** | nothing (and no reply) |
| 4 | Network / repeater / hotspot does not forward data, or forwards it on another slot (inferred) | G4 | repeater/hotspot data support; BrandMeister and similar networks deliver SMS as **private data to the DMR ID** and may let the user choose the format (inferred); on a repeater only the channel's Time Slot is received | nothing |
| 5 | Wrong Colour Code or slot on the channel | G4, G5 | CC and TS equal the repeater's; Monitor does not help for data | nothing (voice may still be heard with Monitor) |
| 6 | Sender uses a format the firmware does not show at all: `0x44` vendor format, UDT, raw/status short data, proprietary DPF, encrypted data | G8, G15, G16 | sender's message type/encryption | nothing (individual `0x44`: radio still replies) |
| 7 | Transfer broken: missed block (unconfirmed → CRC-32 fail), gap ≥ ≈ 390 ms, scanning away, interfering voice on the other slot (simplex) | G11–G13, G4 | signal level; stop scanning; use a quiet channel | nothing |
| 8 | Duplicate suppression: the sender repeats the same message id (`+0x34`) | G17 | change text/restart sender | first copy only |
| 9 | Text starts with `WLT CMD ` | G18 | — | not stored (command `1` sends the GPS position back) |
| 10 | Radio stunned | G18 | `Radio Stun` on screen | texts ignored |
| 11 | Message arrived but went unnoticed: SMS Prompt off / Radio Silent on, during a call display only a tone, popup closed | G22 | Inbox (Menu → SMS → InBox) | stored, no popup/tone |
| 12 | Unmappable characters (emoji etc.) or ISO-8859 accents | §2.1 | — | text cut short or garbled |

## 8. Owner tests (stock firmware, cheapest and safest first)

Rules from `AUTONOMOUS_TX.md` apply. Each test says whether the DM32UV under test can transmit. Group texts
**never** cause an ACK or reply (G19 is for G/I = 0 only).

| # | Test | Can transmit | Expected result (code) |
|---|---|---|---|
| T1 | Read-only: on the radio, note SMS Format, and for the test channel its RX Group List, Radio ID, CC, TS, Double Slot | no | — |
| T2 | Second radio (any brand), **simplex**, same frequency/CC, sends a **group** text to a TG that is in the DM32UV channel's RX Group List; repeat with the sender in each of its formats and the DM32UV set to H-SMS, M-SMS and D-SMS in turn (9 combinations). Use a non-DCDM channel | **no** (group; but note the DCDM CT_CSBK and roaming rules of `AUTONOMOUS_TX.md`) | "Msg Received" + tone and an Inbox entry **only** where formats match: Motorola-style IPv4/UDP ↔ M-SMS, DMR-standard compressed UDP (SAP 3) ↔ D-SMS, defined short data ↔ H-SMS; all other combinations: nothing |
| T3 | As T2 but to a TG **not** in the RX Group List and not the TX contact | no | nothing (even with GCall Match off) |
| T4 | Two DM32UVs, same SMS Format, group text | sender yes, receiver **no** | received; with different SMS Formats: nothing |
| T5 | Private text to the channel's Radio ID | **yes**: link ACK (if the sender asks for one) and an application reply, **also on an Rx Only channel** (R1) | shown and stored; sender reports delivery |
| T6 | Private text to another ID | no | nothing |
| T7 | Text with an emoji in the middle (group) | no | text ends before the emoji |
| T8 | Network (BrandMeister or similar) private SMS to the DMR ID, trying the network's format options | **yes** (as T5) | shown only in the format matching SMS Format; requires repeater/hotspot data forwarding (inferred) |

Do not send `WLT CMD 1` (position reply) unless a transmission is acceptable. Do not test with CSBK commands.

## 9. Offline codeplug checks (if the owner provides a CPS file later)

Logical areas are located in a raw data-flash image by the **area id in the last byte (`0xFFF`) of each 4 KiB
sector** (`CPS_PROTOCOL.md` §4.2); how a given CPS file maps to raw sectors is PC-software dependent.

| Item | Where | Check |
|---|---|---|
| SMS Format | area 4, byte `0x65` bits 2:1 | 0 H-SMS, 1 M-SMS, 2/3 D-SMS |
| SMS Prompt / Radio Silent | area 4, byte `0x20` bits 5 / 7 | tone only |
| GCall/PCall Match | area 4, byte `0x60` bits 1/0 | irrelevant for data |
| Channel record n | area `0x12` (+ following), body at `record + 0x10` (`CHANNEL_RECORD.md` §1) | body `+0x08` bits 7:4 = 1 (digital), bit 3 Rx Only; `+0x0D` bits 3:0 CC, bit 4 TS, bit 5 Double Slot; `+0x0F` bits 5:0 RX group list index; `+0x1B` Radio ID index |
| Channel → TX contact | area `0x42` (channels < 2048), 2 bytes at `(n−1)·2`, 12-bit contact number | points to the intended contact |
| Radio IDs | area `0x67`, record `(n+1)·0x10`, 3 bytes little-endian | the ID the sender addresses; not 0 |
| RX group list k | area `0xF`, `(k−1)·0x6D + 0x1C`, 32 × 3 bytes | contains the talkgroup |
| TX contact | contact areas `0x43…` (24-byte records), byte `+0x16` = 4 and ID at `+0x13..+0x15` | only then accepted as a group destination |

## 10. Open questions (owner) and items left unreviewed

Open questions:
1. Which format does the sending radio or network use (Motorola TMS/IPv4, DMR-standard SAP 3, defined short data)?
2. Does the CPS show "Data ACK"/"Private Call ACK" (record `+0x1D` bits 6/7)? The firmware ignores them.
3. Should a future mod suppress private-message replies on Rx Only channels (R1)? Design decision for the owner.
4. Meaning of contact type byte `+0x16` = 4 (TX contact accepted as group destination only then).

Not reviewed: the `0x44` format's origin; whether `030100A8` bounds long Inbox records (R4); the effect of R3 beyond the
RX context; Power Save's effect on the DMR receiver; `3E33B` bit 7 setter; `3FDE0` bit 2 source (`0305F308`);
`40110` bit 2 (no writer found); the `psint` gate before `0305EF88`; the position display path beyond
`DATA_PATH_ANALYSIS.md` §4.3.
