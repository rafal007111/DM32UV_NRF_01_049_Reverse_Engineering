// @addr 03029F9C
// Result: FAIL, 3 differing items of 9 instructions (near) (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O1 (+2 more equal)
// Oracle: python3 tools/dm32 match 03029F9C analysis/matching/03029F9C_put_le32.c --cflags "-mcpu=ck803 -O1"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* put_le32(v, p): stores v little-endian byte by byte (CPS V items, catalog: high). */
void put_le32_03029F9C(unsigned int v, unsigned char *p)
{
    p[0] = v;
    p[1] = v >> 8;
    p[2] = v >> 16;
    p[3] = v >> 24;
}
