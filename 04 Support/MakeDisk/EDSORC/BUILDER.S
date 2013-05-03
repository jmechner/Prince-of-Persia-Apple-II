* ed/builder
org = $8400
 lst off
*-------------------------------
 org org

 JMP COLDBUILD
 jmp WARMBUILD
 JMP RTNBUILD
 JMP MLEFT
 JMP MRIGHT

 JMP MDOWN
 JMP MUP
 JMP GETNEIGH
 jmp CALCMAT1
 jmp CLRLINKS

 jmp RESTARTBLDR

*-------------------------------
 put eq
 put buildereq
 put movedata

*-------------------------------
* Constraints

MAXBLOX = 24 ;max # of blocks per level

XDIM = 32
YDIM = 32 ;Matrix dimensions

*-------------------------------
* Screen display constants

xoffset = 0

STULX = 9 ;Starting position of screen u.l.
STULY = 12 ;(in matrix)

STPTRX = 6 ;Starting posn of pointer
STPTRY = 2 ;(on screen)

STMATX = STULX+STPTRX
STMATY = STULY+STPTRY

STBLOKX = STMATX
STBLOKY = STMATY+1 ;postion of starter block

DX = 40
DY = 12

POPY = 5
POPX = 4*POPY

ARPX = 30
ARPY = 7

SCANHT = 16
SCANWID = 15 ;dimensions of screen grid

LLX = POPX-DX+xoffset
LLY = POPY-DY+195 ;coords of lower-leftmost visible block

STX = STPTRX*DX-POPX+ARPX+LLX
STY = STPTRY-SCANHT+1*DY+POPY+ARPY+LLY

scrntop = 20
barby = 7

topmosty = -SCANHT+2*DY+LLY+POPY


* Limits of pointer/block posn on screen

LEFTEJ = 1
RIGHTEJ = 13
TOPEJ = 1 ;menu bar threshold
BOTTOMEJ = 13


* Limits of screen u.l. posn in matrix

minulx = -1
maxulx = XDIM-RIGHTEJ-1
minuly = -1
maxuly = YDIM-BOTTOMEJ-1


* Menu bar data

playx = 0
loadx = 120
savex = loadx+76
deletex = savex+76
clearx = deletex+92
trashx = 500

btnimg dfb 14,15,16,17,18,1
btnxl dfb playx,loadx,savex,deletex,clearx,trashx
btnxh dfb >playx,>loadx,>savex,>deletex,>clearx,>trashx
btny dfb 1,1,1,1,1,0
numbtns = btnxh-btnxl-1

c = 28
barlistl dfb playx+c,loadx+c,savex+c,deletex+c
 dfb clearx+c,trashx+10
barlisth dfb >playx+c,>loadx+c,>savex+c,>deletex+c
 dfb >clearx+c,>trashx+10
menulen = barlisth-barlistl-1

btnxlist dfb 0,0,1,1,2,2,3,3,4,4,4,5,5
ptrxlist dfb 1,4,6,8,10,13

*-------------------------------
arrow = 3
bblock = 1

*-------------------------------
* Special keys (development)

SHIFT = $20
CTRL = $60

kcopy = "c"
kdelblock = "d"

kcreateGD1 = "$"
kcreateGD2 = "@"
kcreateMD = "!"
kcreateDD = "#"
ksavegame1 = "g"-CTRL
ksavegame2 = "f"-CTRL
kdelgame = "d"-CTRL

krelink = "l"-CTRL

*-------------------------------
POPside1 = $a9
POPside2 = $ad

*-------------------------------
*
*  C O L D   B U I L D
*
*  Coldstart builder
*
*-------------------------------
COLDBUILD
 sta $c009

 jsr movestuff

 jsr initbuilder

 jsr STARTCLR ;clear matrix

 jmp STARTBUILDER

*-------------------------------
* Restart builder

RESTARTBLDR
 sta $c009

 jsr initbuilder

 jsr STARTCLR

 jmp STARTBUILDER

*-------------------------------
*
*  W A R M B U I L D
*
*  Return to builder from game
*  Like coldstart but leave matrix & blueprint intact
*
*-------------------------------
WARMBUILD
 sta $c009

 jsr movestuff

 jsr initbuilder

 jsr reloadblue ;from backup copy in aux l.c.
 jsr reloadbinfo

 jsr reconstruct ;matrix from blueprint

 jmp STARTBUILDER

*-------------------------------
initbuilder

 lda #1
 sta virgin ;nonzero
 sta menuflg
 sta shownums
 sta inbuilder
;sta sound

 jsr dblhgr

 jsr setfastmain ;bgtable in mainmem

 jsr initgetlnbuf

 lda #0
 sta level
 sta ineditor
 sta inmenu

 rts

*-------------------------------
STARTBUILDER
 jsr initinput

 jsr CTRPTR

 jsr SETUP

 jmp CYCLE

*-------------------------------
*
*  C Y C L E
*
*-------------------------------
CYCLE
 jsr input ;get joystick/kbd input
;(return command in A, 0 = none)
 jsr act ;& act on it

 jsr spkeys ;development keys

 lda setupflg ;redraw entire scrn?
 beq :1 ;no

 jsr SETUP

 jmp CYCLE

:1 jsr moveblok

 jsr pageflip

 jmp CYCLE

*-------------------------------
*
*  S T A R T C L E A R
*
*  Start with clear matrix
*
*-------------------------------
STARTCLR
 lda #0 ;set character start posn:

 ldx #64
