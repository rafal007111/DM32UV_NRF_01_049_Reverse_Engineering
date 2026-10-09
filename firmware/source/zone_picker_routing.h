#ifndef DM32_ZONE_PICKER_ROUTING_H
#define DM32_ZONE_PICKER_ROUTING_H
#include <stdint.h>
/* Replace ONLY the main key read call and the two calls to stock Scan confirmation. */
uint8_t dm32_picker_key_read_bridge(void);
void dm32_picker_entry_bridge(void);
void dm32_picker_render_bridge(void);
#endif
