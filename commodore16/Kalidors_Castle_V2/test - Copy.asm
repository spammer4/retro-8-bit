
.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

; Structs 

.struct _4by4_sprite_graphic
    top_left        .byte
    top_right       .byte
    bottom_right    .byte
    bottom_left     .byte
    colour          .byte
.endstruct 

; ******************** end of structs **********************

; Constants 
ZP_SCREEN = $10
ZP_SPRITE = $12
UP = $0
RIGHT = $1
DOWN = $2
LEFT = $3 
MOVE_OK = $0
SPRITE_GRAPHIC_INDEX = $0
SPRITE_X = $1
SPRITE_Y = $2 
SPRITE_PREV_X = $3
SPRITE_PREV_Y = $4

; ******************** end of constants **********************

; Macros 
.macro _screen_lookup_table
    line_length := 40
    base = $0C00
    .repeat 26, I
        .word base+(line_length * I)
    .endrep
.endmacro

.macro _colour_lookup_table
    colour_line_length := 40
    colour_base = $0800
    .repeat 26, I
        .word colour_base+(colour_line_length * I)
    .endrep
.endmacro

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
        .byte I * 5
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

; Save all the regs to stack
.macro _save_regs 
    pha
    txa
    pha
    tya
    pha
.endmacro

; Restore all the regs from stack
.macro _restore_regs
    pla
    tay
    pla
    tax
    pla
.endmacro

; Loads in a screen row into ZP_SCREEN
.macro _load_screen_row 
        _save_regs
        _load_multiplyX_address 2 
        tay
        lda screen_y_lookup, y
        sta ZP_SCREEN
        iny
        lda screen_y_lookup, y
        sta ZP_SCREEN + 1
        _restore_regs
.endmacro

.macro _load_colour_row 
        _save_regs
        _load_multiplyX_address 2 
        tay
        lda colour_y_lookup, y
        sta ZP_SCREEN
        iny
        lda colour_y_lookup, y
        sta ZP_SCREEN + 1
        _restore_regs
.endmacro

; ******************** end of macros **********************

.CODE
    jsr Cls

    ldy #10              ; y pos
    ldx #10              ; x pos
    lda #1              ; a sprite 

 ;   lda #0
 ;   jsr PrintSprite
 ;   jsr PrintSprite
    ;ldy UP
    ;jsr MoveSprite
    ;jsr PrintSprite
    ; jsr LoadZeroPageSpriteAddress
    ;lda #0
    
    jsr Print4x4Block
    jsr Print4x4Block
    rts 

; Clears the screen 
.proc Cls
    _save_regs

    ldy #00
    lda #32
_Cls_next_row:
    _load_screen_row
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

    _restore_regs
    rts
_Cls_y_temp:
    .byte 0
.endproc

; Loads the zero page sprite address into the ZP_SPRITE address.
; a = sprite number 
.proc LoadZeroPageSpriteAddress
    sta _LoadZeroPageSpriteAddress_a
    sty _LoadZeroPageSpriteAddress_y

    ; Get the sprite multiple and store it 
    tay 
    lda mult_sprite_lookup, y
    sta _LoadZeroPageSpriteAddress_lookup

    ; Now get the address of the sprite data and 
    ; add the offset to it, store it in the ZP_SPRITE
    ; zero page  
    lda #>sprites
    sta ZP_SPRITE+1
    lda #<sprites
    clc
    adc _LoadZeroPageSpriteAddress_lookup
    bcc @LoadZeroPage_no_overflow
    inc ZP_SPRITE+1 
@LoadZeroPage_no_overflow:
    sta ZP_SPRITE

    lda _LoadZeroPageSpriteAddress_a
    ldy _LoadZeroPageSpriteAddress_y
    rts

_LoadZeroPageSpriteAddress_y:
    .byte 0
_LoadZeroPageSpriteAddress_a:
    .byte 0 
_LoadZeroPageSpriteAddress_lookup:
    .byte 0
.endproc 

; Moves a sprite in a given direction, a = sprite, y = direction 
; Returns carry clear if move is OK 
;
.proc MoveSprite 

    jsr LoadZeroPageSpriteAddress

    sta _MoveSprite_a
    sty _MoveSprite_y
    stx _MoveSprite_x

    ; Save the previous x and y values
    ldy SPRITE_X
    lda (ZP_SPRITE),y
    sta _MoveSprite_prev_x
    ldy SPRITE_Y
    lda (ZP_SPRITE),y
    sta _MoveSprite_prev_y

    ; Jump to the direction
    ldy _MoveSprite_y
    cpy RIGHT
    beq @MoveSprite_right
    cpy LEFT
    beq @MoveSprite_left
    cpy DOWN
    beq @MoveSprite_down
    cpy UP
    beq @MoveSprite_up
    jmp @MoveSprite_end

