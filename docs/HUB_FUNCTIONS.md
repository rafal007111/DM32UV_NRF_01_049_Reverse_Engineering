# Hub functions and the display layer — DM32.NRF.01.049 (2026-10-17)

Static only. Inputs re-checked: stock `stock_progmem_1MiB.bin` (`de7dbcbc…`), installed
`current_scan_tick_fix.progmem.bin` (`156a4872…`), GZF `354f9324…`. Tools: GNU binutils 2.42 for C-SKY through
`tools/dm32` (`fn`, `callers`, `callees`, `acc`), Python 3, T-HEAD V3.10.29 toolchain installed by
`tools/setup_cloud.sh --with-thead` (not needed for this pass). No serial port opened, no CPS word sent, no radio
access, no image file written. Naming needs no hardware test.

Labels: **code-verified** = read in the listing (body, literals, call sites); **inferred** = consistent reading that
the code alone does not prove (e.g. a controller model from a command sequence). The catalog confidence follows the
prompt: `high` only when the body was read completely and the RAM/MMIO meaning and the call sites agree.

## 1. Work list (H1.1)

Every catalog row that was `unreviewed` with at least 10 direct callers (`known_direct_callers`), 76 rows, sorted by
caller count. Size in bytes; "auto tag" is the tagger lead before this pass (`—` = none). The extra criterion
(fewer than 10 direct callers but ≥ 10 call sites through tail calls, `jsri` or function pointers) added **no**
row: over all 1584 unreviewed rows, only one function has three or more references that are not a direct `bsr`
(`br(tail)`/`jsri` edges, `lrw` literals, table words): `03055004`, 8 handler-table words (< 10). Method: `Xrefs.callers_of`, `literal_uses`, `words_equal` over the stock image.

| Address | Callers | Size | Auto tag before | Reviewed subsystem | Confidence |
|---|---:|---:|---|---|---|
| `0300F780` | 118 | 44 | — | Storage (data flash) | high |
| `0300C500` | 107 | 30 | — | RTOS wrapper | high |
| `0300C53C` | 102 | 20 | — | RTOS wrapper | high |
| `03017BE8` | 87 | 106 | auto: Menu/input | Display (drawing) | high |
| `03018AF4` | 77 | 90 | auto: Menu/input | Display (fonts) | high |
| `0300F71C` | 68 | 98 | — | Storage (data flash) | high |
| `0304A1E8` | 53 | 24 | auto: Menu/input | Menu/UI framework | high |
| `03035E68` | 51 | 16 | auto: Menu/input | Menu/UI framework | high |
| `03036BB0` | 51 | 166 | auto: Menu/input | Menu/UI framework | medium |
| `03018930` | 42 | 254 | — | Display (fonts) | high |
| `0002C504` | 40 | 68 | — (IRAM) | GPIO | high |
| `0002C548` | 40 | 68 | — (IRAM) | GPIO | high |
| `0300FA28` | 39 | 302 | auto: Codeplug/channels | Storage (data flash) | high |
| `0303A4F4` | 37 | 86 | auto: Menu/input | Display (UI widgets) | high |
| `03030560` | 35 | 88 | auto: Menu/input | Codeplug/channels | medium |
| `03018C70` | 31 | 116 | auto: shared (UI tasks) | Display (UI widgets) | high |
| `0002B9A0` | 29 | 24 | — (IRAM) | Storage (data flash) | high |
| `030130AC` | 29 | 68 | — | Keys/input | high |
| `0301340C` | 28 | 100 | auto: shared (UI tasks) | Audio/tones | medium |
| `0305F904` | 28 | 56 | — | Utility | high |
| `03049498` | 27 | 3340 | auto: Menu/input | Menu/UI framework | medium |
| `0303900C` | 26 | 150 | auto: shared (UI tasks) | Display (drawing) | high |
| `030649A8` | 26 | 6 | — | Codeplug/channels | medium |
| `0300C4D4` | 25 | 22 | — | RTOS wrapper | high |
| `0002B904` | 23 | 88 | — (IRAM) | Storage (data flash) | high |
| `0002DED4` | 23 | 90 | auto: Menu/input | Codeplug/channels | medium |
| `0300C494` | 23 | 20 | — | RTOS wrapper | high |
| `0301AB40` | 23 | 74 | auto: Menu/input | Display (UI widgets) | high |
| `00019494` | 22 | 16 | — (IRAM) | Utility | high |
| `03017EEC` | 22 | 72 | auto: shared (UI tasks) | Display (drawing) | high |
| `03059C14` | 22 | 124 | auto: shared (UI tasks) | Text input editor | low |
| `0001947C` | 21 | 24 | — (IRAM) | Utility | high |
| `03018D78` | 21 | 132 | — | Display (drawing) | high |
| `030649B0` | 20 | 6 | — | Codeplug/channels | medium |
| `03019B80` | 18 | 26 | auto: Menu/input | Display (UI widgets) | high |
| `03066884` | 18 | 68 | auto: Codeplug/channels | Roaming | medium |
| `0002DF9C` | 17 | 342 | — (IRAM) | Utility | high |
| `0305660C` | 17 | 114 | auto: Codeplug/channels | Codeplug/channels | high |
| `00018EF4` | 16 | 164 | auto: Audio/vocoder | Audio/vocoder | low |
| `03034CF4` | 16 | 154 | auto: shared (UI tasks) | Contacts/calls | medium |
| `03030370` | 15 | 412 | auto: Codeplug/channels | Codeplug/channels | medium |
| `0303A4AC` | 15 | 70 | auto: Menu/input | Display (UI widgets) | high |
| `0305AE28` | 15 | 134 | auto: Menu/input | Text input editor | low |
| `0002BA00` | 14 | 16 | — (IRAM) | Storage (data flash) | high |
| `0301D0DC` | 14 | 248 | auto: Main loop | GPIO | high |
| `03034DB4` | 14 | 126 | — | Contacts/calls | low |
| `0300F318` | 13 | 52 | — | Storage (data flash) | high |
| `030193CC` | 13 | 338 | auto: shared (UI tasks) | Display (UI widgets) | medium |
| `030393B8` | 13 | 50 | — | Menu/UI framework | high |
| `03039420` | 13 | 44 | — | Menu/UI framework | high |
| `0304C434` | 13 | 726 | — | Settings | medium |
| `0305CD20` | 13 | 104 | auto: shared (UI tasks) | Menu/UI framework | low |
| `0002C1E8` | 12 | 18 | — (IRAM) | Display (LCD bus) | high |
| `0002DF8C` | 12 | 14 | — (IRAM) | Utility | high |
| `0300F2FC` | 12 | 26 | — | Storage (data flash) | high |
| `030178A4` | 12 | 10 | — | Display (LCD driver) | high |
| `03019AC0` | 12 | 50 | auto: shared (UI tasks) | Display (UI widgets) | high |
| `03059F08` | 12 | 94 | auto: Menu/input | Text input editor | low |
| `030140E4` | 11 | 46 | auto: shared (UI tasks) | Keys/input | medium |
| `03017BD0` | 11 | 24 | — | Display (LCD driver) | high |
| `0301989C` | 11 | 274 | auto: shared (UI tasks) | Display (drawing) | medium |
| `03038F5C` | 11 | 156 | — | Display (drawing) | medium |
| `03041530` | 11 | 170 | — | Display (UI widgets) | low |
| `0304A2D0` | 11 | 188 | — | Settings | low |
| `0305655C` | 11 | 44 | auto: shared (UI tasks) | Codeplug/channels | high |
| `03059A64` | 11 | 32 | auto: Menu/input | Text input editor | low |
| `0002F088` | 10 | 22 | auto: Recording/privacy | Utility | high |
| `0300C464` | 10 | 48 | — | RTOS wrapper | high |
| `0300C4A8` | 10 | 20 | — | RTOS wrapper | high |
| `0300E3B4` | 10 | 50 | — | Codeplug/channels | medium |
| `03019C60` | 10 | 44 | auto: shared (UI tasks) | Display (UI widgets) | high |
| `0302E0CC` | 10 | 6 | — | Contacts/calls | medium |
| `03048554` | 10 | 98 | auto: shared (UI tasks) | Display (UI widgets) | low |
| `0304A3FC` | 10 | 94 | — | Settings | low |
| `03054F90` | 10 | 32 | — | Settings | low |
| `0305BCF4` | 10 | 122 | — | Text input editor | medium |
Result: **76 of 76 named** — 46 `high`, 18 `medium`, 12 `low`. Along the display path 40 more rows were read and
named (35 display, 5 data-flash/SPI), so the pass changed 116 catalog rows (§7).

