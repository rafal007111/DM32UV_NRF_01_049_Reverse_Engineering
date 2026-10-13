# Legacy Ghidra C-SKY processor module

Owner-supplied copy of the C-SKY v2 module used by the original Windows Ghidra 12.1.4 setup (derived from `leommxj/ghidra_csky`, language `CSKY_V2:LE:32:default` version 0.2). `analysis/archives/DM32_NRF_049_correct_base.gzf` needs this version.

`data/languages/32b_data.sinc` is kept exactly as supplied. Install it with `analysis/ghidra_scripts/32b_data.fixed.sinc` overlaid; that combination opens the GZF with no bad instruction prototypes (see `docs/TOOLS.md`). `tools/setup_cloud.sh` does this automatically. The supplied prebuilt `lib/C-SKY.jar` is not included; `src/` holds its ELF relocation handler source.
