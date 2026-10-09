#include "codeplug_reader.h"

static bool locate(uint8_t zone, uint8_t *block, uint16_t *offset) {
    uint8_t index;
    if (zone < 1 || zone > 250) return false;
    index = (uint8_t)(zone - 1);
    *block = (uint8_t)(0x5c + index / 28);
    *offset = (uint16_t)((index % 28) * 145 + (*block == 0x5c ? 16 : 0));
    return true;
}

static bool zone_count(void *context, uint8_t zone, uint8_t *count) {
    dm32_storage *storage = (dm32_storage *)context;
    uint8_t block; uint16_t offset;
    if (!storage || !storage->read || !locate(zone, &block, &offset)) return false;
    return storage->read(storage->context, block, (uint16_t)(offset + 16), count, 1);
}

static bool zone_channel(void *context, uint8_t zone, uint8_t position, uint16_t *channel) {
    dm32_storage *storage = (dm32_storage *)context;
    uint8_t block, bytes[2]; uint16_t offset;
    if (!storage || !storage->read || !channel || position < 1 || position > 64 ||
        !locate(zone, &block, &offset)) return false;
    offset = (uint16_t)(offset + 17 + (position - 1) * 2);
    if (!storage->read(storage->context, block, offset, bytes, 2)) return false;
    *channel = (uint16_t)((uint16_t)bytes[0] | ((uint16_t)bytes[1] << 8));
    return true;
}

dm32_zone_reader dm32_codeplug_zone_reader(dm32_storage *storage) {
    dm32_zone_reader reader = {storage, zone_count, zone_channel};
    return reader;
}
