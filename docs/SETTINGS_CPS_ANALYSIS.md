# Radio settings menus, settings storage, CPS protocol and RF chip — DM32.NRF.01.049

Static analysis, 2026-10-14 (second pass, unattended). Same inputs and tools as `RX_CALL_PATH_ANALYSIS.md` §0
(stock `de7dbcbc…`, installed `156a4872…`, GZF `354f9324…`, Ghidra 12.1.4 + legacy CSKY v0.2 with sinc fix 3,
GNU objdump 2.42). No radio or serial access; nothing here is hardware-verified.

Purpose: know where a future **TS Match** / **CC Match** option could live (menu, RAM flag, data-flash bit) and what
CPS does with the same bytes, without changing CPS/codeplug compatibility.

## 1. Menu → setting id → storage

Method (code-verified): the `Radio Settings` confirm handler `0304FBDC` selects the submenu by
`3E6A5[3E50B+2]` (0 Voice, 1 Key, 2 Display, 3 Other) and the item by `3E6C8[3E50C+2]`, then jumps through
tables `030B2254` (11), `030B2280` (12), `030B22A8` (18), `030B22F0` (22). Item order equals the English
string lists found by scanning menu descriptors (`{table, 0x2NN}` pairs, `030B94DC`, `030B9570`, `030B95F8`,
`030B96A8`). Each case was read in objdump; the value written is the selected list index `3E5EC`.
"block 4" = data-flash area 4 (general settings), RAM mirror `3E9D4+x` written as `3EA..`.

### 1.1 Voice Func (`030B94DC`)

| # | Item | Action | Storage |
|---|---|---|---|
| 0 | Radio Silent | setting `0x10` | block 4 `0x20` bit 7, `3EA15` |
| 1 | Battery Low | `0304CCA0(9, v)` | block 4 `0x21` bit 6, `3EA18` bit 0 |
| 2 | Key Tone | `0304CCA0(0, v)` | `0x20` bit 6, `3EA16` |
| 3 | SMS Prompt | `0304CCA0(1, v)` | `0x20` bit 5, `3EA17` bit 0 |
| 4 | **Group Call** | `0304CCA0(2, v)` | `0x20` bit 4, `3EA17` bit 1 → call-start tone `0x23` (`0305E3F0`) |
| 5 | **Private Call** | `0304CCA0(3, v)` | `0x20` bit 3, `3EA17` bit 2 → call-start tone `0x25` |
| 6 | Call End | `0304CCA0(4, v)` | `0x20` bit 2, `3EA17` bit 3 |
| 7 | Talk Permit | `0304CCA0(5, v)` | `0x20` bit 1, `3EA17` bit 4 |
| 8 | StartUp Sound | `0304CCA0(7, v)` | `0x20` bit 0, `3EA17` bit 6 |
| 9 | Voice Prompt | `0304CCA0(6, v)` | `0x21` bit 7, `3EA17` bit 5 |
| 10 | Ana Roger | setting `0x2A` | `0x21` bits, `3EA18` |

`0304CCA0` stores the inverse of the list index (`v ^ 1`), i.e. index 0 = on (inferred from the list order
`ON`/`OFF` used by these items). Rows 1–9 are code-verified bit positions; exact bit for row 10 not checked.

### 1.2 Key Func (`030B9570`)

Index 0 `Key Lock` opens a prompt. Indices 1–11 (SK1 Short, SK1 Long, SK2 Short, SK2 Long, TK Short, TK Long,
P1 Short, P1 Long, P2 Short, P2 Long, Long Press Time) → settings `0x47`, `0x4C`, `0x48`, `0x4D`, `0x4B`,
`0x50`, `0x49`, `0x4E`, `0x4A`, `0x4F`, `0x51` (code-verified). The side-key function bytes are block 4
`0x87..0x90` (read by `030168CC`, `MONITOR_ANALYSIS.md` §1).

### 1.3 Display Func (`030B95F8`)

| # | Item | Setting / storage |
|---|---|---|
| 0 | Back Light | `0x31` → block 4 `0x30`, `3EA29` |
| 1 | Light Time | `0x2D` → `0x31`, `3EA0E` |
| 2 | Start Display | `0x41` → `0x00`, `3EA08` |
| 3 | Start Character Edit | editor scene |
| 4–9 | CallSign / CHG Font / CH A / CH B / Zone A / Zone B colour | direct writes, e.g. CallSign Color → block 4 `0x34`, `3EA36` |
| 10 | Display CHL Num | no write found in the case |
| 11 | CH Mode Display | `0x43` → `0x80`, `3EA01` |
| 12 | Dual Watch | block 4 `0x80` bits 7:6, `3EA40`, `03064960` |
| 13 | Language | `7` → `0xA4` |
| 14 | Display DIR | `3EA41` bit 0, `03017884` |
| 15 | LED Indicator | `8` → `0xA4` |
| 16 | Menu Exit Time | block 4 `0x32`, `3EA2D`; `3E3B3 = 5·v` |
| 17 | Time Set | scene |

