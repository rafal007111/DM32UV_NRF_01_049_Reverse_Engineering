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

    def test_ui_tables(self):  # docs/UI_MAP.md §2, §8
        img = image.Image("stock")
        scene = lambda n: img.u32(0x030B1184 + 12 * n)  # 12-byte scene records
        self.assertEqual((scene(0), scene(7), scene(14)), (0x0303B374, 0x0303DD68, 0x0303D880))
        self.assertEqual([img.u32(0x03072808 + 4 * k) for k in (0, 14, 23)], [0x03014E38, 0x03014D20, 0x03014CB4])
        self.assertEqual(img.read(0x030B9700, 16).hex(), "50960b0316020000a8960b0316020000")  # Other Func, 22 items

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

    def test_cps_d_command_reads_sd(self):  # CPS_PROTOCOL.md §8a: PROGRAM-loop D -> sd_read_blocks
        self.assertEqual(self.callers(0x03067474), {(0x0302A696, 0x0302A448), (0x0302A6A2, 0x0302A448)})

    def test_register_and_ram_accesses(self):
        sites = {(a.site, a.kind) for a in self.x.accesses_in(0x11000384, 0x11000385)}
        self.assertTrue({(0x0301EC4E, "ld"), (0x0301EC74, "st")} <= sites)
        self.assertTrue(any(0x0002D7C8 <= s < 0x0002DE10 for s, _ in sites))  # IRAM 0002D7C8 writes bits 3:0
        stores = {a.site for a in self.x.accesses_in(0x3E341, 0x3E342) if a.kind == "st"}
        self.assertEqual(stores, {0x0303209A, 0x0303233C, 0x0305CD08, 0x0305CD1C})

    def test_hub_lock_pairing(self):  # HUB_FUNCTIONS.md 2.1-2.3, code-verified
        # data-flash area reader: pend/post the same mutex 39468 around the raw read
        calls = [(s, t) for s, t, k in sorted(self.x.callees_of[0x0300F780])]
        self.assertEqual([t for _, t in calls], [0x0300C500, 0x0300F364, 0x0002B9A0, 0x0300C53C])
        self.assertEqual(sum(1 for i in self.d.code(0x0300F780) if self.d.literal(i) == 0x39468), 1)
        # SPI NOR read: CS GPIO 18 low (0002C548) before, high (0002C504) after
        cs = [t for _, t, k in sorted(self.x.callees_of[0x0002B95C]) if t in (0x0002C504, 0x0002C548)]
        self.assertEqual(cs, [0x0002C548, 0x0002C504])

    def test_lcd_bus(self):  # HUB_FUNCTIONS.md 3.1, code-verified
        stores = {(a.addr, a.site) for a in self.x.accesses_in(0x12000000, 0x12000008) if a.kind == "st"}
        self.assertEqual(stores, {(0x12000000, 0x0002C1D6), (0x12000004, 0x0002C1E2)})
        movi = [int(i.ops.split(",")[1]) for i in self.d.code(0x030178A4) if i.mnem == "movi"]
        self.assertEqual(movi, [44])  # DCS Memory Write 0x2C

    def test_jump_tables(self):
        self.assertEqual(self.d.jump_tables[0x0002D83E][0], 0x0002D8B6)
        self.assertEqual(len(self.d.jump_tables[0x0002D83E]), 7)
        unresolved = [i.addr for ins in self.x.reachable.values() for i in ins
                      if i.mnem == "jmp" and i.addr not in self.d.jump_tables]
        self.assertEqual(unresolved, [])

    def test_ucos3_kernel_review(self):  # LIBRARY_SIGNATURES.md 5, code-verified
        sched_callers = {f for s, f in self.callers(0x00010934)}
        self.assertTrue({0x00011A58, 0x00012720, 0x0306A984, 0x03068FE0} <= sched_callers)  # OSSched after pends
        tmr_start = {t for s, t, k in self.x.callees_of[0x0306BD74]}
        self.assertTrue({0x00011190, 0x0306BB80, 0x0306BA38, 0x00011250} <= tmr_start)
        self.assertIn(0x0306B7F0, {t for s, t, k in self.x.callees_of[0x0306BE28]})  # OSTmrDel -> OS_TmrClr

    def test_osinit_call_order(self):  # LIBRARY_SIGNATURES.md 6, code-verified
        order = [t for s, t, k in sorted(self.x.callees_of[0x00010D5C])]
        self.assertEqual(order, [0x000106DC, 0x000119E0, 0x00010D44, 0x03069550, 0x03069CF8, 0x03069D10,
                                 0x0306A8AC, 0x0306AF0C, 0x00011FD8, 0x00012B70, 0x000118CC, 0x00010A54,
                                 0x00013874, 0x0306B610, 0x0306B970, 0x03068E6C, 0x03068E68])
        tags = {v for s, p, v in self.x.literals_in(0x41000000, 0x56000000) if 0x000116A4 <= s < 0x000117E2}
        self.assertEqual(tags, {0x47534D54, 0x47414C46, 0x47495354, 0x414D4553, 0x53455254, 0x4B434954,
                                0x53555354, 0x55455551})  # OS_IntQRePost object types

    def test_similarity(self):
        from dm32re import similar
        ix = similar.Index(self.x)
        hits = {o: r for o, _, r, _ in ix.query(0x0302E974, top=20, min_ratio=0.9)}
        self.assertIn(0x0302E99C, hits)


