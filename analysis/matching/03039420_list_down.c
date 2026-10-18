// @addr 03039420
// Result: PASS (small); toolchain T-HEAD V3.10.29 B20210423 (pinned)
// Best flags: -mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping
// Oracle: python3 tools/dm32 match 03039420 analysis/matching/03039420_list_down.c --cflags "-mcpu=ck803 -O2 -fno-reorder-blocks -fno-crossjumping"
// Attempts: 3 source variant(s) x 13 flag sets (analysis/matching/pilot.py); variant tried: int count + (unsigned char) cast (adopted); local unsigned char count
/* list_down(&row, &index, count): list cursor down for an 8-row window; wraps from the last item to
   row 1 / index 0 (catalog: high). */
void list_down_03039420(unsigned char *row, unsigned char *index, int count)
{
    if (*index == (unsigned char)count - 1) {
        *index = 0;
        *row = 1;
    } else if (*row == 8) {
        *index = *index + 1;
    } else {
        *index = *index + 1;
        *row = *row + 1;
    }
}
