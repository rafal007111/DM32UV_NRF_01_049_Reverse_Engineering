# GNSS (NMEA) input path — DM32.NRF.01.049

Static analysis, 2026-10-17 (sixth pass). No serial port, no radio access, no image built. Nothing here is
hardware-verified. Inputs, hashes and tools as in `HR_C7000_CROSSCHECK.md` §0 (stock `de7dbcbc…`, GZF `354f9324…`,
Ghidra 12.1.4 + legacy CSKY v0.2 + `32b_data.fixed.sinc` fix 3, GNU binutils 2.42, `tools/dm32`). Literal-pool values
were resolved from the stock image; decompiler output was checked against `flash.asm`/`iram.asm` at the cited sites.

## 1. Data flow (code-verified)

```
GNSS module UART (MMIO 0x14040000 data, 0x14040014 status bit 0 = RX ready)
  → IRAM handler 0002CCE4 (pointer stored by 0301D8C4 from pool 0301DA08; "interrupt handler" inferred): collects '$' … '\n' into the
    150-byte line buffer 38B28, forces CR/LF at 148/149 on overflow, then posts bit 20 (`0x100000`) on event
    group 3FDB0 with `0300C494(3FDB0, 0x100000)` (`0002CDF4…0002CDFA`; the shift after `movi r1, 128` read from the listing)
  → task "gps" 03011A80 (created by 03011804 at boot through 00012DD8 with 0x15 and the cleared 0x400-byte buffer 2FFA4 as arguments;
    priority/stack reading inferred): waits (0305FDD4) for bits 20/25 of 3FDB0 and clears them (0300C4A8); bit 20 → 030119BC copies the line into the 1 KiB ring 386C0
    (state 2FF9C: +0 read index, +2 write index, +4 byte count, +6 line count) and clears 38C88 bit 5
  → main task loop 03068E54 → 03013940 → NMEA parser 03012774 (one sentence per call, between the lock/unlock pair 0300C500/0300C53C on 38D64)
```

So the sentences are parsed in the **main/UI task**, not in task `gps`; task `gps` only moves bytes.

## 2. Parser `03012774` (code-verified fields; NMEA meanings standard)

Helpers: `03011AD4(n)` ring index after the n-th comma, `03011BB8`/`03011C28` computed vs received XOR checksum,
`030113C8(line, out, n, max)` copies NMEA field n−1, `03011450` coordinate string → packed value, `03011B3C`
consumes the sentence, `0305FC70` string compare, `03070CC4` `strchr`.

| Sentence | Accepted talkers | Checks | Stored |
|---|---|---|---|
| RMC | `$GPRMC`, `$BDRMC`, `$GNRMC` | status field = `A`, checksum equal | latitude (field 3) → `38D40` (packed by `03011450`, degree string → `38D44`), longitude (5) → `38D4C` (`38D50`), N/S → `38D5E`, E/W → `38D5F`; speed (7) → `38C88+0xD4`, course (8) → `38C88+0xD2` (0 when the field has no `.`); raw sentence (≤ 150 bytes) → `38C95`, `38C88` bit 6 = valid fix; then `03012678` |
| GGA | `$GPGGA`, `$BDGGA`, `$GNGGA` | checksum equal | satellites (field 7, two digits) → `38C88+0xB5`, altitude (field 9) → `38C88+0xD0` |

`38C88` bit 7 mirrors bit 6; when the fix state changes and the UI is idle, the home screen is redrawn (`030193CC`).
All other sentences (GSV, GSA, …) are ignored. `$BD…` (BeiDou) and `$GN…` (multi-GNSS) talkers are accepted, which
matches the menu string `GPS + BDS` (`030BD268`).

`03012678` — **GNSS time sets the clock** (medium): takes RMC UTC time (field 1) and date (field 9), converts them with
`03011620(2, …)` (time-zone handling, unreviewed) and calls the RTC setter `0301C3E0` (the same setter used by
`RTCITEM`, `RX_CALL_PATH_ANALYSIS.md` §15) whenever the result differs from the current RTC value (`0301C238`).

