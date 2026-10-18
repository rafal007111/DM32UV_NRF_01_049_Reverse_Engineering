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

Storage decision (2026-10-17, targeted review T2, `SETTINGS_CPS_ANALYSIS.md` §11): keep block 4 `0x60` bits 2/3 with
`0 = stock`. In the firmware every writer of `0x60` is a read-modify-write and no other code reads bits 2–7, so the
firmware itself never loses the bits; whether the PC CPS keeps them is not answerable from the firmware. If a CPS write
clears them, both options silently return to stock behaviour (safe direction); the runtime copy `3BA6D` bits 5/6 is
reloaded from `0x60` at boot by `0304B010`.

T2b confirms this choice (`CPS_PROTOCOL.md` §5): the CPS `W` write rewrites whole 4 KiB data-flash sectors, so a
CPS write preserves `0x60` bits 2/3 only if the PC software writes them back unchanged — unknown statically, hence
the `0 = stock` safe direction. A mod must not change the CPS session code (`0302B340`, `0302A448`, `03029FB0`) or
the area layout, or the official CPS could stop reading/writing the codeplug correctly.

## 3. Site inventory (stock bytes; identical in the installed image `156a4872…`)

Bytes are in image order (little-endian halfwords; 32-bit instructions are stored high halfword first).

### 3.1 CC sites — all use the Monitor idiom `lrw r3,3BA54; ld.b r3,(r3,0x18); andi r3,r3,8; zextb r3; bez drop`

| Function / role | VA | Stock bytes | Proposed change |
|---|---|---|---|
| `03028180` terminator | `0302819C` | `73 13 78 83 63 e4 08 20 cc 74 03 e9` | replace `ld.b`+`andi` (6 bytes at `0302819E`) by `bsr cc_bypass` + `nop`, result in `r3` |
| `030282A4` voice LC header | `030282D0` | `66 11 78 83 63 e4 08 20 cc 74 03 e9` | same at `030282D2` |
| `03028644` data-sync dispatcher | `03028B5E` | `72 10 78 83 63 e4 08 20 cc 74 03 e9` | same at `03028B60` — but limited to data types 1/2: Idle (type 9) has no CC check of its own (correction in §3.9) |
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
the received CC before any gate in stock firmware), so policy 2 keeps its stock meaning. *Corrected in §3.9: with
`cc_opt = 1` foreign frames reach the dispatcher and do change `3C61A` and `3BEAB`.*

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

### 3.9 CC Match off — completeness check and corrections (2026-10-14, fifth pass)

Method: every load of the configured CC `33CCD` and of the received CC `3C61A` was listed with two independent
trackers (`tools/dm32 acc`, and the register-tracking scan used in §3.8.4 over all catalogued functions plus the
task entries `030206D0`, `030209E4`, `0301FF9C`, `0301FDD8`, `0305F234`, `0302B340` and IRAM `0002C458`,
`0002D620`, `0002D770`); every `zext …, 7, 4` in flash and IRAM was attributed to its function (58 hits; only
`03028644` and `03028BE4` apply it to the RX status word, the others extract channel-type nibbles). Absence of
other comparisons is therefore **inferred** with that method.

| Reader of `33CCD` | Compares with | Role | CC Match off |
|---|---|---|---|
| `03028B58` (`03028644`, data-sync gate, Monitor idiom at `03028B5E`) | status CC `r5` | gate before the data-type table | bypass **only for data types 1 and 2** (see correction below) |
| `030282CA` (`030282A4`, idiom at `030282D0`) | `3C61A` | voice LC header | bypass |
| `03028196` (`03028180`, idiom at `0302819C`) | `3C61A` | terminator with LC | bypass |
| `03028CE4` (`03028BE4`, idiom at `03028CEA`) | status CC (EMB) | late entry / embedded LC | bypass |
| `030289E4` (`03028644`) | status CC `r5` | `3C626` embedded-CC mismatch counter | bypass (take the reset path) |
| `03027598` (`03027584`) | `3C61A` | PI header | keep (owner decision, `CC_MATCH_DESIGN.md` §4) |
| `03024E92` (`03024E7C`), `0302548C` (`03025480`) | `3C61A` | data header / packet data | keep |
| `03027BBA` (`03027B9C`) | `3C61A` | CSBK | keep |
| `0302733A` (`03027334`) | `3C61A` | TX admit policy 2 | read-only subject |
| IRAM `0002D8A6`, `0002DDF0`, `0002DE36` (`0002D7C8`) | — (copy to `11000384[3:0]`) | TX CC, mode 4 | read-only subject |

