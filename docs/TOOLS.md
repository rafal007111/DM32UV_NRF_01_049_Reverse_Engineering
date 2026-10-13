# Tools

Required for reproducing current work:
- Windows 10/11 and PowerShell.
- T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2, build B20210423: csky-elfabiv2-gcc, ld, objcopy, objdump.
- Ghidra 12.1.4 PUBLIC and JDK 25 for analysis scripts.
- Python 3.11+ for audit/catalog utilities; Visual Studio C++ Build Tools for the Windows C test harnesses.

Original workspace tool copies lived under work/tools and were not copied here. Install trusted copies separately. The C-SKY compiler path in build_csky.ps1 is machine-specific; set the DM32_CSKY_TOOLCHAIN environment variable before running the launcher, or pass ToolchainRoot when calling the PowerShell build script directly. Example: $env:DM32_CSKY_TOOLCHAIN = C:\Tools\csky-elfabiv2-tools-mingw-minilibc-20210423

Run firmware/start_build_scan_tick_fix.cmd to compile and link the standalone candidate module. It does not create full firmware or access COM ports. Ghidra scripts in analysis/ghidra_scripts assume the C-SKY payload is imported in a read-only project. Use the official wrapper's 256-byte header and verify payload hash before analysis. Do not export firmware from a read-only call review.

Useful utilities: rg, Python, C-SKY objdump, a hex viewer, SHA256 tools and Ghidra's decompiler/disassembler. Keep local build and Ghidra databases out of Git.

## Reproducibility commands

See [REPRODUCIBILITY.md](REPRODUCIBILITY.md) for `firmware/tests/run_tests.py`, recovery of the three audit JSON inputs, and `plan_integration.py --profile installed-reference`. Host tests support MSVC/GCC/Clang command lines; the pinned target module build remains Windows/PowerShell. Legacy scanner build switches select the same current sources and canonical `firmware/build/scan_candidate` output.

## Linux cloud sessions

`tools/setup_cloud.sh` installs static-analysis tooling on Ubuntu 24.04 (idempotent, no radio or firmware access):

- OpenJDK 25 (Ubuntu package).
- GNU binutils 2.42 for `csky-elfabiv2` built from the Ubuntu source package into `/opt/csky-binutils` (`as`, `ld`, `objdump`, `objcopy`, `readelf`). Decodes CK803 code, e.g. `csky-elfabiv2-objdump -D -b binary -m csky:ck803 -EL`. Mnemonics may differ slightly from the pinned T-HEAD objdump 2.27.
- Ghidra 12.1.4 PUBLIC (official GitHub release, zip SHA-256 `ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db`, computed on download 2026-10-13; not compared with a vendor-published hash).
- Ghidra has no built-in C-SKY module. The script installs `leommxj/ghidra_csky` at commit `589294d` with `analysis/ghidra_scripts/32b_data.fixed.sinc` replacing `32b_data.sinc`, then compiles SLEIGH. Language ID: `CSKY_V2:LE:32:default`. The base commit was inferred: its `32b_data.sinc` is the closest upstream version to the fixed file. Other local changes from the original workspace, if any, are unknown. Only the data/language part is installed; the module's ELF relocation handler (Java) is not built, which does not matter for raw payload imports.
- Optional `--with-gcc`: upstream GCC 13.3 for `csky-elfabiv2` (C only, libgcc, ~25 min build). Useful for compile/link/size checks of `firmware/source` with `-mcpu=ck803`. It is **not** the pinned T-HEAD GCC 6.3.0 and does not reproduce the installed module bytes; byte-exact builds still require the T-HEAD toolchain. Checked 2026-10-13: all 12 scanner-candidate C modules compile with the build_csky.ps1 flags and `-Werror`, and the linked module is 4491 bytes (T-HEAD build: 4458) within the 0x1800 window.

Load the environment with `source /opt/dm32-tools.env`. Headless Ghidra: `analyzeHeadless <projdir> <name> -import <payload> -processor CSKY_V2:LE:32:default -loader BinaryLoader -loader-baseAddr 0x0300C000`.

Private inputs (`analysis/inputs/*.bin`) are not in Git, so a fresh cloud session has no firmware to analyze until the owner provides them. Host tests (`firmware/tests/run_tests.py`) and the checked-in `analysis/reference` exports work without them.
