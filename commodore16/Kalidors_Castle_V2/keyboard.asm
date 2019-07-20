.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

.INCLUDE "macros.inc"

.CODE
loop:
    m_Key_Pressed_JSR #$7F,#$10,at
    m_Key_Pressed #$7F,#$80,end_program
    jmp loop
at:
    lda #$00
    sta $0C00
end_program:
    rts