:loop sta INFO,x
 inx
 cpx #70
 bcc :loop ;zero misc. INFO (kid, key, etc.)

 jsr STARTCL1 ;clear matrix

 jsr CLRLINKS ;zero link tables

 ldx #STBLOKX
 ldy #STBLOKY
 jsr :putblock

 ldx #STBLOKX+1
 ldy #STBLOKY
 jsr :putblock

 ldx #STBLOKX
 ldy #STBLOKY+1
 jsr :putblock

 ldx #STBLOKX+1
 ldy #STBLOKY+1

:putblock
 stx MATX
 sty MATY
 jsr CALCMAT

 lda NUMNEXT
 ldy #0
 sta (ZTEMP),Y ;One block on screen
 sta SCRNUM

 tax
 lda MATX ;init blueprint room loc list
 sta INFO,x
 lda MATY
 sta INFO+MAXBLOX,x

 inc NUMNEXT

 jmp clrblock

STARTCL1
 JSR CLEARMAT

 LDA #1
 STA NUMNEXT ;# (1-MAXBLOX) of next block to be drawn

 LDA #STULX
 STA ULX
 LDA #STULY
 STA ULY

 rts

*-------------------------------
*
*  I N I T   I N P U T
*
*-------------------------------
;initinput
 lda $c010

 jsr setcenter

 jsr controller

 lda joyX
 beq :jok
 lda joyY
 beq :jok

 lda #0 ;If either jstk axis is centered,
 sta joyon ;assume a joystick is connected--
;else default to kbd-only mode
:jok lda #0
 sta jcount

 rts

*-------------------------------
*
* C T R P T R
*
* Center pointer
*
*-------------------------------
CTRPTR LDA #arrow
 STA CURSOR
 STA savecurs

 LDA #STMATX
 STA MATX
 LDA #STMATY
 STA MATY

 LDA #STPTRX
 STA PTRX
 LDA #STPTRY
 STA PTRY

 LDA #STX
 STA BLOCKX
 LDA #/STX
 STA BLOCKX+1

 LDA #STY
 STA BLOCKY

 lda #0
 sta menuflg

]rts rts

*-------------------------------
*
*  S P E C I A L   K E Y S
*
*-------------------------------
spkeys
 lda keypress
 bpl ]rts

 cmp #kcopy
 beq :copy
 cmp #kcopy-SHIFT
 bne :notc

:copy jmp COPY

:notc cmp #kdelblock
 beq :delblock
 cmp #kdelblock-SHIFT
 bne :notd
:delblock ;not operational yet
 rts

:notd
 cmp #kcreateDD
 bne :11
 jsr setdatadisk
:cd lda #5 ;create blank directory
 jmp dodialog

:11 cmp #kcreateMD
 bne :11a
 jsr setmasterdisk
 jmp :cd

:11a cmp #kcreateGD1
 bne :11b
 jsr setgamedisk1
 jmp :cd

:11b cmp #kcreateGD2
 bne :2
 jsr setgamedisk2
 lda #POPside2
 sta BBundID
 jsr :cd
 lda #POPside1
 sta BBundID
 rts

:2 cmp #ksavegame1
 bne :2a
 jmp bsavegame1

:2a cmp #ksavegame2
 bne :3
 jmp bsavegame2

:3 cmp #kdelgame
 bne :4
 jmp bdelgame

:4 cmp #krelink
 bne :5
 jmp relink

:5
:rts
]rts rts

*-------------------------------
*
*  B S A V E  G A M E
*
* save level -- game portion only
*
*-------------------------------
bsavegame1
 jsr setgamedisk1
 lda #POPside1
]bsg sta BBundID

 lda #$20
 sta PAGE
 lda $C054 ;show page 1

 jsr setsetup

 lda #2
 jsr dodialog

 cpx #$ff
 beq :done
 stx level

 jsr makeblue
 jsr writedir
 jsr dsavelevelg

:done lda #POPside1 ;for master & data disks
 sta BBundID
 rts

bsavegame2
 jsr setgamedisk2
 lda #POPside2
 jmp ]bsg

*-------------------------------
*
*  Delete a file from game disk side 2
*
*-------------------------------
bdelgame
 lda #POPside2
 sta BBundID

 lda #3
 jsr dodialog

 lda #POPside1
 sta BBundID
 rts

*-------------------------------
*
*  A C T   O N   I N P U T
*
*  In: A = command (0 = none)
*
*-------------------------------
act
 cmp #0
 beq :rts

 cmp #Cleft
 BNE :3
 JMP MLEFT

:3 cmp #Cright
 BNE :4
 JMP MRIGHT

:4 CMP #Cup
 BNE :5
 JMP MUP

:5 CMP #Cdown
 BNE :nomove
 JMP MDOWN

:nomove cmp #Cbtn0
 bne :6

 lda menuflg
 bne menufn

 JMP PULLPUSH

:6 cmp #Cbtn1
 bne :7

 lda menuflg
 bne menufn

 jmp ZOOM

:7
:rts rts

*-------------------------------
* reconstruct matrix from blueprint

reconstruct
 jsr STARTCL1
 jsr CTRPTR
 jmp readblue

*-------------------------------
*
*  M E N U F N
*
* Menu bar functions
*
*-------------------------------
menufn lda menuindx

 cmp #5
 bne :1 ;trashcan

]TrashButton

 jmp TRASH

:1 cmp #3 ;delete
 bne :6

]DeleteButton

 lda #3
 jmp dodialog

:6 cmp #4 ;clear
 bne :2

]ClearButton

 jsr setsetup

 lda #4
 jsr dodialog
 cpx #$ff
 beq :rts

 JSR STARTCLR
 JSR CTRPTR

 JMP SETUP

