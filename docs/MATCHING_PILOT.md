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

## 2. M2 — the oracle `tools/dm32 match`

```sh
bash tools/setup_cloud.sh --with-thead && source /opt/dm32-tools.env
python3 tools/dm32 match 0300C3AC analysis/matching/0300C3AC_rf_carrier_get.c                  # PASS, exit 0
python3 tools/dm32 match 03039420 analysis/matching/03039420_list_down.c \
    --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping"                             # PASS
python3 tools/dm32 match 0002C1D0 analysis/matching/0002C1D0_lcd_cmd.c --diff-only               # FAIL, 1 item
python3 analysis/matching/pilot.py --csv analysis/matching/pilot_results.csv                     # whole pilot, ~1 min
```

`tools/dm32re/match.py` (stdlib plus the candidate's gcc/as/objdump; read-only, objects in ignored
`build/dm32re/match`):

1. compiles the C file with `--toolchain` (default `$DM32_CSKY_TOOLCHAIN`, the pinned V3.10.29; tool prefix
   `csky-elfabiv2-` or the older `csky-abiv2-elf-`) and `--cflags` (default `-mcpu=ck803 -Os`);
2. reads the function with its literal pool from the object through `libsig._functions` (the same relocation
   masking as `libsig`): `--func NAME`, else the function whose name ends in the address, else the only one;
3. decodes both sides into instructions and pool words and compares them item by item (difflib alignment for the
   report): fixed bits must be identical; PC-relative fields (br/bt/bf, bez…bhsz, bsr, lrw, jmpi, jsri) are compared
   by the **item they point at**, so a pool that is 2 bytes further because of the absolute 4-byte alignment is not a
   difference; relocations are resolved against the firmware — a symbol name ending in an 8-digit address
   (`FUN_0002c38c`, `DAT_00033cc8`) or `--sym NAME=ADDR` (also `// @sym` lines in the C file) names that address,
   a string-literal pool word matches when the firmware word points at the same string; a `bsr` to the right
   catalog function is equal;
4. firmware extent = catalog size; past it only the pool words referenced from inside are read. **Finding
   (code-verified):** the vendor toolchain shares literal pools between consecutive functions — `0300C3AC` loads
   `00033CC8` from `0300C408`, behind the following functions (GCC 6.3 emits one pool per function);
5. prints the verdict and a two-column listing (both sides disassembled with the candidate's objdump, PC-relative
   operands shown as resolved targets): `PASS` (exit 0), `PASS-ENC` (exit 3: identical except the 16-bit
   `addu/subu` three-operand re-encoding of §1.3, same size and semantics), `UNRESOLVED` (exit 4: equal where
   checkable, a relocation names no firmware address), `FAIL` (exit 1, with the number of differing items),
   2 = error.

Host tests (`tools/tests/test_dm32re.py`): `MatchPure` (no toolchain: pool alignment, encoding-only, relocated call
and data word, firmware longer than the compiled function), `MatchCompiled` (a tiny function with a call and a data
reference compiled by V3.10.29 against a synthetic firmware buffer: PASS, FAIL on a changed byte, FAIL on a wrong
callee), `MatchStock` (pilot facts on the stock image: shared pool, best flag set, entry extension). Tools suite:
45 tests, 2 skipped (GCC 13 corpus), 2026-10-18.

## 3. M3 — pilot on 30 functions

All 30 functions are catalog `high` rows outside the library blocks, reviewed earlier (roles in the catalog). One C
file each under `analysis/matching/` (header: address, result, best flags, oracle command, attempts); results in
`analysis/matching/pilot_results.csv`. Effort cap: 13 flag sets (`pilot.py`) × at most 3 source variants per function
(≤ 39 compiles; most functions 13 or 26). Toolchain: pinned V3.10.29 (V3.10.33 generates the same code, §1). Size
class by firmware instruction count: tiny ≤ 7, small 8–40, medium > 40. "near" = FAIL with ≤ 3 differing items.

