# CC Match off — pointer page (consolidated 2026-10-15)

**This file is no longer a design document.** The single authoritative TS/CC Match design is
[MATCH_OPTIONS_DESIGN.md](MATCH_OPTIONS_DESIGN.md) (site table at its top, §3.7 and §3.9 for CC Match off), and the
host-tested candidate module and in-memory patch plan are in [MATCH_OPTIONS_CANDIDATE.md](MATCH_OPTIONS_CANDIDATE.md).
The full text of this page as written on 2026-10-14 is preserved in git (`git show c32a44e:docs/CC_MATCH_DESIGN.md`);
nothing below was deleted without a pointer.

| Former section (2026-10-14) | Status | Where it lives now |
|---|---|---|
| §1 Two layers (hardware `cc_opt` in `LOCAL_CC` `11000384` bits 9:8, software CC sites) | still valid (datasheet + code) | `HR_C7000_CROSSCHECK.md` §3.1, `MATCH_OPTIONS_DESIGN.md` §3.7 |
| §2 Why not reuse Monitor (Monitor also bypasses PCall/GCall Match via `3BA6C` bit 3, cleared on channel change) | still valid (code-verified) | `MONITOR_ANALYSIS.md`, `MATCH_OPTIONS_DESIGN.md` §1 |
| §2 change table (keep bit 8 at `0301E73C` and in `0301EC40`, four voice sites, unchanged CSBK/data/PI/TX admit) | **superseded** by the guarded site list C1–C7 (adds the `3C626` counter C5, the data-type restriction of C1 and the TX-neutral wrapper T5/T6) | `MATCH_OPTIONS_DESIGN.md` §0 and §3.9 |
| §3 Storage: block 4 `0x60` bit 2 = CC off, bit 3 = TS off | still valid (default used by the candidate) | `MATCH_OPTIONS_DESIGN.md` §2 |
| §3 RAM flag in the mod block `4BFC0` (`dm32_runtime.rx`) | **superseded** — the 2026-10-15 default is `3BA6D` bit 5 (CC off) / bit 6 (TS off), behind one header (`firmware/source/match_flags.h`) so it can be switched; recorded as an open owner decision | `MATCH_OPTIONS_DESIGN.md` §2, `SETTINGS_CPS_ANALYSIS.md` §9.3 |
| §4 Open decisions (PI header strict, data rejected, CPU load with `cc_opt = 1`) | defaults applied: PI strict, data/CSBK rejected; CPU load reviewed statically | `MATCH_OPTIONS_CANDIDATE.md` §2 and §7 |
| §5 CSBK decode flags ignored on Rx Only channels (safety finding) | still valid (code-verified, not hardware-verified) | moved to `DATA_PATH_ANALYSIS.md` §8a |
| §6 Follow-up (fifth pass) | merged | `MATCH_OPTIONS_DESIGN.md` §3.7–§3.9 |

Open questions for the owner, RX-only hardware tests and unreviewed items are listed only in
`MATCH_OPTIONS_DESIGN.md` §6–§8 and `MATCH_OPTIONS_CANDIDATE.md` §9–§11 to avoid diverging copies.
