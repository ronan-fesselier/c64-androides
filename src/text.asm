    ;---------------------------------------------------------------------------
    ; text.asm: text rendering (ported font) and VIC frame timing.
    ;---------------------------------------------------------------------------

    .include "c64_memory.inc"
    .include "charset_layout.inc"
    .include "vic_colors.inc"

    .export draw_glyph
    .export wait_one_frame
    .export wait_frames
    .export dt_color
    .export str_ptr

    .segment "CODE"

    VIC_RASTER = $D012

    ; Zero-page pointers live at $02-$0A rather than the more common
    ; $FB-$FE: that range is used by BASIC/KERNAL helper routines and
    ; IRQs, which can corrupt our data mid-blit. $02-$0A is safe here
    ; since no BASIC is running once init has handed off to us.
    dt_color = $02            ; 1 byte
    str_ptr  = $03            ; 2 bytes ($03/$04)
    col_ptr  = $05            ; 2 bytes ($05/$06)
    dst_ptr  = $09            ; 2 bytes ($09/$0A)

    ;---------------------------------------------------------------------------
    ; draw_glyph: draw a 0-terminated ASCII string (str_ptr) at column X,
    ; row Y, using the ported font (FONT_BASE..FONT_BASE+63 screen codes).
    ; Color: dt_color (set by the caller), matching the original's COLORn
    ; statement before each PRINT.
    ;---------------------------------------------------------------------------

draw_glyph:
    ; dst_ptr = SCREEN_RAM + Y*40 + X ; col_ptr = COLOR_RAM + Y*40 + X
    LDA dt_screen_lo_table, Y
    STA dst_ptr
    LDA dt_screen_hi_table, Y
    STA dst_ptr + 1
    LDA dt_color_lo_table, Y
    STA col_ptr
    LDA dt_color_hi_table, Y
    STA col_ptr + 1
    TXA
    CLC
    ADC dst_ptr
    STA dst_ptr
    BCC draw_glyph_col_ok
    INC dst_ptr + 1
draw_glyph_col_ok:
    TXA
    CLC
    ADC col_ptr
    STA col_ptr
    BCC draw_glyph_loop
    INC col_ptr + 1

draw_glyph_loop:
    LDY #0
    LDA (str_ptr), Y
    BEQ draw_glyph_done
    SEC
    SBC #FONT_FIRST_ASCII
    CLC
    ADC #FONT_BASE
    STA (dst_ptr), Y
    LDA dt_color
    STA (col_ptr), Y
    INC str_ptr
    BNE draw_glyph_skip_inc
    INC str_ptr + 1
draw_glyph_skip_inc:
    INC dst_ptr
    BNE draw_glyph_skip_inc2
    INC dst_ptr + 1
draw_glyph_skip_inc2:
    INC col_ptr
    BNE draw_glyph_loop
    INC col_ptr + 1
    JMP draw_glyph_loop

draw_glyph_done:
    RTS

    ; Precomputed SCREEN_RAM/COLOR_RAM row offsets (row*40), rows 0-24.
dt_screen_lo_table:
    .repeat 25, I
    .byte <(SCREEN_RAM + (I * 40))
    .endrepeat
dt_screen_hi_table:
    .repeat 25, I
    .byte >(SCREEN_RAM + (I * 40))
    .endrepeat
dt_color_lo_table:
    .repeat 25, I
    .byte <(COLOR_RAM + (I * 40))
    .endrepeat
dt_color_hi_table:
    .repeat 25, I
    .byte >(COLOR_RAM + (I * 40))
    .endrepeat

    ;---------------------------------------------------------------------------
    ; wait_one_frame: block until one full VIC frame has passed.
    ;---------------------------------------------------------------------------

wait_one_frame:
wait_frame_start:
    LDA VIC_RASTER
    BNE wait_frame_start      ; wait until raster reaches line 0
wait_frame_end:
    LDA VIC_RASTER
    BEQ wait_frame_end        ; wait until it leaves line 0 (one frame passed)
    RTS

    ;---------------------------------------------------------------------------
    ; wait_frames: block for A frames.
    ;---------------------------------------------------------------------------

wait_frames:
    STA wait_frames_count
wait_frames_loop:
    JSR wait_one_frame
    DEC wait_frames_count
    BNE wait_frames_loop
    RTS

wait_frames_count: .byte 0
