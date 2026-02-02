; >s:move-pixel
; put"move-pixel"
;
;
movemn
;
; move the man (in pixels !!)
;
jsr print  ;* print new man
;
jsr mnmove ;* move him
;
ldx chkx
ldy chky
jsr check    ;* check
;
lda hit
beq itsok    ;* no hit
;
jsr death    ;* hit alien ?
;
lda dead     ;* died ?
bne esc
;
jsr chgrom   ;* change room ?
;
lda newrom
bne esc
;
; are we going to change room ?
;
lda trx
sta manx
lda try
sta many
;
lda temdir
sta dir
;
lda #0
sta going
sta xpix
sta ypix
sta hit
;
itsok
;
jsr uppixe ;* move pixels
;
esc
;
rts
;
;---------***********----------
;
print
;
ldx trx
ldy try
dey
jsr xy
;
jsr bugrub ;* rub him out
;
; ldx #13   ;* to get rid of bug!
;
; ruub1
;
; ldy yrub,x
;
; lda (sl),y
; cmp #148
; bcc dntrub
;
; cmp #148+48
; bcs dntrub
;
; lda #196
; sta (sl),y
;
; dntrub
;
; dex
; bpl ruub1
;
ldx manx
ldy many
jsr xy
;
lda ypix
bne noway
;
lda xpix
beq normpr
;
noway
;
lda #0
sta keepon  ;* moving again
sta antfag
;
lda dir
cmp #3
bcs prnty
;
ldx xpix
lda time6,x
;
clc
adc #148  ;* base char
;
sta char
;
ldx #0
;
prt1
;
ldy waly,x
lda char
sta (sl),y
;
inc char
;
lda #$79
sta (cl),y
;
inx
cpx #6
bne prt1
;
rts
;
time6  .byte 0,6,12,18
;
yrub
;
.byte 0,1,39,40,41,42,43
.byte 79,80,81,82,83
.byte 120,121
;
;
normpr
;
lda antfag ;* !!
bne qrump
;
ldx #1
stx keepon
stx antfag
;
dex
stx mancnt
;
lda #10
sta gloptm
;
; set up glop animation when stop.
;
qrump
;
lda dir
and #3
beq normp
;
ldx manx
inx
ldy many
dey
jsr xy
;
normp
;
ldx #3
;
genars
;
lda achar,x
ldy ychin,x
;
sta (sl),y
;
lda #$79
sta (cl),y
;
dex
bpl genars
rts
;
achar .byt 28,29,30,31
ychin .byt 40,41,80,81
;
;
;****************************
;
prnty
;
ldx ypix
lda time6,x
clc
adc #148+24      ;* base char + 24
sta char
;
ldx #0
;
prt2
;
ldy yval2,x
lda char
sta (sl),y
;
lda #$79
sta (cl),y
;
inc char
inx
cpx #6
bne prt2
;
rts
;
yval2
;
.byte 0,1,40,41,80,81
;
;*********
;
mnmove
;
lda xpix
bne getout ;* cant go left/right
;
lda ypix
bne getout ;* cant go up/down
;
lda manx
sta trx
;
lda many
sta try
;
lda dir
sta temdir
;
bit jfire ;* lay a bomb !
bpl nolay
;
jsr bomb  ;* start one if you can
;
nolay
;
bit jleft
bpl nleft
;
lda dir
and #$0c
beq broun3
;
inc many
dec manx
;
broun3
;
ldx #1
stx dir    ;* 1 - left
stx going
;
dex
stx xpix
stx rustic
;
ldx manx
stx chkx
;
ldy many
sty chky
;
getout     ;* an exit point
;
rts
;
nleft
;
bit jright
bpl nright
;
inc manx
;
lda dir
and #$0c
beq broun4
;
dec manx
inc many
;
broun4
;
ldx #3
stx xpix
;
dex
stx dir     ;* 2 - right
;
dex
stx rustic
stx going
;
ldy many
sty chky
;
ldx manx
inx
stx chkx
;
rts
;
nright
;
bit jup ;* up ?
bpl nup
;
lda dir
and #$03
beq bround
;
inc manx
dec many
;
bround
;
lda #4
sta dir     ;* 4 - up
;
ldx #1
stx going
;
dex
stx rustic
stx ypix
;
ldx manx
stx chkx
;
ldy many
sty chky
;
rts
;
nup
;
bit jdown  ;* down ?
bpl getout
;
lda dir
and #$03
beq broun2
;
dec many
inc manx
;
broun2
;
lda #8     ;* 8 = down
sta dir
;
lda #3
sta ypix
;
lda #1
sta going
sta rustic
;
inc many
;
ldx manx
stx chkx
;
ldy many
iny
sty chky
;
rts
;
;-------------------------------
;
uppixe
;
lda going
beq sit
;
lda rustic
beq kill
;
lda #0
sta rustic
;
sit
;
rts
;
kill
;
lda #1
bit dir
bne mvelft
;
asl a        ; acc = 2
bit dir
bne mverit
;
asl a        ; acc = 4
bit dir
bne mveup
;
asl a        ; acc = 8
bit dir
bne mvedwn
;
; should never get here !
;
mvelft
;
inc xpix
lda xpix
tay
and #3
sta xpix
;
cpy #4
beq stopl
;
rts
;
stopl
;
lda #0
sta xpix
sta going
;
dec manx
;
rts
;
mverit
;
dec xpix
lda xpix
tay
and #3
sta xpix
;
cpy #$ff
beq stopr
;
rts
;
stopr
;
lda #0
sta xpix
sta ypix
sta going
;
rts
;
mvedwn
;
dec ypix
lda ypix
tay
;
and #3
sta ypix
;
cpy #$ff
beq stopr
;
rts
;
mveup
;
inc ypix
lda ypix
tay
;
and #3
sta ypix
;
cpy #4
beq stopu
;
rts
;
stopu
;
lda #0
sta ypix
sta going
;
dec many
;
rts
;
;-------------------------------
;
; rub out all alien (sl) must
;
; point to tl-2
;
bugrub
;
ldx #13   ;* to get rid of bug!
;
ruub1
;
ldy yrub,x
;
lda (sl),y
;
cmp #148+48
bcs dntrub
;
cmp #148
bcs dorbut
;
cmp #32
bcs dntrub
;
dorbut
;
lda #196
sta (sl),y
;
dntrub
;
dex
bpl ruub1
;
;
rts
;
;
;
;
;
;
.end
