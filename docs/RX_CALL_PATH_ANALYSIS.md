# Received call path, per-slot call state and related internals — DM32.NRF.01.049

Static analysis, 2026-10-14. No serial port was opened, no radio was accessed and no image was built.
Nothing in this file is hardware-verified. Confidence labels follow `docs/RE_NOTES.md`.

Builds on `MONITOR_ANALYSIS.md`, `TS_ANALYSIS.md`, `CC_MATCH_ANALYSIS.md` and `DATA_PATH_ANALYSIS.md`;
facts documented there are not repeated.

## 0. Inputs, tools and a decompiler correction

| Item | Value |
|---|---|
| Stock image | `analysis/inputs/stock_progmem_1MiB.bin`, SHA-256 `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0` (checked) |
| Installed image | `analysis/inputs/current_scan_tick_fix.progmem.bin`, SHA-256 `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53` (checked, not analysed: all addresses below are stock code that the Scan Zone patch does not touch) |
| Ghidra database | `analysis/archives/DM32_NRF_049_correct_base.gzf`, SHA-256 `354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d` (checked) |
| Ghidra | 12.1.4 PUBLIC, OpenJDK 25.0.4.1, legacy module `CSKY_V2:LE:32:default` v0.2 + `analysis/ghidra_scripts/32b_data.fixed.sinc` (**with fix 3, below**) |
| Disassembler | GNU objdump (GNU Binutils) 2.42 for `csky-elfabiv2`, via `tools/static/objdump_image.sh` |

### 0.1 Decompiler bug fixed: `zext`/`sext` dropped the top bit (code-verified)

The legacy SLEIGH for the 32-bit `zext rz, rx, msb, lsb` used the mask `(1 << msb) - 1`, so the
decompiler showed **one bit too few** for every multi-bit field. Example, `03028644` at `0302864E`:
`zext r0, r3, 11, 8` (data type, bits 11:8) was shown as `(x & 0x7ff) >> 8` (bits 10:8); `zext r5, r3, 7, 4`
(received CC) as `(x & 0x7f) >> 4`; `zext r12, r3, 3, 2` as `(x & 7) >> 2` (one bit). `sext` had the same mask
and never sign-extended. Fix 3 in `32b_data.fixed.sinc` computes `(rx << (31-msb)) >> (31-msb+lsb)`
(logical for `zext`, arithmetic for `sext`). Instruction decoding and the GZF are unchanged; only p-code
changes. Re-exporting all 2171 functions after the fix: 0 failures, **156 functions decompile differently**.

Consequences for earlier documents (corrections, code-verified against objdump):

- `11000390`/`3BECC` bits **3:2** are one field (decompiler showed bit 2). In modes 0/1/2 it is the burst
  **sync source**: 0 = MS-sourced, 1 = BS-sourced (inferred names from how the code uses them: CACH slot lock is
  only required for value 1, see §2.3); in mode 4 values 2/3 select slot 0/1 (`03028644`). Earlier text "status
  bit 2 is 0 (direct/MS-sourced)" in `TS_ANALYSIS.md` §8 means "bits 3:2 == 0".
- Channel byte `+0x08`: `03056330` passes bits **7:4** (whole nibble) to `0301E580`, not bits 6:4.
- Earlier claims taken from objdump (CC = bits 7:4, data type = bits 11:8) were already correct.

Commands (read-only; `-readOnly` keeps temporary functions out of the project):

```sh
source /opt/dm32-tools.env
analyzeHeadless $PROJ dm32 -import analysis/archives/DM32_NRF_049_correct_base.gzf -noanalysis \
    -scriptPath analysis/ghidra_scripts -postScript ExportDM32.java $OUT
python3 -I tools/static/resolve_ptr_literals.py analysis/inputs/stock_progmem_1MiB.bin \
    $OUT/DM32.NRF.01.049.payload.bin/decompiled.c dec.c
python3 -I tools/static/decomp_grep.py 'FUN_0300c724\(' dec.c        # event posts with owner function
tools/static/objdump_image.sh analysis/inputs/stock_progmem_1MiB.bin $ASM   # flash.asm / iram.asm
analyzeHeadless $PROJ dm32 -process DM32_NRF_049_correct_base -noanalysis -readOnly \
    -scriptPath analysis/ghidra_scripts -postScript DecompAt.java 030206d0 030209e4   # uncatalogued tasks
```

`[3bea8]` in this file means "the RAM address `3BEA8` loaded from a literal pool" (resolved by the helper).
Callers were checked with a BSR/JSR scan of `flash.asm` + `iram.asm`.

## 1. Event consumers and the received-call path (work item 1)

### 1.1 Event groups (code-verified)

| Group | Post / wait / clear | Waiters found (BSR scan of all `0300C700`/`0300C464` call sites) |
|---|---|---|
| `3658C` (RX call/CSBK) | `0300C724` / `0300C700` / `0300C730` | `rxvoice` `030206D0` (mask `0x40006807`), `rxcsbk` `030209E4` (`0x7540000`), TX admit `0301DF8C` (`0x10000000`, `0x8000000`), TX waits `03020EC8` (`0x20000200`), `0301FE28`, `03020FE4` |
| `38330` (RX data) | `0300C78C` | `rxmsg` (known) |
| `3835C` (UI status) | `0300CDB0` (sets byte `2F0B4+0x600` and posts 1) | task **`psint`** `0305F234` (new, see 1.3) |