:2 cmp #1 ;load
 bne :3

]LoadButton
 jsr setsetup

 lda #1
 jsr dodialog

 cpx #$ff
 beq :rts
 stx level

 jsr dloadlevel

 jsr reconstruct ;matrix from blueprint

 jmp SETUP

:3 cmp #2 ;save
 bne :4

]SaveButton

* Note--save routine uses aux hires 1 for scratch
* so do dialog on page 2

 lda #$20
 sta PAGE
 lda $C054 ;show page 1

 jsr setsetup

 jsr setmasterdisk ;data disk will do too

 lda #2
 jsr dodialog

 cpx #$ff
 beq :rts
 stx level

 jsr makeblue
 jsr writedir
 jsr dsavelevel

 jmp SETUP

:4 cmp #0 ;play
 bne :5

]PlayButton

 jmp goplay

:5
:rts rts

*-------------------------------
*
*  M O V E   B L O C K
*
*-------------------------------
MLEFT lda menuflg
 bne menuleft

 lda PTRX
 cmp #LEFTEJ
 bne :cont

 jsr scrright
 jmp setsetup

:cont DEC PTRX
 DEC MATX

 LDA BLOCKX
 SEC
 SBC #DX
 STA BLOCKX
 BCS :1
 DEC BLOCKX+1

:1 rts


menuleft ldx menuindx
 beq menuxset

 dex
 stx menuindx

menuxset lda barlistl,x
 sta BLOCKX
 lda barlisth,x
 sta BLOCKX+1

 rts

*-------------------------------
MRIGHT lda menuflg
 bne mnuright

 lda PTRX
 cmp #RIGHTEJ
 bcc :cont

 jsr scrleft
 jmp setsetup

:cont INC PTRX
 INC MATX

 LDA BLOCKX
 CLC
 ADC #DX
 STA BLOCKX
 BCC :1
 INC BLOCKX+1

:1 RTS

mnuright ldx menuindx
 cpx #menulen
 bcs :no

 inx
 stx menuindx

:no jmp menuxset

*-------------------------------
MDOWN
 lda ineditor
 bne :normal

 lda PTRY
 cmp #TOPEJ-1
 bne :normal

 jsr exitmenu

 jmp :finish

:normal lda PTRY
 cmp #BOTTOMEJ
 bcc :cont

 jsr scrup
 jmp setsetup

:cont LDA BLOCKY
 CLC
 ADC #DY
 STA BLOCKY

:finish inc PTRY
 inc MATY

 RTS

*-------------------------------
MUP lda ineditor
 bne :normal

 lda PTRY
 cmp #TOPEJ
 bne :normal

 jsr entrmenu

 jmp :finish

:normal lda PTRY
 cmp #TOPEJ+1
 bcs :cont

 jsr scrdown
 jmp setsetup

:cont LDA BLOCKY
 SEC
 SBC #DY
 STA BLOCKY

:finish DEC PTRY
 DEC MATY

 RTS

*-------------------------------
*
*  S C R O L L
*
*-------------------------------
scrright
 lda ULX
 cmp #minulx
 beq no

 dec ULX
 dec MATX
 rts

scrleft
 lda ULX
 cmp #maxulx
 beq no

 inc ULX
 inc MATX
 rts

scrup
 lda ULY
 cmp #maxuly
 beq no

 inc ULY
 inc MATY
 rts

scrdown
 lda ULY
 cmp #minuly
 beq no

 dec ULY
 dec MATY
no rts

*-------------------------------
setsetup ldx #1
 stx setupflg
 rts

clrptr jsr dblpeel
 jsr pageflip
 jmp dblpeel ;remove ptr from both pages

*-------------------------------
*
* T R A S H
*
*-------------------------------
TRASH lda savecurs
 cmp #arrow
 bne :cont
:rts rts

:cont lda NUMNEXT
 cmp #3
 bcc :rts ;last block can't be deleted

 lda #arrow
 sta savecurs
 lda saveby
 clc
 adc #ARPY
 sta saveby ;enter as block--leave as arrow

* Erase block #BLOCKNUM from matrix & INFO list

 lda MATX
 pha
 lda MATY
 pha

 ldx BLOCKNUM
 lda INFO,x
 sta MATX
 lda INFO+MAXBLOX,x
 sta MATY
 jsr CALCMAT

 ldy #0
 lda #0 ;empty-space code
 sta (ZTEMP),y ;to matrix

 lda #255 ;nonexistent-block code
 sta INFO,x ;x=BLOCKNUM
 sta INFO+MAXBLOX,x

* If the block we just trashed was the latest entry,
* decrement NUMNEXT to replace it; else wait till
* we run out of new block #s, then go back & look for gaps

 lda NUMNEXT
 sec
 sbc #1
 cmp BLOCKNUM
 bne :later
 sta NUMNEXT

:later pla
 sta MATY
 pla
 sta MATX

:done jmp gtone ;"ok--it's done"

*-------------------------------
*
* E N T E R M E N U
*
*-------------------------------
entrmenu lda #1
 sta menuflg

 lda CURSOR
 sta savecurs
 lda BLOCKY
 sta saveby

 lda #arrow
 sta CURSOR ;Force cursor to arrow
 lda #barby
 sta BLOCKY

* Move ptr to nearest button

 ldy PTRX
 ldx btnxlist-1,y
 stx menuindx
 jmp menuxset

