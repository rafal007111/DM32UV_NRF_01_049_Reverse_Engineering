#include "zone_picker_routing.h"
#include "zone_picker_ui.h"
#include "runtime_state.h"
#include "menu_tables.h"

#ifdef DM32_PICKER_ROUTING_TEST
extern uint8_t dm32_test_key_read(void);
extern void dm32_test_scan_confirm(void);
extern void dm32_test_ui_lock(void);
extern void dm32_test_ui_unlock(void);
extern void dm32_test_ui_redraw(void);
extern void dm32_test_ui_error(uint8_t);
extern volatile uint8_t *dm32_test_scene(void);
extern volatile uint8_t *dm32_test_mode_flags(void);
extern volatile uint8_t *dm32_test_menu_indices(void);
extern volatile uint8_t *dm32_test_scan_map(void);
extern volatile uint16_t *dm32_test_current_count(void);
extern volatile uint8_t *dm32_test_current_items(void);
extern volatile uint8_t *dm32_test_current_index(void);
#define key_read dm32_test_key_read
#define scan_confirm dm32_test_scan_confirm
#define ui_lock dm32_test_ui_lock
#define ui_unlock dm32_test_ui_unlock
#define ui_redraw dm32_test_ui_redraw
#define ui_error dm32_test_ui_error
#define SCENE dm32_test_scene()
#define MODE_FLAGS dm32_test_mode_flags()
#define MENU_INDICES dm32_test_menu_indices()
#define SCAN_MAP dm32_test_scan_map()
#define CURRENT_COUNT dm32_test_current_count()
#define CURRENT_ITEMS dm32_test_current_items()
#define CURRENT_INDEX dm32_test_current_index()
#else
#define key_read ((uint8_t (*)(void))(uintptr_t)0x03013078u)
#define scan_confirm ((void (*)(void))(uintptr_t)0x0304d07cu)
#define ui_redraw ((void (*)(void))(uintptr_t)0x0303b6acu)
#define ui_error ((void (*)(uint8_t))(uintptr_t)0x03021c1cu)
#define SCENE ((volatile uint8_t *)(uintptr_t)0x000320c8u)
#define MODE_FLAGS ((volatile uint8_t *)(uintptr_t)0x0003fdd8u)
#define MENU_INDICES ((volatile uint8_t *)(uintptr_t)0x0003e508u)
#define SCAN_MAP ((volatile uint8_t *)(uintptr_t)0x0003e682u)
#define CURRENT_COUNT ((volatile uint16_t *)(uintptr_t)0x0003e618u)
#define CURRENT_ITEMS ((volatile uint8_t *)(uintptr_t)0x0003e61au)
#define CURRENT_INDEX ((volatile uint8_t *)(uintptr_t)0x0003e5ecu)
static void ui_lock(void) {
    ((void (*)(void *,uint32_t))(uintptr_t)0x0300c500u)((void *)(uintptr_t)0x0003e4e0u,0);
}
static void ui_unlock(void) {
    ((void (*)(void *))(uintptr_t)0x0300c53cu)((void *)(uintptr_t)0x0003e4e0u);
}
#endif

static void restore_scan_menu(dm32_runtime *state) {
    SCENE[3] = state->picker_origin_scene;
    SCENE[4] = 0;
    ui_redraw();
}

void dm32_picker_render_bridge(void) {
    dm32_runtime *state = dm32_runtime_get();
    if (state->magic == DM32_RUNTIME_MAGIC && state->picker.open) {
        if (SCENE[3] == state->picker_origin_scene && dm32_picker_ui_render()) return;
        dm32_picker_ui_cancel();
    }
    ui_redraw();
}

void dm32_picker_entry_bridge(void) {
    dm32_runtime *state = dm32_runtime_get();
    uint8_t item_index = MENU_INDICES[2];
    /* Reuse the exact selection lookup performed by stock 0x0304d07c. */
    if (state->magic != DM32_RUNTIME_MAGIC || !state->picker_origin_valid ||
        state->picker_origin_key != 5 || (*MODE_FLAGS & 2) != 0 ||
        item_index >= 35 || SCAN_MAP[item_index + 2] != DM32_SCAN_ZONE_MENU_ID) {
        scan_confirm();
        return;
    }
    /* Scan confirmation runs under the dispatcher UI lock. No new stock menu push. */
    SCENE[3] = state->picker_origin_scene;
    SCENE[4] = 0;
    if (!dm32_picker_ui_open() || !dm32_picker_ui_render()) {
        dm32_picker_ui_cancel();
        ui_error(0x1b);
        restore_scan_menu(state);
    }
}

uint8_t dm32_picker_key_read_bridge(void) {
    uint8_t key = key_read(); /* Exactly one dequeue, also updates the stock last-key byte. */
    dm32_runtime *state = dm32_runtime_get();
    if (state->magic != DM32_RUNTIME_MAGIC) return key;
    if (!state->picker.open) {
        state->picker_origin_scene = SCENE[3];
        state->picker_origin_valid = true;
        state->picker_origin_key = key;
        /* Inspect the visible menu before stock confirmation advances its depth.
           Scene 0x0e is the Scan list; current items differ from saved SCAN_MAP. */
        if (key == 5 && SCENE[3] == 0x0e && (*MODE_FLAGS & 2) == 0 &&
            *CURRENT_COUNT <= 35 && *CURRENT_INDEX < *CURRENT_COUNT &&
            CURRENT_ITEMS[*CURRENT_INDEX] == DM32_SCAN_ZONE_MENU_ID) {
            ui_lock();
            SCENE[4] = 0;
            if (!dm32_picker_ui_open() || !dm32_picker_ui_render()) {
                dm32_picker_ui_cancel();
                ui_error(0x1b);
                restore_scan_menu(state);
            }
            ui_unlock();
            return 0xff;
        }
        return key;
    }
    ui_lock();
    if (SCENE[3] != state->picker_origin_scene) {
        /* An external stock transition already changed screens. Do not undo it. */
        dm32_picker_ui_cancel();
        ui_unlock();
        return key;
    }
    switch (key) {
    case 1: /* Up */
    case 2: /* Down */
        if (!dm32_picker_ui_move(key == 2)) ui_error(0x1b);
        break;
    case 5: /* Menu/confirm */
        if (dm32_picker_ui_confirm()) restore_scan_menu(state);
        else ui_error(0x1b);
        break;
    case 6: /* Exit/back */
        dm32_picker_ui_back();
        restore_scan_menu(state);
        break;
    case 0xfe: /* Stock redraw event */
        if (!dm32_picker_ui_render()) ui_error(0x1b);
        break;
    default:
        dm32_picker_ui_cancel();
        restore_scan_menu(state);
        ui_unlock();
        return key; /* PTT and every other event retain their stock path. */
    }
    ui_unlock();
    return 0xff; /* Verified unhandled code in stock dispatcher; no second dequeue. */
}
