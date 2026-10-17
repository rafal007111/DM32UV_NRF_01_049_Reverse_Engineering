# USB CPS protocol, flash write semantics and codeplug compatibility — DM32.NRF.01.049

Written 2026-10-17 (targeted review work item **T2b**). Static analysis only: **no serial port was opened, no CPS
word was ever sent, and the radio was not accessed.** Every frame description below is read from the firmware
listing; it is documentation of what the firmware *would* do if a PC sent these bytes, not a procedure to run.

This document completes the CPS command tables that `SETTINGS_CPS_ANALYSIS.md` §3 left partial and that §11 flagged as
needing a re-check. §3 described one of the two frame loops (`03029FB0`, the `SYSINFO` loop); the `PROGRAM`-session
loop `0302A448` has a **different command set and a different address encoding**, documented here for the first time.

Tools: `tools/dm32` (`decomp`, `callers`, `callees`, `info`, `str`), `tools/static/objdump_image.sh`, Ghidra 12.1.4
(CSKY sinc fix 3), binutils 2.42, on `analysis/inputs/stock_progmem_1MiB.bin`
(`de7dbcbc…c97f0`). Addresses are flash VA (flash offset = VA − 0x03000000).

## 0. Summary

- The USB link is driven by task **`usb`** (`0302B340`, created via the code pointer at `0302A104`). It reads
  7-byte **handshake words** and, for the two words that open a transfer session (`PROGRAM`/`PON-PIC` and `SYSINFO`),
  enters a **frame loop**. `PCTESTM` opens the factory **test-mode** loop (`0302AA58`), which can key the
  transmitter.
- There are **two different frame loops**:
  - **`0302A448`** — entered by `PROGRAM`/`PON-PIC`. 6-byte header `cmd a0 a1 a2 len_lo len_hi`, address =
    `a0 | a1<<8 | a2<<16` (24-bit, little-endian), 16-bit length. Commands `S`/`G` (program flash write/read),
    `W`/`R`/`D` (data flash write/read/erase), `V` (info). Ends in a **restart**.
  - **`03029FB0`** — entered by `SYSINFO`. 5/6-byte header, address = `a0<<12 | a1<<8 | a2` (packed), plus the
    `FF FF hh ll` window. Commands `S`/`G` (program flash write/read), `C` (write to the internal `0x10C` record),
    `V` (info). **No restart.**
- **Program flash** (`S`/`G`) is the internal code flash, mapped at `0x0300B000 + addr`, written through
  `0002C164`/erased through `0002C0FC`, read through `0002C0E4`. **Data flash** (`W`/`R`/`D`) is the external SPI
  flash that holds the codeplug, addressed by raw byte offset with sector = `addr >> 12` (4 KiB sectors).
- The firmware never reads back or verifies a CPS write. After a `PROGRAM` session the radio restarts and reloads
  block 4; `SYSINFO` and the test modes do not restart.
- **What a mod must keep stable for CPS compatibility** is in §5. The block 4 `0x60` bits 2/3 storage decision of
  `SETTINGS_CPS_ANALYSIS.md` §11 is unchanged by this pass.

Confidence: the frame state machines, command bytes, address arithmetic and the flash helper targets are
**code-verified** (listing + literal pools + call sites). Which codeplug *record* lives at which raw data-flash
address, and what the PC software does with bytes it does not model, remain **inferred / PC-software-dependent**
(§4, §5).

## 1. Handshake layer — task `usb` `0302B340` (code-verified)

The loop reads 7-byte words with a 500 ms timeout (`FUN_03070a3c` compares the word). While the session flag
`3FDD8` bit 6 is set, a timeout runs `03029F80` (clear UI timers) and `0305F2F4` (restart). On a match, the task
sets the session flags (`3FDD8` bit 6, `3FDDC` bit 3) and replies. Word table at `030B08AC`, handlers at `030B0860`.

