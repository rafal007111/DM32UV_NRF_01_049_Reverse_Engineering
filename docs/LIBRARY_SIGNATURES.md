# Library signatures from the pinned T-HEAD toolchain — DM32.NRF.01.049 (2026-10-17)

Static only. Inputs: stock `stock_progmem_1MiB.bin` (`de7dbcbc…`, verified on load), T-HEAD C-SKY Tools V3.10.29
Minilibc abiv2 B20210423 x86_64 Linux (archive `8b9a353c…`, see [REPRODUCIBILITY.md](REPRODUCIBILITY.md) "Linux
build"), Python 3.13. No radio access, no image written.

```sh
bash tools/setup_cloud.sh --with-thead && source /opt/dm32-tools.env
python3 tools/dm32 libsig --csv analysis/decompiled_modules/libsig_thead_matches.csv   # < 2 s, no binutils needed
python3 tools/dm32 libsig --all                                                         # also short and lead rows
```

## 1. Method (`tools/dm32re/libsig.py`)

Every function of the toolchain's little-endian ck803 archives (`libc`, `libm`, `libgcc`, `libcc-rt`, `libsemi`,
`libssp`, crt objects; default, `soft-fp` and `hard-fp` variants; 2139 distinct functions) is read from the ELF objects
with its literal pool. Bytes under a relocation are masked; the toolchain uses only two kinds:
`R_CKCORE_PCREL_IMM26BY2` (`bsr32`) and `R_CKCORE_ADDR32` (pool words). The longest unmasked run is searched in
the whole image and each hit is checked over the full function. Uniqueness is counted separately for the boot
prefix and the application. For every unique hit the relocations are read back from the firmware: `bsr32`
targets name their callee (and confirm it when the callee matched too), pool words name data, string literals
are compared. Call targets that did not match are compared at their address ("bytes+call"). A "near" pass
compares unmatched call targets and the functions around the library block with every reference of similar
length (difflib ratio ≥ 0.88 on bytes, relocation positions zeroed on both sides; relocation-only tables are
skipped) and reads calls through the alignment.

Strength in the CSV: `exact` (≥ 24 fixed bytes, unique) → catalog `high`; `exact-short` (shorter, but called at the
library position by a matched or near function) and `near` → `medium`; `short` (unique, < 24 bytes, no
corroborating call) → `low`; `lead` = name taken from a relocation only.

## 2. Results (code-verified unless marked)

Application library block `0306F97C…03072E80`, all rows previously `unreviewed`:

| Address | Function | Strength | Notes |
|---|---|---|---|
| `03070B88` | `memcpy` (`__memcpy_fast`) | exact | 36 callers |
| `03070A3C` | `memcmp` (`__memcmp_fast`) | exact | |
| `03071F28` | `memmove` (`__memmove_fast`) | exact | |
| `03070CD8` | `strcpy` (`__strcpy_fast`) | exact | 14 callers |
| `03070DA4` | `strlen` (`__strlen_fast`) | exact | 57 callers; the boot prefix has its own copy at `030010E4` |
| `03070CA8` | `strcat` | exact | |
| `03070DE4` | `strncmp` | exact | |
| `030705A8` | `free` | exact | free-list head `malloc.o:F` = `18000C30` |
| `03070670` | `rand` | exact | seed `18000C34`; callers include `03024908` (mode-4 CSBK timing) and IRAM `00016B60`/`00016BDC` |
| `0307068C` | `srand` | short | no catalog row (inside the gap after `rand`) |
| `03070E08`, `03070E1C`, `03070E38` | `isalpha`, `isdigit`, `isupper` | exact-short | called at the library positions from `strtol`/`strtoul` |
| `03070E44`, `03070E48` | `os_critical_enter`, `os_critical_exit` | exact-short | **stubs `movi r0,0; jmp r15`**: minilibc `malloc`/`free` take no lock (see §3) |
| `03070CC4`, `03071934` | `strchr`, `strerror` | short | `strerror` string literal identical; table `CSWTCH.1` at `18004084` |
| `0306FFE8` | `__make_fp` (libgcc soft-float) | short | |
| `030704C4` | `sprintf` | short | the same bytes are `fprintf`/`sscanf`/`fscanf`; resolved by its callee (below); 49 callers |
| `0307050C` | `malloc` | near 0.97 | two instructions encoded differently; uses `__malloc_lock` (`0004A7D0`) |
| `03070C08` | `memset` | near 0.99 | without the leading `zextb r1` |
| `03070918`, `0307183C` | `strtol`, `strtoul` | near 0.94 / 0.99 | |
| `03070E24` | `isspace` | near 0.90 | without the leading `zextb` |
| `03072E80` | `POPCOUNT_TAB` (libgcc, 256 bytes) | exact | data, no catalog row |

