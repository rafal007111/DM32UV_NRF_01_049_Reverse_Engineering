#!/usr/bin/env python3
"""Register-tracking RAM access scan over flash.asm/iram.asm (read-only).

Within every catalogued function (plus the task entries below) it propagates lrw/mov/addi/subi values and reports
ld/st whose base register + offset falls in [LO, HI], and ldr/str whose base or index register was loaded with an
address in [LO-0x40, HI].  A heuristic: values passed through memory or across branches are not tracked.

    tools/static/objdump_image.sh analysis/inputs/stock_progmem_1MiB.bin $ASM
    python3 -I tools/static/ram_scan.py $ASM 3bebd 3becb
"""
import re,sys,csv,bisect,os

ASM=sys.argv[1]; LO=int(sys.argv[2],16); HI=int(sys.argv[3],16)
REPO=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
funcs=[]
for row in csv.reader(open(os.path.join(REPO,'analysis/decompiled_modules/function_catalog.csv'),encoding='utf-8-sig')):
    if row and re.fullmatch(r'[0-9a-f]{8}',row[0]): funcs.append(int(row[0],16))
funcs += [0x030206d0,0x030209e4,0x0301ff9c,0x0301fdd8,0x0305f234,0x0302b340,0x0002c458,0x0002d770,0x0002d620,0x0302386c,0x030293c8]
funcs=sorted(set(funcs))
lines=[]
for f in ('flash','iram'):
    for l in open(f'{ASM}/{f}.asm'):
        m=re.match(r'\s*([0-9a-f]+):\s+[0-9a-f]+\s+(\S+)\s*(.*)',l)
        if m: lines.append((int(m.group(1),16),m.group(2),m.group(3)))
lines.sort(); addrs=[a for a,_,_ in lines]
for i,fs in enumerate(funcs):
    fe=funcs[i+1] if i+1<len(funcs) else fs+0x4000
    seg=lines[bisect.bisect_left(addrs,fs):bisect.bisect_left(addrs,fe)]
    reg={}
    for a,mn,op in seg:
        ops=[x.strip() for x in op.split('//')[0].split(',')]
        if mn=='lrw':
            m=re.search(r'0x([0-9a-f]+)',op); reg[ops[0]]=int(m.group(1),16) if m else None; continue
        if mn=='mov' and len(ops)==2:
            reg[ops[0]]=reg.get(ops[1]); continue
        if mn in ('addi','subi') and len(ops)==3 and ops[1] in reg and reg[ops[1]] is not None:
            try: v=int(ops[2],0)
            except: v=None
            reg[ops[0]]=None if v is None else reg[ops[1]]+(v if mn=='addi' else -v); continue
        m=re.match(r'(ld|st)\.([bhw])$',mn)
        if m:
            mo=re.search(r'\((r\d+), 0x([0-9a-f]+)\)',op)
            if mo and reg.get(mo.group(1)) is not None:
                t=reg[mo.group(1)]+int(mo.group(2),16)
                if LO<=t<=HI: print('%08x %08x %-7s %-28s -> %x'%(fs,a,mn,op.split('//')[0],t))
            if m.group(1)=='ld' and ops: reg[ops[0]]=None
            continue
        if mn.startswith(('ldr','str')):
            mo=re.search(r'\((r\d+), (r\d+)',op)
            if mo:
                for r in mo.groups():
                    v=reg.get(r)
                    if v is not None and LO-0x40<=v<=HI: print('%08x %08x %-7s %-28s indexed base %x'%(fs,a,mn,op.split('//')[0],v))
        if ops and re.fullmatch(r'r\d+',ops[0]) and not mn.startswith(('st','cmp','b','j','tst','btst','push','pop')):
            reg[ops[0]]=None
