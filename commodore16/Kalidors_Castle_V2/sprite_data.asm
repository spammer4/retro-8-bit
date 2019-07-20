.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

.INCLUDE "macros.inc"

.DATA
    sprites:
        .byte 2             ; graphic index 
        .byte 5             ; x
        .byte 5             ; y
        .byte 5             ; prev x 
        .byte 5             ; prev y 
        .byte 3             ; colour
        .byte 0             ; clear byte

    mult_sprite_lookup:
        m_Gen_Mult_Lookup_Table 6
    sprite_graphic_data:
        .byte 32                    ; Blank sprite, black colour 
        .byte 32                    ; Blank sprite, black colour
        .byte 32                    ; Blank sprite, black colour
        .byte 32                    ; Blank sprite, black colour

        .byte 1
        .byte 2
        .byte 3
        .byte 4

        .byte 4
        .byte 3
        .byte 2
        .byte 1

        .byte 26
        .byte 25
        .byte 26
        .byte 25

.EXPORT sprite_graphic_data, mult_sprite_lookup, sprites