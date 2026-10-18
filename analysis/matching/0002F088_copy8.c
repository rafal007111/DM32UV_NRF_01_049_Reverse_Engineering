// @addr 0002F088
// Result: FAIL, 7 differing items of 8 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O1 (+9 more equal)
// Oracle: python3 tools/dm32 match 0002F088 analysis/matching/0002F088_copy8.c --cflags "-mcpu=ck803 -O1"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: do-while form
/* copy8(dst, src, n): byte copy, n <= 0 does nothing (IRAM, catalog: high). */
void copy8_0002F088(unsigned char *dst, const unsigned char *src, int n)
{
    int i;

    for (i = 0; i < n; i++)
        dst[i] = src[i];
}
