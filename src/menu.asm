    ;---------------------------------------------------------------------------
    ; menu.asm: port of AUTO.BAT, the original Thomson boot menu.
    ;---------------------------------------------------------------------------

    .include "c64_memory.inc"
    .include "charset_layout.inc"
    .include "vic_colors.inc"

    .import draw_glyph
    .import wait_frames
    .import wait_one_frame
    .importzp dt_color
    .importzp str_ptr
    .import clear_screen
    .import start
    .export menu_screen

    .segment "CODE"

    ;---------------------------------------------------------------------------
    ; menu_screen: port of AUTO.BAT, the original Thomson boot menu.
    ; Only "1" (start the game) is wired up today. 
    ; The level editor ("2") has no C64 port yet.
    ;---------------------------------------------------------------------------

menu_screen:
    LDA #0
    STA cursor_state
    STA cursor_frame_count
    JSR clear_screen

    LDA #<menu_text_android
    STA str_ptr
    LDA #>menu_text_android
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #15
    LDY #11
    JSR draw_glyph

    LDA #<menu_text_editor
    STA str_ptr
    LDA #>menu_text_editor
    STA str_ptr + 1
    LDA #COLOR_WHITE
    STA dt_color
    LDX #15
    LDY #12
    JSR draw_glyph

    LDA #<menu_text_prompt
    STA str_ptr
    LDA #>menu_text_prompt
    STA str_ptr + 1
    LDA #COLOR_GREEN
    STA dt_color
    LDX #12
    LDY #20
    JSR draw_glyph

    ;---------------------------------------------------------------------------
    ; menu_wait_key: matches the original's ON VAL(A$) GOTO 350,370, which
    ; only jumps for "2" (editor). Every other digit falls through to the game.
    ;---------------------------------------------------------------------------

    CURSOR_COL = 26
    CURSOR_ROW = 20
    CURSOR_CHAR = FONT_BASE + ($5F - FONT_FIRST_ASCII)   ; underscore glyph
    CURSOR_BLINK_FRAMES = 15                             ; ~0.25s at 60Hz
    DIGIT_ECHO_FRAMES = 60                               ; ~1.0s at 60Hz

menu_wait_key:
    JSR blink_cursor
    JSR scan_key_digit         ; A = digit 1-9 pressed, or $FF if none
    CMP #$FF
    BEQ menu_wait_key
    PHA                        ; save digit across cursor_off
    JSR cursor_off
    PLA
    PHA                        ; save digit across digit_to_screen_code
    JSR digit_to_screen_code
    STA SCREEN_RAM + (CURSOR_ROW * 40) + CURSOR_COL
    LDA #COLOR_WHITE
    STA COLOR_RAM + (CURSOR_ROW * 40) + CURSOR_COL
    PLA
    PHA                        ; save digit across wait_frames
    LDA #DIGIT_ECHO_FRAMES
    JSR wait_frames            ; let the typed digit be visible for a moment
    PLA
    CMP #2
    BEQ menu_got_2
    JMP start                  ; "1" and "3".."9": fall through to the game

menu_got_2:
    JSR clear_screen
    LDA #<editor_text
    STA str_ptr
    LDA #>editor_text
    STA str_ptr + 1
    LDA #COLOR_YELLOW
    STA dt_color
    LDX #8
    LDY #20
    JSR draw_glyph
    JSR wait_any_key
    JMP menu_screen

    ; Strings stored as explicit byte values (ASCII codes) so that a stray
    ; $00 in the source cannot truncate them by accident.
menu_text_android:
    .byte $31, $2D, $20, $41, $4E, $44, $52, $4F, $49, $44, 0 ; "1 - ANDROID"
menu_text_editor:
    .byte $32, $2D, $20, $45, $44, $49, $54, $45, $55, $52, 0 ; "2 - EDITEUR"
menu_text_prompt:
    .byte $56, $4F, $54, $52, $45, $20, $43, $48, $4F, $49, $58, $20, $3A, 0 ; "VOTRE CHOIX :"
editor_text:
    .byte $45, $44, $49, $54, $45, $55, $52, $20                        ; "EDITEUR "
    .byte $49, $4E, $44, $49, $53, $50, $4F, $4E, $49, $42, $4C, $45, 0 ; "INDISPONIBLE"

    ;---------------------------------------------------------------------------
    ; digit_to_screen_code: convert a digit (1-9, in A) to its font screen
    ; code (digits start right after the punctuation range in the font).
    ;---------------------------------------------------------------------------

digit_to_screen_code:
    CLC
    ADC #FONT_BASE + ($30 - FONT_FIRST_ASCII)
    RTS

    ;---------------------------------------------------------------------------
    ; blink_cursor: toggle the menu cursor glyph on/off every
    ; CURSOR_BLINK_FRAMES frames.
    ;---------------------------------------------------------------------------

blink_cursor:
    JSR wait_one_frame
    INC cursor_frame_count
    LDA cursor_frame_count
    CMP #CURSOR_BLINK_FRAMES
    BCC blink_cursor_done
    LDA #0
    STA cursor_frame_count
    LDA cursor_state
    EOR #1
    STA cursor_state
    BEQ cursor_off
    ; fall through to cursor_on
cursor_on:
    LDA #CURSOR_CHAR
    STA SCREEN_RAM + (CURSOR_ROW * 40) + CURSOR_COL
    LDA #COLOR_WHITE
    STA COLOR_RAM + (CURSOR_ROW * 40) + CURSOR_COL
    RTS
cursor_off:
    LDA #CH_EMPTY
    STA SCREEN_RAM + (CURSOR_ROW * 40) + CURSOR_COL
    LDA #0
    STA cursor_state
blink_cursor_done:
    RTS

cursor_frame_count: .byte 0
cursor_state: .byte 0

    ;---------------------------------------------------------------------------
    ; scan_key_digit: read one key via the KERNAL (GETIN), layout-independent.
    ; Returns the pressed digit (1-9) in A, or $FF if no digit key was typed
    ; (either nothing pending, or a non-digit key was pressed and discarded).
    ;---------------------------------------------------------------------------

PETSCII_DIGIT_0 = $30
PETSCII_DIGIT_9 = $39

scan_key_digit:
    JSR GETIN
    BEQ scan_key_digit_none    ; A=0: no key in the buffer
    CMP #PETSCII_DIGIT_0
    BCC scan_key_digit_none
    CMP #PETSCII_DIGIT_9 + 1
    BCS scan_key_digit_none
    SEC
    SBC #PETSCII_DIGIT_0
    RTS
scan_key_digit_none:
    LDA #$FF
    RTS

wait_any_key:
wait_any_key_press:
    JSR GETIN
    BEQ wait_any_key_press
wait_any_key_release:
    JSR GETIN
    BNE wait_any_key_release
    RTS
