; >s:play-game
; put "play-game"
;
; hold all the routines together
;
play
;
sei
;
jsr clvars  ;* clear vars
;
; lda #<messt
; sta mesl
;
; lda #>messt
; sta mesl+1
;
;------------------
;
; lda #0
; sta manx
; sta trx
;
lda #12
sta many
sta try
;
lda #2
sta dir ;* start direction
;
;------------------
;
; man's start position
;
jsr copybm
;
; copy complete bomb char
;
;-------------------------------
;
jsr rooms   ;* set up randomness
;
; lda #0
; sta xpos
; sta ypos
;
jsr setup
;
; lda #1
; sta joysel
;
; jsr prbder  ;* glop border
; jsr prjig   ;* print jigsaw
;  jsr setwin  ;* set up window
;
jsr setirq  ;* irq's on
;
lda #1
sta stop    ;* no movement
sta bready  ;* bomb ready
sta anitem  ;*
sta alitem  ;*
;
jsr scater  ;* scatter jigsaw
;
jsr jmpbak
;
; this is calling a subroutine
; used in the game to print on
; a new screen (as if moved into a
; new room.)
;
lda #0
sta stop    ;* all go
;
; lda #3
; sta lives   ;* no. of lives
;
loop
;
jsr deadck
;
; check if he died during during
; the last raster.
;
jsr comand
;
; check if you want to edit/escape
;
jsr basbom
;
; check if the irq wants this loop
; to do the bomb explosion.
;
lda newrom   ;* move to new room?
beq norm
;
jsr roomon
;
; bring on the new room
;
norm
;
ldx #$08
jsr delay+2
;
;
;
jsr radar    ;* update radar
;
dec alitem
bne dntdit
;
lda almvet   ;* tempo
sta alitem
;
jsr mveali   ;* move aliens
;
dntdit
;
jmp loop
;
;
;
.end
