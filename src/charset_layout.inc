    ;---------------------------------------------------------------------------
    ; charset_layout.inc: screen-code layout of charset.asm.
    ;---------------------------------------------------------------------------

; Screen codes 0-3: terrain tiles
CH_EMPTY  = 0
CH_BRICK  = 1
CH_LADDER = 2
CH_CABLE  = 3
CH_CRATE  = 4

; Screen codes 5-95: text font (ASCII $20-$7A, space through lowercase z)
FONT_BASE = 5
FONT_FIRST_ASCII = $20