The `rxvoice` wait mask is built at `030206F6`: `movi r0, 0x6807; bseti r0, 30` = `0x40006807` (disassembly).

### 1.2 Event 2 (voice LC header accepted) → `rxvoice` (code-verified)

Posted by `030282A4` (voice LC header, 3 sites) and `03028BE4` (late entry, 3 sites; only when the slot
had no call or the source changed). `rxvoice` (`030206D0`, uncatalogued task entry) handles bit 1:

1. Copies the call into descriptor `3BD48`: `+0` = group flag (`3C61C`: 1 group FLCO 0, 0 private FLCO 3),
   `+1` = destination class (1 normal ID, 2 = `FFFFE0..FFFFEF`, 3 = `FFFFF0..FFFFFF` all-call ranges),
   `+4` destination `3C62C[slot]`, `+8` source `3C634[slot]`, using slot `3BEAA` (not the burst slot).
   `03020D50` returns the source; `03020D58` the call class (1 private, 2 group, 3 all call).
2. Call state `3BA54[0] = 1`, `3BA54[1] = 1`; `3BA54[9]` = service options; if `3BEAD == 2` → `03023290(0,1)`.
3. Unless stunned (`3BA6C` bit 2): optional `03065FF0` (when `40138` bit 3), then unless
   `3BD58` bit 6 with `3BD58[3]==6`: **UI notify** `0300D028(1,2)`; `0301E834(group,1)` when `3BD58[1]&3==0`
   (sets `3BA54[0x18]` bit 0, `3BA69`/`3BA68`); and unless (`3BD64==1` and `3BA6C` bit 7, unreviewed) or
   `3FD4D` bit 3: **audio open** `030218B0` and **speaker amplifier** `0301D624(1)`.

Other `rxvoice` bits: `1` PI header (enable decryption, known), `4` call end → `0302197C` (audio close:
amp off, vocoder stop, `11000084 |= 2`), `03029318` (clears `3C620..3C623`, `3C61D`, `3C61A=0xFF`,
`3F722`), `0300D064(1,1)` (UI call-end notify), and posts `0x20000000` when `3BA41` is set (a TX transaction such as `03020EC8` waits on
`0x20000000`, inferred); `0x800`/`0x2000` (known TX answers); `0x4000` cleared only; `0x40000000` → `0300D028(8,2)`.

`030218B0` (audio open, code-verified writes, roles inferred): `11000084 |= 3`, optional recording start
(`3FDE0` bit 4 and `3FDD8` bit 4 → `00015FA4(2)`, `0302123C(1)`), when `03023A7C()==0` vocoder start
`00015F30(4,1)`, `00016000(1)`, `0001600C(0)`, then `000160C0()`; sets `3BD6C` bit 1. `0301D624(1)` drives
GPIO `0x35` through `0002C504` (amplifier, inferred) and sets `3FDD9` bit 1.

### 1.3 UI side: task `psint` `0305F234` (code-verified)

Created at `0300CDA6` (name `"task psint"` at `030770F0`, task argument block built at `0300CD80`). Loop: wait group
`3835C` bit 0, then dispatch on `2F0B4+0x600`: bit 0 → `0305EDBC`, bit 1 → `0305EF3C`, bit 2 → `0305F0F4`,
bit 3 → `0305E654`, bit 4 → `0305F1C0`, bit 5 → `0305EB8C`. Accessors `0300CDC8(sel)`/`0300CE80(sel,mask)`
map selector 9 → byte `+0x603`, 10 → `+0x604`, 11 → `+0x606`, 12 → `+0x607`, 13 → `+0x60C`, 15 → `3BD5A/3BD5B`.

- `0305F0F4` (sel 9): bit 0 → `0305E3F0` (call start), bit 1 → `0305EF88` (text, known), bit 3 → talker alias
  (`0301EE6C` into `3E11B`, compared with `3FD90`).
- `0305E3F0` (sel 11): stores source/class in `3E0EC`/`3E0F0`, sets display flag `3FDEC` bit 0, sets
  `3E0DC[0] = 10` (home/RX-call display state) and plays the call alert tones `0x25` (private, `3EA17` bit 2)
  or `0x23` (group/all, `3EA17` bit 1) via `030397E0`.
- `0305E654` (sel 10, call end) → `0305E5E4`: clears the name buffers `3E11B`, `3FD90`, `3BA75`, `3FDEC` bit 0,
  `3E0DD = 5`, `0301EF74()`, and `0301E850()` when Monitor is on.

Received call chain (code-verified): baseband IRQ → `030239D4` → `03028644`/`03028BE4` → `030282A4`
(accept, `3C620[slot]=1`) → event 2 → `rxvoice` → `0300D028(1,2)` → `psint` → `0305E3F0` (display/tones);
and `030218B0` + `0301D624(1)` (audio). Voice frames are copied by `03028644` into `3C69C` (known).

### 1.4 Event `0x8000000` = slot synchronisation acquired (code-verified post/wait; name inferred)

