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

## 6. Kernel pass 2: OSInit order, port, task list, 109 catalog rows (2026-10-17)

Static only; stock image `de7dbcbc…`, `tools/dm32 fn/callers/callees` (binutils 2.42), T-HEAD-built uC/OS-III
references as structure guide only. Every row carries its evidence in `function_catalog.csv` (subsystems
`RTOS (uC/OS-III, pre-V3.08 with ISR post queue)`, `RTOS (uC/CPU)`, `RTOS (uC/OS-III C-SKY port)`,
`RTOS (BSP tick/interrupt controller)`). Result: **109 rows** reviewed (42 high, 63 medium, 4 low; two of them
upgraded from low, see below). All kernel and uC/CPU rows in IRAM `00010000–00014128` and flash
`03068E00–0306BF08` are now named; six IRAM rows after `00014128` are application code (left for work item B).

**OSInit call order (code-verified, pinned in `Analysis.test_osinit_call_order`):** `OSInitHook` `000106DC`,
`OS_PrioInit` `000119E0`, `OS_RdyListInit` `00010D44`, `OS_FlagInit` `03069550`, `OS_MemInit` `03069CF8`,
`OS_MsgPoolInit` `03069D10`, **`OS_MutexInit` `0306A8AC`**, `OS_QInit` `0306AF0C`, `OS_SemInit` `00011FD8`,
`OS_TaskInit` `00012B70`, `OS_IntQTaskInit` `000118CC`, `OS_IdleTaskInit`, `OS_TickTaskInit` `00013874`,
`OS_StatTaskInit`, `OS_TmrInit`, `OS_Dbg_Init` `03068E6C` (empty), `OSCfg_Init` `03068E68` (empty). Between the
calls OSInit clears the globals in source order, which names them: `OSRunning` `42734`, `OSTCBCurPtr` `42524`,
`OSTCBHighRdyPtr` `42CD0`, `OSPrioCur` `42CE4`, `OSPrioHighRdy` `42CCC`, `OSPrioSaved` `42724`, scheduler-lock
time `42700`/`42CD4`/`42704`, round robin `OSSchedRoundRobinEn` `42532` and default quanta `42604`
(= tick rate / 10), the seven application hook pointers `42714` (TaskCreate), `42708` (TaskDel), `426EC`
(TaskReturn), `426E8` (Idle), `42C00` (Stat), `42A40` (TaskSw), `426D8` (TimeTick), `OSTaskRegNextAvailID`
`42710`.

**Kernel configuration (code-verified from the `OSCfg_*` const table at `03076DBC…03076E5C` and the code):**

| Item | Value |
|---|---|
| Tick rate | `OSCfg_TickRate_Hz` = 100 Hz (`03076E1C`); timer 0 (`0x14000000`) reload = CPU clock (`3A628`) / 100, tick ISR `0306D6EC` on vector 33 |
| Priorities | 64 (`OSPrioTbl` 2 words, `OSRdyList` 64 × 12 bytes at `42740`) |
| Kernel tasks | ISR Queue 0, Timer 58 (10 Hz), Tick 59, Stat 60 (10 Hz), Idle 63; stacks 128 words each, limit 12 |
| ISR post queue | `OSCfg_IntQSize` 10 entries at `40E94` (pre-V3.08 deferred posts; `OS_Sched0` `00011148` switches to the ISR Queue Task from every `OS_CRITICAL_EXIT` with posts pending) |
| ISR stack | `4189C`, 0x100 words; interrupt frames use stack `4B7E0` (port) |
| Message pool | 100 `OS_MSG` at `4125C` (`OSMsgPool` `42A50`) |
| Tick / timer wheels | 17 spokes each (`4209C`, `411D8…`) |
| Timestamps | `CPU_TS_TmrRd` `0306D6A0` returns `OSTickCtr` (`426F4`); `CPU_TS_TmrFreqSet(100)` — time stamps count ticks |
| Enabled options | app hooks, round robin, task profiling (per-task cycles, `OSTaskSwHook`), interrupt-disable and scheduler-lock time measurement, statistics task, timers, flags, memory partitions, mutexes, queues, semaphores, task queues/semaphores, debug lists and names, task registers |

`OS_IntQRePost` `000116A4` dispatches on the object type tags `TMSG`/`FLAG`/`TSIG`/`SEMA`/`TRES`/`TICK`/`TSUS`/`QUEU`;
the `TICK` case runs round robin on `OSRdyList[OSPrioSaved]`, posts the tick task (`OSTickTaskTCB` `4253C`) and every
`OSTmrUpdateCnt` (`4252C`) ticks the timer task (`OSTmrTaskTCB` `42610`).

