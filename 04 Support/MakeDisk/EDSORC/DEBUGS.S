* debugs
EditorDisk = 0
org = $fc00
load = $4c00
 lst off
*-------------------------------
*
*  " D E B U G S "
*
*  Sits in aux language card--called from auxmem
*
*-------------------------------
 org org

 jmp _SHOWPAGE
 jmp DEBUGKEYS

 clc
 bcc MOVEAUXLC ;must be relocatable

 jmp _TITLESCREEN

*-------------------------------
*
*  M O V E A U X L C
*  (Move to auxiliary language card)
*
*  This code is loaded into mainmem, where MASTER calls it
*  to move itself & all other aux l.c. stuff to aux l.c.
*
*  WARNING--once in aux l.c. this code is useless!
*
*  Returns control to main l.c. bank 1
*
*-------------------------------
MOVEAUXLC
 sta $c009 ;ALTZP on (aux l.c.)

 bit $c083
 bit $c083 ;bank 2

 lda #$d0
 ldx #$20
 ldy #$50
 jsr Tmovemem

 bit $c08b
 bit $c08b ;bank 1

 do EditorDisk
 else

 lda #$d0
 ldx #$50
 ldy #$60
 jsr Tmovemem

 fin

 sta $c008 ;ALTZP off (main l.c.)
 rts

*-------------------------------
* "MOVEMEM"

 dum $00
]dest ds 2
]source ds 2
]endsourc ds 2
 dend

movemem sta ]dest+1
 stx ]source+1
 sty ]endsourc+1

 ldy #0
 sty ]dest
 sty ]source
 sty ]endsourc

:loop lda (]source),y
 sta (]dest),y

 iny
 bne :loop

 inc ]source+1
 inc ]dest+1

 lda ]source+1
 cmp ]endsourc+1
 bne :loop
 rts

Tmovemem = movemem-$fc00+$4c00

*-------------------------------
lastpage ds 1

_SHOWPAGE jsr pre
 jsr SHOWPAGE
 jmp post

_TITLESCREEN jsr pre
 jsr TITLESCREEN
 jmp post

*-------------------------------
pre
 pha

 jsr saveregs
 jsr mainmem
 jsr savezero

 pla
]rts rts

post
 jsr loadzero
 jsr auxmem
 jmp loadregs

*-------------------------------
mainmem
 sta $c004
 sta $c002
 rts

*-------------------------------
auxmem
 sta $c005
 sta $c003
]rts rts

*-------------------------------
regs ds 3
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
old80col ds 1

 dend

zerodump = $fa00 ;mainmem
pagedump = $fb00 ;mainmem

eol = $8d ;string delimiter

*-------------------------------
* Keys within routines

kesc = $9b
kpageup = $8b
kpagedown = $8a
k4kup = $95
k4kdown = $88
khires = "H"

*-------------------------------
*
*  D E B U G   K E Y S
*
*  In:  A = kbd value
*
*-------------------------------
kshowzero = "=
kshowpage3 = "\
kshowlastpage = "-

DEBUGKEYS
 cmp #kshowzero
 bne :1

 lda #0
 jmp _SHOWPAGE

:1 cmp #kshowpage3
 bne :4

 lda #3
 jmp _SHOWPAGE
:4
 cmp #kshowlastpage
 bne ]rts

 lda lastpage
 jmp _SHOWPAGE

*-------------------------------
*
*  S H O W P A G E
*
*  Show page on text page 1; any key to exit
*  Keys 0-9 to change page #
*
*  In: A = initial page #
*
*-------------------------------
SHOWPAGE
 pha
 jsr pretext
 pla

newdump  ;A = page #
 jsr  PageDump ;dump a page of memory
 jsr RegsDump ;dump registers

:loop jsr waitloop

 cmp #"0
 bcc :1
 cmp #":
 bcs :1

 sec
 sbc #"0
 jmp newdump ;dump new page

:1 cmp #kpageup
 bne :2
 lda #-1
 jmp chgpg ;change page

:2 cmp #kpagedown
 bne :3
 lda #1
 jmp chgpg

:3 cmp #k4kup
 bne :4
 lda #$10
 jmp chgpg

:4 cmp #k4kdown
 bne :5
 lda #$f0
 jmp chgpg

:5 cmp #khires
 bne :6

 jsr showhires
 jsr waitloop
 jsr showtext
 jmp :loop

:6
:exit
 jmp posttext

*-------------------------------
* Change page
*
* In: A = increment
*
* Lock out pages C0-CF
*-------------------------------
chgpg
 sta ztemp

 lda mempage
:loop clc
 adc ztemp

 cmp #$c0
 bcc :ok
 cmp #$d0
 bcc :loop

:ok sta mempage

 jmp newdump

*-------------------------------
*
*  P R E T E X T / P O S T T E X T
*
*-------------------------------
pretext
 lda $c01f ;read 80COL
 sta old80col

 lda $c01c ;read PAGE2
 sta oldpage

 jsr textcls

