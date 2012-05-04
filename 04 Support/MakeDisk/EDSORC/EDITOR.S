* ed/editor
DunjDisk = 1 ;0 for palace
org = $9600
 lst off
*-------------------------------
*
*  E D I T O R
*
*-------------------------------
 org org

 jmp EDSTART
 JMP CLRBLOCK
 jmp RELINK
 ds 3
 ds 3

*-------------------------------
* MENU DATA
 do DunjDisk
menuType ;(BlueType)
 hex 0d,12,02,0b,06,0f,04,10,11,0e
 hex 01,00,14,00,03,13,00,00,0c,09
 hex 00,00,00,00,0a,15,16,0c,0c,08

menuSpec  ;(BlueSpec)
 hex 00,00,00,00,00,00,02,00,02,00
 hex 00,00,00,00,00,00,02,01,01,00
 hex 00,00,00,03,00,00,00,02,00,00
 else

menuType ;(BlueType)
 hex 0d,12,02,0b,06,0f,04,10,00,0e
 hex 01,00,14,1c,03,13,00,00,0c,09
 hex 00,00,00,0a,19,1a,1b,0c,0c,08

menuSpec  ;(BlueSpec)
 hex 00,00,00,00,00,00,02,00,03,00
 hex 00,00,00,00,00,00,02,01,01,00
 hex 00,00,00,00,00,00,00,02,00,00
 fin

menubSpec ;(bLinkIndex)
 hex 00,00,00,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00,00
 hex 02,03,01,00,00,00,00,00,00,00

*-------------------------------
* "menubSpec" is index # of special symbol to
* appear in this space:
*
* 1 = kid
* 2 = eye
* 3 = guard
*
* "menuSpec": for gadgets, initial bluespec value
*
* 1 = "up"
* 2 = "down"
*
* for panels, panel pattern (0,1,2...)
*
*-------------------------------
 put eq
 put buildereq
 put movedata
 put eddata

*-------------------------------
* Local vars

 dum locals

TEMPX ds 1
TEMPY ds 1
TEMPMX ds 1
TEMPMY ds 1
TEMPULX ds 1
TEMPULY ds 1
TEMPBX ds 2
TEMPBY ds 1
TEMPPX ds 1
TEMPPY ds 1
andwhat ds 1
origscrn ds 1
tempid ds 1
propose ds 1
existobj ds 1
existspec ds 1
tempdata ds 6

 dend

kspeed = 8 ;determine marquee speeds
jspeed = 20 ;in kbd & jstk modes

bkspeed = 15
bjspeed = 50 ;beth blink speed

boxtimer = 90 ;cursor repeat-move speeds
bethtimer = 120 ;(higher = slower)

unreqmask = %11011111

bethxco db 0,1,2
bethoffset db 0,2,4
bethyco hex 00,08,10,18,20,28,30,38

bethbits hex 01,02,04,08,10,20,40,80

* size:        00,01,02,03,04,05
rtlist hex 01,01,02,03,04,01
uplist hex 01,01,01,01,01,02

* special menu symbols

sstartkid = 1
seye = 2
sstartguard = 3

*-------------------------------
ctrl = $60
shift = $20

kleft = $88
kright = $95
kup = $8b
kdown = $8a ;arrows
kbtn0 = " "
kbtn1 = $8d ;return

kunreq = "q"-ctrl

*-------------------------------
*
*  NOTE: Editor uses image lists, redraw buffers, etc.
*  in the approved way -- but only for the background.
*  The cursor, flashing arrows, and other misc. stuff
*  (mostly from EDTABLE) are superimposed manually.
*
*-------------------------------
EDSTART jsr INITPOINT

 lda #0
 sta THIRD
 sta inmenu
 sta linkmode
 sta blackflag

 jsr zerolsts
 jsr zeropeel

 lda #1
 sta antcount

 jsr getneighs

 jsr DoCleanCut

 jmp inploop

*-------------------------------
*
* Clear scrn & redraw entire b.g.
*
*-------------------------------
DoSure
 jsr sure

 jsr zeropeels
 jsr zerored

 jsr drawall
 jsr zerolsts

 jsr menuspecial

 jsr specialsyms

 jmp edges

*-------------------------------
*
*  I N P U T   L O O P
*
*-------------------------------
inploop
 lda $c000
 sta keypress

 lda $c010
 sta keydown

 lda keypress
 bpl :j

 jsr edkeys ;Always check special keys

 jsr actkey
 jmp :cont

:j jsr actjoy

:cont jsr marquee
 jmp inploop

*-------------------------------
*
*  E D I T O R   K E Y S
*
*-------------------------------
edkeys lda keypress
 jsr specialk

 lda keypress
 cmp #$9b ;esc
 bne :1
 jmp EXIT

:1 cmp #kunreq
 bne :2
 jsr gtone
 jmp UnRequire

:2 cmp #"0" ;0-9 set guard prog
 bcc :nonn
 cmp #"9"+1
 bcs :nonn
 sec
 sbc #"0"
 jmp setguardprog

:nonn
:rts rts

*-------------------------------
*
*  A C T   O N   K E Y P R E S S
*
*-------------------------------
actkey LDY #kspeed
:0 LDX #0
:1 DEX
 bne :2
 DEY
 BNE :0
 jmp PMOVE ;Run ant tracks

:2 lda keypress
 BPL :1

 CMP #kleft
 BNE :3
 JMP PLEFT

:3 CMP #kright
 BNE :4
 JMP PRIGHT

