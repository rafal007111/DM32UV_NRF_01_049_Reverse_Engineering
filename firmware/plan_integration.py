"""Generate a REVIEW-ONLY patch manifest. Intentionally has no image-writing mode."""
from pathlib import Path
import argparse, struct, hashlib, json, sys
if sys.flags.optimize:
    raise SystemExit('Run without -O: patch guards require assertions.')

root = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('build', nargs='?', type=Path, default=root / 'build/integration_candidate')
parser.add_argument('--profile', choices=('candidate', 'installed-reference'), default='candidate')
args = parser.parse_args()
build = args.build.resolve()
module = (build / 'staging_module.raw').read_bytes()
audit = json.loads((build / 'integration_audit.json').read_text())
assert hashlib.sha256(module).hexdigest() == audit['sha256']
project = root.parent
original = (project / 'analysis/inputs/DM32_NRF_049_20251017.bin').read_bytes()
expected = 'aff6b4dc09dcce45847173defba26e94157cc628af86826e21e5af227bdc52dd'
assert hashlib.sha256(original).hexdigest() == expected
payload = original[256:]
assert payload == (project / 'analysis/inputs/DM32.NRF.01.049.payload.bin').read_bytes()
symbols = {k:int(v,16) for k,v in audit['symbols'].items()}
base = 0x030dfcec
assert 0 < len(module) <= 0x1800
patches = []

def add(va, before, after, purpose):
    offset = va - 0x0300c000 + 256
    assert len(before) == len(after)
    assert original[offset:offset+len(before)] == before
    assert not any(offset < p['raw_offset']+p['length'] and p['raw_offset'] < offset+len(before) for p in patches)
    patches.append({'va':hex(va), 'raw_offset':offset, 'length':len(before),
                    'before':before.hex(' '), 'after':after.hex(' '), 'purpose':purpose})

def bsr_target(va, data):
    high, low = struct.unpack('<HH', data)
    assert high & 0xfc00 == 0xe000
    half = ((high & 1023) << 16) | low
    if half & (1 << 25): half -= 1 << 26
    return va + 2*half

