    ;---------------------------------------------------------------------------
    ; title.asm: title screen.
    ;---------------------------------------------------------------------------

    .include "vic_colors.inc"

    .import clear_screen
    .import draw_map
    .import draw_glyph
    .import position_sprite
    .importzp src_ptr
    .importzp dt_color
    .importzp str_ptr
    .importzp entity_ptr
    .importzp sprite_index
    .export title_logo
    .export title_screen

    .segment "CODE"

    ;---------------------------------------------------------------------------
    ; title_screen: draw the logo and the credits text underneath it.
    ;---------------------------------------------------------------------------

title_screen:
    JSR clear_screen
    LDA #<title_logo
    STA src_ptr
    LDA #>title_logo
    STA src_ptr + 1
    JSR draw_map

    LDA #<title_text_copyright
    STA str_ptr
    LDA #>title_text_copyright
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #8
    LDY #11
    JSR draw_glyph

    LDA #<title_text_author
    STA str_ptr
    LDA #>title_text_author
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #8
    LDY #13
    JSR draw_glyph

    LDA #<title_text_manettes
    STA str_ptr
    LDA #>title_text_manettes
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #8
    LDY #18
    JSR draw_glyph

    LDA #<title_text_start
    STA str_ptr
    LDA #>title_text_start
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #5
    LDY #23
    JSR draw_glyph

    LDA #<title_text_tapez_ent
    STA str_ptr
    LDA #>title_text_tapez_ent
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #2
    LDY #24
    JSR draw_glyph

    JSR draw_title_pursuers

    RTS

    ;---------------------------------------------------------------------------
    ; draw_title_pursuers: the 8 decorative entities around the logo, sprites 0-7.
    ;---------------------------------------------------------------------------

VIC_SPRITE_COLOR_BASE = $D027

draw_title_pursuers:
    LDX #0
draw_title_pursuers_loop:
    CPX #8
    BCS draw_title_pursuers_done

    TXA
    ASL A                          ; 2 bytes per entry
    TAY
    LDA title_pursuer_positions, Y
    STA title_pursuer_tmp
    LDA title_pursuer_positions + 1, Y
    STA title_pursuer_tmp + 1

    STX sprite_index
    LDA #<title_pursuer_tmp
    STA entity_ptr
    LDA #>title_pursuer_tmp
    STA entity_ptr + 1
    LDX sprite_index
    JSR position_sprite

    LDX sprite_index
    LDA #COLOR_WHITE
    STA VIC_SPRITE_COLOR_BASE, X

    LDX sprite_index
    INX
    JMP draw_title_pursuers_loop
draw_title_pursuers_done:
    RTS

title_pursuer_tmp: .byte 0, 0

    ; (col, row) pairs, tile units — from ANDRDF.BIN's title "level" data,
    ; entities2 table (sprite_id=$02), converted with the confirmed
    ; row=raw_x/2, col=raw_y formula (see project_entity_coordinate_format).
title_pursuer_positions:
    .byte 10, 0
    .byte 30, 0
    .byte 0, 6
    .byte 39, 6
    .byte 0, 14
    .byte 39, 14
    .byte 10, 20
    .byte 30, 20

    ; Strings stored as explicit byte values (ASCII codes)
title_text_copyright:
    .byte $28, $63, $29, $20, $49, $4E, $46, $4F, $47, $52, $41, $4D, $45, $53, $20, $31, $39, $38, $35, 0 ; "(c) INFOGRAMES 1985"
title_text_author:
    .byte $64, $65, $20, $20, $57, $69, $6C, $6C, $69, $61, $6D, $20, $48, $65, $6E, $6E, $65, $62, $6F, $69, $73, 0 ; "de William Hennebois"
title_text_manettes:
    .byte $4D, $41, $4E, $45, $54, $54, $45, $53, $20, $3C, $2D, $20, $2D, $3E, $20, $43, $4C, $41, $56, $49, $45, $52, 0 ; "MANETTES <- -> CLAVIER"
title_text_start:
    .byte $54, $41, $50, $45, $5A, $20, $28, $31, $20, $6F, $75, $20, $32, $29, $20, $50, $4F, $55, $52, $20, $43, $4F, $4D, $4D, $45, $4E, $43, $45, $52, 0 ; "TAPEZ (1 ou 2) POUR COMMENCER"
title_text_tapez_ent:
    .byte $54, $41, $50, $45, $5A, $20, $28, $45, $4E, $54, $29, $20, $50, $4F, $55, $52, $20, $43, $48, $41, $52, $47, $45, $52, $20, $44, $45, $53, $20, $44, $45, $43, $4F, $52, $53, 0 ; "TAPEZ (ENT) POUR CHARGER DES DECORS"

title_logo:
    .byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0
    .byte 2, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0
    .byte 2, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0
    .byte 2, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0
    .byte 2, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
