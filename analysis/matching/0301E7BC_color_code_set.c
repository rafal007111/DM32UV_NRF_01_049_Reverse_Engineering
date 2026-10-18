// @addr 0301E7BC
// Result: FAIL, 8 differing items of 10 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 0301E7BC analysis/matching/0301E7BC_color_code_set.c --cflags "-mcpu=ck803 -Os"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameter, local unsigned char
/* Sets the configured Color Code: 33CCD and HR_C7000 register 11000384 bits 3:0 (catalog: high). */
#define REG32(a) (*(volatile unsigned int *)(a))
struct radio_state { unsigned char pad[5]; unsigned char color_code; };
extern struct radio_state DAT_00033cc8;

void color_code_set_0301E7BC(unsigned char cc)
{
    DAT_00033cc8.color_code = cc;
    REG32(0x11000384) = (REG32(0x11000384) & ~0xFu) | cc;
}
