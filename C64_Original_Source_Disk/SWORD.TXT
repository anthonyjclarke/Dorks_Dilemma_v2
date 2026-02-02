; >s:title-works
; put "title-works"
;
; do the bits on the title page
;
bdrglp
;
; scroll the border round
;
lda $c1f
sta stopa  ;* save it
;
lda $f8f
sta stopb
;
lda $f98
sta stopc
;
; 3 bits saved
;
ldx #30
;
qat1
;
lda $c00,x
sta $c01,x
;
dex
bpl qat1
;
lda #22
sta ty
;
qat2
;
ldx #31
ldy ty
jsr xy
;
ldy #0
lda (sl),y
;
ldy #40
sta (sl),y
;
dec ty
bne qat2
;
lda stopa
sta $c47
;
ldx #0
;
qat3
;
lda $f99,x
sta $f98,x
;
inx
cpx #30
bne qat3
;
lda stopb
sta $fb6
;
lda #0
sta ty
;
qat4
;
ldx #0
ldy ty
jsr xy
;
ldy #40
lda (sl),y
;
ldy #0
sta (sl),y
;
inc ty
lda ty
cmp #23
bne qat4
;
lda stopc
sta $f70
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
.end
