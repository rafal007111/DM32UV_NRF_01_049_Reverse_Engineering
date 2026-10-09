#ifndef DM32_MENU_TABLES_H
#define DM32_MENU_TABLES_H
#include <stdint.h>
/* Indices are zero based physical IDs; visible numbering is filtered by firmware. */
#define DM32_SCAN_ZONE_MENU_ID 9u
#define DM32_TS_MATCH_MENU_ID 22u
#define DM32_CC_MATCH_MENU_ID 23u
typedef struct {
    const char *const *labels;
    uint8_t count;
    uint8_t kind;
    uint16_t reserved;
} dm32_menu_descriptor;
#if UINTPTR_MAX == UINT32_MAX
typedef char dm32_menu_descriptor_size_check[(sizeof(dm32_menu_descriptor) == 8) ? 1 : -1];
#endif
/* Candidate descriptors only. Visibility, navigation and handlers are not hooked. */
extern const dm32_menu_descriptor dm32_scan_menu_candidate[2];
extern const dm32_menu_descriptor dm32_other_menu_candidate[2];
#endif
