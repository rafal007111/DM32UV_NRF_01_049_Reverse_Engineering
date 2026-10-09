#ifndef DM32_FIRMWARE_ZONE_BRIDGE_H
#define DM32_FIRMWARE_ZONE_BRIDGE_H
#include "mod_core.h"
/* NRF.01.049-specific backend. Callers must supply verified RAM storage for state. */
bool dm32_firmware_zone_select(dm32_zone_scan *state, uint8_t zone);
bool dm32_firmware_zone_switch(dm32_zone_scan *state, bool enabled);
bool dm32_firmware_zone_next(dm32_zone_scan *state, uint16_t *channel);
#endif
