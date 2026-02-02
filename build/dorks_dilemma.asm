;===============================================================================
; DORKS DILEMMA - C16/Plus4 Version
; Consolidated Source for ca65 Assembler
;
; Original game by Anthony Clarke (1980s)
; Recovered and reconstructed from C16 floppy disk sources
; Missing code restored from C64 version with TED chip adaptations
;
; Target: Commodore C16/Plus4 (TED chip)
; Assembler: ca65 (cc65 suite)
;
; Load: LOAD"dorks_dilemma.prg",8,1
; Run:  SYS 6496
;
; Controls:
;   Z = Left
;   X = Right
;   K = Up
;   N = Down
;   SPACE = Fire / Start game
;===============================================================================

.setcpu "6502"
.feature labels_without_colons

;===============================================================================
; HARDWARE EQUATES - TED Chip (C16/Plus4)
;===============================================================================

TED     = $FF00

IRQREG  = TED+9             ; IRQ status register
IRQMSK  = TED+10            ; IRQ mask register
RASCOM  = TED+11            ; Raster compare register
RASTHI  = TED+$1C           ; Raster high bit

BORDER  = TED+$19           ; Border color
BACKGR  = TED+$15           ; Background color

JPORT   = TED+8             ; Joystick port

MULTI1  = TED+$16           ; Multicolor 1
MULTI2  = TED+$17           ; Multicolor 2

; Sound registers (TED has 2 channels)
SOU1LO  = TED+14            ; Sound 1 low
SOU2LO  = TED+15            ; Sound 2 low
SOU1HI  = TED+18            ; Sound 1 high
SOU2HI  = TED+16            ; Sound 2 high

VOL     = TED+17            ; Volume control

; Memory locations
SCRBUF  = $0400             ; Buffer (screen size) 0400-07BF
; SCDATA is now a label pointing to included binary data (see end of file)

; Sound flag (for optional sound)
SNDFLG  = $01               ; Sound on/off flag location

;===============================================================================
; ZERO PAGE VARIABLE EQUATES
; Original game uses $02-$FF for zero page variables
;===============================================================================

MESL    = $02               ; Message pointer (2 bytes)
MESSX   = $04               ; Message pixel position

LIVES   = $05               ; Number of lives
XTRA    = $06               ; Extra life compare

JLEFT   = $07               ; Joystick left
JRIGHT  = $08               ; Joystick right
JUP     = $09               ; Joystick up
JDOWN   = $0A               ; Joystick down
JFIRE   = $0B               ; Joystick fire
JMOVE   = $0C               ; Moved flag

INTYPE  = $0D               ; IRQ number

RND     = $0E               ; Random number (4 bytes)

TRYOTH  = $12               ; Try other direction

SL      = $13               ; Screen pointer (2 bytes)
AL      = $15               ; Alien screen pointer (2 bytes)
WORK    = $17               ; Work pointer (4 bytes)
XCOUNT  = $1B               ; X for decoder
YCOUNT  = $1C               ; Y for decoder
SCREEN  = $1D               ; Screen number 0-24

XPOS    = $1E               ; X position in maze
YPOS    = $1F               ; Y position in maze

TEMP    = $20               ; Door temp

MANX    = $21               ; Man X position
TRX     = $22               ; Man temp X position
SAVEX   = $23               ; Saved X position
MANY    = $24               ; Man Y position
TRY     = $25               ; Man temp Y position
SAVEY   = $26               ; Saved Y position
TX      = $27               ; Temp X
TY      = $28               ; Temp Y
FIRE    = $29               ; Fire flag
HIT     = $2A               ; Free to move flag

TEMMAN  = $2B               ; Man move tempo
NEWROM  = $2C               ; Move to new room flag

STOP    = $2D               ; Stop everything flag

CL      = $2E               ; Colour address (2 bytes)

XPIX    = $30               ; Man X pixel
YPIX    = $31               ; Man Y pixel
DIR     = $32               ; Man direction
RUSTIC  = $33               ; Flag
CHAR    = $34               ; Current character
GOING   = $35               ; Moving flag

CHKX    = $36               ; Check X position
CHKY    = $37               ; Check Y position
TEMDIR  = $38               ; Temp direction

BEHIND  = $39               ; Behind character buffer (4 bytes)

DL      = $3D               ; Pointer to buffer (2 bytes)
OL      = $3F               ; Pointer to screen (2 bytes)
COUNT   = $41               ; Number to copy
COPY    = $42               ; Character to copy
COLOUR  = $43               ; Colour of character

ALIPOS  = $44               ; Alien X,Y table (8 bytes)
IRQPRT  = $4C               ; IRQ print table (8 bytes)
IRQRUB  = $54               ; IRQ clear table (8 bytes)
ALITIM  = $5C               ; Time to start (4 bytes)
MOVE    = $60               ; Can move flag
CHEKX   = $61               ; Try X direction
CHEKY   = $62               ; Try Y direction
ALITEM  = $63               ; Alien move tempo
ALICNT  = $64               ; Alien count
ALX     = $65               ; Alien X position
ALY     = $66               ; Alien Y position
PRTALS  = $67               ; Print aliens flag
POINT   = $68               ; Temp pointer

KEYVAL  = $69               ; Inkey value

BDCNT   = $6A               ; Border animation count
ANITEM  = $6B               ; Animate tempo

TIMER   = $6C               ; Bomb timer
BOMSL   = $6D               ; Bomb screen address (2 bytes)
BOMCL   = $6F               ; Bomb colour address (2 bytes)
BOMBON  = $71               ; Bomb on flag
BOMBGO  = $72               ; Go for it BASIC flag
BREADY  = $73               ; Bomb recharged flag
CHTIME  = $74               ; Charge time

; Bomb fill positions
AX      = $75
AY      = $76
BX      = $77
BY      = $78
CX      = $79
CY      = $7A
DX      = $7B
DY      = $7C

STOPA   = $7D               ; Stop direction A
STOPB   = $7E               ; Stop direction B
STOPC   = $7F               ; Stop direction C
STOPD   = $80               ; Stop direction D

BOMX    = $81               ; Top-left bomb X coordinate
XBOMB   = $82               ; X explosion size
BOMY    = $83               ; Top-left bomb Y coordinate
YBOMB   = $84               ; Y explosion size
BOMCOL  = $85               ; Explosion colour
BMBCOL  = $86               ; Bomb colour

NUMB    = $87               ; High print

JIGX    = $88               ; Edit jigsaw X
JIGY    = $89               ; Edit jigsaw Y
COPYL   = $8A               ; Copy address (2 bytes)
COPYCH  = $8C               ; Copy character number
NOCORR  = $8D               ; Number in correct position
JIGNO   = $8E               ; Jigsaw piece number

DELLY   = $8F               ; Time delay pass

COMPX   = $90               ; Man X position comparison
COMPY   = $91               ; Man Y position comparison
SWAP    = $92               ; Character to swap

BRKCNT  = $93               ; Brick animation count
KEEPON  = $94               ; Keep moving flag
MANCNT  = $95               ; Man animation counter
GLOPTM  = $96               ; Man tempo
TOGGLE  = $97               ; Toggle flag
ANTFAG  = $98               ; Flag

DEFTEM  = $99               ; Alien animation
ALYCNT  = $9A               ; Alien tempo
MORON   = $9B               ; Count

DEAD    = $9C               ; Dead flag
STPMAN  = $9D               ; Stop man animation
ALIENS  = $9E               ; Alien number
DUCK    = $9F               ; New alien definition flag
TITLE   = $A0               ; On title page flag
SAVDIR  = $A1               ; Saved direction
MANL    = $A2               ; Man position (2 bytes)
DEDBMB  = $A4               ; Died by bomb flag (2 bytes)

SCRADD  = $A6               ; Score to add

HISPNT  = $A7               ; High thingie
POSITN  = $A8               ; Position in table
INCNT   = $A9               ; Some counter
LETCNT  = $AA               ; Letter counter
BORDY   = $AB               ; Y position

NOTOKL  = $AC               ; Number of aliens to get
NOKILD  = $AD               ; Number killed
PRCOL   = $AE               ; Print colour
CLY     = $AF               ; Y position
MENATW  = $B0               ; Format flag
WALL    = $B1               ; Save wall

DATAX   = $B2               ; Move X position
DATAY   = $B3               ; Move Y position
ALKILL  = $B4               ; Number to kill
CLEARD  = $B5               ; Done this room flag

AR      = $B6               ; Alien rub out (2 bytes)
BONUS   = $B8               ; Bonus flag
DOSFX   = $B9               ; Do clear screen sound flag

ALMVET  = $BA
KILHEX  = $BB
KILDEC  = $BC

SIKBUF  = $BD               ; Score buffer (6 bytes)

;===============================================================================
; PROGRAM LOAD ADDRESS
;===============================================================================
.segment "LOADADDR"
    .word   $1000           ; Load at $1000

;===============================================================================
; SCREEN DATA SEGMENT - 25 compressed maze screens (2400 bytes at $1000-$195F)
;===============================================================================
.segment "SCREENS"
SCDATA:
    .incbin "screens.bin"

;===============================================================================
; MAIN CODE SEGMENT - starts at $1960
;===============================================================================
.segment "CODE"

;-------------------------------------------------------------------------------
; Entry point
;-------------------------------------------------------------------------------
START:
    sei
    jsr CLVARS              ; Clear variables
    jsr INHISC              ; Initialize high score table
    lda #<MESST             ; Initialize message pointer
    sta MESL
    lda #>MESST
    sta MESL+1
    lda #1
    sta SNDFLG              ; Sound on by default
    lda #0
    sta JOYSEL              ; Keyboard mode by default
    jmp GLOPPY              ; Go to title screen

;===============================================================================
; SECTION: TABLES (tables.asm)
;===============================================================================
TIME5:
    .byte 0, 5, 10, 15, 20

TIM32:
    .byte 0, 32, 64, 96, 128, 160, 192, 224

WALY:
    .byte 0, 1, 2, 40, 41, 42

;===============================================================================
; SECTION: UTILITIES (utils.asm)
;===============================================================================

;-------------------------------------------------------------------------------
; RANDOM - Generate random number
;-------------------------------------------------------------------------------
RANDOM:
    lda TED
    and RND+2
    adc TED+2
    asl a
    asl a
    rol RND+3
    rol RND+2
    rol RND+1
    rol RND
    ; Acornsoft RND algorithm
    clc
    ldy #$29
    ldx #$fc
RANLOP:
    tya
    ldy RND+4,x
    adc RND+4,x
    sta RND+4,x
    inx
    bne RANLOP
    rts

;-------------------------------------------------------------------------------
; DELAY - Wait loop
;-------------------------------------------------------------------------------
DELAY:
    ldx #$20
    ldy #$00
DELLOP:
    nop
    nop
    nop
    dey
    bne DELLOP
    dex
    bne DELLOP
    rts

;-------------------------------------------------------------------------------
; CLVARS - Clear zero page variables
;-------------------------------------------------------------------------------
CLVARS:
    lda #$00
    ldx #$07
CLLOP:
    sta $00,x
    inx
    bne CLLOP
    rts

;-------------------------------------------------------------------------------
; CLSWIN - Clear the game play window
;-------------------------------------------------------------------------------
CLSWIN:
    lda #22
    sta CLY
CLRIT1:
    ldx #0
    ldy CLY
    jsr XY
    ldy #30
CLRIT2:
    lda #196
    sta (SL),y
    lda #$71
    sta (CL),y              ; Colour
    dey
    bne CLRIT2
    dec CLY
    bne CLRIT1
    rts

;-------------------------------------------------------------------------------
; XY - Convert X,Y coordinates to screen address
; Input: X = X position, Y = Y position
; Output: SL/SL+1 = screen address, CL/CL+1 = colour address
;-------------------------------------------------------------------------------
XY:
    cpy #0
    bpl YOOKE
    ldy #0
YOOKE:
    ; If Y < 0 then Y = 0
    tya
    asl a
    tay
    lda SCRPOS,y
    sta SL
    lda SCRPOS+1,y
    sta SL+1
    txa
    clc
    adc SL
    sta SL
    sta CL
    lda SL+1
    adc #0
    sta SL+1
    sec
    sbc #4                  ; Colour RAM offset for C16
    sta CL+1
    rts

; Screen position table (C16 screen at $0C00)
SCRPOS:
    .word $0C00,$0C28,$0C50,$0C78,$0CA0
    .word $0CC8,$0CF0,$0D18,$0D40,$0D68
    .word $0D90,$0DB8,$0DE0,$0E08,$0E30
    .word $0E58,$0E80,$0EA8,$0ED0,$0EF8
    .word $0F20,$0F48,$0F70,$0F98,$0FC0

