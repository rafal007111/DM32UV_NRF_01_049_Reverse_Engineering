// @addr 03023CCC
// @sym bit_table=030B043C
// Result: PASS (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2
// Oracle: python3 tools/dm32 match 03023CCC analysis/matching/03023CCC_popcount8.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameter, local unsigned char (adopted)
/* popcount8(mask) over the 8-entry bit table 030B043C (80 40 20 ... 01) (catalog: high). */
extern const unsigned char bit_table[8];

unsigned char popcount8_03023CCC(int imask)
{
    unsigned char mask = imask;
    unsigned char n = 0;
    int i;

    for (i = 0; i < 8; i++)
        if (bit_table[i] & mask)
            n++;
    return n;
}
