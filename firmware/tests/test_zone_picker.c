#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "zone_picker.h"
typedef struct { unsigned rows, read_count, selected_rows; uint8_t first_zone, last_zone; bool fail; } fixture;
static bool count_zone(void *context, uint8_t zone, uint8_t *count) {
    fixture *f = (fixture *)context; ++f->read_count;
    if (f->fail || zone == 2) return false;
    *count = 49; return true;
}
static bool channel_zone(void *context, uint8_t zone, uint8_t pos, uint16_t *channel) {
    (void)context; (void)zone; *channel = pos; return true;
}
static bool name_zone(void *context, uint8_t zone, char name[17]) {
    fixture *f = (fixture *)context;
    if (!f->rows) f->first_zone = zone;
    f->last_zone = zone;
    memset(name, 'Z', 17); /* renderer must terminate fixed-width firmware names */
    return !f->fail;
}
static void draw_zone(void *context, uint8_t row, const char *name, bool selected) {
    fixture *f = (fixture *)context;
    assert(row == f->rows + 1 && name[16] == 0);
    ++f->rows; if (selected) ++f->selected_rows;
}
int main(void) {
    unsigned total, i;
    dm32_zone_picker picker = {0};
    dm32_zone_scan scan, previous;
    fixture f = {0};
    dm32_zone_reader reader = {&f, count_zone, channel_zone};
    dm32_zone_init(&scan); scan.zone_id = 22; scan.cursor = 5;
    previous = scan;
    for (total = 1; total <= 250; ++total) {
        assert(dm32_picker_open(&picker, (uint8_t)total, (uint8_t)total));
        for (i = 0; i < total; ++i) {
            memset(&f, 0, sizeof(f));
            assert(dm32_picker_rows(&picker, &f, name_zone, draw_zone));
            assert(f.rows >= 1 && f.rows <= 8 && f.selected_rows == 1);
            assert(f.first_zone >= 1 && f.last_zone <= total);
            assert(dm32_picker_move(&picker, true));
        }
        assert(picker.selected == total - 1);
        assert(dm32_picker_move(&picker, true) && picker.selected == 0);
        assert(dm32_picker_move(&picker, false) && picker.selected == total - 1);
    }
    assert(memcmp(&scan, &previous, sizeof(scan)) == 0); /* browse never changes source */
    assert(dm32_picker_open(&picker, 22, 0));
    dm32_picker_cancel(&picker);
    assert(memcmp(&scan, &previous, sizeof(scan)) == 0 && !picker.open);
    assert(dm32_picker_open(&picker, 22, 2));
    memset(&f, 0, sizeof(f));
    assert(!dm32_picker_confirm(&picker, &scan, &reader, false));
    assert(picker.open && memcmp(&scan, &previous, sizeof(scan)) == 0);
    assert(dm32_picker_open(&picker, 22, 7));
    assert(!dm32_picker_confirm(&picker, &scan, &reader, true));
    assert(f.read_count == 1); /* active-scan guard precedes reading */
    assert(dm32_picker_confirm(&picker, &scan, &reader, false));
    assert(scan.zone_id == 7 && scan.cursor == 0 && !scan.enabled && !picker.open);
    assert(!dm32_picker_open(&picker, 0, 1));
    assert(!dm32_picker_open(&picker, 251, 1));
    puts("Zone picker: all 1..250 zone counts, pagination, wrap, cancellation and source-only confirmation PASS");
    return 0;
}