## 2. H1 — hub groups

### 2.1 RTOS wrappers (code-verified)

Thin wrappers that hide the uC/OS-III error/timestamp arguments. All take a millisecond or tick argument as noted.

| Address | Name / role | Arguments | Return |
|---|---|---|---|
| `0300C500` | `sem_pend` — `OSSemPend(sem, (ms + 9) / 10, 0, &ts, &err)` | `sem`, `ms` (0 = forever) | err |
| `0300C53C` | `sem_post` — `OSSemPost(sem, 0, &err)` | `sem` | err |
| `0300C4D4` | `sem_create` — `OSSemCreate(sem, "sem", count, &err)` | `sem`, `count` | err |
| `0300C494` | `flag_set` — `OSFlagPost(grp, bits, OS_OPT_POST_FLAG_SET, &err)` | `grp`, `bits` | err |
| `0300C4A8` | `flag_clr` — `OSFlagPost(grp, bits, OS_OPT_POST_FLAG_CLR, &err)` | `grp`, `bits` | err |
| `0300C464` | `flag_pend` — `OSFlagPend(grp, bits, ticks, all ? SET_ALL|CONSUME (0x104) : SET_ANY|CONSUME (0x108), &ts, p_err)` | `grp`, `bits`, `all`, `ticks`, `p_err` | flags |
| `0300C4BC` | (already `high`) `OSTimeDly((ms + 9) / 10)` | `ms` | — |

**Pairing check.** `0300C500` and `0300C53C` are used as a mutex pair on the same object in every hub read here:
`39360` (LCD, created with count 1 by `03017CE4`), `39468` (data flash), `3BD70` (tone request, `03021C1C`/
`03021C60`), `3E34C` (channel reload, `03030560`). Pinned: `Analysis.test_hub_lock_pairing` (callee order of
`0300F780` = pend, area lookup, raw read, post; one `lrw 0x39468`).

### 2.2 Data flash (external SPI NOR) (code-verified)

Layered as: area API (mutex `39468`) → raw sector API → SPI NOR command → SPI port. The commands are the JEDEC set
(`06` WREN, `02` page program, `03` read, `20` 4 KiB sector erase, `05` RDSR/WIP), chip select is **GPIO 18**,
address = `sector << 12 | offset` kept in `386B8`. This refines [CPS_PROTOCOL.md](CPS_PROTOCOL.md) §3 (same helpers,
now with their bodies).

