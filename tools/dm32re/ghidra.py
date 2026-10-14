"""Headless Ghidra decompilation from the checked-in GZF (read-only project under build/dm32re/ghidra).

The project is created once by importing analysis/archives/DM32_NRF_049_correct_base.gzf with
-noanalysis; every later run uses -process -noanalysis -readOnly, so the database never changes.
Output is cached per function under build/dm32re/decomp/<addr>.c. Decompiler output is evidence,
not source: types, boundaries and control flow may be wrong (AGENTS.md).
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from .image import BUILD, REPO

GZF = REPO / "analysis" / "archives" / "DM32_NRF_049_correct_base.gzf"
PROJECT_DIR = BUILD / "ghidra"
PROJECT = "dm32"
PROGRAM = "DM32_NRF_049_correct_base"
CACHE = BUILD / "decomp"
SCRIPTS = Path(__file__).resolve().parent / "ghidra_scripts"


def headless() -> str:
    home = os.environ.get("GHIDRA_INSTALL_DIR", "/opt/ghidra_12.1.4_PUBLIC")
    exe = Path(home) / "support" / "analyzeHeadless"
    if exe.exists():
        return str(exe)
    found = shutil.which("analyzeHeadless")
    if not found:
        raise FileNotFoundError("analyzeHeadless not found; run tools/setup_cloud.sh and source /opt/dm32-tools.env")
    return found


def _env() -> dict:
    env = dict(os.environ)
    env.setdefault("JAVA_HOME", "/usr/lib/jvm/java-25-openjdk-amd64")
    return env


def ensure_project() -> None:
    if (PROJECT_DIR / f"{PROJECT}.gpr").exists():
        return
    PROJECT_DIR.mkdir(parents=True, exist_ok=True)
    subprocess.run([headless(), str(PROJECT_DIR), PROJECT, "-import", str(GZF), "-noanalysis"],
                   check=True, capture_output=True, env=_env())


def decompile(addrs: list[int] | None, refresh: bool = False, timeout: int = 3600) -> dict[int, str]:
    """address -> C. addrs=None decompiles every function in the database."""
    CACHE.mkdir(parents=True, exist_ok=True)
    out: dict[int, str] = {}
    todo = []
    for a in addrs or []:
        p = CACHE / f"{a:08x}.c"
        if p.exists() and not refresh:
            out[a] = p.read_text(encoding="utf-8")
        else:
            todo.append(a)
    if addrs is not None and not todo:
        return out
    ensure_project()
    with tempfile.TemporaryDirectory(prefix="dm32decomp-") as tmp:
        jsonl = Path(tmp) / "out.jsonl"
        args = ["all"] if addrs is None else [f"{a:x}" for a in todo]
        cmd = [headless(), str(PROJECT_DIR), PROJECT, "-process", PROGRAM, "-noanalysis", "-readOnly",
               "-scriptPath", str(SCRIPTS), "-postScript", "Dm32DecompJson.java", str(jsonl), *args]
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, env=_env())
        if not jsonl.exists():
            raise RuntimeError("Ghidra produced no output:\n" + r.stdout[-3000:] + r.stderr[-2000:])
        for line in jsonl.read_text(encoding="utf-8").splitlines():
            row = json.loads(line)
            a = int(row["addr"], 16)
            text = (f"/* {row['name']} @ {a:08X}{' (temporary function, not in the GZF)' if row['temp'] else ''}"
                    f" -- Ghidra decompiler output, unreviewed */\n" + row["c"])
            (CACHE / f"{a:08x}.c").write_text(text, encoding="utf-8")
            out[a] = text
    return out
