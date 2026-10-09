#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "scan_prepare.h"
static unsigned getword(const unsigned char *p) { return p[0] | ((unsigned)p[1] << 8); }
int main(void) {
    unsigned char state[96], saved[96], name[17]; unsigned i;
    memset(name, 'O', sizeof(name)); name[16] = 0;
    memset(state, 0xa5, sizeof(state)); memcpy(saved, state, sizeof(state));
    assert(!dm32_scan_prepare_slots(state, 0, 547, name, false));
    assert(memcmp(state, saved, sizeof(state)) == 0);
    assert(dm32_scan_prepare_slots(state, 4000, 547, name, false));
    assert(state[0] == 0xa5 && state[1] == 2 && state[0x5c] == 2 && state[0xe] == 0);
    assert(state[2] == 0 && state[3] == 6 && state[4] == 0);
    assert(getword(state + 0x16) == 4000 && getword(state + 0x18) == 4000);
    assert(getword(state + 0x58) == 547 && state[0x4c] == 0);
    assert(memcmp(state + 0x1a, saved + 0x1a, 0x42 - 0x1a) == 0);
    assert(memcmp(state + 0x10, saved + 0x10, 6) == 0); /* flags, mode, current target */
    memset(state, 0xa5, sizeof(state)); state[2] = 0x21; state[3] = 19;
    state[6] = 0x23; state[7] = 1; state[0x58] = 7; state[0x59] = 0;
    memcpy(saved, state, sizeof(state));
    assert(dm32_scan_prepare_slots(state, 49, 547, name, true));
    assert(state[2] == 0x21 && state[3] == 19 && getword(state + 6) == 291);
    assert(getword(state + 0x58) == 7 && memcmp(state + 0x42, saved + 0x42, 17) == 0);
    for (i = 0; i < 96; ++i) if (i < 1 || i > 0x5c) assert(state[i] == saved[i]);
    puts("Scan prepare draft: two bounded slots, policy preservation, defaults and untouched unrelated fields PASS");
    return 0;
}
