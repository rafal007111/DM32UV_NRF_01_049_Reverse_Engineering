#!/usr/bin/env python3
"""Build and run host-only tests. Never links target assembly or accesses a radio."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
# Explicit source/define lists keep firmware absolute addresses behind test mocks.
TESTS = {
    "mod_core": (["mod_core"], []),
    "codeplug_boundaries": (["codeplug_reader", "mod_core"], []),
    "menu_filter": (["menu_filter", "menu_tables"], ["DM32_MENU_FILTER_TEST"]),
    "runtime_state": (["runtime_state", "mod_core"], ["DM32_RUNTIME_TEST"]),
    "zone_picker": (["zone_picker", "mod_core"], []),
    "scan_prepare": (["scan_prepare", "mod_core"], []),
    "picker_routing": (["zone_picker_routing", "runtime_state", "mod_core"],
                       ["DM32_PICKER_ROUTING_TEST", "DM32_RUNTIME_TEST"]),
    "zone_picker_ui": (["zone_picker_ui", "zone_picker", "runtime_state", "mod_core",
                        "codeplug_reader", "firmware_zone_bridge"],
                       ["DM32_PICKER_UI_TEST", "DM32_RUNTIME_TEST", "DM32_BRIDGE_TEST"]),
    "scan_start_bridge": (["scan_start_bridge", "scan_prepare", "runtime_state", "mod_core"],
                          ["DM32_SCAN_START_TEST", "DM32_RUNTIME_TEST"]),
    "scan_step_bridge": (["scan_step_bridge", "runtime_state", "mod_core"],
                         ["DM32_SCAN_STEP_TEST", "DM32_RUNTIME_TEST"]),
    "mod_core_real": (["mod_core", "codeplug_reader", "firmware_zone_bridge"],
                      ["DM32_BRIDGE_TEST"]),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cc", default=os.environ.get("CC"), help="host compiler executable (gcc, clang or cl)")
    parser.add_argument("--test", choices=TESTS, action="append", help="run only this test; repeatable")
    args = parser.parse_args()
    compiler = args.cc or next((shutil.which(c) for c in ("cc", "gcc", "clang", "cl") if shutil.which(c)), None)
    if not compiler:
        parser.error("No host compiler. Use a VS Developer shell or --cc /path/to/gcc or clang.")
    msvc = Path(compiler).stem.lower() in ("cl", "clang-cl")
    build = ROOT / "build" / "host_tests"
    build.mkdir(parents=True, exist_ok=True)
    failed, passed, skipped = [], [], []
    for name in args.test or TESTS:
        if name == "mod_core_real" and not os.environ.get("DM32_TEST_CODEPLUG"):
            print("SKIP mod_core_real: DM32_TEST_CODEPLUG is unset", flush=True)
            skipped.append(name)
            continue
        modules, defines = TESTS[name]
        sources = [ROOT / "tests" / f"test_{name}.c"] + [ROOT / "source" / f"{m}.c" for m in modules]
        exe = build / (name + (".exe" if os.name == "nt" else ""))
        if msvc:
            flags = ["/nologo", "/W4", "/std:c11", "/UNDEBUG", "/D_CRT_SECURE_NO_WARNINGS",
                     f"/I{ROOT / 'source'}", f"/Fe:{exe}"] + [f"/D{d}" for d in defines]
        else:
            flags = ["-std=c11", "-Wall", "-Wextra", "-UNDEBUG", "-I", str(ROOT / "source"),
                     "-o", str(exe)] + [f"-D{d}" for d in defines]
        command = [compiler, *flags, *map(str, sources)]
        print(f"BUILD {name}: {subprocess.list2cmdline(command)}", flush=True)
        result = subprocess.run(command, cwd=build)
        if result.returncode:
            failed.append(name + " (compile)")
            continue
        try:
            result = subprocess.run([str(exe)], cwd=build, timeout=60)
            if result.returncode == 77:
                skipped.append(name)
            elif result.returncode:
                failed.append(name + f" (exit {result.returncode})")
            else:
                passed.append(name)
        except subprocess.TimeoutExpired:
            failed.append(name + " (timeout)")
    print(f"RESULT: {len(passed)} passed, {len(skipped)} skipped, {len(failed)} failed")
    for failure in failed:
        print("FAIL " + failure)
    return bool(failed)


if __name__ == "__main__":
    sys.exit(main())