Posted by IRAM `0002D500` when the CACH TC history reaches `0101`/`1010` (slot lock, `3BEB1 = 1`), and by
`03023EB8` (rest-channel CSBK). The only waiter is the **TX admit** function `0301DF8C`: mode 1 (repeater)
after the wake-up loop (`03029C3C`, wait `0x10000000` for `33CE4` ms) waits 360 ms for `0x8000000` and then
calls `0301DE64`; mode 2 waits in its retry loop. `0x10000000` is posted by `03027388` and by `03028644`
(mode 1, BS-sourced data sync of type 9 Idle before slot lock), i.e. "repeater downlink seen" (inferred).
Both belong to the TX/PTT path and are read-only subjects.

## 2. Per-slot call state `3C620..3C627` and timers (work item 2)

`3C614` is the RX call-state block; offsets `+0xC..+0x13` are four 2-byte per-slot arrays.

| Array | Role | Writers | Readers | Confidence |
|---|---|---|---|---|
| `3C620[s]` | voice call active on slot s | set: `030282A4` (header), `03028BE4` (late entry); clear: `03028180` (terminator), `030275F4` (Idle), `03028644` (CC-mismatch counter), `03027388` (rest-channel change), `030297A4`, `030234E8`, `03029318` (both slots) | `03028644` (voice copy, MS gate), `03028BE4` (MS gate, duplicate check), `03023828` (sets `11000408` bit 15), `030237B8` (TX slot pick), `03023AFC`, `03027388` | code-verified |
| `3C622[s]` | data transfer active on slot s | set: `03024E7C`; clear: `03025480` (last block), `03028180` (data terminator FLCO `0x30`), `03024908`, `03027388`, `03029318` | `03025480` (gate), `03028644` (MS gate), `03023AFC`, `0301ED30` (returns `3C622|3C623`) | code-verified |
| `3C624[s]` | terminator seen on slot s (recently ended) | set 1: `03028180` (terminator, also when only the source is own ID); clear: `030282A4`, `03028BE4`, `0302343C` (other slot, 2..12 ticks), `03023394`, `030234E8` | `03027320` (TX admit, slot `3BEAA`) | code-verified writes; meaning inferred |
| `3C626[s]` | embedded-CC mismatch counter of the active voice call | reset: `030282A4`, `03028BE4`, `03028644` on every voice-sync burst and on matching embedded CC; `+1` on a non-sync voice burst whose CC (status bits 7:4) ≠ `33CCD` | `03028644` at `030289E2..03028A0A`: `> 6` → `3C620[s]=0`, post 4 (call end) | code-verified (disassembly) |

Notes:

- The `3C626` counter has **no Monitor bypass**, but it is reset by every voice-sync burst (A), so at most 5
  embedded bursts B–F are counted per superframe; it fires only after 7 consecutive mismatching bursts
  without a voice sync (signal loss, or a foreign embedded CC with broken sync). Monitor reception with a wrong
  CC is therefore not cut off by it in the normal case (inferred from the reset points).
- **Global burst-loss timer** `3BEB8` (`3BEA8+0x10`, halfword): incremented once per baseband tick by the IRAM
  task `txslot` loop at `0002D684` (after `0002D500` and `03023828`), cleared by every accepted burst in all RX
  handlers. `0302343C` (called at `0002D6A2`): in RX (`3BEAD != 2`) `2..12` ticks → clear `3C624[other slot]`,
  `≥ 13` ticks → `03023394` (posts 4 if a call is shown, full reset of both slots, slot lock and RX buffers).
  In TX state (`3BEAD == 2`) thresholds are 3 (mode 1/2 before lock) or 5. The tick is per TDMA slot
  (30 ms inferred from the per-burst TC toggling), so the RX reset is ≈ 390 ms after the last accepted burst.
- **No per-slot hang/capture timer exists.** The timer above is global; any accepted burst on either slot
  resets it.
- **Existing single-slot capture rule (code-verified):** for **MS-sourced** bursts (bits 3:2 == 0) in modes 0
  and 1, `03028644` returns when `3C620[other]==1` or `3C622[other]==1`, and `03028BE4` when `3C620[other]==1`.
  BS-sourced bursts are instead gated by the programmed slot (`3BEA8 != 33CCC`).

Design consequence for "TS Match off" (inferred, not implemented): reuse `3C620[s]`/`3C622[s]` as the
captured slot and apply the existing MS-sourced rule ("drop if the other slot has an active call or data")
to BS-sourced bursts instead of the `3BEA8 != 33CCC` comparison, in both `03028644` and `03028BE4`. Because
the other-slot drop happens before any `3BEB8` clear, the global timer then follows the captured slot and the
existing Idle/terminator/13-tick paths release the capture. TX slot fields (`33CCB`, `3BEAA`, `3BEAC`,
`11000100` bit 0) must not be written by the new path; note that `030282A4`/`03028BE4`/`03027B9C`/`03024E7C`
already copy the burst slot into `3BEAA`/`3BEAC` for MS-sourced (bits 3:2 == 0) traffic.

## 3. CSBK handler `03027B9C` — complete table (work item 3)

Entry (disassembly `03027BA4..03027BBE`): drop if `11000390` bit 26; if `3C61A == 33CCD` → main path, else only
the exception below. There is **no other CC comparison** and no Monitor bypass. After the gate, `3BEAB = 1` for
every CSBK except FID `0x10` opcode `0x3E` (set **before** the destination filter, so CSBKs addressed to other
radios also mark RX activity). Accepted CSBKs (filter `0302768C(3)` returns 0) clear `3BEB8` and, when the burst
is MS-sourced (bits 3:2 == 0), copy the burst slot into `3BEAA` (TX admission slot) in every mode.

