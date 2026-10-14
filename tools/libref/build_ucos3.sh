#!/usr/bin/env bash
# Build a reference corpus of public uC/OS-III + uC/LIB objects for C-SKY CK803, for `tools/dm32 libid`.
# Static analysis only: nothing here touches the radio or a program image.
#
#   bash tools/libref/build_ucos3.sh <dir with uC-OS3, uC-CPU, uC-LIB clones> [out dir]
#
# Sources: https://github.com/weston-embedded/{uC-OS3,uC-CPU,uC-LIB} (Apache-2.0; only V3.08.xx is public,
# while DM32.NRF.01.049 contains an older V3.0x with the "ISR Queue Task"). The port is the uC/OS-III
# Template with a stub cpu.h, so port/assembly functions do not match; kernel C code is what we compare.
# Objects are built with upstream GCC 13 (not the vendor compiler), at several -O levels.
set -euo pipefail
SRC=$(cd "$1" && pwd)
OUT=${2:-$(cd "$(dirname "$0")/../.." && pwd)/build/dm32re/libref}
CC=${CC:-/opt/csky-binutils/bin/csky-elfabiv2-gcc}
mkdir -p "$OUT/cfg"
CFG="$OUT/cfg"
cp "$SRC/uC-OS3/Cfg/Template/os_cfg.h" "$SRC/uC-OS3/Cfg/Template/os_cfg_app.h" \
   "$SRC/uC-OS3/Cfg/Template/os_app_hooks.h" "$SRC/uC-CPU/Cfg/Template/cpu_cfg.h" \
   "$SRC/uC-LIB/Cfg/Template/lib_cfg.h" "$CFG/"
# Stub CPU port: 32-bit little endian, critical sections as calls (like most ports).
cat > "$CFG/cpu.h" <<'H'
#ifndef CPU_MODULE_PRESENT
#define CPU_MODULE_PRESENT
#include <cpu_def.h>
#include <cpu_cfg.h>
typedef void CPU_VOID; typedef char CPU_CHAR; typedef unsigned char CPU_BOOLEAN;
typedef unsigned char CPU_INT08U; typedef signed char CPU_INT08S;
typedef unsigned short CPU_INT16U; typedef signed short CPU_INT16S;
typedef unsigned int CPU_INT32U; typedef signed int CPU_INT32S;
typedef unsigned long long CPU_INT64U; typedef signed long long CPU_INT64S;
typedef float CPU_FP32; typedef double CPU_FP64;
typedef volatile CPU_INT08U CPU_REG08; typedef volatile CPU_INT16U CPU_REG16; typedef volatile CPU_INT32U CPU_REG32;
typedef volatile CPU_INT64U CPU_REG64; typedef void (*CPU_FNCT_VOID)(void); typedef void (*CPU_FNCT_PTR)(void *);
typedef CPU_INT32U CPU_ADDR; typedef CPU_INT32U CPU_DATA; typedef CPU_DATA CPU_ALIGN; typedef CPU_ADDR CPU_SIZE_T;
typedef CPU_INT32U CPU_STK; typedef CPU_ADDR CPU_STK_SIZE; typedef CPU_INT32U CPU_SR; typedef CPU_INT32U CPU_TS_TMR;
#define CPU_CFG_ADDR_SIZE CPU_WORD_SIZE_32
#define CPU_CFG_DATA_SIZE CPU_WORD_SIZE_32
#define CPU_CFG_DATA_SIZE_MAX CPU_WORD_SIZE_64
#define CPU_CFG_ENDIAN_TYPE CPU_ENDIAN_TYPE_LITTLE
#define CPU_CFG_STK_GROWTH CPU_STK_GROWTH_HI_TO_LO
#define CPU_CFG_STK_ALIGN_BYTES 8u
#define CPU_CFG_CRITICAL_METHOD CPU_CRITICAL_METHOD_STATUS_LOCAL
#define CPU_SR_ALLOC() CPU_SR cpu_sr = (CPU_SR)0
#define CPU_INT_DIS() do { cpu_sr = CPU_SR_Save(); } while (0)
#define CPU_INT_EN() do { CPU_SR_Restore(cpu_sr); } while (0)
#define CPU_CRITICAL_ENTER() do { CPU_INT_DIS(); } while (0)
#define CPU_CRITICAL_EXIT() do { CPU_INT_EN(); } while (0)
#define CPU_CRITICAL_EXIT_NO_SCHED() CPU_CRITICAL_EXIT()
#define CPU_MB() __sync_synchronize()
#define CPU_RMB() __sync_synchronize()
#define CPU_WMB() __sync_synchronize()
void CPU_IntDis(void); void CPU_IntEn(void); CPU_SR CPU_SR_Save(void); void CPU_SR_Restore(CPU_SR cpu_sr);
CPU_DATA CPU_CntLeadZeros(CPU_DATA val); CPU_DATA CPU_CntTrailZeros(CPU_DATA val);
void CPU_Init(void);
#endif
H
cp "$SRC/uC-OS3/Ports/Template/os_cpu.h" "$CFG/os_cpu.h"
INC=(-I"$CFG" -I"$SRC/uC-OS3/Source" -I"$SRC/uC-CPU" -I"$SRC/uC-LIB")
FILES=("$SRC"/uC-OS3/Source/os_*.c "$SRC"/uC-LIB/lib_*.c)  # port C file needs the real port tree; skipped
for opt in Os O1 O2; do
    mkdir -p "$OUT/$opt"
    for f in "${FILES[@]}"; do
        base=$(basename "$f" .c)
        "$CC" -mcpu=ck803 -mlittle-endian -"$opt" -ffunction-sections -fno-common -w "${INC[@]}" \
            -c "$f" -o "$OUT/$opt/$base.o" 2>"$OUT/$opt/$base.err" || echo "skip $opt/$base (see .err)"
    done
done
ls "$OUT"/*/*.o | wc -l
