# Received DMR data paths — DM32.NRF.01.049

Static analysis, 2026-10-14. Ghidra 12.1.4 PUBLIC headless, legacy CSKY v0.2 module + `32b_data.fixed.sinc`,
program `analysis/archives/DM32_NRF_049_correct_base.gzf` (SHA-256 `354f9324…`), stock image
`stock_progmem_1MiB.bin` (SHA-256 `de7dbcbc…`). Full export: 2171 functions, 0 decompile failures. Pointer literals
were resolved against the stock image (flash: offset = VA − `03000000`; IRAM source `030C0C38` → `00010000`).
Callers were cross-checked with a BSR32 scan of the whole stock image (flash + IRAM copy) and literal-pool
scans; missing function starts were found with GNU binutils 2.42 `csky-elfabiv2-objdump` and decompiled with
`DecompAt.java` in a read-only project (temporary functions only, GZF unchanged).
No hardware test was performed for anything in this file. Confidence labels follow `docs/RE_NOTES.md`.

Purpose: decide what a "CC Match off" option would do if it also accepted **data** bursts with a foreign Colour
Code. Builds on `MONITOR_ANALYSIS.md`, `TS_ANALYSIS.md` and `CC_MATCH_ANALYSIS.md`.

## 0. Summary

- Data bursts reach four handlers through the data-type jump table at `030B0548` in `03028644` (code-verified
  from disassembly `03028B72`…`03028BD4`). Every one of them except Idle compares received CC (`3C61A`) with the
  configured CC (`33CCD`) itself, with **no** Monitor bypass. CSBK, data header and PI header also require the
  baseband error bit 26 to be clear.
- Packet data is reassembled in the RX data context at RAM `3C278` and classified by `0302530C` into an event
  mask posted to event group `38330`. The task **`rxmsg`** (`0301FF9C`) consumes it, hands text to the UI
  (`0305EF88` → UI task `0302DF18`) and **transmits** link-layer ACK/NACK/SACK and application replies.
- CSBKs post events to group `3658C`. The task **`rxcsbk`** (`030209E4`) **transmits** ACK or NACK CSBKs for
  Radio Check, Call Alert, Remote Monitor, Radio Disable (stun), Radio Enable (revive) and an emergency-type
  request. After the ACK has been sent, the UI runs the action. **Stun is persistent** (`0xA5` written to data
  flash, area 4 offset `0xF00`). The task `rxvoice` (`030206D0`) **transmits** a private-call answer
  (`UU_Ans_Rsp`) when a `UU_V_Req` addressed to the radio arrives.
- A received SMS whose text starts with `"WLT CMD "` and command character `'1'` makes the radio **transmit its
  GPS position** (`$GPRMC` sentence) back to the sender.
- Accepting data with any CC would therefore let a foreign system (another repeater's users, another CC on the
  same frequency) trigger transmissions, stun the radio permanently until revived, open remote monitor, retune
  the slot (Capacity Plus rest-channel CSBK), mark the channel busy for TX admission, and store messages.
  Recommendation (§8): do **not** extend CC Match off to CSBK or to individually addressed data; at most
  allow received group text with all reply/ACK paths suppressed.

## 1. Dispatch (code-verified)

`03028644`: data sync (`status&3 == 2`) stores the received CC in `3C61A` and status bit 2 in `3C616`, then returns
unless `CC_rx == 33CCD` or Monitor flag `3BA6C` bit 3; then clears `33D7C+0x78`, rejects type > 10 and jumps:

| Type | Stub | Handler | Own CC check | Error-bit check | Monitor bypass |
|---|---|---|---|---|---|
| 0 PI Header | `03028BAC` | `03027584` | `3C61A == 33CCD` | bit 26 clear | no |
| 3 CSBK | `03028BBE` | `03027B9C` | `33CCD == 3C61A` (except CC 15 + mode 4 + CT_CSBK) | `11000390` bit 26 clear | no |
| 4/5 MBC | `03028BE2` | none (return) | — | — | — |
| 6 Data Header | `03028BC4` | `03024E7C` | `3C61A == 33CCD` | bit 26 clear | no |
| 7/8/10 Rate ½, ¾, 1 data | `03028BCA` | `03025480(type)` | `3C61A == 33CCD` | none | no |
| 9 Idle | `03028BD0` | `030275F4` | none (only the dispatcher gate) | — | dispatcher gate only |

