# Channel record: qdmr codeplug layout vs. DM32.NRF.01.049 firmware

Static analysis 2026-10-14, stock image `de7dbcbc…`, `tools/dm32` (binutils 2.42) and Ghidra 12.1.4 GZF decompilation.
Reference: [hmatuschek/qdmr](https://github.com/hmatuschek/qdmr) `lib/dm32uv_codeplug.{hh,cc}` at commit
`fb9c96af53f646c0706fa360209b2e0e6cd79a08` (2026-09-08, GPL-3.0; used as a reference only, no code copied).
No hardware test, no serial access.

## 1. Where the firmware reads a channel (code-verified)

- `03055CCC(n, &block, &off)` locates channel `n` (1-based) in the data-flash codeplug: `n < 0x55` → block `0x12`,
  `off = (n-1)*0x30 + 0x20`; otherwise block `0x13 + (n-0x54-1)/0x55`, `off = ((n-0x54-1)%0x55)*0x30 + 0x10`.
  That is the **channel body at record+0x10**, with records of `0x30` bytes, 84 channels after a 16-byte header in
  block `0x12` (`0x12000`) and 85 per following 4 KB block, exactly qdmr's `ChannelBankElement`
  (`channelBanks()=0x12000`, `channelBlock0()=0x10`, `channelsInBlock0()=84`, `channelsPerBlock()=85`).
- `03055D3C` returns `off - 0x10`: the 16-byte name at record+0x00 (qdmr `name()`, 16 bytes).
- `03031658(dst, vfo)` builds the 51-byte (`0x33`) working copy: reads 32 bytes of the body with `0300F780`,
  converts bytes 0–3 and 4–7 from BCD with `0305F904` (RX/TX frequency, 10 Hz units), copies body bytes
  `0x08–0x1F` verbatim (`0002B338`, 24 bytes), reads the name into `+0x20` (`0305655C`) and puts a 16-bit value
  from `030565F4` at `+0x31`. It clears `+0x08` bits 7:4 (type → analog) when `0300D810(rx_freq) == 1`.
  Callers copy it to the **current channel at RAM `3E1F8`** with `03070B88` (`memcpy`, n = 51), e.g. `0301CF16`.
- Write-back is per field into the same flash bytes, e.g. `03056FFC` (Time Slot) gets the body address from
  `03056680` (→ `03055CCC`) and rewrites flash byte `body+0x0D` together with `3E1F8+0x0D` bit 4.
- VFO A/B bodies live in block `0x41` at `0xFAF` / `0xFDF` (`03031658`, `03056680`; selected by `3EA01` bits).
  qdmr does not model these VFO records.

So for the 32 body bytes: **`3E1F8 + k` = record byte `0x10 + k`** (frequencies converted from BCD), and
`3E1F8 + 0x20…0x2F` = record name.

## 2. Field map

Bits are `msb:lsb`. "fw" lists the masks the firmware uses on the RAM copy (`ins` writes, `andi`/`zext` reads;
byte accesses only, found by `tools/dm32` constant tracking) and example functions.

| Record | `3E1F8+` | qdmr field (bits) | Firmware use | Agreement |
|---|---|---|---|---|
| `0x00–0x0F` | `+0x20` | name, ASCII 16 | read by `0305655C` | ✓ |
| `0x10–0x13` | `+0x00` | rxFrequency, BCD ×10 Hz | BCD → int (`0305F904`) | ✓ |
| `0x14–0x17` | `+0x04` | txFrequency, BCD, `FFFFFFFF` = none | same | ✓ |
| `0x18` | `+0x08` | channelType 5:4 (FM, DMR, FM fixed, DMR fixed) | **7:4** (`ins 7,4`, 17 writers; `030570E8` setting `'D'`; value 1 = digital routes DMR in `03056330`) | ≈ field is 4 bits in fw |
| `0x18` | `+0x08` | rxOnly 3 | `&0x08` (12 readers) | ✓ |
| `0x18` | `+0x08` | power 2:1 (low/mid/high) | `ins 2,1`, `zext 2,1` (`0304B158`) | ✓ |
| `0x18` | `+0x08` | loneWorker 0 | toggled at `03016074` (`03015FD4`) | ✓ |
| `0x19` | `+0x09` | bandwidth 7 | `ins 7,7` (9 writers), `zext 7,7` | ✓ |
| `0x19` | `+0x09` | scanListIndex **6:2** (1-based) | **5:0**: `0304B158` setting 50 writes `ins 5,0`; `andi 63` then scan-list loader `0302E1A4` (`0304D14E`, `0304D998`); `0302F418` scan start | ✗ qdmr offset/width disagree with fw |
| `0x1A` | `+0x0A` | preventTalkaround 7 | `ins 7,7` (`030175F4`) | ✓ |
| `0x1A` | `+0x0A` | admitCriterion 5:4 | `&0x70` (6:4) | ≈ |
| `0x1A` | `+0x0A` | — | bit 3 written by `030566CC(v&1)` | fw-only, unknown |
| `0x1A` | `+0x0A` | rxDMRAPRS 2 | `zext 2,2`, `&0x04` | ✓ |
| `0x1A` | `+0x0A` | — | `&0x03` read | fw-only, unknown |
| `0x1B` | `+0x0B` | emergencyNotification 7, emergencyACK 6, emergencySystemIndex 2:0 | only whole-word reads seen | not checked |
| `0x1C` | `+0x0C` | squelchLevel 7:4 | `ins 7,4`, `zext 7,4` | ✓ |
| `0x1C` | `+0x0C` | dmrAPRS 2 | `ins 3,2` (`03062744`) | ≈ fw uses 2 bits |
| `0x1D` | `+0x0D` | colorcode 3:0 | `ins 3,0` (`030572B8` setting `'3'`), `&0x0F` | ✓ (TS_ANALYSIS §1) |
| `0x1D` | `+0x0D` | timeslot 4 (0 = TS1) | `ins 4,4` (`03056FFC` setting 5), `&0x10`, home screen T1/T2 | ✓ |
| `0x1D` | `+0x0D` | **dcdm** 5 | `ins 5,5` (`030571CC` setting `'F'`), selects RX mode 4 in `03056330` | ✓ — names the bit: **DCDM / Double Slot** (was "probably Double Slot") |
| `0x1D` | `+0x0D` | dataACK 6, privateCallACK 7 | no byte-level access found | not checked |
| `0x1E` | `+0x0E` | keyIndex u8 (0 = none) | whole-word reads | not checked |
| `0x1F` | `+0x0F` | encryptionEnable 6 | `ins 6,6` (`0305D0A0`), toggle at `03015E08`, `&0x40` | ✓ |
| `0x1F` | `+0x0F` | groupListIndex 5:0 | `ins 5,0` (`030573A0`), `&0x3F` | ✓ |
| `0x20` | `+0x10` | dmrAPRSChannelIndex 3:0 | no byte-level access found | not checked |
| `0x21–0x22` | `+0x11` | rxTone u16 LE, `FFFF` = off | 16-bit assembly/stores, `FFFF` cleared (`03055154`, `0303654C`) | ✓ |
| `0x23–0x24` | `+0x13` | txTone u16 LE | same | ✓ |
| `0x25` | `+0x15` | vox 4 | `ins 4,4` (`0301BDB4`) | ✓ |
| `0x26` | `+0x16` | showPTTId 7, optSigEnable 4, optSigType 0 (offsets declared, not implemented in qdmr) | `ins 6,4` / `zext 6,4` (`03031060`), `&0x0E` / `zext 3,1` | ≈ fw uses 6:4 and 3:1 |
| `0x29` | `+0x19` | pttIdEnable 2 (declared, not implemented) | `0304B158` setting 66 (`'B'`) writes 7:4; reads `zext 3,2`, `zext 2,2` | fw-only 7:4 |
| `0x2B` | `+0x1B` | dmrIdIndex u8 | read with `lsli 4` (index × 16) | ✓ |

## 3. Findings

- The working copy at `3E1F8` is a code-verified mirror of the codeplug record: body bytes at `+0x00…+0x1F`,
  name at `+0x20`. Every field already documented in TS_ANALYSIS/CC_MATCH_ANALYSIS (type, CC, TS, bit 5) sits
  where qdmr places it, and qdmr's name for bit 5 of `0x1D` is **DCDM** (dual capacity direct mode, the CPS
  "Double Slot"), matching the firmware's RX mode 4 on simplex channels.
- qdmr differences to keep in mind if the owner programs with qdmr (not tested on a radio):
  scan list index (qdmr 6:2, firmware 5:0); channel type, admit and some signalling fields are wider in the
  firmware; `0x1A` bit 3, `0x26` bits 3:1/6:4 and `0x29` bits 7:4 are used by the firmware but not by qdmr.
  In qdmr itself, `enableEmergencyNotification()` writes the `emergencySystemIndex()` offset (`0x1B` bit 0)
  instead of `emergencyNotification()` (`0x1B` bit 7) — a qdmr bug, seen in source only.
- For planned TS/CC Match settings: byte `0x1D` is fully used (CC, TS, DCDM, data ACK, private ACK), so a
  per-channel flag would need a byte both the official CPS and the firmware leave alone. Candidates
  (`0x27`, `0x28`, `0x2A`, `0x2C–0x2F`; no byte access seen in fw) are **inferred unused** only; CPS behaviour
  for them is unknown. A global setting outside the channel record keeps CPS compatibility simpler.
