// @addr 0301EC40
// Result: FAIL, 20 differing items of 24 instructions (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks (+2 more equal)
// Oracle: python3 tools/dm32 match 0301EC40 analysis/matching/0301EC40_monitor_flag_set.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Monitor flag setter: 3BA6C bit 3 = on, HR_C7000 11000384 bits 9:8 = on ? 1 : 0, 3C61B = on ? 8 : 0
   (catalog: high). */
#define REG32(a) (*(volatile unsigned int *)(a))
struct call_state {
    unsigned char pad[0x18];
    unsigned char rx_hang : 1, stun : 1, unused2 : 1, monitor : 1, rest : 4;  /* 3BA6C */
};
struct slot_flags { unsigned char pad[7]; unsigned char monitor_slot; };  /* 3C61B */
extern struct call_state DAT_0003ba54;
extern struct slot_flags DAT_0003c614;

void monitor_flag_set_0301EC40(unsigned char on)
{
    unsigned int r;

    DAT_0003ba54.monitor = on;
    r = REG32(0x11000384) & ~0x300u;
    if (DAT_0003ba54.monitor) {
        DAT_0003c614.monitor_slot = 8;
        r |= 0x100;
    } else {
        DAT_0003c614.monitor_slot = 0;
    }
    REG32(0x11000384) = r;
}