;-------------------------------------------------------------------------------
; COPYBM - Copy bomb character data
;-------------------------------------------------------------------------------
COPYBM:
    ldx #31
GTI205:
    lda $3FA0,x
    sta $3960,x
    dex
    bpl GTI205
    rts

;===============================================================================
; SECTION: SETUP (setup.asm)
;===============================================================================
SETUP:
    lda TED+18
    and #%11111011          ; Characters from RAM
    sta TED+18
    lda TED+7
    ora #$90                ; 256 characters + multicolour
    sta TED+7
    lda #$38
    sta TED+19              ; Characters at $3800 (2K charset)
    ldx #3
RNL:
    lda TED,x               ; Use timers as random seed
    sta RND,x
    dex
    bpl RNL
    lda #$11
    sta BACKGR
    sta BORDER
    lda #$00
    sta MULTI1
    lda #$46
    sta MULTI2
    rts

;===============================================================================
; SECTION: IRQ ROUTINES (irq.asm)
;===============================================================================
RASVAL:
    .byte $C1, $00

SETIRQ:
    sei
    lda #<SERV
    sta $0314
    lda #>SERV
    sta $0315
    lda #%00000010
    sta IRQMSK              ; Enable raster IRQ
    lda RASVAL
    sta RASCOM              ; Set raster compare
    lda #0
    sta INTYPE
    cli
    rts

SERV:
    lda IRQREG
    sta IRQREG              ; Acknowledge IRQ
    lda INTYPE
    eor #1
    sta INTYPE
    ; Save XY variables
    lda SL
    pha
    lda SL+1
    pha
    lda CL
    pha
    lda CL+1
    pha
    lda INTYPE
    bne NORAS1
    jmp RAST1
NORAS1:
    jmp RAST2
NORAS2:

IRQEND:
    pla
    sta CL+1
    pla
    sta CL
    pla
    sta SL+1
    pla
    sta SL
    ldx INTYPE
    lda RASVAL,x
    sta RASCOM
    pla
    tay
    pla
    tax
    pla
    rti

;===============================================================================
; SECTION: RASTER ROUTINES (raster-routines.asm)
;===============================================================================
RAST1:
    ; Main play area - multicolour, steady
    lda TED+7
    and #%11110000
    ora #%00001000
    sta TED+7               ; Multicolour + 40 cols, reset pixel movement
    jsr ANIMAT              ; Animate glop characters
    jsr RANDOM              ; Random numbers
    jmp IRQEND

RAST2:
    ; Pixel scrolling message area
    ldx #7
SHITY:
    dex
    bpl SHITY
    lda TED+7
    and #%11110000          ; Back to 38 cols
    ora MESSX               ; Message pixel position
    sta TED+7
    jsr MESSVE              ; Glop message
    jsr REDJOS              ; Read input device
    lda STOP
    bne MISS1
    jsr UPBOMB              ; Bomb code
    jsr PRNALS              ; Print aliens
    jsr MOVEMN              ; Move man
MISS1:
    lda TITLE               ; On title page?
    beq MISS2
    jsr BDRGLP              ; Scroll border
MISS2:
    jmp IRQEND

;===============================================================================
; SECTION: JOYSTICK (joystik.asm)
; C16 reads joystick by writing to JPORT to select port, then reading back
;===============================================================================
REDJOS:
    lda JOYSEL              ; Check joystick or keyboard mode
    bne TRYJOS
    jmp KEY                 ; Use keyboard
TRYJOS:
    lda #$FD                ; Select joystick port 0
    sta JPORT
    lda #$4A                ; Opcode for 'LSR A'
    sta XTRCDE
    lda JPORT
    eor #$FF
    bne NAYE
    ; Try port 1
    lda #$FA                ; Select joystick port 1
    sta JPORT
    lda #$EA                ; Opcode for 'NOP'
    sta XTRCDE
    lda JPORT
    eor #$FF
    bne NAYE
NOMOVE:
    lda #0
    ldx #5
NME1:
    sta JLEFT,x
    dex
    bpl NME1
    rts
NAYE:
    ror a
    ror JUP
    ror a
    ror JDOWN
    ror a
    ror JLEFT
    ror a
    ror JRIGHT
    lsr a
    lsr a
    lsr a
XTRCDE:
    nop                     ; Self-modifying: NOP or LSR A
    ror JFIRE
    lda #1
    sta JMOVE
    rts

;-------------------------------------------------------------------------------
; KEY - Keyboard input (active low - 0 = pressed)
; Controls: Z=left, X=right, K=up, N=down, Space=fire
; Z=$EF/bit4, X=$7F/bit1, K=$DF/bit4, N=$7F/bit3, Space=$7F/bit4
;-------------------------------------------------------------------------------
KEY:
    lda #0
    ldx #5
KEYCLR:
    sta JLEFT,x
    dex
    bpl KEYCLR
    ; K = UP (row $DF, bit 4)
    lda #$DF
    sta JPORT
    lda JPORT
    and #$10
    bne KNO1
    lda #$80
    sta JUP
KNO1:
    ; Z = LEFT (row $EF, bit 4)
    lda #$EF
    sta JPORT
    lda JPORT
    and #$10
    bne KNO2
    lda #$80
    sta JLEFT
KNO2:
    ; Row $7F: X=right(bit1), N=down(bit3), Space=fire(bit4)
    lda #$7F
    sta JPORT
    lda JPORT
    tax
    and #$02                ; X = RIGHT (bit 1)
    bne KNO3
    lda #$80
    sta JRIGHT
KNO3:
    txa
    and #$08                ; N = DOWN (bit 3)
    bne KNO4
    lda #$80
    sta JDOWN
KNO4:
    txa
    and #$10                ; SPACE = FIRE (bit 4)
    bne KEYEX
    lda #$80
    sta JFIRE
KEYEX:
    rts

;===============================================================================
; SECTION: BOMB CODE (bomb-code.asm)
;===============================================================================
BOMB:
    lda BOMBON              ; Bomb already on?
    bne BM1
    lda BREADY              ; Bomb recharged?
    beq BM1                 ; Not yet
    ldx MANX
    ldy MANY
    lda DIR
    and #3
    beq BERM1
    inx
BERM1:
    lda DIR
    and #$C
    beq BERM2
    iny
BERM2:
    stx BOMX
    sty BOMY                ; Top-left coordinate
    jsr XY
    lda SL
    sta BOMSL
    sta BOMCL
    lda SL+1
    sta BOMSL+1
    lda CL+1
    sta BOMCL+1
    ; Get screen and colour address
    lda #55
    sta TIMER               ; Count down
    ldx #1
    stx BOMBON              ; Bomb is now on
    dex
    stx BOMBGO
    lda SNDFLG
    beq BM1
    lda #$2F
    sta VOL
    ; Channel 2, normal (noise later)
    lda #0
    sta SOU2HI
    sta SOU2LO
BM1:
    rts

;-------------------------------------------------------------------------------
; UPBOMB - Update bomb (called from IRQ)
;-------------------------------------------------------------------------------
UPBOMB:
    jsr READY               ; Update charger
    lda BOMBON
    beq TIMOOT
    ; Only do this if bomb is on
    jsr BOMPRT              ; Print it (flash)
    dec TIMER
    beq STBOMB
    lda #56
    sec
    sbc TIMER               ; Inverse
    asl a
    rol MORON
    asl a
    rol MORON
    asl a
    rol MORON
    asl a
    rol MORON
    sta SOU2LO              ; Sound * 16
    lda MORON
    sta SOU2HI
TIMOOT:
    rts

STBOMB:
    lda #1
    sta BOMBGO              ; Tell main loop to go!
    rts

;-------------------------------------------------------------------------------
; BASBOM - Main loop bomb explosion handler
;-------------------------------------------------------------------------------
BASBOM:
    lda BOMBGO
    bne GOBOMR
    rts
GOBOMR:
    lda ANTFAG
    beq GOBOMR
    ; Wait for man to be in a character position
    lda #$FF
    sta SOU2LO
    sta SOU2HI
    lda SNDFLG
    beq STEW2
    lda #$4F
    sta VOL                 ; Noise now
STEW2:
    ldx #1
    stx STOP                ; No IRQs
    ; Find man's top-left for post-fill detection
    jsr FINDTL
    ; Do the bomb fill
    jsr FILBMB
    sei
    ldx #31
CLBMBC:
    lda #0
    sta $3960,x
    dex
    bpl CLBMBC
    ; Clear charge character
    ; Now stop all bomb stuff
    lda #0
    sta STOP
    sta BOMBGO
    sta BOMBON
    sta BREADY              ; Start charging
    sta CHTIME              ; Charge time
    sta VOL                 ; Sound off
    cli
    rts

;-------------------------------------------------------------------------------
; BOMPRT - Print bomb on screen
;-------------------------------------------------------------------------------
BOMPRT:
    ldx #3
    lda #247
    sta CHAR
    lda TED
    ora #%00001000
    sta BMBCOL              ; Multicolour
SOD1:
    ldy YVAL2,x
    lda CHAR
    sta (BOMSL),y
    lda BMBCOL
    sta (BOMCL),y           ; Flash colour
    dec CHAR
    dex
    bpl SOD1
    rts

;-------------------------------------------------------------------------------
; READY - Charge the bomb
;-------------------------------------------------------------------------------
READY:
    lda BREADY
    beq UPCHRG
    ; Already ready - exit
KWAH:
    rts
UPCHRG:
    dec CHTIME
    bne CHRGE
    lda #1
    sta BREADY
    jsr COPYBM              ; Copy full bomb
    rts
CHRGE:
    ; Update the charging character
    lda CHTIME
    and #$0F
    bne KWAH                ; Wait for top bit to change
    ; Scroll char up to make room for new data
    lda $3970
    pha
    lda $3978
    pha
    ldx #0
SCROL:
    lda $3961,x
    sta $3960,x
    lda $3969,x
    sta $3968,x
    lda $3971,x
    sta $3970,x
    lda $3979,x
    sta $3978,x
    inx
    cpx #7
    bne SCROL
    pla
    sta $396F
    pla
    sta $3967
    lda CHTIME              ; $FF - $00
    lsr a
    lsr a
    lsr a
    lsr a
    ; 0-15
    eor #$0F
    tay
    and #8
    beq BOTBMB              ; Doing top 2
    tya
    and #7
    clc                     ; X = 0 to 7
    adc #16
    tay
BOTBMB:
    tya
    ; Y holds offset to char data
    lda $3FA0,y
    sta $3977               ; Left char
    lda $3FA8,y
    sta $397F               ; Right char
    rts

;===============================================================================
; SECTION: FILLER BOMB (filler-bomb.asm) - RECONSTRUCTED FROM C64
; This section was truncated in C16 source - restored from C64 with adaptations
;===============================================================================
FILBMB:
    ldx BOMX
    stx AX
    stx CX
    inx
    stx BX
    stx DX
    ldy BOMY
    sty AY
    sty BY
    iny
    sty CY
    sty DY
    ; 4 corner addresses sussed
    lda RND+1
    and #3
    clc
    adc #4
    ; Random diameter of bomb 4-7
    sta YBOMB
    lda #0
    sta STOPA
    sta STOPB
    sta STOPC
    sta STOPD
FILL1:
    lda STOPA
    bne STARTB              ; A already finished
    lda #$FF
    sta XBOMB
    ldx AX
FILA:
    ldy AY
    jsr CHKBMB
    bcs STFILA              ; Exit loop
    dex
    inc XBOMB
    lda XBOMB
    cmp YBOMB
    bne FILA
STFILA:
    lda XBOMB
    cmp #$FF
    bne STARTB
    lda #1
    sta STOPA               ; A hit it
STARTB:
    ; Start next direction
    lda STOPB
    bne STARTC
    lda #$FF
    sta XBOMB
    ldx BX
FILB:
    ldy BY
    jsr CHKBMB
    bcs STFILB              ; Bit the dust
    inx
    inc XBOMB
    lda XBOMB
    cmp YBOMB
    bne FILB
STFILB:
    lda XBOMB
    cmp #$FF
    bne STARTC
    lda #1
    sta STOPB
STARTC:
    lda STOPC
    bne STARTD
    lda #$FF
    sta XBOMB
    ldx CX
FILC:
    ldy CY
    jsr CHKBMB
    bcs STFILC              ; Stop it
    dex
    inc XBOMB
    lda XBOMB
    cmp YBOMB
    bne FILC