Slot gates in `03028644` (`TS_ANALYSIS.md` §4) run before the table and are not changed by the CC checks.

## 2. Handlers

### 2.1 Data header `03024E7C` (code-verified)

- Gate: status bit 26 clear and `3C61A == 33CCD`. Sets RX activity `3BEAB` (`3BEA8+3`) = 1.
- Reads 12 bytes with `0300D41C(0, buf, 0xC)`. DPF = octet 0 bits 3:0 (ETSI TS 102 361-1 header layouts match
  field by field; protocol names inferred from that match).
- DPF `0xF` (proprietary header): no destination check; stores SAP/MFID at `3C278+7`/`+8`, appends 5 or 8 bytes
  for SAP 1/4, decrements blocks-to-follow `3C278+0xC`. Without a previously accepted header it has no effect
  on reassembly because `3C622[slot]` stays 0.
- Other DPFs: destination filter `0302768C(6, …)` (returns true = drop):
  - group (octet 0 bit 7): accept only if destination is the channel contact `33CF4` or one of the 32 RX group
    list IDs `33CF8`, and source ≠ own ID. This does **not** depend on GCall Match or Monitor.
  - individual: accept only if destination = own ID `33CEC` (`33CC8+0x24`); own-source echo only in mode 1.
- On accept: resets the slot timeout `3BEB8`; in mode 0 copies the burst slot into `3BEAA`/`3BEAC` (the slot
  used for TX admission, `TS_ANALYSIS.md` §8); stores the raw header at `3C654+12·slot`; decodes DPF 0 UDT,
  1 Response, 2 Unconfirmed, 3 Confirmed, `0xD` Defined short data, `0xE` Raw/status short data into `3C278`
  (layout §3); sets the per-slot data flag `3C622[slot]` = 1 when blocks follow; resets reassembly
  (`+0x3C`, `+0x384`, `+0x38C`, `+0x394`), and for F=1 clears the SACK bitmap `3C2B6` (`0xFF`×20).
- A Response header (DPF 1) with no blocks posts `0x80` to group `38330` (`0300C78C`).

### 2.2 Packet data `03025480(type)` (code-verified)

- Gate: `3C61A == 33CCD` and `3C622[slot] == 1` (an accepted header on the same slot). No destination check of
  its own (the header decided). Sets `3BEAB` = 1.
- Block sizes and CRC-9 masks: type 7 → 12 bytes, mask `0x0F0`; type 8 → 18 bytes, `0x1FF`; type 10 → 24 bytes,
  `0x10F` (these are the ETSI rate ½/¾/1 CRC-9 masks).
- Confirmed (`3C278+1` = 1): per-block DBSN + CRC-9 (`0300C154`); a bad block clears its bit in the SACK bitmap,
  sets the reply to class 2 (selective ACK) and error bit 0 of `+0x394`. F=0 places blocks by DBSN (resend).
- Unconfirmed: blocks appended to `3C2D2` (`3C278+0x5A`); `3C622[slot]` cleared on the last block.
- Last block: CRC-32 (`0300C224`) over the payload, compared with the trailing 4 bytes. Mismatch sets bit 1 of
  `+0x394` (confirmed path also posts the event, unconfirmed path returns silently). Payload length `3C5F4`
  (`+0x37C`) = bytes − 4 − pad (pad from `+0xA`, `+0x1A`, `+0x1D` by DPF); capped at 600 (unconfirmed path).
- Hand-off: `0302530C(3C278)` → event mask → `0300C78C(mask)` (group `38330`). Call sites `030257CC/D0`,
  `0302592A/2E`, `03025B1C/20`.

### 2.3 Payload classifier `0302530C` (code-verified, protocol names inferred)