### 1.4 Other Func (`030B96A8`) — the menu that holds PCall/GCall Match

| # | Item | Setting / storage | Note |
|---|---|---|---|
| 0 | Auto PowerOff | `0x5F` → block 4 `0x1E`, `3EA42` | |
| 1 | TX Timer | `3` → `0xA0`, `3EA09` | TX-related; read-only subject |
| 2 | TOT Predict | block 4 `0xA1`, `3EA0B` | |
| 3 | VOX | submenu | |
| 4 | VOX Delay | block 4 `0xA3`, `3EA33` | |
| 5 | Talk Around | `030566CC(0)`, tone `0x19` | |
| 6 | Ana MIC Gain | `0x55` → `0xA6` | |
| 7 | Digi MIC Gain | `0x54` → `0xA7` | |
| 8 | Freq Step | `0x42` → `03030E80`, `3EA03` | |
| 9 | PowerSave | `0x5A` → `0xA4` | |
| 10 | Lone Worker | submenu | |
| 11 | Man Down | `0x38` → `0xA4` | |
| 12 | FM Radio | `03065F58` | |
| 13 | FM Radio Moni | block 4 `0x700` bit 3, `40138` bit 3 | |
| 14 | Weather Alarm | block 4 `0xA4` bit 2, `3EA41` bit 2 | |
| 15 | TBST Sel | block 4 `0xA5` bits 5:4, `3EA41` bits 4:3 | |
| 16 | Tail | block 4 `0xA5` bits 1:0 from `3E22C` bits 3:2 | |
| 17 | Ana SQL Level | `0300DE8C(v)` | |
| 18 | SMS Format | `0x45` → `0x65` bits 2:1, `3E343` | |
| 19 | **PCall Match** | `9` → `0x60` bit 0, `3EA06` bit 5 → `3BA6D` bit 1 | |
| 20 | **GCall Match** | `10` → `0x60` bit 1, `3EA06` bit 6 → `3BA6D` bit 2 | |
| 21 | MOTO | block 4 `0x85` bit 4, `3EA05` bit 6 | **no reader found**; boot load `0304A45C` reads `0x85` bits 0–3 only |

The Other-menu descriptors are `030B9700` (Chinese list) and `030B9708` (English list, count `0x16`). The
generic Scan Zone candidate replaces `030B9700`; the installed image keeps it stock (`REPRODUCIBILITY.md`). A TS/CC Match item would be entries 22/23
of this list plus two new cases after `030501DE` (inferred design; the case table `030B22F0` and the
`cmphsi r2, 22` bound at `0304FF9E` would have to change).

## 2. Block 4 bytes `0x60..0x67` and free bits (code-verified readers)

| Offset | Readers | Use |
|---|---|---|
| `0x60` | `0304B010` (boot), `0304B158` settings 9/10 (read-modify-write) | bits 0/1 PCall/GCall Match; **bits 2–7: no reader in firmware** |
| `0x61`–`0x64` | `0304B010` | `RX_CALL_PATH_ANALYSIS.md` §8.1 |
| `0x65` | `0305D8C0`, `0304B158` (`0x45`) | bit 3 Call Alert decode, bit 7 Remote Monitor, bit 6 Disable, bit 5 Radio Check, bit 4 Enable (`030214F0(n, on)`), bits 2:1 SMS format `3E343`, bit 0 → `3EA43` bit 0 |
| `0x66` | `0305D8C0` | `3FD78`; `3FD78 = (v+1)·10` (0..11), else 10; 0 → 120 (remote-monitor duration in s, inferred) |
| `0x67` | `0304A45C`, `030610EC` | unreviewed |

Runtime flag byte `3BA6D` (`3BA54+0x19`): bit 0 DMR RX suspended (`0301E8A8(0)` from channel-load
`030584E4`, cleared by `0301E8A8(1)`), bit 1 PCall Match, bit 2 GCall Match, bit 3 own command pending
(`0301EAE8`/`0301F118`), bit 4 set by `0301EC34` (callers `03061E04`, `03061F5E`; blocks RX together with bit 0 in
`03028644`/`03028BE4`); **bits 5–7: no reader found** (all decompiled accesses use masks 1, 2, 4, 8, `0x10`, `0x11`).

