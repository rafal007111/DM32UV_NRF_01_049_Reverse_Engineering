#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "runtime_state.h"

static struct { uint32_t before; dm32_runtime state; uint32_t after; } fixture;
static unsigned boot_calls;
dm32_runtime *dm32_test_runtime_address(void) { return &fixture.state; }
void dm32_test_stock_boot(void) {
    assert(fixture.state.magic == DM32_RUNTIME_MAGIC);
    assert(!fixture.state.zone.enabled && fixture.state.source == 0);
    assert(fixture.state.rx.ts_match && fixture.state.rx.cc_match);
    ++boot_calls;
}
int main(void) {
    unsigned i;
    assert(sizeof(dm32_runtime) == 32);
    assert(offsetof(dm32_runtime, zone) == 4);
    assert(offsetof(dm32_runtime, rx) == 7);
    assert(offsetof(dm32_runtime, source) == 9);
    memset(&fixture, 0xa5, sizeof(fixture));
    dm32_runtime_boot();
    assert(boot_calls == 1);
    assert(fixture.before == 0xa5a5a5a5u && fixture.after == 0xa5a5a5a5u);
    for (i = 0; i < sizeof(fixture.state.reserved); ++i) assert(fixture.state.reserved[i] == 0);
    fixture.state.zone.zone_id = 22;
    fixture.state.zone.enabled = true;
    fixture.state.rx.cc_match = false;
    fixture.state.source = 1;
    dm32_runtime_boot();
    assert(boot_calls == 2 && fixture.state.zone.zone_id == 0);
    assert(fixture.before == 0xa5a5a5a5u && fixture.after == 0xa5a5a5a5u);
    puts("Runtime state: layout, guarded initialization, defaults and boot order PASS");
    return 0;
}
