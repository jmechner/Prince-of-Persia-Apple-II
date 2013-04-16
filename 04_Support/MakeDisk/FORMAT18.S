 lst off
org = $300
*
* Format an 18 sector disk
*
* Call from applesoft:
*
* CALL FO,<slot>,<drive>,<BbundID>,
*         <start track>,<end track>
*
* (Writes out whatever happens to be sitting
*  at $2000.31FF, so do HGR for better results)
*
err_code = 0

get8bit = $E74C

buffer = $2000
rw18 = $6900
slot = $FD
track = $FE
lastrack = $FF

*-------------------------------
 org org
*-------------------------------

 jsr get8bit
 txa
 asl
 asl
 asl
 asl
 sta slot

 jsr get8bit
 stx drive

 jsr get8bit
 stx BbundID

 jsr get8bit
 txa
 pha

 jsr get8bit
 inx
 stx end_track

 jsr rw18
 db 7
BbundID db $11

 jsr rw18
 db 0 ;drive on
drive db 1,5

 lda #$80
 sta lastrack
 jsr rw18
 db 2,0,0 ;recal!

 pla
 sta track

loop jsr rw18
 db $05,>buffer ;write
 bcs wp_error

 jsr rw18
 db $44 ;verify
 ds 18,0
 bcs vr_error

 lda track
 eor #$11
end_track = *-1
 bne loop

 hex 2C
wp_error lda #1
 hex 2C
vr_error lda #2
 sta err_code

 jsr rw18
 db 1 ;drive off
 rts
