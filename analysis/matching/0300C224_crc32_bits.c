// @addr 0300C224
// Result: FAIL, 30 differing items of 30 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+2 more equal)
// Oracle: python3 tools/dm32 match 0300C224 analysis/matching/0300C224_crc32_bits.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int nbits, local unsigned short
/* CRC-32, polynomial 0x04C11DB7, over nbits bits of data, MSB first (DMR packet-data CRC; catalog: high).
   Written the way the code computes it: rotate left, then XOR (poly - 1) for the bit shifted out and poly
   for the data bit. */
unsigned int crc32_bits_0300C224(unsigned int crc, unsigned short nbits, const unsigned char *data)
{
    unsigned int i;
    unsigned int msb;
    unsigned char byte = 0;
    unsigned char bit;

    for (i = 0; i < nbits; i++) {
        if ((i & 7) == 0)
            byte = data[i >> 3];
        bit = (byte << (i & 7)) & 0x80;
        msb = crc >> 31;
        crc = (crc << 1) | msb;
        crc ^= (msb ? 0x04C11DB6 : 0) ^ (bit ? 0x04C11DB7 : 0);
    }
    return crc;
}
