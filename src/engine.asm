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
    .import level00_hero
    .import level01_hero
    .import level02_hero
    .import level03_hero
    .import level04_hero
    .import level05_hero
    .import level06_hero
    .import level07_hero
    .import level08_hero
    .import level09_hero
    .import level00_pursuers
    .import level01_pursuers
    .import level02_pursuers
    .import level03_pursuers
    .import level04_pursuers
    .import level05_pursuers
    .import level06_pursuers
    .import level07_pursuers
    .import level08_pursuers
    .import level09_pursuers
    .import current_level_index
    .import sprites
    .import title_screen
    .export start
    .export position_sprite
    .exportzp entity_ptr
    .exportzp sprite_index

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

    VIC_SPRITE_ENABLE = $D015
    VIC_SPRITE0_X     = $D000
    VIC_SPRITE0_Y     = $D001
    VIC_SPRITE0_COLOR = $D027
    VIC_SPRITE_X_MSB  = $D010 ; 9th X bit, one bit per sprite
    SPRITE_PTR_BASE   = $07F8 ; sprite pointers live at the end of screen RAM ($0400+$3F8)

    PETSCII_1 = $31
    PETSCII_2 = $32

    ; zero-page scratch (defined before use, as ca65 is single-pass)
    sprite_ptr_tmp = $13
    sprite_x_lo    = $14
    sprite_x_hi    = $15
    sprite_x_msb   = $16
    sprite_y_tmp   = $1A

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

    LDA #0
    STA VIC_SPRITE_X_MSB

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
    STA VIC_SPRITE_ENABLE      ; clear sprites

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
    JSR draw_hero
    JSR draw_pursuers

    JMP halt

    ;---------------------------------------------------------------------------
    ; position_sprite: common sprite placement, shared by the hero and the
    ; pursuers.
    ; On entry: X = sprite number (0-7), entity_ptr = pointer to a
    ; {col, row} tile-unit pair.
    ; Sets the sprite's pointer (SPRITE_PTR_BASE+X), X/Y position
    ; (with the 9th X bit handled) and enables it in VIC_SPRITE_ENABLE. 
    ;---------------------------------------------------------------------------

SPRITE_SCREEN_X0 = 24
SPRITE_SCREEN_Y0 = 50

entity_ptr = $17               ; 2 bytes ($17/$18), zero-page scratch
sprite_index = $19

position_sprite:
    STX sprite_index

    ; sprite pointer = address / 64. sprites is 64-byte aligned and
    ; < $4000 (same video bank as SCREEN_RAM), so this is simply
    ; (hi_byte * 4) | (lo_byte >> 6).
    LDA #>sprites
    ASL A
    ASL A
    STA sprite_ptr_tmp
    LDA #<sprites
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    ORA sprite_ptr_tmp
    STA SPRITE_PTR_BASE, X     ; X = sprite_index (unchanged since STX above)

    LDY #0
    LDA (entity_ptr), Y        ; col
    STA sprite_x_lo
    LDA #0
    STA sprite_x_hi

    ASL sprite_x_lo
    ROL sprite_x_hi
    ASL sprite_x_lo
    ROL sprite_x_hi
    ASL sprite_x_lo
    ROL sprite_x_hi            ; hi:lo = col * 8 (16 bits)

    CLC
    LDA sprite_x_lo
    ADC #SPRITE_SCREEN_X0
    STA sprite_x_lo
    LDA sprite_x_hi
    ADC #0
    STA sprite_x_hi

    LDX sprite_index
    TXA
    ASL A                      ; VIC sprite X/Y registers are 2 bytes apart
    TAX
    LDA sprite_x_lo
    STA VIC_SPRITE0_X, X

    LDX sprite_index           ; back to the plain (unshifted) sprite number
    LDA sprite_x_hi
    AND #$01
    BEQ position_sprite_msb_clear
    LDA VIC_SPRITE_X_MSB
    ORA bit_table, X
    STA VIC_SPRITE_X_MSB
    JMP position_sprite_y
