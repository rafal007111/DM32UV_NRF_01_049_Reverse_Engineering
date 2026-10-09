/* Inactive candidate shim. Exact stock frame; final ABI review is mandatory.
 * The branch enters only the already-validated portion of stock Scan Start.
 * Raw halfwords avoid relying on assembler alias syntax for C-SKY push/subi.
 */
    .section .text.dm32_zone_start_tail,"ax"
    .balign 4
    .global dm32_zone_start_tail
    .type dm32_zone_start_tail,@function
dm32_zone_start_tail:
    .short 0x14d3 /* stock push r4,r5,r6,lr */
    .short 0x142d /* stock subi sp,52 */
    .short 0x6d03 /* stock mov r4,r0 */
    .short 0x1062 /* lrw r3, aligned PC + 8 -> literal at offset 12 */
    .short 0x780c /* jmp r3; caller LR was saved in the stock frame */
    .short 0x0000 /* padding; never executed */
    .long 0x0302f498
    .size dm32_zone_start_tail,.-dm32_zone_start_tail
