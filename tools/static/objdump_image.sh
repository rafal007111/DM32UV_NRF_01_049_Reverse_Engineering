#!/usr/bin/env bash
# Disassemble the DM32 stock program image with GNU binutils for csky-elfabiv2 (read-only).
# `objdump -b binary` does not decode 32-bit C-SKY instructions (prints `.long`), so the raw
# flash and IRAM regions are wrapped in an ELF with `.incbin` first.
#   source /opt/dm32-tools.env
#   tools/static/objdump_image.sh analysis/inputs/stock_progmem_1MiB.bin OUTDIR
# Produces OUTDIR/flash.asm (VA 0300C000..) and OUTDIR/iram.asm (VA 00010000.., source 030C0C38).
set -euo pipefail
img=$1; out=$2
mkdir -p "$out"
python3 -I - "$img" "$out" <<'PY'
import sys
d = open(sys.argv[1], 'rb').read()
open(sys.argv[2] + '/flash.bin', 'wb').write(d[0xC000:])
open(sys.argv[2] + '/iram.bin', 'wb').write(d[0xC0C38:0xC0C38 + 0x20000])
PY
for pair in flash:0x0300C000 iram:0x00010000; do
    f=${pair%%:*}; va=${pair#*:}
    printf '.section .text\n.incbin "%s/%s.bin"\n' "$out" "$f" > "$out/$f.s"
    csky-elfabiv2-as -mcpu=ck803 "$out/$f.s" -o "$out/$f.o"
    csky-elfabiv2-ld -e 0 -Ttext="$va" "$out/$f.o" -o "$out/$f.elf"
    csky-elfabiv2-objdump -d "$out/$f.elf" | sed 's/\s*\/\/ \([0-9a-f]*\) <[^>]*>/ \/\/ \1/' > "$out/$f.asm"
done
