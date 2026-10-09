#ifndef DM32_SCAN_STEP_BRIDGE_H
#define DM32_SCAN_STEP_BRIDGE_H
#include <stdint.h>
/* Draft scanner hooks. New-source start/preparation is not implemented yet. */
void dm32_scan_step_bridge(uint16_t stock_channel);
void dm32_scan_mode_bridge(uint8_t mode);
void dm32_scan_list_choice_bridge(uint8_t list);
#endif
