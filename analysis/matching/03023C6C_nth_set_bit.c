// @addr 03023C6C
// @sym bit_table=030B043C
// Result: FAIL, 9 differing items of 19 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+5 more equal)
// Oracle: python3 tools/dm32 match 03023C6C analysis/matching/03023C6C_nth_set_bit.c --cflags "-mcpu=ck803 -Os"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameters, local unsigned char (adopted)
/* nth_set_bit(mask, n): 1-based MSB-first position of the n-th set bit of mask, 0 when there is none
   (bit table 030B043C = 80 40 20 10 08 04 02 01) (catalog: high). */
extern const unsigned char bit_table[8];

unsigned char nth_set_bit_03023C6C(int imask, int in)
{
    unsigned char mask = imask, n = in;
    unsigned char found = 0;
    unsigned char pos;

    for (pos = 1; pos != 9; pos++)
        if ((bit_table[pos - 1] & mask) && ++found == n)
            return pos;
    return 0;
}
