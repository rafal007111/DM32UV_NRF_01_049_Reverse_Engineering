// @addr 03011BB8
// Result: FAIL, 31 differing items of 46 instructions (medium); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks
// Oracle: python3 tools/dm32 match 03011BB8 analysis/matching/03011BB8_nmea_checksum.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* NMEA XOR checksum between '$' and '*' of the current sentence in the 1 KiB ring (read index 2FF9C,
   byte count 2FFA0) (catalog: high). */
struct nmea_ring_state { unsigned short rd; unsigned short wr; unsigned short count; };
extern struct nmea_ring_state DAT_0002ff9c;

unsigned char nmea_checksum_03011BB8(const unsigned char *ring)
{
    unsigned short idx = DAT_0002ff9c.rd;
    unsigned short n = DAT_0002ff9c.count;
    unsigned short k;
    unsigned char sum, c;

    if (n == 0)
        return 0;
    for (k = 0;; idx++) {
        if (idx >= 1024)
            idx = 0;
        if (ring[idx] == '$')
            break;
        if (++k >= n)
            return 0;
    }
    if (k >= n)
        return 0;
    sum = 0;
    for (idx++;; idx++) {
        if (idx >= 1024)
            idx = 0;
        c = ring[idx];
        if (c == '*')
            break;
        sum ^= c;
        if (++k >= n)
            break;
    }
    return sum;
}