Design note (inferred, nothing built): block 4 `0x60` bits 2/3 and `3BA6D` bits 5/6 are the least invasive
places for persistent "TS Match" / "CC Match" flags, mirroring how settings 9/10 work (`0304B158` →
`0301ECF0`). Before using them the owner must confirm with CPS (read only) that CPS keeps unknown bits of
`0x60` unchanged when it writes a codeplug; CPS writes raw 4 KiB sectors (§3), so a CPS that writes 0 there
would silently reset the options but would not break anything else.

## 3. CPS USB protocol (frame loop `03029FB0`/`0302A448`, task `usb` entry `0302B340`; code-verified)

Entry handshake words at `030B08AC` (`PROGRAM`, `PON-PIC`, `PSEARCH` → answer `DP570UV`, `PASSSTA`,
`PASWORD`, `PCTESTM`, `RTCITEM`, `DEL-RCD`, `IDCHECK`, `SYSINFO`) with handlers at `030B0860`; password check in
`0302B224`. Inside a session, receive timeout 2000 ms (`0x72D9` = timeout status):

| Frame (host → radio) | Meaning | Radio action / answer |
|---|---|---|
| `FF FF FF FF x` | end of session | frame loop returns (after `PROGRAM`: restart) |
| `FF FF hh ll x` | address `0xFF000 | hh<<8 | ll` is computed, one more byte is read, then the command byte (`FF`) matches neither `S` nor `G` and the task returns | code-verified path `0302A432`; purpose unclear |
| `56 a1 a2 a3 n` (`'V'`) | info item `n ≤ 0x40`, address must be 0 except `n = 0x0D` | `56 n len data…`: 1 `DM32.NRF.01.049`, 2 12-byte value from `0305FB7C` + xor/or mix, 3 `2022_06_27`, 4 `D1 01.01.004`, 5 `R1 00.01.001`, 11 `C1 00.01.001`, 6–10/14/15 two words each from `030AEAB0..030AEAE8` (inferred band limits), 13 copies `a3` bytes from base `*030AEAF4` + `a1a2` (memory read window), 16 `50 C3 00` (50000) |
| `43 a1 a2 a3 n` + `n` bytes (`'C'`) | write `n` bytes | `03010DB8(0x10C, buf, n)`, answer `06` |
| `53 a1 a2 a3 lo hi` + data (`'S'`) | write `len = hi:lo` bytes at `a1<<12 | a2<<8 | a3` | erase the 4 KiB sector first when the address is sector-aligned (`0002C0FC`), program with `0002C164`, answer `06` |
| `47 a1 a2 a3 lo hi` (`'G'`) | read `len` bytes | `03010DDC(addr, buf, len)`, answer `53 …` header + data |

Address composition is code-verified at `0302A036..0302A044` (`a1<<12 | a2<<8 | a3`; `a2` is presumably
< `0x10`). Writes go straight to SPI flash sectors: CPS overwrites whole codeplug sectors, which is why a firmware
option stored in a codeplug byte depends on CPS preserving it (§2). **Never exercise this from an agent.**

### 3.1 Handshake layer (task loop `0302B340`, created via the pointer at `0302A104`; code-verified)

The loop reads 7-byte words with a 500 ms timeout. While a session flag (`3FDD8` bit 6) is set, a timeout calls
`03029F80` (clears UI timers) and `0305F2F4` (restart). Recognised words (only when exactly 7 bytes arrived):

| Word | Radio action | Answer |
|---|---|---|
| `PROGRAM` / `PON-PIC` | sets session flags (`3FDD8` bit 6, `3FDDC` bit 3), clears `40110` bit 0, stops RF/audio (`0002B634`, `0301E4D0(0)`, `0002B364`, `0002C83C`), runs `0302A448`, then **restart** `0305F2F4` | `0302A448`: `06`, waits for `02`, answers 8 × `FF`, waits for `06`, answers `06`, then the same `V`/`C`/`S`/`G` frame loop as §3 |
| `PSEARCH` | session flags | `06 "DP570UV"` (8 bytes; model identifier) |
| `PASSSTA` | session flags; reads block 4 `0x439` (2 bytes) | `50 xx yy` (password status, inferred) |
| `PASWORD` | `06`, then `0302B224` (10-byte `P`,`W`/`R`, 8-byte password vs block 4 `0x43B`/`0x443`) | `06` / `15` |
| `PCTESTM` | `06`, then `0302AA58` (test-mode state reset, clears `3BE68`…) | `06` |
| `RTCITEM` | `06`, then `0302A9A8` (RTC item, unreviewed) | `06` |
| `DEL-RCD` | `06`, `03010B40` erases the recording sector range `3FFEC..3FFF4` and `3FFE0..3FFF8`, writes `0xA5` markers, then **restart** | `06` |
| `IDCHECK` | session flags | `06` |
| `SYSINFO` | session flags, `06`, then **`03029FB0`** (frame loop without the `02`/`FF` exchange and without a restart at the end) | per frame |
| anything else | `03029F80`; restart if a session was open | — |

