    ;---------------------------------------------------------------------------
    ; engine.asm: boot stub, VIC-II setup, main entry points.
    ;---------------------------------------------------------------------------

    .include "vic_colors.inc"

    .import charset_data
    .import menu_screen
    .import clear_screen
    .import draw_map
    .importzp src_ptr
    .import level00_map
    .import level01_map
    .import level02_map
    .import level03_map
    .import level04_map
    .import level05_map
    .import level06_map
    .import level07_map
    .import level08_map
    .import level09_map
    .import current_level_index
    .export start

    ; Load address for PRG ($0801 = start of BASIC)
    .segment "LOADADDR"
    .word $0801

    .segment "CODE"

    ; BASIC stub: "10 SYS 2061" -> jumps to machine code
    .byte $0B, $08, $0A, $00, $9E
    .byte "2061"
    .byte $00, $00, $00

    BORDER_COLOR = $D020
    BG_COLOR     = $D021
    VIC_MEMPTR   = $D018      ; screen memory/charset pointer register

    ;---------------------------------------------------------------------------
    ; init: VIC-II setup, then enter the boot menu.
    ;---------------------------------------------------------------------------

init:
    SEI                       ; disable interrupts while remapping VIC memory

    LDA #COLOR_BLACK
    STA BORDER_COLOR
    STA BG_COLOR

    ; D018 bits 7-4 = screen addr/1024 ($0400->1), bits 3-1 = charset addr/2048 ($3800->7)
    LDA #%00011110
    STA VIC_MEMPTR

    CLI

    JMP menu_screen

    ;---------------------------------------------------------------------------
    ; start: main game entry point.
    ;---------------------------------------------------------------------------

start:
    JSR clear_screen

    LDA #0
    STA current_level_index
    TAX
    LDA level_map_lo, X
    STA src_ptr
    LDA level_map_hi, X
    STA src_ptr + 1
    JSR draw_map

halt:
    JMP *

level_map_lo:
    .byte <level00_map, <level01_map, <level02_map, <level03_map, <level04_map
    .byte <level05_map, <level06_map, <level07_map, <level08_map, <level09_map
level_map_hi:
    .byte >level00_map, >level01_map, >level02_map, >level03_map, >level04_map
    .byte >level05_map, >level06_map, >level07_map, >level08_map, >level09_map
