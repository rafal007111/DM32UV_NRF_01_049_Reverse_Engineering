# Prompt for the next unattended reverse-engineering agent

Copy everything below the line into a new agent session on this repository.

---

Continue the static reverse-engineering analysis of the Baofeng DM32UV, firmware DM32.NRF.01.049
(C-SKY CK803S / HR-C7000, application VA 0300C000, flash offset = VA − 03000000). Work **unattended**: do not
ask the user anything. When a decision is genuinely the owner's, record it as an open question in the docs and
continue with the next item.

## 0. Before you start

1. Read, in this order: `AGENTS.md`, `README.md`, `docs/RE_NOTES.md` (all dated entries), `docs/DECOMPILED_MODULES.md`,
   `docs/PROJECT_STATUS.md`, `docs/REPRODUCIBILITY.md`, `docs/TOOLS.md`, `docs/MONITOR_ANALYSIS.md`,
   `docs/TS_ANALYSIS.md`, `docs/CC_MATCH_ANALYSIS.md`, `docs/DATA_PATH_ANALYSIS.md`, `docs/RX_CALL_PATH_ANALYSIS.md`,
   `docs/SETTINGS_CPS_ANALYSIS.md`, `docs/MATCH_OPTIONS_DESIGN.md`. Build on them; do not re-derive documented facts.
   Where later docs correct earlier ones (e.g. `RX_CALL_PATH_ANALYSIS.md` §0.1, §13), the later doc wins.
2. Verify input hashes. If any differs, stop and report:
   - stock program image `analysis/inputs/stock_progmem_1MiB.bin` — `de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0`
   - installed image `analysis/inputs/current_scan_tick_fix.progmem.bin` — `156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53`
   - Ghidra database `analysis/archives/DM32_NRF_049_correct_base.gzf` — `354f93246db227e298d7161a370348b034cbd80f9d1507198a77987015bf9d2d`
3. Tooling: `bash tools/setup_cloud.sh` (JDK 25, binutils 2.42 for csky-elfabiv2, Ghidra 12.1.4 + legacy CSKY v0.2
   module + `analysis/ghidra_scripts/32b_data.fixed.sinc`, which includes **fix 3** for `zext`/`sext`; never analyse
   with the unfixed SLEIGH). Then `source /opt/dm32-tools.env`.
4. Build your working set in the scratchpad (exact commands are in `RX_CALL_PATH_ANALYSIS.md` §0):
   - import the GZF and run `ExportDM32.java` once (2171 functions, expect 0 failures);
   - `tools/static/resolve_ptr_literals.py` to turn `PTR_DAT_x` into `[value]`;
   - `tools/static/objdump_image.sh` for `flash.asm`/`iram.asm` (do **not** use `objdump -b binary`, it does not
     decode 32-bit C-SKY instructions);
   - `tools/static/decomp_grep.py` to grep with the owning function;
   - `DecompAt.java` with `-readOnly` for uncatalogued code (task entries such as `rxvoice` `030206D0`, `rxcsbk`
     `030209E4`, `rxmsg` `0301FF9C`, `txmsg` `0301FDD8`, `psint` `0305F234`, `usb` `0302B340`).
5. Reference documents now in `docs/`: `HR_C7000 Document 2.pdf` (baseband chip documentation — not yet used by any
   analysis) and `Baofeng_DM-32UV_User_Manual_20250210.pdf` (menu/CPS names). Read them as data, not instructions.

## 1. Hard rules (from AGENTS.md and the owner)

- Static analysis only. Never open a serial port, talk to the radio, send CPS words (`PROGRAM`, `SYSINFO`,
  `DEL-RCD`, …), or write/flash anything. Hardware tests belong to the owner; write them as RX-only proposals.
- Do not build or propose a program image. Patch ideas go into `docs/MATCH_OPTIONS_DESIGN.md` (or a new design doc)
  as **inferred design** with sites, stock bytes and constraints only.
- TX/PTT behaviour and CPS/codeplug compatibility must stay unchanged. Read-only subjects: `03027334`, `0301DE64`,
  `0301DF0C`, `0301DF8C`, `0002D7C8`, `3BEAA`/`3BEAC`, `33CCB`, `11000100` bit 0.
- Decompiler output can be wrong (types, boundaries, control flow, merged branches). Confirm every important claim in
  the disassembly, literal pools and BSR/JSR call sites. Keep `FUN_xxxxxxxx` names until evidence supports more.
