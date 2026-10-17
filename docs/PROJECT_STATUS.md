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

### Pinned toolchain on Linux (2026-10-17)

The pinned T-HEAD V3.10.29 B20210423 compiler also exists as a native x86_64 Linux build; `tools/setup_cloud.sh --with-thead`
and `firmware/build_csky.sh` reproduce the installed scanner module byte for byte (`b66ca064…`) and the installed image
in memory (`156a4872…`). Byte-exact target builds no longer require the owner's Windows machine.

### Library signatures (2026-10-17)

`tools/dm32 libsig` names 27 C-runtime catalog rows from the pinned T-HEAD libraries (exact or near byte matches);
1892 rows remain unreviewed. The vendor used a different toolchain release than V3.10.29 (code-verified
fingerprint). See [LIBRARY_SIGNATURES.md](LIBRARY_SIGNATURES.md).

### Kernel review (2026-10-17)

The four shared uC/OS-III claims are resolved and 50 kernel/uC/CPU/uC/LIB catalog rows are named (10 high, 38 medium,
2 low); 1843 rows remain unreviewed. See [LIBRARY_SIGNATURES.md](LIBRARY_SIGNATURES.md) §5.

### Library naming finished (2026-10-17)

Kernel pass 2, uC/LIB, the libm/soft-float block and `libsig --norm`: 177 catalog rows reviewed (kernel/port 109,
uC/LIB 15, libm 10, C runtime 43; 174 were unreviewed, 3 raised from low) and 4 C-runtime rows raised to high;
1669 rows remain unreviewed.
Kernel configuration and the full task list are in [LIBRARY_SIGNATURES.md](LIBRARY_SIGNATURES.md) §6. No image
written, no hardware test needed.

### Subsystem tags (2026-10-17)

`tools/dm32 tag` gives 898 of the 1669 unreviewed catalog rows an `auto:` subsystem lead (90.5 % agreement in a
74-function spot check); the rest are shared across task families (248), have no evidence (114) or stay below the
threshold. See [SUBSYSTEM_TAGS.md](SUBSYSTEM_TAGS.md). No image written, no hardware test needed.

### Targeted review T1: transmit paths (2026-10-17)

Static only. [TX_PATHS.md](TX_PATHS.md) lists every TX sink (FM_PTT, RF TX link, PA/power, TX queue, chip RF
interrupts) and every root with its gates; two autonomous analog paths (decode acknowledgement, stun/kill by code) and
the alarm-CSBK admit bypass were added to [AUTONOMOUS_TX.md](AUTONOMOUS_TX.md). 65 catalog rows reviewed. No image
written, no radio accessed.