position_sprite_msb_clear:
    LDA VIC_SPRITE_X_MSB
    AND inv_bit_table, X
    STA VIC_SPRITE_X_MSB

position_sprite_y:
    LDX sprite_index
    INY
    LDA (entity_ptr), Y        ; row
    ASL A
    ASL A
    ASL A                      ; row * 8
    CLC
    ADC #SPRITE_SCREEN_Y0
    STA sprite_y_tmp

    TXA
    ASL A
    TAX
    LDA sprite_y_tmp
    STA VIC_SPRITE0_Y, X

    LDX sprite_index
    LDA VIC_SPRITE_ENABLE
    ORA bit_table, X
    STA VIC_SPRITE_ENABLE
    RTS

bit_table:
    .byte %00000001, %00000010, %00000100, %00001000
    .byte %00010000, %00100000, %01000000, %10000000
inv_bit_table:
    .byte %11111110, %11111101, %11111011, %11110111
    .byte %11101111, %11011111, %10111111, %01111111

    ;---------------------------------------------------------------------------
    ; draw_hero: hero spawns as sprite 0, colored yellow.
    ;---------------------------------------------------------------------------

draw_hero:
    LDX current_level_index
    LDA level_hero_lo, X
    STA entity_ptr
    LDA level_hero_hi, X
    STA entity_ptr + 1

    LDX #0
    JSR position_sprite
    LDA #COLOR_YELLOW
    STA VIC_SPRITE0_COLOR
    RTS

    ;---------------------------------------------------------------------------
    ; draw_pursuers: walk the level's pursuer list (col, row pairs terminated
    ; by PURSUER_LIST_END), assigning sprites 1.. in order, colored white.
    ;---------------------------------------------------------------------------

PURSUER_LIST_END = 255
VIC_SPRITE_COLOR_BASE = $D027

draw_pursuers:
    LDX current_level_index
    LDA level_pursuers_lo, X
    STA entity_ptr
    LDA level_pursuers_hi, X
    STA entity_ptr + 1

    LDX #1                     ; sprite 1 is the first pursuer slot (0 = hero)
draw_pursuers_loop:
    CPX #8                     ; only 8 hardware sprites exist (0-7)
    BCS draw_pursuers_done
    LDY #0
    LDA (entity_ptr), Y
    CMP #PURSUER_LIST_END
    BNE draw_pursuers_body
draw_pursuers_done:
    RTS
draw_pursuers_body:
    STX sprite_index
    JSR position_sprite
    LDX sprite_index
    LDA #COLOR_WHITE
    STA VIC_SPRITE_COLOR_BASE, X       ; sprite N color reg = $D027 + N

    ; advance entity_ptr by 2 bytes (col, row) for the next pursuer
    CLC
    LDA entity_ptr
    ADC #2
    STA entity_ptr
    LDA entity_ptr + 1
    ADC #0
    STA entity_ptr + 1

    INX
    JMP draw_pursuers_loop

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
level_hero_lo:
    .byte <level00_hero, <level01_hero, <level02_hero, <level03_hero, <level04_hero
    .byte <level05_hero, <level06_hero, <level07_hero, <level08_hero, <level09_hero
level_hero_hi:
    .byte >level00_hero, >level01_hero, >level02_hero, >level03_hero, >level04_hero
    .byte >level05_hero, >level06_hero, >level07_hero, >level08_hero, >level09_hero
level_pursuers_lo:
    .byte <level00_pursuers, <level01_pursuers, <level02_pursuers, <level03_pursuers, <level04_pursuers
    .byte <level05_pursuers, <level06_pursuers, <level07_pursuers, <level08_pursuers, <level09_pursuers
level_pursuers_hi:
    .byte >level00_pursuers, >level01_pursuers, >level02_pursuers, >level03_pursuers, >level04_pursuers
    .byte >level05_pursuers, >level06_pursuers, >level07_pursuers, >level08_pursuers, >level09_pursuers
