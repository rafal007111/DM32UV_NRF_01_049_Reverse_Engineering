#include <assert.h>
#include <stdio.h>
#include "mod_core.h"
typedef struct { uint8_t count; uint16_t channels[64]; bool io_error; uint8_t last_zone; } fixture;
static bool read_count(void *context, uint8_t zone, uint8_t *count) {
    fixture *f = (fixture *)context; f->last_zone = zone; *count = f->count; return !f->io_error;
}
static bool read_channel(void *context, uint8_t zone, uint8_t position, uint16_t *channel) {
    fixture *f = (fixture *)context; assert(zone == 7); assert(position >= 1 && position <= f->count);
    *channel = f->channels[position - 1]; return !f->io_error;
}
int main(void) {
    fixture f = {0}; dm32_zone_scan scan; uint16_t channel = 999; unsigned i, mask, cc, slot;
    dm32_zone_reader reader = {&f, read_count, read_channel}; dm32_rx_options options;
    dm32_zone_init(&scan);
    assert(!dm32_zone_switch(&scan, &reader, true));
    f.count = 64; for (i = 0; i < 64; ++i) f.channels[i] = (uint16_t)(i + 1);
    assert(dm32_zone_select(&scan, &reader, 7)); assert(!scan.enabled);
    assert(!dm32_zone_next(&scan, &reader, &channel)); assert(channel == 999);
    assert(dm32_zone_switch(&scan, &reader, true));
    for (i = 1; i <= 64; ++i) { assert(dm32_zone_next(&scan, &reader, &channel)); assert(channel == i); }
    assert(dm32_zone_next(&scan, &reader, &channel)); assert(channel == 1); assert(f.last_zone == 7);
    f.count = 3; f.channels[0] = 0; f.channels[1] = 0xffff; f.channels[2] = 4000; scan.cursor = 63;
    assert(dm32_zone_next(&scan, &reader, &channel)); assert(channel == 4000);
    f.channels[2] = 4001; assert(!dm32_zone_next(&scan, &reader, &channel));
    f.count = 0; assert(!dm32_zone_select(&scan, &reader, 8)); assert(scan.zone_id == 7);
    f.count = 65; assert(!dm32_zone_next(&scan, &reader, &channel));
    f.count = 1; f.channels[0] = 42; f.io_error = true;
    assert(!dm32_zone_next(&scan, &reader, &channel));
    f.io_error = false; assert(dm32_zone_switch(&scan, &reader, false));
    assert(!dm32_zone_next(&scan, &reader, &channel));
    dm32_rx_defaults(&options); assert(options.ts_match && options.cc_match);
    for (mask = 0; mask < 4; ++mask) {
        options.ts_match = (mask & 1) != 0; options.cc_match = (mask & 2) != 0;
        for (cc = 0; cc < 16; ++cc)
            assert(dm32_rx_cc_allowed(&options, 7, (uint8_t)cc) == (!options.cc_match || cc == 7));
        for (slot = 0; slot < 2; ++slot)
            assert(dm32_rx_slot_allowed(&options, 0, (uint8_t)slot) == (!options.ts_match || slot == 0));
        assert(!dm32_rx_cc_allowed(&options, 7, 16)); assert(!dm32_rx_slot_allowed(&options, 0, 2));
        assert(dm32_cc_ignore_argument(&options) == (options.cc_match ? 0 : 1));
    }
    puts("PASS: 64-channel zone scan, selection without start, wrap, invalid entries, I/O failure, independent TS/CC policies");
    return 0;
}