**Port (C-SKY, code-verified structure, names inferred from uC/OS-III port conventions):** `OSStartHighRdy` `000105B8`,
`OSCtxSw` `000105BE` (saves r0–r13, r15, EPSR; when an interrupt frame is pending at `18000BD4` it swaps that frame
instead), `OSIntCtxSw` `000105E6`, the common interrupt entry `0001064A` (vector-table words `00010080…`: frame to
`18000BD4`, ISR stack `4B7E0`, `OSIntEnter`, acknowledge `0x17000010`, handler table `45538[vector − 32]`, `OSIntExit`,
`rte`), `OSTaskStkInit` `00010748` (PSR `0x80000140`, return address `OS_TaskReturn` `000133DC`), `OSInitHook`
`000106DC`. BSP: interrupt controller `0x17000000` (`0306D794`, `0306D7B0`, register/enable `0306D704`/`0306D73C`),
timer `0306D6C0`, tick start `0306D670` (called by the startup `0002E174`).

**Task list (code-verified from the 38 `OSTaskCreate` call sites; priority, stack size in 32-bit words; lower number
= higher priority):**

| Prio | Task (name string) | Entry | Stack | Created by |
|---:|---|---|---:|---|
| 0 | uC/OS-III ISR Queue Task | `0001183C` | 128 | `OS_IntQTaskInit` |
| 5 | task ShutDown | `0301B784` | 128 | `0301B89C` |
| 6 | SlotTimer | `030293C8` | 256 | `0300C904` |
| 7 | keys | `03012D2C` | 192 | `03012EA0` |
| 8 | keyTime | `030151D0` | 256 | `03012EA0` |
| 10 | task rf | `0300DC94` | 256 | `0300D4B0` |
| 11 | task usb | `0302B340` | 200 | `03029F44` |
| 12 | txslot | `0002D620` | 256 | `0300C904` |
| 13 | decrypt | `0002D324` | 256 | `0300C904` |
| 14 | encrypt | `0002D2F0` | 256 | `0300C904` |
| 17 | sysint | `0002D770` | 450 | `0300C904` |
| 18 | rxslot | `0302386C` | 256 | `0300C904` |
| 19 | task sound | `03022FB0` | 256 | `03021BD4` |
| 20 | task psint | `0305F234` | 384 | `0300CD6C` |
| 22 | CclTraffic | `0301E924` | 256 | `0300C904` |
| 23 | rxcsbk | `030209E4` | 256 | `0300C904` |
| 24 | rxvoice | `030206D0` | 384 | `0300C904` |
| 25 | txmsg | `0301FDD8` | 256 | `0300C904`; re-created by `0300C898` after `OSTaskDel` |
| 26 | rxmsg | `0301FF9C` | 256 | `0300C904` |
| 27 | record | `0302124C` | 256 | `0300C904` |
| 28 | task CodeSw | `030323C8` | 384 | `03030314` |
| 29 | task cds | `0300E49C` | 256 | `0301D550` |
| 30 | task init (main task) | `03068E54` | 720 | startup `0002E174` |
| 31 | task menu | `03040A38` | 640 | `03035E18` |
| 32 | Led Manage | `030614D8` | 256 | `03061170` |
| 33 | cpchanscan | `03023B3C` | 256 | `0300C904`, only when `33CC9` = 2 |
| 34 | task TmrHnd | `03055918` | 256 | `030559A8` |
| 35 | task SqlCheck | `03060F18` | 256 | `0300D4B0` |
| 36 | task CallDisp | `0302DF18` | 300 | `0302B7DC` |
| 37 | task InputAlter | `0305AA50` | 200 | `03059448` |
| 38 | task ScanDisp | `0305490C` | 384 | `030545FC` |
| 58 | uC/OS-III Timer Task | `0306BBD4` | 128 | `OS_TmrInit` |
| 59 | uC/OS-III Tick Task | `00013C34` | 128 | `OS_TickTaskInit` |
| 60 | uC/OS-III Stat Task | `0306B1F8` | 128 | `OS_StatTaskInit` |
| 63 | uC/OS-III Idle Task | `00010868` | 128 | `OS_IdleTaskInit` |
| run time | encoder / decoder | `0002E5BC` / `0002EC4C` | 1280 / 768 | `000162A8` (priority from `0001616C`, vocoder library) |

