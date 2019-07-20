
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

UP = $1
RIGHT = $2
DOWN = $3
LEFT = $4 

MOVE_OK = $0
SPRITE_GRAPHIC_INDEX = $0
SPRITE_X = $1
SPRITE_Y = $2 
SPRITE_PREV_X = $3
SPRITE_PREV_Y = $4
SPRITE_COLOUR = $5

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

.macro _set_raster_handler new_handler  
    pha 
    lda $0314
    sta previous_raster_handler 
    lda $0315 
    sta previous_raster_handler + 1 
    sei
    lda #<@handler
    sta $0314
    lda #>@handler
    sta $0315
    lda $FF0A       
    ora $02 
    lda #$CC
    sta $FF0B
    pla
    cli
    rts
@handler:
    jsr new_handler 
    pla
    tay
    pla
    tax
    pla
    rti
.endmacro

; ******************** end of macros **********************

.CODE
    jsr Cls
    _set_raster_handler new_handler 
    rts
    jsr Cls
    rts
    lda $0314 
    ldx $0315 
    sta previous_raster_handler 
    stx previous + 1 
    sei
    lda #<handler
    sta $0314
    lda #>handler
    sta $0315
    cli
    rts
handler:
    lda #$00
    sta $0C00
    jmp (previous)
    
previous:
    .byte 0
    .byte 0

.proc new_handler
    lda #$00
    sta $0C00
    rts
.endproc

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

; ******************** end of code **********************

.DATA
    previous_raster_handler: 
        .word 0
    sprites:
        .byte 2             ; graphic index 
        .byte 5             ; x
        .byte 6             ; y
        .byte 0             ; prev x 
        .byte 0             ; prev y 
        .byte 3             ; colour

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
