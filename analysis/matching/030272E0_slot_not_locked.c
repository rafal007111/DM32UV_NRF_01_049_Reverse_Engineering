// @addr 030272E0
// Result: PASS (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 030272E0 analysis/matching/030272E0_slot_not_locked.c --cflags "-mcpu=ck803 -Os"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Returns 1 when the slot is not locked (3BEB1 != 1) (catalog: high). DMR slot state block at 3BEA8. */
struct slot_state { unsigned char pad[9]; unsigned char slot_lock; };
extern struct slot_state DAT_0003bea8;

int slot_not_locked_030272E0(void)
{
    return DAT_0003bea8.slot_lock != 1;
}
