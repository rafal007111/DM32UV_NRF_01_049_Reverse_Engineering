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
