#include "runtime_state.h"

#ifdef DM32_RUNTIME_TEST
extern dm32_runtime *dm32_test_runtime_address(void);
extern void dm32_test_stock_boot(void);
#define stock_boot dm32_test_stock_boot
#else
typedef void (*stock_boot_function)(void);
#define stock_boot ((stock_boot_function)(uintptr_t)0x0002e174u)
#endif

dm32_runtime *dm32_runtime_get(void) {
#ifdef DM32_RUNTIME_TEST
    return dm32_test_runtime_address();
#else
    return (dm32_runtime *)(uintptr_t)DM32_RUNTIME_ADDRESS;
#endif
}

void dm32_runtime_initialize(void) {
    dm32_runtime *state = dm32_runtime_get();
    uint8_t *bytes = (uint8_t *)state;
    uint8_t i;
    for (i = 0; i < DM32_RUNTIME_BYTES; ++i) bytes[i] = 0;
    dm32_zone_init(&state->zone);
    dm32_rx_defaults(&state->rx);
    state->magic = DM32_RUNTIME_MAGIC;
}

void dm32_runtime_boot(void) {
    dm32_runtime_initialize();
    stock_boot();
}