| Condition (payload at `3C2D2`) | Event | Consumer |
|---|---|---|
| CRC-32 error (`+0x394` bit 1) | `0x800` | `rxmsg` error branch (NACK/SACK) |
| DPF 2/3, byte 0 = `0x45` (IPv4), total length > 33 | `0x1` | `rxmsg`: text message |
| DPF 2/3, `0x45`, total length = 33 (5-byte UDP payload) | `0x2` | `rxmsg`: application ACK received → `0x200` |
| DPF 2/3, byte 0 = `0x44`, bytes 3–4 ≠ 3 | `0x4` | `rxmsg`: message + reply (`03026E78`), no UI notify found |
| DPF 2/3, byte 0 = `0x44`, bytes 3–4 = 3 | `0x8` | `rxmsg`: ACK received → `0x200` |
| DPF 2/3, SAP 3, byte 0 = 0, bytes 5–6 = `"'~"` | `0x2000` | `rxmsg` → UI bit 2: position/APRS-style record |
| DPF 2/3, SAP 3, byte 2 ∈ {0,2}, bytes 3–4 = `01 01` | `0x8000` | `rxmsg`: text (SMS format 2) |
| DPF `0xD` defined short data | `0x10` | `rxmsg`: text (SMS format 0) |
| DPF `0xE` raw/status short data | `0x20` | **no waiter found** (dropped) |
| DPF 1 response | `0x80` | SMS-send transaction `0301F118`, `rxmsg` reply loop |

`0x44`/SAP 3 formats are vendor or compressed-header encodings; their names are not established (unreviewed).

### 2.4 CSBK `03027B9C` (code-verified; opcode names inferred from ETSI/MMDVM/SDRTrunk numbering)

Gate: `11000390` bit 26 clear and `33CCD == 3C61A`. Exception: if CC_rx = 15, mode 4 and FID 0 opcode 7
(CT_CSBK) → `03024908` (mode-4 channel timing; independent of the configured CC). Reads 12 bytes; sets
`3BEAB` = 1 except for FID `0x10` opcode `0x3E`. Destination filter `0302768C(3, …)` (no Monitor bypass):
FID `0x10` opcode `0x3E` always accepted; opcode `0x27` accepted for contact/group IDs (`33CF4…33D78`) with a
foreign source; all others need destination = own ID (for `0x1D`, `0x26` and `0x24` with byte 3 bit 7 clear the
target field is bytes 7–9).

| FID / opcode | Inferred meaning | Action (event to group `3658C`) |
|---|---|---|
| 0 / `0x04` | UU_V_Req (private call request) | event `0x800` → `rxvoice` transmits `UU_Ans_Rsp` |
| 0 / `0x05` | UU_Ans_Rsp | only while waiting for an own request (`3BA43` bit 0): starts own call `03029674` |
| 0 / `0x26` | NACK_Rsp | ends own pending request (`0300D0A4(5)` / `0302154C(2)`) |
| 0 / other (e.g. `0x3D` preamble) | — | no action beyond `3BEAB`=1 and timeout reset |
| `0x10` / `0x1D` | Remote Monitor request | `0x4000000` |
| `0x10` / `0x1E` | unidentified (interrupt-like) | `0x2000` → `rxvoice`: queues a terminator-type burst `030297A4(1,src)`, stops own audio path `030217A8` |
| `0x10` / `0x1F` | Call Alert | `0x2000000` |
| `0x10` / `0x20` | ACK for an own command | `0302154C(4)` (UI result) |
| `0x10` / `0x24`, byte 3 = `0x00` | Radio Check | `0x400000` |
| `0x10` / `0x24`, byte 3 = `0x7E` | Radio Enable (uninhibit) | `0x40000` |
| `0x10` / `0x24`, byte 3 = `0x7F` | Radio Disable (inhibit / stun) | `0x100000` |
| `0x10` / `0x24`, byte 3 = `0x80/0xFE/0xFF` | ACKs for own commands | `0302154C(4)` |
| `0x10` / `0x26` | NACK for an own command | `0302154C(5)` |
| `0x10` / `0x27` | emergency-type request (needs `3BA6C` bit 5) | `0x1000000` |
| `0x10` / `0x3E` | Capacity Plus rest channel (inferred) | `03023EB8`: sets slot `33CCB`/`33CCC` and `3BEAA`/`3BEAC`, may retune via `03023C10` |
| `0x10` / `0x3D` rejected by filter, mode 2 | Capacity Plus preamble (inferred) | sets slot and may retune |