| Address | Name / role | Arguments |
|---|---|---|
| `0300F780` | `area_read` — mutex, `sector = 0300F364(area)`, raw read | `area, off, buf, len` |
| `0300F71C` | `sector_read` — mutex; splits a read crossing a 256-byte page | `sector, off, buf, len` |
| `0300FA28` | `area_write_byte` — copy-on-write of the 4 KiB area with one byte changed, marker move, directory reload, scheduler locked | `area, off, byte` |
| `0300F2FC` | write the area-marker byte at `0xFFF` of a sector | `sector, marker` |
| `0300F318` | reload the RAM area directory `2FED0[sector]` from every `0xFFF` marker | — |
| `0002B9A0` | raw `flash_read` (no lock of its own) | `sector, off, buf, len` |
| `0002B904` | raw `flash_write`, page-split | `sector, off, buf, len` |
| `0002BA00` | raw `flash_erase` (4 KiB) | `sector` |
| `0002BA14` | `flash_read_abs` under the mutex (image and tone data) | `addr, buf, len` |
| `0002B89C`, `0002B8AC`, `0002B95C`, `0002B9B8`, `0002B818`, `0002B840` | set address; page program; read; sector erase; 1-byte command; busy wait | — |

### 2.3 GPIO and SPI ports (code-verified mechanism; controller models inferred)

- `0002C504(n)` **drives GPIO n high** (OR into the output-data register `+0`), `0002C548(n)` **drives it low**
  (AND with the inverted bit). Ports: `n < 32` → `0x14020000`, `n < 64` → `0x14100000`, else `0x14110000`.
  The data-flash code asserts chip select with `0002C548(18)` and releases it with `0002C504(18)`
  (`0002B818`, `0002B8AC`, `0002B95C`, `0002B9B8`, `0002BA14`), which pins the polarity (test above).
- `0301D0DC(n, level)` configures GPIO n as an output: clears `+0x30/+0x38/+0x3C` (interrupt enable, type,
  polarity), sets the direction bit `+4`, then drives `level`. The register layout matches a DesignWare APB GPIO
  (inferred; `SUBSYSTEM_TAGS.md` already listed the identical layout of the three bases).
- SPI: `0002C0A0(port, cs, buf, len)` (write) and `0002BFC8(port, cs, rx, rxlen, tx, txlen)` (write then read),
  byte transfer `0002BF94` (uncatalogued, inside the gap). Port table `030AE9A4`: **0 = `0x140A0000`** (data flash),
  1 = `0x140B0000`, 2 = `0x140E0000`, 3 = `0x14150000`. Registers used: `+0x08` enable, `+0x10` slave select,
  `+0x28` status (bit 0 busy, bit 1 TX not full, bit 2 TX empty), `+0x60` data — a DesignWare SSI layout
  (inferred). This identifies two of the bases listed as unknown in `SUBSYSTEM_TAGS.md` §1 (`0x140A0000`,
  `0x14150000`) as SPI ports; the users of ports 1–3 were not followed.
- Correction of wording in [GNSS_ANALYSIS.md](GNSS_ANALYSIS.md) §3 and [AUDIO_TONES.md](AUDIO_TONES.md): there
  `0002C548` was called "set"/"on" and `0002C504` "clear". Electrically it is the other way round (`0002C548` = low,
  `0002C504` = high); whether low means "on" for the GNSS power (GPIO `0x2C`) or the audio line (GPIO `0x2F`) depends
  on the board and is not known (inferred either way).

### 2.4 Small utilities (code-verified)

`00019494` fill16(dst, v, n), `0001947C` copy16(dst, src, n), `0002F088` copy8(dst, src, n), `0002DF8C`/`0002DF9C`
busy-wait loops (no OS call), `0305F904` little-endian packed BCD → binary (channel frequencies, last byte most
significant), `0300E3B4` CTCSS/DCS code class (0 none, 1 CTCSS, 2 DCS `0x8000`, 3 DCS inverted `0xC000`; class
names inferred), `00018EF4` fixed-point normalised division of the IRAM vocoder library (`low`).

### 2.5 Menu framework, settings getter, keys and tones

| Address | Role | Confidence |
|---|---|---|
| `03035E68` | `scene_set(scene, pending)`: `320CB = scene`, `320CC = pending` when non-zero | high |
| `03036BB0` | back to the parent scene: pops the scene stack (`320CA` → `3E5FF[]`), restores level `320C9`/`3E928`, saved index `3E508`, item list `3E618` (35-byte copy) and count | medium |
| `0304A1E8` | item list = `0..n-1`, `*count = n` (default case of the list builder) | high |
| `03049498` | visible-item list of menu id 0–50 (jump table `030B2058`), hides items by scanner/VFO/channel type and option bytes read from area 4 offset `0x500` | medium |
| `030393B8` / `03039420` | list cursor up/down in an 8-row window with wrap (`&row, &index, count`) | high |
| `0304C434` | `setting_get(id)`: one switch of byte/bit reads of `3E9D4…` (e.g. id 7 = language `3EA04` bit 6, `0x10` Radio Silent `3EA15`, `0x11` key tone `3EA16`) | medium |
| `030130AC` | `post_key(kind, code)`: code → `38E46`, `OSQPost(38D8C)` (the queue read by the key reader `03013078`) for kind 1/3, otherwise only when `307A8 == 1` | high |
| `0301340C` | key-press beep through `03021C60` when key tone (`0x11`) is on and not in PC test mode | medium |
| `03021C60` | `tone_play2(id, arg)` — like `03021C1C`, also stores `arg` in `3BD98` | high |
| `030140E4` | permission callback chain (12 SRAM handlers at `18000804`; `TX_PATHS.md`) | medium |
| `0305CD20` | menu action helper returning to the scene below (tone 27 when `3E33B` bits 6:5 set) | low |

### 2.6 Channel, zone, contact and settings helpers

