"""Program image loading and address mapping.

Stock layout (code-verified from the startup header, see PrepareCSKY.java):
- flash: VA 03000000 + offset in the 1 MiB program image; application starts at 0300C000;
- IRAM runtime: copied from flash header word +0xD8 to [+0xD0, +0xD4) (stock: 030C0C38 -> 00010000..0002F0B4);
- SRAM initialized data: copied from +0xCC to [+0xC4, +0xC8) (stock: 030727D0 -> 18000800..18004C04).
"""

from __future__ import annotations

import hashlib
import struct
from dataclasses import dataclass
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
INPUTS = REPO / "analysis" / "inputs"
BUILD = REPO / "build" / "dm32re"  # ignored by .gitignore (build/)

FLASH_BASE = 0x03000000
APP_BASE = 0x0300C000
KNOWN_IMAGES = {
    "stock": ("stock_progmem_1MiB.bin", "de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0"),
    "installed": ("current_scan_tick_fix.progmem.bin",
                  "156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53"),
}


class ImageError(Exception):
    pass


@dataclass(frozen=True)
class Region:
    name: str
    va: int  # first address
    end: int  # one past the last address
    file_off: int  # where the bytes live in the program image
    code: bool

    def __contains__(self, va: int) -> bool:
        return self.va <= va < self.end


class Image:
    """A verified 1 MiB program image with its flash, IRAM and SRAM views."""

    def __init__(self, which: str = "stock", path: Path | None = None, verify: bool = True):
        name, digest = KNOWN_IMAGES[which]
        self.which = which
        self.path = path or INPUTS / name
        if not self.path.exists():
            raise ImageError(f"{self.path} is missing (private input, not in a fresh clone)")
        self.data = self.path.read_bytes()
        self.sha256 = hashlib.sha256(self.data).hexdigest()
        if verify and self.sha256 != digest:
            raise ImageError(f"{self.path.name}: SHA-256 {self.sha256} != expected {digest}")
        hdr = APP_BASE - FLASH_BASE
        w = lambda o: struct.unpack_from("<I", self.data, hdr + o)[0]
        iram_dst, iram_end, iram_src = w(0xD0), w(0xD4), w(0xD8)
        sram_dst, sram_end, sram_src = w(0xC4), w(0xC8), w(0xCC)
        used = len(self.data.rstrip(b"\xff"))
        self.regions = [
            Region("IRAM", iram_dst, iram_end, iram_src - FLASH_BASE, True),
            Region("SRAM_init", sram_dst, sram_end, sram_src - FLASH_BASE, False),
            Region("FLASH", APP_BASE, FLASH_BASE + used, APP_BASE - FLASH_BASE, True),
        ]

    def region(self, va: int) -> Region | None:
        return next((r for r in self.regions if va in r), None)

    def read(self, va: int, n: int) -> bytes:
        r = self.region(va)
        if r is None or va + n > r.end:
            raise ImageError(f"{va:08X}+{n} is not inside a loaded region")
        off = r.file_off + va - r.va
        return self.data[off:off + n]

    def u32(self, va: int) -> int:
        return struct.unpack("<I", self.read(va, 4))[0]

    def u16(self, va: int) -> int:
        return struct.unpack("<H", self.read(va, 2))[0]

    def cstring(self, va: int, limit: int = 256) -> str | None:
        """A printable NUL-terminated string at va, or None."""
        try:
            raw = self.read(va, min(limit, self.region(va).end - va))
        except (ImageError, AttributeError):
            return None
        end = raw.find(b"\0")
        if end < 2:
            return None
        s = raw[:end]
        if all(32 <= c < 127 or c in (9, 10, 13) for c in s):
            return s.decode("ascii")
        return None

    def words(self, region: Region):
        """(va, value) for every 4-byte-aligned word in a region (literal pools are 4-aligned)."""
        base = region.file_off
        for i in range((-region.va) % 4, region.end - region.va - 3, 4):
            yield region.va + i, struct.unpack_from("<I", self.data, base + i)[0]

    def file_offset(self, va: int) -> int:
        r = self.region(va)
        if r is None:
            raise ImageError(f"{va:08X} not mapped")
        return r.file_off + va - r.va
