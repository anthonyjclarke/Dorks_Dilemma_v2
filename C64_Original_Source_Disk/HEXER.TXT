; >s:hexer
; put "hexer"
;
;
;
hexit
;
;
pha
;
lsr a
lsr a
lsr a
lsr a
;
jsr americ
;
pla
;
americ
;
and #$f
;
cmp #$0a
bcc hex1
;
adc #$06
;
hex1
;
adc #$30
;
and #$3f
;
sta $0c20,x
;
inx
;
rts
;
;
.end
