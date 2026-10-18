// @addr 03055CCC
// Result: FAIL, 51 differing items of 41 instructions (medium); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+3 more equal)
// Oracle: python3 tools/dm32 match 03055CCC analysis/matching/03055CCC_channel_locate.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int n, local unsigned short (adopted)
/* Channel number (1-based) -> data-flash block and offset of its 0x30-byte record: 84 records in block
   0x12 from offset 0x20, then 85 per block from offset 0x10 (catalog: high). */
void channel_locate_03055CCC(int in, unsigned short *block, unsigned short *off)
{
    unsigned short n = in;
    unsigned short blk, q, r;

    if (n < 85) {
        *block = 18;
        *off = (n - 1) * 48 + 32;
        return;
    }
    n -= 84;
    q = n / 85;
    blk = q + 19;
    r = n - q * 85;
    if (r == 0) {
        blk--;
        q--;
    }
    *block = blk;
    *off = ((unsigned char)(n - q * 85) - 1) * 48 + 16;
}