class TagRules(unittest.TestCase):
    """No firmware needed: subsystem-tag decision rules (SUBSYSTEM_TAGS.md 2)."""

    def test_family_and_canon(self):
        from dm32re import tag
        self.assertEqual(tag.family(["Main loop", "Menu/input"]), "UI tasks")
        self.assertIsNone(tag.family(["Main loop", "Digital RX/DMR"]))
        self.assertIsNone(tag.canon("NRF application; subsystem not classified"))
        self.assertIsNone(tag.canon("RTOS (uC/OS-III, pre-V3.08 with ISR post queue)"))
        self.assertEqual(tag.canon("Digital RX/DMR CSBK"), "Digital RX/DMR")

    def test_decide(self):
        from dm32re.tag import Tagger
        t = Tagger._decide(1, {"Scanning": 4.5, "Settings": 1.5}, {"Scanning": ["x"]}, ["main loop step"], ["Main loop"])
        self.assertEqual((t.tag, t.confident), ("Scanning", True))
        t = Tagger._decide(1, {"Scanning": 3.0, "Settings": 2.5}, {}, [], [])
        self.assertFalse(t.confident)  # margin below 1.0
        t = Tagger._decide(1, {"Audio": 2.0}, {}, ["a", "b"], ["Main loop", "Menu/input"])
        self.assertEqual((t.tag, t.confident), ("shared (UI tasks)", True))
        t = Tagger._decide(1, {}, {}, ["a", "b"], ["Main loop", "Digital RX/DMR"])
        self.assertEqual((t.tag, t.confident), ("shared", False))


