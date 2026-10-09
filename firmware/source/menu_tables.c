#include "menu_tables.h"
/* Stock pointers verified in NRF payload; new options retain every old physical ID. */
#define STOCK_LABEL(address) ((const char *)(uintptr_t)(address))
static const char scan_zone_label[] = "Scan Zone";
static const char ts_match_label[] = "TS Match";
static const char cc_match_label[] = "CC Match";
static const char *const scan_cn[] = {
    STOCK_LABEL(0x030bd5a0u),
    STOCK_LABEL(0x030bd5acu),
    STOCK_LABEL(0x030bd5b8u),
    STOCK_LABEL(0x030bd5ccu),
    STOCK_LABEL(0x030bd5e0u),
    STOCK_LABEL(0x030bd5ecu),
    STOCK_LABEL(0x030bd5fcu),
    STOCK_LABEL(0x030bd60cu),
    STOCK_LABEL(0x030bd61cu),
    scan_zone_label
};
static const char *const scan_en[] = {
    STOCK_LABEL(0x030bd62cu),
    STOCK_LABEL(0x030bd638u),
    STOCK_LABEL(0x030bd644u),
    STOCK_LABEL(0x030bd658u),
    STOCK_LABEL(0x030bd66cu),
    STOCK_LABEL(0x030bd67cu),
    STOCK_LABEL(0x030bd688u),
    STOCK_LABEL(0x030bd694u),
    STOCK_LABEL(0x030bd6a0u),
    scan_zone_label
};
static const char *const other_cn[] = {
    STOCK_LABEL(0x030bdfacu),
    STOCK_LABEL(0x030bdfb8u),
    STOCK_LABEL(0x030bdfc4u),
    STOCK_LABEL(0x030bdfd4u),
    STOCK_LABEL(0x030bdfe0u),
    STOCK_LABEL(0x030bdfecu),
    STOCK_LABEL(0x030bdff4u),
    STOCK_LABEL(0x030be000u),
    STOCK_LABEL(0x030be00cu),
    STOCK_LABEL(0x030be018u),
    STOCK_LABEL(0x030be024u),
    STOCK_LABEL(0x030be030u),
    STOCK_LABEL(0x030be03cu),
    STOCK_LABEL(0x030be044u),
    STOCK_LABEL(0x030be050u),
    STOCK_LABEL(0x030be05cu),
    STOCK_LABEL(0x030be068u),
    STOCK_LABEL(0x030be074u),
    STOCK_LABEL(0x030be084u),
    STOCK_LABEL(0x030be090u),
    STOCK_LABEL(0x030be09cu),
    STOCK_LABEL(0x030bd1b0u),
    ts_match_label, cc_match_label
};
static const char *const other_en[] = {
    STOCK_LABEL(0x030be0a8u),
    STOCK_LABEL(0x030be0b8u),
    STOCK_LABEL(0x030be0c4u),
    STOCK_LABEL(0x030be0d0u),
    STOCK_LABEL(0x030be0d4u),
    STOCK_LABEL(0x030be0e0u),
    STOCK_LABEL(0x030be0ecu),
    STOCK_LABEL(0x030be0fcu),
    STOCK_LABEL(0x030be10cu),
    STOCK_LABEL(0x030be118u),
    STOCK_LABEL(0x030be124u),
    STOCK_LABEL(0x030bd1d0u),
    STOCK_LABEL(0x030be130u),
    STOCK_LABEL(0x030be13cu),
    STOCK_LABEL(0x030be14cu),
    STOCK_LABEL(0x030be15cu),
    STOCK_LABEL(0x030be168u),
    STOCK_LABEL(0x030be170u),
    STOCK_LABEL(0x030be180u),
    STOCK_LABEL(0x030be18cu),
    STOCK_LABEL(0x030be198u),
    STOCK_LABEL(0x030be1a4u),
    ts_match_label, cc_match_label
};
const dm32_menu_descriptor dm32_scan_menu_candidate[2] = {
    {scan_cn, 10, 2, 0}, {scan_en, 10, 2, 0}
};
const dm32_menu_descriptor dm32_other_menu_candidate[2] = {
    {other_cn, 24, 2, 0}, {other_en, 24, 2, 0}
};
