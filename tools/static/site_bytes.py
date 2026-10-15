#!/usr/bin/env python3
"""Print stock bytes (image order) at VA:len sites and whether the installed image has the same bytes (read-only).

    python3 -I tools/static/site_bytes.py analysis/inputs/stock_progmem_1MiB.bin \
        analysis/inputs/current_scan_tick_fix.progmem.bin 03028708:16 030207aa:4
Flash VA >= 0x03000000 maps to offset VA-0x03000000; IRAM VA maps to 0xC0C38 + VA-0x10000.
"""
import sys
st=open(sys.argv[1],'rb').read(); ins=open(sys.argv[2],'rb').read()
for arg in sys.argv[3:]:
    va,n=arg.split(':'); va=int(va,16); n=int(n)
    o=va-0x03000000 if va>=0x03000000 else va-0x10000+0xC0C38
    a=st[o:o+n]; b=ins[o:o+n]
    print('%08x %-48s %s'%(va,' '.join('%02x'%x for x in a),'same' if a==b else 'DIFF'))
