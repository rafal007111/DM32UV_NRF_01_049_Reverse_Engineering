# Stock Monitor side-key function — DM32.NRF.01.049

Static analysis, 2026-10-13. Ghidra 12.1.4 PUBLIC headless, legacy CSKY v0.2 module + `32b_data.fixed.sinc`,
program `analysis/archives/DM32_NRF_049_correct_base.gzf` (SHA-256 `354f9324…`), stock image `de7dbcbc…`.
RAM addresses below come from literal pools resolved against the stock image (`PTR_DAT_x` → value).
No hardware test has been performed for anything in this file.

Confidence labels follow `docs/RE_NOTES.md`. "code-verified" here means read from decompiler output
and cross-checked by BSR/literal scans of the stock image; decompiler types and field names are not
proven.

## 1. Key binding and dispatch

| Item | Evidence | Confidence |
|---|---|---|
| Side-key function names: 43-entry pointer table at `030BB424` (`None` … `ManDown`); entry 25 = `Monitor` (`030BB488`) | string pointer scan | code-verified |
| Handler table: 43 entries, flash `030728DC`, copied by startup to RAM `1800090C` (init-data copy `030727D0`→`18000800`); entry 25 = `03017560` | literal/BSR scans, startup header words `+0xC4/+0xCC` | code-verified |
| `030168CC` reads key-function bytes from codeplug block 4, offsets `0x87`…`0x90`, clamps to `<0x2B`, and stores handler pointers from the RAM table into the key slot array at `392F4` | decompiler | code-verified |
| Functions 30 (`TBST Send`) and 38 (`Sub PTT`) get extra press/release flags at `392F0`/`392EC`; Monitor (25) does not, so it acts on a single press | decompiler | code-verified (press semantics inferred) |

## 2. Handler chain

`03017560` (Monitor handler):

1. Returns at once if bit 1 of `3FDDB` is set (same gate as `030140E4`).
2. `03064C9C()`; if `0302ED04()==0` and bit 7 of `3E344` clear and `030649A8()!=0` → `030649B0(1)` (unreviewed).
3. Channel mode `m` = bits 6:4 of channel byte `3E200` (`3E1F8+8`), or from `0002DED4()` when `0302ED04()==0`.
4. `m==2`: sets bit 1 of `3E1DB`, calls `03030560(0xD)`, treats it as `m=0`.
5. While scanning in scan mode 3, `m` comes from bits 5:4 of `3E170` (`3E160+0x10`).
6. `m==0` → `0301742C` (analog monitor). Otherwise → `030174E0(m)`.

`m` values 0/1/3 behave as analog / digital / digital-capable; their CPS names (Analog, Digital, mixed types) are **inferred**.

`0301742C` (analog): if `3E337` bit 6 clear and `030140E4(0x11)` allows it, toggles analog monitor through `03060398`/`030603DC` (selected by `3E340`); otherwise tone `0x21`. Reviewed 2026-10-14: forces the audio path open and makes the squelch-close handler `0300E360` skip muting; see `RX_CALL_PATH_ANALYSIS.md` §5.

`030174E0(m)` (digital):

- Refuses (tone `0x21`) when `m` is not 1 or 3, or when bits 5:4 of `3E0E6` equal `01` (state unreviewed).
- `030140E4(0x19)` runs the 12 permission callbacks at `03014124`; any zero blocks the action.
- Toggle on bit 1 of `3E341` (`3E334+0xD`): clear → `0305CCF0(1)` + tone `0x18`; set → `0305CCF0(0)` + tone `0x19`.
- Redraws the home screen via `030193CC` when the UI scene byte `320CB` is 0 or `[`.