| Address | Role | Confidence |
|---|---|---|
| `03030560` | channel reload request with reason `r` (`3E335`), flag `3FDB0` bit 3 set, waits for bit 2; mutex `3E34C` (RX_CALL_PATH_ANALYSIS.md §16.2) | medium |
| `03030370` | store a 51-byte channel copy (by value) into `3E1F8` and optionally into VFO A `3E374` / VFO B `3E238` | medium |
| `0002DED4` | channel type (`+8` bits 7:4) of the active VFO buffer, forced analog by `0300D810` | medium |
| `0305660C` | `zone_member(zone, i)` → channel number (1 when out of range or > 4000) | high |
| `0305655C` | read the 16-byte name of channel `n` | high |
| `030649A8` / `030649B0` | getter/setter of byte `400FC` (VFO/dual-watch mode flag, meaning inferred) | medium |
| `03066884` | roaming candidate active on the selected VFO (`40144` bits 3/4) | medium |
| `0302E0CC` | getter of the call display byte `3E0E5` | medium |
| `03034CF4` | contact name by ID from area 11, else `"%d"` | medium |
| `03034DB4` | count from the area-11 header | low |
| `0304A2D0`, `0304A3FC`, `03054F90` | per-VFO settings copy, a timed setting `3EA2E`/`3E3B4`, state reset `3E3AC`/`3EC10` | low |

### 2.7 Text input editor (low unless noted)