Writers of `3C61A`: `03028644` (`03028B54` data sync before the gate, `03028900` embedded burst of an active call,
`03028BE0` RC burst), `03028BE4` (`03028CDC`, before its gate), `03029318` (`0xFF` at call end). Readers besides
the table: `03020D88` (home screen `CC:%d`). Conclusion: the four Monitor-idiom sites plus the `3C626` counter are
the **complete voice set** (code-verified sites, completeness inferred), and the hardware `cc_opt` (§3.7) is the
fifth required change.

**Correction 1 — Idle bursts.** §3.1 assumed that "data handlers re-check CC themselves". That is true for types 0,
3, 6, 7, 8, 10, but **not for type 9 Idle**: `030275F4` has no CC test (`DATA_PATH_ANALYSIS.md` §1), so the
dispatcher gate is its only CC filter. Bypassing the gate for all types would let a foreign-CC Idle burst clear
`3BEAB`, set `3BEAF`, post `0x200` (a TX-transaction waiter, `03020EC8`) and end the current call on that slot —
which is exactly what the stock Monitor already does. At `03028B5E` the data type is live in `r0` (used at
`03028B72`), so the cave can restrict the bypass to `r0 ∈ {1, 2}` and must preserve `r0`.

**Correction 2 — TX inputs see foreign-CC traffic once `cc_opt = 1`.** `MATCH_OPTIONS_DESIGN.md` §3.6 stated that
CC Match off does not change `3C61A` handling. That holds only for the software gate; with the hardware filter off,
foreign-CC frames reach the dispatcher, which (code-verified):

- writes the foreign CC to `3C61A` before any gate (`03028B54`, `03028CDC`), so TX admit policy 2
  (`03027334`, "refuse if carrier and last RX CC == own CC") sees a foreign CC and **admits** PTT where stock, which
  never saw the foreign frames, would compare against a stale own-CC value;
- sets `3BEAB` for every admitted voice-sync burst (`03028644` voice path has no CC test) and, with the bypass, for
  foreign LC headers/terminators/late entries, so policy 1 in mode 1 **refuses** PTT during foreign-CC traffic.

Stock Monitor has both effects today. To keep TX/PTT unchanged, the dispatcher wrapper of §3.8.3 (sites T5/T6) can
also restore `3BEAB` **and `3C61A`** after a burst whose status CC differs from `33CCD` while CC Match off is set
and Monitor (`3BA6C` bit 3) is off. The handlers still see the true CC during the call (they read `3C61A` inside the
wrapper), and the home screen then keeps showing the last own CC. Owner decision whether TX should instead follow the
foreign traffic.

**Embedded LC, late entry, PI and talker alias with a foreign CC (code-verified flow, consequences inferred).**

- After the `03028BE4` gate the late-entry path stores the embedded LC per slot, decodes talker alias (FLCO 4–7 into
  `3BA70`, event `0x40000000`), and for status bit 17 (EMB PI flag) copies privacy parameters to `3C685+12·slot`
  (event `0x4000`, cleared only). With the bypass these run for foreign-CC calls as they do under Monitor.
