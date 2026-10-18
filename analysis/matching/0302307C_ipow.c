// @addr 0302307C
// Result: FAIL, 10 differing items of 11 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+4 more equal)
// Oracle: python3 tools/dm32 match 0302307C analysis/matching/0302307C_ipow.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: early return for exp <= 0
/* ipow(base, exp): 1 for exp <= 0 (catalog: high). */
int ipow_0302307C(int base, int exp)
{
    int r = 1;
    int i;

    for (i = 1; i <= exp; i++)
        r *= base;
    return r;
}