Tone IDs: `03021C1C(id)` stores `id` at `3BE64` and posts event `0x40` to `3FDB0`; task `03022FB0` waits on that event and plays tones through `03022410`/`03021C88` (sine table `030AEBA0`). So `0x18`/`0x19`/`0x21` are **audio tone IDs**, not text prompts (code-verified). Their meanings "on"/"off"/"refused" are inferred from the call sites. No other code reads bit 1 of `3E341` for display, so there is no on-screen Monitor indicator in the paths searched (full-program decompiler search).

## 3. State written by the setter

`0305CCF0(on)` → `0301EC40(on)` and bit 1 of `3E341` = `on`.

`0301EC40(on)`:

- bit 3 of `3BA6C` (`3BA54+0x18`) = `on` — the software **Monitor flag** read by the RX path (section 4);
- `11000384` bits 9:8 cleared, then bit 8 = `on`;
- byte `3C61B` (`3C614+7`) = 8 if `on`, else 0.

Related register use (code-verified):

- `0301E7BC(cc)` sets `33CCD` (`33CC8+5`) = channel Color Code and `11000384` bits 3:0 = `cc`. Called from `030572B8`, `03057790` (channel load path). So `11000384` holds the configured CC in bits 3:0 and a CC-related enable in bit 8.
- `0301E580(digital, mode, slot)` (RX mode setup; callers `030215C8`, `03056330`) re-applies bit 8 and `3C61B` from the Monitor flag for non-mode-4 digital setups, and **forces** bit 8 for `mode==4`. It also sets `33CC9` (mode), `33CCB`/`33CCC` (slot) and `11000100` bit 0 (slot). Mode 4 meaning is unreviewed.
- `0002D7C8` (IRAM, TX burst loader) also writes `11000384` bits 3:0 in mode 4 only: CC 15 while a CT_CSBK is transmitted, otherwise `33CCD` (`RX_CALL_PATH_ANALYSIS.md` §4).

The hardware meaning of `11000384` bit 8 (HR-C7000 baseband) is **inferred** to be "accept any Color Code"; the software checks below are code-verified independently of it.

## 4. Effect on DMR receive

Receive status word: `3BECC` (copy) or register `11000390`. Fields used: bits 1:0 sync class, bits 11:8 DMR data type (0–10; values >10 rejected), bits 7:4 received **Color Code** (stored at `3C61A`, `3C614+6`), bit 25/26 error flags. Configured CC: `33CCD`.

Dispatcher `030239D4` → `03028644` / `03028BE4`. For data-sync bursts `03028644` checks `CC_rx == CC_cfg || MonitorFlag` before the data-type jump table at `030B0548`:

| DMR data type | Handler | CC check inside handler | Monitor bypass |
|---|---|---|---|
| 0 PI Header | `03027584` | requires match | **no** |
| 1 Voice LC Header | `030282A4` | match or Monitor | **yes** |
| 2 Terminator with LC | `03028180` | match or Monitor | **yes** |
| 3 CSBK | `03027B9C` | compares CC on some paths | partial (not traced) |
| 4/5 MBC | — | — | — |
| 6 Data Header | `03024E7C` | requires match | **no** |
| 7/8/10 Rate ½/¾/1 data | `03025480` | requires match | **no** |
| 9 Idle | `030275F4` | — | — |

`03028BE4` (other burst path, voice/late entry) also accepts on `CC match || Monitor`. Voice bursts (sync class 1) are played only for a slot already marked accepted (`3C620+slot`), which the LC header or late-entry paths set.

Address filtering, `0302768C` (called from the voice LC, terminator, CSBK, data header and `03028BE4` paths): compares the destination ID with own ID (`33CC8+0x24`), the channel contact (`33CC8+0x2C`) and the RX group list (`33CF8`). With the Monitor flag set it returns "accept" before those comparisons in the private and group branches. So Monitor also opens **talkgroup / destination filtering** for voice (code-verified for the branches read; full branch coverage unreviewed).