:4 CMP #kup
 BNE :5
 JMP PUP

:5 CMP #kdown
 BNE :6
 JMP PDOWN

:6 CMP #kbtn1
 BNE :9
 jmp butt1

:9 CMP #kbtn0
 BNE :10
 jmp butt0

:10 RTS

*-------------------------------
*
*  A C T   O N   J O Y S T I C K
*
*-------------------------------
actjoy jsr controller
 jsr buttons
 jsr getselect

 lda JSTKX
 bpl :1

 lda #1
 cmp jlast
 bne :jleft

 lda jcount
 beq :jleft1
 dec jcount
 rts

:jleft jsr jmove
 jmp PLEFT

:jleft1 jsr jrepeat
 jmp PLEFT

*-------------------------------
:1 beq :2

 lda #2
 cmp jlast
 bne :jright

 lda jcount
 beq :jright1
 dec jcount
 rts

:jright jsr jmove
 jmp PRIGHT

:jright1 jsr jrepeat
 jmp PRIGHT

*-------------------------------
:2 lda JSTKY
 bpl :3

 lda #3
 cmp jlast
 bne :jup

 lda jcount
 beq :jup1
 dec jcount
 rts

:jup jsr jmove
 jmp PUP

:jup1 jsr jrepeat
 jmp PUP

*-------------------------------
:3 beq :nomove

 lda #4
 cmp jlast
 bne :jdown

 lda jcount
 beq :jdown1
 dec jcount
 rts

:jdown jsr jmove
 jmp PDOWN

:jdown1 jsr jrepeat
 jmp PDOWN

*-------------------------------
:nomove lda #0
 sta jlast

 lda BUTT0
 bpl :nobtn0
 jmp butt0

:nobtn0 lda BUTT1
 bpl :rts
 jmp butt1

:rts rts

*-------------------------------
*
*  M A R Q U E E
*
*  run marquee
*
*-------------------------------
marquee dec antcount
 bne :ant1

 lda #jspeed
 sta antcount

 jmp PMOVE

:ant1 rts

*-------------------------------
*
*  J M O V E
*
*-------------------------------
jmove sta jlast

 lda #boxtimer
 sta jcount
 rts

bmove sta jlast

 lda #bethtimer
 sta jcount
 rts

jrepeat lda #1
 sta jcount
 rts

*-------------------------------
*
*  B U T T O N   0
*
*-------------------------------
butt0

* In editor: put down/delete piece
* In editor with links shown: change links
* In menu: pick up piece & exit menu

 lda inmenu
 beq :1
 jmp PICKUP

:1 lda linkmode ;links shown?
 beq :2 ;no
 jmp chglinks

:2 jmp PUT

*-------------------------------
*
*  B U T T O N   1
*
*-------------------------------
butt1

* In editor: go to menu
* In menu: return to builder

 lda inmenu
 beq :1
 jmp EXIT

:1 jmp MENU

*-------------------------------
* Temp development feature: Remove "required" mark from a block

UnRequire
 lda inmenu
 bne :rts

 jsr GET
 and #unreqmask
 jmp putblock

:rts
]rts rts

*-------------------------------
*
* C U T
*
* Cut to new screen
*
*-------------------------------
CUT lda inmenu
 bne ]rts

 jsr calcmat1

 LDY #0
 LDA (MATPTR),Y
 BEQ CANTCUT ;Screen 0 doesn't exist (officially)

 STA SCRNUM

 jsr getneighs

 jmp DoCleanCut

CANTCUT jmp rstorptr

*-------------------------------
CutToMenu
 jsr gr

 jsr retrievemenu

 jsr zeropeels

 jsr PMOVE

 lda $c057

 rts

*-------------------------------
DoCleanCut
 jsr gr

 lda #$20
 sta PAGE
 jsr DoSure

 lda #0
 sta PAGE
 jsr copyscrn

 jsr PMOVE
 lda $c057

 rts

*-------------------------------
* DoCut2: no blackout

DoCut2
 jsr DoSure

 jsr pageflip

 jsr copyscrn

 jmp PMOVE

*-------------------------------
*
* G E T N E I G H S
*
* Get neighboring screen #s
*
*-------------------------------
getneighs
 ldx #-1
 ldy #0
 jsr getneigh
 sta scrnLeft

 ldx #1
 ldy #0
 jsr getneigh
 sta scrnRight

 ldx #0
 ldy #-1
 jsr getneigh
 sta scrnAbove

 ldx #0
 ldy #1
 jsr getneigh
 sta scrnBelow

* & diagonals

 ldx #-1
 ldy #-1
 jsr getneigh
 sta scrnAboveL

 ldx #-1
 ldy #1
 jsr getneigh
 sta scrnBelowL

 ldx #1
 ldy #-1
 jsr getneigh
 sta scrnAboveR

 ldx #1
 ldy #1
 jsr getneigh
 sta scrnBelowR

 rts

*-------------------------------
*
* I N I T P O I N T
*
* initial placement of pointer
*
*-------------------------------
INITPOINT lda virgin ;first time in editor?
 beq :rts ;no
 lda #0
 sta virgin

* Put "pointer" (i.e., box) somewhere
* (X = 0-9, Y = 0-2)

 LDA #0
 STA POINTX
 LDA #1
 STA POINTY

 LDA #1 ;floor
 STA HELD ;Image id# of object in hand
 lda #0
 sta heldspec

* Put menu pointer in u.l. of menu screen 0

 lda #0
 sta savescrn
 sta savepx
 lda #1
 sta savepy

