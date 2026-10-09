#ifndef DM32_SCAN_START_BRIDGE_H
#define DM32_SCAN_START_BRIDGE_H
#include <stdbool.h>
#include <stdint.h>
/* Experimental inactive draft: requires scan_start_tail.S and native ABI review. */
bool dm32_scan_start_bridge(uint32_t explicit_start);
#endif