| FID / opcode | CC gated | Address filter | Action | TX side effect |
|---|---|---|---|---|
| any, CC_rx = 15, mode 4, FID 0 op 7 (CT_CSBK) | **no** (exception) | none | `03024908` DCDM channel timing (§7.5) | changes own slot timing (`3BED8`, `11000400` bit 1) |
| 0 / `0x04` UU_V_Req | yes | dst = own ID | event `0x800` if src ≠ own ID | `rxvoice` transmits `UU_Ans_Rsp` |
| 0 / `0x05` UU_Ans_Rsp | yes | dst = own ID | if own request pending (`3BA43` bit 0): `03029674` starts own call | own call TX starts |
| 0 / `0x26` NACK_Rsp | yes | target bytes 7–9 = own ID | ends own request / UI result `0302154C(2)` | ends own TX attempt |
| 0 / other (e.g. `0x3D` preamble) | yes | dst = own ID | none | `3BEAB` (channel busy) |
| `0x10` / `0x1D` Remote Monitor | yes | target bytes 7–9 = own ID; src ≠ own | `0x4000000` → `rxcsbk` | ACK/NACK, then TX to requester |
| `0x10` / `0x1E` | yes | dst = own; src ≠ own | `0x2000` → `rxvoice` | `030297A4` burst, own TX audio stopped |
| `0x10` / `0x1F` Call Alert | yes | dst = own; src ≠ own | `0x2000000` → `rxcsbk` | ACK/NACK |
| `0x10` / `0x20` ACK | yes | dst = own; src ≠ own | `0302154C(4)` result of own command | none |
| `0x10` / `0x24` byte 3 `0x00` Radio Check | yes | target bytes 7–9 | `0x400000` | ACK/NACK |
| `0x10` / `0x24` byte 3 `0x7E` Enable | yes | target bytes 7–9 | `0x40000` | ACK/NACK, revive |
| `0x10` / `0x24` byte 3 `0x7F` Disable | yes | target bytes 7–9 | `0x100000` | ACK/NACK, persistent stun |
| `0x10` / `0x24` byte 3 `0x80`/`0xFE`/`0xFF` | yes | dst bytes 4–6 | `0302154C(4)` | none |
| `0x10` / `0x26` NACK | yes | target bytes 7–9 = own ID | `0302154C(5)` | none |
| `0x10` / `0x27` (alarm-type request, §7.7) | yes | dst ∈ `33CF4..33D77` (contact + RX group list), src ≠ own | `0x1000000` only if `3BA6C` bit 5 | ACK `0x20/0xA7` if `3BA6C` bit 6 |
| `0x10` / `0x3E` | yes | always accepted | `03023EB8` slot/retune | writes `33CCB/33CCC`, `3BEAA/3BEAC` |
| `0x10` / `0x3D`, mode 2, filter rejected | yes | rejected branch | sets slot from byte 7, may retune `03023C10` (skipped while `33CDD` is set; `rxvoice` sets it while it handles an event) | writes TX/RX slot |

All rows are code-verified from `03027B9C`/`0302768C`; opcode names are inferred (ETSI/MMDVM numbering).

## 4. IRAM `0002D7C8` and the `11000384 |= 0xF` branch (work item 4)

`0002D7C8(slot)` is called once per tick from the `txslot` task loop at `0002D692` with the current burst slot.
It is the **TX burst loader**: it takes the head of the per-slot TX queue (`3C6F0+0xA4+4·slot`, filled by
`030294C8`), writes the payload to the baseband (`0300D3EC`), the burst type to `11000418` and voice/LC
data, then frees the entry. With an empty queue it only re-arms `11000408` bits 7:6.

`11000384` bits 3:0 writes (code-verified, all guarded by `33CC9 == 4`):

| Site | Condition | Value |
|---|---|---|
| empty queue | mode 4 | `33CCD` (configured CC) |
| voice entry, sub-state 6 (last voice burst) | mode 4 | `33CCD` |
| data/CSBK entry | mode 4 and entry burst type (`+3`) = 3 (CSBK) and opcode (`+5 & 0x3F`) = 7 | **`|= 0xF` (CC 15)** |
| data/CSBK entry | mode 4, anything else | `33CCD` |

So the `|0xF` branch runs only in RX mode 4 when the radio **transmits** a CT_CSBK (FID 0 opcode 7). It is the
transmit counterpart of the receive exception in `03027B9C` (CC 15 + mode 4 + CT_CSBK → `03024908`). It is
not related to CC Match and is TX behaviour (read-only subject). Mode 4 is the "Double Slot" channel mode
(§6), which by the CT_CSBK fields (§7.5) is **inferred** to be ETSI Dual Capacity Direct Mode.

## 5. Analog Monitor `0301742C` (work item 5)

`0301742C` (code-verified):

1. Refused when `3E337` bit 6 is set or the permission callbacks `030140E4(0x11)` refuse.
2. Scan interaction: scan mode 3 (`0302ECE0()==3`) → if `3E170` bits 4:3 clear switch to scan mode 6 and load
   the current scan channel (`030584E4(3E166, 8)`), else refuse.
3. Only when the current channel type nibble (`3E200` bits 7:4) is 0 (analog): toggle on `3E340`
   (`3E334+0xC`): `0` → `03060398` (on), else `030603DC` (off); redraw via `030193CC`. Otherwise tone `0x21`.