@MoveSprite_up:
    ldy SPRITE_Y
    lda (ZP_SPRITE),y
    sbc #1
    sta (ZP_SPRITE),y
    jmp @MoveSprite_end
@MoveSprite_down:
    jmp @MoveSprite_end
@MoveSprite_left:
    jmp @MoveSprite_end
@MoveSprite_right:
    jmp @MoveSprite_end

@MoveSprite_end:
    ; The move was ok so now we can set the previous 
    ; x and y values correctly. Then exit with OK

    ldy SPRITE_PREV_X
    lda _MoveSprite_prev_x
    sta (ZP_SPRITE),y
    ldy SPRITE_PREV_Y
    lda _MoveSprite_prev_y
    sta (ZP_SPRITE),y
    ldy _MoveSprite_y
    lda _MoveSprite_a
    clc
    rts

_MoveSprite_a:
    .byte 0 
_MoveSprite_y:
    .byte 0
_MoveSprite_x:
    .byte 0
_MoveSprite_prev_x:
    .byte 0
_MoveSprite_prev_y:
    .byte 0
.endproc

; Prints out a sprite, a is the number of the sprite 
.proc PrintSprite
    sta _PrintSprite_a
    sty _PrintSprite_y
    stx _PrintSprite_x

    tay
    lda mult_sprite_lookup, y
    tay
    lda sprites, y
    pha                         ; sprite data for later  
    iny 
    lda sprites, y
    tax
    iny
    lda sprites, y
    tay
    pla
    jsr Print4x4Block
    
    lda _PrintSprite_a
    ldy _PrintSprite_y
    ldx _PrintSprite_x
    rts
_PrintSprite_y:
    .byte 0
_PrintSprite_x:
    .byte 0
_PrintSprite_a:
    .byte 0
.endproc

; Prints a 4 by 4 block, x = x, y = y and a is the colour
.proc Print4x4Colour

    ; Save the registers
    sty _colour_4by4_y
    sta _colour_4by4_a
    stx _colour_4by4_x

    _load_colour_row
    
    ldy _colour_4by4_x
    sta (ZP_SCREEN),y                 
    iny
    sta (ZP_SCREEN),y                 
    tya
    adc #38
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

.endproc

; Prints a 4 by 4 block, x = x, y = y and a is the sprite number 
.proc Print4x4Block

    ; Save the registers
    sty _4by4_y
    stx _4by4_x
    sta _4by4_a

    _load_screen_row
    
    ; Get the starting location of the sprite data and store the colour 
    tay
    lda mult_sprite_lookup,y

    tax
    lda sprite_graphic_data,x
    ldy _4by4_x
    sta (ZP_SCREEN),y                 
    inx
    iny
    lda sprite_graphic_data,x
    sta (ZP_SCREEN),y                 
    tya
    adc #38
    tay
    inx 
    lda sprite_graphic_data,x
    sta (ZP_SCREEN),y                 
    iny
    inx
    lda sprite_graphic_data,x
    sta (ZP_SCREEN),y                         
    
    ; Get the colour from the sprite 
    inx
    lda sprite_graphic_data,x
    sta _4by4_c

    ldy _4by4_y
    _load_colour_row
    
    lda _4by4_c
    sta (ZP_SCREEN),y                 
    iny
    sta (ZP_SCREEN),y                 
    tya
    adc #39
    tay
    lda _4by4_c
    sta (ZP_SCREEN),y                 
    iny
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

; ******************** end of code **********************

.DATA
    sprites:
        .byte 2             ; graphic index 
        .byte 5             ; x
        .byte 5             ; y
        .byte 0             ; prev x 
        .byte 0             ; prev y 

    mult2_lookup: 
        _multiple_by_2_lookup_table
    mult4_lookup: 
        _multiple_by_4_lookup_table
    mult_sprite_lookup:
        _multiple_by_sprite_lookup_table
    screen_y_lookup:
        _screen_lookup_table
    colour_y_lookup:
        _colour_lookup_table
    sprite_graphic_data:
        .byte 32                    ; Blank sprite, black colour 
        .byte 32                    ; Blank sprite, black colour
        .byte 32                    ; Blank sprite, black colour
        .byte 32                    ; Blank sprite, black colour
        .byte 0                     ; Blank sprite, black colour

        .byte 1
        .byte 2
        .byte 3
        .byte 4
        .byte 7

        .byte 4
        .byte 3
        .byte 2
        .byte 1
        .byte 17
; ******************** end of data **********************