| Address | Function | Class | Insns | Result | Best flags (`-mcpu=ck803` …) | Blocker |
|---|---|---|---:|---|---|---|
| `0300C434` | stub returning 0 | tiny | 2 | **PASS** | any | — |
| `0300C3AC` | `rf_carrier_get` (33CDC) | tiny | 3 | **PASS** | any | — (shared pool handled) |
| `0300C3B4` | `tx_admit_policy_set` (33CD0) | tiny | 3 | **PASS** | any | — |
| `030272E0` | `slot_not_locked` (3BEB1 != 1) | tiny | 5 | **PASS** | any | — |
| `0301E7B0` | `rx_group_entry_set` | tiny | 5 | **PASS** | any | needs `int i` + `(unsigned char)` cast (entry `zextb`) |
| `03023A60` | `rxvoice_busy_set` (33CDD = 1) | tiny | 4 | near 2 | any | scheduling: vendor `movi` before `lrw` |
| `0002C1D0` | `lcd_cmd` | tiny | 5 | near 1 | `-Os` | entry `zextb r0, r0` at the top; GCC 6.3 places it after the address build |
| `0002C3B8` | `power_dac_set` | tiny | 6 | near 2 | any | entry `zextb`; GCC 6.3 folds the extension into the shift |
| `00019494` | `fill16` | tiny | 6 | near 2 | `-Os -fno-reorder-blocks` | loop shape: vendor `blsz` guard + `bnez` latch, GCC 6.3 jumps to the test / uses an index |
| `03029318` | `slot_flags_clear` (7 stores) | small | 13 | **PASS** | `-O1`, `-O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2` | — |
| `03023CCC` | `popcount8` (table 030B043C) | small | 13 | **PASS** | `-O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2` | needs `int` parameter + local `unsigned char` |
| `0002C38C` | `dac_write` (3 channels) | small | 17 | **PASS** | same | needs `int` parameter + local `unsigned char` |
| `03039420` | `list_down` | small | 22 | **PASS** | `-O2 -fno-reorder-blocks -fno-crossjumping` | needs `int count`; with `-fno-schedule-insns2` 2 items (entry `zextb` order) |
| `03029F9C` | `put_le32` | small | 9 | near 3 | `-O1` | vendor `addi r1, 2` between the byte stores (addressing choice) |
| `0002F088` | `copy8` | small | 8 | FAIL 7 | `-O1` | indexed `ldr.b/str.b` loop vs pointer increments; loop shape |
| `0301E7BC` | `color_code_set` | small | 10 | FAIL 8 | any | vendor builds `0x11000000` with `movi 136; lsli 21` and uses offset `0x384`, GCC 6.3 loads `0x11000380` from the pool (offset 4); `andni` vs `movi/subi/and`; entry `zextb` |
| `0302307C` | `ipow` | small | 11 | FAIL 10 | `-Os -fno-reorder-blocks` | loop rotation and `mult` operand order |
| `03020D58` | `rx_call_class` | small | 17 | FAIL 12 | `-Os -fno-reorder-blocks` | vendor reloads the base (`lrw` twice); `inct/incf` select layout |
| `030248E0` | `diff_cmp16` | small | 16 | FAIL 9 (1 enc) | `-Os -fno-reorder-blocks` | entry `zexth` ×3, `subu` three-operand encoding, select layout |
| `03023C6C` | `nth_set_bit` | small | 19 | FAIL 9 | `-Os` | register allocation (`r13`/`r12` counters), loop exit layout |
| `0300F780` | `area_read` | small | 18 | FAIL 10 | `-O1` | vendor extends all parameters into callee-saved registers on entry, GCC 6.3 extends at the use |
| `0301EC40` | `monitor_flag_set` | small | 24 | FAIL 20 | `-O2 -fno-reorder-blocks` | `ins` identical; vendor keeps the bit-field byte in a register (GCC reloads it), rebuilds `0x11000000` with `movi; lsli` before the store (GCC: pool word `0x11000380`), `bseti` vs `ori` |
| `0002C504` | `gpio_set` | small | 27 | FAIL 18 | best set | register allocation (`r3` base / `r2` value vs `r2`/`r1`), no tail duplication |
| `0002C58C` | `gpio_read` | small | 30 | FAIL 19 | best set | same as `gpio_set`, `cmpnei; mvc` per branch |
| `0300C224` | `crc32_bits` | small | 30 | FAIL 30 | `-Os -fno-reorder-blocks` | `inct/incf` selects vs branches, `addu r0, r0, r0` encoding, register allocation |
| `0300C154` | `crc9_bits` | small | 33 | FAIL 38 (1 enc) | `-Os -fno-reorder-blocks` | same as CRC-32 |
| `0300F71C` | `sector_read` | small | 38 | FAIL 35 | best set | register allocation and parameter extension into `r4…r9` |
| `03055CCC` | `channel_locate` | medium | 41 | FAIL 51 | `-Os -fno-reorder-blocks` | `divu`/`ixw`/`mult` strength reduction differs; `zexth` after every operation |
| `03017BE8` | `fill_rect` | medium | 42 | FAIL 29 | best set | loop nest layout, zero-extension after every increment |
| `03011BB8` | `nmea_checksum` | medium | 46 | FAIL 31 | `-O2 -fno-reorder-blocks` | `cmphsi; movi; inct` wrap select, block order |

"best set" = `-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2`.

**Success rates** (code-verified by the oracle, 2026-10-18): tiny 5/9 PASS + 4 near; small 4/18 PASS + 1 near;
medium 0/3; overall **9/30 PASS** (30 %), 5 near. `-mcpu=ck803s` never differed from `-mcpu=ck803`. No function
reached `PASS-ENC` only: the two that contain a vendor three-operand `addu/subu` fail elsewhere too.