`03023EB8` has no mode check on this path (code-verified); `03023C10` retunes only when the rest-channel list
`33D7C+0x70` is non-empty, but the slot fields are written in every case (code-verified). Whether a
conventional channel can meet such a CSBK in practice is inferred.

### 2.5 PI header `03027584` and Idle `030275F4` (code-verified)

- PI header: error bit clear and CC match; stores 12 bytes at `3C684+12·slot`, sets `3E344` bit 1, posts `1`
  to `3658C`; `rxvoice` compares the key/algorithm with `3F720` to enable decryption.
- Idle: no own check (dispatcher gate only); clears `3BEAB`, sets `3BEAF`, posts `0x200`, and if a voice call
  is active on the slot clears `3C620[slot]` and posts `4` (call end).

## 3. RX data context `3C278` (code-verified fields, names inferred from ETSI headers)

| Offset | Field | Offset | Field |
|---|---|---|---|
| `+0x00` | G/I (1 = group) | `+0x2C` | destination ID |
| `+0x01` | A (response requested; confirmed format) | `+0x30` | source ID |
| `+0x04` | DPF | `+0x34`/`+0x36` | message ID / last ID (duplicate filter) |
| `+0x06` | SAP | `+0x3B` | bytes per block |
| `+0x0A` | pad octets | `+0x3C` | received blocks / next DBSN |
| `+0x0B` | F (full message) | `+0x3D` | total blocks |
| `+0x0C` | blocks to follow | `+0x3E` (`3C2B6`) | 20-byte SACK bitmap |
| `+0x0E`/`+0x0F` | N(S) / FSN | `+0x5A` (`3C2D2`) | payload (≤ 600 bytes used) |
| `+0x11..13` | reply class/type/status | `+0x37C` (`3C5F4`) | payload length |
| `+0x384` | write offset | `+0x388`/`+0x38A` | CRC-9 / mask |
| `+0x38C`/`+0x390` | CRC-32 computed / received | `+0x394` | errors (bit 0 block, bit 1 CRC-32) |

There is one context for both slots; `3C622[slot]` only marks which slot owns the transfer.

## 4. Consumers

### 4.1 Tasks (code-verified)

Task table in `0300C904` (names at `03076F50`…): `txmsg` `0301FDD8`, `sysint` IRAM `0002D770`, `txslot` IRAM
`0002D620`, `rxslot` `0302386C`, `rxcsbk` `030209E4`, `rxvoice` `030206D0`, `rxmsg` `0301FF9C`, `CclTraffic`
`0301E924`, `cpchanscan` `03023B3C` (mode 2 only), `SlotTimer` `030293C8`, `record` `0302124C`, `decrypt`
IRAM `0002D324`, `encrypt` IRAM `0002D2F0`. `rxmsg`, `txmsg`, `rxcsbk` and `rxvoice` have no Ghidra function
boundary; they were decompiled with `DecompAt` at their task entry addresses.

### 4.2 `rxmsg` `0301FF9C` (code-verified)

Waits on `38330` mask `0xA81F`.

- CRC error: `03026518(1,1,…)` = NACK (A=1 path; block errors) or `03026518(2,0,…,bitmap)` = selective ACK.
  Both **transmit**.
- Events `1`/`0x2000`/`0x8000`: copies header fields to the message descriptor `3BAC0` (G/I, A, IDs, source
  `+0xC`, text offset `+0x10` = 34, length `+0x14`) and payload to `3BAD8`; notifies the UI with
  `0300D028(2,1)` (new text, duplicate message IDs suppressed) or `(2,2)` (`0x2000`). Which of `1`/`0x8000`/`0x10`
  is treated as text depends on the SMS format `3E343` (codeplug block 4 `0x65` bits 2:1; menu items H-SMS,
  M-SMS, D-SMS — mapping of values to labels inferred).
- Individual (`G/I` = 0) messages, except `0x2000`: if A = 1, wait ≤ 120 ms then `03026518(0,1,…)` = link ACK
  (**transmits**). Then an application reply `03026A14` (IP/UDP reply, `33CEA` preamble CSBKs via
  `03029B3C`, header `03025DAC`, blocks `030260C4`) is **always transmitted**: once unconfirmed, or confirmed with
  up to `33CDE` attempts (`33CC8+0x16`) when `33CE3` (`33CC8+0x1B`) = 1; retries go through `0301DF8C`
  (TX admit policy). `03026A14` switches the baseband to TX via `030294C8` → `03023290(0,2)` in mode 0.
