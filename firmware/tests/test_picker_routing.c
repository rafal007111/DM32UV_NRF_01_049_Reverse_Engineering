#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "runtime_state.h"
#include "zone_picker_routing.h"
static dm32_runtime state;
static volatile uint8_t scene[8], mode_flags, indices[8], scan_map[37];
static volatile uint16_t current_count;
static volatile uint8_t current_items[35], current_index;
static unsigned dequeues, stock_confirms, redraws, renders, errors, lock_depth;
static uint8_t next_key;
static bool open_ok = true, confirm_ok = true;
dm32_runtime *dm32_test_runtime_address(void) { return &state; }
void dm32_test_stock_boot(void) {}
volatile uint8_t *dm32_test_scene(void) { return scene; }
volatile uint8_t *dm32_test_mode_flags(void) { return &mode_flags; }
volatile uint8_t *dm32_test_menu_indices(void) { return indices; }
volatile uint8_t *dm32_test_scan_map(void) { return scan_map; }
volatile uint16_t *dm32_test_current_count(void) { return &current_count; }
volatile uint8_t *dm32_test_current_items(void) { return current_items; }
volatile uint8_t *dm32_test_current_index(void) { return &current_index; }
uint8_t dm32_test_key_read(void) { assert(lock_depth == 0); ++dequeues; return next_key; }
void dm32_test_scan_confirm(void) { ++stock_confirms; }
void dm32_test_ui_lock(void) { assert(lock_depth == 0); ++lock_depth; }
void dm32_test_ui_unlock(void) { assert(lock_depth == 1); --lock_depth; }
void dm32_test_ui_redraw(void) { assert(lock_depth == 1 && scene[4] == 0); ++redraws; }
void dm32_test_ui_error(uint8_t code) { assert(code == 0x1b && lock_depth == 1); ++errors; }
bool dm32_picker_ui_open(void) {
    assert(lock_depth == 1);
    if (!open_ok) return false;
    state.picker.open = true; state.picker.total = 22; state.picker.selected = 0; return true;
}
bool dm32_picker_ui_render(void) { assert(lock_depth == 1); ++renders; return true; }
bool dm32_picker_ui_move(bool forward) {
    assert(lock_depth == 1);
    state.picker.selected = forward ? 1 : 0; ++renders; return true;
}
bool dm32_picker_ui_confirm(void) {
    assert(lock_depth == 1);
    if (!confirm_ok) return false;
    state.zone.zone_id = (uint8_t)(state.picker.selected + 1);
    state.source = 1; state.picker.open = false; return true;
}
void dm32_picker_ui_cancel(void) { assert(lock_depth == 1); state.picker.open = false; }
void dm32_picker_ui_back(void) { dm32_picker_ui_cancel(); }
static uint8_t key(uint8_t event) {
    unsigned before = dequeues; uint8_t result;
    next_key = event; result = dm32_picker_key_read_bridge();
    assert(dequeues == before + 1 && lock_depth == 0); return result;
}
static void enter(void) {
    assert(key(5) == 5); /* stock dispatcher sees confirm before calling its callback */
    scene[3] = 0x1a; scene[4] = 1;
    lock_depth = 1; dm32_picker_entry_bridge(); lock_depth = 0;
    assert(scene[3] == 0x15 && scene[4] == 0);
}
int main(void) {
    unsigned before;
    dm32_runtime_initialize();
    scene[3] = 0x15; indices[2] = 2; scan_map[4] = 9;
    assert(key(0xfe) == 0xfe);
    lock_depth = 1; dm32_picker_entry_bridge(); lock_depth = 0;
    assert(stock_confirms == 1 && !state.picker.open); /* redraw must not open picker */
    enter(); assert(state.picker.open && stock_confirms == 1);
    before = redraws;
    lock_depth = 1; dm32_picker_render_bridge(); lock_depth = 0;
    assert(redraws == before); /* periodic redraw remains the picker */
    assert(key(2) == 0xff && state.picker.selected == 1);
    assert(key(1) == 0xff && state.picker.selected == 0);
    assert(key(0xfe) == 0xff);
    confirm_ok = false; before = redraws;
    assert(key(5) == 0xff && state.picker.open && redraws == before && errors == 1);
    confirm_ok = true;
    assert(key(5) == 0xff && !state.picker.open && state.source == 1 && !state.zone.enabled);
    enter(); before = state.zone.zone_id;
    assert(key(6) == 0xff && !state.picker.open && state.zone.zone_id == before);
    enter(); before = redraws;
    assert(key(0x13) == 0x13 && !state.picker.open && redraws == before + 1); /* PTT passed through */
    enter(); scene[3] = 0x4d; before = redraws;
    assert(key(2) == 2 && !state.picker.open && scene[3] == 0x4d && redraws == before);
    scene[3] = 0x15; enter(); scene[3] = 0x4d; before = redraws;
    lock_depth = 1; dm32_picker_render_bridge(); lock_depth = 0;
    assert(!state.picker.open && scene[3] == 0x4d && redraws == before + 1);
    scene[3] = 0x15; open_ok = false; enter(); assert(!state.picker.open && errors == 2);
    open_ok = true; scan_map[4] = 0;
    assert(key(5) == 5); lock_depth = 1; dm32_picker_entry_bridge(); lock_depth = 0;
    assert(stock_confirms == 2); /* ordinary Scan selection remains stock */
    dm32_runtime_initialize(); scene[3] = 0x0e; scene[4] = 1;
    current_count = 6; current_index = 2;
    current_items[0] = 0; current_items[1] = 1; current_items[2] = 9;
    scan_map[4] = 0; /* Saved map has not been pushed by stock confirmation yet. */
    before = stock_confirms;
    assert(key(5) == 0xff && state.picker.open && scene[3] == 0x0e && scene[4] == 0);
    assert(stock_confirms == before && state.picker_origin_scene == 0x0e);
    assert(key(0xfe) == 0xff && state.picker.open);
    assert(key(6) == 0xff && !state.picker.open && scene[3] == 0x0e);
    current_index = 1;
    assert(key(5) == 5 && !state.picker.open); /* Scan List stays stock. */
    current_index = 2; scene[3] = 7;
    assert(key(5) == 5 && !state.picker.open); /* Other menu stays stock. */
    scene[3] = 0x0e; current_index = 35;
    assert(key(5) == 5 && !state.picker.open); /* Bounds guard. */
    current_index = 2; current_count = 36;
    assert(key(5) == 5 && !state.picker.open);
    memset(&state, 0, sizeof(state)); assert(key(2) == 2); /* not initialized */
    puts("Picker routing: one dequeue, scoped confirmation, redraw, cancel, locking and stock-event passthrough PASS");
    return 0;
}
