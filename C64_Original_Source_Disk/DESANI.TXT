; >s:des-ani
; put "des-ani"
;
; animate chars for mega-
; gloppiness.
;
animat
;
dec anitem
beq fgre
;
rts
;
fgre
;
lda #7
sta anitem
;
; now do the brick chars
;
inc brkcnt
lda brkcnt
cmp #3
bne ntlsbk
;
lda #0
sta brkcnt
;
ntlsbk
;
asl a
asl a
asl a
;
tax
;
ldy #0
;
brklop
;
lda brik1,x
sta $3e38,y
;
lda brik2,x ;* door char
sta $3e40,y
;
inx
iny
cpy #8
bne brklop
;
rts
;
;
brik1
;
; gloppy brick chars
;
.byte $6d,$6d,$fe,$fe,$bf,$bf,$79,$79
.byte $b6,$b6,$7f,$7f,$fd,$fd,$9e,$9e
.byte $db,$db,$bd,$bd,$7e,$7e,$e7,$e7
;
brik2
;
; another gloppy brik char
;
.byte $55,$7d,$7d,$7d,$7d,$7d,$7d,$55
.byte $55,$69,$55,$7d,$7d,$55,$69,$55
.byte $55,$69,$69,$55,$55,$69,$69,$55
;
;--------------------------------
;
;
;
;
;
.end