- Event `4` (`0x44` type): same pattern with reply builder `03026E78`. Event `0x10`: text + link ACK only.
  Events `2`/`8`: application ACK received → posts `0x200` for the SMS-send transaction.

### 4.3 UI side (code-verified unless noted)

- `0305EF88` (status reader, flag byte `2F0B4+0x60C`): bit 1 → if not stunned, copies text (≤ 600) to `3FAE8`,
  then `03054564` checks for the prefix `"WLT CMD "` (`030B2438`) after the format header:
  - not a command → sets new-message flag `3E0E8` bit 6 and stores G/I in `3FD49`;
  - command `'1'` and `38C88` bit 6 (GPS enabled/valid, inferred) → `03062A54(1, src)` builds a `$GPRMC`
    sentence from current GPS data (template at `030B8654`) and sends it with `0305CD88(4, src, …)` →
    `0305D200` → **transmits** an SMS reply (blocked only on Rx Only channels or when `3E33B & 0x60`);
  - other command characters: silently ignored (not stored).
  Bit 2 (`0x2000` type) → when `3E345` bit 2 set, copies a position record to `3E940` and posts `0x4000` if the
  source equals the ID of an own pending request (`3BD38`).
- UI task loop `0302DF18`: new-message bit → `0305D764` formats the record (source + UTF-16/ASCII text) →
  `03053D74(rec, len, 1, …)` → **Inbox in data flash** (logical area 7; 100-entry ring, oldest overwritten;
  writes by `030100A8`/`0300FB58`, copy-on-write 4 KiB block writers like `0300F878`) → popup `030130AC(1,0x2E)`.
  The position bit → if `3FDE0` bit 2 (inferred: APRS Receive) → `030485B8` copies 64 bytes to RAM `3E940`,
  popup `0x2D`, and `03063EA4` draws the position with distance/bearing. Flash storage of position records was
  not found (unreviewed).

### 4.4 `rxcsbk` `030209E4` (code-verified; labels inferred)

Waits on `3658C` mask `0x7540000`. Decode enables in `3BD58` bit 0…4 come from codeplug block 4 offset `0x65`
via `0305D8C0` → `030214F0`: bit 3 → Call Alert, bit 7 → Remote Monitor, bit 6 → Disable, bit 4 → Enable,
bit 5 → Radio Check. `3BA6C` bit 1 is the **Rx Only** flag of the current channel (channel byte `+8` bit 3,
set in `03057790` via `0301EC1C`; user TX paths show the `Rx Only` prompt at `030BB214`).

| Request | Not Rx Only, decode on | Not Rx Only, decode off | Rx Only |
|---|---|---|---|
| Radio Check | **TX** CSBK `0x24/0x80` ACK | **TX** `0x26` NACK | nothing |
| Call Alert | **TX** `0x20/0x9F` ACK, then alert | **TX** NACK | alert, no TX |
| Remote Monitor | **TX** `0x20/0x9D` ACK, then remote monitor | **TX** NACK | nothing |
| Disable (stun) | **TX** `0x24/0xFF` ACK, then **stun** | **TX** NACK | **stun, no TX** |
| Enable (revive) | **TX** `0x24/0xFE` ACK, then revive | **TX** NACK | revive, no TX |
| `0x27` request (needs `3BA6C` bit 5) | **TX** `0x20/0xA7` ACK when `3BA6C` bit 6 set, then action | action, no TX (bit 6 clear) | action, no TX |

CSBKs are built by `03029878` and queued with `030294C8` (TX queue `3C810`, 50 × 36 bytes). After the queue
empties, IRAM `0002D7C8` sees `3BD59` bit 4 and calls `0302154C(6)`; the UI handler `0305EB8C` then executes:

- type 1 Call Alert: `030611F4` (alert tone/screen);
- type 2 Remote Monitor: sets `3FD4C` bit 0 and calls `0301EAC8(1, src)`, the same call-start entry used by the
  user TX paths (`0304EE0C`, `0305182C`, which check Rx Only first) → **starts a transmission to the requester**
  (inferred: open microphone);
