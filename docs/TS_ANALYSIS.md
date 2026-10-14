# Time slot handling and receive slot filtering — DM32.NRF.01.049

Static analysis, 2026-10-14. Same toolchain and inputs as `docs/MONITOR_ANALYSIS.md` (Ghidra 12.1.4 headless,
legacy CSKY v0.2 module + `32b_data.fixed.sinc`, GZF `354f9324…`, stock image `de7dbcbc…`). Pointer literals
in flash and IRAM were resolved against the stock image (IRAM source `030C0C38` → `00010000`).
No hardware test has been performed for anything in this file.

## 1. Channel record fields (current channel copy at `3E1F8`)

| Field | Meaning | Evidence | Confidence |
|---|---|---|---|
| byte `+0x08` bits 7:4 (`&0x70` used) | channel type; 1 = digital | `030570E8` (setting `'D'`) writes it; `03056330` routes digital only for value 1 | code-verified (other values inferred) |
| byte `+0x0D` bits 3:0 | Color Code | `030572B8` (setting `'3'`) writes it; home screen prints it with `"CC:%d"` | code-verified |
| byte `+0x0D` bit 4 | Time Slot: 0 → **T1**, 1 → **T2** | `03056FFC` (setting 5) writes it; home screen `0302B9A4` draws `"T1"` (`0x3154`) or `"T2"` (`0x3254`) from this bit | code-verified |
| byte `+0x0D` bit 5 | selects RX mode 4 on simplex digital channels | `030571CC` (setting `'F'`) sets it when the menu value is 0 and clears it otherwise; `03056330` uses it | code-verified (menu label inferred: probably **Double Slot**, channel menu item at `030B9968`) |

Setting IDs are handled by the generic apply function `0304B158(id, value)` (code-verified for ids 5, `'3'`, `'D'`, `'F'`, 9, 10, `'E'`).

## 2. RX mode selection

`03056330(channel)` (callers `0303821E`, `030583E0`) calls `0301E580(type, mode, slot)`:

| Channel | `mode` | `33CC9` |
|---|---|---|
| analog | 0 (with type 0) | analog path |
| digital, RX freq == TX freq, bit 5 clear | 0 | 0 (simplex) |
| digital, RX freq == TX freq, bit 5 set | 4 | 4 (inferred: dual-slot direct / Double Slot) |
| digital, RX freq != TX freq | 1 | 1 (repeater) |

`slot` = bit 4 of `+0x0D`. `0301E580` stores it in `33CCB`/`33CCC` (`33CC8+3`/`+4`) and in bit 0 of `11000100`
for modes 1 and 4; for mode 0 it forces slot 0. Mode 2 (`33CC9==2`) is not set by `0301E580`; it is used by the
`03023EB8` path, which derives slot and a channel index from a received 5-bit value (rest-channel/trunking-like,
unreviewed).

Runtime slot change: `0301ECC0(slot)` (setting 5) writes `11000100` bit 0, `33CCB`, `33CCC`, `3BEAA`, `3BEAC`.

## 3. Per-burst slot tracking (code-verified)

- Status dispatcher `030239D4` (called by BSR at IRAM `0002D796`, in uncatalogued IRAM code, inferred interrupt path) reads status word `3BEA0`: bit 3 → `03028644`, bit 2 → `03028BE4`,
  bit 1 → IRAM `0002D6C0`, bit 4 → `03027388`, bit 6 → `03023880`.
- IRAM `0002D500(mode)` is called by BSR at IRAM `0002D67C` (uncatalogued IRAM code; per-burst invocation inferred from the TC-bit history it keeps). For modes 0/1 it reads the **CACH TC bit** (status `11000390` bit 22),
  shifts it into a history at `3BEB2` (`3BEA8+10`) and declares slot sync (`3BEB1`=`3BEA8[9]`=1) after an
  alternating `0101`/`1010` pattern. After lock the current burst slot `3BEA8` follows the TC bit or toggles each burst.
  It also accumulates status bits 21:20 in `3BEBC`.
- IRAM `0002D6C0` (mode 1, after lock): when the TC slot differs from `33CCB`, stores status bit 23 in `3BEBB`
  (inferred: CACH AT / channel-busy information for the other slot, used for TX permission).
- `03024868` (CSBK path) sets the current slot from `11000390` bits 3:2.

So the firmware sees bursts from **both** slots and labels each one in software (code-verified). Whether the
HR-C7000 also filters slots in hardware through `11000100` bit 0 is **not established**; the software gates below
would be redundant if it did, which makes hardware slot filtering in mode 1 unlikely (inferred).

## 4. Receive slot gates (code-verified)

| Function | Mode | Condition → drop burst |
|---|---|---|
| `03028644` (header/data bursts) | 0, 1 (sync class 1) | slot locked (`3BEB1`) and `3BEA8 != 33CCC` |
| `03028644` | 2 | locked and `33CCC != 3BEA8` |
| `03028644` | 4 | data-sync burst with `3BEA8 != 3BEAA`, except CSBK (type 3) with CC 15 |
| `03028644` | 0, 1 (sync class 0) | call active on the other slot (`3C620+other`, `3C622+other`) |
| `03028BE4` (voice/embedded path) | 0, 1, 2 | locked and `3BEA8 != 33CCC` |
| `03028BE4` | 4 | `3BEA8 != 3BEAA` |

