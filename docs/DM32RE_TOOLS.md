# dm32re: static-analysis helpers (2026-10-14)

Command-line tools for the stock DM32.NRF.01.049 image (`stock_progmem_1MiB.bin`, SHA-256 `de7dbcbc…`, verified on
load; `--image installed` selects `156a4872…`). Read-only: no serial port, no image output. Built on GNU binutils
2.42 for `csky-elfabiv2` (`tools/setup_cloud.sh`), Python 3.11+ standard library, and optionally Ghidra 12.1.4
with the legacy CSKY v0.2 module. Caches live under ignored `build/dm32re/`.

```sh
source /opt/dm32-tools.env
python3 tools/dm32 fn 0305CCF0           # annotated listing: literals, strings, callee roles, RAM/MMIO accesses
python3 tools/dm32 callers 03017560      # bsr/br tail calls, raw bsr sites, literal uses, table words
python3 tools/dm32 callees 03017560
python3 tools/dm32 tree 030174E0 --up --depth 3
python3 tools/dm32 acc 11000384 --len 4  # every tracked load/store to a RAM/MMIO range (+ literals)
python3 tools/dm32 refs 3E341            # acc + raw words equal to the address
python3 tools/dm32 str "WLT CMD"         # strings and the code/tables that use them
python3 tools/dm32 info 03072940
python3 tools/dm32 similar 0302E974      # look-alike functions
python3 tools/dm32 clusters --min 0.95   # groups of near-identical functions
python3 tools/dm32 decomp 0301EC40 03017560   # Ghidra C from the GZF; temporary function if Ghidra has none
python3 tools/dm32 libid build/dm32re/libref --csv out.csv   # library identification (below)
python3 -m unittest discover -s tools/tests -v
```

## How it works and its limits

- **Disassembly.** `objdump -b binary -m csky:ck803` mis-decodes this firmware: 32-bit instructions come out as two
  `.long` halves and `lrw` pool addresses are wrong (checked at `030174E6`). The tool instead wraps the flash
  (`0300C000…`) and IRAM (`00010000–0002F0B4`, copied from `030C0C38`, per the startup header) in an ELF via
  `.incbin`, puts a symbol at every catalog function, and adds `$d`/`$t` mapping symbols around literal-pool words
  found by its own `lrw`/`jsri` decoding (`pool_address`, checked against objdump on reference objects). It
  iterates until the reachable code stops changing (about 25 s, then cached).
- **Reachability.** Per function: fallthrough, conditional/unconditional branches and GCC switch tables
  (`cmphsi N; bt; lrw table; ldr.w (table, i << 2); jmp`). 94 tables resolve; no reachable `jmp` is left
  unresolved in the stock image. `fn` marks unreached bytes with `?` (pools, padding, or code reached only
  through function pointers).
- **Discovered entries.** 289 entries Ghidra lacks are added as `SUB_…`/`(new)`: `bsr` targets from reachable code
  and table words pointing at a `push` prologue (e.g. the Monitor handler `03017560`, table word `03072940`; the
  same table is also copied to SRAM `18000970`). Their extent is the gap to the next start.
- **Memory accesses.** A linear constant tracker (`movi/movih/ori/lsli/addi/subi/bseti/bclri/lrw/mov`, reset at
  branch targets and after calls) resolves `ld/st (rX, off)` addresses. It reproduces the documented
  `11000384` and `3E341` sites. Values held in callee-saved registers across calls are kept; values passed in
  memory or through pointers are not tracked, so a missing access is not proof of absence.
- **Similarity.** coddog-style: 3-gram candidate generation and difflib ratio on mnemonic streams;
  `SAME-SHAPE` marks identical operand shape. A look-alike is a lead for review, not shared semantics.
- **Ghidra.** `decomp` imports the GZF once into `build/dm32re/ghidra` and then runs
  `-process -noanalysis -readOnly`, so the database never changes. Output is cached per function.

Regression tests (`tools/tests/test_dm32re.py`) pin the documented code-verified facts: callers of `0305CCF0` and
`0301EC40`, table word `03072940`, the `03017560` callees `030174E0`/`0301742C`, the `11000384` and `3E341`
store sites, the IRAM switch table at `0002D83E`, and decoding of `lrw` encodings. 15/15 passed on 2026-10-14
from an empty cache (binutils 2.42, GCC 13.3, Ghidra 12.1.4, Python 3.13).

## Library identification (uC/OS-III)

The firmware contains uC/OS-III (strings `uC/OS-III Idle/ISR Queue/Tick/Stat/Timer Task`; the ISR Queue Task
implies a kernel older than the public V3.08.02). `tools/libref/build_ucos3.sh <dir>` builds uC/OS-III V3.08.02
and uC/LIB from https://github.com/weston-embedded (Apache-2.0) with upstream GCC 13.3 at `-Os/-O1/-O2` and a stub
CPU port. `libid` scores mnemonic similarity plus distinctive constants (`OS_ERR_*` codes, object tags such as
`0x414D4553` 'SEMA') and propagates names through call positions of strong matches.

Results for the stock image: `analysis/decompiled_modules/libid_ucos3_candidates.csv` (13 strong, 11 medium;
**all inferred**). The kernel sits mainly in IRAM (`00010000…`) with timer/queue/flag code in flash
(`0306xxxx`). Manually checked: `00011A58` ≈ `OSSemPend` (same error-code set and 'SEMA' tag) and `0306B78C` ≈
`OSTmrStateGet` (no `OS_ERR_TMR_INACTIVE`, calls only the lock/unlock pair; the tool listed it as shared with
`OSTmrDel`/`OSTmrStart`, which it is not). `SHARED` rows need that kind of review. Short functions (`ASCII_*`, `Str_*`)
match by accident and are reported weak; uC/LIB presence in the firmware is not established.
