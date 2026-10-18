// @addr 0301E7B0
// Result: PASS (tiny); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -Os (+12 more equal)
// Oracle: python3 tools/dm32 match 0301E7B0 analysis/matching/0301E7B0_rx_group_entry_set.c --cflags "-mcpu=ck803 -Os"
// Attempts: 2 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int parameter + (unsigned char) cast (adopted)
/* Stores RX group list entry i at 33CF4 + 4*i (catalog: high). The 32 IDs start at radio_state + 0x2C. */
struct radio_state { unsigned int pad[11]; unsigned int rx_group[32]; };
extern struct radio_state DAT_00033cc8;
void rx_group_entry_set_0301E7B0(int i, unsigned int id) { DAT_00033cc8.rx_group[(unsigned char)i] = id; }
