# Colour Code comparison sites — DM32.NRF.01.049 (step 3)

Static analysis, 2026-10-14, same inputs as `docs/MONITOR_ANALYSIS.md`. Full-program decompiler search for
reads of the configured CC (`33CCD`, `33CC8+5`) and received CC (`3C61A`, `3C614+6`, or status bits 7:4).
No hardware test performed.

| Site | Role | Compares | Monitor bypass | CC Match off should |
|---|---|---|---|---|
| `03028644` (data-sync gate before type table) | RX headers/data | status CC vs `33CCD` | yes | bypass |
| `030282A4` | RX voice LC header | `3C61A` vs `33CCD` | yes | bypass |
| `03028180` | RX terminator with LC | `3C61A` vs `33CCD` | yes | bypass |
| `03028BE4` | RX voice / late entry | status CC vs `33CCD` | yes | bypass |
| `03027584` | RX PI header | `3C61A` vs `33CCD` | no | bypass if encrypted-call headers should follow |
| `03024E7C` | RX data header | `3C61A` vs `33CCD` | no | owner decision (data/SMS/GPS) |
| `03025480` | RX packet data (types 7/8/10) | `3C61A` vs `33CCD` | no | owner decision |
| `03027B9C` | RX CSBK | one gate at entry: `3C61A == 33CCD`; only CC 15 + mode 4 + CT_CSBK bypasses (fully traced 2026-10-14, `RX_CALL_PATH_ANALYSIS.md` §3) | no | keep (see `DATA_PATH_ANALYSIS.md` §8) |
| `03028644` (mode 4 slot gate) | RX mode 4 | CSBK with CC 15 exception | no | leave |
| `03028644` (voice burst counter `3C626[slot]`) | RX: ends an active call after 7 consecutive non-sync voice bursts with foreign embedded CC | status CC vs `33CCD` | **no** | bypass (counter would otherwise end long foreign-CC calls without voice sync) |
| `03027334` | **TX admit** ("colour-code free" policy in `0301DE64`) | `33CCD` vs `3C61A`, mode-4 CC 15 rule | no | **leave unchanged** (TX behaviour) |

Writers of the configured CC: `0301E7BC(cc)` (`33CCD` and `11000384` bits 3:0; callers `030572B8` channel CC
setting, `03057790`), IRAM `0002D7C8` (TX burst loader, mode 4 only: `11000384` bits 3:0 = 15 while transmitting a CT_CSBK, otherwise `33CCD`; TX behaviour, leave unchanged; `RX_CALL_PATH_ANALYSIS.md` §4).

Hardware: `11000384` bits 3:0 hold the configured CC and bit 8 is set by Monitor and forced in RX mode 4. By the
HR-C6000 analogy (OpenGD77 register `0x1F` LocalEMB CC, `0x21` "polite to colour code") these are the C7000
local CC/EMB fields; whether bit 8 relaxes a hardware CC check is inferred, not verified. Software alone decides
acceptance at the sites above.

Design note: the stock Monitor flag (`3BA6C` bit 3) covers the first four rows but also disables the talkgroup and
private-call filter in `0302768C`. A CC-only option therefore needs its own flag tested at the RX rows above, with
`03027334` (TX) excluded. The natural menu home is next to `PCall Match`/`GCall Match` in the Other menu
(`docs/TS_ANALYSIS.md` §5).

2026-10-14: hardware `cc_opt` (`11000384` bits 9:8) and the full design are in [CC_MATCH_DESIGN.md](CC_MATCH_DESIGN.md).

2026-10-14 (fifth pass): the HR_C7000 datasheet documents a **hardware CC filter** (`LOCAL_CC.cc_opt`, `11000384`
bits 9:8). Stock firmware enables "any CC" only for Monitor and RX mode 4 (DCDM). CC Match off therefore needs
`cc_opt = 1` plus the voice-site bypasses; details and the `RF_MODE.adjustsyncmax` caveat in
[HR_C7000_CROSSCHECK.md](HR_C7000_CROSSCHECK.md) §3.1. The completeness check of the voice CC sites is in
[MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) §3.7.
