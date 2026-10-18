// @addr 0300F71C
// Result: FAIL, 35 differing items of 38 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2
// Oracle: python3 tools/dm32 match 0300F71C analysis/matching/0300F71C_sector_read.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameters, locals
/* sector_read(sector, off, buf, len): data-flash read under the mutex 39468; a read that crosses a
   256-byte page is split in two flash_read calls (catalog: high). */
extern int FUN_0300c500(void *sem, int ms);     /* sem_pend */
extern int FUN_0300c53c(void *sem);             /* sem_post */
extern void FUN_0002b9a0(unsigned short sector, unsigned short off, unsigned char *buf, unsigned short len);
extern unsigned char DAT_00039468[];

void sector_read_0300F71C(unsigned short sector, unsigned short off, unsigned char *buf, unsigned short len)
{
    unsigned int o, page_end;
    unsigned short first;

    FUN_0300c500(DAT_00039468, 0);
    o = off & 0xFFF;
    page_end = (o & 0xF00) + 256;
    if (len + o <= page_end) {
        FUN_0002b9a0(sector, off, buf, len);
    } else {
        first = (o & 0xF00) - o + 256;
        FUN_0002b9a0(sector, off, buf, first);
        FUN_0002b9a0(sector, page_end, buf + first, len - first);
    }
    FUN_0300c53c(DAT_00039468);
}
