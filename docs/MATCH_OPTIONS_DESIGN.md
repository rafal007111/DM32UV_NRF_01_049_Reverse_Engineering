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

*Note 2026-10-14 (fifth pass): the gate rule, TX-neutrality measures, captured-slot RAM and final TS site list in §3.8 supersede the proposals in §3.2–3.5; the site bytes below were re-checked and are unchanged.*

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

### 3.8 TS Match off — design closure (2026-10-14, fifth pass; supersedes the open points of §3.2–3.5)

Inputs and tools as in `HR_C7000_CROSSCHECK.md` §0. All sites below are code-verified in `flash.asm`/`iram.asm`;
the behaviour of the proposed changes is **inferred design**. Nothing is built.

**Scope.** The programmed-slot gates exist only for **BS-sourced** bursts (status bits 3:2 = 1). MS-sourced bursts
(bits 3:2 = 0, direct mode) are already accepted on either slot in stock firmware with a first-come rule
(`RX_CALL_PATH_ANALYSIS.md` §2), and RX mode 4 (DCDM) and mode 2 have their own gates. TS Match off therefore only
changes reception of a **repeater downlink** (mode 1, or a mode-0 simplex channel programmed on a repeater output).
There is no hardware slot filter (`HR_C7000_CROSSCHECK.md` §3.2). Notation: **A** = programmed slot `33CCC`,
**B** = the other slot.

#### 3.8.1 Receive-path consumers of the burst slot vs. the TX slot (code-verified)

| Consumer | Index used | With a captured B call | Proposal |
|---|---|---|---|
| Voice copy `03028644` → `3C69C` | burst slot `3BEA8` and hardware bit 19 | correct (copies only for `3C620[slot]`) | none |
| `begin_v_layer2` `03023828` (per tick) | `3C620[3BEA8]` | opens voice delivery on B automatically | none |
| LC/terminator/late-entry stores `3C63C+12·s`, `3C62C[s]`, `3C634[s]`, `3C624[s]`, `3C626[s]`, `3C628/3C62A[s]` | burst slot | correct per slot | none |
| Global call fields `3C61C` (group), `3C61D`, `3C61E`, `3C61F` (service options) | — (last accepted header) | follow the captured call; safe while only one slot is captured | none |
| Talker alias buffer `3BA70` (`03028BE4`, FLCO 4–7) → event `0x40000000` → `psint` → `0301EE6C` | — (global) | filled only by bursts that pass the late-entry gate; with the capture rule only the captured slot (or either slot while idle) writes it | none |
| `rxvoice` `03020714`: `3BA60`/`3BA64` = dst/src of `3C62C/3C634[3BEAA]` (every event) | TX slot | stays the A values | **keep stock**: `3BA64` feeds `0301EC14` → `0305EB8C` CSBK actions (TX targets), `3BA60` only the home-screen numeric fallback and `0302C4FC` |
| `rxvoice` `030207AA`: call descriptor `3BD48` (dst/src) on event 2 | TX slot | would show A's stale IDs | **change** to the captured slot (site T7) |
| `rxvoice` `030208FA`: PI header `3C684+12·s` on event 1 | TX slot | B PI headers are not admitted (§3.8.2) | keep stock; encrypted B calls are not decrypted (owner decision) |
| UI `0305E3F0` (call display, call-start tone, `3E0DC+0x10/0x14`), `0305E5E4`/`0305E654` (call end) | descriptor `3BD48` | correct once T7 is applied | none |
| PTT talk-back `0305C334` → `0305C1E0`: during the call display (`3FDEC` bit 0) or RX hang (`3BA68 == 1`, set by `0301E834` from `rxvoice`) PTT addresses the received call (`3E0DC+0x14` class 1 → `3E0DC+0x10` source, 2/3 → `3BD48` dst) | descriptor | a B call would redirect PTT to B's group/caller while TX stays on slot A | **guard** (site T9): treat a displayed B call like the stock "no talk-back" setting (`3FD4C+0x1E` bits 6:4 = 2) — owner decision |
| Home screen `0302B9A4`: `T1`/`T2` from channel byte `3E205` bit 4 (`0302BB56`), `CC:%d` from `3C61A` | programmed slot | shows the programmed slot during a B call | optional display site (T10), owner decision |
| Scanner busy `0302ED04` → `0301ED00` (`3BA59`, `3C622|3C623`, `3BA55`) | — | scan stops on a captured B call | none (desired; owner to confirm) |
| Recording `030218B0` → `00015FA4(2)`/`0302123C(1)` | — (audio open) | B calls are recorded like A calls | none (owner to confirm) |
| Call log (`Call Log`/`Missed Call` strings) | writer not located | unknown | unreviewed |
| `0305E3F0` → `0305D338` → `0301EAE8(8)`, `0305E390` | — | a B call start cancels a pending own command / alarm state like an A call | none (stock reaction to "call shown"; owner to confirm) |
| TX slot chooser `030237B8`, `03023AFC`, `03027320` | `3BEAA` / `3C620[3BEAA]` / `3C624[3BEAA]` | unaffected while `3BEAA` stays A | none |