## 3. Power and supervision (code-verified writes; roles inferred)

| Function | Behaviour |
|---|---|
| `03011804` (boot, from `0305F674`) | resets the ring state, drives GPIO `0x2C` from `38C88+0xD8` bit 0 (`0002C548` = set, `0002C504` = clear), creates task `gps` |
| `03011914(on)` (from `0304D6B0`, a settings handler) | `on = 1`: `38C88+0xD8` bit 0 = 1 and GPIO `0x2C` set (GNSS power on, inferred); `on = 0`: GPIO cleared, fix state, ring and line buffer zeroed |
| IRAM `0002CABC` (periodic callback, pointer at `0301D850`) | every 10th call: event 1 on `3FDB0`; if `38C88` bit 5 has stayed set for > 150 slow ticks, clears the GNSS buffers (no-data timeout); **if `3FDD8` bits 6/1 = `10` (CPS session open, not `PCTESTM`) for > 800 slow ticks → restart `0305F2F4`** (CPS session watchdog) |

The last row adds a second restart path to `SETTINGS_CPS_ANALYSIS.md` §3.1: an open CPS session that goes silent is
ended by a reboot after about 800 slow ticks (tick period not established).

## 3a. Received position log — data-flash area 1 (code-verified structure; field names inferred)

| Function | Behaviour |
|---|---|
| `03062E20` | record count = 16-bit word at offset 0 of area 1 |
| `03062E44(i)` / `03062E74(i, buf)` | read 3 bytes / a record at `0x10 + 0x50·i` |
| `030634F0(buf, len)` (called by the position display `03063EA4`, `DATA_PATH_ANALYSIS.md` §4.3) | appends a `0x50`-byte record: payload `buf` (up to `0x46` bytes), 2 bytes from `4009C+0x24` and 8 bytes from `4009C+0x28`; when the count would exceed 50 it erases the area, and when it is exactly 50 it keeps the newest 30 and drops 20. Writes go to a spare sector (`0300F5B4`) that is then swapped in (`0300F2FC`, copy-on-write) |
| `03063654` (from the data-area reset `030323F4` and the menu handler `0304D7E0`) | erases area 1 and writes count 0 |
| `030633D8(first, sel, count)` | the `APRS Info %d/%d` list (8 rows per page) |

So the radio stores up to 50 received position reports in data flash. The two extra fields are probably a receive
time stamp (inferred). A position report is a received data message (`DATA_PATH_ANALYSIS.md` §4.3), not AX.25.

Dead code (inferred: no `bsr` and no pointer word in the image): `03011C78` sends a string + CR/LF to the GNSS UART
(`0301D92C`, the only use of the `\r\n` constant `030825E4` found) and `03011CC4` would send the raw RMC sentence as
message type 4 through `0305CD88`. Neither has a Ghidra function or a caller.

## 4. Open questions (owner) and RX-only checks

1. Does the radio set its clock from GNSS? Expected (code): with GNSS on and a fix, the clock jumps to UTC adjusted
   by the configured time zone within seconds. RX-only: enable GPS outdoors, set the clock wrong in the menu, wait for
   a fix and observe the clock.
2. Which menu item calls `03011914` (GNSS on/off)? Expected: the GPS on/off setting.
3. With GNSS off, is `38C88` bit 6 (fix) cleared so that `GPS Invalid` is shown? (code: yes, `03011914(0)`).

## 5. Not reviewed

`03011620` (time zone), `03011450` float helpers, `03013940` (rest of the main-loop step), the APRS encoder and
beacon (`APRS Info %d/%d` at `030633D8`), position display `03063EA4`, the `GPS Info Send` path
(`DATA_PATH_ANALYSIS.md` §4.3 `"WLT CMD"` reply), and how the 0x2C GPIO and the UART at `0x14040000` relate to the
HR_C7000 peripheral map.
