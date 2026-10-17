# DM32UV DM32.NRF.01.049 Reverse Engineering

Private research and modification project for the Baofeng DM32UV NRF 01.049 firmware. The current Scan Zone feature and source-marker fix are installed and confirmed working by the radio owner.

## Contents
- firmware/source: C-SKY source for Scan Zone and integration hooks.
- firmware/tests: local tests for parsers, runtime, picker and scan bridges.
- analysis/reference: current Ghidra function table, C-like decompilation, assembly, strings and call inventory.
- analysis/ghidra_scripts: scripts used to recover menu flow and review candidate calls.
- analysis/decompiled_modules: exhaustive address catalog and concise subsystem index.
- analysis/inputs: private local copies of official update, stock program backup and verified current image.
- docs: tool setup, decompilation inventory and reverse-engineering notes.

Read AGENTS.md first. Then read docs/DECOMPILED_MODULES.md and docs/RE_NOTES.md.

Current verified image SHA-256: 156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53. The complete install result is in analysis/inputs/latest_install_result.json. Scan Zone and marker correction work on the owner's radio.

Function catalog: 2,171 entries, including 213 with decompiler warnings. Many entries remain unreviewed. Decompiler output is evidence, not recovered source code.

Build candidate module with firmware/start_build_scan_tick_fix.cmd. This produces a standalone module, not complete firmware, and does not access the radio. See docs/TOOLS.md for required tools.

This is a private analysis repository containing vendor-derived material. Do not publish firmware binaries or full decompilation. Radio-specific backups must also be kept outside Git. Preserve official CPS/codeplug compatibility and stock PTT/TX behavior. TS Match and CC Match RX settings remain planned work.

### Offline reproducibility repair (2026-10-13)

See [docs/REPRODUCIBILITY.md](docs/REPRODUCIBILITY.md) for the host test runner, recovered menu/hook audits, and the installed-reference patch plan. The rebuilt 4458-byte module matches the installed image exactly; 58 guarded patches replay stock to the full installed SHA-256 in memory without producing an image file. The historical intermediate baseline and original installer remain unavailable. All 11 host tests passed with MSVC; no new hardware validation was performed.

### Legacy recovery follow-up (2026-10-13)

The actual 2171-function Ghidra database is now available as `analysis/archives/DM32_NRF_049_correct_base.gzf`; stock and installed program images are versioned with owner authorization. The exact 568cb4e3 intermediate was found in the legacy Documents/Codex workspace, and both historical byte deltas are verified. This supersedes earlier missing-baseline statements; full historical build/installer provenance remains unreviewed. See [LEGACY_RECOVERY.md](docs/LEGACY_RECOVERY.md).

## Documentation map (2026-10-15)

Reading order for new work: AGENTS.md, this file, [RE_NOTES.md](docs/RE_NOTES.md) (dated entries; later entries win), [DECOMPILED_MODULES.md](docs/DECOMPILED_MODULES.md).

| Topic | Document |
|---|---|
| Status and provenance | [PROJECT_STATUS.md](docs/PROJECT_STATUS.md), [REPRODUCIBILITY.md](docs/REPRODUCIBILITY.md), [LEGACY_RECOVERY.md](docs/LEGACY_RECOVERY.md) |
| Tools | [TOOLS.md](docs/TOOLS.md), [DM32RE_TOOLS.md](docs/DM32RE_TOOLS.md) (`tools/dm32`), [EXTERNAL_RESOURCES.md](docs/EXTERNAL_RESOURCES.md) |
| Baseband chip | [HR_C7000_CROSSCHECK.md](docs/HR_C7000_CROSSCHECK.md), datasheet `docs/HR_C7000 Document 2.pdf` |
| Receive path | [RX_CALL_PATH_ANALYSIS.md](docs/RX_CALL_PATH_ANALYSIS.md), [DATA_PATH_ANALYSIS.md](docs/DATA_PATH_ANALYSIS.md), [MONITOR_ANALYSIS.md](docs/MONITOR_ANALYSIS.md) |
| Time slot / Colour Code | [TS_ANALYSIS.md](docs/TS_ANALYSIS.md), [CC_MATCH_ANALYSIS.md](docs/CC_MATCH_ANALYSIS.md) |
| TS/CC Match design (design only, no image) | [MATCH_OPTIONS_DESIGN.md](docs/MATCH_OPTIONS_DESIGN.md) (site inventory, latest), [CC_MATCH_DESIGN.md](docs/CC_MATCH_DESIGN.md) |
| Alert tones | [AUDIO_TONES.md](docs/AUDIO_TONES.md) |
| GNSS / NMEA | [GNSS_ANALYSIS.md](docs/GNSS_ANALYSIS.md) |
| Settings, CPS, codeplug | [SETTINGS_CPS_ANALYSIS.md](docs/SETTINGS_CPS_ANALYSIS.md), [CHANNEL_RECORD.md](docs/CHANNEL_RECORD.md), user manual `docs/Baofeng_DM-32UV_User_Manual_20250210.pdf` |
| Next unattended agent | [NEXT_AGENT_PROMPT.md](docs/NEXT_AGENT_PROMPT.md) |
