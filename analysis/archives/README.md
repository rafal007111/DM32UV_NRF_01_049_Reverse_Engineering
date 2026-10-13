# Recovered NRF 01.049 Ghidra program

Import `DM32_NRF_049_correct_base.gzf` through **File > Import File** in
Ghidra 12.1.4 PUBLIC. This is a packed existing Program database, not a raw
binary import and not a `.gpr` project. It uses `CSKY_V2:LE:32:default`.
The archive is shared in this private repository at the owner's request.

Source: the recovered legacy `work/ghidra-project/DM32_NRF_049_correct_base`
project under the 2026-10-06 Codex workspace. A copy was opened read-only with
`-noanalysis`, then exported using Ghidra's `GzfExporter` (Ghidra Zip File).
The original project was not edited. A fresh project imported the GZF without
analysis and produced a byte-identical inventory.

Stored content: 2171 functions, one user-defined function name (`startup_entry`
at `0300C000`), 7 data types including built-ins, and no listing comments.
Do not assume the archive contains extensive manual annotations absent from
this stored database. It does preserve the existing function bodies, signatures,
symbols and memory mappings. The generic program image base is zero; the
**FLASH_LCSFC block begins at `0300C000`**, so do not rebase the imported database.
The flash block hash is `3711be95c10975c8f33073ad7a0b3c4d815e301bbcd389a4bd7ff7a0114acc63`.
Copied IRAM, initialized SRAM and uninitialized BSS/stack blocks are also present.

`manifest.json` records the archive hash/size, tool version and verification
scope. The accompanying inventory records function bodies/signatures, user
symbols, initialized block hashes and comment records. Matching inventories
do not independently verify every database field or establish semantic correctness.

The newer local `DmrCorrect` project has only two stored functions. It was
inspected but is not the archive provided here. Firmware and database bytes are
code-verified; no new hardware/serial test was performed.

See `docs/LEGACY_RECOVERY.md` for recovered integration artifacts and the now
identified intermediate image.
