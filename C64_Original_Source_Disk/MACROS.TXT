; put "macros"
;
;
;
.mac dpinc
;
inc ?1
bne ?2
;
inc ?1+1
;
?2
;
.mnd
;
;
;
.mac dpdec
;
lda ?1
sec
sbc #1
sta ?1
;
lda ?1+1
sbc #0
sta ?1+1
;
.mnd
;
;
;
.end
