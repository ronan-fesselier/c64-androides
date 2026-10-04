    ;---------------------------------------------------------------------------
    ; engine.asm: minimal boot stub (clear screen, print a title string).
    ;---------------------------------------------------------------------------

    ; Load address for PRG ($0801 = start of BASIC)
    .segment "LOADADDR"
    .word $0801

    .segment "CODE"

    ; BASIC stub: "10 SYS 2061" -> jumps to machine code
    .byte $0B, $08, $0A, $00, $9E
    .byte "2061"
    .byte $00, $00, $00

    BORDER_COLOR = $D020      ; VIC-II border color register
    BG_COLOR = $D021          ; VIC-II background color register

    COLOR_BLACK = $00
    COLOR_WHITE = $01

    SCREEN_RAM = $0400        ; 1000 bytes: $0400-$07E7
    COLOR_RAM = $D800         ; 1000 bytes: $D800-$DBE7, mirrors screen layout

    CH_SPACE = $20            ; screen code for a blank space (ROM charset)

start:
    LDA #COLOR_BLACK
    STA BORDER_COLOR
    STA BG_COLOR

clear_screen:
    LDA #CH_SPACE
    LDX #0

clear_loop:
    STA SCREEN_RAM, X
    STA SCREEN_RAM + $100, X
    STA SCREEN_RAM + $200, X
    STA SCREEN_RAM + $2E8, X
    LDA #COLOR_WHITE
    STA COLOR_RAM, X
    STA COLOR_RAM + $100, X
    STA COLOR_RAM + $200, X
    STA COLOR_RAM + $2E8, X
    LDA #CH_SPACE
    INX
    BNE clear_loop

    JSR print_title

halt:
    JMP *

    ;---------------------------------------------------------------------------
    ; print_title : blit title_text (already screen codes) to row 12.
    ;---------------------------------------------------------------------------

    TITLE_ROW = 12
    TITLE_COL = 13

print_title:
    LDX #0
print_title_loop:
    LDA title_text, X
    BEQ print_title_done
    STA SCREEN_RAM + TITLE_ROW * 40 + TITLE_COL, X
    INX
    BNE print_title_loop
print_title_done:
    RTS

    ; screen codes: digits = $30-$39, space = $20,
    ; uppercase A-Z = $01-$1A in the default ROM charset.
title_text:
    .byte $03, $36, $34                               ; C64
    .byte $20                                         ; space
    .byte $01, $0E, $04, $12, $0F, $09, $04, $05, $13 ; ANDROIDES
    .byte $00                                         ; terminator
