# CC Match off — design (static, 2026-10-14)

Design only: nothing here is implemented, built or tested on a radio (no hardware tests are possible at the moment).
Inputs: CC_MATCH_ANALYSIS.md, DATA_PATH_ANALYSIS.md, MONITOR_ANALYSIS.md, TS_ANALYSIS.md, CHANNEL_RECORD.md,
the HR_C7000 datasheet (`docs/HR_C7000 Document 2.pdf`) and `tools/dm32` on the stock image `de7dbcbc…`.

## 1. Two layers decide whether a foreign-CC burst is processed

1. **Baseband (hardware).** `LOCAL_CC` `0x11000384` bits 9:8 `cc_opt` (datasheet p. 301): 0 = only frames whose CC equals
   the local CC are decoded; 1 = frames with any correctly received CC are decoded. Writers (code-verified, complete list
   from `tools/dm32 acc 11000384 --len 4`):
   - `0301E580` (RX mode setup, every channel/mode change): clears 9:8, sets bit 8 for RX mode 4 (DCDM) or when the
     Monitor flag `3BA6C` bit 3 is set (`0301E73C`), mirrors 8/0 into `3C61B`.
   - `0301EC40(on)` (Monitor setter): clears 9:8, sets bit 8 when `on`.
   - IRAM `0002D7C8`: bits 3:0 only (CC; `|0xF` in a mode-4 branch). Does not touch 9:8.
   - `0301E7BC(cc)`: bits 3:0 only.
2. **Software.** With `cc_opt=1` the software comparisons in CC_MATCH_ANALYSIS.md are the only CC filter.
   Correction to that table (code-verified 2026-10-14): **all** CSBK processing in `03027B9C` sits inside
   `if (33CCD == 3C61A)`; the only foreign-CC path is the mode-4 CC 15 case (`03024908`). Data header `03024E7C`,
   packet data `03025480` and PI header `03027584` compare without a Monitor bypass (DATA_PATH_ANALYSIS.md).

Consequence (inferred until hardware-verified): skipping the software checks alone would not receive foreign-CC
voice while `cc_opt=0`; CC Match off needs `cc_opt=1` **and** the voice-site bypass.

## 2. Why not reuse Monitor

The existing candidate (`firmware/source/mod_core.c`, `dm32_cc_ignore_argument()` → `0301EC40`) turns on the stock
Monitor state. That also sets `3BA6C` bit 3, which `0302768C` treats as "accept any destination": PCall/GCall Match
filtering is lost, and `03031FD4` clears it on every channel change. A dedicated flag is needed:

| Change | Where | Effect |
|---|---|---|
| keep bit 8 set | `0301E580` at `0301E73C` (test `3BA6C` bit 3) and the off branch of `0301EC40` | `cc_opt=1` survives channel changes and Monitor off |
| voice CC bypass | the four voice sites `03028644` (data-sync gate), `030282A4`, `03028180`, `03028BE4`: today `CC equal ∨ Monitor` | becomes `CC equal ∨ Monitor ∨ CC-Match-off` |
| unchanged | `03027B9C` (CSBK), `03024E7C`, `03025480`, `03027584` (PI, see §4), `03027334` (TX admit), `0302768C` | foreign-CC CSBK/data stay rejected in software; TX/PTT behaviour unchanged |

## 3. Storing the setting (CPS compatibility)

- Codeplug block 4 (`0x4000`) byte `0x60`: bit 0 Private Call Match, bit 1 Group Call Match (qdmr and NeonPlug agree;
  firmware boot loader `0304B010` reads only `&1`/`&2`; settings 9/10 in `0304B158` update single bits with
  `bseti`/`bclri`, preserving the rest — code-verified). Proposal: **bit 2 = CC Match off, bit 3 = TS Match off,
  0 = stock behaviour**, so any CPS that writes zeros restores stock behaviour.
- NeonPlug writes byte `0x60` from its model value (`digitalDecodeFlags`), i.e. it preserves bits it read. Official CPS
  behaviour for bits 2–7 is unknown: check offline by loading a codeplug file with bit 2 set in the CPS, saving it and
  comparing (PC-only, no radio).
- RAM: `3BA6D` bits 0–4 are already used (bits 0/4 gate `03028644`/`03028BE4`), `3EA06` (`3E9D4+0x32`) bits 2–6 too.
  Use the mod's reserved runtime block (`4BFC0`, `dm32_runtime.rx`, already declared) instead of stock RAM.

## 4. Open decisions (owner)

- PI header `03027584`: follow voice (encrypted foreign-CC calls) or keep strict? Default: keep strict.
- Data/SMS from foreign CC: keep rejected (DATA_PATH_ANALYSIS.md §8).
- With `cc_opt=1` the baseband delivers more frames; CPU load/side effects in IRAM `0002D7C8` are unreviewed.

## 5. Related safety finding (CSBK decode flags)

CPS/NeonPlug "Remote Monitor / Radio Disable / Radio Check / Radio Enable / Call Alert Decode" are block 4 byte `0x65`
bits 7/6/5/4/3 (NeonPlug `RadioSettings.ts`, qdmr `dmrMonitor`/`dmrKill`/`dmrRadioCheck`/`dmrReenable`/`dmrRXAlert`),
loaded by `0305D8C0` into `3BD58`. In `rxcsbk` `030209E4` (code-verified via decompiler and pointer literals
`3BD58`, `3BA54`): on a normal channel a disabled decode answers NACK and skips the action; **on an Rx Only channel
(`3BA6C` bit 1) Disable (stun), Enable and Call Alert are executed without checking the decode flags**
(`0302154C(6)` → `0305EB8C` → `0305DFDC` for stun). Radio Check and Remote Monitor do nothing on Rx Only channels.
Only same-CC CSBKs reach this code (§1). Not hardware-verified.

## 6. Follow-up (2026-10-14, fifth pass)

The datasheet confirms §1 (`HR_C7000_CROSSCHECK.md` §3.1). Completeness of the voice sites, the Idle-burst
correction for the data-sync gate, the TX-input side effects of `cc_opt = 1` and the final guarded site list are in
`MATCH_OPTIONS_DESIGN.md` §3.7 and §3.9. Storage: this file proposes the mod's runtime block at `4BFC0` for the
runtime flag, `MATCH_OPTIONS_DESIGN.md` §2 proposes `3BA6D` bits 5/6; `SETTINGS_CPS_ANALYSIS.md` §9 compares both.
