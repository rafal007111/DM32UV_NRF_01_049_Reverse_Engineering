// @addr 00019494
// Result: FAIL, 2 differing items of 6 instructions (near) (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+1 more equal)
// Oracle: python3 tools/dm32 match 00019494 analysis/matching/00019494_fill16.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: do-while form
/* fill16(dst, value, n): n halfwords (IRAM, catalog: high). */
void fill16_00019494(unsigned short *dst, unsigned short value, int n)
{
    while (n > 0) {
        *dst++ = value;
        n--;
    }
}