:rts lda #1
 sta size
 jsr gdist

 ldx HELD
 lda sizelist,x
 sta size
 rts

*-------------------------------
*
* P O I N T E R   L E F T / R I G H T / U P / D O W N
*
*-------------------------------
PLEFT jsr saveptr

 LDA POINTX
 SEC
 SBC #1
 BMI :1
 STA POINTX

 jsr getsize
 JMP PMOVE

:1 LDA #9
 STA POINTX

 jsr getsize
 jmp MLEFT

*-------------------------------
PRIGHT jsr saveptr
 jsr getdist

 LDA POINTX
 CLC
 ADC dright
 CMP #10
 BCS :1
 STA POINTX

 jsr getsize
 JMP PMOVE

:1 LDA #0
 STA POINTX

 jsr getsize
 jmp MRIGHT

*-------------------------------
PUP jsr saveptr
 jsr getdist

 LDA POINTY
 SEC
 SBC dup
 BMI :1
 STA POINTY

 jsr getsize
 JMP PMOVE

:1 LDA #2
 STA POINTY

 jsr getsize
 JSR MUP
 jmp CUT

*-------------------------------
PDOWN jsr saveptr

 LDA POINTY
 CLC
 ADC #1
 CMP #3
 BCS :1
 STA POINTY

 jsr getsize
 JMP PMOVE

:1 LDA #0
 STA POINTY

 jsr getsize
 JSR MDOWN
 jmp CUT

*-------------------------------
*
*  S A V E / R E S T O R E   P O I N T E R   P O S N
*
*-------------------------------
saveptr lda POINTX
 sta TEMPX
 lda POINTY
 sta TEMPY

 lda MATX
 sta TEMPMX
 lda MATY
 sta TEMPMY

 lda ULX
 sta TEMPULX
 lda ULY
 sta TEMPULY

 lda BLOCKX
 sta TEMPBX
 lda BLOCKX+1
 sta TEMPBX+1
 lda BLOCKY
 sta TEMPBY

 lda PTRX
 sta TEMPPX
 lda PTRY
 sta TEMPPY

 rts

*-------------------------------
rstorptr lda TEMPX
 sta POINTX
 lda TEMPY
 sta POINTY

 lda TEMPMX
 sta MATX
 lda TEMPMY
 sta MATY

 lda TEMPULX
 sta ULX
 lda TEMPULY
 sta ULY

 lda TEMPBX
 sta BLOCKX
 lda TEMPBX+1
 sta BLOCKX+1
 lda TEMPBY
 sta BLOCKY

 lda TEMPPX
 sta PTRX
 lda TEMPPY
 sta PTRY

 rts

*-------------------------------
*
*  P O I N T E R M O V E
*
*-------------------------------
PMOVE
 jsr sngpeel ;peel off old pointer

 jsr zeropeel ;zero just-used peelbuf

 DEC THIRD
 BPL :1
 LDA #2
 STA THIRD
:1
 LDA POINTX
 ASL
 ASL
 STA XCO

 LDA #0
 STA OFFSET

 LDY POINTY
 LDA BlockBot+1,Y
 STA YCO

 LDA #ora
 STA OPACITY

 LDA #1
 CLC
 ADC THIRD
 STA IMAGE

 jsr seted ;use edtable

 jsr layrsave
 jsr addpeel

 jsr lay

* Done

 jmp pageflip

*-------------------------------
*
*  G E T   S I Z E
*
*  size cursor to fit object it's holding
*  (only in menu)
*
*-------------------------------
]rts rts

getsize lda inmenu
 beq ]rts

 jmp gsize

*-------------------------------
*
*  G S I Z E
*
*  Get size of object under cursor
*  & move cursor to base piece
*
*-------------------------------
gsize jsr GET ;obj id#
 and #idmask
 sta tempid

 tax
 lda sizelist,x
 sta size

 lda baselist,x ;is cursor on base piece (l.l)?
 cmp tempid
 beq :rts ;yes--we're OK

* no--move cursor to base piece

 sta tempid

 lda size
 cmp #5
 bcc :wide

:tall lda POINTY
 clc
 adc posnlist,x
 sta POINTY
 cmp #3
 bcc :rts
 jmp cutdown

:wide lda POINTX
 sec
 sbc posnlist,x
 sta POINTX
 bpl :rts
 jmp cutleft

* Assume that in menu, pieces never
* overlap screen edges

:rts rts


*-------------------------------
getdist lda inmenu
 beq :rts
 jmp gdist
:rts rts

gdist ldx size
 lda uplist,x
 sta dup
 lda rtlist,x
 sta dright
 rts

*-------------------------------
*
*  G E T
*
*  Return contents of (SCRNUM: POINTX,POINTY) in A
*  (Sets BlueType, BlueSpec, bLinkIndex and Y)
*
*-------------------------------
GET LDA SCRNUM
 jsr bcalcblue

 LDY POINTY
 LDA Mult10,Y

 CLC
 ADC POINTX

 TAY

 LDA (BlueType),Y

 RTS

*-------------------------------
*
* P I C K U P
* (in menu)
*
*-------------------------------
PICKUP jsr GET
 and #idmask
 sta HELD

 lda (bLinkIndex),y
 sta special ;1=kid, 2=eye, etc.

 lda (BlueSpec),y
 sta heldspec

 jsr getsize

 lda #1
 sta dup
 sta dright

* picked up a special symbol?

 lda special
 beq :go

 cmp #seye
 bne :2

 lda #1
 sta linkmode ;show links
 jmp :go