Prior docs called `0302DF18` "the UI task"; its name string is `task CallDisp`. The entries without catalog rows
(`0001183C`, `00013C34`, `0306B1F8`, `0306BBD4`, `00010868`, `000133DC`, `0306D6EC`) are discovered entries
(`SUB_…`) in `tools/dm32`.

**Upgraded rows:** `03069868` `OS_FlagTaskRdy` low → medium (body read: `FlagsRdy` +0x84, `OS_TaskRdy`,
`OS_PendListRemove`; called at all four match positions of `OS_FlagPost`); `0306D6A0` `CPU_TS_TmrRd` low → medium
(`CPU_TS_TmrFreqSet(100)` in `0306D694`).

**Correction to section 5:** mutexes exist. `OS_MutexInit` is the seventh `OSInit` call and `OS_MutexClr`
`0306A4A8` sets the name `?MUTEX`; the mutex API functions sit in catalog gaps (below), so `OSMutexPend` was not
"not located" but uncatalogued. The `OSIntExit` implementation is `000108B0`.

**Uncatalogued kernel functions (no Ghidra boundary; inferred from object tags and `OS_ERR_*` codes, leads only):**
`OSTaskChangePrio` `0001216C`, `OSTaskQFlush` `0001230C`, **`OSTaskQPend` `000123C4`** (25301 message-size check,
`OS_MsgQGet`), `OSTaskQPendAbort` `00012580`, `OSTaskRegGet`/`OSTaskRegGetID`/`OSTaskRegSet` `00012664`/`000126A0`/
`000126E4`, `OSTaskSemPendAbort` `000128B8`, `OSTaskSemSet` `000129B0`, `OSSemPendAbort` `00011C0C`, `OSSemSet`
`00011D0C`, `OSTimeDlyResume` `00013F38`, `OSTimeGet`/`OSTimeSet` `000140D8`/`000140FC`, `OSFlagPendAbort`
`03068E70`, `OSFlagPendGetFlagsRdy` `03068F70`, `OSMemGet`/`OSMemPut`/`OSMemCreate` `03069B00`/`03069B54`/
`03069BD0` (tag `MEM `), `OSMutexPend`/`OSMutexPendAbort`/`OSMutexPost`/`OSMutexCreate`/`OSMutexDel`
`03069F04`/`0306A19C`/`0306A2AC`/`0306A4EC`/`0306A5E8` (tag `MUTX`), `OSQFlush` `0306A8CC`, `OSQPendAbort`
`0306AB78`, `OSQDel` `0306ADC4`, `OSStatTaskCPUUsageInit` `0306B560`, `OSTmrRemainGet` `0306B6D0` (tag `TMR `,
29501…29507), `CPU_NameGet`/`CPU_NameSet` `00010298`/`0001030C`, CPU count-zeros variants `00010434…000105A8`.

## 7. uC/LIB and uC/CPU: presence established, 15 uC/LIB rows (2026-10-17)

uC/LIB is present (code-verified): `Mem_SegGetSizeRem` `0306C4F8` and `Mem_PoolClr` `0306C5BC` use the uC/LIB
memory-type tags `POOL` (`4C4F4F50`), `HEAP` (`50414548`), `NONE` and the `LIB_MEM_ERR_*` codes 10000…10135, call
`CPU_SW_Exception` (`000101B4`, endless loop) on a NULL error pointer, and use the heap segment `Mem_PoolHeap`
(`454EC`); `Mem_Clr` `0306C2C8` is called by `CPU_NameClr` `00010348` with `CPU_Name` (`4564C`, 16 bytes). The API
shape (`Mem_SegGetSizeRem`, `Mem_PoolBlk*`) suggests an older uC/LIB release than the public reference (inferred).
Named: `ASCII_IsAlphaNum/IsLower/IsDig/IsDigHex/IsSpace/IsPrint/ToLower` `0306BF08…0306C094` (character ranges and
call positions inside `Str_ParseNbr_Int32` `0306CDB8`, `Str_FmtNbr_Int32` `0306CF54`, `Str_CmpIgnoreCase_N`
`0306D318`), `Mem_Set` `0306C254`, `Mem_SegCalcTotSize` `0306C12C` (low); 15 rows (14 medium, 1 low). uC/CPU
(11 rows, counted in section 6): interrupt-disable measurement
getters `000101A4…00010224`, `CPU_CntLeadZeros32` `000103E0` (table `03076BD4`) and its wrapper `CPU_CntLeadZeros`
`0001042C` (resolves the section 5 lead), `CPU_TS_TmrFreqSet` `000101E8`, `CPU_TS_TmrInit` `0306D694`.

