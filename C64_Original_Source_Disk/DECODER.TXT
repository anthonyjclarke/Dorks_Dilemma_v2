; >s:decoder
; put "decoder"
;
; decodes the screen number held
; in 'screen' and leaves the
; screen in the buffer 'scrbuf'
; ready to be copied onto the
; screen.
;
decode
;
lda #0
sta work+1 ;* clear from last time
;
ldx screen
lda romnum,x
sta work
;
; acc = 0 to 24
;
ldx #5
;
mult
;
asl work
rol work+1
;
cpx #1
bne not32
;
lda work
sta work+2
lda work+1
sta work+3
;
not32
;
dex
bpl mult
;
lda work
clc
adc work+2
sta selfmd+1
;
lda work+1
adc work+3
clc
adc #>scdata   ;* screen data
sta selfmd+2
;
; selfmd has been set up (by
; self altering code ) to point
; to the start of the compressed
; data for that screen.
;
;
lda #<scrbuf
sta sl
lda #>scrbuf
sta sl+1
;
ldx #0
;
lda #23
sta ycount
;
lp1
;
lda #3
sta xcount
;
lda sl
pha
;
lda sl+1
pha
;
lp2
;
selfmd lda $ffff,x
;
ldy #0
;
lp3
;
asl a
rol work+2
asl a
rol work+2
;
pha
;
lda work+2
and #3
clc
adc #196    ;* base char
;
sta (sl),y
;
pla
;
iny
cpy #4
bne lp3
;
lda sl
clc
adc #4
sta sl
;
lda sl+1
adc #0
sta sl+1
;
inx        ;* next data
;
dec xcount
bpl lp2
;
pla
sta sl+1
;
pla
;
clc
adc #40
sta sl
;
lda sl+1
adc #0
sta sl+1
;
dec ycount
bpl lp1
;
lda cleard   ;* cleared this room?
beq tufluk   ;* no !
;
lda #$00
tax
;
tone1a
;
sta scrbuf,x
sta scrbuf+$100,x
sta scrbuf+$200,x
sta scrbuf+$2c0,x
;
inx
bne tone1a
;
; clear all crap
;
lda #<scrbuf
sta sl
lda #>scrbuf
sta sl+1
;
ldy #15
lda #199     ;* best char
;
tone1
;
sta (sl),y
dey
bpl tone1    ;* roof
;
ldx #22      ;* no. of lines
ldy #0
;
tone2
;
lda #199
sta (sl),y
;
lda sl
clc
adc #40
sta sl
;
lda sl+1
adc #0
sta sl+1
;
dex
bpl tone2
;
; thats the left side (remember
; that it mirror's it later !)
;
ldy #15
lda #199
;
tone3
;
sta (sl),y
dey
bpl tone3
;
; created a blank room (i hope)
;
tufluk
;
; now mirror it
;
lda #<scrbuf
sta lmirr+1
sta rmirr+1
;
lda #>scrbuf
sta lmirr+2
sta rmirr+2
;
lda #23
sta ycount
;
lp4
;
ldx #0
ldy #31
;
lp5
;
lmirr lda $ffff,x
rmirr sta $ffff,y
;
inx
dey
cpy #15
bne lp5
;
lda lmirr+1
clc
adc #40
sta lmirr+1
sta rmirr+1
;
lda lmirr+2
adc #0
sta lmirr+2
sta rmirr+2
;
dec ycount
bpl lp4
;
; it's done - c'est fini !
;
; - no !! put the doors in !
;
ldx screen
lda doordt,x
sta temp
;
ldx #200 ;* door char
;
and #1
beq ndr
;
stx scrbuf+$1b8+31
stx scrbuf+$1e0+31
;
ndr
;
lda temp
and #2
beq ndl
;
stx scrbuf+$1b8
stx scrbuf+$1e0
;
ndl
;
lda temp
and #4
beq ndu
;
stx scrbuf+15
stx scrbuf+16
;
ndu
;
lda temp
and #8
beq ndd
;
stx scrbuf+$398+$f
stx scrbuf+$398+$10
;
ndd
;
;
;
rts
;
;---------------------------
;
doordt
;
; data as follows :-
;
; bit #76543210
;
;          dulr
;
.byte %00001001
.byte %00001011
.byte %00001011
.byte %00001011
.byte %00001010
;
.byte %00001101
.byte %00001111
.byte %00001111
.byte %00001111
.byte %00001110
;
.byte %00001101
.byte %00001111
.byte %00001111
.byte %00001111
.byte %00001110
;
.byte %00001101
.byte %00001111
.byte %00001111
.byte %00001111
.byte %00001110
;
.byte %00000101
.byte %00000111
.byte %00000111
.byte %00000111
.byte %00000110
;
;
;
;
;
.end