| Function | Effect | Confidence |
|---|---|---|
| `03060398` (on) | `3E340 = 1`; `0305BE0C(0,0)` → `0301E558` sets bit 5 of `160009CB`; `0300C2DC(1)` sets `11000080` bit 6; `0002B51C` writes RF chip register `0x47` (`(r & 0xF0FF) | 0x100`, or `0x6740` when `3E345` bit 5); `0301D624(1)` amplifier on; `030611B0` GPIO `0x20` on unless `3EA06` bit 4 | code-verified writes; register meanings inferred (AF output enable) |
| `030603DC` (off) | if no squelch-open state (`3FDEC` bit 2 clear) and analog: `0002B550` (reg `0x47` bits 11:8 = 0), amp off, `11000080` bit 6 clear, GPIO `0x20` off, `160009CB` bit 5 cleared; clears `3E340` | code-verified |
| `0300E2C0` (squelch open, from `03060A74`) | same unmute sequence, sets `3FDEC` bit 2 | code-verified |
| `0300E360` (squelch close) | clears `3FDEC` bit 2; mutes **only if `3E340 == 0`** | code-verified |
| `03060A74` (squelch poll) | decides open/close from `3FE25` (`3FE08+0x1D`) bits 2/1/0 (carrier / tone match, inferred) and the channel RX tone type `3E20E` bits 6:4 | code-verified control flow |
| `0302ED04` (busy test for scanning) | returns busy when `3E340` set on an analog channel | code-verified |

Lifetime: cleared by `030603DC` from the channel-load path `03057790`, the key/menu paths `030149E8`,
`030153A4`, `03015AC8`, `03016EDC`, `03017188`, and directly by `0302FA24` (plays tone `0x18`).
The analog Monitor is therefore "audio forced open regardless of carrier and CTCSS/DCS until toggled off or
the channel changes" (code-verified mechanism; the RF chip's register map is not identified, so "AF output
enable" for register `0x47` is inferred).

## 6. Time slot setter `0301ECC0` and the channel menu (work item 6)

Code-verified chain:

- The channel-menu confirm handler `0304DDB0` (caller `0304E6CE`) dispatches through the 22-entry table
  `030B2150` by item id `3E6A5[3E50B+2]`. The ids match the channel-menu string list at `030B9940`:
  id 5 `Color Code` → `0304E0BA` → setting `0x33` ('3'); id 6 **`Time Slot`** (`030BE52C`) → `0304E114` →
  setting **5**; id 9 `Channel Type` → `0304E24E` → setting `0x44` ('D'); id 10 **`Double Slot`**
  (`030BE558`) → `0304E272` → setting `0x46` ('F').
- `Time Slot`: list index `3E5EC` = 0 → `0304B158(5, 0)`, otherwise `0304B158(5, 1)`. Setting 5 stores the value
  in `3EA11` (`3E9D4+0x3D`), calls **`0301ECC0(value)`** (only caller: `0304C2C8`, `r0` reloaded from the
  argument at `0304C2BE`) and `03056FFC(value)`.
- `03056FFC` sets/clears bit 4 of the current channel copy `3E205` and of byte `+0x0D` of the channel record in
  data flash: `03056680` → `03055CCC(channel)` gives block `0x12`, offset `0x20 + 0x30·(n−1)` for channels
  1–84, then 85 channels per following 4 KiB block from offset `0x10`; VFO mode uses area `0x41` offset
  `0xFAF`/`0xFDF`. `0300FA28` writes the byte; in VFO mode `03030370` saves the VFO record instead.
- `Double Slot`: `030571CC(value)` sets channel byte `+0x0D` bit 5 when the menu index is 0, else clears it
  (same record write path). `03056330` selects RX mode 4 from that bit on simplex digital channels.

So both menu items edit the CPS channel record byte `+0x0D` (bits 4 and 5) and Time Slot additionally retunes the
running slot immediately via `0301ECC0`. Labels of the two Double Slot list entries are not established.

## 7. Data-path internals left open in `DATA_PATH_ANALYSIS.md` §10 (work item 7)

### 7.1 `03026E78` — reply builder for the `0x44` format (code-verified)

TX data context `3BF00` (same layout family as `3C278`). Confirmed (`param_2 == 1`): A = 1, DPF 3, data type 8
(rate ¾, 18-byte blocks, CRC-9 mask `0x1FF`), N(S) incremented unless a retry. Unconfirmed: DPF 2, data type 7
(rate ½, 12-byte blocks, mask `0x0F0`). SAP = 9. Payload from `03025B28(ctx,1)` (8 bytes, §7.6). Sends preamble
CSBKs (`03029B3C`), the data header (`03025DAC`), a second header built from context fields `+4=0xF`, `+5=1`, `+6=0x10`, `+7=2`, `+8=2·G/I` and
6 payload bytes (inferred: DPF 15 proprietary header, MFID `0x10`) and the blocks (`030260C4`). Mode 0 confirmed: `030268CC`; mode 4: `03024794`.

### 7.2 `030260C4` — TX data block segmentation (code-verified)

