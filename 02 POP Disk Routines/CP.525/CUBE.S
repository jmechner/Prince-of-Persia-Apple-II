 lst off

*------------------------------------------------- rotcube

mainYoffset = 46 ;(192-60)/2
botYoffset = 72
mainXoffset = 68 ;(280-144)/2

color = $E4
page = $E6

 dum 0
index ds 1
ysave ds 1
yadd ds 1
yoffset ds 1
 dend

*-------------------------------------------------

rotcube jsr $f3e2 ;hgr
 jsr $f3d8 ;hgr2

 lda #1
 sta yadd

 sta yoffset

* Draw on page not showing:

mainloop lda page
 eor #$60
 sta page
 ldx #$7F
 jsr draw

* If not a //c, then wait for vbl

 lda $FBC0
 beq :is2c
 lda $C019
 bpl *-3
 lda $C019
 bmi *-3
:is2c

* Now display that page

 bit $C054
 lda page
 cmp #$20
 beq *+5
 bit $C055

* Now erase old image from last page

 eor #$60
 sta :smc0+2
 sta :smc1+2
 ldx #$20
 lda #0
:loop tay
:smc0 sta $2000,y
:smc1 sta $2080,y
 iny
 bpl :smc0
 inc :smc0+2
 inc :smc1+2
 dex
 bne :loop

 inc index
 jmp mainloop

*-------------------------------------------------

draw stx color

 ldy #12-1
:drawloop lda drawlist,y
 sty ysave

 pha
 and #15
 jsr getpoint

 tax
 tya
 ldy #0
 jsr $f457 ;plot

 pla
 lsr
 lsr
 lsr
 lsr
 jsr getpoint
 ldx #0
 jsr $f53a ;lineto

 ldy ysave
 dey
 bpl :drawloop

 lda yoffset
 clc
 adc yadd
 bne :not0

 inc yadd ;make +1
 inc yadd

:not0 cmp #191-48-botYoffset
 bcc :0

 dec yadd ;make -1
 dec yadd

:0 sta yoffset
 rts

*-------------------------------------------------
*
* given a = point number, return a = xcoor, y = ycoor
*

getpoint tay

* Get index into tables

 asl ;*16
 asl
 asl
 asl
 adc index
 and #$3F
 tax
 tya

 and #4 ;bottom?
 cmp #4

* Compute ycoor

 lda ydata,x
 bcc :not_bot
 adc #botYoffset-1

:not_bot adc yoffset
 tay

* Compute xcoor

 lda xdata,x
 adc #mainXoffset
 rts

*-------------------------------------------------

drawlist hex 01122330 ;draw top
 hex 45566774 ;draw bottom
 hex 04152637 ;draw connecting lines

xdata hex 908F8E8C8A87837F7A757069635C564F
 hex 484039332C261F1A15100C0805030100
 hex 0000010305080C10151A1F262C333940
 hex 474F565C636970757A7F83878A8C8E8F

ydata hex 181A1C1E21232527282A2B2D2E2E2F2F
 hex 2F2F2F2E2E2D2B2A28272523211E1C1A
 hex 181513110E0C0A080705040201010000
 hex 000000010102040507080A0C0E111315

*-------------------------------------------------