- PI headers keep their own CC check (`03027598`), so a foreign-CC encrypted call is not decrypted from its header.
  The burst-F path (`030289DE` → `03027628`, `RX_INFO.rc_info` algorithm/key vs `3F720`) runs for every accepted
  call without a CC test, so decryption can still start from the first superframe when the key matches (inferred).
- The `3C626` counter is reset by every voice-sync burst (`03028644` voice path), so even without its bypass a
  foreign-CC call is only cut after two consecutive lost sync bursts; the bypass removes that residual risk.

**Mode 2 is unreachable.** The only writer of `33CC9` (RX mode) is `0301E580` (values 0, 1, 4; both trackers), so
the mode-2 paths — including `030280C0`, a CSBK handler that `03028644` calls in mode 2 **before** the CC gate —
are dormant in this build (inferred, absence of other writers). The Capacity-Plus-style handlers reachable in modes
0/1 are the FID `0x10` voice-LC follow branch (§3.8.3, T8), the CACH short-LC handler `03027388` and CSBK opcode
`0x3E` (`03023EB8`); all of them sit behind the CC gates except `03027388` (CACH has no CC).

**Final CC site list** (stock bytes re-checked, identical in the installed image):

| Id | VA | Stock bytes | Change |
|---|---|---|---|
| C1 | `03028B5E` | `72 10 78 83 63 e4 08 20 cc 74 03 e9 3d 00` | `ld.b`+`andi` (6 bytes at `03028B60`) → `bsr cc_bypass_dt` + `nop`; returns non-zero for Monitor, or for CC Match off with `r0 ∈ {1,2}`; clobbers only `r3` like the stock code |
| C2 | `030282D0` | `66 11 78 83 63 e4 08 20 cc 74 03 e9` | `cc_bypass` (Monitor or CC Match off) |
| C3 | `0302819C` | `73 13 78 83 63 e4 08 20 cc 74 03 e9` | `cc_bypass` |
| C4 | `03028CEA` | `59 10 58 82 42 e4 08 20 88 74 02 e9` (the 14-byte row of §3.1 starts 2 bytes earlier with the preceding `bf`) | `cc_bypass` on `r2`; preserve `r3` (status word) |
| C5 | `030289E2` | `6d 10 65 83 4e 65 2c 0c` | take the reset branch when CC Match off |
| C6 | `0301E73C` | `6e 11 78 83 63 e4 08 20 cc 74 03 e9 07 00` | `cc_opt = 1` on channel/mode setup when CC Match off (§3.7) |
| C7 | `0301EC40` off branch | see `MONITOR_ANALYSIS.md` §3 | keep bit 8 when CC Match off (§3.7) |
| T5/T6 | `03023A12`, `03023A1E` | `00 e0 19 26`, `00 e0 e3 28` | shared wrapper: restore `3BEAB`/`3C61A` for foreign-CC bursts (Correction 2) |

Open questions for the owner: (1) should foreign-CC traffic count as "busy" for PTT (stock Monitor behaviour) or be
invisible to TX (wrapper)? (2) should foreign-CC Idle bursts end a call (stock Monitor) — the proposal excludes them?

### 3.10 Static review of new risks (2026-10-17, targeted review T3)

Inputs as in `TX_PATHS.md` (hashes re-checked); `tools/dm32 callers/acc/fn`, Ghidra decompiler output with resolved
literal pools, and a stack-depth scan (push register count plus `subi r14` per function, worst path over direct calls;
calls through pointers are not followed, interrupt frames use the separate ISR stack `4B7E0`,
`LIBRARY_SIGNATURES.md` §6). Static only; the design itself stays **inferred**.

#### 3.10.1 Execution context and stack budget per site (code-verified callers; depths inferred from the scan)