| Word (7 bytes) | Handler action | Reply | Opens |
|---|---|---|---|
| `PROGRAM` / `PON-PIC` | session flags; clear `40110` bit 0; stop RF/audio (`0002B634`, `0301E4D0(0)`, and if `3FDD8`&0x0A `0002B364(1,0,0)`+`0002C83C(0)`); run `0302A448`; then **restart** `0305F2F4` | `0302A448` replies `06`, waits `02`, sends 8×`FF`, waits `06`, replies `06`, then the frame loop | **write session** (program + data flash) |
| `PSEARCH` | session flags | `06 "DP570UV"` (model id) | — |
| `PASSSTA` | session flags; read block 4 `0x439` (2 bytes) | `50 xx yy` (password status, inferred) | — |
| `PASWORD` | `06`, then `0302B224` (host sends 10-byte `'P','W'/'R'` + 8-byte password; compared with block 4 `0x43B`/`0x443`) | `06` ok / `15` bad | — |
| `PCTESTM` | `06`, then `0302AA58` | `06` | **factory test mode** (§3; can TX) |
| `RTCITEM` | `06`, then `0302A9A8` (RTC item, unreviewed) | `06` | RTC set (inferred) |
| `DEL-RCD` | `06`, then `03010B40` (erase the voice-recording sectors `3FFEC..3FFF4` and `3FFE0..3FFF8`, write `0xA5` markers), then **restart** | `06` | recording wipe |
| `IDCHECK` | session flags | `06` | — |
| `SYSINFO` | session flags, `06`, then `03029FB0` (no `02`/`FF` exchange, no restart) | per frame | **read/write session** (program flash + `0x10C`) |
| anything else (7 bytes) | `03029F80`; if a session was open, clear `3FDD8` bit 6 and restart | — | — |

`PROGRAM` and `SYSINFO` both reach powerful flash access. `PROGRAM` is the full firmware+codeplug writer and always
ends in a restart; `SYSINFO` gives program-flash read/write and the `0x10C` write without restarting. `DEL-RCD` and
`PROGRAM` are the handshake words that themselves erase flash. **None of these must be exercised from an agent.**

## 2. Frame tables

### 2.1 `PROGRAM` session — frame loop `0302A448` (code-verified)

Opening exchange: radio sends `06`, waits for `02`; on `02` it sends 8×`FF`, waits for `06`, sends `06`, then loops.
Each pass reads a **5-byte** header `cmd a0 a1 a2 n` (2000 ms timeout; timeout = status `0x72D9` ⇒ return). For the
`V` command the 5 bytes are the whole header. For every other command the loop reads **one more byte** (1000 ms), so
the header is **6 bytes**:

```
byte 0 : command  ('S' 'G' 'W' 'R' 'D' 'V')
byte 1 : a0   addr bits  0..7
byte 2 : a1   addr bits  8..15      address = a0 | a1<<8 | a2<<16   (24-bit, LE)
byte 3 : a2   addr bits 16..23
byte 4 : len low      } length = u16 LE at bytes 4..5
byte 5 : len high     }
```

(Address arithmetic code-verified at `0302A49E…`: `uStack_38 = b1 | b3<<16 | b2<<8`; length `*(u16*)(hdr+4)`.)

| cmd | byte | Meaning | Payload | Flash target (helper) | Reply |
|---|---|---|---|---|---|
| `S` | 0x53 | **write program flash** | `len` bytes follow | if `(addr&0xFFF)==0` erase 4 KiB (`0002C0FC`), then program (`0002C164` → `0002BEBC` at `0x0300B000+addr`) | `06` |
| `G` | 0x47 | **read program flash** | — | read `len` bytes (`03010DDC` → `0002C0E4`) | `53` + `len` data bytes (header reused, `*hdr='S'`) |
| `W` | 0x57 | **write data flash (SPI)** | `len` bytes follow | if `(addr&0xFFF)==0` erase sector `addr>>12` (`0300F700` → `0002BA00`), then program (`0002BAB0`, page-walked across 4 KiB boundaries via `0002BA60`) | `06` |
| `R` | 0x52 | **read data flash (SPI)** | — | read `len` bytes (`0300F848` → `0002B9A0`, sector `addr>>12`, offset `addr&0xFFF`) | `57` + `len` data bytes |
| `D` | 0x44 | **erase data flash (SPI)** | — | erase `ceil(len/512)` 512-byte blocks from `addr` (`03067474`; `1` block if `len<0x200`, else `len>>9`) | `57` header |
| `V` | 0x56 | **info item** `n` (byte 4), `n ≤ 0x40` | — | no flash; see §2.3 | `56 n len data…` |

Notes:
- `S`/`G` and `W`/`R`/`D` are two *separate* address spaces. `S`/`G` hit the **internal program (code) flash**
  window at `0x0300B000 + addr`; `W`/`R`/`D` hit the **external SPI data flash** (the codeplug) by raw byte address.
  A full firmware update therefore uses `S` to lay down code and `W` to lay down the codeplug, both in the one
  `PROGRAM` session, which then restarts.
- The sector-aligned erase in the `S` path (`0002C0FC`) erases a 4 KiB block in the program-flash window and
  restores 4 bytes it read from `0x10C` first; the address plumbing of that erase is not fully resolved in the
  decompiler (the erase length 0x1000 and the program window base are code-verified; the per-sector address is
  **inferred**). Granularity: program flash erases in 4 KiB units, programs in `len`-byte runs.
