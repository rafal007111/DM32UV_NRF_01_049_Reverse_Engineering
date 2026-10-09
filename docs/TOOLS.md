# Tools

Required for reproducing current work:
- Windows 10/11 and PowerShell.
- T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2, build B20210423: csky-elfabiv2-gcc, ld, objcopy, objdump.
- Ghidra 12.1.4 PUBLIC and JDK 25 for analysis scripts.
- Python 3.11+ for audit/catalog utilities; Visual Studio C++ Build Tools for the Windows C test harnesses.

Original workspace tool copies lived under work/tools and were not copied here. Install trusted copies separately. The C-SKY compiler path in build_csky.ps1 is machine-specific; set the DM32_CSKY_TOOLCHAIN environment variable before running the launcher, or pass ToolchainRoot when calling the PowerShell build script directly. Example: $env:DM32_CSKY_TOOLCHAIN = C:\Tools\csky-elfabiv2-tools-mingw-minilibc-20210423

Run firmware/start_build_scan_tick_fix.cmd to compile and link the standalone candidate module. It does not create full firmware or access COM ports. Ghidra scripts in analysis/ghidra_scripts assume the C-SKY payload is imported in a read-only project. Use the official wrapper's 256-byte header and verify payload hash before analysis. Do not export firmware from a read-only call review.

Useful utilities: rg, Python, C-SKY objdump, a hex viewer, SHA256 tools and Ghidra's decompiler/disassembler. Keep local build and Ghidra databases out of Git.
