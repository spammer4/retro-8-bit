; Save x in the ZP_X_TEMP
.macro save_x 
    stx ZP_X_TEMP
.endmacro

; Pull x from ZP_X_TEMP
.macro load_x
    ldx ZP_X_TEMP
.endmacro

; Save Y in the ZP_y_TEMP
.macro save_y 
    stY ZP_Y_TEMP
.endmacro

; Pull y from ZP_Y_TEMP
.macro load_y
    ldy ZP_Y_TEMP
.endmacro

; Loads a row value into ZP register, y register is the row to load 
.macro m_Load_Row_Value_Into_ZP table,ZP
    .scope 
        m_Save_Regs
        lda mult2_lookup,y 
        tay
        lda table, y
        sta ZP
        iny
        lda table, y
        sta ZP + 1
        m_Restore_Regs
    .endscope 
.endmacro

; Generate screen lookup table 
.macro m_Gen_Screen_Lookup_Table base
    .scope
        line_length := 40
        .repeat 26, I
            .word base+(line_length * I)
        .endrep
    .endscope
.endmacro

; Generates a multiplication lookup table 
.macro m_Gen_Mult_Lookup_Table table
    .scope
        .repeat 26, I
            .byte I * table
        .endrep
    .endscope
.endmacro

; Save all the regs to stack
.macro m_Save_Regs 
    pha
    txa
    pha
    tya
    pha
.endmacro

; Restore all the regs from stack
.macro m_Restore_Regs
    pla
    tay
    pla
    tax
    pla
.endmacro

; Keyboard macro m = matrix, k = key and b is branch name if pressed 
.macro m_Key_Pressed m,k,b
    lda m
    sta $FD30	 
    sta $FF08	 
    lda $FF08	 
    and k	 
    beq b
.endmacro

; Keyboard macro m = matrix, k = key and j is routine if pressed 
.macro m_Key_Pressed_JSR m,k,j
.scope 
        m_Key_Pressed m,k,pressed
        jmp end
    pressed:
        jsr j
    end:
.endscope 
.endmacro