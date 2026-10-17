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

See [REPRODUCIBILITY.md](REPRODUCIBILITY.md) for `firmware/tests/run_tests.py`, recovery of the three audit JSON inputs, and `plan_integration.py --profile installed-reference`. Host tests support MSVC/GCC/Clang command lines; the pinned target module build runs on Windows/PowerShell (`build_csky.ps1`) or Linux (`build_csky.sh`, since 2026-10-17). Legacy scanner build switches select the same current sources and canonical `firmware/build/scan_candidate` output.

## Linux cloud sessions

`tools/setup_cloud.sh` installs static-analysis tooling on Ubuntu 24.04 (idempotent, no radio or firmware access):

- OpenJDK 25 (Ubuntu package).
- GNU binutils 2.42 for `csky-elfabiv2` built from the Ubuntu source package into `/opt/csky-binutils` (`as`, `ld`, `objdump`, `objcopy`, `readelf`). Mnemonics may differ slightly from the pinned T-HEAD objdump 2.27. **Do not use `-b binary`** for whole-image listings: checked 2026-10-14, it splits 32-bit instructions into `.long` halves and prints wrong `lrw` pool addresses. Wrap the bytes in an ELF (`.incbin`) as `tools/dm32` does, see [DM32RE_TOOLS.md](DM32RE_TOOLS.md).
- Ghidra 12.1.4 PUBLIC (official GitHub release, zip SHA-256 `ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db`, computed on download 2026-10-13; not compared with a vendor-published hash).
- Ghidra has no built-in C-SKY module. The script installs the legacy module from `analysis/ghidra_csky_module` (language `CSKY_V2:LE:32:default` version 0.2, supplied by the owner from the original Windows setup) and overlays `analysis/ghidra_scripts/32b_data.fixed.sinc`, then compiles SLEIGH. Only the data/language part is installed; the ELF relocation handler source is kept in the module directory but not built, which does not matter for raw payload or GZF imports.
- Optional `--with-thead`: the pinned T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2 B20210423 as its x86_64 Linux build (GCC 6.3.0, objdump 2.27), installed to `/opt/thead-csky-v3.10.29-b20210423` and exported as `DM32_CSKY_TOOLCHAIN` (not on `PATH`). Build with `firmware/build_csky.sh --scan` (Linux port of `build_csky.ps1`). Checked 2026-10-17: rebuilds the installed scanner module byte for byte (`b66ca064…`); archive source, hash and the full check are in [REPRODUCIBILITY.md](REPRODUCIBILITY.md) "Linux build".
- Optional `--with-gcc`: upstream GCC 13.3 for `csky-elfabiv2` (C only, libgcc, ~25 min build). Useful for compile/link/size checks of `firmware/source` with `-mcpu=ck803`. It is **not** the pinned T-HEAD GCC 6.3.0 and does not reproduce the installed module bytes; byte-exact builds still require the T-HEAD toolchain. Checked 2026-10-13: all 12 scanner-candidate C modules compile with the build_csky.ps1 flags and `-Werror`, and the linked module is 4491 bytes (T-HEAD build: 4458) within the 0x1800 window.

Load the environment with `source /opt/dm32-tools.env`. Headless Ghidra: `analyzeHeadless <projdir> <name> -import <payload> -processor CSKY_V2:LE:32:default -loader BinaryLoader -loader-baseAddr 0x0300C000`.

Private inputs (`analysis/inputs/*.bin`) are not in Git, so a fresh cloud session has no firmware to analyze until the owner provides them. Host tests (`firmware/tests/run_tests.py`) and the checked-in `analysis/reference` exports work without them.

### Legacy CSKY module match (2026-10-13)

`analysis/archives/DM32_NRF_049_correct_base.gzf` requires CSKY language version 0.2; every upstream `leommxj/ghidra_csky` commit declares 0.1, so the earlier cloud reconstruction could not open it. The owner supplied the legacy module (upload zip SHA-256 `0525fa540c133939ec3be666205ec2e23feeed5fd7bbce29d3581c66f08be1ad`). Its `32b_data.sinc` lacks the DM32 fixes in `32b_data.fixed.sinc` (`decne`, the `movih` zext form and, since 2026-10-14, fix 3: `zext`/`sext` extract bits msb..lsb inclusive; see `RX_CALL_PATH_ANALYSIS.md` §0.1). Headless GZF import results:

| Module variant | Bad instruction prototypes | Inventory vs checked-in |
|---|---:|---|
| Supplied module as-is | 1 (`decne` at `0300C06E`) | identical |
| Supplied module + `32b_data.fixed.sinc` (installed by the script) | 0 | identical |

The prebuilt `C-SKY.jar` from the zip was not committed or installed; its source (ELF relocation handler only) is in `analysis/ghidra_csky_module/src`.

### Static helpers (2026-10-14)

`tools/static/objdump_image.sh` wraps the flash and IRAM regions in ELF files so binutils decodes 32-bit C-SKY instructions (`-b binary` prints `.long`). `tools/static/resolve_ptr_literals.py` replaces `PTR_DAT_x` names in an `ExportDM32.java` export with the literal values; `tools/static/decomp_grep.py` greps the export with the owning function. All are read-only; run Python helpers with `-I`.

## dm32re analysis CLI (2026-10-14)

`python3 tools/dm32 …` provides annotated listings, callers/callees/call trees, RAM/MMIO access search, string
uses, look-alike functions, cached Ghidra decompilation from the GZF and uC/OS-III identification. Details,
limits and tests: [DM32RE_TOOLS.md](DM32RE_TOOLS.md). The reference corpus needs `--with-gcc`.

### Fifth-pass helpers (2026-10-14)

Read-only, run with `python3 -I` after `tools/static/objdump_image.sh` has produced `$ASM/flash.asm` and `$ASM/iram.asm`:

- `tools/static/ram_scan.py $ASM LO HI` — register-tracking scan for loads/stores and indexed accesses that land in a
  RAM range (used for the free-RAM check `3BEBD..3BECB` and the `33CCD`/`3C61A`/`3BA6D` reader lists; it reproduces the
  40 known `3BEB8..3BEBC` accesses). Heuristic: values passed through memory or across branches are not tracked.
- `tools/static/site_bytes.py STOCK INSTALLED VA:len …` — prints the stock bytes of patch-design sites and compares them
  with the installed image (used for the site tables in `MATCH_OPTIONS_DESIGN.md` §3.7–3.9).
- Datasheet text: `pdftotext -layout "docs/HR_C7000 Document 2.pdf" c7000.txt` (poppler; page numbers = "第 N 页" footers).
