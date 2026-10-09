#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "runtime_state.h"
#include "scan_step_bridge.h"
static dm32_runtime state;
static uint8_t mode;
static unsigned selections, stops, advances;
static uint16_t last_channel;
static bool read_ok = true;
static uint8_t chosen_list;
dm32_runtime *dm32_test_runtime_address(void) { return &state; }
void dm32_test_stock_boot(void) {}
uint8_t dm32_test_scan_mode(void) { return mode; }
void dm32_test_scan_set_mode(uint8_t next) { mode = next; }
void dm32_test_scan_channel(uint16_t channel) { ++selections; last_channel = channel; }
void dm32_test_scan_stop(void) { ++stops; mode = 0; }
void dm32_test_stock_list_choice(uint8_t list) { chosen_list = list; }
bool dm32_firmware_zone_next(dm32_zone_scan *scan, uint16_t *channel) {
    assert(scan == &state.zone); ++advances;
    if (!read_ok) return false;
    *channel = 547; return true;
}
int main(void) {
    unsigned before;
    dm32_runtime_initialize();
    mode = 3; dm32_scan_step_bridge(100); assert(last_channel == 100 && advances == 0);
    state.source = 1; dm32_scan_step_bridge(101); assert(last_channel == 101 && advances == 0);
    state.zone.enabled = true; mode = 0;
    dm32_scan_step_bridge(102); assert(last_channel == 102 && advances == 0);
    mode = 3; dm32_scan_step_bridge(103); assert(last_channel == 547 && advances == 1);
    dm32_scan_mode_bridge(4); assert(mode == 4 && state.zone.enabled); /* pause */
    dm32_scan_mode_bridge(6); assert(mode == 6 && state.zone.enabled); /* hold */
    dm32_scan_mode_bridge(0); assert(mode == 0 && !state.zone.enabled && state.source == 1);
    mode = 3; state.zone.enabled = true; read_ok = false; before = selections;
    dm32_scan_step_bridge(104);
    assert(stops == 1 && !state.zone.enabled && mode == 0 && selections == before);
    state.source = 1; state.zone.enabled = true;
    dm32_scan_list_choice_bridge(3);
    assert(chosen_list == 3 && state.source == 0 && !state.zone.enabled);
    memset(&state, 0, sizeof(state)); mode = 3;
    dm32_scan_step_bridge(105); assert(last_channel == 105 && advances == 2);
    puts("Scan step draft: stock forwarding, source guard, pause/hold, stop and failed read PASS");
    return 0;
}
