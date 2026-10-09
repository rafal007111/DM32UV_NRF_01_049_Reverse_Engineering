OUTPUT_FORMAT("elf32-csky-little")
OUTPUT_ARCH(csky)
ENTRY(dm32_zone_init)
/* Candidate staging location only. This output is not a complete firmware. */
MEMORY { PATCH (rx) : ORIGIN = 0x030DFCEC, LENGTH = 0x1800 }
SECTIONS {
    .text : ALIGN(4) { *(.text*) } > PATCH
    .rodata : ALIGN(4) { *(.rodata*) } > PATCH
    .data : ALIGN(4) { *(.data*) } > PATCH
    .bss (NOLOAD) : ALIGN(4) { *(.bss*) *(COMMON) } > PATCH
    /DISCARD/ : { *(.eh_frame*) *(.comment*) *(.note*) *(.csky_stack_size) }
}
ASSERT(SIZEOF(.data) == 0, "Writable data needs a verified RAM mapping")
ASSERT(SIZEOF(.bss) == 0, "BSS needs a verified RAM mapping")