Splits `ctx+0x4B` (length `+0x36C`, cursor `+0x36E`) into blocks of `ctx+0x34` bytes, queues each with
`030294C8`. Unconfirmed: plain blocks, CRC-32 (`0300C224`) over the payload placed in the last 4 bytes.
Confirmed: per block byte 0 = DBSN·2 (7-bit), CRC-9 (`0300C154`) over data and DBSN, xor `~mask`, stored in
bytes 0–1; CRC-32 in the last block. Returns 1 if no TX queue entry is free after a 60 ms retry.

### 7.3 `0302695C` / `03026600` — retransmission of own confirmed data (code-verified)

`0302695C(…, full, bitmap, len)`: selective mode (`full == 0`) counts the zero bits of the received SACK bitmap
(≤ 20 bytes) as blocks to follow and copies the bitmap to `3BF37`; then preambles, header and
`03026600(ctx, full)`, which re-sends every block whose bitmap bit is 0 (or all blocks). Callers: `0301F118`
(SMS send transaction, 4 sites) and `rxmsg` (`03020200`…`03020438`, reply retries).

### 7.4 `03029674` — own voice call start (code-verified, TX side)

`03029674(group, fid10, privacy, key, dst, src)`: FLCO 0 (group) or 3 (private), service options bit 3
(broadcast) for all-call IDs `FFFFFx` or mode-2 ID `0xFF`, bit 5 when `fid10`, bit 6 privacy; queues three voice
LC header bursts (`0302958C`), a PI header (`03029618`) when private, then a voice-start entry. Used by
`03027B9C` (UU_Ans_Rsp) and the user call paths. Read-only subject.

### 7.5 `03024908` — mode-4 channel timing (code-verified fields, protocol inferred)

Parses the CT_CSBK: 11-bit value (bytes 2–3), 5-bit value, two 20-bit IDs with 2-bit qualifiers
(bytes 4–6, 7–9) and a 2-bit field from bytes 6/9 bit 0. Compares the IDs with the own timing leader
`3BED8+0xC`; adopts a larger leader (`03024894`: state `3BED8=2`, timer 500 via `0300C6E4`, slot from
`11000390` bits 3:2 in `03024868`), keeps its own (`0302454C`), or re-randomises (`03070670`). Clears
`3C622[slot]` on some paths. The field layout matches the ETSI DCDM channel-timing CSBK (sync age, generation,
leader identifier, new leader, leader dynamic identifier) — inferred.

### 7.6 `0x44` and SAP-3 payload formats

`0x44` format (code-verified, both directions: builder `03025B28`, classifier `0302530C`):

| Byte | Message | ACK |
|---|---|---|
| 0 | `0x44` | `0x44` |
| 1 | 0 | 0 |
| 2 | sequence (`ctx+0x30`) | sequence |
| 3–4 | total length + 4, big endian (RX: `≥ 4` → message, event 4) | `00 03` (RX: event 8) |
| 5 | `0xA0` individual / `0xE0` group | `0xBF` |
| 6–7 | message id (`ctx+0x32` = caller value − 0x80) | message id |
| 8 | 4 | — |

Vendor/compressed text format; its origin is not established (inferred: proprietary short header).

SAP 3 (`0302530C`, code-verified tests; ETSI names inferred from TS 102 361-3 UDP/IPv4 header compression):
event `0x8000` when byte 2 ∈ {0, 2} and bytes 3–4 = `01 01` (compressed header with source/destination port id 1,
inferred: text message port), message id = bytes 0–1; event `0x2000` when byte 0 = 0 and bytes 5–6 = `27 7E`
(position record). Text/position offsets are as in `DATA_PATH_ANALYSIS.md` §4.

### 7.7 FID `0x10` opcode `0x27` (code-verified gating, meaning inferred)

`3BA6C` bit 5 (accept) and bit 6 (ACK) come from `0301EC88`/`0301EC94`, called only by `0305DA8C`
(caller `030582BE`, channel load). `0305DA8C(…, w)` takes a channel-derived word: bit 31 → bit 5, bit 30 → bit 6,
bits 28:24 = a 1–15 index into an emergency-system record copied to `3FD7E..3FD8B` (field names inferred: alarm type, mode, repeat
counts). With bit 6, `rxcsbk` answers `0x20/0xA7` and runs UI action type 6 (alarm display). So `0x27` is
inferred to be an **emergency alarm** addressed to a contact/group, accepted only on channels whose emergency
system enables alarm reception.

### 7.8 Inbox records in data-flash area 7 (code-verified)

`03053D74(record, len, kind, fmt)`: kind 1 → area 7 (Inbox; counter `18000AA8`), kind 3 → area 8, kind 5 →
area 9 (Outbox/Draft-like, unreviewed). Area header: offset `0x00` 13-byte used-slot bitmap (100 slots),
offset `0x30` 100-byte age-ordered slot list (oldest first; full list → oldest slot reused).
Records are `0x110` bytes: 13-byte header (byte 0 = status nibble 3 for new Inbox, 1 otherwise, bits 3:2 = `fmt`;
byte 1 = length) followed by the data at `+0x0D`. Slot → location by `03052FBC`: slots `< 14` in the area's
first block at `0x130 + 0x110·(k−1)`, others in another block. Data from `0305D764`: 3-byte source ID (LE),
text converted from UTF-16 (`0301104C` for non-ASCII), terminating 0.

### 7.9 Enable / "revive" `0305F2F4` (resolved as restart, strong inference — `SETTINGS_CPS_ANALYSIS.md` §5)

