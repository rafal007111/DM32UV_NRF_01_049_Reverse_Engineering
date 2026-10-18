// @addr 0002C38C
// Result: PASS (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2
// Oracle: python3 tools/dm32 match 0002C38C analysis/matching/0002C38C_dac_write.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int ch, local unsigned char (adopted)
/* dac_write(ch, v): 12-bit value to DAC 0x140F0000 data A (+8, ch 1), B (+0xC, ch 2), C (+0x10, ch 4)
   (catalog: high). */
#define REG32(a) (*(volatile unsigned int *)(a))

void dac_write_0002C38C(int chan, unsigned int v)
{
    unsigned char ch = chan;

    v &= 0xFFF;
    if (ch == 1)
        REG32(0x140F0008) = v;
    else if (ch == 2)
        REG32(0x140F000C) = v;
    else if (ch == 4)
        REG32(0x140F0010) = v;
}
