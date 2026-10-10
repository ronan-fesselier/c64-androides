    ;---------------------------------------------------------------------------
    ; map.asm: level map rendering.
    ;---------------------------------------------------------------------------

    .include "c64_memory.inc"
    .include "charset_layout.inc"
    .include "vic_colors.inc"

    .export clear_screen
    .export draw_map
    .export src_ptr
    .export current_level_index

    .segment "CODE"

    MAP_WIDTH = 40
    MAP_HEIGHT = 22

    src_ptr = $07             ; 2 bytes ($07/$08)
    dst_ptr = $09             ; 2 bytes ($09/$0A)
    col_ptr = $05             ; 2 bytes ($05/$06)

    ;---------------------------------------------------------------------------
    ; clear_screen: fill SCREEN_RAM with CH_EMPTY and COLOR_RAM with COLOR_BLACK.
    ;---------------------------------------------------------------------------

clear_screen:
    LDX #0
clear_loop:
    LDA #CH_EMPTY
    STA SCREEN_RAM, X
    STA SCREEN_RAM + $100, X
    STA SCREEN_RAM + $200, X
    STA SCREEN_RAM + $2E8, X
    LDA #COLOR_BLACK
    STA COLOR_RAM, X
    STA COLOR_RAM + $100, X
    STA COLOR_RAM + $200, X
    STA COLOR_RAM + $2E8, X
    INX
    BNE clear_loop
    RTS

    ;---------------------------------------------------------------------------
    ; draw_map: blit a 40x22 = 880 screen-code map (src_ptr, set by the
    ; caller) into screen memory AND color RAM (per-tile color via
    ; tile_colors table, indexed by (tile_code * 8) | (level AND 7),
    ; using 16-bit zero-page pointers since 880 > 256.
    ;---------------------------------------------------------------------------

    MAP_LEN = MAP_WIDTH * MAP_HEIGHT

draw_map:
    LDA current_level_index
    AND #$07
    STA level_index

    LDA #0
    STA copied_hi
    LDA #<SCREEN_RAM
    STA dst_ptr
    LDA #>SCREEN_RAM
    STA dst_ptr + 1
    LDA #<COLOR_RAM
    STA col_ptr
    LDA #>COLOR_RAM
    STA col_ptr + 1

    LDA #0
    STA dm_count
    LDY #0                    ; index within current 256-byte page
draw_map_loop:
    LDA (src_ptr), Y          ; A = tile code (0-3)
    STA (dst_ptr), Y          ; write screen code
    ASL A
    ASL A
    ASL A                     ; A = tile_code * 8
    ORA level_index           ; A = (tile_code * 8) | (level & 7)
    TAX
    LDA tile_colors, X
    STA (col_ptr), Y          ; write matching color

    INY
    BNE draw_map_skip_inc
    INC src_ptr + 1
    INC dst_ptr + 1
    INC col_ptr + 1
draw_map_skip_inc:
    INC dm_count
    LDX dm_count
    CPX #<MAP_LEN
    BNE draw_map_loop
    LDA copied_hi
    CMP #>MAP_LEN
    BEQ draw_map_done
    INC copied_hi
    JMP draw_map_loop
draw_map_done:
    RTS

current_level_index: .byte 0
copied_hi:           .byte 0
dm_count:            .byte 0
level_index:         .byte 0

tile_colors:
    ; tile 0 = empty
    .byte COLOR_BLACK, COLOR_BLACK,  COLOR_BLACK, COLOR_BLACK
    .byte COLOR_BLACK, COLOR_BLACK,  COLOR_BLACK, COLOR_BLACK
    ; tile 1 = brick
    .byte COLOR_BLUE,  COLOR_YELLOW, COLOR_RED,   COLOR_GREEN
    .byte COLOR_CYAN,  COLOR_PURPLE, COLOR_RED,   COLOR_GREEN
    ; tile 2 = ladder
    .byte COLOR_WHITE, COLOR_WHITE,  COLOR_WHITE, COLOR_WHITE
    .byte COLOR_WHITE, COLOR_WHITE,  COLOR_WHITE, COLOR_WHITE
    ; tile 3 = cable
    .byte COLOR_WHITE, COLOR_WHITE,  COLOR_WHITE, COLOR_WHITE
    .byte COLOR_WHITE, COLOR_WHITE,  COLOR_WHITE, COLOR_WHITE