STFILC:
    lda XBOMB
    cmp #$FF
    bne STARTD
    lda #1
    sta STOPC
STARTD:
    lda STOPD
    bne FILLEX              ; Exit
    lda #$FF
    sta XBOMB
    ldx DX
FILD:
    ldy DY
    jsr CHKBMB
    bcs STFILD              ; Get out
    inx
    inc XBOMB
    lda XBOMB
    cmp YBOMB
    bne FILD
STFILD:
    lda XBOMB
    cmp #$FF
    bne FILLEX
    lda #1
    sta STOPD
FILLEX:
    dec AY
    dec BY
    inc CY
    inc DY
    ldx #$10
    jsr DELAY+2
    ; Looks better with a delay
    dec YBOMB
    bmi FILOUT
    jmp FILL1
FILOUT:
    ldx #0
    jsr DELAY+2
    jsr MANDED              ; Man hit?
    jsr ALIHIT              ; Any aliens hit?
    jsr CLEXP               ; Clear explosion
    lda DOSFX               ; Do clear screen SFX
    beq JHUYS
    jsr CLSSND              ; Sound
JHUYS:
    lda #0
    sta DOSFX
    rts

;-------------------------------------------------------------------------------
; CHKBMB - Check bomb position (RESTORED FROM C64)
;-------------------------------------------------------------------------------
CHKBMB:
    txa
    pha
    ; Check if coordinate out of range
    cpx #0
    bcc OUTRAN              ; Out of range
    cpx #31
    bcs OUTRAN
    cpy #0
    bcc OUTRAN
    cpy #23
    bcs OUTRAN
    lda #1
    sta BOMCOL
    jsr XY
    ldy #0
    lda (SL),y
    cmp #197
    bcc BMBOK
    cmp #209
    bcs BMBOK
OUTRAN:
    pla
    tax
    sec                     ; C=1 if not ok
    rts
BMBOK:
    lda #248
    sta (SL),y
    lda BOMCOL              ; Colour
    sta (CL),y
    pla
    tax
    clc
    rts

;-------------------------------------------------------------------------------
; CLEXP - Clear explosion (RESTORED FROM C64)
;-------------------------------------------------------------------------------
CLEXP:
    lda #<$0C29
    sta SL
    lda #>$0C29
    sta SL+1
    ldx #21
EXCLR1:
    ldy #30
EXCLR2:
    lda (SL),y
    cmp #248                ; Bomb char?
    bne NEXP
    lda #196
    sta (SL),y
NEXP:
    dey
    bpl EXCLR2
    lda SL
    clc
    adc #40
    sta SL
    lda SL+1
    adc #0
    sta SL+1
    dex
    bpl EXCLR1
    rts

;-------------------------------------------------------------------------------
; CLSSND - Clear screen sound effect
;-------------------------------------------------------------------------------
CLSSND:
    lda #$2F
    sta VOL
    lda #$FF
    sta SOU1LO
    lda #$02
    sta SOU1HI
    ldx #$20
    jsr DELAY+2
    lda #0
    sta VOL
    rts

;===============================================================================
; SECTION: CHECK MAN (check-man.asm)
;===============================================================================
CHECK:
    jsr XY                  ; Convert to screen address
    ldx #3
RUB1:
    ldy YVAL2,x
    lda (SL),y
    sta BEHIND,x            ; Save to buffer
    cmp #197
    bcc CKOK
    cmp #244
    bcs CKOK
    lda #1
    sta HIT
CKOK:
    dex
    bpl RUB1
    rts

;-------------------------------------------------------------------------------
; MANDED - Check if man died from explosion
;-------------------------------------------------------------------------------
MANDED:
    ldx #3
MNDE2:
    ldy YVAL2,x
    lda (MANL),y
    cmp #248                ; Explosion char
    bne BUTDS               ; Not died!
    lda #1
    sta DEAD
    sta DEDBMB              ; Died by bomb
BUTDS:
    dex
    bpl MNDE2
    rts

;-------------------------------------------------------------------------------
; FINDTL - Find top-left of man on screen
;-------------------------------------------------------------------------------
FINDTL:
    lda #22
    sta TEMP
FINDE1:
    ldx #0
    ldy TEMP
    jsr XY
    ldy #30
FINDE2:
    lda (SL),y
    cmp #28
    bne NXTFND
    sty TY
    lda SL
    clc
    adc TY
    sta MANL
    lda SL+1
    adc #0
    sta MANL+1
    rts
NXTFND:
    dey
    bne FINDE2
    dec TEMP
    bne FINDE1
FINDNO:
    inc $FF19               ; Error indicator
    jmp FINDNO

;===============================================================================
; SECTION: MOVE PIXEL (move-pixel.asm)
;===============================================================================
MOVEMN:
    jsr PRINT               ; Print new man
    jsr MNMOVE              ; Move him
    ldx CHKX
    ldy CHKY
    jsr CHECK               ; Check
    lda HIT
    beq ITSOK               ; No hit
    jsr DEATH               ; Hit alien?
    lda DEAD
    bne ESC
    jsr CHGROM              ; Change room?
    lda NEWROM
    bne ESC
    lda TRX
    sta MANX
    lda TRY
    sta MANY
    lda TEMDIR
    sta DIR
    lda #0
    sta GOING
    sta XPIX
    sta YPIX
    sta HIT
ITSOK:
    jsr UPPIXE              ; Move pixels
ESC:
    rts

;-------------------------------------------------------------------------------
; PRINT - Print man on screen
;-------------------------------------------------------------------------------
PRINT:
    ldx TRX
    ldy TRY
    dey
    jsr XY
    jsr BUGRUB              ; Rub him out
    ldx MANX
    ldy MANY
    jsr XY
    lda YPIX
    bne NOWAY
    lda XPIX
    beq NORMPR
NOWAY:
    lda #0
    sta KEEPON
    sta ANTFAG
    lda DIR
    cmp #3
    bcs PRNTY
    ldx XPIX
    lda TIME6,x
    clc
    adc #148
    sta CHAR
    ldx #0
PRT1:
    ldy WALY,x
    lda CHAR
    sta (SL),y
    inc CHAR
    lda #$79
    sta (CL),y
    inx
    cpx #6
    bne PRT1
    rts

TIME6:
    .byte 0, 6, 12, 18

YRUB:
    .byte 0, 1, 39, 40, 41, 42, 43
    .byte 79, 80, 81, 82, 83
    .byte 120, 121

NORMPR:
    lda ANTFAG
    bne QRUMP
    ldx #1
    stx KEEPON
    stx ANTFAG
    dex
    stx MANCNT
    lda #10
    sta GLOPTM
QRUMP:
    lda DIR
    and #3
    beq NORMP
    ldx MANX
    inx
    ldy MANY
    dey
    jsr XY
NORMP:
    ldx #3
GENARS:
    lda ACHAR,x
    ldy YCHIN,x
    sta (SL),y
    lda #$79
    sta (CL),y
    dex
    bpl GENARS
    rts

ACHAR:
    .byte 28, 29, 30, 31
YCHIN:
    .byte 40, 41, 80, 81

PRNTY:
    ldx YPIX
    lda TIME6,x
    clc
    adc #172
    sta CHAR
    ldx #0
PRT2:
    ldy YVAL2,x
    lda CHAR
    sta (SL),y
    lda #$79
    sta (CL),y
    inc CHAR
    inx
    cpx #6
    bne PRT2
    rts

YVAL2:
    .byte 0, 1, 40, 41, 80, 81

;-------------------------------------------------------------------------------
; MNMOVE - Man movement logic
;-------------------------------------------------------------------------------
MNMOVE:
    lda XPIX
    bne GETOUT
    lda YPIX
    bne GETOUT
    lda MANX
    sta TRX
    lda MANY
    sta TRY
    lda DIR
    sta TEMDIR
    bit JFIRE
    bpl NOLAY
    jsr BOMB
NOLAY:
    bit JLEFT
    bpl NLEFT
    lda DIR
    and #$0C
    beq BROUN3
    inc MANY
    dec MANX
BROUN3:
    ldx #1
    stx DIR
    stx GOING
    dex
    stx XPIX
    stx RUSTIC
    ldx MANX
    stx CHKX
    ldy MANY
    sty CHKY
GETOUT:
    rts

NLEFT:
    bit JRIGHT
    bpl NRIGHT
    inc MANX
    lda DIR
    and #$0C
    beq BROUN4
    dec MANX
    inc MANY
BROUN4:
    ldx #3
    stx XPIX
    dex
    stx DIR
    dex
    stx RUSTIC
    stx GOING
    ldy MANY
    sty CHKY
    ldx MANX
    inx
    stx CHKX
    rts

NRIGHT:
    bit JUP
    bpl NUP
    lda DIR
    and #$03
    beq BROUND
    inc MANX
    dec MANY
BROUND:
    lda #4
    sta DIR
    ldx #1
    stx GOING
    dex
    stx RUSTIC
    stx YPIX
    ldx MANX
    stx CHKX
    ldy MANY
    sty CHKY
    rts

NUP:
    bit JDOWN
    bpl GETOUT
    lda DIR
    and #$03
    beq BROUN2
    dec MANY
    inc MANX
BROUN2:
    lda #8
    sta DIR
    lda #3
    sta YPIX
    lda #1
    sta GOING
    sta RUSTIC
    inc MANY
    ldx MANX
    stx CHKX
    ldy MANY
    iny
    sty CHKY
    rts

;-------------------------------------------------------------------------------
; UPPIXE - Update pixel position
;-------------------------------------------------------------------------------
UPPIXE:
    lda GOING
    beq SIT
    lda RUSTIC
    beq KILL
    lda #0
    sta RUSTIC
SIT:
    rts

KILL:
    lda #1
    bit DIR
    bne MVELFT
    asl a
    bit DIR
    bne MVERIT
    asl a
    bit DIR
    bne MVEUP
    asl a
    bit DIR
    bne MVEDWN
MVELFT:
    inc XPIX
    lda XPIX
    tay
    and #3
    sta XPIX
    cpy #4
    beq STOPL
    rts
STOPL:
    lda #0
    sta XPIX
    sta GOING
    dec MANX
    rts

MVERIT:
    dec XPIX
    lda XPIX
    tay
    and #3
    sta XPIX
    cpy #$FF
    beq STOPR
    rts
STOPR:
    lda #0
    sta XPIX
    sta YPIX
    sta GOING
    rts

MVEDWN:
    dec YPIX
    lda YPIX
    tay
    and #3
    sta YPIX
    cpy #$FF
    beq STOPR
    rts

MVEUP:
    inc YPIX
    lda YPIX
    tay
    and #3
    sta YPIX
    cpy #4
    beq STOPU
    rts
STOPU:
    lda #0
    sta YPIX
    sta GOING
    dec MANY
    rts

;-------------------------------------------------------------------------------
; BUGRUB - Rub out man/alien
;-------------------------------------------------------------------------------
BUGRUB:
    ldx #13
RUUB1:
    ldy YRUB,x
    lda (SL),y
    cmp #196
    bcs DNTRUB
    cmp #148
    bcs DORBUT
    cmp #32
    bcs DNTRUB
DORBUT:
    lda #196
    sta (SL),y
DNTRUB:
    dex
    bpl RUUB1
    rts

;===============================================================================
; SECTION: ALIEN CHECK/PRINT (alien-chek-print.asm)
;===============================================================================
CHKALX:
    stx CHEKX
    sty CHEKY
    jsr XY
    ldy #0
    lda (SL),y
    cmp #196
    bne NOMVE
    ldy #40
    lda (SL),y
    cmp #196
    bne NOMVE
    beq CANMV

CHKALY:
    stx CHEKX
    sty CHEKY
    jsr XY
    ldy #0
    lda (SL),y
    cmp #196
    bne NOMVE
    iny
    lda (SL),y
    cmp #196
    bne NOMVE

CANMV:
    lda #1
    sta MOVE
    rts

NOMVE:
    lda #0
    sta MOVE
    rts

;-------------------------------------------------------------------------------
; PRNALS - Print and rub aliens
;-------------------------------------------------------------------------------
PRNALS:
    lda PRTALS
    bne DOIT
    rts
DOIT:
    lda #3
    sta ALICNT
ALILOP:
    lda ALICNT
    asl a
    tax
    stx POINT
    lda IRQRUB,x
    sta AL
    lda IRQRUB+1,x
    sta AL+1
    cmp #$FF
    beq MISOR
    ldx #3