*-------------------------------
*
* E X I T M E N U
*
*-------------------------------
exitmenu lda #0
 sta menuflg

 lda savecurs ;Exiting menu bar
 sta CURSOR ;Return cursor to prior state

 lda saveby
 sta BLOCKY

 ldx menuindx
 lda ptrxlist,x
 sta PTRX

 clc
 adc ULX
 sta MATX

 lda #xoffset
 sta BLOCKX
 lda #0
 sta BLOCKX+1

 ldx PTRX

:loop dex
 beq :gotit

 lda BLOCKX
 clc
 adc #DX
 sta BLOCKX

 lda BLOCKX+1
 adc #0
 sta BLOCKX+1

 bpl :loop

:gotit lda CURSOR
 cmp #arrow
 bne :ok

 lda BLOCKX
 clc
 adc #ARPX
 sta BLOCKX

 lda BLOCKX+1
 adc #0
 sta BLOCKX+1

:ok rts

*-------------------------------
*
* C O P Y
*
*-------------------------------
COPY lda CURSOR
 cmp #arrow
 beq :ptr
:rts rts

:ptr jsr CALCMAT1
 ldy #0
 lda (MATPTR),y
 beq :rts ;no block here

 jsr bcalcblue
 lda BlueType
 sta ZTEMP
 lda BlueType+1
 sta ZTEMP+1 ;ZTEMP: source block

 lda BlueSpec
 sta ZTEMP+2
 lda BlueSpec+1
 sta ZTEMP+3

 jsr NEWBLOK ;clrblock sets BlueType,BlueSpec
 bmi :rts ;not OK

 jmp copyblok

*-------------------------------
copyblok ldy #29

:loop lda (ZTEMP),y
 sta (BlueType),y

 lda (ZTEMP+2),y
 sta (BlueSpec),y
 dey
 bpl :loop
 rts

*-------------------------------
*
* P U L L / P U S H
*
*-------------------------------
PULLPUSH LDA CURSOR
 CMP #arrow
 beq :ptr
 jmp PUSH ;Push block in

:ptr JSR CALCMAT1

 LDY #0
 LDA (MATPTR),Y
 BEQ :new ;No block here--make a new one

 STA BLOCKNUM
 sta number
 JMP PULL ;Pull out block

:new jsr NEWBLOK
 bpl PUSH
 rts  ;Not OK

*-------------------------------
*
* P U S H
*
* Push block into place
*
*-------------------------------
PUSH JSR CALCMAT1

 LDY #0
 LDA (MATPTR),Y
 BEQ :11

 RTS ;There's a block here already

:11 LDA BLOCKNUM
 STA (MATPTR),Y

 tax
 lda MATX
 sta INFO,x
 lda MATY
 sta INFO+MAXBLOX,x

 LDA BLOCKX
 STA TEMP
 CLC
 ADC #POPX
 STA BLACKX

 LDA BLOCKX+1
 STA TEMP+1
 ADC #0
 STA BLACKX+1

 LDA BLOCKY
 STA TEMP+2
 SEC
 SBC #POPY
 STA BLACKY

 LDA #POPY
 STA TEMP+3

:1 LDA BLOCKX
 CLC
 ADC #4
 STA BLOCKX
 LDA BLOCKX+1
 ADC #0
 STA BLOCKX+1

 LDA BLOCKY
 SEC
 SBC #1
 STA BLOCKY

 jsr pushsub

 DEC TEMP+3
 BNE :1

 jsr pushsub

* Change cursor from block to pointer

 jsr zeropeels

 LDA #arrow
 STA CURSOR

 LDA TEMP
 CLC
 ADC #ARPX
 STA BLOCKX

 LDA TEMP+1
 ADC #0
 STA BLOCKX+1

 LDA TEMP+2
 CLC
 ADC #ARPY
 STA BLOCKY

 RTS

*-------------------------------
pushsub
 JSR moveblok
 JSR RESTORUR
 jmp pageflip

*-------------------------------
*
*  R E S T O R U R
*
* Restore neighboring blocks to U, R, and UR
*
*-------------------------------
RESTORUR lda menuflg
 beq :cont
 jmp :rts

* Block above (U)?

:cont LDX #0
 LDY #-1
 JSR GETNEIGH
 BEQ :10
 sta number

* AND UMASK / ORA U

 LDA #8
 STA IMAGE
 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 STA YCO
 LDA #0
 STA OPACITY
 JSR dbldraw

 LDA #5
 STA IMAGE
 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 STA YCO
 LDA #1
 STA OPACITY
 JSR dbldraw

* print block#

 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 sec
 sbc #DY
 STA YCO
 jsr prblokno

* Block to right (R)?

:10 LDX #1
 LDY #0
 JSR GETNEIGH
 BEQ :11
 sta number

* AND RMASK / ORA R

 LDA #0
 STA OPACITY
 LDA #9
 JSR XPL5

 LDA #1
 STA OPACITY
 LDA #6
 JSR XPL5

* print block#

 LDA BLACKX
 clc
 adc #DX
 STA XCO
 LDA BLACKX+1
 adc #>DX
 STA OFFSET
 LDA BLACKY
 STA YCO
 jsr prblokno

* Block to upper right (UR)?

:11 LDX #1
 LDY #-1
 JSR GETNEIGH
 BEQ :12
 sta number

* AND URMASK / ORA UR

 LDA #0
 STA OPACITY
 LDA #10
 JSR XPL5

 LDA #1
 STA OPACITY
 LDA #7
 JSR XPL5

* print block#

 LDA BLACKX
 clc
 adc #DX
 STA XCO
 LDA BLACKX+1
 adc #>DX
 STA OFFSET
 LDA BLACKY
 sec
 sbc #DY
 STA YCO
 jsr prblokno

:12 lda BLOCKNUM
 sta number
:rts rts

