"""Read-only ELF/raw consistency and stock menu pointer audit. No firmware writes."""
from pathlib import Path
import sys, struct, hashlib, json
if sys.flags.optimize:
    raise SystemExit('Run without -O: this legacy audit requires assertions.')

root = Path(__file__).resolve().parent
build = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else root / 'build/integration_candidate'
elf = (build / 'staging_module.elf').read_bytes()
raw = (build / 'staging_module.raw').read_bytes()
assert elf[:6] == b'\x7fELF\x01\x01', 'Expected ELF32 little endian'
assert struct.unpack_from('<HH', elf, 16) == (2, 252), 'Expected linked C-SKY executable'
linked_flags = struct.unpack_from('<I', elf, 36)[0]
assert linked_flags == 0x21000000, 'Unexpected linked ELF flags'
object_flags = {}
modules = ['mod_core', 'codeplug_reader', 'firmware_zone_bridge', 'runtime_state', 'menu_tables', 'menu_filter']
if any((build / (name+'.o')).exists() for name in ('zone_picker','zone_picker_ui')):
    modules += ['zone_picker','zone_picker_ui']
if (build / 'zone_picker_routing.o').exists(): modules += ['zone_picker_routing']
if any((build / (name+'.o')).exists() for name in ('scan_prepare','scan_start_bridge','scan_step_bridge','scan_start_tail')):
    modules += ['scan_prepare','scan_start_bridge','scan_step_bridge','scan_start_tail']
for module in modules:
    obj = (build / (module+'.o')).read_bytes()
    flags = struct.unpack_from('<I', obj, 36)[0]
    assert obj[:6] == b'\x7fELF\x01\x01' and flags == 0x21000009
    assert struct.unpack_from('<HH', obj, 16) == (1, 252)
    object_flags[module] = hex(flags)
table = struct.unpack_from('<I', elf, 32)[0]
stride, count, names = struct.unpack_from('<HHH', elf, 46)
sections = [struct.unpack_from('<10I', elf, table + i * stride) for i in range(count)]
ns = sections[names]
name_bytes = elf[ns[4]:ns[4]+ns[5]]
section_name = lambda s: name_bytes[s[0]:].split(b'\0')[0].decode('ascii')
allocated = []
for s in sections:
    if s[2] & 2 and s[5]:
        assert s[1] == 1 and not (s[2] & 1), 'Unexpected writable/NOBITS allocation'
        allocated.append({'section': section_name(s), 'address': s[3], 'bytes': s[5], 'flags': s[2]})
base = min(s['address'] for s in allocated)
assert base == 0x030dfcec and len(raw) <= 0x1800
assert max(s['address'] + s['bytes'] for s in allocated) - base == len(raw)
for s in sections:
    if s[2] & 2 and s[5]:
        assert raw[s[3]-base:s[3]-base+s[5]] == elf[s[4]:s[4]+s[5]]
symbols, functions, undefined = {}, {}, []
for s in sections:
    if s[1] != 2: continue
    st = sections[s[6]]
    strings = elf[st[4]:st[4]+st[5]]
    for i in range(s[5] // 16):
        name, value, size, info, other, section = struct.unpack_from('<IIIBBH', elf, s[4]+i*16)
        label = strings[name:].split(b'\0')[0].decode('ascii')
        if label and not section: undefined.append(label)
        if label and section:
            symbols[label] = value
            if info & 15 == 2: functions[label] = value
assert not undefined, undefined
if 'dm32_zone_start_tail' in symbols:
    tail_offset = symbols['dm32_zone_start_tail'] - base
    assert raw[tail_offset:tail_offset+16] == bytes.fromhex('d3 14 2d 14 03 6d 62 10 0c 78 00 00 98 f4 02 03'), 'Unexpected stock-frame shim'
    assert symbols['dm32_zone_start_tail'] % 4 == 0, 'Shim pool alignment'
payload = (root.parent / 'analysis/inputs/DM32.NRF.01.049.payload.bin').read_bytes()
assert hashlib.sha256(payload).hexdigest() == '3711be95c10975c8f33073ad7a0b3c4d815e301bbcd389a4bd7ff7a0114acc63', 'Wrong NRF 01.049 payload'
assert payload[base-0x0300c000:base-0x0300c000+0x1800] == bytes(0x1800)
word = lambda a: struct.unpack_from('<I', raw, a-base)[0]
menu_audit = json.loads((root / 'menu_tables_audit.json').read_text(encoding='utf-8-sig'))
assert menu_audit['stock_image_sha256'] == 'de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0'
for category, symbol, new_count in [('scan', 'dm32_scan_menu_candidate', 10), ('other', 'dm32_other_menu_candidate', 24)]:
    descriptor = symbols[symbol]
    for language, slot in [('cn', 0), ('en', 1)]:
        ptr, count, kind, reserved = struct.unpack_from('<IBBH', raw, descriptor-base+8*slot)
        assert (count, kind, reserved) == (new_count, 2, 0)
        old = next(t for t in menu_audit['stock_tables'] if t['name'] == category+'_'+language)
        assert old['count'] == len(old['pointers']) == new_count-len(['Scan Zone'] if category == 'scan' else ['TS Match', 'CC Match'])
        stock_offset = int(old['table_va'], 16) - 0x0300c000
        assert list(struct.unpack_from('<' + str(old['count']) + 'I', payload, stock_offset)) == [int(p,16) for p in old['pointers']]
        for i, expected in enumerate(old['pointers']): assert word(ptr+4*i) == int(expected, 16)
        expected_labels = ['Scan Zone'] if category == 'scan' else ['TS Match', 'CC Match']
        for i, label in enumerate(expected_labels, old['count']):
            p = word(ptr + 4*i)
            assert base <= p < base+len(raw)
            assert raw[p-base:].split(b'\0')[0].decode('ascii') == label
report = {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(),
          'linked_elf_flags': hex(linked_flags), 'object_elf_flags': object_flags,
          'allocated_sections': allocated, 'functions': {k:hex(v) for k,v in functions.items()},
          'symbols': {k:hex(v) for k,v in symbols.items() if k.startswith('dm32_')},
          'undefined_symbols': undefined, 'menu_old_pointers_verified': 62,
          'firmware_modified': False, 'device_tested': False}
(build / 'integration_audit.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
(build / 'integration_entries.tsv').write_text(''.join(f'{a:08x}\t{n}\n' for n,a in functions.items()), encoding='ascii')
print(f'Module verified: {len(raw)} bytes, {len(functions)} functions, 62 original menu pointers; no firmware changed.')
