// @addr 0002C3B8
// Result: FAIL, 2 differing items of 6 instructions (near) (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 0002C3B8 analysis/matching/0002C3B8_power_dac_set.c --cflags "-mcpu=ck803 -Os"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameter + (unsigned char) cast
/* Power-control DAC: DAC channel B (0x140F000C) = v << 4 via dac_write(2, ...) (catalog: high). */
extern void FUN_0002c38c(int ch, unsigned int v);

void power_dac_set_0002C3B8(unsigned char v)
{
    FUN_0002c38c(2, v << 4);
}