- `W` erases **one** sector per sector-aligned write and then programs across sector boundaries; `D` is the bulk
  erase (512-byte granularity). Neither reads back.
- The loop maintains an ack/handshake toggle (`030611B0/CC/D8/F4`, `iVar10`) between frames; `S`/`W` and the
  immediate commands send `06` or the data reply and continue until `FF FF FF FF`-style end or a timeout.

### 2.2 `SYSINFO` session — frame loop `03029FB0` (code-verified; matches `SETTINGS_CPS_ANALYSIS.md` §3, corrected)

Each pass reads a **5-byte** header first. Address encoding differs from the `PROGRAM` loop:

```
if b0==FF and b1==FF:
    if b2==FF and b3==FF  -> end of session (return)
    else                  -> addr = 0xFF000 | b2<<8 | b3   (special 0xFF000 window)
else:
    addr = b1<<12 | b2<<8 | b3          (packed; a1 is a nibble, overlaps a2 in bits 12..15)
    cmd  = b0
```

| cmd | byte | Meaning | Length field | Flash target | Reply |
|---|---|---|---|---|---|
| `V` | 0x56 | info item `n` = b4, `n ≤ 0x40`; addr must be 0 unless `n==0x0D` (then addr = `b1:b2`) | — | no flash; §2.3 | `56 n len data…` |
| `C` | 0x43 | **write to the internal `0x10C` record** | `n` = b4 (single-byte length) | `03010DB8(0x10C, buf, n)` → `0301C98C` (writes a config/calibration record at `0x10C`; purpose inferred) | `06` |
| `S` | 0x53 | **write program flash** (reads a 6th byte, len = `u16` at b4..b5) | u16 | erase (`0002C0FC`) if `(addr&0xFFF)==0`, program (`0002C164`) | `06` |
| `G` | 0x47 | **read program flash** (reads a 6th byte, len = `u16`) | u16 | `03010DDC` → `0002C0E4` | `53` + data |
| else | — | — | — | return (ends the loop) | — |

So `SYSINFO` exposes program-flash read/write with the packed 20-bit address and the `0xFF000` window, plus the
`0x10C` config write (`C`). It does **not** expose the `W`/`R`/`D` data-flash commands; those exist only in the
`PROGRAM` loop. `SYSINFO` does not restart, so a PC tool can read device/program data without forcing a reboot.

### 2.3 `V` info items (both loops; code-verified values)

`n` (byte 4) selects the item; most require addr = 0. Reply is `56 n len data…`.

| `n` | Content | Source |
|---|---|---|
| 1 | `"DM32.NRF.01.049"` (firmware id) | `030A2718`/`030A2324` |
| 2 | 12-byte value: `0305FB7C(ptr)` then an xor/or mix of its first 8 bytes | `0305FB7C` |
| 3 | `"2022_06_27"` (build date) | string |
| 4 | `"D1 01.01.004"` | string |
| 5 | `"R1 00.01.001"` | string |
| 6, 7, 8, 9, 10 | two 32-bit words each (band limits, inferred) via `03029F9C` | `030A…` pointer pairs |
| 0x0B | `"C1 00.01.001"` | string |
| 0x0D | copies b4′ bytes from base `*030A2{90c,53c}` + addr (memory-read window) | — |
| 0x0E | two words (band limits; **`SYSINFO` loop only** — the `PROGRAM` loop does not list `0x0E` and sends junk) | — |
| 0x0F | two words | — |
| 0x10 | `50 C3 00` = 50000 | constant |

The `PROGRAM` and `SYSINFO` `V` tables are identical except item `0x0E` (present only in `SYSINFO`). Items the loop
does not list fall through and return `n+3` bytes of whatever is in the buffer.

## 3. `PCTESTM` factory test mode — `0302AA58` + `030215C8` (code-verified; **can key the transmitter**)

`PCTESTM` opens the test loop `0302AA58`. It reads **5-byte** frames `b0 b1 b2 cmd param` where `b0` selects an
action (`'R'`/`'W'`/`'S'`/other), `cmd` (byte 3) is the **test sub-command** and `param` (byte 4, `≤ 0x40`) is a
value. The `switch(cmd)` maps each sub-command to a *mode index* (`*0302AE_` into the band/frequency tables) and a
band/power index, then configures the radio. The actions:

- **set mode** (b0 not `R`/`W`/`S`): programs the frequency/band for the selected test and, for mode indices
  `< 0x32` (the TX test group), calls **`0300E40C`** (analog TX hardware on — PA + CTCSS + power ramp, `TX_PATHS.md`
  S3/S4) and **`030215C8(n)`** (baseband test-mode setup). For mode indices `≥ 0x32` it sets up an RX test
  (`030215C8(9)` etc.). This is the branch that **transmits**.