#### 3.8.2 Gate rule for BS-sourced bursts (replaces the four `cmpne`/`bt` gates of §3.2)

`ts_gate` keeps the stock result when TS Match is on. When it is off:

| Burst | Admit when | Drop when |
|---|---|---|
| slot A, any type | always, except below | A voice-start (data type 1 LC header in `03028644`, any burst at the `03028BE4` late-entry gates) while `3C620[B] == 1` (first-come capture) |
| slot B, `03028644`, sync 01 (voice burst) | `3C620[A] == 0` and `3C622[A] == 0` | otherwise |
| slot B, `03028644`, sync 10 data type 1 (LC header) or 2 (terminator) | same | otherwise |
| slot B, `03028644`, sync 10 data type 9 (Idle) | never; **if `3C620[B] == 1`: clear it and post event 4** (what `030275F4` does for the call, without its `3BEAB`/`3BEAF` writes and the `0x200` TX-waiter event) | always |
| slot B, `03028644`, any other data type (PI header 0, CSBK 3, data 6/7/8/10, MBC) or sync 11 (RC) | never | always (no CSBK/data TX side effects, `DATA_PATH_ANALYSIS.md` §6) |
| slot B, `03028BE4` late entry | `3C620[A] == 0` | otherwise |

The B-Idle rule is needed because during a B call the repeater keeps sending A bursts, which reset the global
13-tick timer `3BEB8`; without it a B call that lost its terminator would stay captured until the repeater drops.
At each gate the decoded status is still in registers (`03028644`: `r1` = bits 1:0, `r0` = bits 11:8, `r12` =
bits 3:2; `03028BE4`: `r4` = bits 3:2, `r3` = status word). Stock clobbers only `r2`/`r3` (`03028644`) or `r1`/`r2`
(`03028BE4`) at these sites; the cave must preserve everything else and must save/restore registers around the
`0300C724(4)` call. Programmed-slot priority (A pre-empts B) instead of first-come would need writes at the
`3C620[slot] = 1` accept points of `030282A4` (`0302834A`, `03028470`, `0302859C`) and `03028BE4`; listed as the
alternative for owner question 1 below.

#### 3.8.3 TX neutrality

| TX input (read-only subjects untouched) | Effect of an admitted B burst | Measure |
|---|---|---|
| `3BEAB` RX activity (`030272EC`, policies 1/2 in mode 1) | set by `03028644` (voice path, before the `3C620` test), `030282A4` (after the CC gate, before the destination filter), `03028BE4`, `03028180` | wrapper at the dispatcher calls (sites T5/T6): save `3BEAB`, call the handler, restore it when TS off, status bits 3:2 = 1 and `3BEA8 != 33CCC` — exactly the bursts stock drops before touching `3BEAB` |
| `3BEAA`/`3BEAC`, `33CCB`/`33CCC` | B is BS-sourced, so the MS-only copies in `030282A4`/`03028BE4` do not run; **but** `030282A4` FID `0x10` header with FLCO bit 2, rejected by the filter and `33CDD == 0` (`030284D4…03028514`) writes all four slot bytes from LC byte 6 and may retune (`03023C10`) — Capacity-Plus-style follow, no mode check | guard site T8: skip that branch for B bursts |
| `3C624[3BEAA]` (`03027320`) | indexed by `3BEAA` = A | none |
| `3BA55` call shown (`0301DE64` request type 3, `0301ED00`) | set by `rxvoice` for a B call | owner decision (stock refuses data/CSBK sends during any shown call) |
| `3BA68` hang state (`030272EC` ignores busy when it is 2 = own TX hang) | a B call sets 1 (RX hang) | owner decision (same as an A call in stock) |
| PTT talk-back target | redirected to the B call | guard T9 |
| CC (`03027334`) | `3C61A` = last received CC; B bursts pass the same CC gates | none |

#### 3.8.4 Captured-slot RAM byte

`3BEBD..3BECB` (15 bytes) is free (inferred, method below): it lies in the BSS that the reset code zeroes
(`0300C05C…0300C072`: `0x2F0B4…0x4A7E0`, word loop, code-verified); a register-tracking scan of every catalogued
function plus the task entries (`lrw`/`mov`/`addi` propagation, constant offsets and `ldr`/`str` bases) found no
access to `3BEBD..3BECB` and no indexed access based in `3BE68..3BECB` (the same scan finds all 40 known
`3BEB8..3BEBC` accesses and the three `rxvoice` `3BEAA` loads); a raw word search finds no literal between
`3BEB0` and `3BECB`. Proposal: `3BEBD` = slot of the displayed call (written by the T7 cave), read by the T9 guard.

