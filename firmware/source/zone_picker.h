#ifndef DM32_ZONE_PICKER_H
#define DM32_ZONE_PICKER_H
#include "mod_core.h"
/* Independent of the stock editable Zone List and its active-zone globals. */
typedef struct { uint8_t total, selected; bool open; } dm32_zone_picker;
typedef bool (*dm32_read_zone_name)(void *context, uint8_t zone, char name[17]);
typedef void (*dm32_draw_zone_row)(void *context, uint8_t row, const char *name, bool selected);
bool dm32_picker_open(dm32_zone_picker *picker, uint8_t total, uint8_t prior_zone);
bool dm32_picker_move(dm32_zone_picker *picker, bool forward);
void dm32_picker_cancel(dm32_zone_picker *picker);
bool dm32_picker_confirm(dm32_zone_picker *picker, dm32_zone_scan *scan,
                         const dm32_zone_reader *reader, bool scan_active);
bool dm32_picker_rows(const dm32_zone_picker *picker, void *context,
                     dm32_read_zone_name read_name, dm32_draw_zone_row draw_row);
#endif
