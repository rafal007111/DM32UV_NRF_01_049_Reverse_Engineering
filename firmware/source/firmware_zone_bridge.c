#include "firmware_zone_bridge.h"
#include "codeplug_reader.h"

/* Bound only to the verified stock NRF image aff6b4dc...52dd. Not a universal ABI. */
#ifdef DM32_BRIDGE_TEST
extern void dm32_test_firmware_read(uint8_t block, uint16_t offset, void *data, uint16_t size);
#define firmware_read dm32_test_firmware_read
#else
typedef void (*firmware_read_function)(uint8_t, uint16_t, void *, uint16_t);
#define firmware_read ((firmware_read_function)(uintptr_t)0x0300f780u)
#endif

static bool native_read(void *context, uint8_t block, uint16_t offset, void *data, uint16_t size) {
    uint16_t i; uint8_t *bytes = (uint8_t *)data;
    (void)context;
    if (!data || block < 0x5c || block > 0x64 || size < 1 || size > 2 ||
        (uint32_t)offset + size > 4095) return false;
    for (i = 0; i < size; ++i) bytes[i] = 0xff;
    firmware_read(block, offset, data, size);
    /* The existing ROM/firmware wrapper exposes no verified I/O status return.
       Erased/unread values remain FF and are rejected by count/ID validation.
       Do not claim this backend detects every physical SPI error. */
    return true;
}

static const dm32_storage native_storage = {0, native_read};

bool dm32_firmware_zone_select(dm32_zone_scan *state, uint8_t zone) {
    dm32_zone_reader reader = dm32_codeplug_zone_reader((dm32_storage *)&native_storage);
    return dm32_zone_select(state, &reader, zone);
}

bool dm32_firmware_zone_switch(dm32_zone_scan *state, bool enabled) {
    dm32_zone_reader reader = dm32_codeplug_zone_reader((dm32_storage *)&native_storage);
    return dm32_zone_switch(state, &reader, enabled);
}

bool dm32_firmware_zone_next(dm32_zone_scan *state, uint16_t *channel) {
    dm32_zone_reader reader = dm32_codeplug_zone_reader((dm32_storage *)&native_storage);
    return dm32_zone_next(state, &reader, channel);
}
