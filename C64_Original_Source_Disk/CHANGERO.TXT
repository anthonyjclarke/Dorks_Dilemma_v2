; >s:change-room
; put "change-room"
;
; all the stuff related with
; moving to another room.
;
chgrom
;
; check buffer 'behind' to see
; if there is a door there.
;
ldy #0
ldx #3
;
clk
;
lda behind,x
cmp #200      ;* door char
bne nxt
;
iny
;
nxt
;
dex
bpl clk
;
cpy #2
beq newbod
;
rts
;
newbod
;
; there were two door chars so
; he must be right next to a door
; by looking at the value of
;
; 'dir' 0-left 1-right 2-up 4-down
;
; it is known which way he has
; moved
;
lda #1
sta newrom ;* tell basic loop
sta stop   ;* to change to new
;          ;* room
;
rts
;
;-------------------------------
;
; called by the basic loop
; to move to a new room - the
; basic loop has control.
;
roomon
;
;lda #1
;sta stop    ;* halt everything
;
; will already have been done
;
lda #1
bit dir
bne scrlft  ;* going left
;
asl a
bit dir
bne scrrgt  ;* going right
;
asl a
bit dir
bne scrup   ;* going up
;
asl a
bit dir
bne scrdwn
;
rts
;
;----------
;
scrrgt
;
inc xpos
;
lda #0
sta manx
lda #11
sta many
;
jmp jmpbak
;
;************
;
scrlft
;
dec xpos
;
lda #28
sta manx
lda #11
sta many
;
jmp jmpbak
;
;************
;
scrdwn
;
inc ypos
;
lda #15
sta manx
lda #0
sta many
;
jmp jmpbak
;
;**********
;
scrup
;
dec ypos
;
lda #15
sta manx
lda #20
sta many
;
; jmp jmpbak
;
jmpbak
;
; all the above routines must
; jump back here to continue
;
ldy ypos
lda time5,y
clc
adc xpos
sta screen ;* 0 - 24
;
tax
lda gotbit,x ;* cleared this room?
sta cleard   ;* 0 = no
;
jsr setlvl   ;* set level vars
;
ldx #0
stx prtals
stx newrom
stx going
stx xpix
stx ypix
stx bombon ;* kill the bomb if
stx bombgo ;* changing rooms
;
; jsr inital ;* start new aliens
;
jsr decode ;* put new screen on
;
lda #$10
sta delly  ;* delay for fade in
;
jsr fadein ;* copy it onto screen
;
lda cleard
bne tenson
;
; print jig-piece if room not
; cleared yet
;
jsr prpice ;* print jigsw piece
;
jmp drink
;
tenson
;
jsr gotmes ;* print mess if done
;
lda #7
sta almvet
;
drink
;
lda manx
sta savex
;
lda many
sta savey
;
lda dir
sta savdir
;
lda #14
sta chkx
;
lda #10
sta chky
;
lda duck
bne frut
;
jsr initkl  ;* number to kill
;
frut
;
; jsr setlvl  ;* set level vals
;
jsr inital  ;* start aliens
;
lda #0
sta stop
;
rts     ;* return to basic 'loop'
;
;---------------------------
;
;
;
.end