ALILP1:
    lda #196
    ldy YVAL2,x
    sta (AL),y
    dex
    bpl ALILP1
    ldx POINT
    lda IRQPRT,x
    sta AL
    sta CL
    lda IRQPRT+1,x
    sta AL+1
    sec
    sbc #4
    sta CL+1
    ldx #3
    lda #212
    sta CHAR
ALILP2:
    ldy YVAL2,x
    lda CHAR
    sta (AL),y
    lda #$7C
    sta (CL),y
    dec CHAR
    dex
    bpl ALILP2
MISOR:
    dec ALICNT
    bpl ALILOP
    rts

;-------------------------------------------------------------------------------
; ALIHIT - Check if aliens were killed by explosion
;-------------------------------------------------------------------------------
ALIHIT:
    lda #3
    sta ALICNT
    lda #0
    sta BONUS
CJPL1:
    lda ALICNT
    asl a
    tax
    stx POINT
    lda IRQPRT,x
    sta AL
    lda IRQRUB,x
    sta AR
    lda IRQRUB+1,x
    sta AR+1
    lda IRQPRT+1,x
    sta AL+1
    cmp #$FF
    beq CJPL3
    ldx #3
CJPL2:
    ldy YVAL2,x
    lda (AL),y
    cmp #248
    beq ALIGT
    dex
    bpl CJPL2
    bmi CJPL3
ALIGT:
    ldx #3
CJPL4:
    lda #196
    ldy YVAL2,x
    sta (AL),y
    sta (AR),y
    dex
    bpl CJPL4
    ldx POINT
    lda #$FF
    sta IRQPRT,x
    sta IRQRUB,x
    sta IRQPRT+1,x
    sta IRQRUB+1,x
    sta ALIPOS,x
    sta ALIPOS+1,x
    inc BONUS
    ldx ALICNT
    lda TED+2
    and #15
    clc
    adc #15
    sta ALITIM,x
    lda CLEARD
    beq JUYTT
    lda #1
    ldy #4
    jsr SCORE+2
    jmp HEWQ
JUYTT:
    lda #5
    jsr SCORE
    lda #2
    ldy #4
    jsr SCORE+2
HEWQ:
    lda BONUS
    cmp #4
    bne NOBONS
    lda #1
    ldy #3
    jsr SCORE+2
NOBONS:
    jsr KILLED
CJPL3:
    dec ALICNT
    bmi CJPL5
    jmp CJPL1
CJPL5:
    rts

;===============================================================================
; SECTION: ALIENS MEGA CODE (aliens-mega-code.asm)
;===============================================================================
INITAL:
    ldx #7
ALPO1:
    lda #$FF
    sta IRQPRT,x
    sta IRQRUB,x
    sta ALIPOS,x
    dex
    bpl ALPO1
    ldx #3
    lda #1
ALAP2:
    sta ALITIM,x
    dex
    bpl ALAP2
    lda NOKILD
    cmp ALKILL
    bne MJORE
    rts
MJORE:
    ldx #7
AL11:
    lda ALSTAT,x
    sta ALIPOS,x
    dex
    bpl AL11
POCHIN:
    jsr GETDEF
    lda #1
    sta ALYCNT
    rts

ALSTAT:
    .byte 1, 1, 29, 1, 1, 21, 29, 21

;-------------------------------------------------------------------------------
; MVEALI - Move aliens (called from main loop)
;-------------------------------------------------------------------------------
MVEALI:
    lda #0
    sta PRTALS
    ldx #7
ALIM1:
    lda IRQPRT,x
    sta IRQRUB,x
    dex
    bpl ALIM1
    ldx MANX
    ldy MANY
    lda DIR
    and #3
    beq IRRO1
    inx
IRRO1:
    lda DIR
    and #$0C
    beq IRRO2
    iny
IRRO2:
    stx COMPX
    sty COMPY
    lda #3
    sta ALICNT
ALIM2:
    lda ALICNT
    asl a
    tax
    lda ALIPOS,x
    cmp #$FF
    beq KNAKED
    sta ALX
    lda ALIPOS+1,x
    sta ALY
    txa
    pha
    jsr MVEHIM
    pla
    pha
    tax
    lda ALY
    sta ALIPOS+1,x
    tay
    lda ALX
    sta ALIPOS,x
    tax
    jsr XY
    pla
    tax
    lda SL
    sta IRQPRT,x
    lda SL+1
    sta IRQPRT+1,x
    jmp M25

KNAKED:
    lda #$FF
    sta IRQPRT,x
    sta IRQPRT+1,x
    stx POINT
    ldx ALICNT
    dec ALITIM,x
    bne M25
    ldx POINT
    lda ALSTAT,x
    sta ALIPOS,x
    lda ALSTAT+1,x
    sta ALIPOS+1,x
M25:
    dec ALICNT
    bpl ALIM2
    lda #1
    sta PRTALS
    rts

;-------------------------------------------------------------------------------
; MVEHIM - Move individual alien
;-------------------------------------------------------------------------------
MVEHIM:
    lda ALX
    cmp COMPX
    beq TRYYXS
    lda ALX
    sec
    sbc COMPX
    bmi MLE1
    jsr ALLEFT
    lda MOVE
    bne MVED
MLE1:
    jsr ALRIGT
    lda MOVE
    bne MVED
TRYYXS:
    lda ALY
    sec
    sbc COMPY
    bmi MLE3
    jsr ALUP
    lda MOVE
    bne MVED
MLE3:
    jsr ALDOWN
MVED:
    lda #0
    sta MOVE
    rts

;-------------------------------------------------------------------------------
; Alien movement directions
;-------------------------------------------------------------------------------
ALLEFT:
    ldx ALX
    dex
    ldy ALY
    jsr CHKALX
    lda MOVE
    beq CLE
    dec ALX
CLE:
    rts

ALRIGT:
    ldx ALX
    inx
    inx
    ldy ALY
    jsr CHKALX
    lda MOVE
    beq CR
    inc ALX
CR:
    rts

ALUP:
    ldx ALX
    ldy ALY
    dey
    jsr CHKALY
    lda MOVE
    beq CU
    dec ALY
CU:
    rts

ALDOWN:
    ldx ALX
    ldy ALY
    iny
    iny
    jsr CHKALY
    lda MOVE
    beq CD
    inc ALY
CD:
    rts

;===============================================================================
; SECTION: PLAY GAME (play-game.asm)
;===============================================================================
PLAY:
    sei
    jsr CLVARS
    lda #12
    sta MANY
    sta TRY
    lda #2
    sta DIR
    jsr COPYBM
    jsr ROOMS
    jsr SETUP
    jsr SETIRQ
    lda #1
    sta STOP
    sta BREADY
    sta ANITEM
    sta ALITEM
    jsr SCATER
    jsr JMPBAK
    lda #0
    sta STOP
LOOP:
    jsr DEADCK
    jsr COMAND
    jsr BASBOM
    lda NEWROM
    beq NORM
    jsr ROOMON
NORM:
    ldx #$08
    jsr DELAY+2
    dec ALITEM
    bne DNTDIT
    lda ALMVET
    sta ALITEM
    jsr MVEALI
DNTDIT:
    jmp LOOP

;===============================================================================
; SECTION: ANIMATE CHARS (animate-chars.asm)
;===============================================================================
ANIMAT:
    jsr ANIEXP
    lda STPMAN
    bne DROYT
    jsr MANGLP
DROYT:
    jsr ALIANI
    dec ANITEM
    beq FGRE
    rts
FGRE:
    lda #7
    sta ANITEM
    ldx BDCNT
    inx
    cpx #6
    bne NTENA
    ldx #0
NTENA:
    stx BDCNT
    lda ANISEQ,x
    asl a
    asl a
    asl a
    tax
    ldy #0
ANI1:
    lda XDAT,x
    sta $3E58,y
    lda YDAT,x
    sta $3E60,y
    inx
    iny
    cpy #8
    bne ANI1
    inc BRKCNT
    lda BRKCNT
    cmp #3
    bne NTLSBK
    lda #0
    sta BRKCNT
NTLSBK:
    asl a
    asl a
    asl a
    tax
    ldy #0
BRKLOP:
    lda BRIK1,x
    sta $3E38,y
    lda BRIK2,x
    sta $3E40,y
    lda BRIK3,x
    sta $3E30,y
    inx
    iny
    cpy #8
    bne BRKLOP
    rts

;-------------------------------------------------------------------------------
; ANIEXP - Explosion character animation
;-------------------------------------------------------------------------------
ANIEXP:
    jsr RANDOM
    ldx RND+1
    ldy #0
EXP1:
    lda $8000,x
    sta $3FC0,y
    inx
    iny
    cpy #8
    bne EXP1
    lda BOMBGO
    beq FROUT
    ldx #31
DSAR:
    lda $3960,x
    eor TED
    and $3FA0,x
    sta $3960,x
    dex
    bpl DSAR
FROUT:
    rts

;-------------------------------------------------------------------------------
; MANGLP - Man glopping animation
;-------------------------------------------------------------------------------
MANGLP:
    lda KEEPON
    bne STORP
    ldx #0
    beq GEETIN
STORP:
    dec GLOPTM
    beq GRUNTY
    rts
GRUNTY:
    lda #45
    sta GLOPTM
    ldy MANCNT
    ldx TIM32,y
GEETIN:
    ldy #0
FROD:
    lda BALMAN,x
    sta $38E0,y
    inx
    iny
    cpy #32
    bne FROD
    ldx MANCNT
    inx
    cpx #4
    bne FACE
    ldx #2
FACE:
    stx MANCNT
    rts

ANISEQ:
    .byte 0, 1, 2, 3, 2, 1

XDAT:
    .byte $00,$00,$81,$FF,$FF,$81,$00,$00
    .byte $00,$00,$C3,$7E,$7E,$C3,$00,$00
    .byte $00,$00,$E7,$3C,$3C,$E7,$00,$00
    .byte $00,$00,$FF,$18,$18,$FF,$00,$00

YDAT:
    .byte $3C,$18,$18,$18,$18,$18,$18,$3C
    .byte $24,$3C,$18,$18,$18,$18,$3C,$24
    .byte $24,$24,$3C,$18,$18,$3C,$24,$24
    .byte $24,$24,$24,$3C,$3C,$24,$24,$24

BRIK1:
    .byte $6D,$6D,$FE,$FE,$BF,$BF,$79,$79
    .byte $B6,$B6,$7F,$7F,$FD,$FD,$9E,$9E
    .byte $DB,$DB,$BD,$BD,$7E,$7E,$E7,$E7

BRIK2:
    .byte $55,$7D,$7D,$7D,$7D,$7D,$7D,$55
    .byte $55,$69,$55,$7D,$7D,$55,$69,$55
    .byte $55,$69,$69,$55,$55,$69,$69,$55

BRIK3:
    .byte $55,$69,$55,$7D,$7D,$7D,$7D,$55
    .byte $55,$69,$69,$69,$55,$7D,$7D,$55
    .byte $55,$69,$69,$69,$69,$69,$55,$55

BALMAN:
    .byte $00,$05,$17,$1F,$5F,$7F,$7F,$77
    .byte $00,$50,$94,$A4,$E5,$E9,$F9,$F9
    .byte $77,$77,$75,$7D,$5D,$1F,$17,$05
    .byte $F9,$F9,$F9,$E9,$E5,$A4,$94,$50
    .byte $01,$17,$1B,$1D,$06,$17,$1F,$5F
    .byte $40,$D4,$E4,$74,$90,$94,$E4,$E5
    .byte $7F,$77,$75,$7D,$5F,$1F,$17,$05
    .byte $E9,$F9,$F9,$F9,$E5,$E4,$94,$50
    .byte $05,$17,$1F,$1F,$1E,$1F,$07,$16
    .byte $50,$D0,$74,$FD,$FD,$A5,$D0,$94
    .byte $1F,$5F,$7F,$77,$5F,$1F,$17,$05
    .byte $E4,$E5,$F9,$F9,$E5,$E4,$94,$50
    .byte $05,$07,$1D,$7F,$7F,$5A,$07,$16
    .byte $50,$D4,$F4,$F4,$B4,$F4,$D0,$94
    .byte $1F,$5F,$7F,$77,$5F,$1F,$17,$05
    .byte $E4,$E5,$F9,$F9,$E5,$E4,$94,$50

;-------------------------------------------------------------------------------
; ALIANI - Alien animation
;-------------------------------------------------------------------------------
ALIANI:
    dec ALYCNT
    beq HUG
    rts
HUG:
    lda #20
    sta ALYCNT
    inc DEFTEM
    lda DEFTEM
    and #1
    tay
    ldx TIM32,y
    ldy #0
COMUNI:
    lda ALIBUF,x
    sta $3E88,y
    inx
    iny
    cpy #32
    bne COMUNI
    rts