Identified by hand from the call shape (T-HEAD objdump 2.27 listing of the stock bytes):

| Address | Function | Evidence | Label |
|---|---|---|---|
| `030704E0` | `vsprintf` | `r1 = -1`, `bsr 03070E90`; the only callee of `sprintf` | code-verified shape |
| `03070E90` | `vsnprintf` | called by `vsprintf`; calls `03070EF0` | inferred |
| `03070EF0` | printf formatting core (2340 bytes) | called by `vsnprintf`; also calls `strtol` | inferred, not reviewed |
| `03070500` | `atoi`/`atol` = `strtol(s, NULL, 10)` | `movi r1,0; movi r2,10; bsr 03070918`; callers include the NMEA parser `03012774` | code-verified |
| `030704F4` | `atof`-style `030706E4(s, NULL)` | call shape; `030706E4` (548 bytes) likely `strtod`; callers `03062A54` (GPS text), `03063EA4` | inferred |

Not matched (vendor build differs; candidates from the near pass below 0.88, all unreviewed leads): soft-float
helpers `0306F97C…0306FF5C` (`__pack_f` named as a call target at `0306FDDC`, `__floatsidf`-like `0306FAEC`,
`__fpcmp_parts`-like `0306FF5C`/`030703D0`), `03070000` (744 bytes, double arithmetic), 64-bit shift helpers
`03070474`/`0307049C`, `03071950` (1046 bytes, `__dtostr`-like), `03071DE4`/`03071EA4` (`__lltostr`/`__ltostr`-like),
`03071FE0`/`030723BC` (~970 bytes each, 64-bit division-like). No library function was found in IRAM.

## 3. Findings

