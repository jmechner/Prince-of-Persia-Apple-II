    lst off

org = $2FF

floppyslot = 6
floppydrive = 2

*
* Merlin 2.52 --> RW18 "USR" interface routine.
* by Roland Gustafsson
*
* Merlin USR routine for writing out 18 sector data.
* This is the code that gets executed when the USR
* pseudo-op is specified.  The parameters passed are:
*
* usr <BbundID>,<track>,<byte offset 0-$11FF>,<byte length>
*
* An easy way to specify length is to allocate X number
* of bytes for each module and use that number for len.
* To specify exact length, use org = $(org) at top of
* your source code, then "org org" instead of usual
* org (origin).  That way you specify length by simply
* using "*-org".
*

*-------------------------------
*
* Stuff in aux memory:
*
rw18 = $6900 ;uses $1000-1AFF for tables
temp18buf = $6E00
obj_buf = $8000

* zpage
 dum $60
obj_lo ds 1
obj_hi ds 1
dst_lo ds 1
dst_hi ds 1
len_lo ds 1
len_hi ds 1
flushflag ds 1
 dend
slot = $FD

* Merlin stuff

usrads = $B6DA ;vector set up by INSTALL18
eval = $E5F9
passnum = $02
value = $55
*-------------------------------
 org org
 db eof-*-1
*-------------------------------
*
* This routine at $300 must be in both main and aux!
*
*-------------------------------
*
* Here is the USR routine:
*
user lda passnum
 bne :0
 rts

* Pass 2 so do your stuff!

:0 ldx #0
 ldy #<obj_buf
 lda #>obj_buf
 sty obj_lo
 sta obj_hi

* Get BbundID

 jsr get16bit
 tya
 pha

* Get track number

 jsr get16bit
 tya
 pha

* get offset into track data

 jsr get16bit
 sty dst_lo
 clc
 adc #>temp18buf
 sta dst_hi

* get length of data to be written out

 jsr get16bit
 sty len_lo
 sta len_hi

 pla
 sta $C003 ;aux mem
 sta $C005
 sta track

 pla
 sta BbundID

* Turn off any interupts and save status

 php
 sei

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

* seek desired track

 jsr rw18
 db 2,1
track db 0

* read in current data

 jsr rw18
 db $83,>temp18buf

:movebyte ldy #0
 sty flushflag
 lda (obj_lo),y
 sta (dst_lo),y

 inc obj_lo
 bne *+4
 inc obj_hi

 inc dst_lo
 bne *+4
 inc dst_hi

 lda len_lo
 bne *+4
 dec len_hi
 dec len_lo

 lda dst_hi
 cmp #>temp18buf+$1200
 bne *+5
 jsr flush?

 lda len_lo
 ora len_hi
 bne :movebyte

 jsr flush?

* turn off drive and get out of here!

 jsr rw18
 db 1

 sta $C002
 sta $C004
 plp
 rts

*-------------------------------
*
* If data has been written to temp18buf,
* then flush the buffer!
*
flush? lda flushflag
 bne :nodata

 ldy #<temp18buf
 lda #>temp18buf
 sty dst_lo
 sta dst_hi
 jsr rw18
 db $C5,>temp18buf

 lda len_lo
 ora len_hi
 beq :nodata

* read in current data

 jsr rw18
 db $83,>temp18buf

 inc flushflag

:nodata rts
*-------------------------------
*
* Get 16bit number from source code
*
get16bit jsr eval
 ldy value
 lda value+1
 inx
 rts
eof
*------------------------------- end of file!
 sav usr18
