#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "runtime_state.h"
#include "zone_picker_ui.h"
static dm32_runtime state;
static uint8_t scan_mode, total = 22;
static unsigned rows, highlights, refreshes, reads, clears, pending_rows, last_rows;
static uint8_t selected_rows[9];
static unsigned starts, stops, errors, marks, stock_marks;

void dm32_test_picker_stop(void) { ++stops; scan_mode=0; state.zone.enabled=false; }
bool dm32_test_picker_start(uint32_t command) { assert(command==1); ++starts; scan_mode=1; state.zone.enabled=true; return true; }
void dm32_test_picker_error(uint8_t code) { assert(code==0x1b); ++errors; }
void dm32_test_picker_mark(uint16_t row, bool selected) { assert(row>=1 && row<=8); (void)selected; ++marks; }
void dm32_test_list_tick(uint16_t x,uint16_t y,uint16_t width,uint16_t bytes,const void *glyph,uint16_t color) {
    assert(x==8 && y==40 && width==24 && bytes==72);
    assert(glyph==(const void *)(uintptr_t)0x03082be0u && color==0xffff);
    ++stock_marks;
}

dm32_runtime *dm32_test_runtime_address(void) { return &state; }
void dm32_test_stock_boot(void) {}
uint8_t dm32_test_scan_mode(void) { return scan_mode; }
void dm32_test_zone_locator(uint8_t zone, uint16_t *block, uint16_t *offset) {
    unsigned index = zone - 1;
    *block = (uint16_t)(0x5c + index / 28);
    *offset = (uint16_t)((index % 28) * 145 + (*block == 0x5c ? 16 : 0));
}
void dm32_test_firmware_read(uint8_t block, uint16_t offset, void *out, uint16_t size) {
    unsigned record_offset;
    assert(block >= 0x5c && block <= 0x64 && offset + size <= 4095);
    ++reads;
    if (block == 0x5c && offset == 0 && size == 1) { *(uint8_t *)out = total; return; }
    record_offset = (offset - (block == 0x5c ? 16 : 0)) % 145;
    if (size == 16 && record_offset == 0) memset(out, 'Z', 16);
    else if (size == 1 && record_offset == 16) *(uint8_t *)out = 49;
    else { assert(0); }
}
void dm32_test_clear(uint16_t color) { assert(color == 0); ++clears; }
void dm32_test_rectangle(uint16_t x, uint16_t y, uint16_t right, uint16_t bottom, uint16_t color) {
    assert(x == 0 && y == 0 && right == 240 && bottom == 27 && color == 0);
}
void dm32_test_text(uint16_t pos, uint16_t fg, uint16_t bg, const char *text) {
    assert(pos == 1 && fg == 0xffff && bg == 0 && strcmp(text, "Scan Zone") == 0);
}
void dm32_test_row(uint16_t row, const char *name, uint8_t selected) {
    assert(row >= 1 && row <= 8 && strlen(name) == 16);
    ++rows; ++pending_rows; selected_rows[row] = selected;
}
void dm32_test_scroll(uint16_t selected, uint16_t count) { assert(selected < count && count == total); }
void dm32_test_refresh(void) {
    unsigned i;
    highlights = 0;
    for (i = 1; i <= 8; ++i) highlights += selected_rows[i];
    assert(highlights == 1 && pending_rows <= 8);
    last_rows = pending_rows; pending_rows = 0; ++refreshes;
}
int main(void) {
    unsigned before_reads;
    dm32_runtime_initialize();
    state.zone.zone_id = 22;
    assert(dm32_picker_ui_open());
    assert(dm32_picker_ui_render() && last_rows == 8 && refreshes == 1);
    assert(dm32_picker_ui_move(true) && last_rows == 8 && state.picker.selected == 0);
    assert(dm32_picker_ui_move(true) && last_rows == 2 && state.picker.selected == 1);
    assert(dm32_picker_ui_move(false) && last_rows == 2 && state.picker.selected == 0);
    assert(dm32_picker_ui_move(false) && last_rows == 8 && state.picker.selected == 21);
    assert(clears == 0); /* No black full-screen frame, including page changes. */
    dm32_picker_ui_cancel();
    assert(!state.picker.open && state.source == 0 && state.zone.zone_id == 22);
    assert(dm32_picker_ui_open());
    scan_mode = 3; before_reads = reads;
    assert(!dm32_picker_ui_confirm() && !dm32_picker_ui_open() && reads == before_reads);
    scan_mode = 0;
    assert(dm32_picker_ui_move(true));
    assert(dm32_picker_ui_confirm());
    assert(state.source == 1 && state.zone.zone_id == 1 && !state.zone.enabled && !state.picker.open);
    scan_mode=1; state.zone.enabled=true;
    assert(dm32_picker_ui_open() && stops==1 && scan_mode==0);
    assert(dm32_picker_ui_render() && marks==1);
    assert(dm32_picker_ui_move(true));
    assert(dm32_picker_ui_confirm() && state.zone.zone_id==2 && starts==1 && scan_mode==1);
    assert(dm32_picker_ui_open() && stops==2);
    assert(dm32_picker_ui_move(true));
    dm32_picker_ui_back();
    assert(state.zone.zone_id==2 && starts==2 && scan_mode==1);
    assert(dm32_picker_ui_open());
    dm32_picker_ui_cancel(); /* External events cancel without restarting before PTT. */
    assert(starts==2 && scan_mode==0 && errors==0);
    dm32_scan_list_tick_bridge(8,40,24,72,(const void *)(uintptr_t)0x03082be0u,0xffff);
    assert(stock_marks==0); /* Zone source suppresses the actual list tick. */
    state.source=0;
    dm32_scan_list_tick_bridge(8,40,24,72,(const void *)(uintptr_t)0x03082be0u,0xffff);
    assert(stock_marks==1);
    state.magic=0; state.source=1;
    dm32_scan_list_tick_bridge(8,40,24,72,(const void *)(uintptr_t)0x03082be0u,0xffff);
    assert(stock_marks==2); /* Invalid state forwards all six arguments unchanged. */
    dm32_runtime_initialize();
    total = 0; assert(!dm32_picker_ui_open());
    total = 251; assert(!dm32_picker_ui_open());
    state.magic = 0; before_reads = reads;
    assert(!dm32_picker_ui_open() && !dm32_picker_ui_render() && reads == before_reads);
    puts("Native picker adapter: read-only bindings, row rendering, cancellation and selection without scan start PASS");
    return 0;
}
