// @addr 0300C154
// Result: FAIL, 38 differing items of 33 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+1 more equal)
// Oracle: python3 tools/dm32 match 0300C154 analysis/matching/0300C154_crc9_bits.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int nbits, local unsigned char
/* DMR CRC-9 (polynomial 0x59, 9-bit register) over nbits bits of data, MSB first (confirmed-data block
   CRC; catalog: high). Same structure as the CRC-32 at 0300C224. */
unsigned int crc9_bits_0300C154(unsigned int crc, unsigned char nbits, const unsigned char *data)
{
    unsigned short i;
    unsigned int msb;
    unsigned char byte = 0;
    unsigned char bit;

    crc &= 0x1FF;
    for (i = 0; i < nbits; i++) {
        if ((i & 7) == 0)
            byte = data[i >> 3];
        bit = (byte << (i & 7)) & 0x80;
        msb = crc >> 8;
        crc = ((crc << 1) | msb) & 0x1FF;
        crc ^= (msb ? 0x58 : 0) ^ (bit ? 0x59 : 0);
    }
    return crc;
}
