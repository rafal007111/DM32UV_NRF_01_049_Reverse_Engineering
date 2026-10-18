// @addr 0300F780
// Result: FAIL, 10 differing items of 18 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O1 (+1 more equal)
// Oracle: python3 tools/dm32 match 0300F780 analysis/matching/0300F780_area_read.c --cflags "-mcpu=ck803 -O1"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameters, locals
/* area_read(area, off, buf, len): data-flash area read under the data-flash mutex 39468; the sector comes
   from the area directory 0300F364 (catalog: high). */
extern int FUN_0300c500(void *sem, int ms);                 /* sem_pend */
extern int FUN_0300c53c(void *sem);                         /* sem_post */
extern unsigned short FUN_0300f364(unsigned char area);     /* area -> sector */
extern void FUN_0002b9a0(unsigned short sector, unsigned short off, void *buf, unsigned short len);
extern unsigned char DAT_00039468[];

void area_read_0300F780(unsigned char area, unsigned short off, void *buf, unsigned short len)
{
    FUN_0300c500(DAT_00039468, 0);
    FUN_0002b9a0(FUN_0300f364(area), off, buf, len);
    FUN_0300c53c(DAT_00039468);
}
