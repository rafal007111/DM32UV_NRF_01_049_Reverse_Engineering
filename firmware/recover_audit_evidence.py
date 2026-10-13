#!/usr/bin/env python3
"""Recover review evidence from pinned local images; never produce a firmware image."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

ROOT = Path(__file__).resolve().parent
INPUTS = ROOT.parent / "analysis/inputs"
STOCK = "de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0"
BASELINE = "568cb4e37a14104702c3c0deaa92f57086159fcddcfa3d5f53646db4aeecd819"
CURRENT = "156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53"
WRAPPER = "aff6b4dc09dcce45847173defba26e94157cc628af86826e21e5af227bdc52dd"
MODULE_BASE = 0x030DFCEC
FLASH = 0x03000000


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pinned(path, expected, size):
    data = path.read_bytes()
    require(len(data) == size and digest(data) == expected, f"Wrong input: {path.name}")
    return data


def symbols_from_elf(data):
    require(data[:6] == b"\x7fELF\x01\x01", "Expected ELF32 little endian")
    require(struct.unpack_from("<HH", data, 16) == (2, 252), "Expected C-SKY executable")
    offset = struct.unpack_from("<I", data, 32)[0]
    stride, count = struct.unpack_from("<HH", data, 46)
    sections = [struct.unpack_from("<10I", data, offset + i * stride) for i in range(count)]
    symbols = {}
    for section in sections:
        if section[1] != 2:
            continue
        strings_section = sections[section[6]]
        strings = data[strings_section[4]:strings_section[4] + strings_section[5]]
        for pos in range(section[4], section[4] + section[5], 16):
            name, value, size, info, other, index = struct.unpack_from("<IIIBBH", data, pos)
            label = strings[name:].split(b"\0")[0].decode("ascii")
            if index and info & 15 == 2 and label.startswith("dm32_"):
                symbols[value] = label
    return symbols


def branch_target(va, data):
    high, low = struct.unpack("<HH", data)
    require(high & 0xFC00 == 0xE000, f"Not a BSR at {va:08x}")
    half = ((high & 1023) << 16) | low
    if half & (1 << 25):
        half -= 1 << 26
    return va + half * 2


def delta(before, after):
    require(len(before) == len(after) == 0x100000, "Expected equal 1 MiB images")
    ranges, pos = [], 0
    replay = bytearray(before)
    while pos < len(before):
        if before[pos] == after[pos]:
            pos += 1
            continue
        start = pos
        while pos < len(before) and before[pos] != after[pos]:
            pos += 1
        entry = {"image_offset": start, "va": hex(FLASH + start), "length": pos - start,
                 "before": before[start:pos].hex(), "after": after[start:pos].hex()}
        require(replay[start:pos] == bytes.fromhex(entry["before"]), "Patch guard failed")
        replay[start:pos] = bytes.fromhex(entry["after"])
        ranges.append(entry)
    require(bytes(replay) == after, "Complete in-memory replay mismatch")
    sectors = {i // 4096 for i, (a, b) in enumerate(zip(before, after)) if a != b}
    return {"before_sha256": digest(before), "after_sha256": digest(after),
            "confidence": "code-verified", "meaning": "observed byte delta, not historical build provenance",
            "changed_bytes": sum(p["length"] for p in ranges), "changed_4k_chunks": len(sectors),
            "complete_in_memory_replay_verified": True, "patches": ranges}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, default=ROOT / "build/scan_candidate")
    parser.add_argument("--objdump", type=Path, required=True, help="T-HEAD C-SKY objdump 2.27 executable")
    parser.add_argument("--baseline", type=Path, help="optional exact 568cb4e3... image")
    parser.add_argument("--output", type=Path, default=ROOT, help="directory for recovered JSON evidence")
    args = parser.parse_args()
    stock_path = INPUTS / "stock_progmem_1MiB.bin"
    stock = pinned(stock_path, STOCK, 0x100000)
    current = pinned(INPUTS / "current_scan_tick_fix.progmem.bin", CURRENT, 0x100000)
    wrapper = pinned(INPUTS / "DM32_NRF_049_20251017.bin", WRAPPER, 873964)
    require(wrapper[256:] == stock[0xC000:0xE14EC], "Wrapper/stock mapping mismatch")
    module = (args.build / "staging_module.raw").read_bytes()
    require(0 < len(module) <= 0x1800, "Module outside reserved placement")
    require(module == current[0xDFCEC:0xDFCEC + len(module)], "Rebuilt module differs from installed image")
    require(stock[0xDFCEC:0xE14EC] == bytes(0x1800), "Stock module placement is not empty")
    symbols = symbols_from_elf((args.build / "staging_module.elf").read_bytes())
    tool = str(args.objdump.resolve())
    version = subprocess.check_output([tool, "--version"], text=True).splitlines()[0]
    require("2.27" in version, "Use the pinned T-HEAD 2.27 decoder; 2.47 has known partial decodes")
    command = [tool, "-D", "-b", "binary", "-m", "csky:ck803", "-EL",
               "--adjust-vma=0x03000000", "--start-address=0x0300c000",
               "--stop-address=0x03070600", str(stock_path)]
    disassembly = subprocess.check_output(command, text=True)
    decoded = {int(m[1], 16): int(m[2], 16) for line in disassembly.splitlines()
               if (m := re.search(r"^\s*([0-9a-f]+):.*\bbsr\s+0x([0-9a-f]+)", line))}
    provenance = {"confidence": "code-verified", "recovered": True,
                  "method": "pinned stock/current bytes, decoded stock BSR boundaries, byte-identical rebuilt module symbols",
                  "firmware_sha256": WRAPPER, "stock_image_sha256": STOCK,
                  "installed_image_sha256": CURRENT, "module_sha256": digest(module),
                  "tool_version": version, "objdump_sha256": digest(args.objdump.read_bytes()),
                  "hardware_test_performed": False}
    expected = {0x0302F418: "dm32_scan_start_bridge", 0x0302ECE8: "dm32_scan_step_bridge",
                0x0302ECA0: "dm32_scan_mode_bridge", 0x0302F59C: "dm32_scan_list_choice_bridge",
                0x03013078: "dm32_picker_key_read_bridge", 0x0304D07C: "dm32_picker_entry_bridge",
                0x0303B6AC: "dm32_picker_render_bridge", 0x0002E174: "dm32_runtime_boot",
                0x03049498: "dm32_menu_filter_bridge", 0x03018D78: "dm32_scan_list_tick_bridge"}
    sites = []
    for va, old_target in sorted(decoded.items()):
        off = va - FLASH
        before, after = stock[off:off + 4], current[off:off + 4]
        if before == after:
            continue
        require(branch_target(va, before) == old_target, "Decoder/encoding disagreement")
        target = branch_target(va, after)
        require(MODULE_BASE <= target < MODULE_BASE + len(module), "Changed call outside module")
        name = symbols.get(target)
        require(name is not None and expected.get(old_target) == name, f"Unmapped hook at {va:08x}")
        sites.append({"va": hex(va), "raw_offset": off - 0xC000 + 256,
                      "image_offset": off, "region": "flash text", "original_target": hex(old_target),
                      "replacement_symbol": name, "installed_target": hex(target),
                      "before": before.hex(), "after": after.hex(),
                      "role": f"observed installed call redirect to {name}"})
    tables = []
    for category, desc, count in [("scan", 0x030B90A8, 9), ("other", 0x030B9700, 22)]:
        for language, slot in [("cn", 0), ("en", 1)]:
            ptr, n, kind, reserved = struct.unpack_from("<IBBH", stock, desc - FLASH + 8 * slot)
            require((n, kind, reserved) == (count, 2, 0), "Stock menu descriptor mismatch")
            pointers = struct.unpack_from(f"<{count}I", stock, ptr - FLASH)
            tables.append({"name": category + "_" + language, "descriptor_va": hex(desc + 8 * slot),
                           "table_va": hex(ptr), "count": count, "pointers": [hex(p) for p in pointers]})
    reports = {"menu_tables_audit.json": {**provenance, "stock_tables": tables}}
    for filename, prefix in [("picker_routing_audit.json", "dm32_picker_"),
                             ("scan_start_hooks_audit.json", "dm32_scan_")]:
        selected = [s for s in sites if s["replacement_symbol"].startswith(prefix)
                    and s["replacement_symbol"] != "dm32_scan_list_tick_bridge"]
        require(bool(selected), "No recovered hooks")
        reports[filename] = {**provenance, "sites": selected}
    baseline = pinned(args.baseline, BASELINE, 0x100000) if args.baseline else None
    chain = [delta(stock, baseline), delta(baseline, current)] if baseline else [
        {"before_sha256": STOCK, "after_sha256": BASELINE, "status": "unresolved: baseline image unavailable"},
        {"before_sha256": BASELINE, "after_sha256": CURRENT, "status": "install-record only; patch bytes unavailable"}]
    require(stock[:0xC000] == current[:0xC000], "Boot prefix changed")
    require(struct.unpack_from("<I", stock, 0x705A4)[0] == 0x4BFE0, "Stock heap guard")
    require(struct.unpack_from("<I", current, 0x705A4)[0] == 0x4BFC0, "Installed heap guard")
    require(any(s["va"] == "0x300c074" and s["replacement_symbol"] == "dm32_runtime_boot" for s in sites), "Startup hook missing")
    reports["image_provenance_audit.json"] = {**provenance,
        "status": "REVIEW ONLY - NO IMAGE PRODUCED", "flashable": False,
        "historical_chain_complete": baseline is not None, "historical_chain": chain,
        "direct_stock_to_installed": delta(stock, current), "observed_installed_calls": sites,
        "boot_prefix_0xc000_unchanged": True, "module_matches_installed": True,
        "module_base": hex(MODULE_BASE), "module_bytes": len(module),
        "heap_end_before": "0x4bfe0", "heap_end_after": "0x4bfc0",
        "limitations": ["Original installer/build tool and intermediate-image creation recipe are unavailable.",
                        "Byte replay is not a complete integration safety or hardware audit.",
                        "TS/CC receive integration remains incomplete."]}
    args.output.mkdir(parents=True, exist_ok=True)
    for filename, report in reports.items():
        (args.output / filename).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Recovered {len(sites)} installed calls, 62 menu pointers and full guarded stock/current delta.")
    print("Historical baseline: " + ("verified" if baseline else "unavailable; gap retained explicitly"))


if __name__ == "__main__":
    main()