| Sites | Function | Only caller chain | Task (priority, stack) | Worst direct-call depth of the task | Note |
|---|---|---|---|---|---|
| T1, T2, C1, C5 | `03028644` | `030239D4` ← task `sysint` `0002D770` | `sysint` (17, 450 words = 1800 B) | 1080 B (via the voice-decrypt path `0002B30C` → `00015880` → vocoder IRAM) | ≈ 720 B margin; the caves are leaves except the B-Idle rule's `0300C724(4)` post |
| T3, T4, C4 | `03028BE4` | `030239D4` | `sysint` | depth of `03028BE4` itself 136 B | large margin |
| T8, C2 | `030282A4` | `03028644` | `sysint` | 152 B below `03028644` | — |
| C3 | `03028180` | `03028644` | `sysint` | 132 B | — |
| T5, T6 | `030239D4` call sites | task `sysint` | `sysint` | the wrapper frame adds to every path below it (keep ≤ 16 B) | see §3.10.2 |
| T7 | `030207AA` | task `rxvoice` `030206D0` | `rxvoice` (24, 384 words = 1536 B) | 360 B | large margin |
| T9 | `0305CB6C` | `0305C334` ← task `keys` `03012D2C` (event 8) | `keys` (7, 192 words = 768 B) | site at depth 96 B; **stock** worst static path ~844 B (no-float) / ~1180 B (float) exceeds the 768 B stack — **resolved in §3.10.9**: a loose over-approximation, most likely infeasible/benign in stock, not caused by the design | keep T9 a **frameless leaf** (adds 0 B) — see §3.10.9 |
| C6 | `0301E73C` (`0301E580`) | `03056330` ← channel loader `03057790` (main, `CodeSw`, `keys`, menu contexts), PCTESTM `030215C8`, menu `03038034` | several | `0301E580` depth 112 B | bit change only |
| C7 | `0301EC40` | `0305CCF0` (Monitor key in `keys`, alarm entry), `03031FD4` (`CodeSw`) | several | small | bit change only |
| T10 | `0302BB56` (`0302B9A4`) | `0302C200`, `0302C350` (UI) | UI | — | display only |

**Resolved (code-verified callers):** every receive-gate site runs only in task `sysint`; no site runs in an ISR.

#### 3.10.2 Shared variables, writers and pre-emption (code-verified accesses, `tools/dm32 acc`)

| Variable | Writers (context) | Readers (context) |
|---|---|---|
| `3BEAA` (TX/admission slot) | dispatcher handlers `03027388`, `03027B9C`, `030280C0`, `030282A4`, `03028BE4`, `03024E7C`, `03023EB8` (`sysint`); slot lock `0002D500` (`txslot`); TS setter `0301ECC0` (menu task via `0304B158`); mode-4 setup `03024120` (channel apply) | `030237B8`, `03023AFC`, `03027320` (`CclTraffic`), `rxcsbk`, `03027388`, `03028644`, `03028BE4` |
| `3BEAB` (RX activity) | handlers `03023EB8`, `03024E7C`, `03025480`, `03027584`, `030275F4`, `03027B9C`, `030280C0`, `03028180`, `030282A4`, `03028644`, `03028BE4` (`sysint`); RX reset `03023364` ← `03023394` (burst-loss timeout `0302343C` in `txslot`, `030234E8`, retune `03023C10`, `03024224`) | `030272EC` only (TX admit, `CclTraffic`) |
| `3C61A` (last RX CC) | `03028644` (3 sites), `03028BE4` (`sysint`); `03029318` = `0xFF` (from `rxvoice` and from the RX reset in `txslot`) | CC gates in the handlers (`sysint`), `03027334` (`CclTraffic`), `03020D88` (home `CC:%d`) |
| `3BEB8` (burst-loss timer) | cleared by 23 stores in the handlers (`sysint`), by `0002D7C8` (`txslot`) and `030294C8` (any TX producer), `03023364` | `0302343C` only (`txslot`, every tick) |
| `3BEBD` (proposed captured-slot byte) | none | none (re-checked this pass) |

