#!/usr/bin/env python3
"""Replace Ghidra PTR_DAT_/PTR_FUN_ literal-pool names in a decompiler export with their values.

Read-only helper for DM32.NRF.01.049 static analysis. Reads the 1 MiB stock program image
(flash offset = VA - 0x03000000; IRAM 0x00010000.. is copied from flash offset 0xC0C38).

    python3 -I tools/static/resolve_ptr_literals.py IMAGE decompiled.c dec.c

PTR_DAT_0302836c -> [3bea8] (the 32-bit word stored at 0302836c), PTR_FUN_x -> &FUN_<value>.
Names whose address is outside flash/IRAM are left unchanged.
"""
import re
import struct
import sys

IRAM_VA, IRAM_SRC, IRAM_LEN = 0x10000, 0xC0C38, 0x20000


def main(image_path, src_path, out_path):
    img = open(image_path, 'rb').read()

    def word(va):
        if 0x03000000 <= va < 0x03000000 + len(img):
            off = va - 0x03000000
        elif IRAM_VA <= va < IRAM_VA + IRAM_LEN:
            off = IRAM_SRC + va - IRAM_VA
        else:
            return None
        return struct.unpack_from('<I', img, off)[0]

    def dat(m):
        v = word(int(m.group(1), 16))
        return m.group(0) if v is None else '[%x]' % v

    def fun(m):
        v = word(int(m.group(1), 16))
        return m.group(0) if v is None else '&FUN_%08x' % (v & ~1)

    text = open(src_path, encoding='utf-8').read()
    text = re.sub(r'PTR_DAT_([0-9a-f]{8})', dat, text)
    text = re.sub(r'PTR_FUN_([0-9a-f]{8})', fun, text)
    open(out_path, 'w', encoding='utf-8').write(text)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