- **`'R'`** (0x52): read back the stored calibration/test value → reply `W`+data (1 or 2 bytes).
- **`'W'`** (0x57): apply a host-supplied parameter through a function-pointer table → reply `06`.
- **`'S'`** (0x53): stop the test and **persist** the parameter to **data-flash area 2** (`0300F878(2, off, …)`),
  reply `06`. (Area 2 = factory calibration; see `RX_CALL_PATH_ANALYSIS.md` §16.1, role now confirmed as
  calibration/test storage.)

`030215C8(n)` (`HR_C7000_CROSSCHECK.md` §8.2) sets `WORK_MODE`, `LAYER2_*`, and for `n = 1/2/3` asserts
`0300C304(1)` = HR_C7000 **`FM_PTT`** (TX sink **S1** in `TX_PATHS.md`). So a host that completes the `PCTESTM`
handshake and sends a TX-group sub-command puts the radio into a **continuous transmit test**, bypassing PTT, the
channel Rx-Only bit, TOT and the TX-admit gates. Cross-checked against `TX_PATHS.md`: the `PCTESTM` row and the
`RF sweep test` (`03055600`, reachable only after `PCTESTM`) are the two USB-reachable TX paths; both require the
`PCTESTM` word first and are otherwise unreachable.

**Which sub-commands can key TX:** every `cmd` whose resulting mode index is `< 0x32` (the groups that set
`puVar4[3] |= 0x18` / the low-index TX tests: `cmd` 1, 2, the 3..7 and 8..0xC groups, 0x10..0x2D, 0x30..0x37,
0x40..0x53, etc., which map to indices below 0x32). Sub-commands that map to indices `≥ 0x32` (e.g. the `0x60`
group → index `'J'`) set up RX/analog-RX tests. Exact per-sub-command TX/RX classification is **code-verified in
structure but was not tabulated byte-by-byte** (≈60 switch cases); the safety-relevant fact — that TX test modes
exist and key the PA directly — is code-verified. **Never send `PCTESTM` or any test sub-command from an agent.**

## 4. Address map — which CPS address reaches which codeplug area

### 4.1 Program flash (`S`/`G`)

CPS program-flash addresses are offsets into the internal code-flash window at `0x0300B000`. This is the firmware
image region. A `PROGRAM` session uses `S` to write it (firmware update) and `G` to read it back.

### 4.2 Data flash (`W`/`R`/`D`) and the firmware's logical areas

The `W`/`R`/`D` commands address the external SPI data flash by **raw byte offset**, sector = `addr >> 12`
(4 KiB). The firmware, internally, does *not* address the data flash by raw sector; it uses a **logical area**
abstraction (`0300F594(area)` → `0300F364`): each 4 KiB sector stores its logical **area id in its last byte
(offset `0xFFF`)**, and `0300F364` scans a RAM directory of those marker bytes (`030F4F0[]`, count `030F4F8`) to
find which physical sector currently holds a given area. Writes go through a copy-on-write writer
(`0300F878`/`0300FA28`/`0300FB58`/`0300FDA4`): the whole 4 KiB area is copied through a spare sector and only the
requested bytes are patched, so a firmware-side save never clears bytes it does not model, and the physical sector
of an area can move.

Consequence for the CPS: because the CPS addresses raw sectors while the firmware resolves areas through the
`0xFFF` marker directory, a CPS codeplug write must lay down **whole sectors including their `0xFFF` marker byte**;
a CPS read/write therefore sees the *physical* layout, and a full codeplug write defines the entire area directory.
Linking a given raw CPS address to a logical area requires knowing the physical layout the PC software uses, which
is **not in this repository** (PC-software-dependent).

The logical areas and their records (code-verified readers; see `RX_CALL_PATH_ANALYSIS.md` §16.1 for the full
table and evidence):

| Area | Content |
|---|---|
| 2 | factory calibration / bounded boot settings (written by `PCTESTM` `'S'`, §3) |
| 4 | general settings ("block 4"): `0x60`/`0x85`/`0xA0` setting bytes, `0xF00` stun marker, `0xF01`/`0xF02` boot channel restore |
| 6 | 64 × 16-byte list |
| 7, 8, 9, 10 | Inbox / Outbox / Draft / quick-text messages (boot marker at `0xFFF`) |
| 11 | digital contacts (count at 0, string `"Tx Contact %d/%d"`) |
| `0x0C`–`0x0E` | Call Log (Missed / Answered / Sent, 20 × 14-byte records) |
| 15 | RX group lists |
| 16 | per-channel privacy key list (key id + up to 32-byte key) |
| 17 | scan lists |
| 18 (`0x12`) | channel records |
| `0x41` | VFO A/B channel-like records |
| `0x65` / `0x66` | roaming zones / roaming channels |
| 1, 3, `0x5C`, `0x67` | position log / `0306xxxx` subsystem / single-byte values |

