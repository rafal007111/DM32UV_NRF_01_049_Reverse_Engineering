#ifndef DM32_MOD_CORE_H
#define DM32_MOD_CORE_H
#include <stdbool.h>
#include <stdint.h>

/* Portable new logic; firmware hooks, storage and UI are not connected yet. */
typedef struct {
    uint8_t zone_id;
    uint8_t cursor; /* zero-based position; channel reader uses one-based positions */
    bool enabled;
} dm32_zone_scan;

typedef bool (*dm32_read_count)(void *context, uint8_t zone, uint8_t *count);
typedef bool (*dm32_read_channel)(void *context, uint8_t zone, uint8_t position, uint16_t *channel);
typedef struct {
    void *context;
    dm32_read_count count;
    dm32_read_channel channel;
} dm32_zone_reader;

void dm32_zone_init(dm32_zone_scan *scan);
bool dm32_zone_select(dm32_zone_scan *scan, const dm32_zone_reader *reader, uint8_t zone);
bool dm32_zone_switch(dm32_zone_scan *scan, const dm32_zone_reader *reader, bool on);
bool dm32_zone_next(dm32_zone_scan *scan, const dm32_zone_reader *reader, uint16_t *channel);

typedef struct { bool ts_match; bool cc_match; } dm32_rx_options;
void dm32_rx_defaults(dm32_rx_options *options);
/* Internal slots are 0=TS1 / 1=TS2. This is policy only, not a hardware TS bypass. */
bool dm32_rx_slot_allowed(const dm32_rx_options *options, uint8_t configured, uint8_t received);
bool dm32_rx_cc_allowed(const dm32_rx_options *options, uint8_t configured, uint8_t received);
uint8_t dm32_cc_ignore_argument(const dm32_rx_options *options);
#endif