The Monitor flag does not bypass any of these gates (no `3BA6C & 8` test in these branches). Per-slot call
state is kept in arrays indexed by slot (`3C620[slot]`, `3C614[0xC+slot]`, `3C614[0xE+slot]`, `3C614[0x12+slot]`),
so the data structures already distinguish both slots.

## 5. Existing call-match options (code-verified)

Strings `PCall Match` (`030BE18C`) and `GCall Match` (`030BE198`) are items of the **Other** settings menu
(pointer slots `030B96F4`/`030B96F8`, next to the descriptor at `030B9700` that the Scan Zone work extended).
Settings 9 and 10 in `0304B158` store them in codeplug block 4 offset `0x60` bits 0/1 and, via `0301ECF0`, in
`3BA6D` (`3BA54+0x19`) bits 1 and 2. `0302768C` uses them: bit 1 rejects private calls not addressed to the own
ID; bit 2 restricts group calls to the channel contact (`33CC8+0x2C`) and the RX group list (`33CF8`, 32 IDs).
Monitor overrides both. This is the natural place for TS Match and CC Match menu items.

## 6. Consequences for TS Match (off = receive both slots)

- Minimal software change: skip the `3BEA8 != 33CCC` gates in `03028644` and `03028BE4` for modes 0/1 when a
  new "TS Match off" flag is set.
- Needed on top (not yet analyzed): keep only one call at a time (first slot wins until its terminator/timeout),
  make sure audio, call display and hang time follow the accepted slot, and leave TX slot (`33CCB`, `11000100`
  bit 0) unchanged so PTT keeps using the programmed slot.
- Risk: `0002D6C0` uses the other slot's AT bit for TX permission; changing RX slot selection must not alter it.
- Before any patch: confirm whether `11000100` bit 0 gates slots in hardware (e.g. trace all readers/writers and
  the HR-C7000 register meaning), because a hardware filter would make the software change ineffective.

## 7. Is `11000100` a hardware slot filter? (step 1, 2026-10-14)

All accesses (full-program decompiler search): written by `030215C8` (`0x13` mode-4 init, `2`, `0x80`, `0x22`),
`03023574` (`0x6E` at DMR init), `0301E580` (`&0x7E|4` for slot 1 → `0x6E`, `&~0x80|5` for slot 2 → `0x6F`,
`|0x80` analog), `0301ECC0` (bit 0 = slot), `03061D50` (bit 7), and saved/restored by IRAM `000169D8`/`00016AD0`.
No receive routine reads it.

External comparison (design reference only, no code copied): OpenGD77 (`open-ham/OpenGD77` commit `b843c1f`,
GPL-2.0) drives the related HR-C6000. Its register `0x10` is initialised to `0x6E` with the comment
"DMR, Tier2, Timeslot mode, Layer2, Repeater, Aligned, Slot 1". OpenGD77 receives both slots with that value and
implements its TS filter purely in software: CACH TC from register `0x52` bit 2, received CC from `0x52`
bits 7:4, and a "captured slot" with a timeout when the TS filter is off.

The DM32 values (`0x6E`/`0x6F` per slot, `0x80` analog) and the software TC tracking plus software slot gates
match that model. **Inferred (strong):** `11000100` is the HR-C7000 counterpart of HR-C6000 register `0x10`; bit 0
selects the radio's own (TX/timing) slot and does not stop the other slot's bursts from reaching software.
Not hardware-verified. The C7000 register map is not a 1:1 copy (32-bit registers; e.g. sync patterns at
`11000350`… are packed 16-bit pairs of the C6000 byte table).

## 8. Call arbitration and audio (step 2)

- Per-slot voice call state `3C620[slot]` (`3C614+0xC+slot`): set to 1 by the voice LC header handler
  `030282A4` and by the late-entry path in `03028BE4`; cleared by the terminator handler `03028180`, `030297A4`
  and `030234E8` (slot 0). `3C622[slot]` and `3C626[slot]` are further per-slot counters/flags (unreviewed).
- `030282A4` stores the accepted call's LC per slot (`3C614+0x2A+12*slot`…), destination at `3C62C+4*slot`,
  source at `3C634+4*slot`, then posts event `2` via `0300C724` (consumer not traced).
- In `030282A4`, when status bit 2 is 0 (direct/MS-sourced burst, inferred), the radio copies the received slot
  into `3BEAA`/`3BEAC`. `3BEAA` is the slot that TX admission checks use (`03027320`), so in direct mode the
  current slot follows the received call (code-verified copy; TX consequence inferred).
- Voice bursts (sync class 1) in `03028644` are read from the baseband (`0300D41C` with buffer selectors
  `0x36/0x66/0x39/0x69`) into **one shared ping-pong buffer** at `3C69C` (`3C614+0x88`, index `3C6D2`) for any
  slot whose `3C620[slot]` is set. Recording (`3F722`) copies from the same buffer.
- Consequence: with the slot gates removed, two simultaneous calls would interleave in the same voice buffer.
  A TS Match off implementation must keep one captured slot: accept the first voice header, ignore the other
  slot until terminator or timeout. OpenGD77 uses exactly this capture model.
- TX constraints found: `030272EC` (channel busy: `3BEBB` other-slot busy or `3BEAB` RX activity), `03027320`
  (no call on `3C624[3BEAA]`) and `03027334` (CC differs) feed the TX admit policy in `0301DE64`/`0301DF0C`/
  `0301DF8C` (policy 0 always, 1 channel free, 2 colour-code free; caller `0301F118`, `03020DC8`, `03020FE4`).
  A TS Match change must not modify `3BEAA`/`3BEAC`, `33CCB` or these functions.
