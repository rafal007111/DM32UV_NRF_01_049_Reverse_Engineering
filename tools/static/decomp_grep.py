#!/usr/bin/env python3
"""Grep an ExportDM32 decompiled.c (optionally resolved) and prefix each hit with its function.

    python3 -I tools/static/decomp_grep.py 'FUN_0300c724\(2\)' dec.c
"""
import re
import sys

if len(sys.argv) != 3:
    sys.exit(__doc__)
pat = re.compile(sys.argv[1])
fn = '?'
for line in open(sys.argv[2], encoding='utf-8'):
    m = re.match(r'/\* Address: (\w+);', line)
    if m:
        fn = m.group(1)
    elif pat.search(line):
        print(fn + ': ' + line.strip())
