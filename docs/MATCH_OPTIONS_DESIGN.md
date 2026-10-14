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