:2

:go jsr leavem
 jmp CUT

*-------------------------------
*
*  C L E A R   M A T
*
*  Put object #objid on screen at (POINTX,POINTY)
*  Pass 1 (clearmat): clear away underlying objects
*
*  Return X = 0 if we can do it, -1 if we can't
*
*-------------------------------
clearmat lda SCRNUM
 sta origscrn

 lda objid
 pha
 lda POINTX
 pha
 lda POINTY
 pha
 lda MATX
 pha
 lda MATY
 pha

:loop jsr clearsec ;clear this section

 ldx objid
 lda linklist,x ;pointer to next section
 bmi :done ;ff is "end-of-list" code

 sta objid
 jsr getnext ;get position (up or right 1)
 jmp :loop ;& clear next section

:done ldx #0 ;can-do code

 lda SCRNUM
 bne :ok

* we ended up on screen 0--can't do it

 jsr gtone
 ldx #-1 ;can't-do-it code

:ok lda origscrn
 sta SCRNUM

 pla
 sta MATY
 pla
 sta MATX
 pla
 sta POINTY
 pla
 sta POINTX
 pla
 sta objid
 rts

*-------------------------------
*
*  P L A C E   M A T
*
*  Pass 2: place new object
*
*-------------------------------
placemat lda SCRNUM
 sta origscrn

 lda objid
 pha
 lda POINTX
 pha
 lda POINTY
 pha
 lda MATX
 pha
 lda MATY
 pha

:loop jsr placesec

 ldx objid
 lda linklist,x ;pointer to next section
 bmi :end ;ff is "end-of-list" code

 sta objid
 jsr getnext ;get next section (up or right 1)
 jmp :loop

* Done -- but does this object need floorpiece above?

:end cmp #$fe ;requires floorpiece on top?
 bne :done ;no
 jsr getabove

 lda andwhat
 bne :placing

* Removing object -- so unmark extra floorpiece
* (it's no longer required)

 jsr GET
 and #unreqmask ;turn off "required" flag
 jsr putblock
 jmp :done

* Placing object -- so mark floorpiece above it
* (or put a floorpiece there if there isn't one)

:placing jsr GET
 and #idmask
 bne :1

 jsr addsqr ;to redraw list
 jsr GET
 lda #1 ;floorpiece

:1 ora #reqmask
 jsr putblock

:done lda origscrn
 sta SCRNUM

 pla
 sta MATY
 pla
 sta MATX
 pla
 sta POINTY
 pla
 sta POINTX
 pla
 sta objid
 rts

*-------------------------------
*
*  C L E A R   S E C
*
*  Clear section; delete links
*  (If section is part of a composite object, remove
*  the whole thing)
*
*-------------------------------
clearsec
 lda size
 pha
 lda SCRNUM
 pha
 lda objid
 pha
 lda POINTX
 pha
 lda POINTY
 pha
 lda MATX
 pha
 lda MATY
 pha

 jsr gsize ;Get size--move POINTX,Y to base

 jsr GET ;base section

 jsr deletelink

 lda tempid
 sta objid

:loop lda #0
 sta propose ;what we want
 jsr GET
 jsr reqchek ;what we'll settle for
 jsr putblock
 jsr addsqr

 ldx objid
 lda linklist,x ;pointer to next section
 bmi :end ;ff is "end-of-list" code

 sta objid
 jsr getnext ;get next section (up or right 1)
 jmp :loop

:end cmp #$fe ;requires floorpiece on top or at right?
 bne :done ;no

 jsr getabove
 jsr GET
 and #unreqmask
 jsr putblock

:done pla
 sta MATY
 pla
 sta MATX
 pla
 sta POINTY
 pla
 sta POINTX
 pla
 sta objid
 pla
 sta SCRNUM
 pla
 sta size

:rts rts

*-------------------------------
*
*  P L A C E   S E C
*
*-------------------------------
placesec lda objid
 and andwhat ;placing or removing?
 sta propose
 jsr GET
 jsr reqchek
 jsr putblock

 lda heldspec
 sta (BlueSpec),y ;initial state of gadget

 jsr addsqr ;add square to list
]rts rts

*-------------------------------
* put A in (BlueType),Y
* In: A,Y ... trashes X

putblock ldx SCRNUM
 beq ]rts ;not scrn 0
 sta (BlueType),y
]rts rts

*-------------------------------
*
*  A D D   S Q R
*
* add this square to redraw buffer
*
* In: Y = block index
*
*-------------------------------
addsqr lda SCRNUM
 cmp origscrn
 bne ]rts
addsqr1
 jsr redsqr ;redraw this square

 iny ;& the one to right
 jsr redsqr

 tya
 sec
 sbc #10
 tay ;& the one to u.r.
 jsr redsqr

 dey ;& the one above
 jsr redsqr

]rts rts

*-------------------------------
redsqr cpy #30
 bcs ]rts

 lda #2
 sta redbuf,y
 sta wipebuf,y
 sta fredbuf,y

 lda #63 ;block height
 sta whitebuf,y

 rts

*-------------------------------
*
*  R E Q  C H E K
*
*  In:  A = id # of object currently occupying this space
*       propose = id # of object we'd like to put here
*
*-------------------------------
reqchek and #reqmask
 bne :requird
 lda propose ;carte blanche
 rts

:requird lda propose
 bne :ok
 lda #1 ;no--make it a floorboard instead
:ok ora #reqmask ;and mark it
 rts

*-------------------------------
getnext lda size
 cmp #5
 bcs tall