*-------------------------------
*
* P U L L
*
* Pull block out
*
*-------------------------------
PULL LDA #0
 STA (MATPTR),Y

 JSR dblpeel
 JSR pageflip
 JSR dblpeel

 jsr zeropeels

 LDA #bblock
 STA CURSOR

 LDA BLOCKX
 SEC
 SBC #ARPX
 STA TEMP

 LDA BLOCKX+1
 SBC #0
 STA TEMP+1

 LDA BLOCKY
 SEC
 SBC #ARPY
 STA TEMP+2 ;TEMP is where block's going to end up

 LDA TEMP
 CLC
 ADC #POPX
 STA BLOCKX
 STA BLACKX

 LDA TEMP+1
 ADC #0
 STA BLOCKX+1
 STA BLACKX+1

 LDA TEMP+2
 SEC
 SBC #POPY
 STA BLOCKY ;BLOCKX-Y is where block's sitting now
 STA BLACKY

 jsr animpull

:no rts

*-------------------------------
*
* A N I M P U L L
*
*-------------------------------
animpull JSR ERASEBLOK

 jsr moveblok
 jsr RESTORUR
 jsr pageflip

 jsr ERASEBLOK

 LDA #POPY
 STA TEMP+3 ;Counter

:1 LDA BLOCKX
 SEC
 SBC #4
 STA BLOCKX

 LDA BLOCKX+1
 SBC #0
 STA BLOCKX+1

 INC BLOCKY

 jsr moveblok
 jsr RESTORUR
 jsr pageflip

 DEC TEMP+3
 BNE :1

 jsr moveblok
 jsr RESTORUR

* Change cursor from pointer to block

 LDA TEMP
 STA BLOCKX
 LDA TEMP+1
 STA BLOCKX+1
 LDA TEMP+2
 STA BLOCKY

 RTS

*-------------------------------
*
* E R A S E B L O K
*
*-------------------------------
ERASEBLOK
 LDA #2
 STA IMAGE
 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET
 LDA BLOCKY
 STA YCO
 LDA #0
 STA OPACITY
 JSR dbldraw ;Erase existing block ("AND" BLOCKMASK)

 lda menuflg
 bne :1

 JSR RESTORDL

 JSR RESTORUR

:1 RTS

*-------------------------------
*
* R E S T O R D L
*
*-------------------------------
RESTORDL LDX #-1
 LDY #1
 JSR GETNEIGH
 BEQ :10

* ORA DL

:15 LDA #11
 STA IMAGE
 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 CLC
 ADC #12
 STA YCO
 LDA #1
 STA OPACITY
 JSR dbldraw

:10 LDX #-1
 LDY #0
 JSR GETNEIGH
 BEQ :11

* AND LMASK / ORA L

 LDA #19
 STA IMAGE
 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 STA YCO
 LDA #0
 STA OPACITY
 JSR dbldraw

 LDA #12
 STA IMAGE
 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 STA YCO
 LDA #1
 STA OPACITY
 JSR dbldraw

:11 LDX #0
 LDY #1
 JSR GETNEIGH
 BEQ :12

* ORA D

 LDA #13
 STA IMAGE
 LDA BLACKX
 STA XCO
 LDA BLACKX+1
 STA OFFSET
 LDA BLACKY
 CLC
 ADC #12
 STA YCO
 LDA #1
 STA OPACITY
 JSR dbldraw

:12 RTS

zerobuf rts
 do 0
zerobuf ldx BUFFLAG
 inx
 lda BUFADL,X
 sta IMAGE
 lda BUFADH,X
 sta IMAGE+1
 lda #0
 tay
 sta (IMAGE),y
 rts
 fin

*-------------------------------
*
* G E T N E I G H
*
* Given: DX & DY (in X & Y)
* Return: Contents of neighboring space (in A)
*
*-------------------------------
GETNEIGH LDA MATX
 PHA
 LDA MATY
 PHA

 TXA
 CLC
 ADC MATX
 STA MATX
 bmi :no
 cmp #XDIM
 bcs :no

 TYA
 CLC
 ADC MATY
 STA MATY
 bmi :no
 cmp #YDIM
 bcs :no

 JSR CALCMAT

 LDY #0
 LDA (ZTEMP),Y
 tax

:done pla
 sta MATY
 pla
 sta MATX

 txa
 rts

:no ldx #0
 beq :done

*-------------------------------
*
* C L E A R M A T
*
* Clear matrix (32 x 32)
*
*-------------------------------
CLEARMAT LDA #MATBASE
 STA ZTEMP
 LDA #/MATBASE
 STA ZTEMP+1

 LDA #0
 LDY #0
:1 STA (ZTEMP),Y
 INC ZTEMP
 BNE :1
 INC ZTEMP+1
 LDX ZTEMP+1
 CPX #/ENDMAT
 BCC :1

 RTS

*-------------------------------
*
* D R A W M A T
*
* Put a visual depiction of matrix onscreen
*
* Matrix dimensions: XDIM x YDIM
* Grid dimensions: SCANWID x SCANHT
* Matrix coords of grid's upper-leftmost block: (ULX,ULY)
* Screen coords of grid's lower-leftmost block: (LLX,LLY)
*
*-------------------------------
DRAWMAT LDA MATX
 PHA
 LDA MATY
 PHA
 LDA BLOCKX
 PHA
 LDA BLOCKX+1
 PHA
 LDA BLOCKY
 PHA

 lda #scrntop
 sta TOPCUT ;leave margin for menu bar