`txslot` (priority 12) can pre-empt `sysint` (17); `rxvoice` (24), `CclTraffic` (22) and the UI tasks cannot. So the
only concurrent writer during a handler is the `txslot` RX reset (`03023394` → `03023364` clears `3BEAB`/`3BEB8`/slot
lock, `03029318` sets `3C61A = 0xFF`).

**New risk R1 — wrapper restore after a concurrent RX reset (T5/T6, inferred design).** A wrapper that saves `3BEAB`/
`3C61A` before the handler and restores them afterwards would undo a reset that `txslot` made in between, leaving a
stale "busy" or a stale own CC (TX admit policy 1 would refuse, policy 2 would compare with an old value). Rule that is
safe against the reset: restore `3BEAB` only as "saved == 0 and current ≠ 0 → write 0", and `3C61A` only when it still
holds the burst's foreign CC; do both compare-and-write steps inside the CPU critical-section pair the firmware already
uses (`CPU_SR_Save` `0001018C` / `CPU_SR_Restore` `0001019C`, used e.g. in `0300F878`, `0301C98C`). Status: **resolved by design rule** (code-verified writers;
the rule is inferred).

#### 3.10.3 Burst-loss timer `3BEB8` with TS Match off (code-verified stock behaviour)

In `03028644`, mode 0 or 1, a BS-sourced burst on either slot clears `3BEB8` and sets `3BEAF` only while the repeater
downlink is not yet seen (`3BEAF == 0`: stores at `030286DE`, `03028780`, the latter also posts `0x10000000`). After
that, the slot gates T1 (`03028708`) / T2 (`030287B8`) drop other-slot bursts **before** any `3BEB8` store, and mode 0
additionally needs slot lock `3BEB1` (`03028700`). So in stock only the programmed slot refreshes the timer; with TS
Match off every admitted B burst refreshes the shared timer too. Consequence: a captured B call cannot time out while A
carries traffic, which is why the B-Idle rule of §3.8.2 is needed (confirmed). Dropped B bursts (other data types) leave
the cave before any timer store, as in stock. Status: **resolved** (code-verified mechanism).

#### 3.10.4 Scanner, recording, Call Log (code-verified readers)

- Scanner busy `0302ED04` (digital) → `0301ED00`: `3BA59` (TX/request state), `3C622` read as a halfword (data on
  either slot), `3BA55` (call shown), `30E0C`; then hang state `3BA68`, `3E0E3` (call display), `3BA43` bit 1. A captured
  B call sets `3BA55` through `rxvoice` and therefore stops the scan, as does a foreign-CC call with CC Match off — the
  same reaction as stock Monitor. Status: resolved; owner preference in §3.8.6 stays.
- Recording (`0302124C`) takes the caller IDs from the call descriptor `3BD48`, and the Call Log (`0302DF18` →
  `03058B34`) from `3E0DC`, which `0305E3F0` fills from `3BD48`. With T7 (descriptor from the captured slot) both record
  the B caller correctly. Status: resolved (data flow code-verified, design inferred).

#### 3.10.5 CPU load with `cc_opt = 1` (inferred from code and datasheet)

`cc_opt = 1` only lets foreign-CC frames raise `dll_frame_rx_interp`; the chip still delivers at most one frame per
received 30 ms slot, as with stock Monitor, which already runs this way. The expensive part of `03028644` (the
1080-B voice-decrypt path) runs only while `3F722` (decrypt active) is set, i.e. after a matching PI header (CC-checked,
`03027598`) or a burst-F algorithm/key match (`03027628`). IRAM `0002D7C8` runs once per tick independently of
`cc_opt` and writes `LOCAL_CC` bits 3:0 only in mode 4. The phy-RX handler `0002D374` (bit 11, a bit-error counter over a
reference pattern table `030B0248`) does not touch the TS/CC variables. Status: **no new load class beyond stock
Monitor** (inferred); owner check below.

#### 3.10.6 Status of the items of `NEXT_AGENT_PROMPT.md` item 5

