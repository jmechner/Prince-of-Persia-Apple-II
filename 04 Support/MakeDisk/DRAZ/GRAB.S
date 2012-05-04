* grab
org = $4400
 lst off
*-------------------------------
*
*  Grab hi-res screen from side 2 of game disk, tracks 22-23
*
*-------------------------------
*
*  To use from BASIC:
*
*  BLOAD data into main mem
*
*  TrackNo   = track # (0-34)
*  DriveNo   = drive # (1-2)
*
*  G = 17408 ($4400)
*  poke G+3,TrackNo
*  poke G+4,DriveNo
*  call G
*
*-------------------------------
 org org

 jmp grab

TrackNo ds 1
DriveNo ds 1

zerosave ds $10

*-------------------------------
rw18buf = $4800 ;length $800
endrwbuf = $5000

temp18buf = $4800 ;length $1200
endtempbuf = $5a00

rw18 = $d000

floppyslot = 6

BbundID = $ad

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
*  G R A B
*
*-------------------------------
grab

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

* grab data

 jsr grab18

* Done--restore zero page vars

 ldx #$f
:loop2 lda zerosave,x
 sta $f0,x
 dex
 bpl :loop2

]rts rts

*-------------------------------
*
*  G R A B  1 8
*
*  In: TrackNo, DriveNo
*
*-------------------------------
grab18 lda $c083
 lda $c083 ;enable RAM

* set BbundID

 ldx DriveNo
 cpx #1
 beq :1
 ldx #2 ;default to drive 2
:1 stx drive

 jsr rw18
 db 7,BbundID

* turn on drive and delay .5 seconds

 ldx #floppyslot*16
 stx slot

 jsr rw18
 db 0
drive db 2,5

* seek first track

 lda TrackNo
 sta track

 jsr rw18
 db 2,1
track db 0

* Load in 2 tracks at $2000

 jsr loadhr

* turn off drive

:done jsr rw18
 db 1

* out of here!

 sta $c082

 rts

*-------------------------------
*
* load hires scrn
*
*-------------------------------
loadhr
 jsr rw18
 hex c3,20

 jsr rw18
 hex c4
 hex 32,33,34,35,36,37,38,39,3a
 hex 3b,3c,3d,3e,3f,00,00,00,00

 rts

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
 sav grab