* Scan screen L-R, B-T

 LDA #SCANHT-1
 CLC
 ADC ULY
 STA MATY

 LDA #SCANWID
 CLC
 ADC ULX
 STA RMARGIN

 LDA #LLY
 STA BLOCKY

* Do a line

:4 LDA #LLX
 STA BLOCKX
 LDA #/LLX
 STA BLOCKX+1

 lda #0
 sta MATX
 jsr CALCMAT

 LDA ULX
 STA MATX

:3 JSR LAYBLOK ;Lay down block if it's there

 LDA BLOCKX
 CLC
 ADC #DX
 STA BLOCKX

 LDA BLOCKX+1
 ADC #/DX
 STA BLOCKX+1

 INC MATX
 LDA MATX
 CMP RMARGIN
 BNE :3

* Next line up

 LDA BLOCKY
 SEC
 SBC #DY
 STA BLOCKY

 DEC MATY

 LDA MATY
 BMI :done
 CMP ULY
 BCS :4
 LDA ULY
 BMI :4

:done PLA
 STA BLOCKY
 PLA
 STA BLOCKX+1
 PLA
 STA BLOCKX
 PLA
 STA MATY
 PLA
 STA MATX

 lda #0
 sta TOPCUT

 lda BLOCKNUM
 sta number
 RTS

*-------------------------------
*
*  L A Y  B L O K
*
*  Lay down a block (if it's there)
*
*-------------------------------
LAYBLOK ldy MATX
 bmi :no
 cpy #XDIM
 bcs :no

 lda MATY
 bmi :no
 cmp #YDIM
 bcs :no

 lda (ZTEMP),Y
 beq :no
 sta number

 LDA #2
 STA IMAGE
 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET
 LDA BLOCKY
 STA YCO
 LDA #0
 STA OPACITY
 JSR dbldraw

 LDA #1
 STA IMAGE
 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET
 LDA BLOCKY
 STA YCO
 LDA #1
 STA OPACITY
 jsr dbldraw

 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET
 LDA BLOCKY
 STA YCO
 jmp prblokno

:no RTS

*-------------------------------
*
*  X P L 5
*
*-------------------------------
XPL5 STA IMAGE
 LDA BLACKX
 CLC
 ADC #35
 STA XCO
 LDA BLACKX+1
 ADC #0
 STA OFFSET
 LDA BLACKY
 STA YCO
 JMP dbldraw

*-------------------------------
*
* N E W B L O K
*
*-------------------------------
NEWBLOK LDA NUMNEXT
 CMP #MAXBLOX+1
 beq :recycle ;out of fresh blocks

 sta BLOCKNUM
 sta number
 CLC
 ADC #1
 STA NUMNEXT

:cont lda BLOCKX
 sec
 sbc #ARPX
 sta BLOCKX

 lda BLOCKX+1
 sbc #0
 sta BLOCKX+1

 lda BLOCKY
 sec
 sbc #ARPY
 sta BLOCKY

 lda #bblock
 sta CURSOR

 lda BLOCKNUM
 sta SCRNUM

 jsr clrblock

 lda #0 ;"OK"
 rts

* we're out of fresh blocks -- now go back & look for
* discarded ones we can reuse

:recycle
 ldx #1 ;block #
:loop lda INFO,x
 bmi :got_one ;255 = discarded-block code
 inx
 cpx #MAXBLOX+1
 bcc :loop
;all blocks in use
:braap jsr gtone
 lda #-1 ;"NO"
 rts

:got_one stx BLOCKNUM
 stx number
 bne :cont

*-------------------------------
*
* Z O O M
*
* Zoom in on this block
*
*-------------------------------
ZOOM JSR CALCMAT1

 LDY #0
 LDA (MATPTR),Y
 BEQ NOBLOK ;No block here

 STA SCRNUM

* Cut to large-scale view of block's contents (single hi-res)

 lda $c054
 lda $c056 ;lores p1
 jsr swsingle
 jsr storemenu

 lda #1
 sta ineditor

 jmp edstart

*-------------------------------
* R T N B U I L D : return to builder from editor
* or from reboot

RTNBUILD sta $c009

 lda #0
 sta ineditor
 jsr swsingle
 lda $c054
 lda $c056 ;show lores p. 1 (black)
 JSR SETUP

NOBLOK JMP CYCLE

*-------------------------------
*
* S E T U P
*
* Set up builder screen on both pages (double hi-res)
*
*-------------------------------
SETUP jsr zeropeels

 lda #0
 sta setupflg

 jsr dodblcls
 jsr DRAWMAT
 jsr MENUBAR

 lda $c057
 jsr swdouble ;set dblhires
 jsr pageflip ;draw & show 1 page

 jsr copyscrn
 jsr copyauxscrn ;copy to other page

 jsr moveblok

 jsr pageflip

 rts

*-------------------------------
*
*  M E N U B A R
*
*  Draw menu bar across top of screen
*
*-------------------------------
MENUBAR
 lda #0
 sta TOPCUT

 ldx #numbtns

 dex ;for now (will be trash)

:loop stx TEMP

 lda #ora
 jsr drawicon

 ldx TEMP
 dex
 bpl :loop

 rts

drawicon
 sta OPACITY

 lda btnimg,x
 sta IMAGE

 lda btnxl,x
 sta XCO
 lda btnxh,x
 sta OFFSET

 lda btny,x
 sta YCO

 jmp dbldraw

*-------------------------------
*
* C A L C M A T
*
* Given: MATX & MATY (0-31)
* Return: ZTEMP = 32*MATY + MATX
*
*-------------------------------
CALCMAT LDA MATY
 STA ZTEMP
 LDA #0
 STA ZTEMP+1

 ASL ZTEMP
 ROL ZTEMP+1
 ASL ZTEMP
 ROL ZTEMP+1
 ASL ZTEMP
 ROL ZTEMP+1
 ASL ZTEMP
 ROL ZTEMP+1
 ASL ZTEMP
 ROL ZTEMP+1

 LDA MATX
 CLC
 ADC ZTEMP
 STA ZTEMP

 LDA #/MATBASE
 ADC ZTEMP+1
 STA ZTEMP+1

 RTS

CALCMAT1 JSR CALCMAT

 LDA ZTEMP
 STA MATPTR
 LDA ZTEMP+1
 STA MATPTR+1

 RTS

*-------------------------------
*
* R E A D B L U E
*
* read blueprint
*
* Use blueprint room loc list (INFO[0-63])
* to map blocks into 32x32 matrix
*
* In: blank matrix; blueprint just loaded from disk
*
*-------------------------------
readblue lda MATX
 pha
 lda MATY
 pha

 lda INFO ;next available block #
 sta NUMNEXT

 ldx #1
 ldy #0

:loop jsr getinfo
 bmi :skip ;255 = nonexistent block
 jsr CALCMAT
 txa
 sta (ZTEMP),y

:skip inx
 cpx NUMNEXT
 bcc :loop

:done pla
 sta MATY
 pla
 sta MATX
 rts

getinfo lda INFO,x
 sta MATX
 lda INFO+MAXBLOX,x
 sta MATY
]rts rts