`0305EB8C` type 4: if stunned (`0305DF8C`), `0305DFA4(0xA0)` writes `A0, <0304C434(6)>, 3E1B4 (16 bit)` to
area 4 offset `0xF00`, then `0305F2F4`. Boot (`0305DF4C`) treats `0xA5`/`0xA6` as stunned and anything else as
normal, so the persistent part of the revive is the `0xA0` marker (code-verified). `0305F2F4` itself only writes
`1100005C = 0x01000000` (boot `0002BB9C` writes `0x01000001`) and `11000000 = 0xFFFFFE7F`; it has 15 callers,
e.g. after the data-area resets at `03033116..0303312A`. Inferred: system restart/power latch; not established.
The RAM stun flags are not cleared on this path, which supports the restart reading.

## 8. Settings persistence and CPS protocol (work item 8, partial)

### 8.1 Block 4 (general settings) loaded by `0304B010` (code-verified)

| Offset | Destination | Transform |
|---|---|---|
| `0x60` bits 0/1 | `3EA06` bits 5/6 → `3BA6D` (PCall/GCall Match, known) | — |
| `0x61` | `33CE8` (`33CC8+0x20`) | `(v+1)·50` |
| `0x62` | `33CE4` (`33CC8+0x1C`) wake-up wait used by `0301DF8C` | `(max(v,1)−1)·30 + 300` |
| `0x63` | `33CE1` (`33CC8+0x19`) wake-up retries | clamp 1..8 |
| `0x64` | `3E334` byte 0 | `v+2`, `v > 0x11` → 0 |
| constants | `33CDE` (`+0x16`) = 3 confirmed-data retries, `0301E7FC(3)`, `0301E80C(0x14)`, `0301E824()` | — |

Own DMR ID: `0301E798(*3F018)` from the channel's DMR-ID index (channel byte `+0x1B` via `03057654`) at
`0304CF6A`, `0305034E`, `03057704`, `03058412`. Configured CC: channel byte `+0x0D` bits 3:0 via `0301E7BC`.

### 8.2 Setting id → block-4 offset map in `0304B158` (code-verified writes; menu labels in `SETTINGS_CPS_ANALYSIS.md` §1)

| Id | Offset / target | Id | Offset / target |
|---|---|---|---|
| 3 | `0xA0` (+ `3EA09`), `0305D8C0` | `0x2C` | `0xA8` (2 bytes) |
| 5 | channel `+0x0D` bit 4, `3EA11` (Time Slot) | `0x2D` | `0x31`, `3EA0E` |
| 7, 8, `0x38`, `0x5A` | `0xA4` | `0x2E` | `0x86`, `3EA2B` |
| 9, 10 | `0x60` bits 0/1 (PCall/GCall Match) | `0x31` | `0x30`, `3EA29` |
| `0x0C`, `0x0D`, `0x43` | `0x80` | `0x3A` | `0xA2`, `3EA32` |
| `0x0F` | `0x85`, `3EA04` | `0x3E`, `0x40` | `0x40` |
| `0x10`–`0x16`, `0x18` | `0x20` bits | `0x3F` | `0x41` |
| `0x17`, `0x1A`, `0x2A` | `0x21` bits | `0x41` | `0x00`, `3EA08` |
| `0x33` | channel CC (`030572B8`) | `0x45` | `0x65` (decode/SMS bits) |
| `0x44`/`0x46` | channel `+0x08` / `+0x0D` bit 5 | `0x51` | `0x93`, `3EA30` |
| `0x54`/`0x55` | `0xA7`/`0xA6` | `0x56` | `0x33` |
| `0x52`/`0x53`/`0x57` | area `0x11` `0xE01`/`0xE05`/`0xE00` | `0x59` | `0x301`, `0x8B`–`0x90` (key functions) |
| `0x5F` | `0x1E` | `6`, `0x2B` | area `0x5C` (zone/channel position) |

No setting id writes `3E341` bit 1 (Monitor) or `3BA6C` bit 3: Monitor state is not persisted (consistent with
`MONITOR_ANALYSIS.md` §5).

### 8.3 CPS protocol (framing completed in `SETTINGS_CPS_ANALYSIS.md` §3)

USB frame loop `03029FB0` (task `"task usb"` created by `03029F44` has entry `0302B340`; correction in `SETTINGS_CPS_ANALYSIS.md` §3.1). Command words at `030B08AC`:
`PROGRAM`, `PON-PIC`, `PSEARCH` (answer `DP570UV`), `PASSSTA`, `PASWORD`, `PCTESTM`, `RTCITEM`, `DEL-RCD`,
`IDCHECK`, `SYSINFO`; handler pointers at `030B0860`. Inside the session: `'V'` version items (1 =
`DM32.NRF.01.049`, 3 = `2022_06_27`, 4/5/11 = `D1 01.01.004`/`R1 00.01.001`/`C1 00.01.001`, 6–10/14 = pairs of
words from `030AEAB0..030AEAF0`, inferred band limits); `'G'` reads data flash (`03010DDC`) and answers with `'S'`-framed data; `'S'` writes SPI flash
(`0002C164`, erasing at 4 KiB boundaries with `0002C0FC`); `'C'` calls `03010DB8(0x10C, …)` (unreviewed); each write is
ACKed with `0x06`. `0302B224` checks the CPS password (`'P','W'` → block 4 `0x43B`, `'P','R'` → `0x443`,
8 bytes) and answers `0x06`/`0x15`. Framing, addressing and lengths are unreviewed. **Do not test this on the
radio from an agent.**

