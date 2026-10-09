#ifndef DM32_ZONE_PICKER_UI_H
#define DM32_ZONE_PICKER_UI_H
#include <stdbool.h>
#include <stdint.h>
/* Native UI endpoints. Key/menu call sites are not installed yet. */
bool dm32_picker_ui_open(void);
bool dm32_picker_ui_render(void);
bool dm32_picker_ui_move(bool forward);
bool dm32_picker_ui_confirm(void);
void dm32_picker_ui_cancel(void);
void dm32_picker_ui_back(void);
void dm32_scan_list_tick_bridge(uint16_t x, uint16_t y, uint16_t width,
                               uint16_t bytes, const void *glyph, uint16_t color);
#endif