## 5. Compatibility rules for mods (static; supersedes the "partial" note in `SETTINGS_CPS_ANALYSIS.md` §11)

What is code-verified about CPS/codeplug round-trips:
1. The CPS `W` write erases and rewrites **whole 4 KiB data-flash sectors**, including the `0xFFF` area marker.
   Any byte in a sector the CPS writes survives only if the **PC software** writes it back unchanged.
2. Firmware-side saves (`0300F878` family) are copy-on-write and patch only the requested bytes, so the **firmware**
   never clears unknown bits of an area it rewrites.
3. The firmware never verifies or reads back a CPS write. After a `PROGRAM` session the radio restarts and
   `0304B010` reloads block 4 at boot, so a CPS-written value takes effect on the next start. `SYSINFO` and the test
   modes do not restart.
4. Block 4 `0x60`: readers are `0304B010` (bits 0/1) and `0304B158` settings 9/10 (read-modify-write via
   `0300FA28`); no reader or bulk read covers bits 2–7, and the only variable-length writer near it (`030610D8`,
   `0x50`) is unreachable (`SETTINGS_CPS_ANALYSIS.md` §10.1). So bits 2/3 are free *in the firmware*.

What depends on the PC CPS software (not in this repository, so **unknown statically**): whether a CPS write back
preserves bytes/bits it does not model (block 4 `0x60` bits 2–7, `0x85` bit 4, `0x67`), zeroes them, or rewrites
them from a template; and the PC codeplug **file format**.

Rules for a mod (unchanged from §11, re-confirmed):
1. Store new options only in bits the firmware never reads today and whose value 0 = stock behaviour (block 4
   `0x60` bits 2/3 for CC/TS Match off). `MATCH_OPTIONS_DESIGN.md` §2 keeps this storage choice.
2. Never repurpose bytes the CPS models (channel, zone, contact, scan-list, roaming records); a per-channel option
   would need CPS support that does not exist.
3. Treat any new option as volatile across a CPS write until the owner round-trip check (below) shows it survives.
4. Do not change the CPS session code (`0302B340`, `0302A448`, `03029FB0`, `0302AA58`), the handshake words
   (`030B08AC`), the address arithmetic, the flash helpers, or the restart after `PROGRAM`. A mod that moves code
   must not shift any of these or the data-flash area layout.

## 6. Open questions for the owner

1. Which CPS version is used, and is its codeplug **file format** documented anywhere? A raw image of area 4 would
   turn the round-trip check below into a pure offline file comparison.
2. Does the PC CPS preserve block 4 `0x60` bits 2–7 (and `0x85` bit 4, `0x67`) on a read→write round trip? Only the
   PC software can answer this.
3. `0302A9A8` (`RTCITEM`) and the `0x10C` record written by `C`/`0301C98C` are not fully reviewed (purpose inferred).

## 7. RX-only / owner test proposals

**All of these write the radio or program it; they are owner decisions, never agent actions.**

- **Codeplug round-trip (writes the radio).** With stock firmware: CPS read → save file A; write A back unchanged;
  CPS read → save file B; compare A and B offline (should be identical). Then enable PCall Match on the radio, read
  → file C, and confirm only area 4 byte `0x60` bit 0 differs from A. If a tool can set `0x60` bit 2 in a saved
  file (hex-edit, once the format is known), a CPS write→read then shows whether the CPS keeps it.
- **Never** exercise `PROGRAM`, `SYSINFO`, `DEL-RCD` or `PCTESTM` frames, or any test sub-command, from an
  automated agent. `PCTESTM` TX test modes transmit; `DEL-RCD` erases recordings; `PROGRAM`/`SYSINFO` write flash.

## 8. Not reviewed

- Per-sub-command TX/RX classification of all ≈60 `PCTESTM` cases (structure code-verified; byte table not built).
- The `0x10C` record semantics (`0301C98C`), `RTCITEM` (`0302A9A8`), and the `0002C0FC` program-erase per-sector
  address plumbing.
- The PC CPS software and codeplug file format (not in this repository).
- CPS-tagged helpers not on the frame paths: `0002BAB0…0002C164` neighbours, `0301C8E0…0301C98C`,
  `03066F70…030674F0`.