;===============================================================================
; SECTION: MESSAGE STUFF (message-stuff.asm)
;===============================================================================
MESSVE:
    lda MESSX
    sec
    sbc #1
    tay
    and #7
    sta MESSX
    tya
    and #8
    bne MESHIL
    rts
MESHIL:
    ldx #0
MSL1:
    lda $0FC1,x
    sta $0FC0,x
    inx
    cpx #39
    bne MSL1
    ; Put next letter on
    inc MESL
    bne RUPERT
    inc MESL+1
RUPERT:
    ldy #0
    lda (MESL),y
    cmp #$FF
    bne NTMSED
    lda #<MESST
    sta MESL
    lda #>MESST
    sta MESL+1
    jmp RUPERT
NTMSED:
    and #$3F
    sta $FC0+39
    rts

;===============================================================================
; SECTION: BORDER SCROLLING (title-works.asm)
;===============================================================================
BDRGLP:
    lda $81F
    sta STOPA
    lda $BB7
    sta STOPB
    lda $B98
    sta STOPC
    ldx #30
QAT1:
    lda $800,x
    sta $801,x
    dex
    bpl QAT1
    lda #22
    sta BORDY
QAT2:
    ldx #31
    ldy BORDY
    jsr XY
    ldy #0
    lda (CL),y
    ldy #40
    sta (CL),y
    dec BORDY
    bne QAT2
    lda STOPA
    sta $847
    ldx #0
QAT3:
    lda $B99,x
    sta $B98,x
    inx
    cpx #30
    bne QAT3
    lda STOPB
    sta $BB6
    lda #0
    sta BORDY
QAT4:
    ldx #0
    ldy BORDY
    jsr XY
    ldy #40
    lda (CL),y
    ldy #0
    sta (CL),y
    inc BORDY
    lda BORDY
    cmp #23
    bne QAT4
    lda STOPC
    sta $B70
    rts

;===============================================================================
; SECTION: DEATH CODE (death-code.asm)
;===============================================================================
DEATH:
    ldx #3
CHKDTH:
    lda BEHIND,x
    cmp #209
    bcc DODOK
    cmp #213
    bcs DODOK
    lda #1
    sta DEAD
DODOK:
    dex
    bpl CHKDTH
    rts

DEADCK:
    lda DEAD
    bne RUNTY
    rts
RUNTY:
    ldx #1
    stx STOP
    stx STPMAN
    dex
    stx DEAD
    jsr DOIT
    ; Replace man with cross chars
    ldx #7
CLOPE:
    lda $38E0,x
    sta $3908,x
    lda $38F0,x
    sta $3910,x
    lda $38E8,x
    sta $3918,x
    lda $38F8,x
    sta $3920,x
    dex
    bpl CLOPE
    lda DEDBMB
    beq NTHYU
    lda MANL
    sta SL
    sta CL
    lda MANL+1
    sta SL+1
    sec
    sbc #4
    sta CL+1
    jmp STEVE
NTHYU:
    ldx MANX
    ldy MANY
    lda DIR
    and #3
    beq CHAKA
    inx
CHAKA:
    lda DIR
    and #4
    beq KHAN
    iny
KHAN:
    jsr XY
STEVE:
    lda SNDFLG
    beq STEW1
    lda #$2F
    sta VOL
STEW1:
    lda #2
    sta SOU2HI
    lda SL
    pha
    sec
    sbc #40
    sta SL
    lda SL+1
    pha
    sbc #0
    sta SL+1
    jsr BUGRUB
    pla
    sta SL+1
    pla
    sta SL
    ldx #3
    lda #36
    sta CHAR
CLONET:
    ldy DEDY,x
    lda CHAR
    sta (SL),y
    lda #$7F
    sta (CL),y
    dec CHAR
    dex
    bpl CLONET
    ; Animation loop
    ldy #15
ANRT:
    ldx #14
CLOSCR:
    lda $3908,x
    sta $3909,x
    lda $3918,x
    sta $3919,x
    dex
    bpl CLOSCR
    tya
    pha
    ldx #$20
    jsr DELAY+2
    pla
    tay
    asl a
    asl a
    asl a
    asl a
    sta SOU2LO
    lda #0
    sta $3908
    sta $3918
    dey
    bpl ANRT
    ; Scroll up the cross
    ldx #0
SCRUPS:
    lda CROSSL,x
    sta $3917
    lda CROSSR,x
    sta $3927
    ldy #0
MEATLF:
    lda $3909,y
    sta $3908,y
    lda $3919,y
    sta $3918,y
    iny
    cpy #15
    bne MEATLF
    txa
    pha
    ldx #$30
    jsr DELAY+2
    pla
    tax
    lda RND+2
    sta SOU2LO
    inx
    cpx #15
    bne SCRUPS
    lda #0
    sta VOL
    tax
    tay
WRATH:
    inc BACKGR
    dey
    bne WRATH
    dex
    bne WRATH
    lda #$11
    sta BACKGR
    ldx #$00
    jsr DELAY+2
    jsr DELAY+2
    jsr DELAY+2
    lda #0
    sta STPMAN
    sta DEDBMB
    dec $CEB
    dec LIVES
    bne MORE
    jmp GMEOVR
MORE:
    lda SAVEX
    sta MANX
    lda SAVEY
    sta MANY
    lda SAVDIR
    sta DIR
    lda #1
    sta DUCK
    jsr JMPBAK
    lda #0
    sta DUCK
    jmp LOOP

DEDY:
    .byte 0, 40, 1, 41

CROSSL:
    .byte $05,$07,$57,$7F,$7F,$6B,$57,$07
    .byte $07,$07,$07,$07,$15,$5A,$6A,$55

CROSSR:
    .byte $50,$D0,$D5,$FD,$FD,$E9,$D5,$D0
    .byte $D0,$D0,$D0,$D0,$54,$F5,$BD,$55

;===============================================================================
; SECTION: CHANGE ROOM (change-room.asm)
;===============================================================================
CHGROM:
    ldy #0
    ldx #3
CLK:
    lda BEHIND,x
    cmp #200
    bne NXT
    iny
NXT:
    dex
    bpl CLK
    cpy #2
    beq NEWBOD
    rts
NEWBOD:
    lda #1
    sta NEWROM
    sta STOP
    rts

ROOMON:
    lda #1
    bit DIR
    bne SCRLFT
    asl a
    bit DIR
    bne SCRRGT
    asl a
    bit DIR
    bne SCRUP
    asl a
    bit DIR
    bne SCRDWN
    rts
SCRRGT:
    inc XPOS
    lda #0
    sta MANX
    lda #11
    sta MANY
    jmp JMPBAK
SCRLFT:
    dec XPOS
    lda #28
    sta MANX
    lda #11
    sta MANY
    jmp JMPBAK
SCRDWN:
    inc YPOS
    lda #15
    sta MANX
    lda #0
    sta MANY
    jmp JMPBAK
SCRUP:
    dec YPOS
    lda #15
    sta MANX
    lda #20
    sta MANY

JMPBAK:
    ldy YPOS
    lda TIME5,y
    clc
    adc XPOS
    sta SCREEN
    tax
    lda GOTBIT,x
    sta CLEARD
    jsr SETLVL
    ldx #0
    stx PRTALS
    stx NEWROM
    stx GOING
    stx XPIX
    stx YPIX
    stx BOMBON
    stx BOMBGO
    jsr DECODE
    lda #$10
    sta DELLY
    jsr FADEIN
    lda CLEARD
    bne TENSON
    jsr PRPICE
    jmp DRINK
TENSON:
    jsr GOTMES
    lda #7
    sta ALMVET
DRINK:
    lda MANX
    sta SAVEX
    lda MANY
    sta SAVEY
    lda DIR
    sta SAVDIR
    lda #14
    sta CHKX
    lda #10
    sta CHKY
    lda DUCK
    bne FRUT
    jsr INITKL
FRUT:
    jsr INITAL
    lda #0
    sta STOP
    rts

;===============================================================================
; SECTION: SCORE ROUTINES (score-routines.asm)
;===============================================================================
SCOREP = $C21+120

SCORE:
    ldy #5
ADDLOP:
    sta SCRADD
    lda SCOREP,y
    cmp #32
    bne NTORT
    lda #$30
NTORT:
    clc
    adc SCRADD
    cmp #$3A
    bmi SCOREL
    sec
    sbc #$A
    sta SCOREP,y
    lda #1
    dey
    bpl ADDLOP
SCOREL:
    sta SCOREP,y
    lda SCOREP+2
    and #15
    cmp XTRA
    beq XARGON
    sta XTRA
    lda LIVES
    cmp #9
    beq XARGON
    inc LIVES
    inc $C00+200+35
XARGON:
    rts

;===============================================================================
; SECTION: SCATTER (scatter.asm)
;===============================================================================
SCATER:
    jsr PRJIG
    lda #1
    sta DELLY
    lda #0
    sta SCREEN
SCAT1:
    jsr RADAR
    jsr DECODE
    jsr FADEIN
    jsr PRPICE
    ldx #$40
    jsr DELAY+2
    jsr GETRID
    jsr COLJIG
    bit JFIRE
    bmi HUNCK
    ldx #$10
    jsr DELAY+2
    inc SCREEN
    lda SCREEN
    cmp #25
    bne SCAT1
    rts
HUNCK:
NOPAL:
    jsr RADAR
    jsr GETRID
    ldx #$20
    jsr DELAY+2
    jsr COLJIG
    inc SCREEN
    lda SCREEN
    cmp #25
    bne NOPAL
    rts

GETRID:
    ldx SCREEN
    lda JIGNUM,x
    clc
    adc #215
    sta COPY
    ldx #24
SCAT2:
    ldy RADY,x
    lda $E02,y
    cmp COPY
    bne NTSCAT
    lda #27
    sta $E02,y
NTSCAT:
    dex
    bpl SCAT2
    rts

;===============================================================================
; SECTION: INIT ROOMS (init-rooms.asm)
;===============================================================================
ROOMS:
    jsr SETUP
    jsr RNDBUF
    ldx #24
WRD2:
    lda SCRBUF+25,x
    sta JIGNUM,x
    dex
    bpl WRD2
    jsr RNDBUF
    ldx #24
WRD3:
    lda SCRBUF+25,x
    sta ROMNUM,x
    lda #0
    sta GOTBIT,x
    dex
    bpl WRD3
    rts

RNDBUF:
    ldx #24
    lda #0
WDR1:
    sta SCRBUF,x
    dex
    bpl WDR1
    lda #0
    sta XCOUNT
WDDR:
    jsr RANDOM
    lda RND+2
    and #31
    cmp #25
    bcs WDDR
    tay
    tax
    lda SCRBUF,x
    bne WDDR
    lda #1
    sta SCRBUF,x
    tya
    ldx XCOUNT
    sta SCRBUF+25,x
    inc XCOUNT
    lda XCOUNT
    cmp #25
    bne WDDR
    rts

;===============================================================================
; SECTION: KILLER CODE (killer-code.asm)
;===============================================================================
INITKL:
    lda #0
    sta NOKILD
    lda KILHEX
    sta ALKILL
    lda CLEARD
    bne KILLED
    sed
    lda KILDEC
    sta NOTOKL
    cld
    jmp OHSHIT

KILLED:
    lda CLEARD
    beq KILOP
    lda #$30
    sta $D3B
    sta $D3C
    rts
KILOP:
    inc NOKILD
OHSHIT:
    sed
    lda NOTOKL
    sec
    sbc #1
    sta NOTOKL
    cld
    pha
    lsr a
    lsr a
    lsr a
    lsr a
    ora #$30
    sta $D3B
    pla
    and #15
    ora #$30
    sta $D3C
    lda NOTOKL
    beq KILALL
    rts
KILALL:
    ldx SCREEN
    lda #1
    sta GOTBIT,x
    sta CLEARD
    sta DOSFX
    jsr TRANSF
    rts

;===============================================================================
; SECTION: LEVEL INCREASE (level-increase.asm)
;===============================================================================
SETLVL:
    ldx LEVEL
    lda LVALMV,x
    sta ALMVET
    lda LVNOKL,x
    sta KILHEX
    lda LVNOKK,x
    sta KILDEC
    rts

LVALMV:
    .byte 20, 16, 12, 8, 4
LVNOKL:
    .byte 10, 15, 20, 25, 30
LVNOKK:
    .byte $11, $16, $21, $26, $31

UPLEVL:
    inc LEVEL
    lda LEVEL
    cmp #5
    bne MLOK
    lda #4
    sta LEVEL
