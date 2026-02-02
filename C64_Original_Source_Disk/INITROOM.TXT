; >s:init-rooms
; put "init-rooms"
;
; called at the start of every
; game to set up the following
; tables :-
;
; jignum
; ------
;
; what piece number of the
; jigsaw is in this room
;
; romnum
; ------
;
; the screen data for that room.
;
; gotbit
; ------
;
; have we cleared this room ?
;
;
rooms
;
; ldx #3
;
; roomfl
;
; lda ted,x
; sta rnd,x
;
; dex
; bpl roomfl
;
jsr setup
;
; nice & random
;
jsr rndbuf ;* random buffer
;
ldx #24
;
wrd2
;
lda scrbuf+25,x
sta jignum,x
;
dex
bpl wrd2
;
jsr rndbuf ;* random buffer
;
ldx #24
;
wrd3
;
lda scrbuf+25,x
sta romnum,x
;
lda #0
sta gotbit,x
;
; clear that table
;
dex
bpl wrd3
;
;
rts
;
;-----------------------------
;
rndbuf
;
;fill scrbuf+25 to (scrbuf+25)+24
; with 0-24
;
ldx #24
lda #0
;
wdr1
;
sta scrbuf,x
dex
bpl wdr1
;
lda #0
sta xcount
;
wddr
;
jsr random
;
lda rnd+2
and #31
cmp #25
bcs wddr
;
tay
;
tax
lda scrbuf,x
bne wddr
;
; that no. already used
;
lda #1
sta scrbuf,x
;
; used now. !
;
tya
;
ldx xcount
sta scrbuf+25,x
;
inc xcount
lda xcount
cmp #25
bne wddr
;
rts
;
;
;
;
;
;
;
.end
