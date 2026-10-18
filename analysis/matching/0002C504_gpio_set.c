// @addr 0002C504
// Result: FAIL, 18 differing items of 27 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2
// Oracle: python3 tools/dm32 match 0002C504 analysis/matching/0002C504_gpio_set.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping -fno-schedule-insns2"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* gpio_set(n): ORs 1 << (n % 32) into the output-data register of port A/B/C (0x14020000, 0x14100000,
   0x14110000) (catalog: high). */
#define REG32(a) (*(volatile unsigned int *)(a))

void gpio_set_0002C504(unsigned int n)
{
    if (n < 32)
        REG32(0x14020000) |= 1u << n;
    else if (n < 64)
        REG32(0x14100000) |= 1u << (n - 32);
    else
        REG32(0x14110000) |= 1u << (n - 64);
}
