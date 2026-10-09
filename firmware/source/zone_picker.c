#include "zone_picker.h"

static bool valid(const dm32_zone_picker *picker) {
    return picker && picker->open && picker->total >= 1 && picker->total <= 250 &&
           picker->selected < picker->total;
}

bool dm32_picker_open(dm32_zone_picker *picker, uint8_t total, uint8_t prior_zone) {
    if (!picker || total < 1 || total > 250) return false;
    picker->total = total;
    picker->selected = (prior_zone >= 1 && prior_zone <= total) ? (uint8_t)(prior_zone - 1) : 0;
    picker->open = true;
    return true;
}

bool dm32_picker_move(dm32_zone_picker *picker, bool forward) {
    if (!valid(picker)) return false;
    if (forward) picker->selected = (picker->selected + 1 == picker->total) ? 0 : (uint8_t)(picker->selected + 1);
    else picker->selected = picker->selected ? (uint8_t)(picker->selected - 1) : (uint8_t)(picker->total - 1);
    return true;
}

void dm32_picker_cancel(dm32_zone_picker *picker) {
    if (picker) picker->open = false;
}

bool dm32_picker_confirm(dm32_zone_picker *picker, dm32_zone_scan *scan,
                         const dm32_zone_reader *reader, bool scan_active) {
    if (!valid(picker) || !scan || scan_active || scan->enabled) return false;
    if (!dm32_zone_select(scan, reader, (uint8_t)(picker->selected + 1))) return false;
    picker->open = false;
    return true;
}

bool dm32_picker_rows(const dm32_zone_picker *picker, void *context,
                     dm32_read_zone_name read_name, dm32_draw_zone_row draw_row) {
    uint8_t first, row, index;
    char name[17];
    if (!valid(picker) || !read_name || !draw_row) return false;
    first = (uint8_t)(picker->selected & 0xf8u);
    for (row = 0; row < 8; ++row) {
        index = (uint8_t)(first + row);
        if (index >= picker->total) break;
        if (!read_name(context, (uint8_t)(index + 1), name)) return false;
        name[16] = 0;
        draw_row(context, (uint8_t)(row + 1), name, index == picker->selected);
    }
    return true;
}