So a CPS **write** session is `PROGRAM` (… frames …) and always ends in a restart, while `SYSINFO` gives the same
read/write frame access without restarting. `DEL-RCD` and `PROGRAM` are the only words that erase or rewrite
flash besides the `S`/`C` frames. Read-only documentation; never send these from an agent.

### 3.2 Channel record (0x30 bytes in data flash, RAM copy `3E1F8`, 0x33 bytes) — loader `03057790`

Record location: `03055CCC` (`RX_CALL_PATH_ANALYSIS.md` §6). The loader reads 0x20 bytes, converts the two
frequencies with `0305F904(…, 4)` (BCD, inferred) and copies bytes `+0x08..+0x1F` unchanged. Bit uses below are
code-verified in `03057790`, `03056330`, `0305DA8C` and the menu writers; names are inferred unless a menu string
confirms them.

| Byte | Bits | Use |
|---|---|---|
| `+0x00..+0x03` | | RX frequency (10 Hz units after conversion) |
| `+0x04..+0x07` | | TX frequency; forced to RX when `+0x0A` bit 3 is set or the radio state `3E335 == 0x10` (talkaround), unless `+0x0A` bit 7 |
| `+0x08` | 7:4 | channel type: 0 analog, 1 digital, 2/3 mixed types (setting `'D'`, menu `Channel Type`) |
| `+0x08` | 3 | Rx Only (`0301EC1C` → `3BA6C` bit 1); forced on, with type 0, for frequencies in the AM window |
| `+0x08` | 2:1 | forced to `2` when the channel is loaded with mode argument 4 (unreviewed) |
| `+0x0A` | 7 | set by the loader when RX == TX (simplex) |
| `+0x0A` | 6:4 | **TX admit policy** → `33CD0` (`MATCH_OPTIONS_DESIGN.md` §3.6) |
| `+0x0A` | 3 | talkaround (TX := RX), inferred |
| `+0x0B` | 7 | emergency alarm (`0x27`) accept → `3BA6C` bit 5; bit 6 ACK → `3BA6C` bit 6 (cleared when bit 7 is 0); bits 4:0 emergency system index 1–15 (`0305DA8C`) |
| `+0x0C` | 3:2 | value 1 with digital type 1/3 enables privacy TX (`4009C` bit 0) using key slot `+0x10` (0–7) from block 4 `(slot+400)·2` (`Digit Encrypt`, inferred) |
| `+0x0D` | 3:0 | Colour Code (`0301E7BC`) |
| `+0x0D` | 4 / 5 | Time Slot / Double Slot (`RX_CALL_PATH_ANALYSIS.md` §6) |
| `+0x0F` | 5:0 | passed to `030562C4` (unreviewed) |
| `+0x16` | 6:4 | analog RX squelch/tone type (`03060A74`) |
| `+0x1B` | | DMR ID list index → own ID (`03057654`, `0301E798`) |

None of the bits proposed for TS/CC Match live in the channel record; a per-channel option would need an unused
bit here **and** CPS support, which is why `MATCH_OPTIONS_DESIGN.md` proposes global settings instead.

## 4. RF transceiver identity (strong inference)

`0002C2F8(reg, val16)` / `0002C340(reg)` drive a 3-wire bus (GPIO `7`, `0x18`; read sets `reg | 0x80`).
Register use matches the Beken **BK4819** map (as documented by open UV-K5 firmware projects; design reference
only): `0x38`/`0x39` 32-bit frequency in 10 Hz units (`0002B56C`; `0300D84C` compares with `14400000` = 144 MHz),
`0x67 & 0x1FF` RSSI (`0300EBB0`), `0x68`–`0x6A` CTCSS/CDCSS scan results, `0x47` AF output select, `0x48` AF gain,
`0x51` sub-audio, `0x58`–`0x5F` FSK, `0x70`–`0x72` tone generators, `0x30` enable. Consequences:

