# TS Match / CC Match receive options — patch design inventory (design only)

Status: **inferred design, nothing built, no image produced, nothing to install.** Written 2026-10-14 from static
analysis only (inputs and tools as in `RX_CALL_PATH_ANALYSIS.md` §0). Every site below must be re-audited with the
pinned toolchain and the AGENTS.md image rules (exact baseline hash, guarded bytes, placement/size, branch targets,
boot prefix/startup/heap invariants, full-image comparison) before anyone proposes an image. TX/PTT behaviour and
CPS/codeplug compatibility must stay unchanged.

## 1. Behaviour to implement

| Option | Off (non-stock) behaviour | Must not change |
|---|---|---|
| CC Match off | accept **voice** (LC header, terminator, embedded/late entry, voice bursts) with any received CC; keep talkgroup/private filters (unlike Monitor) | data, CSBK and PI-header CC checks (`DATA_PATH_ANALYSIS.md` §8), TX admit `03027334`, mode-4 CC 15 rules |
| TS Match off | receive the other time slot on repeater (mode 1) and simplex (mode 0) channels with **one captured slot** at a time | TX slot `33CCB`, `3BEAA`/`3BEAC`, `11000100` bit 0, `0002D6C0` channel-busy logic, mode 2/4 gates |

## 2. State and storage (inferred choices)

| Item | Proposed location | Evidence that it is free |
|---|---|---|
| Runtime flags | `3BA6D` bit 5 (CC off), bit 6 (TS off) | all decompiled and disassembled accesses use masks 1, 2, 4, 8, `0x10`, `0x11` (`SETTINGS_CPS_ANALYSIS.md` §2); `3BA6C` has no free bit |
| Persistent flags | block 4 `0x60` bit 2 (CC off), bit 3 (TS off) | only readers are `0304B010` (bits 0/1) and `0304B158` settings 9/10 (read-modify-write) |
| Menu | Other Func entries 22/23 after `MOTO` (descriptor `030B9708`, case table `030B22F0`, bound `0304FF9E`) | string list and table layout in `SETTINGS_CPS_ANALYSIS.md` §1.4 |
| Boot load | extend the `0304B010` path that already reads `0x60` and calls `0301ECF0` | code-verified loader |

Open: whether CPS preserves bits 2–7 of block 4 `0x60` (owner read-only CPS check).

## 3. Site inventory (stock bytes; identical in the installed image `156a4872…`)

Bytes are in image order (little-endian halfwords; 32-bit instructions are stored high halfword first).

### 3.1 CC sites — all use the Monitor idiom `lrw r3,3BA54; ld.b r3,(r3,0x18); andi r3,r3,8; zextb r3; bez drop`

| Function / role | VA | Stock bytes | Proposed change |
|---|---|---|---|
| `03028180` terminator | `0302819C` | `73 13 78 83 63 e4 08 20 cc 74 03 e9` | replace `ld.b`+`andi` (6 bytes at `0302819E`) by `bsr cc_bypass` + `nop`, result in `r3` |
| `030282A4` voice LC header | `030282D0` | `66 11 78 83 63 e4 08 20 cc 74 03 e9` | same at `030282D2` |
| `03028644` data-sync dispatcher | `03028B5E` | `72 10 78 83 63 e4 08 20 cc 74 03 e9` | same at `03028B60` (data handlers re-check CC themselves, so data stays CC-gated) |
| `03028BE4` embedded LC / late entry | `03028CE8` | `08 0c 59 10 58 82 42 e4 08 20 88 74 02 e9` | same pattern on `r2` at `03028CEC`; here `r3` still holds the status word (used at `03028CF8`) and must be preserved |
| `03028644` embedded-CC mismatch counter | `030289E2` | `6d 10 65 83 4e 65 2c 0c` (`lrw; ld.b r3,(r3,5); cmpne r3,r5; bf reset`) | when CC off, take the reset path (else long foreign-CC calls without sync get cut after 7 bursts) |

`cc_bypass` (cave): `return (3BA6C & 8) | (3BA6D & 0x20)`, clobbering only the register the site tests (`r3`, or `r2` at
`03028CEC`). All four host functions push `r15` in their prologue, so a `bsr` is safe (code-verified prologues:
`03028180` `push r4,r15`; `030282A4` `push r4-r7,r15`; `03028644` `push r4-r9,r15`; `03028BE4` `push r4-r8,r15`).

### 3.2 TS sites — BS-sourced slot gate `ld.b (3BEA8); ld.b (33CC8+4); cmpne; bt drop`

| Function / mode | VA | Stock bytes |
|---|---|---|
| `03028644` mode 0 | `03028708` | `6f 12 40 83 6f 12 64 83 ca 64 60 e8 68 02` |
| `03028644` mode 1 | `030287B8` | `63 11 40 83 63 11 64 83 ca 64 60 e8 10 02` |
| `03028BE4` mode 0 | `03028C32` | `4a 12 20 82 48 12 44 82 86 64 60 e8 6b 03` |
| `03028BE4` mode 1 | `03028C74` | `59 11 20 82 57 11 44 82 86 64 60 e8 4a 03` |

