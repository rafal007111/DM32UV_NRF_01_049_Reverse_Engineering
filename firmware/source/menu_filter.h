#ifndef DM32_MENU_FILTER_H
#define DM32_MENU_FILTER_H
#include <stdbool.h>
#include <stdint.h>
#define DM32_FILTER_SCAN 0x0du
#define DM32_FILTER_OTHER 6u
#define DM32_MAIN_MENU_CAPACITY 35u
/* Extends a stock map in place only if the complete addition fits. */
bool dm32_menu_extend(uint8_t category, uint16_t *count, uint8_t *items, uint16_t capacity);
/* Stock ABI: category in r0, uint16 count pointer in r1, byte array in r2. */
void dm32_menu_filter_bridge(uint8_t category, uint16_t *count, uint8_t *items);
#endif