:wide inc POINTX
 lda POINTX
 cmp #10
 bcs cutrt
 rts

getabove
tall dec POINTY
 bmi cutup
 rts

*-------------------------------
getscrn jsr getscrn1
 sta SCRNUM
 rts

getscrn1 lda MATX
 bmi :1
 cmp #31
 bcs :1
 lda MATY
 bmi :1
 cmp #31
 bcs :1 ;off edge?
 jsr calcmat1
 ldy #0
 lda (MATPTR),y
 rts
:1 lda #0
 rts

cutleft lda POINTX
 clc
 adc #10
 sta POINTX
 dec MATX
 jmp getscrn

cutdown lda POINTY
 sec
 sbc #3
 sta POINTY
 inc MATY
 jmp getscrn

cutrt lda #0
 sta POINTX
 inc MATX
 jmp getscrn

cutup lda #2
 sta POINTY
 dec MATY
 jmp getscrn

*-------------------------------
* set kid starting block

setstart
 lda KidStartScrn
 cmp SCRNUM ;this screen?
 bne :cont

 ldy KidStartBlock
 jsr addsqr1 ;for redraw
:cont
 jsr GET
 cpy KidStartBlock ;kid already here?
 bne :1 ;no
;yes--toggle face
 lda KidStartFace
 eor #$ff
 sta KidStartFace
 jmp :2

:1 lda #-1
 sta KidStartFace

 sty KidStartBlock

 lda SCRNUM
 sta KidStartScrn

:2 jmp addsqr1 ;& redraw this block

*-------------------------------
* set guard starting block
* repeat clicks change guard position & delete guard

setguard
 ldx SCRNUM
 lda GdStartBlock-1,x ;previous starting posn for this scrn
 cmp #30
 bcs :cont ;none

 tay
 jsr addsqr1 ;redraw this square too

:cont
 jsr GET
 tya

 ldx SCRNUM
 cmp GdStartBlock-1,x
 bne :1

 lda GdStartFace-1,x
 bmi :3
;3rd press--delete guard
 lda #30 ;o.s.
 bne :4

:3 eor #$ff
 sta GdStartFace-1,x
 jmp :2

:1 lda #-1
 sta GdStartFace-1,x

 tya
:4 sta GdStartBlock-1,x

:2 jmp addsqr1 ;& redraw this block

*-------------------------------
*
* P U T
*
* Put down a copy of the piece you're holding
* (If this space already contains a piece identical to the one
* you're holding, then instead of placing it, remove it)
*
* Complication: if object partially overlaps a large-sized
* object, we have to delete the whole object, not just those
* portions overlapped by the new one.
*
* Also, if object is potentially linkable, assign it a
* link table index; if deleting or replacing a linkable
* object, remove its existing link table entry
*
*-------------------------------
SaveSpec ds 1

PUT
 lda heldspec
 sta SaveSpec

 lda special
 cmp #sstartkid
 bne :1

 jsr setstart ;set starting block
 jmp Cont1

:1 cmp #sstartguard
 bne :2

 jsr setguard
 jmp Cont1

:2
 lda #$ff
 sta andwhat ;ff if placing, 00 if removing

 jsr GET
 and #idmask
 sta existobj ;existing objid
 lda (BlueSpec),y
 sta existspec ;existing spec

 lda HELD
 sta objid

 cmp #panelwof
 beq SpPanel ;special handling for panels

 do DunjDisk
 else
 cmp #block
 beq SpBlock ;& blocks
 fin

 cmp #floor
 bne :11
 jmp SpFloor ;& for floorpieces placed on panels
:11
 cmp #gate
 bne :12
 jmp SpGate ;& for gates
:12
 cmp #flask
 bne :10
 jmp SpFlask ;& for flasks
:10
 cmp #space
 bne :15
 jmp SpSpace ;& for back panels

:15 cmp #exit
 bne :16
 jmp SpExit
:16

* Everything else: just place or remove

Continue lda existobj
 cmp objid
 bne Place

]remove lda #0
 sta andwhat

Place jsr clearmat ;update matrix (and keep track of which
  ;squares will need to be redrawn)
 cpx #-1
 beq Cont1 ;can't do it

 jsr placemat

 jsr assignlink

Cont1 lda SaveSpec
 sta heldspec

 jmp UpdateBG

*-------------------------------
* Placing gate on gate?

SpGate
 lda existobj
 cmp #gate
 bne Continue
;Yes--just change state
 lda existspec
 eor #3 ;toggle 1/2
;(Preserve existing links)
 sta (BlueSpec),y

 jsr addsqr1
]cont1 jmp Cont1
]cont jmp Continue
]place jmp Place
*-------------------------------
*  Placing a block

SpBlock
 lda existobj
 cmp #block
 bne ]cont

 lda existspec ;existing pattern
 bne ]remove
 lda #1
 sta heldspec
 bne ]place

*-------------------------------
*  Placing a panel

SpPanel
 lda existobj
 cmp #panelwof
 beq :ispanel
 cmp #panelwif
 beq :ispanel

* put panel on top of something else

 cmp #floor
 bne ]place ;panelwof

 lda #panelwif
 sta objid
 bne ]place ;panelwif

* put panel on top of panel

:ispanel lda heldspec ;desired pattern
 cmp existspec ;existing pattern
 beq :rempanel

* change only pattern

 lda existobj
 sta objid
 bne ]place

* remove panel

:rempanel lda existobj
 cmp #panelwof
 beq ]remove

 lda #floor
 sta objid
 bne ]place ;but leave floorpiece

