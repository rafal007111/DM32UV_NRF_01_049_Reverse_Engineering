# Offline reproduction and evidence recovery

Checked 2026-10-13 for Baofeng DM32UV, **DM32.NRF.01.049 only**.
GitHub API reported `visibility: private` for
`rafal007111/DM32UV_NRF_01_049_Reverse_Engineering` on that date.

## Host tests

From any directory, invoke `firmware/tests/run_tests.py` by its path. From the repository root:

```sh
python firmware/tests/run_tests.py
```

Requires Python 3.11+ and a host C compiler. GCC/Clang use C11; MSVC requires
a Visual Studio Developer Command Prompt and `/std:c11` support.
Use `--cc cl`, `--cc clang`, or `--cc /path/to/gcc` to choose one explicitly.
The runner records each source list and define in its output, keeps assertions
enabled, and compiles the firmware bridges with their explicit host mock flags.
No target assembly is linked. Executables/objects stay under ignored
`firmware/build/host_tests`. `--test NAME` can be repeated for selected tests.

Ten tests use embedded fixtures. The eleventh, `mod_core_real`, is skipped unless
`DM32_TEST_CODEPLUG` points to the private **DMR1 capture matching
`codeplug_zone_fixture.h`**. It is not a test for arbitrary codeplugs.

```powershell
$env:DM32_TEST_CODEPLUG = 'C:\private\DMR1.data'
python firmware/tests/run_tests.py --cc cl --test mod_core_real
```

The test uses portable `fopen`, rejects incomplete 4096-byte pages, and returns
77 when the variable is unset. A configured but unreadable file is a failure.
Keep captures outside Git. On 2026-10-13 all 11 tests passed with MSVC, including
the local 22-zone DMR1 fixture (MSVC 19.44.35229 x64, Python 3.13); GCC/Clang command support has not been executed
on Linux in this session. These are host-model tests, not RF/hardware validation.

## Rebuild and audit the standalone module

The C-SKY build still requires Windows/PowerShell and the pinned T-HEAD toolchain
in `docs/TOOLS.md`. It is not a portable target toolchain installation.

```powershell
./firmware/build_csky.ps1 -ToolchainRoot 'C:\Tools\csky-elfabiv2-tools-mingw-minilibc-20210423' -IncludeScanCandidate
python firmware/audit_staging.py firmware/build/scan_candidate
python firmware/plan_integration.py firmware/build/scan_candidate --profile installed-reference
```

The official updater `analysis/inputs/DM32_NRF_049_20251017.bin` is versioned
in this private repository at the owner's request. The stock and installed program images are also versioned with owner authorization.
Generate only the ignored payload locally by removing the updater's 256-byte header
and verifying its manifest SHA-256.
The audit uses the repo-relative payload path
and checks its exact hash. The three recovered `firmware/*_audit.json` files for
menu tables and routing are versionable evidence and require no external work
directory. Run audits without Python `-O`; the existing assertion-based guards
now explicitly reject optimized mode.

The current scanner module is **4458 bytes**, placed at `0x030DFCEC`, SHA-256
`b66ca0640d5aa8878ce0fc85aa3fceaac0133f86fa92a8b6fa4747d90fd4a7a1`.
Using T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2 B20210423, GCC 6.3.0 and
objdump 2.27, the rebuilt bytes exactly match the installed image's module.
The ELF audit also checks section placement/size, object flags, undefined
symbols, stock-frame shim bytes, and 62 original menu pointers.

Legacy ScanZoneTest/Polish/SourceFix/TickFix switches now explicitly warn that
they select the **current** scanner sources and use the same `scan_candidate`
directory. They cannot reproduce historical source versions. PickerEntryFix
likewise aliases the current integration build. Compiler temporary files use a
local ignored build directory and the prior TEMP/TMP values are restored.

## Exact endpoint replay versus historical installation

`--profile installed-reference` produces
`firmware/build/scan_candidate/installed_reference_patch_plan.json`.
It applies 58 byte-guarded changes to the pinned stock **in memory only**, checks
the unchanged `0xC000` boot prefix and compares all 1 MiB against the pinned
installed input. The reproduced SHA-256 is
`156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53`.
No image file is produced, and the report remains `flashable: false`.

The default `candidate` profile retains the older proposal (60 changes). It
additionally replaces the Other menu descriptor at `0x030B9700` and redirects
the menu-filter call at `0x0303E24C`. Those sites remain stock in the installed
image. Together they account for the 11 byte difference between the default
proposal's in-memory result and the installed reference. Thus a successful
candidate module build alone must not be described as that installed image.

The historical sequence remains incomplete:

| Stage | SHA-256 | Evidence |
|---|---|---|
| Stock | `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0` | Local exact image; code-verified hash |
| Installer baseline | `568cb4e37a14104702c3c0deaa92f57086159fcddcfa3d5f53646db4aeecd819` | Install record only; image and creation recipe unavailable |
| Installed/readback | `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53` | Local exact image and recorded full readback; owner reported working Scan Zone/tick |

`firmware/image_provenance_audit.json` retains both missing historical edges
explicitly. Its separate direct stock-to-installed delta guards every changed
byte (4266 bytes across 24 distinct 4 KiB chunks), records before/after bytes,
and verifies full in-memory replay. This is **code-verified endpoint evidence**,
not proof of how the missing baseline was created. The install record's 2190
bytes/28 sectors use a different baseline and must not be substituted for this
delta. The original installer tool is still unavailable.

## Regenerate recovered evidence

```powershell
python firmware/recover_audit_evidence.py --objdump 'C:\Tools\csky-elfabiv2-tools-mingw-minilibc-20210423\bin\csky-elfabiv2-objdump.exe'
```

This hashes the inputs, verifies the rebuilt module against the installed
bytes, uses T-HEAD 2.27 stock BSR instruction boundaries and target encodings,
and maps installed destinations to the rebuilt ELF function symbols. It
recovers 16 picker hooks, 34 scanner hooks, and five other calls (boot, two
menu-filter and two tick calls), plus the stock menu tables. Each recovered
hook has its VA, image/container offsets, original and installed target,
before/after bytes and replacement symbol. The JSON records hashes and decoder
version/hash. These are recovered lists, not the lost original audit files.

Use `--output DIRECTORY` to compare regeneration without replacing the checked-in
evidence. If the exact missing image is recovered, `--baseline PATH` validates
its hash and generates both historical byte deltas. Even then, its original
source/build recipe requires separate evidence.

No radio access was used. Existing owner verification is preserved as historical
evidence; byte identity and host tests do not independently establish CPS,
PTT/TX or RF behavior. TS/CC model functions remain separate from actual RX
integration, and the final frame/audio disposition remains unresolved.

### Legacy recovery follow-up (2026-10-13)

The actual 2171-function Ghidra database is now available as `analysis/archives/DM32_NRF_049_correct_base.gzf`; stock and installed program images are versioned with owner authorization. The exact 568cb4e3 intermediate was found in the legacy Documents/Codex workspace, and both historical byte deltas are verified. This supersedes earlier missing-baseline statements; full historical build/installer provenance remains unreviewed. See [LEGACY_RECOVERY.md](LEGACY_RECOVERY.md).
