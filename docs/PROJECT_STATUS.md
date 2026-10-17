# Project status - 2026-10-09

Standalone project prepared for continuing work independently of the original workspace.

The last installed Scan Zone/tick image was read back in full and the owner confirmed it works.

See analysis/inputs/latest_install_result.json and latest_install_log.txt.

Reproducibility repairs are documented in REPRODUCIBILITY.md: recovered audit inputs, a host test runner, and exact installed-reference in-memory replay. The historical 568cb4e3 baseline and original installer are still missing. Further RX work should retain these limitations. Keep stock PTT/TX behavior and official CPS/codeplug compatibility.

The address catalog has 2,171 entries. Only a subset has been manually named and explained; do not treat the catalog as complete semantic documentation. See docs/DECOMPILED_MODULES.md.

### Legacy recovery follow-up (2026-10-13)

The actual 2171-function Ghidra database is now available as `analysis/archives/DM32_NRF_049_correct_base.gzf`; stock and installed program images are versioned with owner authorization. The exact 568cb4e3 intermediate was found in the legacy Documents/Codex workspace, and both historical byte deltas are verified. This supersedes earlier missing-baseline statements; full historical build/installer provenance remains unreviewed. See [LEGACY_RECOVERY.md](LEGACY_RECOVERY.md).

### Branch consolidation (2026-10-15)

All agent branches were consolidated into `master` (fast-forward to the most complete branch, which already contained every other branch; no commit was lost or rewritten). Since 2026-10-14 the static work added the HR_C7000 register cross-check (hardware CC filter `cc_opt` exists; no hardware slot filter is used), the received call path, settings/CPS map, channel record layout, `tools/dm32` helpers and a design-only TS/CC Match site inventory. Nothing new was built into an image, installed or hardware-tested; TS/CC Match remain unimplemented. Host tests: firmware 10 passed / 1 skipped, tools 15 run / 9 skipped (no objdump/Ghidra in the check environment).

### Sixth pass (2026-10-17)

Static documentation only: HR_C7000 register leads closed (`HR_C7000_CROSSCHECK.md` §8), data-flash area map and
channel reload reasons (`RX_CALL_PATH_ANALYSIS.md` §16), the `0x50` overwrite risk removed (`SETTINGS_CPS_ANALYSIS.md`
§10), design-document consolidation. The TS/CC Match candidate module, target build and patch plan are still open.
Nothing built into an image, installed or hardware-tested.
