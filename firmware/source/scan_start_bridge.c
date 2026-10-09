#include "scan_start_bridge.h"
#include "scan_prepare.h"
#include "runtime_state.h"
#include "firmware_zone_bridge.h"
#ifdef DM32_SCAN_START_TEST
extern uint8_t *dm32_test_scan_state(void);
extern uint8_t *dm32_test_channel_config(void);
extern uint8_t *dm32_test_radio_config(void);
extern uint8_t *dm32_test_radio_aux(void);
extern uint8_t dm32_test_scan_mode(void);
extern void dm32_test_scan_set_mode(uint8_t);
extern void dm32_test_scan_stop(void);
extern bool dm32_test_stock_start(uint32_t);
extern void dm32_test_prepare_list(uint8_t);
extern void dm32_test_prepare_basic(void);
extern uint16_t dm32_test_current_channel(uint8_t,uint8_t);
extern bool dm32_test_start_tail(uint32_t);
extern bool dm32_test_scan_zone_name(uint8_t, uint8_t *);
#define zone_name dm32_test_scan_zone_name
#define STOCK_STATE dm32_test_scan_state()
#define CHANNEL_CONFIG dm32_test_channel_config()
#define RADIO_CONFIG dm32_test_radio_config()
#define RADIO_AUX dm32_test_radio_aux()
#define stock_mode dm32_test_scan_mode
#define stock_set_mode dm32_test_scan_set_mode
#define stock_stop dm32_test_scan_stop
#define stock_start dm32_test_stock_start
#define prepare_list dm32_test_prepare_list
#define prepare_basic dm32_test_prepare_basic
#define current_channel dm32_test_current_channel
#define start_tail dm32_test_start_tail
#else
extern bool dm32_zone_start_tail(uint32_t explicit_start);
#define STOCK_STATE ((uint8_t *)(uintptr_t)0x0003e160u)
#define CHANNEL_CONFIG ((uint8_t *)(uintptr_t)0x0003e1f8u)
#define RADIO_CONFIG ((uint8_t *)(uintptr_t)0x0003e9d4u)
#define RADIO_AUX ((uint8_t *)(uintptr_t)0x0003e334u)
#define stock_mode ((uint8_t (*)(void))(uintptr_t)0x0302ece0u)
#define stock_set_mode ((void (*)(uint8_t))(uintptr_t)0x0302eca0u)
#define stock_stop ((void (*)(void))(uintptr_t)0x0302f388u)
#define stock_start ((bool (*)(uint32_t))(uintptr_t)0x0302f418u)
#define prepare_list ((void (*)(uint8_t))(uintptr_t)0x0302e1a4u)
#define prepare_basic ((void (*)(void))(uintptr_t)0x0302e144u)
#define current_channel ((uint16_t (*)(uint8_t,uint8_t))(uintptr_t)0x0305660cu)
#define start_tail dm32_zone_start_tail
static bool zone_name(uint8_t zone, uint8_t *name) {
    uint16_t block=0, offset=0;
    ((void (*)(uint8_t,uint16_t *,uint16_t *))(uintptr_t)0x03055c90u)(zone,&block,&offset);
    if (zone < 1 || zone > 250 || block < 0x5c || block > 0x64 || offset > 4079) return false;
    ((void (*)(uint8_t,uint16_t,void *,uint16_t))(uintptr_t)0x0300f780u)((uint8_t)block,offset,name,16);
    name[16]=0;
    return true;
}
#endif

static bool abort_start(dm32_runtime *state, uint8_t cursor) {
    state->zone.enabled = false;
    state->zone.cursor = cursor;
    if (stock_mode() != 0) stock_stop();
    return false;
}

bool dm32_scan_start_bridge(uint32_t explicit_start) {
    dm32_runtime *state = dm32_runtime_get();
    uint8_t mode, cursor, next_cursor, list, i;
    uint16_t first, origin;
    uint8_t name[17];
    bool result, keep_policy = false, running;
    if (state->magic != DM32_RUNTIME_MAGIC || state->source != 1)
        return stock_start(explicit_start);
    if ((RADIO_CONFIG[0x2d] & 4) == 0 || (RADIO_AUX[0x15] & 4) != 0) {
        state->zone.enabled = false;
        return stock_start(explicit_start);
    }
    mode = stock_mode();
    if (!explicit_start && mode == 2) return false; /* Same paused-start convention as a stock list. */
    running = mode != 0 && state->zone.enabled;
    cursor = state->zone.cursor;
    if (!dm32_firmware_zone_switch(&state->zone, true)) return abort_start(state, cursor);
    next_cursor = explicit_start ? 0 : cursor;
    state->zone.cursor = next_cursor;
    if (!dm32_firmware_zone_next(&state->zone, &first)) {
        return abort_start(state, cursor);
    }
    state->zone.cursor = next_cursor; /* Preflight must not consume the first scan step. */
    origin = current_channel(RADIO_CONFIG[0x29], RADIO_CONFIG[0x26]);
    if (origin < 1 || origin > 4000) return abort_start(state, cursor);
    for (i = 0; i < 17; ++i) name[i] = 0;
    if (!zone_name(state->zone.zone_id, name)) return abort_start(state, cursor);
    stock_set_mode(0);
    list = (uint8_t)(CHANNEL_CONFIG[9] & 0x3f);
    if (running) {
        keep_policy = true; /* Preserve the original policy during TX/hold resume. */
    }
    else if (list >= 1 && list <= 32 && list <= STOCK_STATE[0]) {
        prepare_list(list);
        keep_policy = STOCK_STATE[0x5c] >= 2 && STOCK_STATE[0x5c] <= 16;
    }
    if (!keep_policy) prepare_basic();
    if (!dm32_scan_prepare_slots(STOCK_STATE, first, origin, CHANNEL_CONFIG + 0x20, keep_policy)) {
        state->zone.enabled = false;
        return false;
    }
    /* Stock home renderers 030317bc/03031b7c read the 12-byte source label
       at 3e196. Keep the separate channel/TX name at 3e1a2 untouched. */
    for (i = 0; i < 11; ++i) STOCK_STATE[0x36+i] = name[i];
    STOCK_STATE[0x41] = 0;
    /* Exact stock start tail owns config snapshots, authorization and mode 1. */
    result = start_tail(explicit_start);
    state->zone.enabled = result && stock_mode() != 0;
    return result;
}
