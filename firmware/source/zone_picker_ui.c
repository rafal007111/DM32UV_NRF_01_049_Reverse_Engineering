#include "zone_picker_ui.h"
#include "runtime_state.h"
#include "firmware_zone_bridge.h"
#include "scan_start_bridge.h"

#ifdef DM32_PICKER_UI_TEST
extern void dm32_test_firmware_read(uint8_t, uint16_t, void *, uint16_t);
extern void dm32_test_zone_locator(uint8_t, uint16_t *, uint16_t *);
extern uint8_t dm32_test_scan_mode(void);
extern void dm32_test_clear(uint16_t);
extern void dm32_test_rectangle(uint16_t, uint16_t, uint16_t, uint16_t, uint16_t);
extern void dm32_test_text(uint16_t, uint16_t, uint16_t, const char *);
extern void dm32_test_row(uint16_t, const char *, uint8_t);
extern void dm32_test_scroll(uint16_t, uint16_t);
extern void dm32_test_refresh(void);
extern void dm32_test_picker_stop(void);
extern bool dm32_test_picker_start(uint32_t);
extern void dm32_test_picker_error(uint8_t);
extern void dm32_test_picker_mark(uint16_t, bool);
#define fw_stop dm32_test_picker_stop
#define fw_start dm32_test_picker_start
#define fw_error dm32_test_picker_error
#define fw_mark dm32_test_picker_mark
#define fw_read dm32_test_firmware_read
#define fw_locator dm32_test_zone_locator
#define fw_scan_mode dm32_test_scan_mode
#define fw_clear dm32_test_clear
#define fw_rectangle dm32_test_rectangle
#define fw_text dm32_test_text
#define fw_row dm32_test_row
#define fw_scroll dm32_test_scroll
#define fw_refresh dm32_test_refresh
#else
#define fw_read ((void (*)(uint8_t,uint16_t,void *,uint16_t))(uintptr_t)0x0300f780u)
#define fw_locator ((void (*)(uint8_t,uint16_t *,uint16_t *))(uintptr_t)0x03055c90u)
#define fw_scan_mode ((uint8_t (*)(void))(uintptr_t)0x0302ece0u)
#define fw_clear ((void (*)(uint16_t))(uintptr_t)0x03017eecu)
#define fw_rectangle ((void (*)(uint16_t,uint16_t,uint16_t,uint16_t,uint16_t))(uintptr_t)0x03017be8u)
#define fw_text ((void (*)(uint16_t,uint16_t,uint16_t,const char *,...))(uintptr_t)0x03018af4u)
#define fw_row ((void (*)(uint16_t,const char *,uint8_t))(uintptr_t)0x03018c70u)
#define fw_scroll ((void (*)(uint16_t,uint16_t))(uintptr_t)0x030391a8u)
#define fw_refresh ((void (*)(void))(uintptr_t)0x03019bd4u)
#define fw_stop ((void (*)(void))(uintptr_t)0x0302f388u)
#ifdef DM32_SCANNER_INTEGRATION
#define fw_start dm32_scan_start_bridge
#else
#define fw_start ((bool (*)(uint32_t))(uintptr_t)0x0302f418u)
#endif
#define fw_error ((void (*)(uint8_t))(uintptr_t)0x03021c1cu)
static void fw_mark(uint16_t row, bool selected) {
    const uint8_t *y = (const uint8_t *)(uintptr_t)0x0308274fu;
    ((void (*)(uint16_t,uint16_t,uint16_t,uint16_t,const void *,uint16_t))(uintptr_t)0x03018d78u)
        (8,y[row],0x18,0x48,(const void *)(uintptr_t)0x03082be0u,selected ? 0 : 0xffff);
}
#endif

static bool read_name(void *context, uint8_t zone, char name[17]) {
    uint16_t block = 0, offset = 0;
    uint8_t i;
    (void)context;
    if (zone < 1 || zone > 250) return false;
    fw_locator(zone, &block, &offset);
    if (block < 0x5c || block > 0x64 || (uint32_t)offset + 16 > 4095) return false;
    for (i = 0; i < 17; ++i) name[i] = 0;
    fw_read((uint8_t)block, offset, name, 16);
    name[16] = 0;
    /* Stock reader has no validated physical I/O return status. */
    return true;
}

static void draw_row(void *context, uint8_t row, const char *name, bool selected) {
    (void)context;
    fw_row(row, name, (uint8_t)(selected ? 1 : 0));
    if (dm32_runtime_get()->source == 1 &&
        (uint8_t)((dm32_runtime_get()->picker.selected & 0xf8u) + row) == dm32_runtime_get()->zone.zone_id)
        fw_mark(row, selected);
}

