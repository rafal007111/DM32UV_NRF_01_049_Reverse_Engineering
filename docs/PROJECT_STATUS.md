# Project status - 2026-10-09

Standalone project prepared for continuing work independently of the original workspace.

The last installed Scan Zone/tick image was read back in full and the owner confirmed it works.

See analysis/inputs/latest_install_result.json and latest_install_log.txt.

Reproducibility repairs are documented in REPRODUCIBILITY.md: recovered audit inputs, a host test runner, and exact installed-reference in-memory replay. The historical 568cb4e3 baseline and original installer are still missing. Further RX work should retain these limitations. Keep stock PTT/TX behavior and official CPS/codeplug compatibility.

The address catalog has 2,171 entries. Only a subset has been manually named and explained; do not treat the catalog as complete semantic documentation. See docs/DECOMPILED_MODULES.md.

### Legacy recovery follow-up (2026-10-13)

The actual 2171-function Ghidra database is now available as `analysis/archives/DM32_NRF_049_correct_base.gzf`; stock and installed program images are versioned with owner authorization. The exact 568cb4e3 intermediate was found in the legacy Documents/Codex workspace, and both historical byte deltas are verified. This supersedes earlier missing-baseline statements; full historical build/installer provenance remains unreviewed. See [LEGACY_RECOVERY.md](LEGACY_RECOVERY.md).
