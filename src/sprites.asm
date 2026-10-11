    ;---------------------------------------------------------------------------
    ; sprites.asm: hero/pursuer sprite data.
    ; Share this same bitmap, differing only by sprite color ($D027-$D02E).
    ;---------------------------------------------------------------------------

    .export sprites

    .segment "SPRITES"

sprites:
    ; idle
    .byte $00, $00, $00
    .byte $10, $00, $00
    .byte $38, $00, $00
    .byte $54, $00, $00
    .byte $38, $00, $00
    .byte $10, $00, $00
    .byte $10, $00, $00
    .byte $10, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
    .byte $00, $00, $00