* putting floor on top of panel

SpFloor
 lda existobj
 cmp #panelwof
 beq :addfloor
 cmp #panelwif
 beq :remfloor

 bne ]cont ;continue as usual

:addfloor lda #panelwif
 sta objid
 lda existspec
 sta heldspec
 jmp ]place

:remfloor lda #panelwof
 sta objid
 lda existspec
 sta heldspec
 jmp ]place

*-------------------------------
* Placing a flask

SpFlask
 lda existobj
 cmp #flask
 beq :y

 lda #0
 sta existspec
 jmp ]cont
:y ;Yes--just change state
 lda existspec
 clc
 adc #1

 cmp #8
 bcc :07
 lda #0

:07 sta (BlueSpec),y

 lda #1
 sta blackflag ;redraw entire screen

 jmp ]cont1

]cont jmp Continue
]place jmp Place
*-------------------------------
* Placing a back wall pattern on space or floor

SpSpace
 lda existobj
 cmp #space
 beq :1
 cmp #floor
 bne ]cont
:1
 ldx heldspec ;desired pattern
 beq ]cont
 sta objid
 cpx existspec ;existing pattern
 bne ]place ;add pattern
 lda #0
 sta heldspec
 beq ]place ;remove pattern

*-------------------------------
* Exit on exit-->window

SpExit
 lda existobj
 cmp #exit
 bne ]cont
 lda #window
 sta objid
 bne ]cont

*-------------------------------
*
* U P D A T E   B G
*
* We've added or deleted or changed an object --
* redraw as much of the screen as we have to
*
*-------------------------------
UpdateBG
 lda blackflag
 beq :1

 lda #0
 sta blackflag
;if blackflag set,
 jmp DoCut2 ;redraw entire scrn

:1
 jsr sngpeel ;peel off cursor
 jsr zeropeel
 jsr upscrn ;update screen squares listed in table

 jsr pageflip

 jsr sngpeel
 jsr zeropeel
 jsr upscrn ;other page too

 jsr PMOVE
 jmp PMOVE ;put cursor back on both scrns

*-------------------------------
upscrn jsr fast
 jsr drawall

 jsr zerolsts

 jsr specialsyms ;add special symbols

 jmp edges ;add edge arrows

*-------------------------------
*
*  A S S I G N   L I N K   I N D E X
*
* In: objid
*     Results of GET
* Out: X = link index
*
* Link table setup is different in editor than in game.
* Each controller (e.g. pressplate) and each gadget
* (e.g. portcullis) gets 4 bytes in link tables:
*
* L1 ... bLINK1,x     (where x=link index, 0-127)
* L2 ... bLINK2,x
* L3 ... bLINK3,x
* L4 ... bLINK4,x
*
* 21 bits of L1-L3 indicate whether each of the 21
* symbols is on or off (0=off) for this piece.
* Bit 7 of L4 indicates whether this link index has been
* assigned (0=free).
* Bits 1-6 of L4, and bit 7 of L1,L2 & L3, are unused for now.
*
*-------------------------------
assignlink

* First delete existing link index for this space (if any)

 jsr GET
 jsr deletelink

* Then create new link if appropriate

 sty ysave

 lda objid
 and andwhat
 tax
 lda linkable,x ;in eddata
 beq :rts ;object unlinkable

* Search thru link table to find first empty space

 ldx #0
:loop lda bLINK4,x
 bpl :gotit
 inx
 bpl :loop

* x=128 -- link table full

 jmp gtone

:gotit lda bLINK4,x
 ora #$80 ;set L4 hibit
 sta bLINK4,x

 lda #0
 sta bLINK1,x
 sta bLINK2,x
 sta bLINK3,x ;zero L1-3

 txa
 ldy ysave
 sta (bLinkIndex),y ;link index

* Link complete

:rts rts

*-------------------------------
*
*  D E L E T E   L I N K
*
*-------------------------------
deletelink
 lda (bLinkIndex),y
 bmi :rts ;unlinked

 tax ;link index

 lda #$7f
 and bLINK4,x ;clear hibit of bLINK4
 sta bLINK4,x ;to clear entry in linktable

 lda #$ff
 sta (bLinkIndex),y ;and unlink object

:rts rts

*-------------------------------
*
*  C L E A R   B L O C K
*
*  In: SCRNUM
*
*-------------------------------
CLRBLOCK lda SCRNUM
 jsr bcalcblue ;get bLinkIndex too (bBLUESPEC)

 LDY #29

:1 lda #0 ;initialize 30 spaces
 sta (BlueType),Y ;with linkless blanks

 lda #$ff
 sta (bLinkIndex),y
 sta (BlueSpec),y

 DEY
 BPL :1

* clr guard start posn

 ldx SCRNUM
 lda #30
 sta GdStartBlock-1,x
 lda #1
 sta GdStartProg-1,x

]rts RTS

*-------------------------------
* Set guard program #
* In: A = prog # (0-9)

setguardprog
 ldx SCRNUM
 sta GdStartProg-1,x
 lda #1
 sta blackflag ;redraw entire scrn
 jmp UpdateBG

*-------------------------------
*
*  M O V E   L / R / U / D
*
* Move from one screen to another
*
*-------------------------------
MLEFT lda inmenu
 bne :1
 jsr mleft
 jmp CUT
:1 rts

MRIGHT lda inmenu
 bne :1
 jsr mright
 jmp CUT
:1 rts

MUP lda inmenu
 bne :1
 jmp mup
