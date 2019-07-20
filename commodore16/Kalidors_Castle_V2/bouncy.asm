.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

;.IMPORT Cls 

.INCLUDE "macros.inc"
.INCLUDE "constants.inc"

.SEGMENT "STARTUP"
    jsr Cls    
    lda #0
loop:
    jsr ClearPreviousSprite
    jsr PrintSprite
    ldx #$20
    jsr Delay
    ldy x_direction
    jsr MoveSprite
    bcc continue1

    ; Horizontal collision 
    cpy #LEFT
    beq set_right
    ldy #LEFT
    sty x_direction
    jmp continue1
set_right:
    ldy #RIGHT
    sty x_direction
    jmp continue1

continue1:
    ldy y_direction
    jsr MoveSprite
    bcc continue2

; Vertical collision 
    cpy #UP
    beq set_down
    ldy #UP
    sty y_direction
    jmp continue2
set_down:
    ldy #DOWN
    sty y_direction
    jmp continue2

continue2:
    m_Key_Pressed #$7F,#$80,end_program
    jmp loop
end_program:
    rts
end:
    rts 

x_direction:
    .byte LEFT 
y_direction:
    .byte UP


; ******************** end of code **********************

