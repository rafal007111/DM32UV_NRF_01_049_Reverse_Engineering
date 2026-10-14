"""Regression tests for tools/dm32re against facts documented as code-verified in docs/*.md.

Run from the repository root:  python3 -m unittest discover -s tools/tests -v
Tests needing the private stock image, C-SKY binutils, Ghidra or the reference corpus are skipped
when those are missing. Nothing here opens a serial port or writes a program image.
"""

import os
import shutil
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from dm32re import disasm, image  # noqa: E402

HAVE_IMAGE = (image.INPUTS / "stock_progmem_1MiB.bin").exists()
try:
    disasm.tool("objdump")
    HAVE_BINUTILS = True
except FileNotFoundError:
    HAVE_BINUTILS = False
LIBREF = image.BUILD / "libref"


class PureDecoding(unittest.TestCase):
    """No firmware needed: encodings checked against GNU objdump 2.42 output."""

    def test_lrw16_pool(self):
        # objdump: "4: 1073  lrw r3, 0x0 // 50"  and  "2: 117b  lrw r3, 0x0 // ec"
        self.assertEqual(disasm.pool_address(0x4, 0x1073, 2, "lrw"), 0x50)
        self.assertEqual(disasm.pool_address(0x2, 0x117B, 2, "lrw"), 0xEC)

    def test_lrw32_pool(self):
        # objdump: "30174f0: ea830098  lrw r3, [pc, 608] // from address pool at 3017750"
        self.assertEqual(disasm.pool_address(0x030174F0, 0xEA830098, 4, "lrw"), 0x03017750)

    def test_not_a_pool(self):
        self.assertIsNone(disasm.pool_address(0x100, 0x3843, 2, "cmpnei"))

    def test_parse_objdump(self):
        text = (" 30174fc:\t0c03      \tbf      \t0x3017502\t// 3017502 <f+0x1c>\n"
                " 3017504:\te000538c \tbsr      \t0x3021c1c\t// 3021c1c <f+0xa736>\n"
                " 3017510:\t0000      \t.short\t0x0000\n")
        a, b, c = disasm.parse_objdump(text)
        self.assertEqual((a.mnem, a.target, a.size), ("bf", 0x3017502, 2))
        self.assertEqual((b.mnem, b.target, b.size), ("bsr", 0x3021C1C, 4))
        self.assertTrue(c.data)


@unittest.skipUnless(HAVE_IMAGE, "private stock image missing")
class StockImage(unittest.TestCase):
    def test_hash_and_regions(self):
        img = image.Image("stock")
        self.assertEqual(img.sha256, "de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0")
        iram = img.regions[0]
        self.assertEqual((iram.name, iram.va, iram.end, iram.file_off), ("IRAM", 0x10000, 0x2F0B4, 0xC0C38))
        self.assertEqual(img.u32(0x03072940), 0x03017560)  # Monitor handler table entry 25

    def test_wrong_hash_rejected(self):
        with self.assertRaises(image.ImageError):
            image.Image("stock", path=image.INPUTS / "current_scan_tick_fix.progmem.bin")


