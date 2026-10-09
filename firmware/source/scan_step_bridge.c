#include "scan_step_bridge.h"
#include "runtime_state.h"
#include "firmware_zone_bridge.h"
#ifdef DM32_SCAN_STEP_TEST
extern uint8_t dm32_test_scan_mode(void);
extern void dm32_test_scan_set_mode(uint8_t);
extern void dm32_test_scan_channel(uint16_t);
extern void dm32_test_scan_stop(void);
extern void dm32_test_stock_list_choice(uint8_t);
#define scan_mode dm32_test_scan_mode
#define set_mode dm32_test_scan_set_mode
#define set_channel dm32_test_scan_channel
#define scan_stop dm32_test_scan_stop
#define list_choice dm32_test_stock_list_choice
#else
#define scan_mode ((uint8_t (*)(void))(uintptr_t)0x0302ece0u)
#define set_mode ((void (*)(uint8_t))(uintptr_t)0x0302eca0u)
#define set_channel ((void (*)(uint16_t))(uintptr_t)0x0302ece8u)
#define scan_stop ((void (*)(void))(uintptr_t)0x0302f388u)
#define list_choice ((void (*)(uint8_t))(uintptr_t)0x0302f59cu)
#endif

void dm32_scan_step_bridge(uint16_t stock_channel) {
    dm32_runtime *state = dm32_runtime_get();
    uint16_t channel;
    if (state->magic != DM32_RUNTIME_MAGIC || state->source != 1 ||
        !state->zone.enabled || scan_mode() == 0) {
        set_channel(stock_channel);
        return;
    }
    if (dm32_firmware_zone_next(&state->zone, &channel)) set_channel(channel);
    else {
        state->zone.enabled = false;
        scan_stop(); /* Original stop restores the radio's configuration. */
    }
}

void dm32_scan_mode_bridge(uint8_t mode) {
    dm32_runtime *state = dm32_runtime_get();
    set_mode(mode);
    if (state->magic == DM32_RUNTIME_MAGIC && mode == 0) state->zone.enabled = false;
}

void dm32_scan_list_choice_bridge(uint8_t list) {
    dm32_runtime *state = dm32_runtime_get();
    list_choice(list); /* The existing UI operation owns its usual CPS-compatible write. */
    if (state->magic == DM32_RUNTIME_MAGIC && list <= 32) {
        state->source = 0;
        state->zone.enabled = false;
    }
}
