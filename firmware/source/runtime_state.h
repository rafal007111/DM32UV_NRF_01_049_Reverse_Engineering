#ifndef DM32_RUNTIME_STATE_H
#define DM32_RUNTIME_STATE_H
#include "mod_core.h"
#include "zone_picker.h"

/* Candidate reservation: reduce the stock heap end from 0x4bfe0 to 0x4bfc0.
   This address MUST NOT be used on stock firmware without that reservation. */
#define DM32_RUNTIME_ADDRESS 0x0004bfc0u
#define DM32_RUNTIME_BYTES 32u
#define DM32_RUNTIME_MAGIC 0x5a4d3332u

typedef struct {
    uint32_t magic;
    dm32_zone_scan zone;
    dm32_rx_options rx;
    uint8_t source; /* 0 = stock scan list, 1 = selected zone */
    dm32_zone_picker picker;
    uint8_t picker_origin_scene;
    bool picker_origin_valid;
    uint8_t picker_origin_key;
    uint8_t reserved[16];
} dm32_runtime;

typedef char dm32_runtime_size_check[(sizeof(dm32_runtime) == DM32_RUNTIME_BYTES) ? 1 : -1];
dm32_runtime *dm32_runtime_get(void);
void dm32_runtime_initialize(void);
/* Candidate replacement for startup's call to 0x0002e174; not hooked yet. */
void dm32_runtime_boot(void);
#endif
