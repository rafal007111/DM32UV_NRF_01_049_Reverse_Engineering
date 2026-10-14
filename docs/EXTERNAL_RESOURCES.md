# External resources for DM32.NRF.01.049 work (surveyed 2026-10-14)

Web/GitHub survey for tools and documents useful to this project. Nothing below was run against the radio;
serial tools are listed for the **owner** only (AGENTS.md: agents never open a serial port or write the radio).
Third-party binaries and documents are not copied into this repository.

## HR_C7000 datasheet (highest value)

Document 2 is versioned in this repository as [`docs/HR_C7000 Document 2.pdf`](HR_C7000%20Document%202.pdf)
(Chinese, 412 pages, Word 2010 export dated 2017-07-19, SHA-256
`d60f652e114d5103b2252be604089528775dffa263c703545d7cfed9fe490253`, 9 913 753 bytes; identical to the copy in
[yo3hjv/Baofeng-DM32 `chipset_docs/`](https://github.com/yo3hjv/Baofeng-DM32/tree/main/chipset_docs), originally
connectsystems.com). Document 1 (96 pages, SHA-256 `a2507062…ca52`) is only in that mirror. Page numbers below are
PDF pages of Document 2 (they equal the printed "第 N 页" numbers). Memory map p. 89:
`0x1100_0000–0x1100_FFFF` = Modem (64 KB). Registers from §4.6.5 (baseband system control) and §10.2 (DMR layer 2,
register table 28 on p. 297), base `0x1100_0000`:

| Register | Offset | Page | Datasheet fields (translated) | Firmware cross-check (tools/dm32) |
|---|---|---|---|---|
| `WORK_MODE` | `0x100` | 97 (§4.6.5.7) | bit8 digital+analog auto-detect; bit7 0=DMR/1=FM; bit6 TierI/II; bit5 continuous/TDMA; [4:3] layer mode; bit2 repeater; bit1 aligned; **bit0 `work_slot_sel` 0=TS1, 1=TS2** | written by `0301ECC0` (bit0), `0301E580`, `030215C8`, IRAM `000169D8`/`00016AD0` |
| `LOCAL_CC` | `0x384` | 301 (§10.2.2.11) | bit16 encryption type; **[9:8] `cc_opt`: 0 = decode only frames whose CC equals local CC; 1 = decode frames with any correctly received CC; 2/3 = decode nothing**; [3:0] local CC (default 1) | `0301EC40` clears [9:8] and sets bit8 when Monitor is on → `cc_opt=1`; IRAM `0002D7C8` writes [3:0] |
| `RX_TYPE_INFO` | `0x390` | 302 (§10.2.2.14) | RO: [30] CRC8 err, [29] Golay err, [28] QR err, [27] checksum err, [26] CRC16 err, [25] RS24 err, [24] data block err, [23] CACH AT, [22] CACH TC, [21:20] CACH LCSS, **[19] current RX slot**, [17] PI, [16:15] LCSS, [14:12] voice burst A–F, **[11:8] data type, [7:4] received CC**, [3:2] sync type MS/BS/TDMA1/TDMA2, [1:0] none/voice/data/RC | `0002C458` copies it to RAM `3BECC`; `03028644` extracts exactly these fields; also read by `0002D500`, `03024868`, `03027B9C`, `030282A4` |
| `LAYER2_CONTROL` | `0x400` | 303 (§10.2.2.16) | txen/rxen sync enables, slot master/slave modes | – |
| `LAYER2_SLOTON` | `0x404` | 304 (§10.2.2.17) | RX/TX slot-on flags and controls (layer-2) | – |
| `LAYER2_TXRX_CTRL` | `0x408` | 305 (§10.2.2.18) | TX complete, layer-2 RX sync-loss control, … | IRAM `0002D7C8`, `030215C8` |

Status: register semantics are **datasheet-documented**; the firmware sites are **code-verified** (instruction
level). Together they make the Monitor hypothesis concrete: bit 8 of `11000384` switches the hardware to accept
any valid CC (previously "not established" in RE_NOTES). Software CC checks in the handlers (CC_MATCH_ANALYSIS.md)
still apply on top. Not hardware-verified. The datasheet is a 2017 revision; confirm against behaviour.

## Codeplug layout (CPS compatibility)

- [hmatuschek/qdmr](https://github.com/hmatuschek/qdmr) `lib/dm32uv_codeplug.{hh,cc}` (≈7 000 lines, commit
  `fb9c96af`, 2026-09-08): full DM-32UV codeplug map, e.g. 48-byte channel record with `timeslot` bit at
  `0x1D:4`, `colorcode` at `0x1D:0`, `admitCriterion` `0x1A:4`, `rxOnly` `0x18:3`; plus `dm32uv_interface.cc`
  (programming protocol). GPL-3.0: use as reference, do not copy code into this repo.
- [infamy/NeonPlug](https://github.com/infamy/NeonPlug) `src/radios/dm32uv/` (TypeScript, ≈9 500 lines):
  web CPS with byte-level structures, block layouts and a write guard.

Use: map the firmware's channel-record readers to these fields before adding TS/CC Match settings.

## Firmware corpus and community patches

- [M7OCM/DM-32UV](https://github.com/M7OCM/DM-32UV): firmware `DM32.01.01.{032…049}`, `01.02.046`, `L01.048`,
  `DM32_Fanti_049_20251106.bin` (= `DM32.NRF.02.049`) and **`DM32_NRF_049_20251017.bin`, byte-identical to our
  official wrapper** (SHA-256 `aff6b4dc…52dd`, checked 2026-10-14). Branch `Mods`: RA4FHE band mods,
  `no_check_ALPU`, and IU2VTP's documented 6-byte GPS NMEA fix for `01.L01.048` (`%04.4f`/`%05.4f` →
  `%09.4f`/`%010.4f`). The same format strings exist in NRF.01.049 at `030B86B0`/`030B86B8`, used by `03062A54`
  next to `$GPRMC` (inferred: same longitude padding bug; not tested).
- [Chicago-Offline/dm32-info](https://github.com/Chicago-Offline/dm32-info): version tracking with hashes,
  hardware notes (HR_C7000 CK803S, RF chip FD6818: RSSI register `0x67`, noise `0x65`; ALPU-MP on I2C; ILI9341;
  ATGM336H GPS), AES constant-IV analysis verified on air for NRF.01.049 with dsd-fme + RTL-SDR.
- [gzalo/dm32-uv](https://github.com/gzalo/dm32-uv): HR_C7000 ROM bootloader protocol (115200 8N1; `02 24 00 03`
  hello, `02 18` write memory, `02 1B` execute), DR5800 service manual link (same MCU, schematics/calibration),
  XuanTie CDS toolchain link (V5.2.31).
- [yo3hjv/Baofeng-DM32](https://github.com/yo3hjv/Baofeng-DM32): flash dumps, calibration files, annotated board
  photo, datasheets. Warning there: a program flash restored from another radio reports "Incorrect HW version";
  keep this radio's own backups.
- OpenDM32 / OpenGD77 port (Koshak, andynvkz, VK3KYY): binaries on infotex58.ru topic 1168, source unpublished.
  A closed binary for the same chip; usable as a second C-SKY corpus for register usage, not as source.

## Owner-side tools (serial; never from an agent)

- [rogerclarkmelbourne/DM32](https://github.com/rogerclarkmelbourne/DM32) `python/`: `C7000_read_progmem.py`
  (program flash GD25Q08 via the ROM bootloader and uploaded C-SKY microcode), `C7000_read_Q128.py` /
  `dm32_read_Q128.py` (16 MB data flash), write counterparts, `DM32_firmware_loader.py` (Baofeng bootloader).
  Independent readback for install verification.
- dsd-fme + RTL-SDR: receive-only decoding of CC, slot and data type on air, to prepare and check RX tests.

## Analysis tools worth adding later

- [clearbluejar/ghidriff](https://github.com/clearbluejar/ghidriff): command-line Ghidra diffing (accepts GZF),
  for NRF.01.049 vs NRF.02.049 / 01.01.049 / L01.048. `tools/dm32 similar` covers rough matching meanwhile.
- XuanTie CDS / C-SKY toolchains (xrvm.cn): newer vendor GCC builds for compiler fingerprinting.
- Not found: a public Ghidra/IDA C-SKY module besides the legacy one used here; QEMU support for CK803.
