.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

.INCLUDE "macros.inc"
.INCLUDE "constants.inc"

.CODE

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
; Problem code is in x

.proc MoveSprite 

    sta _MoveSprite_a
    sty _MoveSprite_y
    stx _MoveSprite_x

    jsr LoadZeroPageSpriteAddress

    ; Save the previous x and y values, these will be set later 
    ldy #SPRITE_X
    lda (ZP_SPRITE),y
    sta _MoveSprite_prev_x
    ldy #SPRITE_Y
    lda (ZP_SPRITE),y
    sta _MoveSprite_prev_y
    
    ; Jump to the direction
    ldy _MoveSprite_y
    dey
    beq @MoveSprite_up
    dey
    beq @MoveSprite_right
    dey
    beq @MoveSprite_down
    dey
    beq @MoveSprite_left
    jmp @MoveSprite_end

@MoveSprite_up:
    ldy #SPRITE_Y
    lda (ZP_SPRITE),y
    tax
    dex
    bmi @MoveSprite_boundary_hit         ; Branch if Y is at 0 and we try to move up

    save_x
    save_y

    ; Check for character collisions above 
    ldy #SPRITE_X
    lda (ZP_SPRITE),y
    tax
    stx _MoveSprite_x_temp
    ldy #SPRITE_Y
    lda (ZP_SPRITE),y
    tay
    dey
    sty _MoveSprite_y_temp
    jsr CharAt
    cpx #EMPTY_CHAR
    bne @MoveSprite_character_hit
    ldx _MoveSprite_x_temp
    ldy _MoveSprite_y_temp
    inx
    jsr CharAt
    cpx #EMPTY_CHAR
    bne @MoveSprite_character_hit

    load_x 
    load_y

    txa
    sta (ZP_SPRITE),y
    jmp @MoveSprite_end
@MoveSprite_down:
    ldy #SPRITE_Y
    lda (ZP_SPRITE),y
    tax
    inx
    cpx #24                             ; bottom border
    beq @MoveSprite_boundary_hit
    txa
    sta (ZP_SPRITE),y
    jmp @MoveSprite_end
@MoveSprite_left:
    ldy #SPRITE_X
    lda (ZP_SPRITE),y
    tax
    dex
    bmi @MoveSprite_boundary_hit         ; Branch if X is at 0 and we try to move up
    txa
    sta (ZP_SPRITE),y
    jmp @MoveSprite_end
@MoveSprite_right:
    ldy #SPRITE_X
    lda (ZP_SPRITE),y
    tax
    inx
    cpx #39                             ; right border
    beq @MoveSprite_boundary_hit
    txa
    sta (ZP_SPRITE),y
    jmp @MoveSprite_end

@MoveSprite_boundary_hit:
    lda _MoveSprite_a
    ldy _MoveSprite_y
    ldx #MOVE_BOUNDARY_HIT
    sec 
    rts

@MoveSprite_character_hit:
    tay
    lda _MoveSprite_a
    ldy _MoveSprite_y
    ldx #MOVE_CHAR_HIT
    sec 
    rts

@MoveSprite_end:
    ; The move was ok so now we can set the previous 
    ; x and y values correctly. Then exit with OK

    ; Check to see is we have already moved, is so we cannot 
    ; set the previous values 
    ldy #SPRITE_CLEAR_BYTE
    lda (ZP_SPRITE),y
    tay
    dey 
    beq @MoveSprite_exit

    ldy #SPRITE_PREV_X
    lda _MoveSprite_prev_x
    sta (ZP_SPRITE),y
    ldy #SPRITE_PREV_Y
    lda _MoveSprite_prev_y
    sta (ZP_SPRITE),y

    ; We've not previously moved, set the clear flag to 1  
    ldy #SPRITE_CLEAR_BYTE
    lda #$01
    sta (ZP_SPRITE),y 

@MoveSprite_exit:
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
_MoveSprite_x_temp:
    .byte 0
_MoveSprite_y_temp:
    .byte 0
_MoveSprite_prev_x:
    .byte 0
_MoveSprite_prev_y:
    .byte 0
.endproc

; This will clear the sprite off the screen using its old value, a is the sprite number  
.proc ClearPreviousSprite 
    jsr LoadZeroPageSpriteAddress

    sta _ClearSprite_a
    sty _ClearSprite_y
    stx _ClearSprite_x

    ; Check to see if the sprite has moved, if not then just exit 
    ldy #SPRITE_CLEAR_BYTE
    lda (ZP_SPRITE),y
    dey 
    beq @ClearSprite_exit

    ldy #SPRITE_PREV_X
    lda (ZP_SPRITE),y
    tax 
    ldy #SPRITE_PREV_Y
    lda (ZP_SPRITE),y
    tay

    lda #0                          ; this is not the sprite number but the graphic block
    jsr Print4x4Block
    jsr Colour4x4Block

    ; Indicate that the sprite move has been cleared 

    lda #$00
    ldy #SPRITE_CLEAR_BYTE
    sta (ZP_SPRITE),y

@ClearSprite_exit:

    lda _ClearSprite_a 
    ldy _ClearSprite_y
    ldx _ClearSprite_x
    rts

_ClearSprite_a:
    .byte 0
_ClearSprite_x:
    .byte 0
_ClearSprite_y:
    .byte 0
.endproc

; Prints out a sprite, a is the number of the sprite 
.proc PrintSprite

    jsr LoadZeroPageSpriteAddress

    sta _PrintSprite_a
    sty _PrintSprite_y
    stx _PrintSprite_x

    ldy #SPRITE_X
    lda (ZP_SPRITE),y
    tax
    ldy #SPRITE_Y
    lda (ZP_SPRITE),y
    sta _PrintSprite_y_temp
    ldy #SPRITE_GRAPHIC_INDEX
    lda (ZP_SPRITE),y
    ldy _PrintSprite_y_temp
    jsr Print4x4Block
    ldy #SPRITE_COLOUR
    lda (ZP_SPRITE),y
    ldy _PrintSprite_y_temp

    jsr Colour4x4Block

    ldy _PrintSprite_y
    ldx _PrintSprite_x
    lda _PrintSprite_a
    rts

_PrintSprite_y:
    .byte 0
_PrintSprite_x:
    .byte 0
_PrintSprite_a:
    .byte 0
_PrintSprite_y_temp:
    .byte 0
.endproc

; ******************** end of code **********************

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
; ******************** end of data **********************

.EXPORT MoveSprite
.EXPORT PrintSprite
.EXPORT ClearPreviousSprite
.EXPORT sprite_graphic_data