`03059C14` init (cursor `(32, 5)` in `3ED48`/`3EE92`, buffer `3EEB8` 340 bytes, mode `18000B0A`), `03059A64` save
and reset the cursor, `0305AE28` mode step (symbol table `030B62E8` `".,'?!-()@/:_;+&%*=<>$[]{}~^`#|"`), `03059F08`
redraw, `0305BCF4` cursor advance with the same 12/24-px metrics and wrap as `03018930` (medium).

## 3. H2 — display architecture

### 3.1 Hardware interface and controller

- **Bus:** memory-mapped LCD interface at **`0x12000000`**: command register `+0`, data register `+4`, both written
  one byte per store (`0002C1D0`, `0002C1DC`; pixel = two data bytes high then low, `0002C1E8`). Init sets
  `0x12000010 = 0x303` and `0x12000028` bit 0, then waits for bit 1 (timing/enable of an 8080-style parallel
  interface; inferred). Code-verified: the only stores to `0x12000000…07` are the two at `0002C1D6`/`0002C1E2`
  (`Analysis.test_lcd_bus`). This identifies the base listed as unknown in `SUBSYSTEM_TAGS.md` §1.
- **Controller:** `03017CE4` (called once from the boot path `0305F674`) sends the MIPI-DCS / ST7789-class sequence
  `11` sleep out, `B2` porch `0C 0C 00 33 33`, `35 00` tearing effect, `36` orientation, `3A 05` (16-bit RGB565),
  `B7 56`, `BB 17`, `C0 2C`, `C2 01`, `C3 0B`, `C6 EF`, `D0 A7`, `D0 A4 A1`, `D6 A1`, `E0`/`E1` 14-byte gamma, screen
  clear, `21` inversion on, `29` display on, `2C`. The controller is **inferred** to be an ST7789V (the command
  set and values are the usual ST7789V init). GPIO 66 is pulsed high/low/high with 120 ms steps (reset, inferred);
  GPIO 70 is configured as an output driven high (backlight or chip select, not determined). The init also clears
  bits of `0x1100003C` (mask `0xFFF80107`) — that is in the HR_C7000 window and is **open** (pin mux or chip
  register; not looked up in the datasheet in this pass).
- **Orientation:** `03017884(v)`: `36 C0` when `v == 0`, else `36 00`; at init `v = 3EA41` bit 0 (a display
  setting; that it is a user "rotate/flip" option is inferred).
- **Model:** **direct write, no frame buffer.** Every primitive sets a window (`2A` `03017B80`, `2B` `03017BA8`,
  `03017BD0`, cursor `03017910`), sends `2C` (`030178A4`) and streams RGB565 pixels. Screen **240 × 320**
  (clipping constants 240/241 and 320/321 in `0303900C`, `03038F5C`, `03017FC4`, `030186E4`), portrait.
- **Locking:** drawing functions take the LCD mutex **`39360`** with `0300C500`/`0300C53C`; the low-level pixel and
  line helpers (`0301793C`, `030179E8`, the glyph drawers) do not and rely on the caller.
- **Colours:** RGB565 constants `0x0000` black, `0xFFFF` white, `0xC618` light grey (popup/selection), `0xF800`
  red; user colour settings index the palette `030B1770` (`3EA37`, `3EA38`, `3EA39`; inferred).
- Unreached helpers in the gap after `030178A4` (no catalog row, no reachable caller found): `030178B0` DCS `28`
  display off, `030178BC` `29` display on, `030178C8` `10` sleep in + 120 ms, `030178D8` `11` sleep out + 120 ms,
  `030178E8` 8-bit CASET. Whether a function pointer reaches them was not checked.

### 3.2 Drawing primitives (`03017884…03019D00`, one source file; code-verified unless marked)

| Address | Primitive | Arguments |
|---|---|---|
| `0301793C` | pixel (no lock) | `x, y, colour` |
| `03017BE8` | fill rectangle, end exclusive, locked | `x0, y0, x1, y1, colour` |
| `03017CBC` / `03017CD8` | fill / clear (black) the whole screen | `colour` / — |
| `03017EEC` | clear the content area y 27–289 | `colour` |
| `030179E8` | line (no lock) | `x0, y0, x1, y1, colour` |
| `03017C54` | rectangle outline (four lines), locked | `x0, x1, y0, y1, colour` |
| `0303900C` | blit RGB565 image, clipped | `x, y, w, h, pixels` |
| `03038F5C` | blit RGB565 image at a menu-row y (table `0308274F`) (medium) | `x, row, w, h, pixels` |
| `03017FC4` | blit RGB565 image streamed from data flash (`0x150000` region, boot picture, inferred) | `x, y, w, h, nbytes` |
| `03017954` | 1-bpp bitmap opaque (MSB first, `w` px per row) | `x, y, w, nbytes, bits, fg, bg` |
| `03018D78` | 1-bpp bitmap transparent (Scan List checkmark `03082BE0`, status icons) | `x, y, w, nbytes, colour, bits` |
| `0301989C` | 24-row column bitmap, white on black (medium) | `y, x, bits, w` |

### 3.3 Fonts and text

| Font | Location | Glyph | Index | Drawer |
|---|---|---|---|---|
| ASCII 12 × 24 | program flash `0307850C` | 36 bytes, 3 bytes per column, MSB at the top | `ch − 0x20` | `030186E4` |
| GB2312 hanzi 24 × 24 | **SPI data flash** `0x180000` (base word `030AEACC`, region end `0x200FFF`) | 72 bytes, column-major | `(b0 − 15 − 0xA1)·94 + (b1 − 0xA1)` (row `0xB0` = first row) | `03010E24` + `03018644` |
| GB2312 symbols 24 × 24 | **SPI data flash** `0x265000` (base word `030AEADC`) | 72 bytes | `(b0 − 0xA1)·94 + (b1 − 0xA1)` for `b0 < 0xA6` | `03010E48` + `03018644` |
| ASCII 8 × 16 | program flash `0307785C` | 16 bytes | `ch − 0x20` (others → glyph 0) | `03010E6C` + `030180C0` |
| GB2312 16 × 16 | **SPI data flash** `0xC9000` (base word `030AEABC`) | 32 bytes | GB2312 row/cell (partly read) | `03010EC4` + `030184F4` |
| Large digits 27 × 32 | program flash `03077244`, dot `03079268` | 108 bytes | digit 0–9 | `03010E0C`, `03019800` |
| Small digits 8 × 14 | program flash `030777C0` | 14 bytes | 0–9, 10 = dot | `03010E18`, `03018BAC` |

- **Text drawing:** `03018930(y, x, str, fg, bg)` is the main string drawer (149 call sites): bytes `< 0x80` are
  ASCII (12 px advance), byte pairs `≥ 0xA1` are GB2312 (24 px; `A1 E3` advances 12 px), anything else draws an
  8 × 16 block (`030184B4`); it wraps to `x = 5`, `y + 24` past `x` 216 (CJK) / 228 (ASCII). `03018AF4(y, fg, bg,
  fmt, …)` formats with `vsprintf` and centres: `x = (240 − 12·strlen) / 2` (219 call sites). Small-font strings:
  `03018790` (transparent; at most 16 or 20 characters) and `03018854` (opaque, not read in full).
- **Language:** string tables are 8-byte rows `{char **pair, 0x0201}` indexed by `3EA04` (`3E9D4+0x30`) **bit 6 × 8**;
  the pair holds the Chinese (GB2312) string first and the English string second, e.g. `030BA414` →
  `"设置成功"` / `"Setting is OK"`, `030BA6B8` → `"返回"` / `"BACK"`. So **bit 6 = 0 Chinese, 1 English**
  (code-verified from the pointer order; that 0 is the Chinese default is inferred). The same code draws both
  scripts; the language only selects the string.
- **Data-flash region table** `030AEAB0` (start/end words, also used by the CPS loops `03029FB0`/`0302A448`):
  `0x1000–0xC8FFF` (codeplug areas, 200 sectors), `0xC9000–0x149FFF` (16 × 16 font), `0x150000–0x175FFF`
  (picture), `0x180000–0x200FFF` (24 × 24 hanzi), `0x201000–0x264FFF` (tone/voice data, `0302225C`, inferred),
  `0x265000–0x27EFFF` (24 × 24 symbols), `0x278000–0x6DBFFF` (`03033534`/`03033650`, not followed),
  `0x6DC000–0xFFFFFF`. No bitmap or font data was exported.

### 3.4 Screen layout and widgets

The screen is split into a **status bar** y 0–26 (black, white line at y 26), a **content area** y 27–289 and a
**soft-key bar** y 290–319.

| Address | Widget | Confidence |
|---|---|---|
| `030193CC` | status bar with icons (GNSS, Radio Silent, battery/signal-style bitmaps; partly inferred) | medium |
| `03019B9C` | clear screen above the soft-key bar and redraw the separator | high |
| `03019BD4` | soft-key bar with left label (x 12, table `030BA698`) and `"BACK"` (x 180) | high |
| `03019C60` | right soft-key label `"BACK"` | high |
| `03019AC0` | clear one 24-px text row (row 0 = status bar) | high |
| `03019AF8` | clear the main/VFO band | low |
| `03019B80` | popup box (23,50)–(217,210) grey | high |
| `0301AB40` | popup: 48 × 48 icon at (96, 86) + two centred lines at y 144/174 | high |
| `0303A4F4` | timed popup (icon by kind, 1 s, then parent scene) | high |
| `0303A4AC` | timed popup `"Setting is OK"` | high |
| `03018C70` | menu list row 1–8: grey bar with black text when selected, else white on black (y tables `03082748`/`03082750`) | high |
| `03041530` | selection-mark column of a list | low |
| `03048554` | formatted message popup with timer | low |
| `03019800`, `03018BAC` | frequency in large / small digits | high / medium |

Scene functions were not reviewed; only the ones on the followed path are named. `03018E68` (1248 bytes, channel
panel), `03019570`, `030199BC`, `03019CF0` (string drawer variant), `03018854`, `03018168`, `0301859C`,
`030184F4`, `03017A98`, `03018A30`, `03018CE4`, `03018DFC` and `03019C34`/`03019C98`/`03019CC4` belong to the
same layer and stay unreviewed (§6).

## 4. Owner observations (optional, receive only, no transmission)

Not needed for the naming. If the owner wants to confirm display facts, these can be checked by looking at the
screen, without pressing PTT and with the radio on a receive-only test channel: (1) switching the menu language
changes only the strings, not the layout (Chinese ↔ English, setting behind `3EA04` bit 6); (2) a successful
setting shows a 1-second popup with an icon and "Setting is OK"; (3) the status bar is about 1/12 of the height and
the soft-key bar shows "BACK" at the right.

## 5. Open questions

- `0x1100003C` written by the LCD init: HR_C7000 register or pin-mux? Check against the datasheet register map.
- GPIO 70 role (backlight or LCD chip select) and the polarity of GNSS GPIO `0x2C` / audio GPIO `0x2F`.
- Users of SPI ports 1–3 (`0x140B0000`, `0x140E0000`, `0x14150000`).
- Contents of data-flash regions `0x278000–0x6DBFFF` and `0x6DC000–` and whether `0x201000` holds voice prompts.
- Whether the unreached DCS helpers `030178B0…030178E8` are reached through a pointer (display off/sleep).

## 6. Left unreviewed

The display-layer rows listed at the end of §3.4, the GB2312 16 × 16 drawer bodies (`030184F4`, `03018168`,
`0301859C`), the menu scenes and the text-editor internals beyond the hubs. No hardware test is pending for this
work.

## 7. Catalog and tagger

116 rows changed (76 work-list + 40 on the display/data-flash path); all were `unreviewed` before. Totals:

| | high | medium | low | unreviewed | `auto:` |
|---|---:|---:|---:|---:|---:|
| before (`1c4bb96`) | 296 | 258 | 33 | 1584 | 848 |
| after | 377 | 280 | 46 | 1468 | 795 |

Tagger check (recorded in [SUBSYSTEM_TAGS.md](SUBSYSTEM_TAGS.md) §7): 53 reviewed rows carried an `auto:` tag; 28
were `shared (UI tasks)` (true by construction, not counted). Of the 25 decided tags **10 agree** and **15
disagree**; the main cause is that the tagger has no display tag and did not know the LCD base `0x12000000`.

## 8. Pass 3, work item P1 — code relevant to TS/CC Match and CPS compatibility (2026-10-18)

Static only (inputs re-checked: stock `de7dbcbc…`, installed `156a4872…`, GZF `354f9324…`, datasheet `d60f652e…`;
binutils 2.42 through `tools/dm32`, datasheet text with `pdftotext -layout`). No serial port, no CPS word, no radio
access, no image file written.

**Work list.** Every `unreviewed` row tagged `auto: Codeplug/channels` (20), `auto: Baseband registers` (48),
`auto: shared (DMR tasks)` (28), `auto: CPS/USB` (37), `auto: Digital RX/DMR` (7), `auto: Digital TX/DMR` (11) and
`auto: Digital TX/DMR data` (3): **154 rows, all read**. On the way 17 more rows were read and named (the mode-4
timer helpers, the SPI port and program-flash helpers they call, the DAC writer, two GPIO/pin-mux helpers), and two
reviewed rows were corrected (`03067474`, `0002C3B8`). 171 catalog rows changed; confidence of the 169 new rows:
**95 high, 62 medium, 12 low**. Per-row roles are in the catalog (`evidence` = "pass 3 P1").

### 8.1 Results by group

| Group | Rows | Main result (labels as in the catalog) |
|---|---:|---|
| HR_C7000 registers | 24 | Register names from the datasheet tables (system control, baseband control, link layer, FM; §10 of [HR_C7000_CROSSCHECK.md](HR_C7000_CROSSCHECK.md)): FM bandwidth `0300C2CC`, ADC enable `0301E4D0`, line out `03021AD8`, two-point modulation `03021748`/`03021788`, IQ centre `03021764`, PHY test `030216F4`, TX voice source `0305D1D8`, AHB voice read `00016104`, PCM interrupt clear `0002E378`/`0002E388`, the layer-2 slot set-up `030231A8`/`030231C0`/`03023258`/`03023A88`/`03023AD8` (datasheet + code) |
| DCDM (RX mode 4) | 20 | The channel-timing (CT_CSBK) state machine `3BED8`/`3BEEC` with four OS timers (`35358` periodic, `35390`, `3548C`, `36490` one-shot) — and a transmitter: **`03024224` queues CT_CSBK bursts on its own** (§8.2) |
| CPS/USB | 31 | The CPS link is **UART0** (`0x14030000`, ops table `18000A88`: read `0302B680`, write `0302B798`); program flash is an SPI NOR behind the LCSFC controller (`0002BCA8` command issue, `0002BDEC` erase, `0002BEBC` program, `0002BE7C` read); the `SYSINFO` `C` command is a read-modify-erase-write of the **4 KiB program-flash page `0x0300B000`** (`0301C98C`); CPS `V` item 2 is an 8-byte ID read from **SPI port 3** (`0301C950`); the `PCTESTM` `W` parameters go through the SRAM table `18000AC0` (DAC power, IQ centre, modulation, deviation, sub-audio) and `030553C0` loads the area-2 TX calibration |
| SD card (SPI1) | 9 | A complete SD-card SPI-mode driver (CMD0/8/9/12/16/17/18/24/25/55/58, ACMD23/41, SDHC by card type `33C60`) on SPI port 1 with chip select GPIO 23; its init code (`03066F18`, `03067216…`) is **not reached** from any catalog entry and nothing writes the card type, so the driver is **dormant** (inferred). **Correction:** the CPS `PROGRAM`-loop command `D` calls `03067474` = **SD block read** (`CMD17`/`CMD18`, 512-byte blocks, reply `W` + data), not a data-flash erase (§8.3) |
| Codeplug/channels | 20 | Per-field channel setters, all with the same pattern (mutex `3E34C`, working copy `3E1F8` when a roaming candidate is active, else `0300FA28` on the record byte): squelch `0300DE8C`, VOX `0301BDB4` (body `0x15` bit 4), scan list `0302F59C`, power `03030EDC`, signalling `03031060`, **Talk Around `030566CC` = body `0x1A` bit 3** (the "fw-only" bit of [CHANNEL_RECORD.md](CHANNEL_RECORD.md)), RX group list `030573A0`, DMR ID `03057688`, key `0305CFF0`, encryption `0305D0A0`, APRS `03062744`/`03062828`; the factory reset / default-codeplug writer `030323F4`; four list scenes |
| Data / TX queue | 14 | `txmsg` body `0301F118`, SMS/data builders (`03026BB8`, `03027050`, IPv4/UDP header `03025BC0`), CRC-9 `0300C154` and CRC-32 `0300C224` (polynomial constants), voice LC header / PI header queueing `0302958C`/`03029618`, data terminator `030268CC`, queue depth `03029E4C` |
| Privacy | 25 | AES (S-box `180011A4`, SubBytes/ShiftRows/MixColumns/AddRoundKey, Nr 10/14), IV update LFSRs, received-IV check with debug labels "IV err:"/"IV ok:" going to empty print stubs, TX voice encryption `000157F4` |
| Boot / other | 18 | Clock set-up `0002C9B8`, program-flash quad mode `0002BB9C`, codec init `03021AF8`, PWM/DAC pin mux, PA GPIOs low and task `cds` `0301D550`, power-on factory-reset key check `0305F4D4`, recording playback `03061D50`, RTOS wait wrappers of `sysint`/`txslot`/`CclTraffic` |

### 8.2 Findings that matter for TX, the TS/CC Match design and CPS compatibility

1. **New autonomous transmitter: DCDM channel timing (code-verified flow; RF emission inferred from the queue).** When
   a channel with the DCDM ("Double Slot", record `0x1D` bit 5) bit is loaded, `0301E580` calls `03024120`, which
   arms the 270 s timer `36490`. If no timing leader is heard, `030243A0` makes the radio the leader, a random backoff
   (`030241A4`, `rand()`) arms timer `3548C`, and its callback `03024224` queues CT_CSBK bursts (`03029464` →
   `030294C8`) after `03023290(4, 2)`; the cycle repeats every 120 s (`0300C6AC(120000)`). Received CT_CSBKs
   (`03024908`) re-time or join the leader. The only gate in the chain is the carrier flag / own TX queue
   (`0300C3AC`, `3C6FC[3BEAC]`); **no Rx Only, CPS-session or stun test** was found in `03024120…03024794`
   (inferred, direct calls and the timer callbacks followed). Added to [TX_PATHS.md](TX_PATHS.md) and
   [AUTONOMOUS_TX.md](AUTONOMOUS_TX.md). It runs only in RX mode 4, which TS/CC Match does not touch.
2. **Boot-time `FM_PTT = 1` is baseband-only (inferred).** `000169D8` (saved/restored by `00016AD0`), called once at
   boot through `00015D8C`, sets WORK_MODE FM and `FM_PTT = 1` during the vocoder/codec start-up. Its call subtree
   (direct calls, depth 6) contains no PA (`0002C83C`), RF-chip (`0002C2F8`) or power-ramp (`0002B364`) call, and
   `0301D550` drives both PA GPIOs low at boot; so this keys only the baseband modulator (closes the open item of
   `TX_PATHS.md` §8).
3. **TS/CC Match design: no change.** None of the 154 functions reads or writes `33CCC`, `3BEA8`, `3C620`,
   `3C61A`, `33CCD` or the gate registers; the only new reader of a per-burst field is `030237AC` (TX slot chooser
   input `3C616` = sync type of the last burst), which has the same value (BS) for both slots of a repeater, so TS
   Match off does not change it. The DCDM state machine runs only in RX mode 4 and stays a read-only subject. The
   read-only subject list of `MATCH_OPTIONS_DESIGN.md` §3.10 gains `030237AC` and the DCDM chain (§3.10.10 there).
4. **CPS compatibility: one correction, one addition.** `D` is a dormant SD-card read, so a `PROGRAM` session can
   only erase data flash through sector-aligned `W` writes (the rule "a CPS write replaces whole sectors" stands).
   The `SYSINFO` `C` command rewrites the program-flash page `0x0300B000`, i.e. the 4 KiB **in front of the
   application** — a mod must not place code or data there ([CPS_PROTOCOL.md](CPS_PROTOCOL.md) §2.2, §5).

### 8.3 Tagger agreement (P1 rows)

Of the 169 newly reviewed rows, 155 carried an `auto:` tag; 29 `shared (…)` rows are not counted. Of the 126
decided tags **51 agree** (40 %): Codeplug/channels 14 of 20, Baseband registers 13 of 48, CPS/USB 13 of 37,
Digital TX/DMR 5 of 11, Digital TX/DMR data 3 of 3, Digital RX/DMR 3 of 7. Main causes: the IRAM privacy and
vocoder code and the mode-4 timer code sit next to baseband code (neighbourhood and RAM evidence), program-flash,
SPI and SD helpers are reached from the CPS task, and menu scenes that set channel fields read like codeplug code.
Recorded in [SUBSYSTEM_TAGS.md](SUBSYSTEM_TAGS.md) §8.

### 8.4 Left open (P1)

The privacy bit-transform `0001496C` and its helpers (`low`), the vocoder frame processing `00016838`, the
LCSFC status compare in `0002BC7C`, and the meaning of the CT_CSBK fields beyond the ETSI DCDM reading.

## 9. Pass 3, work item P2 — second-tier hubs (5–9 direct callers, 2026-10-18)

Work list: every `unreviewed` row with 5–9 `known_direct_callers` after P1 — **74 rows** (81 before P1; 7 were
reviewed in P1). All 74 read like §2 (role, arguments, return, side effects, RAM/MMIO). Result: **13 high, 41 medium,
20 low**; the low rows are mostly IRAM vocoder arithmetic and text-editor drawing whose exact formulas were not
followed. Per-row text is in the catalog (`evidence` = "pass 3 P2").

### 9.1 Groups

| Group | Addresses | Notes |
|---|---|---|
| Storage | `0300F5B4` spare-sector allocator, `0300FB58` 128-byte-chunk copy-on-write area writer, `0002BA60` absolute data-flash write | the copy-on-write family of §2.2 is now complete (`0300F878`, `0300FA28`, `0300FB58`, `0300FDA4` all take a spare via `0300F5B4`) |
| Channels / VFO | `03031658` working-copy builder, `030314B8` TX frequency (**record `0x1A` bits 1:0 = shift direction** none/+/−), `0002DF30` VFO copy, `0304A200` zone headers, `0304A39C`, `03064C9C`, `0300D810` analog-only band, `03055D3C`, `03057654` DMR ID list (area `0x67`), `030567EC` | |
| Contacts / messages / Call Log | `03033274` count, **`030332AC` contact locator: 24-byte records, 170 per area, areas `0x43`+**, `030332E0` read, `0303331C` search, `030396A0` pick; `03052ED8`/`03054110` message boxes (areas 7–10); `03058984` Call Log clear | adds areas `0x43…` to the area map of [CPS_PROTOCOL.md](CPS_PROTOCOL.md) §4.2 |
| Menu framework / editor | `0303B374` (the redraw prologue of §3.10.9), `0304735C` `show_message`, **`03059D5C` manual-ID validation**, number/text editor `0305953C`, `03059C90`, `0305A1D0`, `0305A464`, `0305A4FC`, list inits `0303972C`/`0303976C`, `03052E28` notice | |
| Display | `03018854` small-font string drawer, home date/time `0301B5F0`, VFO frequency/icons `030306C8`/`030305B8`, indicator `0301A464`, `03060460` | |
| RF / audio | `0002B50C`/`0002B514` RF reg 0x50 unmute/mute wrappers, `0300F124` RF reg 0x24 = 0, `0300DF08` analog RX restore, `03023028` audio gain, `030397E0` per-event alert tones, tone sample timer **`0301D858` start / `0301D878` stop** (hardware timer 2) | |
| FM broadcast radio | bit-banged two-wire bus on **GPIO 25 (data) / 26 (clock)**, device address `0x20` (`03065C48`, `03065D0C`, `03065D60`; RDA5807-class receiver inferred), pause/resume `03065FF0`/`03065FD8` | |
| Misc | RTC date conversion `0301C238`, recording sector lookup/count `0300F52C`/`03010CF8`, hardware timer disable `0002CBEC`, tick wait `0305FDEC`, LED GPIO 33 `030611F4`, call hang clear `0301E850`, `03021598`, `03055A1C`, delays and stubs, `__floatunsidf` `0306FC60`, IRAM vocoder helpers `00018C9C`…`0001ADA0` | |

### 9.2 API pairs (call sites checked with `Xrefs.callers_of`)

| Pair | Result |
|---|---|
| tone timer `0301D858` start / `0301D878` stop | every one of the 8 functions that stops the timer also starts it; `03022190` only starts it (its stop is in the tone task `03022410`) — pairs match |
| RF reg 0x50 unmute `0002B50C` / mute `0002B514` | split by role: unmute at TX/tone start (`0305BE64`, `03061648`, `03065114`, PCTESTM, sweep, Remote Monitor), mute at TX/tone end (`030601CC`, `03068A88`, `03068B4C`, `03068C1C`, `03068D04`, `0305C1E0`); only the DTMF keypad `03059904` does both — consistent with a start/end pair |
| FM pause `03065FF0` / change `03065FD8` | no common caller: pause at call/TX starts, the other at call/scene ends — consistent pair (direction of `03065FD8` low) |
| data-flash mutex `39468` | `0300FB58`, `03010CF8` pend and post it on every path read (like §2.1) |

### 9.3 What P2 changes elsewhere

- **`MATCH_OPTIONS_DESIGN.md` §3.10.9 (keys stack):** the branch "`03059D5C() == 0`" in the PTT handler is the
  **invalid manual-ID** case (error popup + redraw), not "a PTT event while a menu scene is active". The deep redraw
  path is therefore rarer than assumed; the verdict (most likely benign, T9 must stay a frameless leaf) is unchanged.
- **`CHANNEL_RECORD.md`:** byte `0x1A` bits 1:0 = repeater shift direction (0 none, 1 +, 2 −; `030314B8`).
- **`CPS_PROTOCOL.md` §4.2:** contact records live in areas `0x43…` (170 × 24 bytes each), area 11 holds the header.
- No P2 function touches the TS/CC Match sites or the TX admit inputs.
