    ;---------------------------------------------------------------------------
    ; c64_memory.inc: C64 memory map / KERNAL addresses used across modules.
    ;---------------------------------------------------------------------------

SCREEN_RAM = $0400        ; 1000 bytes: $0400-$07E7
COLOR_RAM  = $D800        ; 1000 bytes: $D800-$DBE7, mirrors screen layout

GETIN = $FFE4             ; KERNAL: read one key, A=0 if none pending