| Item | Status |
|---|---|
| Execution context of every site | resolved (§3.10.1) |
| Stack budget | resolved for `sysint`/`rxvoice`; `keys` stock static path above its stack resolved in §3.10.9 (over-approximation, most likely benign, not caused by the design; T9 must stay a frameless leaf) |
| Re-entrancy / shared variables | resolved with rule R1 (§3.10.2) |
| Burst-loss timer | resolved (§3.10.3) |
| Scanner, recording, Call Log | resolved (§3.10.4) |
| CPU load with `cc_opt = 1` | inferred; owner RX-only test 1 below |

#### 3.10.7 Owner RX-only tests (stock firmware)

Disable first, as in `TX_PATHS.md` §7 (Lone Worker, Auto Roaming, VOX, beacon, alarm, analog decode responses; Rx Only
channel where possible).

| # | Test | Expected |
|---|---|---|
| 1 | Monitor on, on a busy repeater with a different CC, for several minutes | foreign voice without dropouts and normal key response (bounds the `cc_opt = 1` load) |
| 2 | Scan a list containing a busy repeater whose traffic is only on the other slot | stock: scan does not stop (confirms §3.10.4 gate order) |
| 3 | Receive a long call on the programmed slot while the other slot is idle | call ends with the terminator or about 13 ticks after the last burst (`3BEB8`) |

#### 3.10.8 Left unreviewed

IRAM vocoder functions on the decrypt path (`00016890`, `000182BC`, …); `0300C5E4`/
`0300C550` (timer helpers of the mode-4 path); the 30 IRAM SPI/GPIO helpers listed by the reach scan but not on a site.
(The `keys` stack question is resolved in §3.10.9.)

#### 3.10.9 The `keys` task stack path (work item S, 2026-10-17; code-verified frames, feasibility inferred)

**Question (from §3.10.1 row T9):** the stock worst static path from task `keys` (`03012D2C`, prio 7, stack **192
words = 768 B**, created by `03012EA0`) through the PTT handler `0305C334` → menu redraw `0303B6AC` → `sprintf`
`030704C4` was estimated at ~1224 B — above the 768 B stack. Is it feasible?

**How the PTT handler reaches the redraw (code-verified).** `keys` dispatches key/PTT events to `0305C334` through
the handler table at `03013060` (a `jsri`, i.e. a *function-pointer* call — the stack scan does not cross it, which
is why the scan is rooted at `0305C334`). Inside `0305C334`, the menu redraw `0303B6AC` is called at `0305C92C`
**only in the branch where `FUN_03059D5C() == 0`** (a key/PTT event while a menu scene is active). `0303B6AC` then
runs a common prologue (`bsr 0303B374` at `0303B6C6`) before dispatching the active scene through the pointer table
`030B0D7C`.

**Real frames (prologue `push` reg count ×4 + entry `subi sp`, from the stock image).** `03012D2C` +44 B,
`0305C334` +52 B, `0303B6AC` +48 B, `0303B374` +60 B, `030704C4` (`sprintf`) +16 B, formatting core `03070EF0`
+244 B. A direct-call (`bsr`) stack scan rooted at `0305C334` (pointer calls not followed, ISR frames on the
separate stack `4B7E0`) gives:

- **With the floating-point `printf` subtree: ~1180 B.** The bottom ~456 B is `__dtostr` (`03071950` +68) →
  `__muldf3` (`0306F4DC` +188) → `__pack_d` (`03070000` +200), reached from the formatting core only via the
  float-conversion branch `03070EF0 → 03071674 → 03071950`, i.e. **only for a `%e`/`%f`/`%g` format**. The deepest
  `sprintf` reached on the menu-redraw path, `03019800`, formats a **frequency** with the integer format
  `"%03d.%05d"` (`param_6/100000`, `param_6%100000`) — no float — so the float subtree is **not on this path**.
