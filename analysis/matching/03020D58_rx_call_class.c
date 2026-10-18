// @addr 03020D58
// Result: FAIL, 12 differing items of 17 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os -fno-reorder-blocks (+4 more equal)
// Oracle: python3 tools/dm32 match 03020D58 analysis/matching/03020D58_rx_call_class.c --cflags "-mcpu=ck803 -Os -fno-reorder-blocks"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Returns the RX call class: 1 private, 2 group, 3 all call (catalog: high). RX call record at 3BD48. */
struct rx_call { unsigned char type; unsigned char group_kind; };
extern struct rx_call DAT_0003bd48;

int rx_call_class_03020D58(void)
{
    if (DAT_0003bd48.type == 0)
        return 1;
    if (DAT_0003bd48.type != 1)
        return 3;
    return DAT_0003bd48.group_kind == 3 ? 3 : 2;
}
