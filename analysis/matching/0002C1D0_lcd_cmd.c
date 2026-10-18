// @addr 0002C1D0
// Result: FAIL, 1 differing items of 5 instructions (near) (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+4 more equal)
// Oracle: python3 tools/dm32 match 0002C1D0 analysis/matching/0002C1D0_lcd_cmd.c --cflags "-mcpu=ck803 -Os"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameter + (unsigned char) cast
/* lcd_cmd(byte): stores the byte to the LCD bus command register 0x12000000 (catalog: high). */
#define REG32(a) (*(volatile unsigned int *)(a))

void lcd_cmd_0002C1D0(unsigned char c)
{
    REG32(0x12000000) = c;
}
