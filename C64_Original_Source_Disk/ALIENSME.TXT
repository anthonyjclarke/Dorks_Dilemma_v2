; >s:aliens-mega/code
; put "aliens-mega/code"
;
; all the alien stuff
;
inital
;
ldx #7
;
alpo1
;
lda #$ff
sta irqprt,x
sta irqrub,x
sta alipos,x
;
dex
bpl alpo1
;
ldx #3
lda #1
;
alap2
;
sta alitim,x
;
dex
bpl alap2
;
lda nokild  ;* a check in case
cmp alkill  ;* this is called when
bne mjore   ;* all aliens killed
;
rts         ;*
;
mjore
;
; set them up
;
ldx #7
;
al11
;
lda alstat,x
sta alipos,x   ;* rub x,y 's
;
dex
bpl al11
;
pochin
;
jsr getdef     ;* char type ?
;
lda #1
sta alycnt
;
rts
;
alstat .byte 1,1,29,1,1,21,29,21
;
; all starting positions
;
;--------------------------------
;
mveali
;
; called by the basic loop
;
; move them
;
lda #0
sta prtals     ;* dont print
;
ldx #7
;
alim1
;
lda irqprt,x
sta irqrub,x
;
dex
bpl alim1
;
; transfer print postions to
; rub postions
;
ldx manx
ldy many
;
lda dir
and #3
beq irro1
;
inx
;
irro1
;
lda dir
and #$0c
beq irro2
;
iny
;
irro2
;
stx compx
sty compy
;
; tl of man
;
lda #3
sta alicnt  ;* alien count
;
alim2
;
lda alicnt
asl a
tax
;
lda alipos,x
cmp #$ff    ;* is he dead ?
beq knaked  ;* yes.
;
sta alx
;
lda alipos+1,x
sta aly
;
; x & y positions got
;
txa
pha
;
jsr mvehim     ;* move him
;
pla
pha
tax
;
lda aly
sta alipos+1,x ;* new y pos.
tay
;
lda alx
sta alipos,x   ;* new x pos.
tax
;
jsr xy
;
pla
tax
;
lda sl
sta irqprt,x
;
lda sl+1
sta irqprt+1,x
;
; screen address in irq table
;
jmp m25
;
knaked
;
lda #$ff
;
sta irqprt,x
sta irqprt+1,x
;
stx point
;
ldx alicnt
dec alitim,x    ;* start it ?
;
bne m25         ;* not ready yet
;
ldx point
;
lda alstat,x    ;* start pos
sta alipos,x
;
lda alstat+1,x
sta alipos+1,x
;
; start him again
;
m25             ;* by-pass
;
dec alicnt
bpl alim2
;
; all done
;
lda #1
sta prtals
;
rts
;------------------------------
;
mvehim
;
; move the aliens at alx,aly
;
;
lda alx
cmp compx   ;* x pos. the same ?
beq tryyxs
;
lda alx
sec
sbc compx
;
bmi mle1
;
jsr alleft
;
lda move
bne mved
;
mle1
;
jsr alrigt
;
lda move
bne mved  ;* he's made a decision
;
tryyxs
;
lda aly
sec
sbc compy
bmi mle3
;
jsr alup
;
lda move
bne mved
;
mle3
;
jsr aldown
;
;
mved
;
lda #0
sta move
;
rts
;
;******************************
;
; do all the trying to move
;
alleft
;
; try left
;
ldx alx
dex
ldy aly
;
jsr chkalx ;* check pos x axis
;
lda move
beq cle
;
dec alx
;
; was allowd to go left
;
cle
;
rts
;
;-----------------------
;
alrigt
;
; try right
;
ldx alx
inx
inx
ldy aly
;
jsr chkalx ;* check pos x axis
;
lda move
beq cr
;
inc alx
;
; allowd to go right
;
cr
;
rts
;
;***********************
;
alup
;
; try up
;
ldx alx
ldy aly
dey
;
jsr chkaly ;* check pos y axis
;
lda move
beq cu
;
dec aly
;
; allowd to go up
;
cu
;
rts
;
;***********************
;
aldown
;
; try down
;
ldx alx
ldy aly
iny
iny
;
jsr chkaly ;* check pos y axis
;
lda move
beq cd
;
inc aly
;
; allowd to go down
;
cd
;
rts
;
;
;
;
;
;
;
;
;
;
.end
