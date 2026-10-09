#include <assert.h>
#include <stdio.h>
#include "codeplug_reader.h"
static bool boundary_read(void *context, uint8_t block, uint16_t offset, void *data, uint16_t size) {
    uint8_t *bytes = (uint8_t *)data; (void)context;
    /* Expected offsets are independent examples, not calculated by the adapter. */
    if (size == 1 && ((block == 0x5c && offset == 3947) ||
                     (block == 0x5d && offset == 16) ||
                     (block == 0x64 && offset == 3641))) { bytes[0] = 1; return true; }
    if (size == 2 && ((block == 0x5c && offset == 3948) ||
                     (block == 0x5d && offset == 17) ||
                     (block == 0x64 && offset == 3642))) {
        bytes[0] = 0xa0; bytes[1] = 0x0f; return true;
    }
    return false;
}
int main(void) {
    dm32_storage storage = {0, boundary_read};
    dm32_zone_reader reader = dm32_codeplug_zone_reader(&storage);
    dm32_zone_scan scan; uint16_t channel = 0; uint8_t count = 0;
    uint8_t zones[] = {28,29,250}; unsigned i;
    for (i = 0; i < sizeof(zones); ++i) {
        dm32_zone_init(&scan); assert(dm32_zone_select(&scan, &reader, zones[i]));
        assert(dm32_zone_switch(&scan, &reader, true));
        assert(dm32_zone_next(&scan, &reader, &channel)); assert(channel == 4000);
    }
    assert(!reader.count(reader.context, 0, &count));
    assert(!reader.count(reader.context, 251, &count));
    assert(!reader.channel(reader.context, 29, 0, &channel));
    assert(!reader.channel(reader.context, 29, 65, &channel));
    puts("PASS: zone block boundaries 28/29/250 and out-of-range guards");
    return 0;
}