MLOK:
    jsr CLSWIN
    ldx #<LVLOVR
    ldy #>LVLOVR
    jsr PWINT
    jsr CLSSND
    jsr CLSSND
    jsr CLSSND
    jmp PLAY

LVLOVR:
    .byte 8,8,$76,86,72,106,72,86,32,68,92,88,94,86,72,102,72,70,40,0
    .byte 8,9,$66,87,73,107,73,87,32,69,93,89,95,87,73,103,73,71,41,0
    .byte 9,12,$75,90,92,108,32,94,86,64,112,32,102,78,80,100,0
    .byte 9,13,$65,91,93,109,32,95,87,65,113,32,103,79,81,101,0
    .byte $FF

;===============================================================================
; SECTION: VARIETY - ALIEN DEFINITIONS (variety.asm)
;===============================================================================
GETDEF:
    lda DUCK
    beq OUTDUK
    lda ALIENS
    jmp QUAZI
OUTDUK:
    lda TED
    and #3
    tax
    lda RND,x
    and #7
    sta ALIENS
QUAZI:
    tay
    ldx TIM32,y
    ldy #0
DEFER:
    lda DEF1,x
    sta ALIBUF,y
    lda DEF2,x
    sta ALIBUF+32,y
    inx
    iny
    cpy #32
    bne DEFER
    lda #1
    sta DEFTEM
    rts

; Alien sprite data - 8 types, 32 bytes each
DEF1:
    .byte $00,$15,$6A,$7E,$7E,$76,$6A,$6B
    .byte $00,$54,$A9,$BD,$BD,$9D,$A9,$E9
    .byte $6B,$6F,$6A,$6F,$6D,$6F,$6A,$15
    .byte $E9,$F9,$A9,$F9,$79,$F9,$A9,$54
    .byte $05,$07,$16,$1E,$19,$1A,$76,$6E
    .byte $50,$D0,$94,$B4,$64,$A4,$9D,$B9
    .byte $6A,$56,$06,$1E,$1A,$79,$69,$54
    .byte $A9,$95,$90,$B4,$A4,$6D,$69,$15
    .byte $05,$16,$1A,$5A,$6A,$6E,$6E,$66
    .byte $50,$94,$A4,$A5,$A9,$B9,$B9,$99
    .byte $6A,$69,$5A,$1A,$16,$05,$00,$00
    .byte $A9,$69,$A5,$A4,$94,$50,$00,$00
    .byte $15,$6F,$7F,$55,$7B,$55,$7F,$5F
    .byte $54,$E5,$F9,$55,$B9,$55,$F9,$A5
    .byte $1F,$15,$07,$07,$07,$07,$07,$05
    .byte $E4,$54,$90,$90,$90,$90,$90,$50
    .byte $15,$7F,$6B,$7F,$7B,$7E,$1F,$05
    .byte $54,$FD,$E9,$FD,$ED,$BD,$F4,$50
    .byte $06,$01,$06,$01,$06,$1A,$19,$14
    .byte $90,$40,$90,$40,$90,$A4,$64,$14
    .byte $10,$44,$01,$16,$6A,$55,$7F,$7F
    .byte $04,$11,$40,$94,$A9,$55,$AD,$AD
    .byte $55,$6A,$16,$01,$06,$06,$06,$01
    .byte $55,$89,$94,$40,$90,$90,$D0,$40
    .byte $00,$15,$7E,$7E,$7F,$7F,$7F,$15
    .byte $00,$00,$40,$D4,$F4,$D4,$40,$00
    .byte $1B,$15,$1B,$15,$1B,$15,$7F,$15
    .byte $00,$00,$00,$00,$00,$50,$F4,$50
    .byte $00,$00,$05,$16,$1A,$5B,$6B,$6F
    .byte $00,$00,$50,$94,$A4,$E5,$E9,$F9
    .byte $6F,$6F,$6F,$6B,$5B,$1A,$16,$05
    .byte $F9,$F9,$F9,$E9,$E5,$A4,$94,$50

DEF2:
    .byte $00,$15,$6A,$7E,$76,$6B,$6B,$6F
    .byte $00,$54,$A9,$BD,$9D,$E9,$E9,$F9
    .byte $6A,$6F,$6D,$6D,$6D,$6F,$6A,$15
    .byte $A9,$F9,$79,$79,$79,$F9,$A9,$54
    .byte $05,$07,$16,$1E,$19,$1A,$16,$7E
    .byte $50,$D0,$94,$B4,$64,$A4,$94,$BD
    .byte $6A,$66,$56,$1E,$1A,$19,$19,$14
    .byte $A9,$99,$95,$B4,$A4,$64,$64,$14
    .byte $00,$00,$05,$16,$1A,$5A,$66,$6E
    .byte $00,$00,$50,$94,$A4,$A5,$99,$B9
    .byte $6E,$6A,$69,$67,$59,$1A,$16,$05
    .byte $B9,$A9,$69,$D9,$65,$A4,$94,$50
    .byte $00,$00,$00,$15,$5F,$7F,$55,$7B
    .byte $00,$00,$00,$54,$E5,$F9,$55,$B9
    .byte $55,$7F,$5F,$1F,$15,$07,$07,$05
    .byte $55,$F9,$A5,$E4,$54,$90,$90,$50
    .byte $00,$00,$15,$7F,$6B,$67,$7F,$7E
    .byte $00,$00,$54,$FD,$E9,$D9,$FD,$BD
    .byte $1F,$05,$06,$01,$06,$1A,$19,$14
    .byte $F4,$50,$90,$40,$90,$A4,$44,$14
    .byte $10,$04,$01,$16,$6A,$55,$7A,$7A
    .byte $04,$10,$40,$94,$A9,$55,$FD,$FD
    .byte $55,$6A,$16,$01,$07,$07,$07,$01
    .byte $55,$89,$94,$40,$D0,$D0,$90,$40
    .byte $00,$00,$00,$00,$00,$15,$7E,$7E
    .byte $00,$00,$00,$00,$00,$00,$40,$D4
    .byte $7F,$7F,$7F,$15,$1B,$15,$7F,$15
    .byte $F4,$D4,$40,$00,$00,$50,$F4,$50
    .byte $00,$00,$0F,$3D,$35,$F6,$D6,$DA
    .byte $00,$00,$F0,$7C,$5C,$9F,$97,$A7
    .byte $DA,$DA,$DA,$D6,$F6,$35,$3D,$0F
    .byte $A7,$A7,$A7,$97,$9F,$5C,$7C,$F0

;===============================================================================
; SECTION: COMMAND (command.asm)
;===============================================================================
COMAND:
    jsr CHKSPC
    bcc NOEDIT
    lda #1
    sta STOP
    lda VOL
    pha
    lda #0
    sta VOL
    jsr EDIT
    dec STOP
    pla
    sta VOL
NOEDIT:
    rts

CHKSPC:
    lda #$10
    ldy #$BF
    jsr KEYIT
    rts

KEYIT:
    sta $FD30
    sty $FF08
    lda $FF08
    and $FD30
    cmp $FD30
    rts

;===============================================================================
; SECTION: INKEY (inkey.asm)
;===============================================================================
INKEY:
    lda #0
    sta KEYVAL
INK1:
    lda KEYVAL
    asl a
    tax
    inc KEYVAL
    lda INKDAT,x
    tay
    lda INKDAT+1,x
    jsr KEYIT
    bcc NOINKY
    lda KEYVAL
    rts
NOINKY:
    lda KEYVAL
    cmp #29
    bne INK1
    lda #0
    rts

INKDAT:
    .byte $FD,$04,$F7,$10,$FB,$10
    .byte $FB,$04,$FD,$40,$FB,$20
    .byte $F7,$04,$F7,$20,$EF,$02
    .byte $EF,$04,$EF,$20,$DF,$04
    .byte $EF,$10,$EF,$80,$EF,$40
    .byte $DF,$02,$7F,$40,$FB,$02
    .byte $FD,$20,$FB,$40,$F7,$40
    .byte $F7,$80
    .byte $FD,$02,$FB,$80,$F7,$02
    .byte $FD,$10
    .byte $7F,$10
    .byte $FE,$02,$FE,$01

;===============================================================================
; SECTION: DECODER (decoder.asm)
;===============================================================================
DECODE:
    lda #0
    sta WORK+1
    ldx SCREEN
    lda ROMNUM,x
    sta WORK
    ldx #5
MULT:
    asl WORK
    rol WORK+1
    cpx #1
    bne NOT32
    lda WORK
    sta WORK+2
    lda WORK+1
    sta WORK+3
NOT32:
    dex
    bpl MULT
    lda WORK
    clc
    adc WORK+2
    sta SELFMD+1
    lda WORK+1
    adc WORK+3
    clc
    adc #>SCDATA
    sta SELFMD+2
    lda #<SCRBUF
    sta SL
    lda #>SCRBUF
    sta SL+1
    ldx #0
    lda #23
    sta YCOUNT
LP1:
    lda #3
    sta XCOUNT
    lda SL
    pha
    lda SL+1
    pha
LP2:
SELFMD:
    lda $FFFF,x
    ldy #0
LP3:
    asl a
    rol WORK+2
    asl a
    rol WORK+2
    pha
    lda WORK+2
    and #3
    clc
    adc #196
    sta (SL),y
    pla
    iny
    cpy #4
    bne LP3
    lda SL
    clc
    adc #4
    sta SL
    lda SL+1
    adc #0
    sta SL+1
    inx
    dec XCOUNT
    bpl LP2
    pla
    sta SL+1
    pla
    clc
    adc #40
    sta SL
    lda SL+1
    adc #0
    sta SL+1
    dec YCOUNT
    bpl LP1
    lda CLEARD
    beq TUFLUK
    lda #$00
    tax
TONE1A:
    sta SCRBUF,x
    sta SCRBUF+$100,x
    sta SCRBUF+$200,x
    sta SCRBUF+$2C0,x
    inx
    bne TONE1A
    lda #<SCRBUF
    sta SL
    lda #>SCRBUF
    sta SL+1
    ldy #15
    lda #199
TONE1:
    sta (SL),y
    dey
    bpl TONE1
    ldx #22
    ldy #0
TONE2:
    lda #199
    sta (SL),y
    lda SL
    clc
    adc #40
    sta SL
    lda SL+1
    adc #0
    sta SL+1
    dex
    bpl TONE2
    ldy #15
    lda #199
TONE3:
    sta (SL),y
    dey
    bpl TONE3
TUFLUK:
    lda #<SCRBUF
    sta LMIRR+1
    sta RMIRR+1
    lda #>SCRBUF
    sta LMIRR+2
    sta RMIRR+2
    lda #23
    sta YCOUNT
LP4:
    ldx #0
    ldy #31
LP5:
LMIRR:
    lda $FFFF,x
RMIRR:
    sta $FFFF,y
    inx
    dey
    cpy #15
    bne LP5
    lda LMIRR+1
    clc
    adc #40
    sta LMIRR+1
    sta RMIRR+1
    lda LMIRR+2
    adc #0
    sta LMIRR+2
    sta RMIRR+2
    dec YCOUNT
    bpl LP4
    ldx SCREEN
    lda DOORDT,x
    sta TEMP
    ldx #200
    and #1
    beq NDR
    stx SCRBUF+$1B8+31
    stx SCRBUF+$1E0+31
NDR:
    lda TEMP
    and #2
    beq NDL
    stx SCRBUF+$1B8
    stx SCRBUF+$1E0
NDL:
    lda TEMP
    and #4
    beq NDU
    stx SCRBUF+15
    stx SCRBUF+16
NDU:
    lda TEMP
    and #8
    beq NDD
    stx SCRBUF+$398+$F
    stx SCRBUF+$398+$10
NDD:
    rts

DOORDT:
    .byte %00001001,%00001011,%00001011,%00001011,%00001010
    .byte %00001101,%00001111,%00001111,%00001111,%00001110
    .byte %00001101,%00001111,%00001111,%00001111,%00001110
    .byte %00001101,%00001111,%00001111,%00001111,%00001110
    .byte %00000101,%00000111,%00000111,%00000111,%00000110

;===============================================================================
; SECTION: FADEIN (dumper.asm)
;===============================================================================
FADEIN:
    lda MULTI1
    pha
    lda MULTI2
    pha
    jsr CLSWIN
    lda SNDFLG
    beq NSND1
    lda #%00101111
    sta VOL
NSND1:
    lda #3
    sta COUNT
COP1:
    lda #8
    sta TEMP
    jsr RANDOM
    lda RND+1
    and #3
    sta SOU2HI
    lda RND+2
    and #$80
    sta SOU2LO
