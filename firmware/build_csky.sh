#!/usr/bin/env bash
# Linux counterpart of build_csky.ps1 (same flags, module order and outputs) for the pinned
# T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2 B20210423 x86_64 build.
# Produces only a standalone module (staging_module.raw), never a firmware image; no radio access.
# Usage: firmware/build_csky.sh [--toolchain DIR] [--integration] [--scan]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
toolchain=${DM32_CSKY_TOOLCHAIN:-}
integration=0
scan=0
while [ $# -gt 0 ]; do
    case $1 in
        --toolchain) toolchain=$2; shift 2 ;;
        --integration) integration=1; shift ;;
        --scan) scan=1; integration=1; shift ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done
[ -n "$toolchain" ] || { echo 'Set DM32_CSKY_TOOLCHAIN or pass --toolchain to the installed T-HEAD C-SKY tools.' >&2; exit 1; }
cc=$toolchain/bin/csky-elfabiv2-gcc
objdump=$toolchain/bin/csky-elfabiv2-objdump
ld=$toolchain/bin/csky-elfabiv2-ld
objcopy=$toolchain/bin/csky-elfabiv2-objcopy
"$cc" --version | head -1
"$cc" --version | grep -q 'T-HEAD C-SKY Tools V3.10.29 Minilibc abiv2 B20210423' \
    || echo 'WARNING: not the pinned T-HEAD V3.10.29 B20210423 compiler; output is not byte-exact' >&2

build=$here/build
if [ $scan = 1 ]; then build=$build/scan_candidate
elif [ $integration = 1 ]; then build=$build/integration_candidate; fi
mkdir -p "$build/tmp"
export TMPDIR=$build/tmp

modules=(mod_core codeplug_reader firmware_zone_bridge)
[ $integration = 1 ] && modules+=(runtime_state menu_tables menu_filter zone_picker zone_picker_ui zone_picker_routing)
[ $scan = 1 ] && modules+=(scan_prepare scan_start_bridge scan_step_bridge scan_start_tail)
defines=()
[ $scan = 1 ] && defines+=(-DDM32_SCANNER_INTEGRATION)

objects=()
for m in "${modules[@]}"; do
    src=$here/source/$m.c
    [ $m = scan_start_tail ] && src=$here/source/scan_start_tail.S
    obj=$build/$m.o
    "$cc" -mcpu=ck803 -Os -ffreestanding -fno-builtin -fno-stack-protector -ffunction-sections -fdata-sections \
        -Wall -Wextra -Werror "${defines[@]}" -c "$src" -o "$obj"
    "$objdump" -dr "$obj" > "$build/$m.asm"
    "$objdump" -f "$obj" > "$build/$m.elf-info.txt"
    objects+=("$obj")
done
"$ld" -T "$here/source/staging_module.ld" -Map "$build/staging_module.map" --no-undefined -o "$build/staging_module.elf" "${objects[@]}"
"$objcopy" -O binary "$build/staging_module.elf" "$build/staging_module.raw"
"$objdump" -dr "$build/staging_module.elf" > "$build/staging_module.asm"
echo "BUILD COMPLETE: $build"
echo 'A standalone staging_module.raw was generated. It is NOT a complete radio firmware.'
echo 'No original firmware was changed and no radio connection was opened.'