*-------------------------------
*
*  G O P L A Y
*
*  Play level
*
*-------------------------------
goplay
 jsr setmasterdisk

 lda #0
 jsr dodialog

 cpx #$ff
 beq ]rts

 jsr makeblue

 jsr savebinfo
 jsr saveblue ;in aux l.c

 jsr gr ;show black lores
 jmp gogame

*-------------------------------
*
*  D O   D I A L O G
*
*  do dialog
*
*-------------------------------
dodialog
 pha

 jsr clrptr

 pla
 jsr dialog ;(show hidden page, do dialog on it,
;hide it again)

* Level # is returned in x-reg; ff if failure

 cpx #$ff
 beq :fix

 lda setupflg ;will we be redrawing both screens from scratch?
 bne ]rts ;yes
;no--better fix them now
:fix txa
 pha

 jsr copyscrn
 jsr copyauxscrn ;copy shown page to hidden page

 lda #0
 sta setupflg

 pla
 tax
 rts

*-------------------------------
*
*  C L R  L I N K S
*
* Zero bLINK tables
* (no links assigned yet)
*
*-------------------------------
CLRLINKS ldx #0
 txa
:loop sta bLINK1,x ;covers bLINK2
 sta bLINK3,x ;covers bLINK4
 inx
 bne :loop
 rts

*===============================
*
*    M  A  K  E    B  L  U  E  P  R  I  N  T
*
*-------------------------------
 dum locals

glinkptr ds 1
cyindex ds 1
bitmask ds 1
tempscrn ds 1
ctypead ds 2
cGspecad ds 2
cBspecad ds 2
tempby ds 1
ctrlflag ds 1
ctrlindex ds 1
ctrlbyte ds 1
pptimer ds 1
symbtype ds 1

 dend

*-------------------------------
makeblue
 lda SCRNUM
 pha

 jsr buildmap
 jsr assemblinks

 pla
 sta SCRNUM
 rts

*-------------------------------
* Build map from INFO

buildmap
 lda MATX
 pha
 lda MATY
 pha

 lda NUMNEXT
 sta INFO

 ldx #1 ;start w/ block #1

:loop stx TEMP+1
 jsr getinfo
 bmi :skip ;255 = nonexistent block

 txa
 asl
 asl
 sta TEMP

 ldx #-1
 ldy #0
 jsr GETNEIGH
 ldy TEMP
 sta MAP-4,y ;left

 ldx #1
 ldy #0
 jsr GETNEIGH
 ldy TEMP
 sta MAP-3,y ;right

 ldx #0
 ldy #-1
 JSR GETNEIGH
 ldy TEMP
 sta MAP-2,y ;up

 ldx #0
 ldy #1
 JSR GETNEIGH
 ldy TEMP
 sta MAP-1,y ;down

:skip ldx TEMP+1
 inx
 cpx NUMNEXT
 bcc :loop

:done pla
 sta MATY
 pla
 sta MATX
 rts

*-------------------------------
*
*  A S S E M B L E   L I N K   T A B L E S
*
* Use the raw linkage data in BUILDERINFO to
* build the LINKLOC/LINKMAP tables in BLUEPRINT.
*
* BLUESPEC:
* For controllers: pointer (0-255) to first LINKLOC entry
*  for this controller
* For gadgets: gadget's current state
*
* LINKLOC:
*  Bits 0-4: screen posn (0-29)
*  Bits 5-6: low 2 bits of screen # (1-24)
*  Bit 7: 1 = this is last entry, 0 = more to come
*
* LINKMAP:
*  Bits 0-4 (first entry only): pressplate timer (0-31)
*  Bits 5-7: high 3 bits of screen #
*
*-------------------------------
* Assemble link table for this entire level

assemblinks
 lda #0
 sta glinkptr ;to first free byte in LINKLOC

 lda NUMNEXT
 sec
 sbc #1
 sta SCRNUM

:loop jsr assemble1

 dec SCRNUM
 bne :loop
 rts

*-------------------------------
* Assemble link table for every controller on this screen

assemble1
 lda SCRNUM
 jsr bcalcblue ;returns BLUETYPE in BlueType
