* mblast
org = $3000
 lst off
*-------------------------------
*
*  M B L A S T
*
*  Blast music table to 18-sector disk
*  in drive 1
*
*  Can be BRUN from Applesoft (ProDos or 3.3)
*
*  First BLOAD music table into main mem at TabStart
*
*-------------------------------
 org org

 jmp mblast

*-------------------------------
TrackNo = 19
TabStart = $2000
TablEnd = $2600

*-------------------------------
rw18buf = $3800
endrwbuf = $4000

temp18buf = $4000
rw18 = $d000

floppyslot = 6
floppydrive = 1

BbundID = $a9

slot = $fd
ztrack = $fe

 dum $300
TABLEND ds 1 ;hi byte
TABSTART ds 1 ;hi byte
TRACK ds 1
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
*
*  M B L A S T
*
*-------------------------------
mblast

* move rw18 to l.c.

 sta $c083 ;read/write RAM

 lda #>rw18
 ldx #>rw18buf
 ldy #>endrwbuf

 jsr movemem

* message

 jsr MSG

* blast music

 lda #TrackNo
 sta TRACK

 lda #>TabStart
 sta TABSTART

 lda #>TablEnd
 sta TABLEND

 jsr blast18

* Done

 jmp MSG2

*-------------------------------
*
*  B L A S T  1 8
*
*  In: TABSTART, TABLEND, TRACK
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

* write out table (1-2 tracks)

 jsr wrtrack

 lda TABSTART
 clc
 adc #$12
 sta TABSTART

 lda TABLEND
 cmp TABSTART ;table longer than 18 sectors?
 bcc :done ;no

 lda TRACK
 clc
 adc #1
 sta ztrack
 jsr wrtrack ;yes--write out second track

* turn off drive

:done jsr rw18
 db 1

* out of here!

 sta $c082

 rts

*-------------------------------
wrtrack ldy #0
 lda TABSTART
 sty obj_lo
 sta obj_hi

 lda #0
 sta dst_lo
 lda #0 ;offset
 clc
 adc #>temp18buf
 sta dst_hi

 lda #0
 sta len_lo ;1-sector chunks
 lda TABLEND
 sec
 sbc TABSTART
 clc
 adc #1
 sta len_hi
 cmp #$12
 bcc :ok ;fits on 1 track

 lda #$12
 sta len_hi ;write 1 track at a time

:ok jsr rw18
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
 jsr flush?

:4 lda len_lo
 ora len_hi
 bne :loop

 jsr flush?

 rts

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
 dum $00

dest ds 2
source ds 2
endsourc ds 2

 dend
*-------------------------------
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
 dum $00

base ds 2
tab ds 1
line ds 1
inverse ds 1
bytenum ds 1
mempage ds 1
oldpage ds 1
strptr ds 2
xsave ds 1
ysave ds 1
nextbytenum ds 1
direcptr ds 1
ztemp ds 1

 dend

eol = $8d ;string delimiter

*-------------------------------
* WAITLOOP
*-------------------------------
waitloop
 sta $c010

:loop lda $c000
 bpl :loop

 sta $c010

 rts

*-------------------------------
*  C R
*-------------------------------
cr
 lda #0
 sta tab

 inc line
 ldx line
 jmp bascalc

*-------------------------------
*
*  P R L I N E
*
*  Print a line of normal text
*
*  In: A-X = string ptr
*
*-------------------------------
prline
 sta strptr
 stx strptr+1
:loop
 ldy #0
 lda (strptr),y
 cmp #eol
 beq :rts

 jsr prcharn

 inc strptr
 bne :loop
 inc strptr+1
 bne :loop

:rts rts

*-------------------------------
*
*  P R H E X B Y T E
*
*  Print a hex byte (in A)
*
*-------------------------------
prhexbyte
 pha
 lsr
 lsr
 lsr
 lsr
 jsr prhexdig

 pla
 and #$0f
 jmp prhexdig

*-------------------------------
*
*  P R H E X D I G
*
*  Print a hex digit (in A)
*  Trashes X
*
*-------------------------------
prhexdig
 tax
 lda hextoasc,x
 jmp prchar

*-------------------------------
*
*  P R C H A R
*
*  Print an ASCII character (in A)
*
*-------------------------------
prchar
 ldy tab
 and #%00111111
 ora inverse
 sta (base),y

 inc tab

 rts

prcharn ;normal
 ldy tab
 sta (base),y

 inc tab

 rts

*-------------------------------
*
*  H O M E
*
*-------------------------------
home
 jsr textcls

 lda #0
 sta tab

 ldx #0
 stx line

 jmp bascalc

*-------------------------------
*
*  I N V E R S E / N O R M A L
*
*-------------------------------
normal
 lda #$80
 sta inverse
 rts

inv
 lda #0
 sta inverse
 rts

toggle
 lda inverse
 eor #$80
 sta inverse
 rts

*-------------------------------
*
*  S E T L I N E
*
*  In: X = line #
*
*-------------------------------
setline
 lda #0
 sta tab

 stx line

*-------------------------------
*
*  B A S C A L C
*
*  In: X = line # (0-24)
*
*-------------------------------
bascalc
 cpx #24
 bcs :rts

 lda textl,x
 sta base

 lda texth,x
 sta base+1

:rts rts

*-------------------------------
*
*  T E X T C L S
*
*  Clear text page 1 to black
*
*-------------------------------
textcls lda #$a0 ;space

cls40 ldy #$f7
:2 sta $400,y
 sta $500,y
 sta $600,y
 sta $700,y

 dey
 cpy #$7f
 bne :3

 ldy #$77
:3 cpy #$ff
 bne :2

 rts

*-------------------------------
*
*  M E S S A G E
*
*-------------------------------
MSG
 jsr home
 jsr normal

 lda #msg
 ldx #>msg
 jsr prline

 jsr waitloop

 rts

MSG2
 jsr home
 jsr normal

 lda #msg2
 ldx #>msg2
 jsr prline

 jsr waitloop

*-------------------------------
* 40-column text base addresses
*-------------------------------

textl hex 00,80,00,80,00,80,00,80
 hex 28,a8,28,a8,28,a8,28,a8
 hex 50,d0,50,d0,50,d0,50,d0

texth hex 04,04,05,05,06,06,07,07
 hex 04,04,05,05,06,06,07,07
 hex 04,04,05,05,06,06,07,07

*-------------------------------
* Hex to ASCII
*-------------------------------

hextoasc asc "0123456789ABCDEF"

*-------------------------------
*
*  S T R I N G   D A T A
*
*-------------------------------
msg asc "Put game disk in drive 1 and hit a key"
 db #eol

msg2 asc "Hit control-reset to reboot"
 db #eol

*-------------------------------
 lst
eof ds 1
 lst off
*-------------------------------
 sav mblast
