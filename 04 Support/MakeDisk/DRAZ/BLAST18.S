* draz/blast18
org = $9200
 lst off
*-------------------------------
rw18 = $d000
temp18buf = $4000
endtempbuf = $5200

floppyslot = 6
floppydrive = 2

slot = $fd
ztrack = $fe

 dum $300
TABLEND ds 1 ;hi byte of table end addr
TABSTART ds 1 ;hi byte of table start addr
TRACK ds 1 ;track #
 ds 1
IDBYTE ds 1 ;18-sector ID byte
OFFSET ds 1 ;sector offset (00-11)
Len1 ds 1
Len2 ds 1
 dend

 dum $f0
obj_lo ds 1
obj_hi ds 1
dst_lo ds 1
dst_hi ds 1
len_lo ds 1
len_hi ds 1
flushflag ds 1
 dend
*-------------------------------
 org org

* In: TABSTART, TABLEND, TRACK, IDBYTE, OFFSET

blast18 lda $c083
 lda $c083 ;enable RAM

* set BbundID

 lda IDBYTE
 sta BbundID

 jsr rw18
 db 7
BbundID db $a9

* turn on drive and delay .5 seconds

 ldx #floppyslot*16
 stx slot
 ldx #floppydrive
 stx drive

 jsr rw18
 db 0
drive db 2,5

* seek first track

 lda TRACK
 sta track

 jsr rw18
 db 2,1
track db 0

* Write out data (1-2 tracks)

 ldy #0
 lda TABSTART
 sty obj_lo
 sta obj_hi

 lda OFFSET
 clc
 adc #>temp18buf
 sty dst_lo
 sta dst_hi

 lda #>endtempbuf
 sec
 sbc dst_hi
 sty len_lo
 sta len_hi ;# sectors left on this track (1-18)

 lda TABLEND
 sec
 sbc TABSTART
 clc
 adc #1 ;total # of sectors to write (1-36)
 cmp len_hi
 bcs :ok ;write to end of track
 sta len_hi ;write portion of track

:ok lda len_hi
 sta Len1
 jsr wrtrack ;write 1st track

* Write out 2nd track if necessary

 ldy #0
 sty Len2
 sty obj_lo
 lda TABSTART
 clc
 adc Len1
 cmp TABLEND
 beq :1
 bcs :done ;it fit on 1 track
:1 sta obj_hi

 lda #>temp18buf ;start at beginning of 2nd track
 sty dst_lo
 sta dst_hi

 lda TABLEND
 sec
 sbc obj_hi
 clc
 adc #1 ;# of sectors left to write (1-18)
 sty len_lo
 sta len_hi
 sta Len2

 lda TRACK
 clc
 adc #1
 sta ztrack
 jsr wrtrack ;write out second track

* turn off drive

:done jsr rw18
 db 1

* out of here!

 sta $c082

 rts
*-------------------------------
*
* write 1 track
*
* In: obj, dst, len
*  (trashes these vars)
*
*-------------------------------
* read in current data

wrtrack
 jsr rw18
 db $83,>temp18buf

:loop ldy #0
 sty flushflag
 lda (obj_lo),y
 sta (dst_lo),y

 inc obj_lo
 bne :1
 inc obj_hi

:1 inc dst_lo
 bne :2
 inc dst_hi

:2 lda len_lo
 bne :3
 dec len_hi
:3 dec len_lo

 lda dst_hi
 cmp #>temp18buf+$1200
 bne :4
 jmp flush?

:4 lda len_lo
 ora len_hi
 bne :loop

 jmp flush?

*-------------------------------
flush? lda flushflag
 bne :nodata

 ldy #<temp18buf
 lda #>temp18buf
 sty dst_lo
 sta dst_hi
 jsr rw18
 db $c5,>temp18buf

 lda len_lo
 ora len_hi
 beq :nodata

 jsr rw18
 db $83,>temp18buf

 inc flushflag

:nodata rts
*-------------------------------
eof
 sav blast18
