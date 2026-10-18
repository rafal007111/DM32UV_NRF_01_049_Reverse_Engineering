// @addr 03017BE8
// Result: FAIL, 29 differing items of 42 instructions (medium); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2
// Oracle: python3 tools/dm32 match 03017BE8 analysis/matching/03017BE8_fill_rect.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameters, locals
/* fill_rect(x0, y0, x1, y1, colour): x1/y1 exclusive, under the LCD mutex 39360 (catalog: high). */
extern int FUN_0300c500(void *sem, int ms);     /* sem_pend */
extern int FUN_0300c53c(void *sem);             /* sem_post */
extern void FUN_03017bd0(unsigned short x0, unsigned short y0, unsigned short x1, unsigned short y1);
extern void FUN_030178a4(void);                 /* LCD memory write (DCS 0x2C) */
extern void FUN_0002c1e8(unsigned short rgb565);
extern unsigned char DAT_00039360[];

void fill_rect_03017BE8(unsigned short x0, unsigned short y0, unsigned short x1, unsigned short y1,
                        unsigned short colour)
{
    unsigned short w, h, x, y;

    FUN_0300c500(DAT_00039360, 0);
    FUN_03017bd0(x0, y0, x1 - 1, y1 - 1);
    FUN_030178a4();
    w = x1 - x0;
    h = y1 - y0;
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
            FUN_0002c1e8(colour);
    FUN_0300c53c(DAT_00039360);
}