- type 3 Disable: `0305DFDC` → stun bit `3FD4C` bit 1 and `0301EC28` (`3BA6C` bit 2), stops scan and audio, writes
  `0xA5` + data to **data flash area 4 offset `0xF00`** (`0305DFA4` → `0300F878`); restored at boot by
  `0305DF4C` (`0xA5`/`0xA6` → stunned). While stunned, `rxvoice` does not play voice and `0305EF88` ignores SMS;
  `0303B374` shows `Radio Stun`.
- type 4 Enable: if stunned, writes `0xA0` and `0305F2F4` (revive).
- type 6: emergency-type alarm display.

### 4.5 `rxvoice` `030206D0` data-related events (code-verified)

- `0x800` (UU_V_Req to own ID): `030237B8(0)` in modes 0/1, then **TX** CSBK opcode 5 (`UU_Ans_Rsp`, byte 3 =
  `0x20`) to the requester; `3BA54` = 1.
- `0x2000` (FID `0x10` opcode `0x1E` to own ID): queues a burst with `030297A4(1, src)` (**TX**), sets
  `3BA54` = 2, waits 360 ms, `030217A8` stops the local TX audio path. Meaning unidentified.

## 5. Reassembly answers

- Confirmed vs unconfirmed: `3C278+1` (header A bit) selects the confirmed block format (DBSN + CRC-9 per block).
- Block count: header `+0xC`; received count `+0x3C`; completion when count ≥ blocks-to-follow.
- CRC: CRC-9 per confirmed block (`0300C154`), CRC-32 over the payload (`0300C224`), both code-verified as
  comparisons; the polynomials were not checked.
- Hand-off: `0302530C` + `0300C78C(mask)` from `03025480`; buffer `3C2D2`, length `3C5F4`, descriptor copy at
  `3BAC0`/`3BAD8` by `rxmsg`, UI copy at `3FAE8`, Inbox record via `0305D764` at `3F026`.

## 6. Received data that makes the radio transmit (code-verified unless noted)

1. Link-layer ACK / NACK / SACK for confirmed data addressed to the own ID (`03026518`).
2. Application reply for every individually addressed text in the IPv4, SAP-3 `0x8000` and `0x44` formats
   (`03026A14`, `03026E78`), preceded by preamble CSBKs; confirmed variant retries up to `33CDE` times.
3. GPS position reply to `"WLT CMD "` + `'1'` (`03062A54` → `0305CD88`).
4. CSBK ACK or NACK to Radio Check, Call Alert, Remote Monitor, Disable, Enable and `0x27` requests (`03029878`).
5. Remote Monitor: a voice/call transmission to the requester after the ACK (inferred from `0301EAC8`).
6. `UU_Ans_Rsp` to a private call request (`UU_V_Req`).
7. Burst queued by `030297A4` on FID `0x10` opcode `0x1E`.
8. Responses to the radio's own transactions: SACK from the far end makes `0301F118` retransmit blocks
   (`0302695C`); `UU_Ans_Rsp` starts the radio's own pending call (`03029674`).

Indirect TX/PTT effects: accepted data and CSBK set RX activity `3BEAB`, which the "channel free" admit policy
reads (`030272EC`); a data header in mode 0 moves the TX admission slot `3BEAA`/`3BEAC`; FID `0x10`/`0x3E`
rewrites the TX/RX slot `33CCB`/`33CCC` and can retune; `0x1E` stops the local TX audio path.

## 7. Destination checks that would still apply

CC is the only network-level check. After it, `0302768C` still requires the own ID or a contact/RX-group-list
ID for data headers and most CSBKs (no Monitor bypass for these). The per-slot gates still apply. A foreign
system can therefore reach the radio only with traffic addressed to its own DMR ID, its contact or its RX
group list, or with the unaddressed FID `0x10`/`0x3E` CSBK. On amateur networks DMR IDs are unique and public,
so addressed traffic from a neighbouring repeater with another CC is realistic (inferred).

## 8. Risk table: "accept data with any CC"