#### 3.8.5 Final site list (stock bytes in image order; identical in the installed image `156a4872…`)

| Id | VA | Stock bytes (guard) | Instruction(s) | Proposed change |
|---|---|---|---|---|
| T1 | `03028708` | `6f 12 40 83 6f 12 64 83 ca 64 60 e8 68 02 b5 04` | `lrw r3,3BEA8; ld.b r2,(r3,0); lrw r3,33CC8; ld.b r3,(r3,4); cmpne r2,r3; bt 03028BE2; br 03028880` (`03028644` mode 0, BS) | first 4 bytes → `bsr ts_gate_644` (sets C = drop), next 6 bytes → 3 × `nop`; `bt`/`br` unchanged |
| T2 | `030287B8` | `63 11 40 83 63 11 64 83 ca 64 60 e8 10 02 5d 04` | same, mode 1 | same |
| T3 | `03028C32` | `4a 12 20 82 48 12 44 82 86 64 60 e8 6b 03 45 04` | `lrw r2,3BEA8; ld.b r1,(r2,0); lrw r2,33CC8; ld.b r2,(r2,4); cmpne r1,r2; bt 03029312; br 03028CCA` (`03028BE4` mode 0) | `bsr ts_gate_be4` + 3 × `nop` |
| T4 | `03028C74` | `59 11 20 82 57 11 44 82 86 64 60 e8 4a 03 24 04` | same, mode 1 | same |
| T5 | `03023A12` | `00 e0 19 26` | `bsr 03028644` in `030239D4` | `bsr rx_wrap_644` (save/restore `3BEAB`, §3.8.3) |
| T6 | `03023A1E` | `00 e0 e3 28` | `bsr 03028BE4` | `bsr rx_wrap_be4` |
| T7 | `030207AA` | `48 d8 02 00` | `ld.b r2,(r8,0x2)` (`rxvoice` event 2, slot for `3BD48`) | `bsr slot_of_call` returning in `r2` the slot whose `3C620` is set (`3BEAA` when TS on or none), storing it in `3BEBD` |
| T8 | `030284D4` | `7b 10 75 83` | `lrw r3,33CC8; ld.b r3,(r3,0x15)` then `bnez` skip (`030282A4` FID `0x10` follow branch) | `bsr follow_guard`: return `r3 ≠ 0` (skip) for a B burst when TS off, else `33CDD` |
| T9 | `0305CB6C` | `7b 12 7e 83` | `lrw r3,3FD4C; ld.b r3,(r3,0x1E)` (join point of the talk-back test in `0305C334`) | `bsr talkback_guard`: return `0x20` (no talk-back) when TS off and `3BEBD != 33CCC`, else the stock byte |
| T10 (optional) | `0302BB56` | `7b 10 6d 83` | `lrw r3,3E1F8; ld.b r3,(r3,0xD)` (home `T1`/`T2`) | display the slot of the shown call (owner decision) |
| — | `03020714`, `030208FA` | `68 d8 02 00`, `48 d8 02 00` | `rxvoice` `3BA60/3BA64` and PI-header slot | **unchanged** (§3.8.1) |

All patched functions keep their `push … r15` prologues (code-verified for `03028644`, `03028BE4`, `030239D4`
`push r4,r15`, `030206D0` task loop with other `bsr` calls, `030282A4`, `0305C334`), so a `bsr` at these sites
is safe. The T3/T4 caves must preserve `r3` (status word, used at `03028CD0`/`03028CF8`). Every branch target
listed is inside its own function. Code space: four small caves plus the wrapper, estimated < 400 bytes together
with §3.1 (inferred), within the 1686-byte window of §4.

#### 3.8.6 Open questions for the owner

1. First-come capture (the stock MS-sourced rule, proposed) or programmed-slot priority (A pre-empts B; more sites)?
2. During a B call: should PTT talk back to the B caller (on slot A) or use the channel contact (proposed, T9)?
3. Should data/CSBK sends be refused while a B call is shown (`3BA55`, stock behaviour for A calls)?
4. Should the home screen show the slot of the received call (T10)?
5. Should encrypted B calls be decrypted (would need B PI headers, `030208FA` and `03027584` changes)?

#### 3.8.7 RX-only hardware tests (stock firmware, to prepare the design)

| Item | Test | Expected |
|---|---|---|
| A-slot Idle during B traffic | SDR (dsd-fme) on a busy repeater: watch both slots while only B carries a call | Repeater sends Idle bursts on A while B is active (confirms why the B-Idle rule is needed) |
| Talk-back | Stock radio: receive a group call that is not the channel contact, press PTT within the hang time | Radio transmits to the received group (confirms §3.8.1 talk-back reading) |
| Scan stop | Stock radio scanning a list containing the repeater, traffic only on the other slot | Scan does not stop (stock); with TS off it would stop |

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