@unittest.skipUnless(HAVE_IMAGE and HAVE_BINUTILS, "needs stock image and csky binutils")
class Analysis(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from dm32re import xrefs
        cls.d = disasm.load("stock")
        cls.x = xrefs.Xrefs(cls.d)

    def callers(self, target):
        return {(s, f) for s, f, k in self.x.callers_of.get(target, []) if k == "bsr"}

    def test_cc_setter_listing(self):
        first = self.d.code(0x0301EC40)[:3]
        self.assertEqual([(i.addr, i.mnem, i.size) for i in first],
                         [(0x0301EC40, "lrw", 2), (0x0301EC42, "ld.b", 2), (0x0301EC44, "ins", 4)])
        self.assertEqual(self.d.literal(first[0]), 0x3BA54)

    def test_monitor_callers(self):  # RE_NOTES.md, code-verified
        self.assertEqual(self.callers(0x0305CCF0), {(0x03017526, 0x030174E0), (0x03017534, 0x030174E0),
                                                    (0x0305E198, 0x0305E134), (0x0305E2B4, 0x0305E134)})
        self.assertEqual(self.callers(0x0301EC40), {(0x0303209C, 0x03031FD4), (0x0303233E, 0x03031FD4),
                                                    (0x0305CCFA, 0x0305CCF0), (0x0305CD0E, 0x0305CCF0)})

    def test_discovered_table_handler(self):
        self.assertIn(0x03017560, self.d.cat.by_addr)  # not a Ghidra function; entry 25 of 030728DC
        self.assertIn(0x03072940, self.x.words_equal(0x03017560))
        callees = {(s, t) for s, t, k in self.x.callees_of[0x03017560]}
        self.assertIn((0x030175E8, 0x030174E0), callees)
        self.assertIn((0x030175E0, 0x0301742C), callees)

    def test_register_and_ram_accesses(self):
        sites = {(a.site, a.kind) for a in self.x.accesses_in(0x11000384, 0x11000385)}
        self.assertTrue({(0x0301EC4E, "ld"), (0x0301EC74, "st")} <= sites)
        self.assertTrue(any(0x0002D7C8 <= s < 0x0002DE10 for s, _ in sites))  # IRAM 0002D7C8 writes bits 3:0
        stores = {a.site for a in self.x.accesses_in(0x3E341, 0x3E342) if a.kind == "st"}
        self.assertEqual(stores, {0x0303209A, 0x0303233C, 0x0305CD08, 0x0305CD1C})

    def test_jump_tables(self):
        self.assertEqual(self.d.jump_tables[0x0002D83E][0], 0x0002D8B6)
        self.assertEqual(len(self.d.jump_tables[0x0002D83E]), 7)
        unresolved = [i.addr for ins in self.x.reachable.values() for i in ins
                      if i.mnem == "jmp" and i.addr not in self.d.jump_tables]
        self.assertEqual(unresolved, [])

    def test_similarity(self):
        from dm32re import similar
        ix = similar.Index(self.x)
        hits = {o: r for o, _, r, _ in ix.query(0x0302E974, top=20, min_ratio=0.9)}
        self.assertIn(0x0302E99C, hits)


@unittest.skipUnless(HAVE_IMAGE and HAVE_BINUTILS and (LIBREF / "Os" / "os_sem.o").exists(),
                     "reference corpus not built (tools/libref/build_ucos3.sh)")
class LibraryId(unittest.TestCase):
    def test_ossempend(self):
        from dm32re import cli, libid
        c = cli.Ctx("stock", False)
        ref = [r for r in libid.load_reference([str(LIBREF / "Os" / "os_sem.o")]) if r.name == "OSSemPend"]
        fw = libid.load_firmware(c)
        best = libid.match(ref, fw)["Os/OSSemPend"][0]
        self.assertEqual(best[3].key, "00011A58")
        self.assertGreaterEqual(best[2], 0.5)  # error-code constants agree

    def test_strength(self):
        from dm32re.libid import strength
        self.assertEqual(strength(0.5, 0.7, 10, 100, 0.0), "strong")
        self.assertEqual(strength(1.0, 0.0, 0, 6, 0.0), "weak")  # short functions never count


@unittest.skipUnless(shutil.which("analyzeHeadless") or os.path.exists("/opt/ghidra_12.1.4_PUBLIC"),
                     "Ghidra missing")
class GhidraDecompile(unittest.TestCase):
    def test_cc_setter(self):
        from dm32re import ghidra
        c = ghidra.decompile([0x0301EC40])[0x0301EC40]
        self.assertIn("_DAT_11000384", c)
        self.assertIn("0x100", c)


if __name__ == "__main__":
    unittest.main()
