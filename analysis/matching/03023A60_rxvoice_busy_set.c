// @addr 03023A60
// Result: FAIL, 2 differing items of 4 instructions (near) (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 03023A60 analysis/matching/03023A60_rxvoice_busy_set.c --cflags "-mcpu=ck803 -Os"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Sets the rxvoice busy flag 33CDD = 1 (catalog: high). */
struct radio_state { unsigned char pad[0x15]; unsigned char rxvoice_busy; };
extern struct radio_state DAT_00033cc8;

void rxvoice_busy_set_03023A60(void)
{
    DAT_00033cc8.rxvoice_busy = 1;
}
