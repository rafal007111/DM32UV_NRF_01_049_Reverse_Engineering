// @addr 0300C3B4
// Result: PASS (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 0300C3B4 analysis/matching/0300C3B4_tx_admit_policy_set.c --cflags "-mcpu=ck803 -Os"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Sets the TX admit policy 33CD0 (catalog: high). */
struct radio_state { unsigned char pad[0x08]; unsigned char tx_admit_policy; };
extern struct radio_state DAT_00033cc8;

void tx_admit_policy_set_0300C3B4(unsigned char policy)
{
    DAT_00033cc8.tx_admit_policy = policy;
}