Time slot: one branch of `03028BE4` (selected by a mode byte that is `33CC9` or a per-slot state, decompiler variable reused) still requires received slot (`3BEA8`) == configured slot (`33CCC`) with no Monitor bypass. Monitor is therefore probably **not** a dual-slot monitor (inferred; the branch selection is not fully traced).

Additional readers: `0305E5E4` calls `0301E850` when the Monitor flag is set (role unreviewed); `0302C4FC` skips an action when bit 1 of `3E341` is set (role unreviewed).

## 5. Lifetime

- Cleared in `03031FD4` (channel/home refresh path that recomputes the current channel): it clears bit 1 of `3E341` and calls `0301EC40(0)` when the radio state byte `3E335` is 1 or 9, and in its state-10 branch. That this runs on every channel change is inferred from its callers and the current-channel lookup it performs.
- Cleared by `0305E134` (`0305CCF0(0)` on two paths; role unreviewed, it also stops scanning).
- No persistence of bit 1 of `3E341` across power cycles was found (not proven).

## 6. Summary and consequences for CC Match

On a digital channel the stock Monitor key is a temporary **promiscuous voice receive** mode: it ignores the Color Code and destination/talkgroup filtering for voice calls (LC header, terminator, late entry). It does **not** bypass CC for PI headers, data headers or packet data, and does not remove the time-slot restriction in the path read. It beeps (tones `0x18`/`0x19`) and is reset by channel changes.

For the planned **CC Match off** setting this means:

- the infrastructure exists (flag `3BA6C` bit 3, register `11000384` bit 8, re-apply in `0301E580`);
- but the stock flag also disables talkgroup filtering, so reusing it as-is would be "promiscuous", not just "ignore CC";
- a narrower CC-only option would need a separate flag or patches at the CC comparisons (`03028644`, `030282A4`, `03028180`, `03028BE4`, plus the non-bypassed data paths if data should follow).

## 7. Owner test (stock firmware, RX only)

1. CPS: assign **Monitor** to a side key; program a DMR channel for the local repeater with a **wrong Color Code**; keep the correct slot and talkgroup/RX group.
2. On that channel press Monitor once (expect a tone), do not change channel, and wait for voice traffic.
3. Expected if this analysis is right: voice audible with Monitor on, silent with Monitor off; SMS/GPS data still not received.
4. Optional second test with the **correct** CC but a talkgroup outside your RX group list: Monitor on should make that traffic audible.
5. Record which tone sounds on each press.

## 8. Follow-up 2026-10-14

See `RX_CALL_PATH_ANALYSIS.md`. Relevant to the Monitor test: during an accepted voice call `03028644` counts
non-sync voice bursts whose embedded CC differs from `33CCD` in `3C626[slot]` and ends the call after 7 in a row,
**without** a Monitor bypass; the counter is reset by every voice-sync burst, so normal foreign-CC traffic
should still play (inferred). If the owner's wrong-CC Monitor test gives choppy audio or calls that drop after
about half a second, this counter is the first suspect. The received call reaches the UI through event 2 →
task `rxvoice` → `psint` `0305E3F0` and the audio through `030218B0`/`0301D624` (code-verified).

## 9. Datasheet cross-check (2026-10-14, fifth pass)

`docs/HR_C7000_CROSSCHECK.md`: `11000384` bits 9:8 are `LOCAL_CC.cc_opt` (datasheet p. 301). Bit 8 set = `cc_opt = 1`,
"decode frames with any correctly received CC"; with `cc_opt = 0` the chip decodes only frames whose CC equals the
local CC. The "accept any Colour Code" reading of §3 is therefore **datasheet + code** (not hardware-verified).
The firmware does not clear `RF_MODE` (`11000104`) bit 12 `adjustsyncmax`, which the datasheet requires when
`cc_opt = 1` (open question in that file, §5). The user manual (§5.10 and the icon table in §4.3) lists a Monitor
status icon; the search in §2 found no reader of `3E341` bit 1 for display, so the icon source is still open
(it may be drawn from another state; unreviewed).
