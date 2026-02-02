; >s:des-irq
; put "des-irq"
;
;*********************
;
; all the irq routines
;
;*********************
;
;
setirq
;
; set up irq's
;
sei
;
lda #<serv
sta $0314
lda #>serv
sta $0315
;
; lda #%00000010
; sta irqmsk
;
; enable irq's from :-
;
; raster
;
; no hassle from timer 2 in this !
;
; lda #$c0
; sta rascom
;
; set raster compare
;
cli
;
rts
;
;-------------------------------
;
serv
;
;************************
;
;irq comes here - wow !!!
;
;************************
;
; lda irqreg
; sta irqreg ;* reset bits
;
;
;*************************
;
; raster service routine
;
;*************************
;
jsr animat
;
;************
;
;  irq exit
;
;************
;
irqend
;
jmp $ce0e
;
pla
tay
pla
tax
pla
rti
;
;
;
;
;
.end 
