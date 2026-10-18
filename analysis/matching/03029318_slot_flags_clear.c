// @addr 03029318
// Result: PASS (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O1 (+2 more equal)
// Oracle: python3 tools/dm32 match 03029318 analysis/matching/03029318_slot_flags_clear.c --cflags "-mcpu=ck803 -O1"
// Attempts: 1 source variant(s) x 13 flag sets (analysis/matching/pilot.py)
/* Clears the per-slot voice/data flags 3C620..3C623 and 3C61D, sets the last RX CC 3C61A = 0xFF and
   clears 3F722 (catalog: high). */
struct slot_flags {
    unsigned char pad0[6];
    unsigned char last_cc;      /* 3C61A */
    unsigned char pad1[2];
    unsigned char flag_61d;     /* 3C61D */
    unsigned char pad2[2];
    unsigned char voice[2];     /* 3C620, 3C621 */
    unsigned char data[2];      /* 3C622, 3C623 */
};
struct privacy_rx { unsigned char pad[2]; unsigned char flag; };
extern struct slot_flags DAT_0003c614;
extern struct privacy_rx DAT_0003f720;

void slot_flags_clear_03029318(void)
{
    DAT_0003c614.data[0] = 0;
    DAT_0003c614.data[1] = 0;
    DAT_0003c614.voice[0] = 0;
    DAT_0003c614.voice[1] = 0;
    DAT_0003c614.flag_61d = 0;
    DAT_0003c614.last_cc = 0xFF;
    DAT_0003f720.flag = 0;
}
