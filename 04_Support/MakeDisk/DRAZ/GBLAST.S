* gblast
org = $4400
 lst off
*-------------------------------
*
*  General 18-sector blast routine
*
*  Blasts up to 2 tracks of data to 18-sector disk in drive 2
*
*-------------------------------
*
*  To use from BASIC:
*
*  BLOAD data into main mem
*
*  TrackNo   = track # (0-34)
*  DataStart = hi byte of data start address
*  DataEnd   = hi byte of data end address
*  Offset    = sector offset ($00-11)
*  Drive     = drive # (1-2)
*
*  poke gblast+3,TrackNo
*  poke gblast+4,DataStart
*  poke gblast+5,DataEnd
*  poke gblast+6,Offset
*  poke gblast+7,Drive
*  call gblast
*
*  peek(gblast+8) = # sectors written to 1st track
*  peek(gblast+9) = # sectors written to 2nd track
*
*-------------------------------
 org org

 jmp gblast

TrackNo ds 1
DataStart ds 1 ;hi byte
DataEnd ds 1 ;hi byte
Offset ds 1
DriveNo ds 1
Len1 ds 1
Len2 ds 1

zerosave ds $10

*-------------------------------
rw18buf = $4800 ;length $800
endrwbuf = $5000

temp18buf = $4800 ;length $1200
endtempbuf = $5a00

rw18 = $d000

floppyslot = 6

BbundID = $a9

slot = $fd
ztrack = $fe

*-------------------------------
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
*
*  G B L A S T
*
*-------------------------------
gblast

* save zero page vars

 ldx #$f
:loop lda $f0,x
 sta zerosave,x
 dex
 bpl :loop

* move rw18 to l.c.

 sta $c083 ;read/write RAM

 lda #>rw18
 ldx #>rw18buf
 ldy #>endrwbuf

 jsr movemem

* blast data

 jsr blast18

* Done--restore zero page vars

 ldx #$f
:loop2 lda zerosave,x
 sta $f0,x
 dex
 bpl :loop2

]rts rts

*-------------------------------
*
*  B L A S T  1 8
*
*  In: TrackNo, DataStart, DataEnd, Offset
*
*-------------------------------
blast18 lda $c083
 lda $c083 ;enable RAM

* set BbundID

 jsr rw18
 db 7,BbundID

* turn on drive and delay .5 seconds

 ldx #floppyslot*16
 stx slot

 ldx DriveNo
 cpx #1
 beq :1
 ldx #2 ;default to drive 2
:1 stx drive

 jsr rw18
 db 0
drive db 2,5

* seek first track

 lda TrackNo
 sta track

 jsr rw18
 db 2,1
track db 0

* Write out data (1-2 tracks)

 ldy #0
 lda DataStart
 sty obj_lo
 sta obj_hi

 lda Offset
 clc
 adc #>temp18buf
 sty dst_lo
 sta dst_hi

 lda #>endtempbuf
 sec
 sbc dst_hi
 sty len_lo
 sta len_hi ;# sectors left on this track (1-18)

 lda DataEnd
 sec
 sbc DataStart
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
 lda DataStart
 clc
 adc Len1
 cmp DataEnd
 beq :1
 bcs :done ;it fit on 1 track
:1 sta obj_hi

 lda #>temp18buf ;start at beginning of 2nd track
 sty dst_lo
 sta dst_hi

 lda DataEnd
 sec
 sbc obj_hi
 clc
 adc #1 ;# of sectors left to write (1-18)
 sty len_lo
 sta len_hi
 sta Len2

 lda TrackNo
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
*
*  Move a block of memory
*
*-------------------------------
 dum $f0

dest ds 2
source ds 2
endsourc ds 2

 dend

movemem sta dest+1
 stx source+1
 sty endsourc+1

 ldy #0
 sty dest
 sty source
 sty endsourc

:loop lda (source),y
 sta (dest),y

 iny
 bne :loop

 inc source+1
 inc dest+1

 lda source+1
 cmp endsourc+1
 bne :loop

 rts

*-------------------------------
 sav gblast