:1 jmp menuup

MDOWN lda inmenu
 bne :1
 jmp mdown
:1 jmp menudown

*-------------------------------
menuup lda SCRNUM
 sec
 sbc #1
 sta nextscrn
 rts

menudown lda SCRNUM
 clc
 adc #1
 sta nextscrn
 rts

*-------------------------------
*
* M E N U
*
* Cut to menu screen
*
*-------------------------------
MENU lda #1
 sta inmenu
 lda #0
 sta linkmode

 jsr switchem

 lda SCRNUM
 sta nextscrn

 jsr bcalcblue

 jmp CutToMenu

*-------------------------------
switchem ldx savescrn
 lda SCRNUM
 sta savescrn
 stx SCRNUM

 ldx savepx
 lda POINTX
 sta savepx
 stx POINTX

 ldx savepy
 lda POINTY
 sta savepy
 stx POINTY

 rts

*-------------------------------
*
* L E A V E M
*
* Leave menu
* (pass object id# in HELD)
*
*-------------------------------
leavem jsr switchem

 lda #0
 sta inmenu
 rts

*-------------------------------
*
* E X I T
*
* Back to builder (make sure we're out of menu first)
*
*-------------------------------
EXIT lda inmenu
 beq :1
 jsr leavem

:1 jmp rtnbuild

*-------------------------------
*
*  E D G E S
*
*-------------------------------
edges
 lda inmenu
 bne :rts

 lda SCRNUM
 sta number
 jsr prscrnum ;print screen # at u.l.

 ldx SCRNUM
 lda GdStartBlock-1,x
 cmp #30
 bcs :99 ;no guard on this screen
 lda GdStartProg-1,x
 cmp #10
 bcc :ok ;correct screens created w/earlier versions
 lda #1 ;of editor--default to 1
 sta GdStartProg-1,x
:ok sta number
 jsr prgdprog ;print guard prog # in l.l.

:99 lda SCRNUM
 jsr getneighs

 lda scrnRight
 beq :1
 jsr rtedge

:1 lda scrnLeft
 beq :2
 jsr leftedge

:2 lda scrnBelow
 beq :3
 jsr botedge

:3 lda scrnAbove
 beq :4
 jsr topedge
:4

:rts
]rts rts

*-------------------------------
*
* S P E C I A L   S Y M S
*
* Add special symbols (kid, guard, etc.)
* not covered by FRAMEADV
*
*-------------------------------
specialsyms
 jsr AddKid
 jsr AddGuard
 rts

*-------------------------------
AddKid
 lda KidStartScrn
 cmp SCRNUM ;this screen?
 bne ]rts

 lda KidStartBlock
 jsr getxy

 lda KidStartFace
 eor #$ff
 sta OPACITY

 ldx #sstartkid
 jmp drawmenusym

AddGuard
 ldx SCRNUM
 lda GdStartBlock-1,x
 cmp #30
 bcs ]rts

 jsr getxy

 ldx SCRNUM
 lda GdStartFace-1,x
 eor #$ff
 sta OPACITY

 ldx #sstartguard
 jmp drawmenusym

*-------------------------------
* In: A = block # (0-29)
* Out: XCO, YCO

getxy
 jsr unindex

 asl
 asl
 sta XCO

 lda BlockBot+1,x
 sta YCO
 rts

*-------------------------------
*
* C H A N G E   L I N K S
*
*-------------------------------
chglinks
 jsr GET
 and #idmask
 sta objid
 lda (bLinkIndex),y
 ;sta objspec
 bmi :skipit ;unlinkable object
 sta linkindex

 jmp bethmode

:skipit rts

*-------------------------------
*
*  B E T H   M O D E
*
* Within the selected block:
*  Jstk moves blinking square (Beth) U-D, L-R
*  btn 0 adds/removes symbol
*  btn 1 exits link change mode
*
*-------------------------------
bethmode
 jsr initbeth ;start in l.r

:input lda $c000
 sta keypress
 bpl :nokey

 jsr edkeys ;always!

:nokey lda joyon
 beq :k

:j jsr bethjoy
 jsr blinkbeth

 lda BUTT1
 bpl :input
 bmi exitbeth ;exit link change mode

:k jsr bethkbd

 lda BUTT1
 bpl :input
 bmi exitbeth ;exit link change mode

*-------------------------------
exitbeth jsr sngpeel
 jsr pageflip
 jsr sngpeel ;take off beth

 jsr zeropeels

 jsr PMOVE
 jmp PMOVE ;put cursor back

*-------------------------------
initbeth
 lda #0 ;start in l.r.
 sta bethx ;0-2
 sta bethy ;0-6
 lda #1
 sta bethstatus ;on
 sta antcount
 rts

*-------------------------------
blinkbeth
 dec antcount
 bne :ant1

 lda #bjspeed
 sta antcount

 lda bethstatus
 eor #1
 sta bethstatus ;1/0

 jmp movebeth
:ant1 rts

*-------------------------------
bethkbd ;someday

*-------------------------------
bethjoy jsr controller
 jsr buttons
 jsr getselect

 lda JSTKX
 bpl :1

 lda #1
 cmp jlast
 bne :jleft

 lda jcount
 beq :jleft1
 dec jcount
 rts

:jleft jsr bmove
 jmp bethl

:jleft1 jsr jrepeat
 jmp bethl

*-------------------------------
:1 beq :2

 lda #2
 cmp jlast
 bne :jright

 lda jcount
 beq :jright1
 dec jcount
 rts

