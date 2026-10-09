#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "runtime_state.h"
#include "scan_start_bridge.h"
static dm32_runtime state;
static uint8_t stock[96], config[51], radio[128], aux[64], mode;
static unsigned stock_calls, list_calls, basic_calls, tails, stops, reads;
static bool count_ok = true, channel_ok = true, list_ok = true;
bool dm32_test_scan_zone_name(uint8_t zone, uint8_t *name) {
    assert(zone>=1 && zone<=250); memcpy(name,"ZONE NAME",10); name[16]=0; return true;
}
dm32_runtime *dm32_test_runtime_address(void) { return &state; }
void dm32_test_stock_boot(void) {}
uint8_t *dm32_test_scan_state(void) { return stock; }
uint8_t *dm32_test_channel_config(void) { return config; }
uint8_t *dm32_test_radio_config(void) { return radio; }
uint8_t *dm32_test_radio_aux(void) { return aux; }
uint8_t dm32_test_scan_mode(void) { return mode; }
void dm32_test_scan_set_mode(uint8_t next) { mode = next; }
void dm32_test_scan_stop(void) { assert(!state.zone.enabled); mode = 0; ++stops; }
bool dm32_test_stock_start(uint32_t command) { assert(command <= 1); ++stock_calls; return true; }
void dm32_test_prepare_list(uint8_t list) {
    assert(list == 2 && mode == 0); ++list_calls;
    stock[0x5c] = list_ok ? 16 : 0; stock[2] = 0x21; stock[3] = 19;
    memcpy(stock+0x42,"TX CHANNEL",11); stock[6] = 0x23; stock[7] = 1; stock[4] = 0x22; stock[0x58] = 7;
}
void dm32_test_prepare_basic(void) { assert(mode == 0); ++basic_calls; }
uint16_t dm32_test_current_channel(uint8_t zone, uint8_t channel) {
    assert(zone == 11 && channel == 3); return 547;
}
bool dm32_test_start_tail(uint32_t explicit_start) {
    assert(memcmp(stock+0x36,"ZONE NAME",9)==0 && stock[0x41]==0);
    assert(memcmp(stock+0x42,stock[2]==0x21 ? "TX CHANNEL" : "ORIGIN",stock[2]==0x21 ? 10 : 6)==0);
    assert(mode == 0 && stock[1] == 2 && stock[0x5c] == 2 && stock[4] == 0 && stock[0xe] == 0);
    ++tails;
    if (explicit_start || (stock[0x10] & 0x80)) mode = 1;
    return true;
}
bool dm32_firmware_zone_switch(dm32_zone_scan *scan, bool on) {
    assert(scan == &state.zone && on); ++reads;
    if (!count_ok) return false;
    scan->enabled = true; return true;
}
bool dm32_firmware_zone_next(dm32_zone_scan *scan, uint16_t *channel) {
    assert(scan == &state.zone && scan->enabled); ++reads;
    if (!channel_ok) return false;
    *channel = (uint16_t)(100 + scan->cursor); ++scan->cursor; return true;
}
static void setup(void) {
    dm32_runtime_initialize(); state.source = 1; state.zone.zone_id = 22;
    memset(stock, 0, sizeof(stock)); memset(config, 'N', sizeof(config));
    memcpy(config+0x20,"ORIGIN",7);
    memset(radio, 0, sizeof(radio)); memset(aux, 0, sizeof(aux));
    radio[0x2d] = 4; radio[0x29] = 11; radio[0x26] = 3;
    config[9] = 0; stock[0] = 3; mode = 0;
    count_ok = channel_ok = list_ok = true;
}
int main(void) {
    unsigned before;
    setup(); state.zone.cursor = 9;
    assert(dm32_scan_start_bridge(1) && mode == 1 && state.zone.enabled && state.zone.cursor == 0);
    assert(basic_calls == 1 && list_calls == 0 && stock[2] == 0 && stock[3] == 6);
    assert(stock[0x58] == 0x23 && stock[0x59] == 2); /* origin channel 547 */
    setup(); config[9] = 2;
    assert(dm32_scan_start_bridge(1) && stock[2] == 0x21 && stock[3] == 19 && stock[6] == 0x23);
    before = list_calls; mode = 6; state.zone.cursor = 5; stock[0x10] = 0x80; config[9] = 3;
    assert(dm32_scan_start_bridge(0) && mode == 1 && list_calls == before && state.zone.cursor == 5);
    mode = 2; before = reads;
    assert(!dm32_scan_start_bridge(0) && mode == 2 && state.zone.enabled && reads == before);
    mode = 6; count_ok = false; before = stops;
    assert(!dm32_scan_start_bridge(0) && mode == 0 && !state.zone.enabled && stops == before + 1);
    setup(); channel_ok = false; state.zone.cursor = 7; before = tails;
    assert(!dm32_scan_start_bridge(1) && state.zone.cursor == 7 && tails == before && mode == 0);
    setup(); config[9] = 2; list_ok = false;
    assert(dm32_scan_start_bridge(1) && stock[2] == 0 && stock[3] == 6);
    setup(); radio[0x2d] = 0; before = stock_calls;
    assert(dm32_scan_start_bridge(1) && stock_calls == before + 1 && !state.zone.enabled);
    setup(); state.source = 0; before = stock_calls;
    assert(dm32_scan_start_bridge(0) && stock_calls == before + 1);
    puts("Scan start draft: preflight, no-list defaults, stock TX policy, resume, pause, errors and VFO forwarding PASS");
    return 0;
}
