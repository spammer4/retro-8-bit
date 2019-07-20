.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

.INCLUDE "macros.inc"
.INCLUDE "constants.inc"

.CODE

; Clears the screen 
.proc Cls
    m_Save_Regs

    ldy #00
    lda #32
_Cls_next_row:
    m_Load_Row_Value_Into_ZP screen_y_lookup,ZP_SCREEN
    sty _Cls_y_temp
    ldx #00
    ldy #00
_Cls_next_col:
    sta (ZP_SCREEN),y
    iny
    cpy #40
    bne _Cls_next_col
    ldy _Cls_y_temp
    iny  
    cpy #25
    bne _Cls_next_row

    m_Restore_Regs
    rts
_Cls_y_temp:
    .byte 0
.endproc

; Load X up with a value and it will count down until zero, x is restored at the end. 
.proc Delay 
                        stx Delay_x
                        sty Delay_y
                        ldy #$FF
            Delay_loop_y:
                        dey
                        bne Delay_loop_y
                        ldy #$FF
                        dex 
                        bne Delay_loop_y
                        ldx Delay_x
                        ldy Delay_y
                        rts
Delay_x: 
    .byte 0
Delay_y:
    .byte 0
.endproc


; Colours a 4 by 4 block, x = x, y = y and a is the colour
.proc Colour4x4Block
    .scope 
        ; Save the registers
        sty _colour_4by4_y
        sta _colour_4by4_a
        stx _colour_4by4_x

        m_Load_Row_Value_Into_ZP colour_y_lookup,ZP_SCREEN
        
        ldy _colour_4by4_x
        sta (ZP_SCREEN),y                 
        iny
        sta (ZP_SCREEN),y                 
        tya
        clc
        adc #39
        tay
        lda _colour_4by4_a
        sta (ZP_SCREEN),y                 
        iny
        sta (ZP_SCREEN),y                         

        ; Restore the regs
        ldy _colour_4by4_y
        lda _colour_4by4_a
        ldx _colour_4by4_x
        rts 
    _colour_4by4_y:
            .byte 0
    _colour_4by4_a:
            .byte 0
    _colour_4by4_x:
            .byte 0
    .endscope 
.endproc

; Returns in x the character at x and y 
.proc CharAt

    sta _CharAt_a
    sty _CharAt_y

    m_Load_Row_Value_Into_ZP screen_y_lookup,ZP_SCREEN
    txa
    tay
    lda (ZP_SCREEN),y
    tax
    ldy _CharAt_y
    lda _CharAt_a

    rts 
_CharAt_a: 
    .byte 0
_CharAt_y: 
    .byte 0
.endproc 

; Prints a 4 by 4 block, x = x, y = y and a is the sprite number 
.proc Print4x4Block
    ; Save the registers
    sty _4by4_y
    stx _4by4_x
    sta _4by4_a

    m_Load_Row_Value_Into_ZP screen_y_lookup,ZP_SCREEN

    ; Get the starting location of the sprite data  
    tay
    lda mult4_lookup,y
    tax
    lda sprite_graphic_data,x
    ldy _4by4_x
    sta (ZP_SCREEN),y             
    inx
    iny
    lda sprite_graphic_data,x
    sta (ZP_SCREEN),y                 
    tya
    clc
    adc #39
    tay
    inx 
    lda sprite_graphic_data,x
    sta (ZP_SCREEN),y                 
    iny
    inx
    lda sprite_graphic_data,x
    sta (ZP_SCREEN),y                         
    
    ; Restore the regs
    ldy _4by4_y
    ldx _4by4_x
    lda _4by4_a

    rts 
_4by4_y:
        .byte 0
_4by4_a:
        .byte 0
_4by4_x:
        .byte 0
_4by4_c:
        .byte 0
.endproc            ; Print4x4Block

.EXPORT Cls
.EXPORT Delay
.EXPORT Print4x4Block
.EXPORT Colour4x4Block
.EXPORT CharAt