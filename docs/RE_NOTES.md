# Reverse engineering notes: DM32.NRF.01.049

## Target and evidence

Radio: Baofeng DM32UV, firmware DM32.NRF.01.049. Official wrapper SHA-256: aff6b4dc09dcce45847173defba26e94157cc628af86826e21e5af227bdc52dd. Stock program backup SHA-256: de7dbcbc9302396e1c35a3325328cdf307f107949faf705caafc1604311c97f0. The code is C-SKY CK803S/HR-C7000, not ARM. Application VA starts at 0300C000; program-flash offset is VA minus 03000000.

Use confidence labels: hardware-verified means owner observed it on the radio and readback matched; code-verified means supported by instructions/literals/call flow; inferred means likely but not proven; unreviewed means catalog-only. The C-like output is not original source and cannot reproduce the vendor binary exactly.

## Menu and UI

Scene object begins at RAM 320C8; current scene byte +3, pending callback +4. UI mutex at 3E4E0. Current menu count/items/index at 3E618, 3E61A, 3E5EC; saved indices at 3E508; main physical map at 3E65F; Scan map at 3E682. Main physical ID 1 is Scan. Scan scene 0E; Scan List child scene 15.

Dispatch/confirmation/key routines: 03038500, 0303B6AC, 03048F50, 0304D07C, 03013078. Recovered tables and evidence are in analysis/ghidra_scripts and analysis/reference.

## Scan Zone

Stock scan state begins at RAM 3E160. Mode getter/setter: 0302ECE0/0302ECA0. Stop/start: 0302F388/0302F418. Scan List record loader: 0302E1A4. Native list renderer: 0302E820. Zone locator/current-channel lookup: 03055C90/0305660C.

The home source label is the 11-byte field at 3E196 with a terminator at 3E1A1. Channel/TX name is separate at 3E1A2. Native Scan List checkmark draws are at 0302E8C6 and 0302E952 via 03018D78 using bitmap 03082BE0. Generic marker helper 03039E34 does not cover that path. Scan Zone uses the same checkmark bitmap and the bridge suppresses native list ticks when zone source is selected. Owner reports the latest image works.

Current image SHA-256: 156a48723b20aadabab1a674f99c036c0319b2791667869d8b5e382128fc2e53. Full readback result is analysis/inputs/latest_install_result.json. Mod uses 32 bytes of reserved RAM at 4BFC0..4BFE0 and candidate code area beginning 030DFCEC. Stock prefix, startup and heap invariants were checked for each image.

## TS/CC receive investigation

CC setter path 0305CCF0 -> 0301EC40. The setter changes receiver software state and bit 8 of hardware register 11000384 based on argument bit 0. This setter behavior is code-verified; matched/mismatched packet acceptance remains untested end-to-end.

TS candidate 0301ECC0 writes receiver state bits but is not itself proof of dual-slot monitoring. DMR candidates 030239D4, 03028644 and 03028BE4 require deeper trace. Nearby receive code extracts CC from bits 7:4 of a decoded word, but the earliest TS/CC accept/drop point is not yet established.

Next trace: sync acquisition -> slot decode -> CC/TS comparisons -> RX accept/drop. Find callers of stock setters and their persistent setting fields. Compare matched/mismatched CC and slot on radio. Keep TX/PTT behavior unchanged as requested.

## Boundaries

Keep full program/data-flash backups and dated install logs. Do not write radio from an unattended agent. Image builds must use exact known baseline, guarded patch bytes and full-image comparison. The latest verified feature does not establish correctness of untested scanner modes or receive behavior.
