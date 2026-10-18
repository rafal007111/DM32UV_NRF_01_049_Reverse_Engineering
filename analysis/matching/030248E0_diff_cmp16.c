// @addr 030248E0
// Result: FAIL, 9 differing items of 16 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+4 more equal)
// Oracle: python3 tools/dm32 match 030248E0 analysis/matching/030248E0_diff_cmp16.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameters, local unsigned short
/* diff_cmp16(a, b, lim): 0 when |a - b| <= lim, 1 when b - a > lim, 2 when a - b > lim (catalog: high). */
int diff_cmp16_030248E0(unsigned short a, unsigned short b, unsigned short lim)
{
    if (a < b)
        return (int)(b - a) > lim;
    return (int)(a - b) > lim ? 2 : 0;
}
