#ifndef DM32_MATCH_OPTIONS_H
#define DM32_MATCH_OPTIONS_H
#include <stdbool.h>
#include <stdint.h>
#include "match_flags.h"
/* TS Match / CC Match receive options. Candidate sources, NOT installed and not hardware-tested.
   Site ids (C1..C7, T1..T9, B1, M1..M4) and register contracts: docs/MATCH_OPTIONS_CANDIDATE.md.
   With both options 0 every function returns exactly what the replaced stock instructions did. */

/* Stock RAM/MMIO used by the receive sites (literal-pool values, code-verified). */
#define DM32_RX_FLAGS_ADDRESS 0x0003ba54u   /* +0x18 = 3BA6C (bit 3 Monitor), +0x19 = 3BA6D */
#define DM32_RX_SLOT_ADDRESS 0x0003bea8u    /* +0 burst slot, +2 TX slot 3BEAA, +3 RX activity 3BEAB */
#define DM32_CHANNEL_RX_ADDRESS 0x00033cc8u /* +0 analog, +1 mode 33CC9, +4 slot 33CCC, +5 CC 33CCD, +0x15 33CDD */
#define DM32_CALL_STATE_ADDRESS 0x0003c614u /* +6 3C61A, +7 3C61B, +0xC 3C620[2], +0xE 3C622[2] */
#define DM32_RX_STATUS_ADDRESS 0x0003beccu  /* RX_TYPE_INFO copy from ISR 0002C458 */
#define DM32_LOCAL_CC_ADDRESS 0x11000384u   /* HR_C7000 LOCAL_CC: bits 9:8 cc_opt, 3:0 CC */

/* Receive-path decisions (called from register-exact stubs in match_caves.S). */
uint32_t dm32_cc_bypass(void);                    /* C2, C3, C4, C6: stock = 3BA6C & 8 */
uint32_t dm32_cc_bypass_dt(uint32_t data_type);   /* C1: bypass only for data types 1/2 */
uint32_t dm32_cc_counter_cc(uint32_t received);   /* C5: value compared with the received CC */
uint32_t dm32_cc_opt_monitor(uint32_t ba6c);      /* C7: stock = ba6c & 8 */
bool dm32_ts_drop_644(uint32_t sync, uint32_t data_type); /* T1, T2 (BS-sourced, modes 0/1) */
bool dm32_ts_drop_be4(void);                      /* T3, T4 */
uint32_t dm32_slot_of_call(void);                 /* T7: slot for the call descriptor */
uint32_t dm32_follow_guard(uint32_t sync_source); /* T8: stock = 33CDD */
uint32_t dm32_talkback_guard(void);               /* T9: stock = byte 3FD4C+0x1E */
void dm32_rx_wrap_644(void);                      /* T5: replaces bsr 03028644 in 030239D4 */
void dm32_rx_wrap_be4(void);                      /* T6: replaces bsr 03028BE4 in 030239D4 */
bool dm32_rx_restore_needed(uint32_t status, uint32_t slot);

/* Settings: boot load (B1) and the Other Func menu items 22/23 (M1..M4). */
void dm32_match_boot(uint32_t gcall, uint32_t pcall, uint32_t stored);
void dm32_match_apply_cc_opt(void);
void dm32_match_set(uint32_t item, uint32_t list_index);
void dm32_match_menu_open(uint32_t item);
uint32_t dm32_match_flags(void);

#define DM32_MATCH_ITEM_CC 22u
#define DM32_MATCH_ITEM_TS 23u
#define DM32_MATCH_STOCK_ITEMS 22u
#endif