**Best flags** (inferred from the PASS set): one flag set reproduces 8 of the 9 PASS functions:
`-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2` (8 PASS, 379 differing items summed over all
30; plain `-Os` 5 PASS / 506, `-O1` 6 PASS / 519, `-O2` 5 PASS / 526). The 9th (`list_down`) needs post-reload scheduling. So the
vendor code looks like an `-O2`-class build without block reordering, cross-jumping/tail merging and post-reload
scheduling — which fits a GCC 4.5-era C-SKY port rather than a deliberate flag choice (inferred).

**Failure causes**, in order of frequency:

1. **Parameter extension on entry**: the vendor compiler re-extends every `char`/`short` parameter (`zextb`/`zexth`)
   as the first instructions, often into callee-saved registers; GCC 6.3 trusts the caller's promotion or extends at
   the use. Modelling the parameter as `int` with a local narrow copy fixes it only when the scheduler keeps the
   order (4 PASS depend on this; it is a modelling choice, recorded in each file).
2. **Register allocation**: different preferred registers for address bases and temporaries (`r3`/`r2` vs `r2`/`r1`,
   `r12`/`r13` counters), not reachable from the source.
3. **Instruction selection and constants**: `inct/incf` conditional selects for `?:`, MMIO bases built with
   `movi; lsli` and large load/store offsets instead of a pool word, `andni`/`bseti` forms, `divu`/`ixw` sequences,
   `zexth` after every 16-bit operation.
4. **Block layout and loop shape**: loop rotation with a `blsz` guard, no tail duplication, reloaded bases.
5. **Assembler encoding**: 16-bit three-operand `addu/subu` (§1.3); handled by `PASS-ENC` but never the only
   difference in this set.
6. **Shared literal pools** between functions: a layout property handled by the oracle (pool words compared by
   index).

## 4. Estimate and recommendation

Vendor code outside the libraries: 263 catalog functions ≤ 16 bytes, 658 of 17–80 bytes, 581 of 81–240 bytes, 411
larger (384 KB in all; `function_catalog.csv` sizes). Extrapolating the pilot rates with **V3.10.29** (inferred,
small sample, and the pilot picked well-understood functions):

| Class | Catalog functions | Expected PASS | Bytes covered |
|---|---:|---|---|
| ≤ 16 bytes | 263 | ~50 % → ~130 | ~1.3 KB |
| 17–80 bytes | 658 | ~20 % → ~130 | ~6 KB |
| 81–240 bytes | 581 | ≤ 5 % → ≤ 30 | ≤ 4 KB |
| > 240 bytes | 411 | ~0 | 0 |

That is **about 3 % of the vendor code bytes**, almost all trivial getters, setters and stubs whose meaning is
already known. Cost: the pilot needed about 13–39 compiles and a few minutes of agent time per function; a larger
run over ~900 small functions would take on the order of 100 agent-hours and ~25 000 compiles (cheap: ~1 s each).

**Recommendation: no-go** for a large agent-driven matching effort with the reachable compilers. The blockers are
compiler properties (entry extension, register allocation, selection, scheduling), not missing knowledge of the
source; more iterations do not remove them, and forcing them would be fake matching.

**Go condition:** obtain the vendor toolchain — most likely C-SKY Tools V2.x with GCC 4.5.1 and its assembler
(§1.3), e.g. from an old CDK/CDS installer the owner may have, or from the HR_C7000/radio SDK. Then rerun
`python3 analysis/matching/pilot.py --toolchain <root>` (the oracle and the 30 C files are toolchain-agnostic; adapt
`libsig.LIB_DIRS` if the library layout is not `lib/gcc/csky-elfabiv2/6.3.0`) and first run
`tools/dm32 libsig --toolchain <root> --norm`: if the vendor libc rows become `exact`, the release is found and a
pilot rate well above 50 % for small functions would justify a larger effort on selected subsystems. Matching is not
needed for the planned TS/CC Match work, which uses our own module built with V3.10.29.

## 5. Open questions for the owner

- Is an old C-SKY CDK/CDS installation (Windows) or a Hongrui HR_C7000 / radio vendor SDK available? Its
  `csky-abiv2-elf-*` toolchain (version string, e.g. "C-SKY Tools V2.x") would settle the vendor compiler. Please
  record its hash; agents only read its libraries and run its compiler.
- Should matching be pursued at all for this firmware? The pilot says it pays off only with the vendor's compiler.

## 6. Hardware tests

None: the pilot changes no firmware, builds no image and needs no radio. No image file was written, no serial port
opened.

## 7. Left open

- Medium class sampled with 3 functions only (instruction counts > 40); no large functions tried.
- `PASS-ENC` exercised only by host tests, not by a real function in this set.
- The int-parameter modelling (§3 cause 1) should be re-checked with the vendor compiler, where the plain
  `unsigned char` parameter is expected to reproduce the entry extension directly.
- Catalog: no row changed (the PASS functions confirm types and widths already in their evidence: byte flags at
  `33CDC`, `33CD0`, `3BEB1`, `33CDD`, 32-bit group IDs at `33CF4`, 12-bit DAC value; no new evidence for a row).