- **Without the float subtree: ~844 B** (still over 768 B). The excess now comes from two large menu-redraw local
  frames, `03018E68` +160 B and `03031658` +148 B, chained with a data-flash record read
  (`0305660C`→`0300F780`→`0300F364`→…). These are the per-scene redraw/record-read buffers.

**Verdict (inferred):** the ~1180/844 B figure is a **loose static over-approximation, not a demonstrated
dynamic path.** The scan maximises over `bsr` edges that are branch-exclusive and scene-selected: `0303B6AC`
dispatches **one** scene per call, the deep frames (`03018E68`/`03031658`) and the float subtree are each reached
only under specific scene state and format strings, and they are not shown to be simultaneously live on a single
PTT-triggered redraw. The stock firmware is owner-confirmed working, and pressing PTT inside menus is routine; a
routine ~76–450 B overflow of the `keys` stack would corrupt the adjacent task stack and reset the radio, which is
not observed. So the path is **most likely infeasible / benign in stock**. It is **not provable infeasible
statically** without enumerating every `0303B6AC` scene handler reachable under PTT and every reachable format
string (beyond this pass), so it is recorded as a **latent, pre-existing stock margin risk, not caused by the TS/CC
Match design.**

**Stock stack checking (code-verified presence, port behaviour inferred).** The kernel is uC/OS-III with
`OSTaskStkChk` and `OSTaskSwHook` built in and a per-task stack **limit of 12 words = 48 B**
(`LIBRARY_SIGNATURES.md` §6). On the CK803S port there is no hardware stack-limit trap: `OSTaskStkChk` is a
diagnostic (used by the stat task to report used/free, it does not trap), and the limit is only sampled at a
context switch via `OSTaskSwHook`. A transient deep `sprintf` within one `keys` time-slice would therefore overrun
and corrupt memory **before** any check ran. So stock firmware would **not reliably catch** this overflow if it
did occur — which is another reason to keep the path from getting any deeper.

**Consequence for T9 (`0305CB6C`).** Regardless of the verdict, the static bound already sits at or above the 768 B
budget, so the TS/CC Match design must add **0 B** to this path: **T9 stays a frameless leaf** (no `push`, no stack
locals, no calls). A single extra ≥48 B frame here could turn a just-within-budget redraw into an overflow.

**Owner RX-only test (optional; does not transmit if set up as stated).** Set the active channel to **Rx Only**
(so PTT cannot key TX — `CHANNEL_RECORD.md`, channel byte `+0x08` bit 3), then press PTT repeatedly while sitting in
each menu scene that renders a frequency/scan/channel label (the deep-frame scenes). A stack overflow would show as
a reset or corruption. This is RX-only *only* because the Rx Only channel blocks the transmitter; without that it
would transmit and is an owner decision.

#### 3.10.10 Pass-3 P1 review of TS/CC-relevant code (2026-10-18; `HUB_FUNCTIONS.md` §8)

The 154 unreviewed functions tagged Codeplug/channels, Baseband registers, shared (DMR tasks), CPS/USB and Digital
RX/TX were read (code-verified accesses). Result for this design: **no change** to the behaviour (§1), the storage
(§2), the site lists (§3.8.5, §3.9) or the risk rules (§3.10.1–§3.10.9).

- None of them reads or writes `33CCC`, `33CCD`, `3BEA8`, `3C620…3C627`, `3C61A`, `3BEAB` or `LOCAL_CC`.
- New read-only subjects (TX inputs found in this pass): `030237AC` (TX slot chooser input `3C616` = sync type of the
  last burst; the same value for both slots of a repeater, so TS Match off does not change it) and the DCDM
  channel-timing chain `03024120…03024794` with its timer callbacks (RX mode 4 only; it transmits CT_CSBKs on its own,
  `TX_PATHS.md` §9). The complete read-only list is now §3.10.1 + §3.8.3 + these two.
- The menu insertion point (§2, Other Func entries 22/23) and its tables are mapped in [UI_MAP.md](UI_MAP.md).

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