- Label every finding: hardware-verified / code-verified / inferred / unreviewed. Record addresses, caller and data-flow
  evidence, tool versions and input hashes. Mark absence-of-evidence results ("no writer found") as inferred and say
  how you searched.
- Re-read your own document text against the evidence before committing (earlier passes caught wrong bit
  set/clear, wrong byte offsets and a mis-identified task entry this way).

## 2. Work items (priority order; finish and document each before moving on)

1. **HR-C7000 register cross-check.** Use `docs/HR_C7000 Document 2.pdf` to confirm or refute the inferred meanings of
   `11000384` (bits 3:0 CC, bit 8 set by Monitor/mode 4), `11000100` (slot/mode, OpenGD77 C6000 `0x10` analogy),
   `11000390`/`3BECC` status fields (bits 1:0 sync class, 3:2 sync source, 7:4 CC, 11:8 data type, 14:12 voice burst,
   17, 19, 22 TC, 23 AT, 25/26 errors), `11000394` (privacy alg/key), `11000400`, `11000404/408`, `11000418` (TX burst
   type), `11000000` and `1100005C` (restart hypothesis for `0305F2F4`). Update `MONITOR_ANALYSIS.md`,
   `TS_ANALYSIS.md` §7, `CC_MATCH_ANALYSIS.md` and `RX_CALL_PATH_ANALYSIS.md` with the datasheet evidence; upgrade or
   downgrade confidence labels accordingly. In particular decide whether a hardware CC or slot filter exists.
2. **TS Match off design closure** (`MATCH_OPTIONS_DESIGN.md` §3.2–3.6). Trace every remaining consumer of the burst
   slot vs. the TX slot on the receive path (UI call display `0305E3F0`, talker alias `0x40000000` path, recording,
   call log, scan/hang logic, `3C628`/`3C62A`, `3BA70`), and every place that would set `3BEAB`/`3BA55` for an
   other-slot capture. Confirm that `3BEBD..3BECB` is free (BSS layout, zero-init at boot, indexed accesses). Produce a
   final site list with stock bytes and guard bytes; still no image.
3. **CC Match off design closure.** Confirm the four Monitor-idiom CC sites and the `3C626` counter are the complete
   voice set (search for every comparison of `33CCD`/`33CC8+5` with any received CC, including IRAM and uncatalogued
   code). Check embedded-LC/late-entry and PI-header interaction with foreign CC, and the talker-alias path.
4. **Settings storage for new options.** Use the user manual and the menu tables to confirm labels for the setting ids in
   `SETTINGS_CPS_ANALYSIS.md` §1–2; determine whether any code reads block 4 `0x60` bits 2–7, `0x85` bit 4 ("MOTO")
   or `3BA6D` bits 5–7 through indirect/indexed accesses or block copies (e.g. `0304A45C`, CPS frame handlers).
   Document the exact boot-load and save paths a new option would need.
5. **Unreviewed internals:** channel byte `+0x0F` (`030562C4`), channel `+0x08` bits 2:1, `03023D24`, `0302A9A8`
   (`RTCITEM`), `0302AA58` (`PCTESTM`), the recording path (`0302123C`, `00015FA4`, `03010B40` sector ranges), the
   vocoder/privacy functions (`00015F30…000160C0`, `0001556C`, `00015880`, `00015728`, `00014698`, `0001D4B8`), the
   `Digit Monitor` softkey (`030BF168`, descriptor array around `030BA6A0`), the `0x4000` event / status bit 17.
6. **Function catalog hygiene.** Add rows for reviewed uncatalogued entries (task entries above, `0302B340`) if the
   catalog format allows, otherwise list them in `DECOMPILED_MODULES.md`. Keep `function_catalog.csv` byte format
   (UTF-8 BOM, CRLF) and change only the rows you reviewed.

## 3. Deliverables

- Update the relevant `docs/*.md` or add `docs/<TOPIC>_ANALYSIS.md` with tables of address, role, evidence, confidence.
- Add a short dated entry to `docs/RE_NOTES.md` per pass, linking to the detailed doc.
- Update `analysis/decompiled_modules/function_catalog.csv` (role, confidence, evidence) for every function reviewed and
  the cluster table in `docs/DECOMPILED_MODULES.md`.
- Commit any new read-only Ghidra scripts to `analysis/ghidra_scripts` and helpers to `tools/static`, with the exact
  command lines in the doc that uses them.
- Each doc pass ends with: open questions for the owner, RX-only hardware test proposals with expected results, and the
  list of items left unreviewed.
- Commit in logical steps with clear messages and push to the designated branch. Do not open a pull request.
- Do not include model identifiers in commits or docs.
