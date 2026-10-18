// @addr 0002C58C
// Result: FAIL, 19 differing items of 30 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2
// Oracle: python3 tools/dm32 match 0002C58C analysis/matching/0002C58C_gpio_read.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* gpio_read(n): input level of GPIO n from EXT_PORTA (+0x50) of port A/B/C (catalog: high). */
#define REG32(a) (*(volatile unsigned int *)(a))

int gpio_read_0002C58C(unsigned int n)
{
    if (n < 32)
        return (REG32(0x14020050) & (1u << n)) != 0;
    if (n < 64)
        return (REG32(0x14100050) & (1u << (n - 32))) != 0;
    return (REG32(0x14110050) & (1u << (n - 64))) != 0;
}
