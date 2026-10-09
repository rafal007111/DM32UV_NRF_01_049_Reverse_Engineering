#include "mod_core.h"

static bool count_checked(const dm32_zone_reader *reader, uint8_t zone, uint8_t *count) {
    return reader && reader->count && reader->channel && zone >= 1 && zone <= 250 &&
           reader->count(reader->context, zone, count) && *count >= 1 && *count <= 64;
}

void dm32_zone_init(dm32_zone_scan *scan) {
    scan->zone_id = 0;
    scan->cursor = 0;
    scan->enabled = false;
}

bool dm32_zone_select(dm32_zone_scan *scan, const dm32_zone_reader *reader, uint8_t zone) {
    uint8_t count;
    if (!scan || !count_checked(reader, zone, &count)) return false;
    scan->zone_id = zone;
    scan->cursor = 0;
    /* Selection does not enable scanning. Scan Switch owns this state. */
    return true;
}

bool dm32_zone_switch(dm32_zone_scan *scan, const dm32_zone_reader *reader, bool on) {
    uint8_t count;
    if (!scan) return false;
    if (on && !count_checked(reader, scan->zone_id, &count)) return false;
    scan->enabled = on;
    return true;
}

bool dm32_zone_next(dm32_zone_scan *scan, const dm32_zone_reader *reader, uint16_t *channel) {
    uint8_t count, attempts;
    if (!scan || !channel || !scan->enabled || !count_checked(reader, scan->zone_id, &count))
        return false;
    if (scan->cursor >= count) scan->cursor = 0;
    for (attempts = 0; attempts < count; ++attempts) {
        uint16_t candidate;
        uint8_t position = (uint8_t)(scan->cursor + 1);
        scan->cursor = (uint8_t)(position % count);
        /* Do not silently turn an I/O error into a valid channel. */
        if (!reader->channel(reader->context, scan->zone_id, position, &candidate)) return false;
        if (candidate >= 1 && candidate <= 4000) {
            *channel = candidate;
            return true;
        }
    }
    return false;
}

void dm32_rx_defaults(dm32_rx_options *options) {
    options->ts_match = true;
    options->cc_match = true;
}

bool dm32_rx_slot_allowed(const dm32_rx_options *options, uint8_t configured, uint8_t received) {
    return options && configured <= 1 && received <= 1 &&
           (!options->ts_match || configured == received);
}

bool dm32_rx_cc_allowed(const dm32_rx_options *options, uint8_t configured, uint8_t received) {
    return options && configured <= 15 && received <= 15 &&
           (!options->cc_match || configured == received);
}

uint8_t dm32_cc_ignore_argument(const dm32_rx_options *options) {
    return (uint8_t)(options->cc_match ? 0 : 1);
}
