#include "scan_prepare.h"
static void word(uint8_t *where, uint16_t value) {
    where[0] = (uint8_t)value; where[1] = (uint8_t)(value >> 8);
}
bool dm32_scan_prepare_slots(uint8_t state[96], uint16_t first_channel,
                            uint16_t origin_channel, const uint8_t origin_name[17],
                            bool preserve_stock_policy) {
    uint8_t i;
    if (!state || !origin_name || first_channel < 1 || first_channel > 4000 ||
        origin_channel < 1 || origin_channel > 4000) return false;
    if (!preserve_stock_policy) {
        state[2] = 0; /* Stock PTT fallback selects the user's configured channel. */
        state[3] = 6; /* Same default initialized by stock 0x0302f780. */
        for (i = 6; i <= 12; ++i) state[i] = 0;
        for (i = 0; i < 17; ++i) state[0x42 + i] = origin_name[i];
        state[0x4c] = 0; /* Preserve the stock display-name truncation. */
        word(state + 0x58, origin_channel);
    }
    state[1] = 2;
    state[4] = 0; /* No scan-list priority channels in a whole-zone iterator. */
    word(state + 8, 0); word(state + 10, 0);
    state[0x0e] = 0;
    word(state + 0x16, first_channel);
    word(state + 0x18, first_channel);
    state[0x5c] = 2;
    return true;
}