COP4:
    lda SOU2LO
    clc
    adc #16
    sta SOU2LO
    lda SOU2HI
    adc #0
    sta SOU2HI
    lda #<$C00
    sta OL
    lda #>$C00
    sta OL+1
    lda #<SCRBUF
    sta DL
    lda #>SCRBUF
    sta DL+1
    ldx COUNT
    lda COMPAR,x
    sta COPY
    lda COLTBL,x
    ldx TEMP
    ora LUMIN,x
    sta COLOUR
    lda MULTI1
    and #$F
    ora LUMIN,x
    sta MULTI1
    lda MULTI2
    and #$F
    ora LUMIN,x
    sta MULTI2
    ldx #23
COP2:
    ldy #31
COP3:
    lda (DL),y
    cmp COPY
    bne WRONG
    sta (OL),y
    lda OL
    sta CL
    lda OL+1
    sec
    sbc #4
    sta CL+1
    lda COLOUR
    sta (CL),y
WRONG:
    dey
    bpl COP3
    lda OL
    clc
    adc #40
    sta OL
    lda OL+1
    adc #0
    sta OL+1
    lda DL
    clc
    adc #40
    sta DL
    lda DL+1
    adc #0
    sta DL+1
    dex
    bpl COP2
    ldx DELLY
    jsr DELAY+2
    dec TEMP
    bmi COPO4
    jmp COP4
COPO4:
    dec COUNT
    bmi COPO1
    jmp COP1
COPO1:
    lda #0
    sta VOL
    pla
    sta MULTI2
    pla
    sta MULTI1
    rts

COMPAR:
    .byte 199, 198, 200, 197
COLTBL:
    .byte $0F, $0A, $0D, $0C
LUMIN:
    .byte $50
    .byte $70, $60, $50, $40
    .byte $30, $20, $10, $00

;===============================================================================
; SECTION: RADAR (radar-scanner.asm)
;===============================================================================
RADAR:
    ldy #7
    lda #255
WAL1:
    sta $3E50,y
    dey
    bpl WAL1
    ldx MANX
    inx
    txa
    lsr a
    lsr a
    tay
    lda BBTS,y
    pha
    lda MANY
    lsr a
    lsr a
    tay
    iny
    pla
    sta $3E50,y
    ldx #24
WAL3:
    ldy RADY,x
    lda #201
    cpx SCREEN
    bne YHTFS
    lda #202
YHTFS:
    sta $EF2,y
    cmp #201
    beq ODS
    lda #$66
    bne OSD
ODS:
    lda #$41
OSD:
    sta $EF2-$400,y
    dex
    bpl WAL3
    rts

BBTS:
    .byte $7F, $BF, $DF, $EF
    .byte $F7, $FB, $FD, $FE

RADY:
    .byte 0, 1, 2, 3, 4
    .byte 40, 41, 42, 43, 44
    .byte 80, 81, 82, 83, 84
    .byte 120, 121, 122, 123, 124
    .byte 160, 161, 162, 163, 164

;===============================================================================
; SECTION: BORDER PRINT (border.asm)
;===============================================================================
PRBDER:
    ldx #6
PRB1:
    lda #203
    sta $C20,x
    sta $FB8,x
    sta $DB0,x
    sta $EC8,x
    lda #$71
    sta $820,x
    sta $BB8,x
    dex
    bne PRB1
    lda #22
    sta TY
PRB2:
    ldx #32
    ldy TY
    jsr XY
    ldy #0
    lda #204
    sta (SL),y
    lda #$71
    sta (CL),y
    ldy #7
    lda #204
    sta (SL),y
    lda #$71
    sta (CL),y
    dec TY
    bne PRB2
    ldx #205
    stx $C20
    inx
    stx $C27
    inx
    stx $F98+32
    inx
    stx $F98+31+8
    ldx #249
    stx $DB0
    stx $EC8
    inx
    stx $DB7
    stx $ECF
    rts

;===============================================================================
; SECTION: JIGSAW CODE (jigsaw-code.asm)
;===============================================================================
PRPICE:
    ldx SCREEN
    lda JIGNUM,x
    asl a
    asl a
    asl a
    tax
    ldy #0
JIG1:
    lda $3EB8,x
    sta JIGBUF,y
    inx
    iny
    cpy #8
    bne JIG1
    lda #7
    sta COUNT
JIG2:
    lda COUNT
    tay
    asl a
    tax
    lda JIGBUF,y
    pha
    lsr a
    lsr a
    lsr a
    lsr a
    jsr XPAND
    sta $3F80,x
    sta $3F81,x
    pla
    and #$F
    jsr XPAND
    sta $3F90,x
    sta $3F91,x
    dec COUNT
    bpl JIG2
    ldx #15
JIG4:
    ldy JIGYVL,x
    lda JIGCHR,x
    sta $DC7-41,y
    lda JIGCOL,x
    sta $DC7-41-$400,y
    dex
    bpl JIG4
    rts

JIGBUF:
    .byte 0, 0, 0, 0, 0, 0, 0, 0

JIGYVL:
    .byte $00, $01, $02, $03
    .byte $28, $29, $2A, $2B
    .byte $50, $51, $52, $53
    .byte $78, $79, $7A, $7B

JIGCHR:
    .byte 205, 203, 203, 206
    .byte 204, 240, 242, 204
    .byte 204, 241, 243, 204
    .byte 207, 203, 203, 208

JIGCOL:
    .byte $71, $71, $71, $71
    .byte $71, $42, $42, $71
    .byte $71, $42, $42, $71
    .byte $71, $71, $71, $71

XPAND:
    sta WORK
    ldy #3
JIG3:
    lsr WORK
    php
    ror WORK+1
    plp
    ror WORK+1
    dey
    bpl JIG3
    lda WORK+1
    rts

GOTMES:
    lda #6
    sta TX
    lda #11
    sta TY
    lda TED
    and #7
    ora #$70
    sta PRCOL
    ldx #0
GORME1:
    txa
    pha
    lda GOTMS,x
    jsr DUBHIT
    pla
    tax
    inc TX
    inx
    cpx #19
    bne GORME1
    ldx #19
GORME2:
    lda #203
    sta $D6E+40,x
    sta $D6E+160,x
    dex
    bpl GORME2
    ldx #204
    stx $D95+40
    stx $D95+80
    stx $D95+40+21
    stx $D95+80+21
    inx
    stx $D6D+40
    inx
    stx $D6D+40+21
    inx
    stx $D6D+160
    inx
    stx $D6D+160+21
    ldx #40
    stx $DA9+40
    inx
    stx $DA9+80
    rts

GOTMS:
    .byte "YOU HAVE THIS PIECE"

TRANSF:
    ldx SCREEN
    lda JIGNUM,x
    clc
    adc #215
    sta STOPA
    ldx #0
SHVEIT:
    ldy RADY,x
    lda $E02,y
    cmp #27
    bne NKIP
    lda STOPA
    sta $E02,y
    jmp EATYRE
NKIP:
    inx
    cpx #25
    bne SHVEIT
EATYRE:
    lda #32
    sta $DC7
    sta $DC7+40
    sta $DC8
    sta $DC8+40
    jsr COLJIG
    rts

;===============================================================================
; SECTION: EDIT JIGSAW (edit-jigsaw.asm)
;===============================================================================
EDIT:
    lda #0
    sta JIGX
    sta JIGY
    sta SWAP
RELESO:
    jsr CHKSPC
    bcs RELESO
EDJIG1:
    ldx #$30
    jsr DELAY+2
    jsr CHKSPC
    bcc CARYON
YESFAB:
    jsr CHKSPC
    bcs YESFAB
    jsr COLJIG
    rts
CARYON:
    jsr JIGGY
    bit JFIRE
    bpl EDJIG1
    lda SWAP
    bne PLACE
    lda SL
    sta COPYL
    lda SL+1
    sta COPYL+1
    ldy #0
    lda (SL),y
    sta COPYCH
    sta $E01+80
    lda #1
    sta SWAP
    bne EDJIG1
PLACE:
    ldy #0
    lda (SL),y
    sta (COPYL),y
    lda COPYCH
    sta (SL),y
    lda #0
    sta SWAP
    lda #37
    sta $E01+80
    jmp EDJIG1

JIGGY:
    ldx JIGX
    ldy JIGY
    bit JLEFT
    bpl LENO
    cpx #0
    beq LENO
    dex
LENO:
    bit JRIGHT
    bpl RINO
    cpx #4
    beq RINO
    inx
RINO:
    bit JUP
    bpl UPNO
    cpy #0
    beq UPNO
    dey
UPNO:
    bit JDOWN
    bpl DONO
    cpy #4
    beq DONO
    iny
DONO:
    stx JIGX
    sty JIGY
    jsr JIGXY
    jsr COLJIG
    lda TED
    and #%11110111
    ldy #0
    sta (CL),y
    rts

JIGXY:
    txa
    clc
    adc #34
    tax
    tya
    clc
    adc #12
    tay
    jsr XY
    rts

COLJIG:
    ldx #0
    stx NOCORR
    lda #215
    sta JIGNO
CJIG1:
    ldy RADY,x
    lda $E02,y
    cmp #27
    bne NOEMP
    lda #$64
    bne COLIT
NOEMP:
    cmp JIGNO
    bne NOCOR
    inc NOCORR
    lda #$71
    bne COLIT
NOCOR:
    lda #$10
COLIT:
    sta $A02,y
    inc JIGNO
    inx
    cpx #25
    bne CJIG1
    lda NOCORR
    cmp #25
    bne NTFIND
    jmp UPLEVL
NTFIND:
    rts

PRJIG:
    ldx #24
    lda #239
    sta CHAR
PRJIG1:
    ldy RADY,x
    lda CHAR
    sta $E02,y
    dec CHAR
    dex
    bpl PRJIG1
    rts

;===============================================================================
; SECTION: HIGH PRINT (high-print.asm)
;===============================================================================
PRSCRN:
    ldx #<BITS
    ldy #>BITS
    jsr PWINT
    ldx #13
    lda #42
POOPS:
    sta $C81+40,x
    dex
    bpl POOPS
    rts

PRHISC:
    lda #0
    sta NUMB
HISC1:
    lda #0
    sta MENATW
    lda NUMB
    asl a
    clc
    adc #5
    sta TY
    lda #6
    sta TX
    lda NUMB
    clc
    adc #$31
    pha
    and #7
    ora #$70
    sta PRCOL
    pla
    jsr DUBHIT
    inc TX
    inc TX
    lda NUMB
    asl a
    asl a
    asl a
    asl a
    tax
    lda #5
    sta COUNT
WALT:
    txa
    pha
    lda HISTBL,x
    sta WALL
    cmp #'0'
    bne FOO2
    lda MENATW
    bne FOO3
    lda #32
    bne FOO1
FOO2:
    lda #1
    sta MENATW
FOO3:
    lda WALL
FOO1:
    jsr DUBHIT
    pla
    tax
    inx
    inc TX
    dec COUNT
    bpl WALT
    inc TX
    lda #9
    sta COUNT
WILT:
    txa
    pha
    lda HISTBL,x
    jsr DUBHIT
    pla
    tax
    inx
    inc TX
    dec COUNT
    bpl WILT
    inc NUMB
    lda NUMB
    cmp #5
    bne HISC1
    rts

PWINT:
    stx ALTER1+1
    stx ALTER2+1
    stx ALTER3+1
    stx ALTER4+1
    sty ALTER1+2
    sty ALTER2+2
    sty ALTER3+2
    sty ALTER4+2
    ldx #0
ALTER1:
    lda $FFFF,x
    cmp #$FF
    beq NZTT
    sta TX
    inx
ALTER2:
    lda $FFFF,x
    sta TY
    inx
    txa
    pha
    ldx TX
    ldy TY
    jsr XY
    pla
    tax
ALTER4:
    lda $FFFF,x
    sta PRCOL
    inx
    ldy #0
ALTER3:
    lda $FFFF,x
    beq NZT
    sta (SL),y
    lda PRCOL
    sta (CL),y
    iny
    inx
    bne ALTER3
NZT:
    inx
    bne ALTER1
NZTT:
    rts

