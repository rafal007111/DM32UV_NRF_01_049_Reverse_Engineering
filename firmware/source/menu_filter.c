#include "menu_filter.h"
#include "menu_tables.h"

bool dm32_menu_extend(uint8_t category, uint16_t *count, uint8_t *items, uint16_t capacity) {
    uint16_t i, at;
    bool have_ts = false, have_cc = false;
    if (!count || !items || *count > capacity) return false;
    if (category == DM32_FILTER_SCAN) {
        at = *count;
        for (i = 0; i < *count; ++i) {
            if (items[i] == DM32_SCAN_ZONE_MENU_ID) return true;
            if (items[i] == 1) at = (uint16_t)(i + 1); /* stock Scan List */
        }
        /* Zone scanning is exposed where the stock channel Scan List is present. */
        if (at == *count && (*count == 0 || items[*count - 1] != 1)) return true;
        if (*count == capacity) return false;
        for (i = *count; i > at; --i) items[i] = items[i - 1];
        items[at] = DM32_SCAN_ZONE_MENU_ID;
        ++*count;
        return true;
    }
    if (category != DM32_FILTER_OTHER) return true;
    for (i = 0; i < *count; ++i) {
        if (items[i] == DM32_TS_MATCH_MENU_ID) have_ts = true;
        if (items[i] == DM32_CC_MATCH_MENU_ID) have_cc = true;
    }
    if ((uint32_t)*count + (have_ts ? 0u : 1u) + (have_cc ? 0u : 1u) > capacity) return false;
    if (!have_ts) items[(*count)++] = DM32_TS_MATCH_MENU_ID;
    if (!have_cc) items[(*count)++] = DM32_CC_MATCH_MENU_ID;
    return true;
}

#ifdef DM32_MENU_FILTER_TEST
extern void dm32_test_stock_filter(uint8_t, uint16_t *, uint8_t *);
extern uint16_t *dm32_test_main_count(void);
extern uint8_t *dm32_test_main_items(void);
#define stock_filter dm32_test_stock_filter
#define MAIN_COUNT dm32_test_main_count()
#define MAIN_ITEMS dm32_test_main_items()
#else
typedef void (*stock_filter_function)(uint8_t, uint16_t *, uint8_t *);
#define stock_filter ((stock_filter_function)(uintptr_t)0x03049498u)
#define MAIN_COUNT ((uint16_t *)(uintptr_t)0x0003e618u)
#define MAIN_ITEMS ((uint8_t *)(uintptr_t)0x0003e61au)
#endif

void dm32_menu_filter_bridge(uint8_t category, uint16_t *count, uint8_t *items) {
    stock_filter(category, count, items);
    /* Other callers use unrelated buffers. Modify only the verified main UI map. */
    if (count == MAIN_COUNT && items == MAIN_ITEMS)
        (void)dm32_menu_extend(category, count, items, DM32_MAIN_MENU_CAPACITY);
}
