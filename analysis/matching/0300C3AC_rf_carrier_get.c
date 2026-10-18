// @addr 0300C3AC
// Result: PASS (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 0300C3AC analysis/matching/0300C3AC_rf_carrier_get.c --cflags "-mcpu=ck803 -Os"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Returns the RF carrier flag 33CDC (catalog: high). Radio state block at 33CC8. */
struct radio_state { unsigned char pad[0x14]; unsigned char rf_carrier; };
extern struct radio_state DAT_00033cc8;

unsigned char rf_carrier_get_0300C3AC(void)
{
    return DAT_00033cc8.rf_carrier;
}
