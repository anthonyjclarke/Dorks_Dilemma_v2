; >s:designer
; put "designer"
;
; screen designer
;
.lib main-vars*
;
*=$02
;
sl     .word 0
;
xpos   .byte 0
ypos   .byte 0
;
left   .byte 0
right  .byte 0
up     .byte 0
down   .byte 0
fire   .byte 0
;
count  .byte 0
;
xx     .byte 0
yy     .byte 0
;
temp   .byte 0
;
onchar .byte 0
;
xcount .byte 0
ycount .byte 0
;
bits   .byte 0
intype .byte 0
;
anitem .byte 0
brkcnt .byte 0
;
;
;
;
;
*=$2000
;
;
lda #$c0
sta $ff12
lda #$38
sta $ff13
lda #$98
sta $ff07
;
lda #$00
sta multi1
;
lda #$46
sta multi2
;
lda #$05
jsr $ffd2
;
lda #$93
jsr $ffd2
;
jsr setirq
;
ldx #0
;
lp1
;
lda #$71
sta $800,x
sta $900,x
sta $a00,x
sta $b00,x
;
lda #32
sta $c00,x
sta $d00,x
sta $e00,x
sta $f00,x
;
inx
bne lp1
;
lda #$11
sta $ff15
sta $ff19
;
ldx #23
;
lda #<$c00
sta sl
;
lda #>$c00
sta sl+1
;
ldx #23
;
lp2
;
ldy #15
;
lp3
;
lda #196
sta (sl),y
;
dey
bpl lp3
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
bpl lp2
;
lda #1
sta xpos
sta ypos
;
; edit pos.
;
lda #196
sta onchar
;
jsr change
;
lp4
;
; main loop
;
jsr movcsr ;* move cursor
;
jsr prog
;
jsr mirror
;
jsr delay
;
jmp lp4
;
brk
;
;
;
;
;******
;
mirror
;
lda #<$c00
sta ml+1
sta mr+1
lda #>$c00
sta ml+2
sta mr+2
;
lda #23
sta count
;
mir1
;
ldx #0
ldy #31
;
mir2
;
ml lda $ffff,x
mr sta $ffff,y
;
inx
dey
cpy #15
bne mir2
;
lda ml+1
clc
adc #40
sta ml+1
sta mr+1
;
lda ml+2
adc #0
sta ml+2
sta mr+2
;
dec count
bpl mir1
;
rts
;
;---------
;
movcsr
;
lda #$4a
sta xtra
;
lda #$fd
sta $ff08
;
lda $ff08
eor #$ff
bne naye
;
lda #$ea
sta xtra
;
lda #$fa
sta $ff08
;
lda $ff08
eor #$ff
;
bne naye
;
rts
;
naye
;
ror a
ror up
;
ror a
ror down
;
ror a
ror left
;
ror a
ror right
;
lsr a
lsr a
lsr a
;
xtra .byte $ff
;
ror fire
;
lda xpos
sta xx
;
lda ypos
sta yy
;
bit left
bpl nleft
;
lda xpos
beq nleft
;
dec xpos
;
nleft
;
bit right
bpl nright
;
lda xpos
cmp #15
beq nright
;
inc xpos
;
nright
;
bit down
bpl ndown
;
lda ypos
cmp #23
beq ndown
;
inc ypos
;
ndown
;
bit up
bpl nup
;
lda ypos
beq nup
;
dec ypos
;
nup
;
bit fire
bpl nfire
;
inc onchar
lda onchar
and #3
;
clc
adc #196
;
sta onchar
;
jsr change
;
nfire
;
ldx xx
ldy yy
lda onchar
jsr print
;
lda sl+1
sec
sbc #4
sta sl+1
;
lda onchar
and #3
clc
adc #$79
;
sta (sl),y
;
ldx xpos
ldy ypos
lda #'*
jsr print
;
ldx #0
;
fil1
;
lda $800,x
and #$7
ora #$38
sta $800,x
;
lda $900,x
and #$7
ora #$38
sta $900,x
;
lda $a00,x
and #$7
ora #$38
sta $a00,x
;
lda $b00,x
and #$7
ora #$38
sta $b00,x
;
inx
bne fil1
;
lda sl+1
sec
sbc #4
sta sl+1
;
lda #$71
sta (sl),y
;
rts
;
;---------
;
print
;
sta temp
;
tya
asl a
tay
;
lda scr,y
sta sl
lda scr+1,y
sta sl+1
;
txa
tay
;
lda temp
sta (sl),y
;
rts
;
;
scr
;
.word $c00,$c28,$c50,$c78,$ca0
.word $cc8,$cf0,$d18,$d40,$d68
.word $d90,$db8,$de0,$e08,$e30
.word $e58,$e80,$ea8,$ed0,$ef8
.word $f20,$f48,$f70,$f98,$fc0
;
;
;-------
;
delay
;
ldx #$40
ldy #$00
;
del
;
nop
;
dey
bne del
;
dex
bne del
;
rts
;
;-------------
change
;
ldx #7
;
onl
;
lda onlp,x
and #$3f
sta $c70,x
;
dex
bpl onl
;
lda onchar
sta $c77
;
rts
;
onlp .byte 'char = '
;
;
;-----------------------------
;
;
;
prog
;
lda #$08
ldy #$fe
jsr keyit
bcc noch
;
ldx xpos
ldy ypos
lda onchar
jsr print
;
lda #<$c00
sta sl
lda #>$c00
sta sl+1
;
ldx #0
;
lda #23
sta ycount
;
prloop
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
pr1
;
lda #0
sta bits
;
ldy #3
;
pr2
;
lda (sl),y
and #3
;
lsr a
ror bits
lsr a
ror bits
;
dey
bpl pr2
;
lda bits
sta $2800,x
;
inx
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
dec xcount
bpl pr1
;
pla
sta sl+1
;
pla      ;* sl
clc
adc #40
sta sl
;
lda sl+1
adc #0
sta sl+1
;
dec ycount
bpl prloop
;
lda #$05
jsr $ffd2
;
brk
;
noch
;
rts
;
keyit
;
sty $fd30
sty $ff08
and $ff08
;
bne rtty
;
sec
rts
;
rtty
;
clc
rts
;
;--------------
;
.lib des-irq*
.lib des-ani*
;
;
;
;
.end
