 lst off

org = $1000
userbuf = org+$100
rw18buf = org+$200

rw18 = $6900
user = $300

usrads = $B6DA

devnum = $BF30
devcnt = $BF31
devlst = $BF32

*-------------------------------
 org org
*-------------------------------
*
* 2/5/87 by Roland Gustafsson
*
* Initialize 18 sector user routines!
*
start ldx #$4C
 ldy #<user
 lda #>user
 stx usrads
 sty usrads+1
 sta usrads+2

* Move user routine to both banks

 ldy userbuf
:0 lda userbuf,y
 sta $C004 ;main mem
 sta user-1,y
 sta $C005 ;aux mem
 sta user-1,y
 dey
 bne :0

* Move RW18 to aux mem

 ldx #5
:1 lda rw18buf,y
:2 sta rw18,y
 dey
 bne :1
 sta $C004
 inc :1+2
 inc :2+2
 sta $C005
 dex
 bne :1

 sta $C004
*
* Disconnect /RAM
*
 ldy #0
:3 lda devlst,Y
 and #$F0
 cmp #$B0
 beq :4
 iny
 cpy devcnt
 beq :3
 blt :3
 bge :9
*
:4 lda devlst+1,Y
 sta devlst,Y
 iny
 cpy devcnt
 beq :4
 blt :4
 dec devcnt
 lda devnum
 bne :9
 ldy devcnt
 lda devlst,Y
 sta devnum
:9 rts

*------------------------------- end of this file
 sav install18