Proposed change: replace `cmpne` (2 bytes) + `bt drop` (4 bytes) by a `bsr ts_gate` + conditional branch, where
`ts_gate` returns "drop" when TS on and `slot != 33CC8[4]` (stock), or when TS off and
`3C620[other] || 3C622[other]` (the existing MS-sourced capture rule, `RX_CALL_PATH_ANALYSIS.md` §2). Because
the drop happens before any `3BEB8` clear, the global 13-tick timer then follows the captured slot.

Additional TS-off concerns (must be designed before an image):

- Voice from the other slot is written to the shared buffer `3C69C` only when `3C620[slot]` is set, so capture keeps
  audio clean; verify `rxvoice` uses `3BEAA` (TX slot) for the call descriptor — with TS off it must use the burst
  slot, or the display shows the wrong call.
- `030282A4`/`03028BE4` copy the burst slot into `3BEAA`/`3BEAC` only for MS-sourced bursts; BS-sourced captures on
  the other slot must not write them (TX slot unchanged).
- Mode 1 slot lock (`3BEB1`) and CACH tracking already see both slots; no change.

### 3.3 Burst-type restriction for TS off (code-verified register use, design inferred)

The slot gate in `03028644` runs **before** the data-type jump table, so removing it would also admit CSBKs,
data headers/blocks and PI headers from the other slot (TX side effects, `DATA_PATH_ANALYSIS.md` §6). At the gate
the decoded status is still in registers (`0302864A..03028662`): `r1` = bits 1:0 (sync class: 1 voice sync,
2 data sync, 0 embedded/no sync), `r0` = bits 11:8 (data type), `r12` = bits 3:2 (sync source), `r5` = bits 7:4
(CC). `ts_gate` should therefore admit the other slot only for `r1 == 1` (voice sync burst) and for `r1 == 2`
with `r0 ∈ {1, 2}` (voice LC header, terminator with LC). In `03028BE4` (embedded LC/late entry) `r4` holds
bits 3:2; only voice-related LC arrives there, but FLCO `0x30` data terminators and FID `0x10` services
(`3C7A4`) must stay on the programmed slot.

### 3.4 Receive consumers indexed by the TX slot `3BEAA` (code-verified)

| Site | Code | Stock bytes | Use |
|---|---|---|---|
| `03020714` (`rxvoice`, every event) | `ld.b r3,(r8,0x2)` | `68 d8 02 00` | copies dst/src `3C62C/3C634[slot]` to `3BA60/3BA64` |
| `030207AA` (`rxvoice`, event 2) | `ld.b r2,(r8,0x2)` | `48 d8 02 00` | call descriptor `3BD48` dst/src |
| `030208FA` (`rxvoice`, event 1 PI header) | `ld.b r2,(r8,0x2)` | `48 d8 02 00` | PI header `3C684+12·slot` → decryption key match |
| `03020A22` (`rxcsbk`) | `ld.b r3,(r2,0x2)` | `62 82` | CSBK requester/target (CSBKs stay slot-gated, leave) |

In stock firmware the slot of an accepted voice header always equals `3BEAA` (mode 1: only the programmed slot
passes the gate and `0002D500` sets `3BEAA = 33CC8[4]` at slot lock; mode 0: `030282A4`/`03028BE4` copy the burst
slot into `3BEAA` for MS-sourced bursts). With TS off a captured call on the other slot breaks that equality, so
the three `rxvoice` loads must read a **captured-slot byte** instead. Candidate RAM: `3BEBD..3BECB` (15 bytes inside
the `3BEA8` block) has no literal-pool, constant-offset or memset reference (scan of flash + IRAM, inferred free;
BSS-zeroed at boot is unverified). Writing the burst slot there in the accept paths of `030282A4`/`03028BE4`
keeps stock behaviour when TS Match is on, because the value then equals `3BEAA`. The 32-bit `ld.b` form allows any
offset, so each `rxvoice` site is a guarded 4-byte change (`02 00` → `15 00` for offset `0x15`).

### 3.5 Interaction with TX admission (code-verified reads; consequence inferred)

`0301DE64` (TX admit, read-only subject) uses three receive-side values that a captured other-slot call would set:

| Value | Set by (receive side) | Read by | Effect if set by an other-slot capture |
|---|---|---|---|
| `3BEAB` RX activity | accept paths of `030282A4`, `03028180`, `03028BE4`, `03028644`, `03024E7C`, `03025480`, `03027584`, `03027B9C` (all after the slot gate); cleared by Idle `030275F4`, reset `03023364` | only `030272EC` (busy = `3BEBB` or `3BEAB`, unless `3BA68 == 2`) | "channel free" (policy 1) and "colour-code free" (policy 2) admission refuse PTT while the other slot is being received |
| `3BA55` call shown | `rxvoice` event 2; cleared on call end | `0301DE64` for request type 3 | data/CSBK transmissions refused during the captured call |
| `3C624[3BEAA]` | terminator handler | `03027320` | unaffected if `3BEAA` stays the programmed slot |