- Analog Monitor writes `0x47` bits 11:8 = 1 (normal FM AF) — "AF unmute" is now a strong inference.
- The alternative value `0x6740` (bits 11:8 = 7) is used when `3E345` bit 5 is set; `0300D84C` sets that bit only
  when the frequency lies in the window `3848C+0x20 .. 3848C+0x24`. In the BK4819 map AF type 7 is AM, so this is
  the **AM airband receive** path (inferred).
- `3E337` bit 6 (which makes `0301742C` refuse analog Monitor) is set by `0300D84C` when the frequency is outside
  both TX band windows `3848C+0..4` and `+8..0xC` (code-verified condition; "RX-only frequency" inferred).

## 5. Other items closed in this pass

| Item | Finding | Confidence |
|---|---|---|
| `0305F2F4` | Called after the CPS session ends (`0302B224`, 4 sites) and after the data-area reset in `030323F4` (`0305407C(1/3/5)` then `0305F2F4` at `0303312E`); writes `1100005C = 0x01000000` (boot `0002BB9C` sets `0x01000001` after SPI-flash status setup) and `11000000 = 0xFFFFFE7F` | strong inference: **system restart** |
| Message areas | `03053D74`/`0305407C` kind 1 → area 7 **InBox** (counter `18000AA8`), kind 3 → area 8 **OutBox** (`18000AB0`; caller `0305D34C` after a send), kind 5 → area 9 **DraftBox** (`18000AB8`; callers are the Save actions `0304DB58`, `0304F7B8`, `030507BC`, `03050D2C`, `030523EC`, `030526A8`) | code-verified callers; names from menu strings |
| `030297A4(mode, id)` | queues a **Terminator with LC** burst (TX entry type 2) on TX slot `3BEAC`: mode 0 copies the own LC (`3C71C`), mode 1 builds LC bytes 0–1 from `3C6F0`, byte 2 `0x10`, source = `id`; clears `3C620/3C622[slot]` and `3C6FC[slot]` | code-verified (TX) |
| `03023EB8` | rest-channel follow: LSN = byte 2 bits 4:0 → slot `(LSN+1)&1`, channel `(LSN+1)>>1` in list `33D7C` (12-byte entries, count `+0x70`); same channel → slot lock + event `0x8000000`; else `03023C10` retunes (`0300C3A8(rx, tx)`) and resets RX (`03023394`). Later CSBKs go through `03023D24` and are ignored while `33CDD` is set | code-verified; Capacity Plus inferred |
| Status bit 17 / event `0x4000` | in `03028BE4` a set bit 17 makes the embedded block be copied to the PI-header store `3C685+12·slot` (unless a PI header was already received, `3E344` bit 1) and posts `0x4000`, which `rxvoice` only clears; in `03028644` voice burst 5 copies bit 17 to `3C619` | code-verified; "embedded privacy parameters" inferred |
| `3C62A[slot]` | last embedded LC service-options byte; used with list `3C7A4` and `03029C78` for FID `0x10` services | partly reviewed |
| `Digit Monitor` softkey (`030BF168`) | descriptor at `030BA6F0` has no direct literal reference | unresolved |

## 6. Owner questions and RX-only checks

1. CPS (read only): does CPS show options matching block 4 `0x60` bits 2–7 or `0x85` bit 4 ("MOTO")? Read a
   codeplug, toggle PCall Match on the radio, read again and compare byte `0x60` of area 4 in the CPS file.
2. Does the radio receive AM on airband frequencies (§4)? RX-only: listen to an airband ATIS in VFO mode.
3. After a CPS write, does the radio restart by itself (§5, `0305F2F4`)?

## 7. Not reviewed

Exact bit for Ana Roger; Display colour storage offsets beyond CallSign Color; `03065F58` FM radio;
`0300DE8C` squelch level; `03029C78` and the `3C7A4` service list; `03023D24`; CPS handshake handlers at
`030B0860`; `Digit Monitor` softkey use.

## 8. Datasheet labels (2026-10-14, fifth pass)

§5 `0305F2F4`: `11000000` is `SYS_SOFT_RSTN` (bits 8/7 = CPU/system soft reset, active low) and `1100005C` is
`QUAD_ENABLE` (SPI flash four-wire mode) — restart is now datasheet + code ([HR_C7000_CROSSCHECK.md](HR_C7000_CROSSCHECK.md)).
§5 status bit 17: the datasheet names it the received EMB **PI** flag (privacy indicator).
