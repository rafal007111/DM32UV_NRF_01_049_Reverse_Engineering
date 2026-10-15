#ifndef DM32_MATCH_FLAGS_H
#define DM32_MATCH_FLAGS_H
/* TS/CC Match option storage. Candidate only: owner decision still open
   (docs/MATCH_OPTIONS_DESIGN.md section 2, SETTINGS_CPS_ANALYSIS.md section 9.3).
   Default of the 2026-10-15 pass: runtime flags in stock RAM 3BA6D (3BA54+0x19) bits 5/6,
   which have no reader or writer in stock firmware (inferred, register-tracking scan).
   To move them into the mod block (4BFC0, dm32_runtime.rx) change only this header. */
#define DM32_MATCH_FLAGS_ADDRESS 0x0003ba6du
#define DM32_MATCH_CC_OFF 0x20u /* 1 = CC Match off (accept voice with any CC) */
#define DM32_MATCH_TS_OFF 0x40u /* 1 = TS Match off (receive the other slot, one captured slot) */

/* Persistent copy: codeplug/data-flash area 4 byte 0x60, bits 2/3. 0 = stock behaviour,
   so a CPS that writes zeros restores stock. CPS preservation of these bits is unverified. */
#define DM32_MATCH_STORE_AREA 4u
#define DM32_MATCH_STORE_OFFSET 0x60u
#define DM32_MATCH_STORE_CC_OFF 0x04u
#define DM32_MATCH_STORE_TS_OFF 0x08u

/* Captured/displayed call slot (3BEA8+0x15), free BSS byte (inferred, MATCH_OPTIONS_DESIGN.md 3.8.4).
   Bit 4 marks a valid value, bit 0 is the slot. */
#define DM32_MATCH_CALL_SLOT_ADDRESS 0x0003bebdu
#define DM32_MATCH_CALL_SLOT_VALID 0x10u
#endif
