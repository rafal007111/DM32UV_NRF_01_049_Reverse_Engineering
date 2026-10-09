#ifndef DM32_CODEPLUG_READER_H
#define DM32_CODEPLUG_READER_H
#include "mod_core.h"
/* Backend resolves logical block IDs. It must not expose physical addresses here. */
typedef bool (*dm32_read_block)(void *context, uint8_t block, uint16_t offset, void *data, uint16_t size);
typedef struct { void *context; dm32_read_block read; } dm32_storage;
dm32_zone_reader dm32_codeplug_zone_reader(dm32_storage *storage);
#endif