@unittest.skipUnless(HAVE_IMAGE and HAVE_BINUTILS, "needs stock image and csky binutils")
class TagStock(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from dm32re import cli, tag
        cls.tags = tag.Tagger(cli.Ctx("stock", False)).run()

    def test_spot_checked(self):  # SUBSYSTEM_TAGS.md 4, checked by hand
        # 0300C2CC and 0301C98C were reviewed in pass 3 (P1) and are no longer tagged; two still-unreviewed rows
        # of other tags replace them (SUBSYSTEM_TAGS.md 8).
        for va, want in [(0x0302225C, "Audio/tones"), (0x00014208, "Audio/vocoder"),
                         (0x0302F370, "Scanning"), (0x0300EEA4, "Main loop"), (0x0305E6DC, "UI/status"),
                         (0x030683AC, "shared (UI tasks)")]:
            t = self.tags[va]
            self.assertEqual((t.tag, t.confident), (want, True), f"{va:08X}")

    def test_misleading_signals_lowered(self):
        self.assertFalse(self.tags[0x030569E4].confident)  # reached only from the keys task, a menu helper


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


THEAD = Path(os.environ.get("DM32_CSKY_TOOLCHAIN", "/opt/thead-csky-v3.10.29-b20210423"))
HAVE_THEAD = (THEAD / "csky-elfabiv2" / "lib" / "ck803" / "libc.a").exists()


class LibSigDecoding(unittest.TestCase):
    def test_bsr32_target(self):
        from dm32re import libsig
        # T-HEAD objdump 2.27: "30704ec: e00004d2 bsr 0x3070e90" and "30718c4: e3fffaba bsr 0x3070e38"
        self.assertEqual(libsig.bsr32_target(bytes.fromhex("00e0d204"), 0, 0x030704EC), 0x03070E90)
        self.assertEqual(libsig.bsr32_target(bytes.fromhex("ffe3bafa"), 0, 0x030718C4), 0x03070E38)
        self.assertIsNone(libsig.bsr32_target(bytes.fromhex("14d06ccb"), 0, 0x100))


class LibSigNormalise(unittest.TestCase):
    """No firmware needed: vendor versus V3.10.29 encodings (LIBRARY_SIGNATURES.md 9)."""

    def test_three_operand_addu_subu(self):
        from dm32re.libsig import norm_insn
        # stock 0001393A "addu r1, r1, r2" (5928) == as 2.42 "addu16 r1, r1, r2" -> 6048
        self.assertEqual(norm_insn(0x5928), norm_insn(0x6048))
        # stock 000101AC "subu r0, r0, r3" (580D) == two-operand subu r0, r3 (600E)
        self.assertEqual(norm_insn(0x580D), norm_insn(0x600E))
        # stock 00010AD8 "addu r2, r3, r2" (5B48): commutative, == addu r2, r3 (608C)
        self.assertEqual(norm_insn(0x5B48), norm_insn(0x608C))
        # distinct registers stay three-operand; subu is not commutative
        self.assertEqual(norm_insn(0x5A2D), (2, 0x5A2D))  # subu r1, r2, r3
        self.assertEqual(norm_insn(0x5B01), (2, 0x5B01))  # subu r0, r3, r0

    def test_pc_relative_fields_masked(self):
        from dm32re.libsig import norm_insn
        self.assertEqual(norm_insn(0x041F), norm_insn(0x0401))  # br16
        self.assertEqual(norm_insn(0xE800, 0x001C), norm_insn(0xE800, 0x0100))  # br32
        self.assertEqual(norm_insn(0xE903, 0x0016), norm_insn(0xE903, 0x0002))  # bez r3
        self.assertNotEqual(norm_insn(0xE903, 0x0016), norm_insn(0xE904, 0x0016))  # bez r4
        self.assertEqual(norm_insn(0xE000, 0x000A), norm_insn(0xE3FF, 0xFABA))  # bsr32
        self.assertEqual(norm_insn(0x1065), norm_insn(0x1061))  # lrw16 r3, offset differs
        self.assertNotEqual(norm_insn(0x1065), norm_insn(0x1045))  # lrw16 r2

    def test_leading_self_extension_dropped(self):
        from dm32re.libsig import norm_tokens
        rts, zextb_r1 = b"\x3c\x78", b"\x44\x74"  # 783C rts, 7444 zextb r1, r1
        self.assertEqual(norm_tokens(zextb_r1 + rts), norm_tokens(rts))
        self.assertNotEqual(norm_tokens(rts + zextb_r1), norm_tokens(rts))  # only at the start

    def test_pool_alignment(self):
        from dm32re.libsig import norm_compare, norm_tokens
        word = b"\x78\x56\x34\x12"
        a = norm_tokens(b"\x61\x10" + b"\x3c\x78" + word, base=0)  # lrw16 r3 -> pool at 4; rts
        b = norm_tokens(b"\x62\x10" + b"\x3c\x78" + b"\x03\x6c" + word, base=2)  # pool at 8, filler at 6
        self.assertEqual(a, b)
        self.assertEqual(a[-1], ("D", 0x12345678))
        ref = norm_tokens(b"\x61\x10" + b"\x3c\x78" + word, mask=b"\x01" * 4 + b"\x00" * 4)
        self.assertEqual(ref[-1], ("D", None))  # relocated pool word matches any value
        self.assertTrue(norm_compare(ref, a)[0])


@unittest.skipUnless(HAVE_THEAD, "pinned T-HEAD toolchain missing (tools/setup_cloud.sh --with-thead)")
class LibSigReference(unittest.TestCase):
    def test_malloc_free_relocations(self):
        from dm32re import libsig
        libc = THEAD / "csky-elfabiv2" / "lib" / "ck803" / "libc.a"
        blob = dict(libsig.ar_members(libc))["malloc.o"]
        fns = {f.names[0]: f for f in libsig._functions(blob, "libc.a:malloc.o")}
        free = fns["free"]
        self.assertEqual(len(free.code), 120)  # .size 112 plus the literal pool behind it
        self.assertEqual([r.sym.name for r in free.relocs],
                         ["os_critical_enter", "os_critical_exit", "__malloc_lock", ".data"])
        self.assertEqual(free.labels, {116: "malloc.o:F"})


@unittest.skipUnless(HAVE_IMAGE and HAVE_THEAD, "needs stock image and the pinned T-HEAD toolchain")
class LibSigStock(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from dm32re import catalog, libsig
        img = image.Image("stock")
        refs = libsig.load_reference(THEAD)
        rows, _ = libsig.run_match(img, refs)
        rows += libsig.near(img, refs, rows, catalog.load())
        cls.rows = {m.va: m for m in rows}
        cls.strength = staticmethod(libsig.strength)

    def test_exact(self):  # LIBRARY_SIGNATURES.md, code-verified
        for va, name in [(0x03070B88, "memcpy"), (0x03070A3C, "memcmp"), (0x030705A8, "free"),
                         (0x03070DA4, "strlen"), (0x030010E4, "strlen")]:
            self.assertIn(name, self.rows[va].names)
            self.assertEqual(self.strength(self.rows[va]), "exact")

    def test_relocations_read_back(self):
        self.assertIn("malloc.o:F", self.rows[0x18000C30].names)
        self.assertIn("__malloc_lock", self.rows[0x0004A7D0].names)
        self.assertGreaterEqual(self.rows[0x03070E44].agree, 1)  # os_critical_enter called from free

    def test_norm(self):  # LIBRARY_SIGNATURES.md 9: identical after normalisation
        from dm32re import catalog, libsig
        rows = {m.va: m for m in libsig.norm_pass(image.Image("stock"), libsig.load_reference(THEAD),
                                                    catalog.load(), 0x03070500, 0x03071900, set())}
        for va, name in [(0x0307050C, "malloc"), (0x03070C08, "memset"), (0x03070E24, "isspace"),
                         (0x0307183C, "strtoul")]:
            self.assertEqual((rows[va].method, name in rows[va].names), ("norm", True))
        self.assertEqual(rows[0x03070918].method, "norm-near")  # strtol, ratio 0.98
        self.assertIn("strtol", rows[0x03070918].names)

    def test_near(self):
        self.assertIn("malloc", self.rows[0x0307050C].names)
        self.assertGreaterEqual(self.rows[0x0307050C].ratio, 0.95)
        self.assertNotIn(0x0306F10C, self.rows)  # relocation-only tables never count as near


class MatchPure(unittest.TestCase):
    """No toolchain needed: the oracle's comparison on hand-made objects (docs/MATCHING_PILOT.md, M2)."""

    def ref(self, code, base=0, relocs=()):
        from dm32re import libsig
        mask = bytearray(b"\x01" * len(code))
        for r in relocs:
            mask[r.off:r.off + 4] = b"\x00\x00\x00\x00"
        return libsig.RefFn(["f"], "test", code, mask, list(relocs), start=base)

    def test_pool_alignment_is_not_a_difference(self):
        from dm32re import match
        word = b"\x78\x56\x34\x12"
        ref = self.ref(b"\x61\x10" + b"\x3c\x78" + word)  # lrw16 r3 -> pool at 4; rts
        fw = match.BufferView({0x03010002: b"\x62\x10" + b"\x3c\x78" + b"\x03\x6c" + word})  # pool at +8
        self.assertEqual(match.compare(ref, fw, 0x03010002).verdict, match.PASS)
        fw = match.BufferView({0x03010002: b"\x62\x10" + b"\x3c\x78" + b"\x03\x6c" + b"\x00\x00\x00\x00"})
        self.assertEqual(match.compare(ref, fw, 0x03010002).verdict, match.FAIL)  # pool word differs

    def test_encoding_only(self):
        from dm32re import match
        ref = self.ref(b"\x04\x60" + b"\x3c\x78")  # 6004 addu r0, r1; rts
        fw = match.BufferView({0x100: b"\x04\x58" + b"\x3c\x78"})  # 5804 addu r0, r0, r1 (vendor form)
        res = match.compare(ref, fw, 0x100)
        self.assertEqual((res.verdict, res.enc), (match.PASS_ENC, 1))
        fw = match.BufferView({0x100: b"\x08\x60" + b"\x3c\x78"})  # 6008 addu r0, r2
        self.assertEqual(match.compare(ref, fw, 0x100).verdict, match.FAIL)

    def test_relocated_call_and_data(self):
        import struct
        from dm32re import libsig, match
        callee = libsig.Symbol("FUN_03020000", 0, 0, 0, 1, 0)
        data = libsig.Symbol("g_state", 0, 0, 1, 1, 0)
        # bsr32 FUN_03020000 (offset field zero in the object); lrw16 r3 -> pool at 8; rts; pool word
        code = b"\x00\xe0\x00\x00" + b"\x61\x10" + b"\x3c\x78" + b"\x00\x00\x00\x00"
        ref = self.ref(code, relocs=[libsig.Reloc(0, libsig.R_PCREL26, callee, 0),
                                     libsig.Reloc(8, libsig.R_ADDR32, data, 4)])
        imm = ((0x03020000 - 0x03010000) >> 1) & 0x3FFFFFF
        bsr = struct.pack("<HH", (0xE0000000 | imm) >> 16, imm & 0xFFFF)
        good = bsr + b"\x61\x10\x3c\x78" + struct.pack("<I", 0x0003BEAC)
        fw = match.BufferView({0x03010000: good})
        self.assertEqual(match.compare(ref, fw, 0x03010000).verdict, match.UNRESOLVED)  # g_state unknown
        self.assertEqual(match.compare(ref, fw, 0x03010000, {"g_state": 0x3BEA8}).verdict, match.PASS)
        self.assertEqual(match.compare(ref, fw, 0x03010000, {"g_state": 0x3BEB0}).verdict, match.FAIL)
        imm2 = ((0x03020010 - 0x03010000) >> 1) & 0x3FFFFFF
        bad = struct.pack("<HH", (0xE0000000 | imm2) >> 16, imm2 & 0xFFFF) + good[4:]
        fw = match.BufferView({0x03010000: bad})
        self.assertEqual(match.compare(ref, fw, 0x03010000, {"g_state": 0x3BEA8}).verdict, match.FAIL)

    def test_firmware_longer_than_compiled(self):
        from dm32re import match
        ref = self.ref(b"\x3c\x78")  # rts
        fw = match.BufferView({0x100: b"\x3c\x78\x04\x60\x3c\x78"}, sizes={0x100: 6})
        self.assertEqual(match.compare(ref, fw, 0x100).verdict, match.FAIL)
        fw = match.BufferView({0x100: b"\x3c\x78\x04\x60\x3c\x78"}, sizes={0x100: 2})
        self.assertEqual(match.compare(ref, fw, 0x100).verdict, match.PASS)


@unittest.skipUnless(HAVE_THEAD, "pinned T-HEAD toolchain missing (tools/setup_cloud.sh --with-thead)")
class MatchCompiled(unittest.TestCase):
    """A tiny function compiled by the pinned toolchain against a synthetic firmware buffer."""

    SRC = ("extern void FUN_03020000(int);\n"
           "extern volatile unsigned DAT_0003bea8;\n"
           "int f_03010000(int a, int b) { FUN_03020000(a + b); return DAT_0003bea8 + 1; }\n")

    @classmethod
    def setUpClass(cls):
        import tempfile
        from dm32re import match
        cls.tmp = tempfile.TemporaryDirectory()
        src = Path(cls.tmp.name) / "f.c"
        src.write_text(cls.SRC)
        cls.obj = match.compile_c(src, THEAD, "-mcpu=ck803 -Os", Path(cls.tmp.name))
        cls.ref = match.pick(cls.obj, None, 0x03010000)

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def firmware(self, at=0x03010000):
        """The compiled bytes with their relocations applied for a function placed at `at`."""
        import struct
        from dm32re import libsig, match
        code = bytearray(self.ref.code)
        for r in self.ref.relocs:
            tgt = match.symbol_address(r, {})
            if r.type == libsig.R_PCREL26:
                imm = ((tgt - (at + r.off)) >> 1) & 0x3FFFFFF
                hi, lo = struct.unpack_from("<HH", code, r.off)
                w = (hi << 16 | lo) & ~0x3FFFFFF | imm
                struct.pack_into("<HH", code, r.off, w >> 16, w & 0xFFFF)
            else:
                struct.pack_into("<I", code, r.off, tgt)
        return bytes(code)

    def test_pass(self):
        from dm32re import match
        self.assertEqual(self.ref.names[0], "f_03010000")
        self.assertEqual({r.sym.name for r in self.ref.relocs}, {"FUN_03020000", "DAT_0003bea8"})
        fw = match.BufferView({0x03010000: self.firmware()}, sizes={0x03010000: len(self.ref.code)})
        res = match.compare(self.ref, fw, 0x03010000)
        self.assertEqual((res.verdict, res.differing), (match.PASS, 0))

    def test_fail(self):
        from dm32re import match
        code = bytearray(self.firmware())
        code[0] ^= 0x01  # change the first instruction
        res = match.compare(self.ref, match.BufferView({0x03010000: bytes(code)}), 0x03010000)
        self.assertEqual(res.verdict, match.FAIL)
        self.assertGreaterEqual(res.differing, 1)

    def test_wrong_callee_fails(self):
        from dm32re import match
        fw = match.BufferView({0x03010000: self.firmware()})
        res = match.compare(self.ref, fw, 0x03010000, {"FUN_03020000": 0x03020004})
        self.assertEqual(res.verdict, match.FAIL)


@unittest.skipUnless(HAVE_IMAGE and HAVE_THEAD, "needs stock image and the pinned T-HEAD toolchain")
class MatchStock(unittest.TestCase):
    """Pilot results on the stock image (docs/MATCHING_PILOT.md 3), with the committed pilot C files."""

    def verdict(self, addr, name, flags):
        from dm32re import match
        src = image.REPO / "analysis" / "matching" / name
        func, syms = match.source_hints(src.read_text())
        ref = match.pick(match.compile_c(src, THEAD, flags), func, addr)
        return match.compare(ref, match.FwView("stock"), addr, syms)

    def test_shared_pool_pass(self):  # the vendor pool word for 0300C3AC sits behind later functions (0300C408)
        res = self.verdict(0x0300C3AC, "0300C3AC_rf_carrier_get.c", "-mcpu=ck803 -Os")
        self.assertEqual(res.verdict, "PASS")
        self.assertEqual([r.fw.off for r in res.rows if r.fw.kind == "D"], [0x5C])

    def test_best_flag_set(self):
        best = "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
        for addr, name in [(0x0002C38C, "0002C38C_dac_write.c"), (0x03023CCC, "03023CCC_popcount8.c"),
                           (0x03029318, "03029318_slot_flags_clear.c")]:
            self.assertEqual(self.verdict(addr, name, best).verdict, "PASS", name)

    def test_entry_extension_is_a_difference(self):  # vendor zextb r0, r0 on entry, GCC 6.3 trusts the caller
        res = self.verdict(0x0002C1D0, "0002C1D0_lcd_cmd.c", "-mcpu=ck803 -Os")
        self.assertEqual((res.verdict, res.differing), ("FAIL", 1))


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