- **The vendor used a different toolchain release** (code-verified fingerprint, release itself unknown): T-HEAD
  V3.10.29 never emits the 16-bit three-operand `addu`/`subu` with `rz == rx` (0 in our module and in its own
  `libc.a`), while the stock application has 809 of them (`addu` 580, `subu` 229) and the boot prefix 16. The
  near-identical libc functions differ in exactly such encodings and in dropped `zextb`. Consequence: our own module
  stays byte-exact with V3.10.29, but vendor functions cannot be reproduced byte for byte with it ("matching
  decompilation" needs a normalised comparison or the vendor's release).
- **Heap without locking** (inferred): `os_critical_enter`/`exit` are the minilibc default stubs, so `malloc`/`free`
  are not protected against task switches. Only two functions call them (`0305D34C`, the OutBox save after a send,
  and `03010978`, unreviewed), so a conflict needs both in different tasks at once; not reviewed further.
- **Names for 27 catalog rows** (9 high, 13 medium, 5 low → see `function_catalog.csv`, subsystem
  `C runtime (T-HEAD minilibc/libgcc)`), plus RAM labels `18000C30` (malloc free list), `18000C34` (rand seed),
  `0004A7D0` (`__malloc_lock`), `18004084` (`strerror` table).

## 4. uC/OS-III with T-HEAD-built references

`CC=$DM32_CSKY_TOOLCHAIN/bin/csky-elfabiv2-gcc bash tools/libref/build_ucos3.sh <src> build/dm32re/libref_thead`
(uC-OS3 `9a3fc5f4`, uC-CPU `ae5796e2`, uC-LIB `71b5f65d`; 60 objects, 585 functions). Exact byte search: only
`ASCII_ToLower`/`ASCII_ToUpper` (16 bytes) and `OS_PendListInit` (8 bytes) hit, each 2 or 8 bytes **inside** an
existing function (`0306C094`, `03069DBC`), so they are accidental; the public V3.08 kernel is not byte-identical to
the firmware's older kernel. uC/LIB presence remains not established.

Similarity scoring (`python3 tools/dm32 libid build/dm32re/libref_thead --min 0`, binutils 2.42) with the
T-HEAD-built corpus, compared with the GCC 13.3 corpus of `libid_ucos3_candidates.csv`; non-weak rows saved as
`analysis/decompiled_modules/libid_ucos3_thead_candidates.csv`. **All rows stay inferred.**

- strong 22 / medium 14 (GCC 13.3: 13 / 11). The mnemonic ratio rises for most kernel functions (e.g.
  `OSSchedLock` 0.62 → 0.78, `OSTaskStkChk` 0.52 → 0.62, `OSSemPend` 0.52 → 0.59), as expected from a compiler
  closer to the vendor's.
- 12 of the 13 earlier strong rows keep their address. `OSTmrDel`/`OSTmrStart` move from `0306B78C` to
  `0306BD74`, which agrees with the earlier manual check that `0306B78C` is `OSTmrStateGet` only.
- New strong leads (unshared): `OSFlagPend` `03068FE0`, `OSQCreate` `0306ACCC`, `OSQPost` `0306B03C`,
  `OSSemDel` `00011E84`, `OSTmrCreate` `0306B844`; uC/LIB `Str_Str_N` `0306D520` (strong), `Str_Len_N`
  `0306D120`, `Str_Cmp_N` `0306D248`, `Str_Char_Last_N` `0306D47C` — four `Str_*` functions next to each other
  make uC/LIB presence likely (inferred), unlike the accidental `ASCII_*` byte hits above.
- Shared claims `00011A58`, `00012720`, `0306BD74`, `00010934`: resolved in §5.

## 5. Kernel review: shared claims resolved, 50 catalog rows named (2026-10-17)

Same inputs; `tools/dm32 fn/callers` listings (binutils 2.42), constants and callee sequences compared with the
T-HEAD-built references. Evidence per row is in `function_catalog.csv` (10 high, 38 medium, 2 low).

**Shared claims (code-verified):**

| Address | Claims | Result | Evidence |
|---|---|---|---|
| `00011A58` | `OSSemPend` / `OSMutexPend` | `OSSemPend` | `'SEMA'` tag `0x414D4553`, no `'MUTX'` tag, no priority-change call |
| `00012720` | `OSTaskSemPend` / `OSTaskQPend` | `OSTaskSemPend` | error 28206 present, no `p_msg_size` check (25301), no `OS_MsgQGet` before the pend |
| `0306BD74` | `OSTmrDel` / `OSTmrStart` / `OSTmrRemainGet` | `OSTmrStart` | state switch: RUNNING → `OS_TmrUnlink` + `OS_TmrLink(p, 0)`; STOPPED/COMPLETED → `OS_TmrLink`; UNUSED → 29501; else 29505. `OSTmrDel` is `0306BE28` (`OS_TmrUnlink` + `OS_TmrClr` `0306B7F0`) |
| `00010934` | `OSSched` / `OSIntExit` | `OSSched` | called at the `OSSched` position by 19 task-level Pend/Post/Del/Create functions; never from an ISR epilogue |

**Kernel version (code-verified structure, version inferred):** the firmware kernel predates V3.08: posts are
deferred from ISRs (`OS*Post` → `OS_IntQPost` `00011604` when nested, else the task-level `OS_SemPost` `00011FE8` /
`OS_QPost` `0306AF1C`, functions absent from V3.08), `OS_TmrLock` is `OSSchedLock`, and `OS_ERR_OS_NOT_RUNNING`
(24201) is never used. Configuration seen in the code: uC/CPU interrupt-disable time measurement
(`CPU_IntDisMeasStart/Stop` `0001023C`/`00010260` inside every critical section) and scheduler-lock time
measurement (`OS_SchedLockTimeMeasStart/Stop` `0001117C`/`000111EC`).

**RAM labels (code-verified from the bodies):** `OSIntNestingCtr` `426FC` (ISR test in `OSTmrStart`),
`OSSchedLockNestingCtr` `42531`, ISR post queue entries `42A5E` / max `4270E` / in-pointer `4273C`,
`OSCfg_IntQSize` at flash `03076DD0`, scheduler-lock time maxima `42CD4`/`42704`, interrupt-disable measurement
`4563C`/`45648`/`45638`/`4565C`/`45660`.

**Not named** (left unreviewed, leads only): `0001042C` (wrapper to `000103E0`, possibly `CPU_CntLeadZeros`),
`OSInit` callees by call order only (`000106DC` `OSInitHook`, `000119E0` `OS_PrioInit`, `00010D44`
`OS_RdyListInit`, `03069550` `OS_FlagInit`, `03069CF8` `OS_MemInit`, `03069D10` `OS_MsgPoolInit`, `0306AF0C`
`OS_QInit`, `00011FD8` `OS_SemInit`, `00012B70` `OS_TaskInit`, `000118CC` `OS_IntQTaskInit`, `00013874`
`OS_TickTaskInit`), `Mem_SegAlloc` (`0305FDD4`, 11 instructions), the `OSTmrRemainGet`/`OSTaskQPend`/
`OSMutexPend`/`OSIntExit` implementations (not located).

## Open questions for the owner

- None blocking. If the vendor toolchain release becomes known (CDK project files, an SDK in the update package),
  its libraries would settle the near rows and enable matching decompilation of vendor code.

## RX-only hardware tests

None needed: names of library functions do not change radio behaviour.

## Left unreviewed

The not-matched rows of §2, `03070EF0` (formatter), `03010978` (heap user), the "Not named" kernel leads of §5 and
all other catalog rows still marked `unreviewed` (1843 on 2026-10-17).