BITS:
    .byte 3,17,$66,3,$F,$E,$14,$12,$0F,$0C,0
    .byte 5,18,$76,$3C,$26,$3E,0
    .byte 5,20,$79,136,137,138,0
    .byte 5,21,$79,139,140,141,0
    .byte 14,17,$77,74,80,98,72,0
    .byte 14,18,$54,75,81,99,73,0
    .byte 15,19,$77,102,92,0
    .byte 15,20,$54,103,93,0
    .byte 14,21,$77,94,86,64,112,0
    .byte 14,22,$54,95,87,65,113,0
    .byte 24,17,$66,$13,$0F,$15,$0E,$04,0
    .byte 25,18,$66,$3C,$27,$3E,0
    .byte 25,20,$71,142,143,144,0
    .byte 25,21,$71,145,146,147,0
    .byte 9,2,$64,70,92,98,84,100,32,32,70,80,86,72,88,88,64,0
    .byte 9,3,$44,71,93,99,85,101,32,32,71,81,87,73,89,89,65,0
    .byte $FF

DUBHIT:
    and #$3F
    cmp #32
    bne NTSPC
    rts
NTSPC:
    cmp #$30
    bcc LETTER
    and #$0F
    asl a
    clc
    adc #116
    bne BYPASS
LETTER:
    asl a
    clc
    adc #62
BYPASS:
    pha
    ldx TX
    ldy TY
    jsr XY
    pla
    ldy #0
    sta (SL),y
    pha
    lda PRCOL
    sta (CL),y
    pla
    clc
    adc #1
    ldy #40
    sta (SL),y
    lda PRCOL
    and #$0F
    ora #$60
    sta (CL),y
    rts

;===============================================================================
; SECTION: SCREEN INIT (screen-init.asm)
;===============================================================================
SETWIN:
    ldx #<WELCH
    ldy #>WELCH
    jsr PWINT
    lda #$79
    sta $965
    sta $966
    sta $965+40
    sta $966+40
    rts

SLUDGE:
    ldx #31
QUEEN1:
    lda #37
    sta $C00,x
    sta $F98,x
    dex
    bpl QUEEN1
    lda #23
    sta TY
QUEEN2:
    ldx #0
    ldy TY
    jsr XY
    ldy #0
    lda #37
    sta (SL),y
    lda #$11
    sta (CL),y
    lda #37
    ldy #31
    sta (SL),y
    lda #$11
    sta (CL),y
    dec TY
    bne QUEEN2
    ldx #31
    ldy #0
QUEEN3:
    lda TCOL,y
    sta $800,y
    sta $BB7-31,x
    iny
    dex
    bpl QUEEN3
    rts

TCOL:
    .byte $07,$17,$27,$37
    .byte $47,$57,$67,$77
    .byte $06,$16,$26,$36
    .byte $46,$56,$66,$76
    .byte $05,$15,$25,$35
    .byte $45,$55,$65,$75
    .byte $02,$12,$22,$32
    .byte $42,$52,$62,$72

WELCH:
    .byte 33,1,$65,100,68,92,98,72,213,0
    .byte 33,2,$45,101,69,93,99,73,214,0
    .byte 33,3,$65,32,32,32,32,32,$30,0
    .byte 33,4,$53,$C,9,$16,5,$13,$3A,0
    .byte 35,5,$63,$33,0
    .byte 33,6,$54,1,$C,9,5,$E,$13,0
    .byte 35,7,$64,32,32,0
    .byte 33,8,$61,66,92,88,66,44,45,0
    .byte 33,9,$41,67,93,89,67,46,47,0
    .byte 33,11,$64,10,9,7,19,1,$17,0
    .byte 33,19,$77,$D,0
    .byte 33,20,$77,$1,0
    .byte 33,21,$77,$10,0
    .byte $FF

;===============================================================================
; SECTION: ALTERABLES (alterables.asm)
;===============================================================================
JOYSEL = $C3

ALTER:
    lda #$10
    ldy #$FE
    jsr KEYIT
    bcc ALT1
    lda JOYSEL
    eor #1
    sta JOYSEL
    ldx #47
ALT2:
    lda $3C40,x
    pha
    lda JKCHAR,x
    sta $3C40,x
    pla
    sta JKCHAR,x
    dex
    bpl ALT2
ALT1:
    lda #$20
    ldy #$FE
    jsr KEYIT
    bcc ALT3
    lda SNDFLG
    eor #1
    sta SNDFLG
    ldx #47
ALT4:
    lda $3C70,x
    pha
    lda SQCHAR,x
    sta $3C70,x
    pla
    sta SQCHAR,x
    dex
    bpl ALT4
ALT3:
    rts

JKCHAR:
    .byte $05,$16,$1A,$1A,$16,$05,$07,$07
    .byte $40,$50,$D0,$90,$50,$40,$40,$41
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $07,$05,$1F,$7F,$7F,$55,$7F,$15
    .byte $46,$55,$FF,$FF,$FF,$55,$FE,$55
    .byte $40,$50,$A4,$E9,$F9,$55,$A9,$54

SQCHAR:
    .byte $18,$0C,$06,$03,$01,$00,$00,$00
    .byte $00,$00,$00,$01,$83,$C6,$6C,$38
    .byte $30,$60,$C0,$80,$00,$00,$00,$00
    .byte $00,$00,$01,$03,$06,$0C,$18,$10
    .byte $6C,$C6,$83,$01,$00,$00,$00,$00
    .byte $00,$00,$00,$80,$C0,$60,$30,$10

;===============================================================================
; SECTION: MAGNIFICENT (magnificent.asm)
;===============================================================================
GLOPPY:
    sei
    jsr CLSWIN
    jsr COPYBM
    ldx #1
    stx STOP
    stx TITLE
    dex
    stx MANX
    stx MANY
    stx SCREEN
    jsr SETUP
    jsr SETIRQ
    jsr RADAR
    jsr CLRJIG              ; Clear jigsaw area on title screen
    jsr PRBDER
    jsr SLUDGE
    jsr HIGH
    jsr SETWIN
    jsr PRSCRN
    jsr PRHISC
    lda #$22
    sta MULTI2
GLLOO:
    jsr ALTER
    ldx #$30
    jsr DELAY+2
    bit JFIRE
    bpl GLLOO
    lda #0
    sta TITLE
    sta LEVEL
    lda #3
    sta LIVES
    jmp PLAY

;-------------------------------------------------------------------------------
; CLRJIG - Clear jigsaw display area (25 positions)
;-------------------------------------------------------------------------------
CLRJIG:
    ldx #24
CLRJLP:
    ldy RADY,x
    lda #32
    sta $E02,y
    dex
    bpl CLRJLP
    rts

;===============================================================================
; SECTION: GAME OVER (game-over.asm)
;===============================================================================
GMEOVR:
    jsr CLSWIN
    ldx #<ENDER
    ldy #>ENDER
    jsr PWINT
    lda #80
    sta TEMP
    ldy #0
ENDLOP:
    ldx #10
    lda RND
    and #%11110111
    ora #%00110000
ENTIT:
    sta $9C2,x
    sta $9C2+40,x
    dex
    bpl ENTIT
    dey
    bne ENDLOP
    dec TEMP
    bne ENDLOP
    ldx #5
LET9:
    lda SCOREP,x
    cmp #32
    bne LET8
    lda #$30
LET8:
    sta SIKBUF,x
    dex
    bpl LET9
    jmp GLOPPY

ENDER:
    .byte 11,11,$71,76,64,88,72,32,32,92,106,72,98,0
    .byte 11,12,$71,77,65,89,73,32,32,93,107,73,99,0
    .byte $FF

;===============================================================================
; SECTION: WORK HIGH (work-high.asm)
;===============================================================================
HIGH:
    lda #0
    sta HISPNT
    sta POSITN
HLP1:
    lda HISPNT
    clc
    adc #6
    tax
    sec
    ldy #6
HLP2:
    lda HISTBL-1,x
    sbc SIKBUF-1,y
    dex
    dey
    bne HLP2
    bcc ITSIN
    lda HISPNT
    clc
    adc #16
    sta HISPNT
    inc POSITN
    lda POSITN
    cmp #5
    bne HLP1
    rts

ITSIN:
    jsr PRENTR
    jsr MVESCR
    jsr CLSWIN
    rts

MVESCR:
    lda POSITN
    pha
    asl a
    asl a
    asl a
    asl a
    sta INCNT
PLAC:
    cmp #4
    beq INLAST
    ldx #64
MOVESC:
    lda HISTBL,x
    sta HISTBL+16,x
    dex
    cpx INCNT
    bne MOVESC
INLAST:
    ldx INCNT
    ldy #0
MVT1:
    lda SIKBUF,y
    sta HISTBL,x
    inx
    iny
    cpy #6
    bne MVT1
    ldx #10
LET0:
    lda #32
    sta $EB3,x
    lda #$51
    sta $EB3-$400,x
    dex
    bpl LET0
    ldy #0
INPUT:
    sty LETCNT
    lda #37
    sta $EB3,y
    ldx #$30
    jsr DELAY+2
INPUT1:
    jsr INKEY
    beq INPUT1
    ldy LETCNT
    cmp #$1C
    beq LETEXT
    cmp #$1D
    bne LET1
    cpy #0
    beq INPUT
    lda #32
    sta $EB3,y
    dey
    jmp INPUT
LET1:
    cpy #10
    beq INPUT
    cmp #$1B
    bne LET2
    lda #32
LET2:
    sta $EB3,y
    iny
    jmp INPUT
LETEXT:
    lda INCNT
    clc
    adc #6
    tay
    ldx #0
LET4:
    lda $EB3,x
    cmp #37
    bne LET5
    lda #32
LET5:
    sta HISTBL,y
    iny
    inx
    cpx #10
    bne LET4
    rts

PRENTR:
    ldx #<TEXT
    ldy #>TEXT
    jsr PWINT
    ldx #15
QUINCY:
    lda #42
    sta $CD0,x
    cpx #10
    bcs QUINC1
    sta $EDB,x
QUINC1:
    dex
    bpl QUINCY
    ldx #5
QUINC3:
    lda SCOREP,x
    sta $D29,x
    lda #$52
    sta $929,x
    dex
    bpl QUINC3
    rts

TEXT:
    .byte 8,3,$77,68,92,90,76,98,64,102,104,86,64,102,80,92,90,100,40,0
    .byte 8,4,$67,69,93,91,77,99,65,103,105,87,65,103,81,93,91,101,41,0
    .byte 3,7,$73,25,15,21,18,32,19,3,15,18,5,32,15,6,32,48,48,48,48,48,48
    .byte 32,9,19,32,9,14,0
    .byte 10,9,$73,102,78,72,32,102,92,94,32,74,80,106,72,0
    .byte 10,10,$63,103,79,73,32,103,93,95,32,75,81,107,73,0
    .byte 5,13,$72,94,86,72,64,100,72,32,72,90,102,72,98,32
    .byte 112,92,104,98,32,90,64,88,72,0
    .byte 5,14,$62,95,87,73,65,101,73,32,73,91,103,73,99,32
    .byte 113,93,105,99,32,91,65,89,73,0
    .byte $FF

;===============================================================================
; SECTION: HALL OF FAME (hall-of-fame.asm)
;===============================================================================
HISAMP:
    .byte "000100  GREMLIN "

INHISC:
    ldy #0
INH1:
    ldx #0
INH2:
    lda HISAMP,x
    sta HISTBL,y
    iny
    inx
    cpx #16
    bne INH2
    cpy #80
    bne INH1
    rts

;===============================================================================
; SECTION: MESSAGE (whooppee-message.asm)
;===============================================================================
MESST:
    .byte "     DORKS DILEMMA "
    .byte "BY MICRO "
    .byte "PROJECTS LTD HAVE YOU PLAYED XARGON WARS"
    .byte ";PETALS OF DOOM OR TYCOON TEX?"
    .byte $FF

;===============================================================================
; SECTION: EXTRA MEMORY TABLES (runtime addresses, not in PRG file)
; These tables use free RAM at $0400-$07BF (screen buffer area)
; Total needed: 64+25+25+25+25+80+1 = 245 bytes
;===============================================================================
ALIBUF  = $0400             ; 64 bytes: Alien buffer
JIGNUM  = $0440             ; 25 bytes: Jigsaw numbers
ROMNUM  = $0459             ; 25 bytes: Room numbers
RADBUF  = $0472             ; 25 bytes: Radar buffer
GOTBIT  = $048B             ; 25 bytes: Got bit flags
HISTBL  = $04A4             ; 80 bytes: High score table
LEVEL   = $04F4             ; 1 byte: Current level

;===============================================================================
; CHARACTER SET DATA - Custom graphics (256 chars × 8 bytes = 2048 bytes)
; Placed in CHARS segment to load at $3800
;===============================================================================
.segment "CHARS"
CHARSET:
    .incbin "chars.bin"

;===============================================================================
; END OF SOURCE
;===============================================================================