| Kind of data | Effect if CC check removed | Transmits? | Persistent change? | Recommendation |
|---|---|---|---|---|
| Group text (DPF 2/3/`0xD`, G/I=1, contact or RX group list) | stored in Inbox, popup | no (no ACK for group) | yes, Inbox flash (100-entry ring) | acceptable if wanted |
| Individual text | Inbox + popup | **yes**: link ACK if A=1 and application reply always | Inbox flash | only with ACK/reply suppressed for foreign CC |
| Confirmed data with block errors | NACK/SACK | **yes** | no | keep CC check |
| Response packets (DPF 1), app ACKs | may complete/corrupt own SMS transaction, trigger block retransmission | **yes** (own retransmit) | no | keep CC check |
| `"WLT CMD "` + `'1'` | GPS position sent to requester | **yes** | no | keep CC check (privacy) |
| Position (`'~`, `0x2000`) | displayed, RAM `3E940` | no | not found | acceptable if wanted |
| Raw/status short data (DPF `0xE`) | event without consumer | no | no | no effect |
| `0x44` type | reply builder | **yes** (individual) | no | keep CC check |
| PI header | enables decryption for a foreign call | no | no | follow voice choice |
| CSBK Radio Check / Call Alert / Remote Monitor | ACK/NACK, alert, remote monitor TX | **yes** | no | keep CC check |
| CSBK Disable / Enable | stun or revive | **yes** (ACK/NACK); Rx Only: none | **yes**, data flash `0xF00` | keep CC check (critical) |
| CSBK UU_V_Req | private-call answer | **yes** | no | keep CC check |
| CSBK FID `0x10` `0x1E` | queued burst, own TX audio stopped | **yes** | no | keep CC check |
| CSBK FID `0x10` `0x3E` / mode-2 `0x3D` | slot change, possible retune | no direct TX; changes TX slot | runtime only | keep CC check |
| Preamble and other CSBKs | `3BEAB` busy → TX admit "channel free" may refuse PTT | no, but PTT behaviour | no | keep CC check |
| Idle | already only behind the dispatcher gate | no | no | unchanged |

Recommended design for CC Match off (inferred, not implemented):

1. Bypass CC only at the voice sites (`CC_MATCH_ANALYSIS.md`) by default.
2. If data is wanted, add a separate option that bypasses CC in `03024E7C`/`03025480` **only for group
   destinations** (G/I = 1), and remember "foreign CC" for the transfer so that `rxmsg` skips `03026518`,
   `03026A14`, `03026E78` and the `"WLT CMD"` reply for it.
3. Never bypass the CSBK CC check (`03027B9C`), and leave `03027334` (TX admit) untouched.

## 9. Open points for the owner

- Should received foreign-CC group texts be stored in the Inbox (flash) or only shown?
- Is the `"WLT CMD "` GPS poll wanted at all (it answers any matching sender with the radio's position)?
- ~~CPS names of the decode bits in block 4 `0x65`~~ resolved 2026-10-14 from NeonPlug/qdmr: bit 7 Remote Monitor Decode, 6 Radio Disable Decode, 5 Radio Check Decode, 4 Radio Enable Decode, 3 Call Alert Decode, 2:1 Data Service, 0 Missed Call Alert. **Rx Only channels execute Disable/Enable/Call Alert regardless of these flags** (CC_MATCH_DESIGN.md §5). H/M/D-SMS mapping still open.
- Owner hardware checks, all receive-side and without patches: whether CPS shows "Radio Disable decode" etc.;
  with stock firmware, send a radio check from a second radio on the same CC to confirm the ACK path; do **not**
  test Disable on the only radio (stun is persistent until an Enable is received).

## 10. Not reviewed

Update 2026-10-14: `03026E78`, `030260C4`, `0302695C`, `03029674`, `03024908`, the `0x44`/SAP-3 formats, the
event `0x8000000` consumer (TX admit `0301DF8C`), the area 7 record layout, `0305F2F4` (partly) and the `0x27`
request gating are now covered in `RX_CALL_PATH_ANALYSIS.md` §1.4 and §7. Original list:

`03026E78`, `030260C4`, `0302695C`, `03029674`, `03024908` internals; `0x44` and SAP-3 payload formats; the event
`0x8000000` consumer; flash layout of area 7 records; `0305F2F4` revive details; `0x27` request semantics.