The section 4 byte hits of `ASCII_ToLower` inside `0306C094` were accidental as a byte match, but the function itself
is `ASCII_ToLower` in the vendor encoding (`zextb`, range check, `+32`).

No direct call from vendor code into uC/LIB was found: the `Str_*` and `Mem_*` functions have no callers outside the
library and the CPU name functions, so uC/LIB is linked but essentially unused (inferred; calls through pointers
are not tracked).
Uncatalogued uC/LIB functions (leads): `Mem_HeapAlloc` `0306C42C`, `Mem_PoolCreate` `0306C608`,
`Mem_PoolBlkGetNbrAvail` `0306C9B8`, `Mem_PoolBlkGet` `0306CA10`, `Mem_PoolBlkGetUsedAtIx` `0306CAD4`,
`Mem_PoolBlkFree` `0306CB80`, `Mem_PoolBlkIxGet` `0306CC94`, `Str_Str` `0306D5A8`, `Str_FmtNbr_Int32U/S` `0306D5B4`/
`0306D5E0`, `Str_ParseNbr_Int32U/S` `0306D61C`/`0306D630`, further `Str_*` in `0306D154…0306D23C`.

## 8. Block `0306D800–0306F97C`: fdlibm libm and libgcc fp-bit soft-float (2026-10-17)

Identified (code-verified by constants and call structure): the block is the vendor build of the toolchain's libm
(fdlibm) and of libgcc's `fp-bit` soft-float, linked between uC/LIB and the minilibc block.

- libm (`C runtime (libm, fdlibm)`, 10 rows: 7 high, 3 medium): `asin` `0306D7E0` (coefficients pS0…pS5/qS1…qS4, `pio2_hi/lo`, `pio4_hi`
  in initialised SRAM `18000C38…18000CB0`), `sin` `0306DE28` and `cos` `0306DCBC` (π/4 test `3FE921FB`, then
  `__ieee754_rem_pio2` and the `n & 3` switch over the kernels), `__ieee754_rem_pio2` `0306E16C` (`pio2_1…pio2_3t`,
  `invpio2`), `__kernel_sin` `0306E57C` (S1…S6), `__kernel_cos` `0306E6FC` (C1…C6), `sqrt` `0306DEE0`, `fabs`
  `0306DD74`, `ceil` `0306DC14`, `floor` `0306DD7C`. Callers: the GNSS position code (`03062E98`, `03063878`,
  `03063960`, `03063EA4`; purpose not reviewed) and `0305FD98`, `030676CC`.
- soft-float (section 9) `0306EB10…0306FFE8` and `03070000…030703D0`.
- Left unreviewed: `0306E0BC` (remainder-like helper, calls `0306E88C`; norm lead `_rem`), `0306E88C`
  (`fmod`-like; `7FF00000`/`FFF00000` tests).

## 9. Normalised comparison (`libsig --norm`) and the C runtime leftovers (2026-10-17)

`python3 tools/dm32 libsig --norm` (pure Python, < 10 s) adds a pass over the library block `0306D7E0…03072800`
that compares instruction tokens after normalising the vendor encodings (`norm_tokens`, `norm_insn` in
`tools/dm32re/libsig.py`):

- 16-bit three-operand `addu`/`subu` (`0x58xx…0x5Fxx`) with `rz == rx` (or `rz == ry` for `addu`) become the
  two-operand form `0x6000 | rz << 6 | rx << 2 (| 2 for subu)`, the only form V3.10.29 emits;
- a leading run of `zextb`/`zexth`/`sextb`/`sexth rx, rx` is dropped;
- PC-relative fields (`br/bt/bf` 16/32, `bez…bhsz`, `bsr32`, `lrw16/32`, `jsri`, `jmpi`) are masked, literal
  pools become data tokens (relocated words match any value), and an alignment filler before a pool is dropped
  (pool alignment depends on the absolute address, so the reference uses its section offset);
- `norm` = identical token streams over the whole function (register-exact) → evidence for `high`;
  `norm-near` = register-exact difflib ratio ≥ 0.90; `norm-lead` = best register-blind candidate (register fields
  of the common formats cleared) with ratio ≥ 0.25 and ≥ 0.03 ahead of any other name — a rank, never a name by
  itself.