## 9. Open questions for the owner

1. Does CPS show an "Emergency System" with "Alarm receive/ACK" options per channel (would confirm §7.7)?
2. What are the two list entries of the radio's **Double Slot** channel menu item (to map bit 5 = index 0)?
3. Which CPS options correspond to block 4 offsets `0x61`–`0x64` (preamble/wake-up related, §8.1)?
4. Is TS Match off meant to follow only the first call (capture) or to prefer a priority slot?

## 10. RX-only owner hardware test proposals (stock firmware, no CPS write beyond normal programming)

| Finding | Test | Expected if correct |
|---|---|---|
| §1.3 call-start UI: tone `0x25` private / `0x23` group only when the matching option bit is set | Receive a group call and a private call with the "call alert tone" options on and off | Tone on start only when enabled; display shows source |
| §2 burst-loss timer ≈ 390 ms | Listen to a repeater kerchunk without terminator (e.g. key up and walk out of range) | Display/audio clear within about 0.4 s of the last burst |
| §2 MS-sourced capture rule | Simplex channel, two other radios on the frequency: start a call from radio A, then radio B transmits on the other slot | Only A heard until A ends |
| §5 analog Monitor | Analog channel with CTCSS; press Monitor with no signal, then with a signal using the wrong tone | Noise/audio audible in both cases; Monitor off restores squelch; channel change turns it off |
| §6 Time Slot menu | Change Time Slot in the radio menu, power-cycle, read the codeplug with CPS (read only) | Channel's TS changed in CPS (byte `+0x0D` bit 4) |
| §7.7 `0x27` | With a second radio, send an emergency alarm to a group in the RX list on a channel with and without an emergency system | Alarm shown only when enabled; ACK only when ACK option set |
| §4 CC 15 on CT_CSBK (mode 4) | Not testable RX-only without a DCDM peer; skip | — |

## 11. Not reviewed

`030297A4` internals; `03023EB8`/`03023C10` retune timing; `0301E834` consumers of `3BA68..3BA6C`; recording path
(`0302123C`, `00015FA4`); vocoder functions `00015F30`…`000160C0`; RF chip identity (register `0x47`);
`0305F2F4` hardware meaning; area 8/9 roles; full CPS framing; labels of most setting ids in §8.2; the
`0x4000` event (status bit 17 embedded data) and `3C628` (embedded LC qualifier) semantics.

## 12. Second pass (2026-10-14, unattended)

Closed from §11 in `SETTINGS_CPS_ANALYSIS.md`: `030297A4` (queues a Terminator with LC), `03023EB8`/`03023C10`
(rest-channel follow and retune), `0305F2F4` (system restart, strong inference), message areas 8/9 (OutBox,
DraftBox), status bit 17 / event `0x4000` (embedded privacy parameters, inferred), RF chip (BK4819 register map,
strong inference; analog Monitor = AF type 1, AM airband = AF type 7), CPS framing, labels for most setting ids,
and free storage bits for future TS/CC Match options (block 4 `0x60` bits 2–7, `3BA6D` bits 5–7).
Still open: recording/vocoder internals, `03029C78`/`3C7A4`, `03023D24`, the CPS handshake handlers, `Digit Monitor`.

## 13. Third pass (2026-10-14, unattended)

| Item | Finding | Confidence |
|---|---|---|
| Task chain | `sysint` (IRAM `0002D770`) loops on `0300C850(0)` and calls the burst dispatcher `030239D4` while `33CC8[0] == 0` (digital); `rxslot` `0302386C` and `SlotTimer` `030293C8` only count/toggle (`31294`, `3C6E8`) | code-verified |
| `3F720` / `3F722` | voice-privacy context: byte 0 algorithm (1 → `00014698` key schedule with a 9-byte key and `000147AC(…,0x7E)`, ARC4-like; 2 → `0001D4B8`/`0001D4C4`, AES-like; 4 → `0001CFAC`), byte 1 key id; `3F722` = decrypt active, set by the PI-header match in `rxvoice` and by `03027628`, cleared by `03029318`/`030234E8`; `03028644` then runs `0002B300`/`0002B30C` over each voice burst. Not recording (correction to `TS_ANALYSIS.md` §8) | code-verified flow; algorithm names inferred |
| `03029C78` | builds a CSBK (byte 0 `0x9E` = last block + opcode `0x1E`, FID from entry `+2`, IDs from `+4..+11`) and writes it **directly** to the baseband (`0300D3EC`, `11000418`), bypassing the TX queue; called from `03028644` (burst 4) and `03028BE4` when `3C7A4[12·slot]` is non-zero and the LC service bits 5:4 are `0x30` | code-verified |
| `3C7A4` arming | `3C7A4 = 3C6F0+0xB4`; no literal, constant-offset store or block copy writes it anywhere in flash/IRAM (scans of all functions plus the uncatalogued tasks `txmsg`, `rxmsg`, `sysint`, `SlotTimer`, `rxslot`, `CclTraffic`) → the direct-TX path looks **dormant** in this build | inferred (absence) |
| TS-off design | receive consumers indexed by `3BEAA`, voice-only bypass and TX-admission interaction added to `MATCH_OPTIONS_DESIGN.md` §3.3–3.5 | code-verified sites; design inferred |