showtext
 lda $c054 ;page 1
 lda $c051 ;text
 sta $c00c ;40-column

 rts

*-------------------------------
posttext
 lda mempage
 sta lastpage ;for next time

 jsr showhires

 lda #$00 ;black
 jmp cls40

*-------------------------------
* Show orig. hires page

showhires
 lda oldpage ;original page
 bpl :1 ;page 1
 lda $c055 ;page 2
:1
 lda old80col
 bpl :2
 sta $c00d ;80-col on
:2
 lda $c050 ;graphics
 rts

*-------------------------------
*
*  P A G E D U M P
*
*  In: A = page # (auxmem)
*
*  Locks out $c0-cf
*
*-------------------------------
PageDump
 sta mempage

 cmp #$c0
 bcc :ok
 cmp #$d0
 bcs :ok
 rts  ;lock out $c0-cf
:ok
 jsr copypage ;to mainmem

 jsr home
 jsr normal

 lda #STRpage
 ldx #>STRpage
 jsr prline ;"Page "

 lda mempage
 jsr prhexbyte

 jsr inv

 lda #0
 sta bytenum

 lda #8
 sta tab

:rulerloop
 lda #" "
 jsr prchar

 lda bytenum
 jsr prhexdig

 jsr toggle

 inc bytenum

 lda bytenum
 cmp #$10
 bne :rulerloop

 jsr cr
 jsr cr

 lda #0
 sta bytenum
:nextline
 jsr normal
 lda #"$"
 jsr prchar

 lda mempage
 jsr prhexbyte

 lda bytenum
 jsr prhexbyte

 lda #":"
 jsr prchar

 lda #8
 sta tab

* Print next 16 byte values

 lda bytenum
 tax
 clc
 adc #$10
 sta nextbytenum

:loop stx xsave

 jsr toggle

 lda pagedump,x
 jsr prhexbyte

 ldx xsave
 inx
 cpx nextbytenum
 bne :loop

* Next line

 cpx #0
 beq :rts
 stx bytenum

 jsr cr

 jmp :nextline

:rts rts

*-------------------------------
*
*  R E G S D U M P
*
*-------------------------------
RegsDump
 jsr normal

 ldx #19
 jsr setline

 ldx #0
 lda #"A"
 jsr printreg

 ldx #1
 lda #"X"
 jsr printreg

 ldx #2
 lda #"Y"
 jsr printreg

 rts

*-------------------------------
printreg
 stx xsave

 jsr prchar
 inc tab

 lda #"="
 jsr prchar
 inc tab

 ldx xsave
 lda regs,x
 jsr prhexbyte

 lda tab
 clc
 adc #5
 sta tab
 rts

*-------------------------------
*
*  W A I T L O O P
*
*  Wait for keypress (return in A, hibit set)
*
*-------------------------------
waitloop
 sta $c010

:loop lda $c000
 bpl :loop

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
*  S A V E / L O A D  R E G S
*-------------------------------
saveregs sta regs
 stx regs+1
 sty regs+2
 rts

loadregs lda regs
 ldx regs+1
 ldy regs+2
 rts

*-------------------------------
*  S A V E Z E R O
*-------------------------------
savezero
 ldx #0

:loop lda $00,x
 sta zerodump,x

 inx
 bne :loop
 rts

*-------------------------------
*  L O A D Z E R O
*-------------------------------
loadzero
 ldx #0

:loop lda zerodump,x
 sta $00,x

 inx
 bne :loop
 rts

*-------------------------------
*  C O P Y P A G E
*
*  Copy desired auxmem page to "pagedump" in mainmem
*
*  In: A = page #
*-------------------------------
copypage
 tax
 beq :pagezero

 sta :loop+2 ;self-mod

 sta $c003 ;read auxmem

 ldx #0

:loop lda $300,x
 sta pagedump,x

 inx
 bne :loop

 sta $c002 ;read mainmem

 rts

* Read original page 0 from pagedump, not the current page 0

:pagezero
 ldx #0
:loop0 lda zerodump,x
 sta pagedump,x
 inx
 bne :loop0
 rts

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
TITLESCREEN
 jsr pretext
 jsr textcls

 jsr home
 jsr normal

 lda #title
 ldx #>title
 jsr prline

 ldx #3
 jsr setline
 lda #date
 ldx #>date
 jsr prline

 ldx #11
 jsr setline
 lda #please
 ldx #>please
 jsr prline

 ldx #23
 jsr setline
 lda #copyr
 ldx #>copyr
 jsr prline

:loop lda $c061
 ora $c062
 bpl :loop
 sta $c010
 rts

*-------------------------------
*
*  S T R I N G   D A T A
*
*-------------------------------
STRpage asc "Page "
 db #eol

title asc "PRINCE OF PERSIA Level Editor"
 db #eol
date asc "Working Copy"
 db #eol
please asc "PLEASE DO NOT COPY!!"
 db #eol
copyr asc "Copyright 1989 Jordan Mechner"
 db #eol

*-------------------------------
 lst
eof ds 1
 usr $a9,21,$e00,*-org
 lst off
