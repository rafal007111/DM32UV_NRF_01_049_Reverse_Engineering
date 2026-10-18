# Matching-decompilation pilot — DM32.NRF.01.049 (2026-10-18)

Static only. Inputs: stock `stock_progmem_1MiB.bin` (`de7dbcbc…`, verified on load), the catalog
`analysis/decompiled_modules/function_catalog.csv`, Python 3.13, the toolchains in §1. No radio access, no serial
port, no image file written. Question: can vendor functions be rewritten in C and compiled byte-identical
("matching decompilation"), and with which compiler?

## 1. M1 — candidate compilers

### 1.1 Candidates tried

All downloads went to their own directories under `/opt/untrusted` / `/opt/cand` (outside the repository, not
committed); only the compiler/binutils binaries were run. The cloud proxy allows GitHub git reads and GitHub release
downloads; vendor sites return 403.

| # | Candidate | Source | Archive SHA-256 / commit | Version strings | libc flavour | libsig vs vendor libc/fp block | Vendor fingerprint |
|---|---|---|---|---|---|---|---|
| 1 | T-HEAD C-SKY Tools V3.10.29 B20210423 (pinned) | `github.com/cjacker/wm_sdk_w80x` release `init` (`tools/setup_cloud.sh --with-thead`) | `8b9a353c157e4d44001a21974254a21cc0f3c7ea2bf3c894f18a905509a7048f` | `csky-elfabiv2-gcc (T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2 B20210423) 6.3.0`, GNU as/objdump 2.27 | minilibc | exact 11, exact-short 5, norm 4, near 1, short 5, lead 38 (64 rows; `libsig_thead_matches.csv`) | **no**: 0 three-operand `addu/subu rz,rz,ry`; `unsigned char` parameters not re-extended |
| 2 | Xuantie-800 Tools V3.10.33 B20250328 | `github.com/Taixin-Semiconductor/XuanTie-CSKY-Toolchains` release `untagged-714ed6e395fc96712ea8`, `csky-elfabiv2-tools-x86_64-minilibc-20250328.tar.gz` (80 699 744 bytes) | `ad5c8564ada7fbf77acb952448b03a394d7aafb56c945b2f8698d598076a69f9` (matches the repository's `SHA256SUMS`) | `csky-elfabiv2-gcc (Xuantie-800 Tools V3.10.33 Minilibc abiv2 B20250328) 6.3.0`, GNU as/objdump 2.27 | minilibc | **identical to #1** (same 64 rows and strengths; only two lead names differ, `vsprintf`/`vfprintf` and a `__dtostr` ratio). Of 2135 common reference functions only 64 differ in bytes (printf variants, unwinder, `asctime`, `localeconv`, `__guard_setup`) | **no**; `.text` of every probe at `-Os/-O1/-O2` is byte-identical to #1 |
| 3 | Upstream GNU binutils 2.42 (Ubuntu source, `/opt/csky-binutils`) | `tools/setup_cloud.sh` | Ubuntu 24.04 `binutils` source package | GNU as 2.42 | — | — (no C library) | **no**: assembles `addu r0, r0, r1` and `addu16 r0, r0, r1` as the two-operand `6004` |
| 4 | C-SKY binutils `csky-binutils-3_2_0-release` | `github.com/c-sky/binutils-gdb` tag (git clone) | commit `ca4bb439dc85ca0a697128d5459e5d17c67f4e2d` (2017-11-13) | source only, not built | — | — | **no** (source review): `v2_work_add_sub` in `gas/config/tc-csky.c` already rewrites `addu/subu rz, rz, ry` (and `addu rz, rx, rz`) to the 16-bit two-operand form whenever all registers are ≤ r15 |
| 5 | Upstream GCC 13.3 (`--with-gcc`) | `tools/setup_cloud.sh` | Ubuntu `gcc-13` source | — | none (libgcc only) | not run | not built: it uses the upstream assembler (#3), which already fails the fingerprint |
| 6 | C-SKY Tools V2.10.00 Minilibc ABIV2 B20161206 (GCC 4.5.1), `csky-abiv2-elf-tools-x86_64-minilibc-20161211` | named in the RT-Thread `bsp/ck802` README (CDK 1.6.0 era) | — | — | minilibc | — | **not reachable**: no GitHub copy found (web search, GitHub and GitLab project search) |
| 7 | T-HEAD/XRVM, Aliyun OSS (`occ-oss-prod…`), `occ.t-head.cn`, `www.xrvm.cn`, `gitee.com`, AUR (`csky-elfabiv2-tools-bin` → occ), NationalChip SDK docs | vendor sites | — | — | — | — | **blocked** (proxy 403 / DNS) |
| 8 | Windows MinGW and macOS packages of #2 (`…mingw-minilibc-20250328`, `…macos-arm64-…`) | same release as #2 | in the Taixin `SHA256SUMS` | same V3.10.33 / V3.10 source | minilibc | — | not tried: same release as #2, a Linux build exists, so Wine was not needed |

Other places looked at: `c-sky/toolchain-build` (branches `gcc-6_3-Release_V3_10`, `gcc-6_3-build`, `gcc-15-dev`, tag
`csky-script-3_2_0-release`), `c-sky/gcc` (only GCC 6 branches and tag `csky-gcc-3_2_0-release`, no GCC 4.x C-SKY
branch), `xeecos/csky-toolchain-macos` (build script only), C-SKY buildroot forks on GitLab (Linux toolchains).

### 1.2 Fingerprint probes

Probe file (scratch, not committed): `a = a + b` / `a = a - b` chains, an `unsigned char` classifier, a dense switch,
a summing loop and a byte store loop, plus the four GPIO/LCD leaves of §3, compiled with `-mcpu=ck803` at
`-Os`, `-O1`, `-O2`. Results for #1 and #2 (identical): no `0x58xx…0x5Fxx` `addu/subu` with `rz == rx`; a
leading `zextb` appears only where the value is not already an `unsigned char` parameter. Direct assembler test
(#1, #2, #3, `-mcpu=ck801/802/803/803s/803e`): every reachable GNU assembler encodes `addu rz, rz, ry` and the
explicit `addu16 rz, rz, ry` as the two-operand form.

### 1.3 Verdict on the vendor compiler

- **No reachable toolchain is the vendor's** (code-verified for #1–#4 as stated). V3.10.29 and V3.10.33 have the
  same code generation and the same libraries, so the vendor's release is neither.
- **The fingerprint is an assembler property** (code-verified from the binutils source and the assembler tests):
  the vendor's assembler does not fold `addu/subu rz, rz, ry` to the two-operand form, so it predates C-SKY binutils
  V3.2.0 (2017-11) or is not GNU as. The stock application also uses the three-operand form with `rz == ry` for
  `addu`, which every reachable assembler folds too.
- **Most likely vendor toolchain** (inferred): a C-SKY Tools V2.x release (GCC 4.5.1, CDK 1.x/CDS era, e.g.
  V2.10.00 B20161206). This agrees with the 2017 HR_C7000 datasheet revision, the hand-written minilibc string
  functions that are byte-identical except `memset`/`isspace` (older `.S` sources without the leading `zextb`), and
  the different instruction selection of the vendor's compiled libc (`LIBRARY_SIGNATURES.md` §9). It could not be
  downloaded from this environment.
- Consequence for M2/M3: byte-exact PASS is only possible for functions without a 16-bit `addu/subu` whose
  register allocation and block order happen to agree with GCC 6.3. The oracle therefore reports the assembler
  re-encoding separately (`PASS-ENC`), which is a property of the assembler and not of the C source.