def call(va, old_target, new_target, purpose):
    offset = va - 0x0300c000 + 256
    before = original[offset:offset+4]
    assert bsr_target(va, before) == old_target
    distance = new_target-va
    assert distance % 2 == 0 and -(1 << 26) <= distance < (1 << 26)
    half = (distance//2) & 0x3ffffff
    after = struct.pack('<HH', 0xe000 | (half >> 16), half & 65535)
    assert bsr_target(va, after) == new_target
    add(va, before, after, purpose)

add(base, bytes(len(module)), module, 'candidate code and label arrays; final placement review required')
add(0x030705a4, struct.pack('<I', 0x4bfe0), struct.pack('<I', 0x4bfc0), 'reserve 32 bytes from end of stock heap')
call(0x0300c074, 0x0002e174, symbols['dm32_runtime_boot'], 'initialize reserved state then call original RTOS entry')
for va, symbol, table_cn, table_en, count in [
    (0x030b90a8,'dm32_scan_menu_candidate',0x030b9060,0x030b9084,9),
    (0x030b9700,'dm32_other_menu_candidate',0x030b9650,0x030b96a8,22),
]:
    if args.profile == 'installed-reference' and symbol == 'dm32_other_menu_candidate': continue
    before = struct.pack('<IIII', table_cn, 0x200+count, table_en, 0x200+count)
    source = symbols[symbol]-base
    add(va, before, module[source:source+16], 'replace descriptor contents in place; existing descriptor references retained')
for va in (0x0303da62, 0x0303e4e2, 0x0303e24c):
    if args.profile == 'installed-reference' and va == 0x0303e24c: continue
    call(va, 0x03049498, symbols['dm32_menu_filter_bridge'], 'stock menu filtering plus new rows for verified main map')
picker_symbols = {'dm32_picker_key_read_bridge','dm32_picker_entry_bridge','dm32_picker_render_bridge'}
picker_included = picker_symbols.issubset(symbols)
if picker_included:
    routing = json.loads((root / 'picker_routing_audit.json').read_text())
    assert routing['firmware_sha256'] == expected
    for site in routing['sites']:
        offset = int(site['va'],16)-0x0300c000+256
        assert original[offset:offset+4] == bytes.fromhex(site['before'])
        call(int(site['va'],16), int(site['original_target'],16),
             symbols[site['replacement_symbol']], site['role'])
scan_symbols = {'dm32_scan_start_bridge','dm32_scan_step_bridge','dm32_scan_mode_bridge','dm32_scan_list_choice_bridge','dm32_zone_start_tail'}
scan_included = scan_symbols.issubset(symbols)
if scan_included:
    scanner = json.loads((root/'scan_start_hooks_audit.json').read_text())
    assert scanner['firmware_sha256'] == expected
    for site in scanner['sites']:
        assert site['region'] == 'flash text', 'IRAM call requires a separate relocation-aware review'
        va = int(site['va'],16)
        assert site['raw_offset'] == va-0x0300c000+256
        assert original[site['raw_offset']:site['raw_offset']+4] == bytes.fromhex(site['before'])
        call(va,int(site['original_target'],16),symbols[site['replacement_symbol']], 'scanner candidate: '+site['replacement_symbol'])
    if 'dm32_scan_list_tick_bridge' in symbols:
        for va in (0x0302e8c6, 0x0302e952):
            call(va,0x03018d78,symbols['dm32_scan_list_tick_bridge'],'native Scan List tick suppression')
report = {'status':'REVIEW ONLY - INCOMPLETE - NO IMAGE PRODUCED', 'flashable':False,
          'original_sha256':expected, 'module_sha256':audit['sha256'], 'patches':patches,
          'picker_event_routing_included':picker_included,
          'scanner_routing_included':scan_included,
          'missing':['TS/CC menu selection handlers and submenus',
                     'CC and TS receive integration', 'persistent settings mapping', 'on-device validation'],
          'firmware_modified':False}
report['profile'] = args.profile
if args.profile == 'installed-reference':
    assert picker_included and scan_included, 'Installed reference requires the complete scanner module'
    stock = (project / 'analysis/inputs/stock_progmem_1MiB.bin').read_bytes()
    installed = (project / 'analysis/inputs/current_scan_tick_fix.progmem.bin').read_bytes()
    assert len(stock) == len(installed) == 0x100000
    assert hashlib.sha256(stock).hexdigest() == 'de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0'
    expected_installed = '156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53'
    assert hashlib.sha256(installed).hexdigest() == expected_installed
    assert stock[0xc000:0xe14ec] == payload
    replay = bytearray(stock)
    for patch in patches:
        offset = int(patch['va'],16)-0x03000000
        before, after = bytes.fromhex(patch['before']), bytes.fromhex(patch['after'])
        assert replay[offset:offset+len(before)] == before
        replay[offset:offset+len(after)] = after
    assert replay[:0xc000] == stock[:0xc000]
    assert bytes(replay) == installed, 'Full source/module/patch replay differs from installed reference'
    report['status'] = 'REVIEW ONLY - INSTALLED REFERENCE REPLAY VERIFIED - NO IMAGE PRODUCED'
    report['replayed_image_sha256'] = hashlib.sha256(replay).hexdigest()
    provenance = json.loads((root / 'image_provenance_audit.json').read_text(encoding='utf-8'))
    report['historical_intermediate_baseline_recovered'] = provenance.get('historical_chain_complete', False)
    report['missing'].append('Independent verification of historical build/installer provenance')
if not picker_included: report['missing'].insert(0,'Scan Zone picker event routing/native build')
if not scan_included: report['missing'].insert(0,'Scan Zone start/iteration/stop integration')
filename = 'installed_reference_patch_plan.json' if args.profile == 'installed-reference' else 'integration_patch_plan.json'
(build / filename).write_text(json.dumps(report,indent=2),encoding='utf-8')
print(f'Review-only plan: {len(patches)} guarded changes; no firmware image created.')