Results (CSV regenerated with `--norm`: `analysis/decompiled_modules/libsig_thead_matches.csv`, 64 rows; the
default run without `--norm` is unchanged):

| Address | Before | Now |
|---|---|---|
| `0307050C` malloc, `03070C08` memset, `03070E24` isspace, `0307183C` strtoul | near (0.97/0.99/0.90/0.99) | **norm** (identical after normalisation) → catalog `high` |
| `03070918` strtol | near 0.94 | norm-near 0.98 (one register choice differs) |

The other vendor library functions differ in register allocation and instruction selection, so their register-blind
ratios stay at 0.25–0.73: the vendor release is not a re-encoding of V3.10.29 but a different compiler build.
`norm-lead` ranks were checked against constants and call structure: of 36 leads, the name is confirmed for the
soft-float operators and `strtod`, but four are wrong (`0306D7E0` → `__kernel_tan`, really `asin`; `0306E6FC` →
`__kernel_sin`, really `__kernel_cos`; `0306DE28` → `cos`, really `sin`; `0306EB40` → `__strcpy_chk`, really
`__fixunsdfsi`), which is why a lead alone never names a row. Host tests: `LibSigNormalise` (pure encodings) and
`LibSigStock.test_norm` (the four `norm` rows and strtol).

Named from structure plus leads (`C runtime (T-HEAD minilibc/libgcc)`, 43 rows: 22 medium, 21 low; evidence per row):
single precision `__addsf3`/`__subsf3` `0306ECBC`/`0306ECF0`, `__mulsf3` `0306ED30`, `__divsf3` `0306EE44`,
`_fpadd_parts` `0306EB7C`, `__floatsisf` `0306EFB0`, `__floatunsisf` `0306F090`, `__fixsfsi` `0306F004`,
`__fixunssfsi` `0306EB10`, `__extendsfdf2` `0306F064`, `__gesf2` `0306EF70`, `__pack_f`/`__unpack_f`
`0306FDDC`/`0306FEB8`, `__fpcmp_parts_f` `0306FF5C`; double precision `__adddf3`/`__subdf3` `0306F458`/`0306F494`,
`__muldf3` `0306F4DC`, `__divdf3` `0306F784`, `_fpadd_parts` `0306F10C`, `__floatsidf` `0306FAEC`, `__fixdfsi`
`0306FB70`, `__fixunsdfsi` `0306EB40`, `__truncdfsf2` `0306FC1C`, `__make_dp` `0306FBF4`, `__gedf2` `0306FA10`,
`__pack_d`/`__unpack_d` `03070000`/`030702FC`, `__fpcmp_parts_d` `030703D0`, six comparisons whose operator is not
determined (`0306EF30`, `0306F97C`, `0306F9C4`, `0306FA5C`, `0306FAA4`, `03072780`); 64-bit shifts `03070474`/
`0307049C`; `strtod` `030706E4`; `vsnprintf` `03070E90` (low → medium); printf core `03070EF0`, `__dtostr`-like
`03071950`, `__lltostr`-like `03071DE4`, 64-bit division helpers `03071FE0`/`030723BC` (low).

Left unreviewed in the C runtime: `0306FC60` (calls `__pack_d` three times), `0306FD70` (helper of the multipliers),
`03070698`, `03071834`, `03071D90`, `03071DB0` (`__isinf` lead), `03071EA4`.

## Open questions for the owner

- None blocking. If the vendor toolchain release becomes known (CDK project files, an SDK in the update package),
  its libraries would settle the near and lead rows and enable matching decompilation of vendor code.
- The vocoder tasks `encoder`/`decoder` get their priority at run time from `0001616C`; whether that library is
  third-party (it has its own IRAM code around `00014200…00017000`) is open.

## RX-only hardware tests

None needed: names of library functions do not change radio behaviour. This work changed no firmware.

## Left unreviewed

- Library block (2026-10-17, after sections 6–9): `0306E0BC`, `0306E88C` (libm helpers), `0306FC60`, `0306FD70`,
  `03070698`, `03071834`, `03071D90`, `03071DB0`, `03071EA4` (C runtime); the six comparison operators named only as
  a group; the uncatalogued kernel/uC/LIB functions listed in sections 6–7; `03010978` (heap user).
- IRAM `00014164…000141C8` (six rows after the kernel) are application code, handled by the subsystem tags.
- All other catalog rows still marked `unreviewed` (1669 on 2026-10-17 after this pass; high 247, medium 224,
  low 31).