bool dm32_picker_ui_open(void) {
    dm32_runtime *state = dm32_runtime_get();
    uint8_t total = 0;
    if (state->magic != DM32_RUNTIME_MAGIC) return false;
    if (fw_scan_mode() != 0 && (state->source != 1 || !state->zone.enabled)) return false;
    fw_read(0x5c, 0, &total, 1);
    if (!dm32_picker_open(&state->picker, total, state->zone.zone_id)) return false;
    state->reserved[0] = (uint8_t)(fw_scan_mode() != 0);
    if (state->reserved[0]) { fw_stop(); state->zone.enabled = false; }
    return true;
}

bool dm32_picker_ui_render(void) {
    dm32_runtime *state = dm32_runtime_get();
    bool result;
    uint8_t rows, row;
    if (state->magic != DM32_RUNTIME_MAGIC || !state->picker.open ||
        state->picker.total < 1 || state->picker.total > 250 ||
        state->picker.selected >= state->picker.total) return false;
    fw_rectangle(0, 0, 0xf0, 0x1b, 0);
    fw_text(1, 0xffff, 0, "Scan Zone");
    result = dm32_picker_rows(&state->picker, 0, read_name, draw_row);
    rows = (uint8_t)(state->picker.total - (state->picker.selected & 0xf8u));
    if (rows > 8) rows = 8;
    for (row = (uint8_t)(rows + 1); row <= 8; ++row)
        fw_row(row, "                ", 0);
    fw_scroll(state->picker.selected, state->picker.total);
    fw_refresh();
    return result;
}

bool dm32_picker_ui_move(bool forward) {
    dm32_runtime *state = dm32_runtime_get();
    uint8_t previous;
    char old_name[17], new_name[17];
    if (state->magic != DM32_RUNTIME_MAGIC) return false;
    previous = state->picker.selected;
    if (!dm32_picker_move(&state->picker, forward)) return false;
    if ((previous & 0xf8u) != (state->picker.selected & 0xf8u))
        return dm32_picker_ui_render();
    /* Read both names before drawing; preserve the rest of the visible page. */
    if (!read_name(0, (uint8_t)(previous + 1), old_name) ||
        !read_name(0, (uint8_t)(state->picker.selected + 1), new_name)) {
        state->picker.selected = previous;
        return false;
    }
    fw_row((uint8_t)((previous & 7u) + 1), old_name, 0);
    fw_row((uint8_t)((state->picker.selected & 7u) + 1), new_name, 1);
    if (state->source == 1 && state->zone.zone_id == (uint8_t)(previous + 1))
        fw_mark((uint8_t)((previous & 7u) + 1), false);
    if (state->source == 1 && state->zone.zone_id == (uint8_t)(state->picker.selected + 1))
        fw_mark((uint8_t)((state->picker.selected & 7u) + 1), true);
    fw_scroll(state->picker.selected, state->picker.total);
    fw_refresh();
    return true;
}

bool dm32_picker_ui_confirm(void) {
    dm32_runtime *state = dm32_runtime_get();
    bool resume;
    if (state->magic != DM32_RUNTIME_MAGIC || !state->picker.open ||
        state->picker.total < 1 || state->picker.total > 250 ||
        state->picker.selected >= state->picker.total || fw_scan_mode() != 0 || state->zone.enabled)
        return false;
    if (!dm32_firmware_zone_select(&state->zone, (uint8_t)(state->picker.selected + 1))) return false;
    state->source = 1;
    resume = state->reserved[0] != 0;
    state->reserved[0] = 0;
    dm32_picker_cancel(&state->picker);
    if (resume && !fw_start(1)) fw_error(0x1b);
    return true;
}

void dm32_picker_ui_cancel(void) {
    dm32_runtime *state = dm32_runtime_get();
    if (state->magic == DM32_RUNTIME_MAGIC) {
        state->reserved[0] = 0;
        dm32_picker_cancel(&state->picker);
    }
}

void dm32_picker_ui_back(void) {
    dm32_runtime *state = dm32_runtime_get();
    bool resume = state->magic == DM32_RUNTIME_MAGIC && state->reserved[0] != 0;
    dm32_picker_ui_cancel();
    if (resume && !fw_start(1)) fw_error(0x1b);
}

/* Only the two tick draws in stock Scan List renderer 0302e820 call this.
   Suppression leaves the row background drawn by stock 03018c70 intact. */
#ifdef DM32_PICKER_UI_TEST
extern void dm32_test_list_tick(uint16_t,uint16_t,uint16_t,uint16_t,const void *,uint16_t);
#define stock_list_tick dm32_test_list_tick
#else
#define stock_list_tick ((void (*)(uint16_t,uint16_t,uint16_t,uint16_t,const void *,uint16_t))(uintptr_t)0x03018d78u)
#endif
void dm32_scan_list_tick_bridge(uint16_t x, uint16_t y, uint16_t width,
                               uint16_t bytes, const void *glyph, uint16_t color) {
    dm32_runtime *state=dm32_runtime_get();
    if (state->magic == DM32_RUNTIME_MAGIC && state->source == 1) return;
    stock_list_tick(x,y,width,bytes,glyph,color);
}
