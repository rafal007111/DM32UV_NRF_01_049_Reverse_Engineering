#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "menu_filter.h"
#include "menu_tables.h"
static struct { unsigned before; uint8_t items[35]; uint8_t after; } fixture;
static uint16_t main_count;
static unsigned stock_calls;
uint16_t *dm32_test_main_count(void) { return &main_count; }
uint8_t *dm32_test_main_items(void) { return fixture.items; }
void dm32_test_stock_filter(uint8_t category, uint16_t *count, uint8_t *items) {
    uint8_t i;
    ++stock_calls; *count = 0;
    if (category == DM32_FILTER_SCAN) { items[(*count)++] = 0; items[(*count)++] = 1; }
    else if (category == DM32_FILTER_OTHER) {
        for (i = 0; i < 22; ++i) if (i != 8 && i != 15) items[(*count)++] = i;
    }
}
int main(void) {
    uint8_t copy[35], other[35], original[35];
    uint16_t count; unsigned i, n;
    memset(&fixture, 0xa5, sizeof(fixture));
    dm32_menu_filter_bridge(DM32_FILTER_SCAN, &main_count, fixture.items);
    assert(stock_calls == 1 && main_count == 3);
    assert(fixture.items[0] == 0 && fixture.items[1] == 1 && fixture.items[2] == 9);
    assert(dm32_menu_extend(DM32_FILTER_SCAN, &main_count, fixture.items, 35));
    assert(main_count == 3); /* no duplicate */
    dm32_menu_filter_bridge(DM32_FILTER_OTHER, &main_count, fixture.items);
    assert(main_count == 22 && fixture.items[17] == 19 && fixture.items[18] == 20);
    assert(fixture.items[19] == 21 && fixture.items[20] == 22 && fixture.items[21] == 23);
    assert(fixture.before == 0xa5a5a5a5u && fixture.after == 0xa5);
    count = 0;
    dm32_menu_filter_bridge(DM32_FILTER_OTHER, &count, other);
    assert(count == 20); /* unrelated count/map are kept stock */
    for (n = 0; n <= 35; ++n) {
        for (i = 0; i < 35; ++i) copy[i] = (uint8_t)(100 + i);
        if (n > 1) copy[1] = 1;
        memcpy(original, copy, sizeof(copy)); count = (uint16_t)n;
        if (n > 1 && n < 35) {
            assert(dm32_menu_extend(DM32_FILTER_SCAN, &count, copy, 35));
            assert(count == n + 1 && copy[2] == 9);
            assert(memcmp(copy + 3, original + 2, n - 2) == 0);
        } else if (n == 35) {
            assert(!dm32_menu_extend(DM32_FILTER_SCAN, &count, copy, 35));
            assert(memcmp(copy, original, sizeof(copy)) == 0 && count == n);
        } else {
            assert(dm32_menu_extend(DM32_FILTER_SCAN, &count, copy, 35));
            assert(count == n && memcmp(copy, original, sizeof(copy)) == 0);
        }
    }
    memset(copy, 0xaa, sizeof(copy)); memcpy(original, copy, sizeof(copy)); count = 34;
    assert(!dm32_menu_extend(DM32_FILTER_OTHER, &count, copy, 35));
    assert(count == 34 && memcmp(copy, original, sizeof(copy)) == 0);
    count = 36; assert(!dm32_menu_extend(DM32_FILTER_OTHER, &count, copy, 35));
    puts("Menu filter: visible order, stock delegation, buffer bounds and no partial changes PASS");
    return 0;
}
