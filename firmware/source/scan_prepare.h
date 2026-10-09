#ifndef DM32_SCAN_PREPARE_H
#define DM32_SCAN_PREPARE_H
#include <stdbool.h>
#include <stdint.h>
/* Internal stock state remains a 16-slot structure; only two virtual slots are used. */
bool dm32_scan_prepare_slots(uint8_t state[96], uint16_t first_channel,
                            uint16_t origin_channel, const uint8_t origin_name[17],
                            bool preserve_stock_policy);
#endif
