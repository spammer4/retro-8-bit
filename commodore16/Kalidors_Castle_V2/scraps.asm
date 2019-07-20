; Prints a character at x, y. Character in a
.proc PrintChar
        ldy y_pos
        lda mult2_lookup,y 
        tay
        lda screen_y_lookup, y
        sta ZP_SCREEN
        iny
        lda screen_y_lookup, y
        sta ZP_SCREEN + 1
        ldy x_pos
        lda chr
        sta (ZP_SCREEN),y                 ; Indirect addressing 
        rts
_PrintChar_x:
        .byte 0
_PrintChar_y:
        .byte 0
_PrintChar_a: 
        .byte 0
.endproc 

    y_temp: 
        .byte 0
    x_temp:
        .byte 0
    a_temp:
        .byte 0
    x_pos: 
        .byte 10
    y_pos:
        .byte 10
    chr:
        .byte 0
    sprite:
        .byte 0

; Structs 

.struct _4by4_sprite_graphic
    top_left        .byte
    top_right       .byte
    bottom_right    .byte
    bottom_left     .byte
    colour          .byte
.endstruct 

.macro _multiple_by_2_lookup_table
    .repeat 26, I
        .byte I * 2
    .endrep
.endmacro

.macro _multiple_by_4_lookup_table
    .repeat 26, I
        .byte I * 4
    .endrep
.endmacro

.macro _multiple_by_sprite_lookup_table
    .repeat 26, I
        .byte I * 6
    .endrep
.endmacro

; Loads a multiple of X into A 
.macro _load_multiplyX_address multiple  
        .if multiple=2
            lda mult2_lookup,y 
        .endif
        .if multiple=4
            lda mult4_lookup,y 
        .endif
.endmacro

; Loads in a screen row into ZP_SCREEN
.macro _load_screen_row 
        m_Save_Regs
        lda mult2_lookup,y 
        tay
        lda screen_y_lookup, y
        sta ZP_SCREEN
        iny
        lda screen_y_lookup, y
        sta ZP_SCREEN + 1
        m_Restore_Regs
.endmacro

.macro _load_colour_row 
        m_Save_Regs
        lda mult2_lookup,y  
        tay
        lda colour_y_lookup, y
        sta ZP_SCREEN
        iny
        lda colour_y_lookup, y
        sta ZP_SCREEN + 1
        m_Restore_Regs
.endmacro