In stock firmware these only reflect the programmed slot, so TS Match off changes PTT admission unless the caves keep
`3BEAB` for own-slot bursts only (e.g. store other-slot activity in a separate byte). Whether PTT should be refused
while another-slot call is heard is an **owner decision**; the requirement "TX/PTT unchanged" implies it should not.

### 3.6 TX admit policy by channel mode (code-verified, read-only subject)

Policy = channel record byte `+0x0A` bits 6:4, loaded by the channel load `03057790` (`030583F6`) through
`0300C3B4` into `33CD0`; callers pass it as the second argument of `0301DF8C`. A return of 1 means "refuse"
(`33CDB = 1`, busy prompt). Names "Always / Channel Free / Colour Code Free" are inferred from the CPS convention.

| Channel mode (`33CC9`) | Policy 0 | Policy 1 | Policy 2 | Inputs |
|---|---|---|---|---|
| 0 simplex / 4 Double Slot | allow | refuse if RF carrier `33CDC` | refuse if carrier and last RX CC `3C61A == 33CCD` (`03027334`) | `33CDC` = `3FDD8` bit 5, set by the RF carrier poll `0306081C`/`03060E60` (cleared after 31 polls without carrier) |
| 1 repeater (`0301DE64`, after wake-up `03029C3C` and slot lock) | allow | refuse if busy (`030272EC`: `3BEBB` or `3BEAB`) and no terminator just seen (`3C624[3BEAA] != 1`) | as policy 1 but only when the last RX CC equals `33CCD` | `3BEAB`, `3BEBB`, `3C624`, `3C61A` |
| 2 (`0301DF0C`) | allow | refuse if call/data on `3BEAA` (`03023AFC`) and `3C624[3BEAA] != 1` | same plus CC test | `3C620/3C622[3BEAA]` |
| any, request type 3 | — | refuse if busy or `3BA55` | — | |

Consequences: in modes 0 and 4 the admit test uses the RF carrier and the last received CC, not slot state, so
TS Match off does not change it (a carrier is present either way). In mode 1 only `3BEAB` and `3BA55` would be
touched by an other-slot capture (§3.5). CC Match off does not change `3C61A` handling (the dispatcher stores
the received CC before any gate in stock firmware), so policy 2 keeps its stock meaning.

### 3.7 Hardware CC layer (correction 2026-10-14, fifth pass)

§3.1 lists only software sites. The HR_C7000 datasheet (`HR_C7000_CROSSCHECK.md` §3.1) documents a hardware CC
filter: with `LOCAL_CC.cc_opt` (`11000384` bits 9:8) = 0, frames whose CC differs from `11000384` bits 3:0 are not
decoded at all. CC Match off therefore also needs `cc_opt = 1` on normal channels, as `CC_MATCH_DESIGN.md` §2
proposes. The two writers that clear bits 9:8 are code-verified:

| Site | Stock bytes (image order) | Instruction | Role |
|---|---|---|---|
| `0301E73C` (`0301E580`, non-mode-4 path) | `6e 11 78 83 63 e4 08 20 cc 74 03 e9 07 00` at `0301E73C..0301E749` (`lrw r3,3BA54; ld.b r3,(r3,0x18); andi r3,r3,8; zextb r3; bez`) | Monitor test before `bseti r4, 8` at `0301E750` | re-applies `cc_opt` on every channel/mode setup |
| `0301EC40` (Monitor setter) | see `MONITOR_ANALYSIS.md` §3 | clears 9:8, sets bit 8 when `on` | Monitor off would clear `cc_opt` |

The `0301E73C` site uses the same Monitor idiom as the four voice sites, so the same `cc_bypass` cave
(§3.1) can serve it; `0301EC40(0)` would additionally have to keep bit 8 when CC Match off is set. Mode 4 already
forces bit 8. `RF_MODE.adjustsyncmax` is not written by stock firmware even when `cc_opt = 1`; leave it unchanged
unless an owner test (`HR_C7000_CROSSCHECK.md` §5) shows a problem.

## 4. Code and RAM placement (constraints found)

- The installed Scan Zone module occupies `030DFCEC..030E0E56` inside a `0x1800` window ending at `030E14EC`.
  `030E14EC` is exactly the end of the official updater payload (`0x0300C000 + 0xD54EC`). The window tail
  `030E0E56..030E14EC` (**1686 bytes**) is zero in both stock and installed images and is the only spare space
  known to be inside the payload range. Stock is also zero from `030E14EC` to `03100000`, but that area lies outside
  the official payload and its boot/updater treatment is unreviewed — do not use it without that review.
- RAM: the mod already uses `4BFC0..4BFE0`. Using `3BA6D` bits avoids new RAM for the flags.
- Two caves (`cc_bypass`, `ts_gate`) plus menu cases are estimated at well under 300 bytes (inferred).

## 5. Verification plan (owner, after a future image exists — not now)

All RX-only: wrong-CC repeater with CC Match off (voice audible, talkgroups still filtered, SMS/CSBK still ignored);
TS Match off on a busy repeater (first call heard until terminator/timeout, other slot ignored meanwhile, PTT still
uses the programmed slot — confirm with a second radio that the transmission appears on the programmed slot);
Monitor still works as before; CPS read/write round trip keeps the options (or document that CPS clears them).
