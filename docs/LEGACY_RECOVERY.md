# Legacy environment recovery — 2026-10-13

This follow-up supersedes earlier statements that the intermediate image and
old Ghidra database could not be found. The earlier search covered Desktop/AI;
the surviving environment was found under Documents/Codex/2026-10-06.

## Shared inputs

The owner authorized adding both `analysis/inputs/stock_progmem_1MiB.bin`
and `analysis/inputs/current_scan_tick_fix.progmem.bin` to the private repository.
Their size is 1048576 bytes each and their complete SHA-256 values match
`analysis/inputs/manifest.json`: stock `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0`,
installed `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53`.
The official updater container is already versioned. Its payload can be derived
locally by removing the first 256 bytes; verify the resulting SHA-256
`3711be95c10975c8f33073ad7a0b3c4d815e301bbcd389a4bd7ff7a0114acc63`.

## Ghidra database

`analysis/archives/DM32_NRF_049_correct_base.gzf` is the actual legacy program
export, not a reconstructed import. Ghidra 12.1.4 PUBLIC exported it from a
read-only copy with no analysis pass. Reimport into a fresh project reproduced
the inventory exactly. It contains 2171 functions, one user-defined function
name, seven data types including built-ins and zero listing-comment records.
Archive SHA-256 and exact mapping/verification scope are in
`analysis/archives/manifest.json` and `analysis/archives/README.md`.
No claim is made that all prior unsaved annotations survived.

## Integration artifacts

The legacy `outputs/DM32UV_NRF_poprawiona_baza/integration_review` directory
contains 15 files. Eight have byte-identical copies already under
`analysis/reference/key_routing` or `analysis/reference/menu_flow`; seven
previously missing files were copied to `analysis/reference/integration_review`.
`recovery_manifest.json` maps every source-relative file to its repository
counterpart with byte count and SHA-256. The original three menu/picker/scanner
audit JSONs are preserved under `analysis/reference/legacy_audits`; they do not
replace the independently reconstructed audits used by current build tools.
Their historical semantic claims have not all been re-reviewed.

## Identified intermediate image

The exact baseline is the legacy
`test_scan_source_fix/DM32_NRF_049_SCAN_SOURCE_FIX.progmem.bin`, SHA-256
`568cb4e37a14104702c3c0deaa92f57086159fcddcfa3d5f53646db4aeecd819`.
The raw intermediate stays local; the recovered manifest records guarded bytes
for both transitions and verifies complete replay in memory:

| Transition | Changed bytes | Distinct 4 KiB chunks |
|---|---:|---:|
| Stock → SCAN_SOURCE_FIX baseline | 4533 | 31 |
| SCAN_SOURCE_FIX baseline → installed SCAN_TICK_FIX | 2190 | 28 |
| Stock → installed (direct comparison) | 4266 | 24 |

The second transition matches the recorded installer counts. This resolves the
missing **byte-level chain**, but does not independently verify the original
installer's execution or every historical build step. Legacy image-preparation
scripts were also located; none were executed. No firmware image was installed
or hardware accessed. Current reproducible endpoint replay remains documented
in `REPRODUCIBILITY.md`; the recovered historical chain is in
`firmware/image_provenance_audit.json`.