;   "    BLUESPEC in BlueSpec
 ;   "    bLINDEX in bLinkIndex
 lda BlueType
 sta ctypead
 lda BlueType+1
 sta ctypead+1 ;bluetype of controller screen

 lda bLinkIndex
 sta cBspecad
 lda bLinkIndex+1
 sta cBspecad+1 ;link index of controller screen

 lda BlueSpec
 sta cGspecad
 lda BlueSpec+1
 sta cGspecad+1 ;game bluespec of controller screen

 ldy #29 ;block #
:loop sty cyindex

 lda (ctypead),y
 and #idmask
 cmp #pressplate
 beq :pp
 cmp #upressplate
 bne :skip ;not a controller
:pp
 lda (cBspecad),y ;link index
 sta ctrlindex
 bpl :ok

 jsr gtone ;braap!
 lda ctrlindex
 jsr showpage
 jmp :skip ;unlinked controller--shouldn't happen

:ok tax ;x = link index

 jsr addlist

:skip ldy cyindex
 dey
 bpl :loop

 rts

*-------------------------------
*
*  A D D   L I S T
*
* Make list of gadgets controlled by this controller
* and add it to LINKLOC/LINKMAP
* (Do one byte at a time)
*
* In: y = cyindex (controller block #)
*
*-------------------------------
addlist
 lda glinkptr
 sta (cGspecad),y ;y = controller block #

 lda #0
 sta ctrlflag ;no matches yet

 lda #bLINK1
 sta sm1+1
 sta sm2+1
 lda #>bLINK1
 sta sm1+2
 sta sm2+2

 lda #0 ;global
 jsr dobyte ;byte 1

 lda #bLINK2
 sta sm1+1
 sta sm2+1
 lda #>bLINK2
 sta sm1+2
 sta sm2+2

 lda #0 ;global
 jsr dobyte ;byte 2

 lda #bLINK3
 sta sm1+1
 sta sm2+1
 lda #>bLINK3
 sta sm1+2
 sta sm2+2

 lda #1 ;local
 jsr dobyte ;byte 3

 ldx glinkptr ;to next free byte in LINKLOC

 lda ctrlflag
 beq :nomatches ;still zero...

* There's been at least one match.
* Set hibit of last LINKLOC entry.

:continue
 dex
 lda LINKLOC,x
 ora #$80 ;set hibit
 sta LINKLOC,x
 rts

* This "controller" controls nothing.  Signify this by
* setting LINKLOC to $FF (an otherwise unattainable value)
* and LINKMAP to initial value of pp timer

:nomatches
 lda #$ff
 sta LINKLOC,x

 lda #0 ;initial pptimer value
 sta LINKMAP,x

 inc glinkptr
 rts

*-------------------------------
* In: A = symbol type (0 = global, 1 = local)

dobyte
 sta symbtype

 ldx ctrlindex
sm2 lda bLINK1,x ;self-modifying code
 ;(can be bLINK1,2 or 3)
 sta ctrlbyte ;controller bLINKbyte

* Do one bit at a time

 lda #1
:loop sta bitmask
 and ctrlbyte
 beq :skipbit ;this bit is clear

 jsr dobit

:skipbit lda bitmask
 asl ;next bit
 bpl :loop
;hi bit is unused
 rts

*-------------------------------
dobit
 lda symbtype
 bne :local

* Global symbol --
* Test every object on every screen in this level
* to see if this bit is set

 lda NUMNEXT ;#+1 of screens in this level
 sec
 sbc #1
 sta tempscrn

:nextscrn
 jsr doscrn

 dec tempscrn
 bne :nextscrn ;next screen
 rts

* Local symbol -- do this scrn only

:local lda SCRNUM
 sta tempscrn

 jmp doscrn

*-------------------------------
* do a screen
* In: tempscrn

doscrn
 lda tempscrn
 jsr bcalcblue ;returns BlueType,Bluespec,bLinkIndex

 ldy #29 ;block #
:loop jsr testobj
 dey
 bpl :loop ;next block

 rts

*-------------------------------
* If object is a gadget, test it for this bit;
* if bit is set, add object to list

* In: BlueType, bLinkIndex
* In & out: y = block #

testobj
 lda (bLinkIndex),y
 bmi :rts ;ff means object is unlinked

 tax ;x = link index (0-127)

 lda (BlueType),y
 and #idmask ;objid
;is it a controllable gadget?
 cmp #gate
 beq yes

 cmp #exit
 beq yes

* NOTE--insert other controllable gadgets here
* as we implement them

:rts rts

yes
sm1 lda bLINK1,x ;self-modifying code
 ;(can be BLINK1,2 or 3)
 and bitmask
 beq :rts ;bit is clear
;bit is set

* We have a match -- add this gadget to LINKlist

 lda #1
 sta ctrlflag ;so we know there's at least one
 ;gadget in list

 ldx glinkptr ;to first free byte in LINKLOC

 sty tempby ;gadget block # (0-29)

 lda tempscrn ;gadget screen # (1-24)
 and #%00000011 ;2 low bits
 asl
 asl
 asl
 asl
 asl ;bits 5-6: 2 low bits of screen#
 ora tempby ;bits 0-4: block#
 sta LINKLOC,x ;bit 7 clear (for now)

 lda tempscrn
 and #%00011100 ;3 high bits
 asl
 asl
 asl ;bits 5-7: 3 high bits of screen#

 ora #0 ;bits 0-4: init value of timer

 sta LINKMAP,x

 inc glinkptr ;but not past 255

:rts rts

*-------------------------------
 lst
 ds 1
 usr $a9,24,$0000,*-org
 lst off