:jright jsr bmove
 jmp bethr

:jright1 jsr jrepeat
 jmp bethr

*-------------------------------
:2 lda JSTKY
 bpl :3

 lda #3
 cmp jlast
 bne :jup

 lda jcount
 beq :jup1
 dec jcount
 rts

:jup jsr bmove
 jmp bethu

:jup1 jsr jrepeat
 jmp bethu

*-------------------------------
:3 beq :nomove

 lda #4
 cmp jlast
 bne :jdown

 lda jcount
 beq :jdown1
 dec jcount
 rts

:jdown jsr bmove
 jmp bethd

:jdown1 jsr jrepeat
 jmp bethd

*-------------------------------
:nomove lda #0
 sta jlast

 lda BUTT0
 bmi bethbtn0

 rts

*-------------------------------
* Turn this symbol on/off

bethbtn0
 jsr togglebit

 ldy POINTY
 lda POINTX
 clc
 adc Mult10,y
 tay ;block index
 jsr redsqr

 lda SCRNUM
 jsr bcalcblue

 lda (bLinkIndex),y
 sta objspec

* update both scrns

 jsr sngpeel ;peel off cursor
 jsr zeropeel
 jsr upscrn ;update screen squares listed in table

 jsr redrawbeth

 jsr pageflip

 jsr sngpeel
 jsr zeropeel
 jsr upscrn ;other page too

 jsr redrawbeth

* put back beth cursor

 jsr movebeth
 jmp movebeth

*-------------------------------
togglebit
 ldx bethy
 lda bethbits,x ;bitmask--changing bit = 1, others 0
 ldx linkindex

 ldy bethx
 beq :L1
 cpy #1
 beq :L2

:L3 eor bLINK3,x
 sta bLINK3,x
 rts

:L1 eor bLINK1,x
 sta bLINK1,x
 rts

:L2 eor bLINK2,x
 sta bLINK2,x
:rts rts

*-------------------------------
* beth l,r,u,d

bethl lda bethx
 beq :rts
 dec bethx

:rts jmp movebeth

bethr lda bethx
 cmp #2
 bcs :rts
 inc bethx

:rts jmp movebeth

bethu lda bethy
 cmp #6
 bcs :rts
 inc bethy
:rts jmp movebeth

bethd lda bethy
 beq :rts
 dec bethy
:rts jmp movebeth

*-------------------------------
movebeth
 jsr sngpeel ;peel off old beth
 jsr zeropeel

 lda POINTX
 asl
 asl
 ldx bethx
 clc
 adc bethxco,x
 sta XCO

 lda bethoffset,x
 sta OFFSET

 ldx POINTY
 lda BlockBot+1,x
 ldx bethy
 sec
 sbc bethyco,x
 sta YCO

 lda bethstatus
 beq :bethoff

* Beth on: draw symbol normal or inverse depending
* on what's underneath

 jsr getbit
 beq :norm

:inv jsr invbethsym
 jmp pageflip

:norm jsr drawbethsym

* Beth off: invisible

:bethoff jmp pageflip

*-------------------------------
* Get bit -- 0 or nonzero

getbit ldx bethy
 lda bethbits,x
 ldx linkindex
 ldy bethx
 beq :L1
 dey
 beq :L2
:L3 and bLINK3,x
 rts
:L1 and bLINK1,x
 rts
:L2 and bLINK2,x
 rts

*-------------------------------
seted
 jsr zerocrop

 lda #edtable
 sta TABLE
 lda #>edtable
 sta TABLE+1
 rts

*-------------------------------
zerocrop
 lda #0
 sta TOPCUT
 sta LEFTCUT

 lda #40
 sta RIGHTCUT
 rts

*-------------------------------
*
*  R E D R A W   B E T H
*
* In: POINTY (0-2)
*     POINTX (0-9)
*     objspec
*
*-------------------------------
redrawbeth
 lda bethx
 pha
 lda bethy
 pha

 lda POINTX
 asl
 asl
 sta XCO

 lda #0
 sta OFFSET

 lda POINTY
 tay
 lda BlockBot+1,y
 sta loy

 jsr drawallsymb

:done pla
 sta bethy
 pla
 sta bethx

 rts

*-------------------------------
*
*  R E L I N K
*
*  Emergency measure should link data get messed up
*  Erases all links
*
*-------------------------------
RELINK
; jsr showpage

* Step 1: clear link tables

 jsr clrlinks

* Step 2: go through every object in every screen
* and assign a new link index to every linkable object

 lda #0 ;running counter (points to
 sta linkindex ;first available link index)

 lda SCRNUM
 pha

 lda NUMNEXT
 sec
 sbc #1
 sta SCRNUM

:loop jsr RelinkScrn ;do a screen

 dec SCRNUM
 bne :loop

 pla
 sta SCRNUM
 rts

*-------------------------------
RelinkScrn
 lda SCRNUM
 jsr bcalcblue

 ldy #29

:loop lda (BlueType),y
 and #idmask ;objid
 tax
 lda linkable,x ;in eddata
 beq :nolink ;object unlinkable

 lda linkindex
 bmi :nolink ;only space for 128 links

 sta (bLinkIndex),y ;link index
 tax

 lda #$80 ;set hibit
 sta bLINK4,x ;of bLINK4

 inc linkindex
 bne :next

:nolink lda #$ff ;no link
 sta (bLinkIndex),y
:next
 dey
 bpl :loop

]rts rts

*-------------------------------
 lst
eof ds 1
 usr $a9,25,$0000,*-org
 lst off
