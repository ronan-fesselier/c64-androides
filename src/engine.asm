    ;---------------------------------------------------------------------------
    ; engine.asm: boot stub, VIC-II setup, main entry points.
    ;---------------------------------------------------------------------------

    .include "c64_memory.inc"
    .include "vic_colors.inc"

    .import charset_data
    .import menu_screen
    .import clear_screen
    .import draw_map
    .import draw_crates
    .importzp src_ptr
    .importzp crate_ptr
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
    .import level00_crates
    .import level01_crates
    .import level02_crates
    .import level03_crates
    .import level04_crates
    .import level05_crates
    .import level06_crates
    .import level07_crates
    .import level08_crates
    .import level09_crates
    .import current_level_index
    .import title_screen
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

    PETSCII_1 = $31
    PETSCII_2 = $32

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
    JSR title_screen
    JSR wait_players_key
    STA num_players
    JMP start_level

wait_players_key:
wait_players_key_loop:
    JSR GETIN
    BEQ wait_players_key_loop
    CMP #PETSCII_1
    BEQ wait_players_key_one
    CMP #PETSCII_2
    BEQ wait_players_key_two
    JMP wait_players_key_loop
wait_players_key_one:
    LDA #1
    RTS
wait_players_key_two:
    LDA #2
    RTS

num_players: .byte 0

halt:
    JMP *

    ;---------------------------------------------------------------------------
    ; start_level: draw the level map.
    ;---------------------------------------------------------------------------

start_level:
    JSR clear_screen

    LDA #0
    STA current_level_index
    TAX
    LDA level_map_lo, X
    STA src_ptr
    LDA level_map_hi, X
    STA src_ptr + 1
    JSR draw_map

    LDA current_level_index
    TAX
    LDA level_crate_lo, X
    STA crate_ptr
    LDA level_crate_hi, X
    STA crate_ptr + 1
    JSR draw_crates

    JMP halt
level_map_lo:
    .byte <level00_map, <level01_map, <level02_map, <level03_map, <level04_map
    .byte <level05_map, <level06_map, <level07_map, <level08_map, <level09_map
level_map_hi:
    .byte >level00_map, >level01_map, >level02_map, >level03_map, >level04_map
    .byte >level05_map, >level06_map, >level07_map, >level08_map, >level09_map
level_crate_lo:
    .byte <level00_crates, <level01_crates, <level02_crates, <level03_crates, <level04_crates
    .byte <level05_crates, <level06_crates, <level07_crates, <level08_crates, <level09_crates
level_crate_hi:
    .byte >level00_crates, >level01_crates, >level02_crates, >level03_crates, >level04_crates
    .byte >level05_crates, >level06_crates, >level07_crates, >level08_crates, >level09_crates
