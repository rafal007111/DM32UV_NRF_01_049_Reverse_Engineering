# Alert tones and the tone task — DM32.NRF.01.049

Static analysis, 2026-10-17 (sixth pass). No radio access, no image built, nothing hardware-verified. Inputs, hashes
and tools as in `HR_C7000_CROSSCHECK.md` §0. Builds on `MONITOR_ANALYSIS.md` §2 (tone ids `0x18`/`0x19`/`0x21`).

## 1. Engine (code-verified)

- `03021C1C(id)` stores `id` in `3BE64` and posts event `0x40` on `3FDB0` (known).
- Task loop `03022FB0` (uncatalogued): waits for `0x40` on `3FDB0`, clears it, then: `3BE64 == '('` → `03061648`;
  `3BE64 == ')'` → `03022F18(386A8)`; otherwise `03022410(id)`.
- `03022410(id)` gates, prepares the audio path and plays one pattern:
  - **Radio Silent**: if getter `0304C434(0x10)` is non-zero (id `0x10` is the Radio Silent setting id in `SETTINGS_CPS_ANALYSIS.md` §1.1; that the getter uses the same id is inferred), only ids `0x0F` and
    `0x16` play;
  - nothing plays while `3E340` (`3E334+0xC`, the byte the analog Monitor toggle `0301742C` uses) is non-zero;
  - while `3FDEC & 3` (bit 0 = call display, `RX_CALL_PATH_ANALYSIS.md` §1.3) ids `0x10`–`0x14` and `0x21` are dropped,
    so key/refusal beeps are suppressed during a received call;
  - sets `3E334+7` bit 3 (tone active), mutes the RX path (`0300E360` when `3FDEC` bit 2), on analog channels
    `0002B550`, GPIO `0x2F` on (`0002C548`), audio route `03055BF8`/`03055C28`, `0301E4F0(1)`, amplifier `0301D624(1)`.
  - patterns are sequences of `03021C88(duration, f1, f2, f3, f4, l1, l2, l3, l4)` (up to four simultaneous
    components; reading of the arguments as durations/frequency words/levels is **inferred**, units unverified),
    `03021FE0`/`03021DE0` (variants), `0302215C(n)` pauses (inferred).

## 2. Tone ids (callers from a `movi r0, id; bsr 03021C1C` scan; meaning labels inferred unless marked)

| Id | Callers | Meaning |
|---|---|---|
| `0x00`–`0x04`, `0x0A`, `0x0B` | none found by the scan (may be queued with a computed id) | multi-segment beeps |
| `0x05`–`0x09` | | custom tones: one byte read from handle `386B4` at `(id + 0xE1)·0x10` → `0302225C` |
| `0x0F` | `03021C44` when `3E9D4+0x43` bit 6 = Voice Func **StartUp Sound** (`3EA17` bit 6, `SETTINGS_CPS_ANALYSIS.md` §1.1) | power-on melody, LED toggled during it (`030611B0`/`030611CC`); **plays even with Radio Silent** (code-verified) |
| `0x10`–`0x14` | | short single beeps (key tones, inferred); dropped during a call display |
| `0x15`, `0x2E`, `0x2F` | `0300E530`, `0302D674`, `03055A70`; `030654F8` (`0x2E`/`0x2F`) | four-times repeated two-segment patterns (siren-like) |
| `0x16` | `0301AC98` (analog call screen with decoded `PTT ID`, when `3FD4C+1` bit 3 is set), `0302D598` | **looped sample sound** (`03022190`): IMA-style 4-bit samples from `030AFBA0` (`0x4F0` bytes, decoder `03029EA8`) written to `16000980` while `3FD4C+1` bit 3 is set (alarm state, inferred); **plays even with Radio Silent** |
| `0x18` / `0x19` | 20 / 18 sites (e.g. Monitor on/off `030174E0`) | "on" / "off" confirmation (code-verified sites, `MONITOR_ANALYSIS.md`) |
| `0x1A` | 12 sites | two-segment chord |
| `0x1B`, `0x30` | 45 sites; PTT handler `0305C334` (`0x30`) | long low tone — error/not allowed (inferred from 45 refusal-style sites) |
| `0x1F` | side-key handler `030149A4` | |
| `0x20` | channel change `03031FD4`, `0303B374`, boot channel restore `03058528` | `03021DE0` pattern |
| `0x21` | 58 sites | "refused" (code-verified sites, `MONITOR_ANALYSIS.md`); dropped during a call display |
| `0x22` | `0305DD00` when `3FD4C+0x2D` bit 3 and not `3BD6C` bit 1 | alarm-related (inferred) |
| `0x23` / `0x25` | `0305E3F0` via `030397E0` (and `0x25` from `0301BCC4`, `030654F8`) | group / private call start (code-verified, `RX_CALL_PATH_ANALYSIS.md` §1.3) |
| `0x27` | | `0302236C(3BD98)` with audio route `03055C28(6)` |
| `0x28` | `0306160C` | |
| `0x29` | `0300F258` | |
| `0x2D` | analog Monitor area (`03017420`, unreached by the catalog) | |

## 3. Open questions (owner) and checks

1. With Radio Silent on, does the radio still play the power-on melody (if StartUp Sound is on)? Expected (code): yes.
2. Which event plays id `0x16` (looped sample)? Expected: emergency alarm siren; safe check without TX: none — leave.
3. During a received call, are key beeps silent? Expected (code): yes for ids `0x10`–`0x14`.

## 4. Not reviewed

`03021C88`/`03021FE0`/`03021DE0` argument units, `0302225C` (custom tones), `03022F18`, `03061648`, the callers of
ids `0x15`, `0x1F`, `0x28`, `0x29`, `0x2D`, `0x2E`, `0x2F`, the analog TX tone paths (`Ana Roger`, TBST).
