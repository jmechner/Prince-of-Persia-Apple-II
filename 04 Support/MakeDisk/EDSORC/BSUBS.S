* bsubs
org = $7200
 lst off
*-------------------------------
*
*  B U I L D E R   S U B S
*
*-------------------------------
 org org

 JMP DBLHGR
 JMP DBLDRAW
 JMP MOVEBLOK
 JMP SWSINGLE
 JMP SWDOUBLE

 jmp SPECIALK
 jmp BCALCBLUE
 jmp TOPEDGE
 jmp BOTEDGE
 jmp LEFTEDGE

 jmp RTEDGE
 jmp PRBLOKNO
 jmp PRSCRNUM
 jmp MENUSPECIAL
 jmp DRAWBETHSYM

 jmp INVBETHSYM
 jmp DRAWALLSYMB
 jmp STOREMENU
 jmp DoDblCls
 jmp DoDblLay

 jmp DoDblFast
 jmp DoDblSave
 jmp DoDblWipe
 jmp DoDblPrint
 jmp DoDblImseek

 jmp PAGEFLIP
 jmp INPUT
 jmp DBLPEEL
 jmp RETRIEVEMENU
 jmp MOVESTUFF

 jmp DoDblOra
 jmp COPYAUXSCRN
 jmp DRAWMENUSYM
 jmp UNINDEX
 jmp SUPERGUARDS

 jmp INITINPUT
 jmp DRAWFLASKNO
 jmp PRGDPROG

*-------------------------------
 put eq
  put buildereq
 put movedata

*-------------------------------
* Local vars

 dum locals

rowno ds 1
yindex ds 1
colno ds 1
bitmask ds 1
temp ds 1

 dend

*-------------------------------
*  Key equates

SHIFT = $20
CTRL = $60

kleft = "h"-CTRL
kright = "u"-CTRL
kup = "k"-CTRL
kdown = "j"-CTRL

kbtn0 = " "
kbtn1 = RETURN

*-------------------------------
arrow = 3
blockn = 1

bluediff = BLUETYPE-bLINDEX

*-------------------------------
* EDTABLE shapes

ibox1 = 1
iwipe = 4
uparr = 5
dnarr = 6
lftarr = 7
rtarr = 8
digits = 9

kid = $13
eye = $14
guard = $2d

bethmask1 = $15
bethmask2 = $16

bethsyms hex 17,18,19,1a,1b,1c,1d,00
 hex 1e,1f,20,21,22,23,24,00
 hex 25,26,27,28,29,2a,2b,00

*-------------------------------
* initial states

initials db 0
 db 48*4 ;1: gate up
 db 0 ;2: gate down

*------------------------------
*
*  D B L H G R
*
*  Clear both double hi-res pages and display page 2
*  Also clear lo-res page 1
*
*-------------------------------
DBLHGR
 STA $C00C ;80COL off
 STA $C000 ;80STORE off
 STA $C07E ;IOUDIS on

 lda #0
 JSR lrcls ;Clear lo-res page 1 to black

 LDA $C054 ;Page 1
 LDA $C052 ;MIXED off
 LDA $C056 ;HIRES off
 LDA $C050 ;TEXT off

 LDA #0
 STA PAGE

 jsr DoDblCls

 LDA $C057 ;HIRES on
 STA $C00D ;80COL on
 STA $C05E ;DHIRES on

 LDA #$20
 STA PAGE

 jsr DoDblCls ;Clear hires p.2

 jsr zeropeels ;zero peel buffers

 lda #0
 sta TOPCUT

 rts

*-------------------------------
*
*  M O V E B L O C K
*
*  Move block (or pointer) from where it was 2 frames
*  ago to where BLOCKX and BLOCKY say it is now
*
*-------------------------------
MOVEBLOK
 jsr DBLPEEL ;peel off old block or pointer
;(using peel buffer we set up 2 frames ago)

 jsr DZEROPEEL ;zero just-used peel buffer

 jsr DRAWPTR ;draw new block or pointer

]rts rts

*-------------------------------
*
*  D Z E R O P E E L
*
*  Zero peel buffer for whichever page we're on
*
*-------------------------------
DZEROPEEL
 lda PAGE
 beq :page1

 lda #0
 sta peelX+maxpeel

 lda #dpeelbuf2
 sta PEELBUF
 lda #>dpeelbuf2
 sta PEELBUF+1
 rts

:page1 sta peelX

 lda #dpeelbuf1
 sta PEELBUF
 lda #>dpeelbuf1
 sta PEELBUF+1
 rts

*-------------------------------
*
*  D B L   D R A W   P T R
*
*  Draw block or pointer in current posn (BLOCKX,BLOCKY)
*
*-------------------------------
DRAWPTR

* "AND" blockmask

 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET

 LDA BLOCKY
 STA YCO

 LDA CURSOR ;1=block, 3=arrow
 CLC
 ADC #1 ;MASK
 STA IMAGE

 LDA #0
 STA OPACITY ;"AND"

 jsr dblsetup ;set up for dbllay

* Save underlayer in peel buffer

 jsr DoDblSave

 jsr addpeel ;in grafix

* Lay down image

 jsr DoDblLay

* "OR" block

 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET

 LDA BLOCKY
 STA YCO

 LDA CURSOR
 STA IMAGE

 LDA #1
 STA OPACITY ;"OR"

 jsr DBLDRAW

 lda CURSOR
 cmp #1 ;block?
 bne ]rts

 LDA BLOCKX
 STA XCO
 LDA BLOCKX+1
 STA OFFSET
 LDA BLOCKY
 STA YCO

 jmp prblokno ;print block #

*-------------------------------
*
*  D B L   P E E L
*
*  "Peel off" images laid down on this page
*
*-------------------------------
DBLPEEL
 ldx PAGE
 beq :1
 ldx #maxpeel
:1 stx :sm+1

 lda peelX,x ;# images in peel list
 beq :rts

:loop pha

 clc
:sm adc #0 ;0 or maxpeel
 tax

 lda peelIMGL,x
 sta IMAGE

 lda peelIMGH,x
 sta IMAGE+1

 lda peelX,x
 sta XCO

 lda peelY,x
 sta YCO

 lda #sta
 sta OPACITY

 jsr DoDblFast

 pla
 sec
 sbc #1
 bne :loop

:rts
]rts rts

*-------------------------------
*
*  P R S C R N U M
*
*  print screen # in u.l. corner
*  (single hi-res)
*
*-------------------------------
PRSCRNUM
 lda shownums
 beq ]rts

 lda #10
 sta YCO
 lda #0
 sta XCO
 sta OFFSET

 ldx number ;1-MAXBLOX
 lda digit1,x
 jsr sprint

 ldx number
 lda digit2,x
 jmp sprint

*-------------------------------
* print guard prog # in lower left

PRGDPROG
 lda #190
 sta YCO
 lda #0
 sta XCO
 sta OFFSET
 ldx number
 lda digit2,x
 jmp sprint

*-------------------------------
*
*  S I N G L E   H R   P R I N T
*
*  Single hires print
*  In: A = character (0-9 or space)
*
*-------------------------------
sprint
 cmp #" "
 beq :rts
 sec
 sbc #"0"
 sta addr
 clc
 adc #digits
 sta IMAGE

 lda #0
 sta OPACITY
 jsr genmaskor

 ldx addr
 lda OFFSET ;advance cursor
 clc
 adc chrbits,x
 sta OFFSET
:rts
]rts rts

*-------------------------------
*
*  P R I N T   B L O C K N O
*
*  print block # on face
*  (double hi-res)
*
*-------------------------------
PRBLOKNO
 lda shownums
 beq ]rts

 lda XCO
 clc
 adc #5
 sta charx

 lda OFFSET
 adc #0
 sta charx+1

 lda YCO
 clc
 adc #7
 sta chary

 jsr cvtx

 ldx number ;1-MAXBLOX
 lda digit1,x
 jsr print
 ldx number
 lda digit2,x
 jmp print

*-------------------------------
digit2
 asc "0123456789012345678901234"
digit1
 asc "          111111111122222"
chrbits
 db 6,4,6,6,6,6,6,6,6,6

*-------------------------------
*
* D B L   S E T U P
*
* In: IMAGE (image #)
* XCO/OFFSET (2-byte X-coord, 0-559)
* YCO (0-191)
* OPACITY (0-2)
* ("IXYO)
*
*-------------------------------
DBLDRAW jsr dblsetup
 jmp DoDblLay

*-------------------------------
dblsetup
 lda #dblimage
 sta TABLE
 lda #>dblimage
 sta TABLE+1

 jsr DoDblImseek ;setup starting addr of img table
 jmp cvtx ;convert xco to byte & offset

*-------------------------------
*
* S W   S I N G L E
*
* Switch from double to single hi-res
*
*-------------------------------
SWSINGLE
 STA $C00C ;80COL off
 STA $C05F ;DHIRES off
 rts

*-------------------------------
*
* S W  D O U B L E
*
* Switch from single to double hi-res
*
*-------------------------------
SWDOUBLE
 STA $C00D ;80COL on
 STA $C05E ;DHIRES on
]rts rts

*-------------------------------
*
* S P E C I A L   K E Y S
*
* In: ASCII code in A-reg, hibit set
*
*-------------------------------

ctrl = $60
shift = $20

ksoundsw = "s"
knum = "n"

* development section

krestart = "r"-ctrl
kreboot = "z"-ctrl

*-------------------------------
SPECIALK
 lda keypress
 jsr debugkeys

 lda keypress

 cmp #krestart
 bne :0
 jmp restartbldr

:0 cmp #kreboot
 bne :1

  jsr saveblue ;to aux
  jmp reboot

:1
*-------------------------------
:cont
 cmp #ksoundsw-ctrl
 beq soundsw

 cmp #knum-ctrl
 beq numsw

:2
]rts rts

*-------------------------------
soundsw ;lda sound
;eor #$ff
;sta sound
 jmp gtone

numsw lda shownums
 eor #1
 sta shownums
 lda #1
 sta setupflg
]rts rts

*-------------------------------
* INIT INPUT

INITINPUT

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
*  M E N U   S P E C I A L
*
*  Superimpose special stuff on b.g.
*
*  If this is menu screen, draw special symbols;
*  if not, draw flask #s;
*  if links are shown, draw beth rectangles
*
*-------------------------------
MENUSPECIAL
; lda inmenu
; ora linkmode
; beq ]rts ;neither special case
 lda SCRNUM
 jsr bcalcblue

 ldy #2 ;start at bottom

:row sty rowno

 lda BlockBot+1,y
 sta loy

 lda Mult10,y
 sta yindex

 lda #0
 sta colno

:loop asl
 asl
 sta XCO

 ldy yindex
 lda (bLinkIndex),y
 sta objspec

 lda (BlueType),y
 and #idmask
 sta objid

 jsr DRAWFLASKNO

 jsr DRAWALLSYMB

 lda inmenu
 beq :skip

 lda objspec
 beq :skip
 bmi :skip
 tax ;valid codes: 1-127

 lda loy
 sta YCO

 lda #0
 sta OPACITY ;don't mirror

 jsr DRAWMENUSYM
:skip
 inc yindex
 inc colno

 lda colno
 cmp #10
 bcc :loop

:nextln ldy rowno
 beq :done
 dey
 jmp :row

:done rts

*-------------------------------
*
* S U P E R   G U A R D S
*
* Superimpose guard figures on screen
* for each square with secmask marked
*
*-------------------------------
SUPERGUARDS
 lda SCRNUM
 jsr bcalcblue

 ldy #2 ;start at bottom

:row sty rowno

 lda BlockBot+1,y
 sta loy

 lda Mult10,y
 sta yindex

 lda #0
 sta colno

:loop asl
 asl
 sta XCO

 ldy yindex
 lda (BlueType),y
 and #secmask
 beq :skip

 lda loy
 sta YCO

 lda #0
 sta OPACITY ;don't mirror

 ldx #3 ;guard
 jsr DRAWMENUSYM
:skip
 inc yindex
 inc colno

 lda colno
 cmp #10
 bcc :loop

:nextln ldy rowno
 beq :done
 dey
 jmp :row

:done rts

*-------------------------------
*
*  B C A L C B L U E
*
*  In: A = screen # (1-24); NOT 0
*
*  Out: BlueType, BlueSpec, bLinkIndex
*
*-------------------------------
BCALCBLUE
 jsr calcblue ;returns BlueType, BlueSpec

* Now get bLinkIndex

 lda inmenu
 bne :calcmenu

 lda BlueType
 sec
 sbc #bluediff
 sta bLinkIndex

 lda BlueType+1
 sbc #>bluediff
 sta bLinkIndex+1

 rts

:calcmenu
 lda #menubspec
 sta bLinkIndex

 lda #>menubspec
 sta bLinkIndex+1

]rts rts

]bug jmp gtone

*-------------------------------
* Draw flask # (if object is a flask)

flaskbits hex 00,01,02,04,08,10,20,40

DRAWFLASKNO
 lda objid
 cmp #flask
 bne ]rts

 lda linkmode
 bne ]rts
 lda inmenu
 bne ]rts

 lda (BlueSpec),y
 tax
 cpx #8
 bcs ]rts

* Note--for convenience we'll use the beth routine

 lda #0
 sta linkbits
 sta linkbits+1

 lda flaskbits,x
 sta linkbits+2

 jmp drawallsymb1

*-------------------------------
*
*  D R A W   A L L   S Y M B
*
*  Draw all symbols in a beth rectangle
*
*  In: XCO, YCO, objspec
*
*-------------------------------
DRAWALLSYMB
 lda linkmode
 beq ]rts
 lda inmenu
 bne ]rts

 ldx objspec ;link index
 bmi ]rts ;ff=unlinkable object
;index range is 0-127
 lda bLINK4,x
 bpl ]bug ;hibit should be set

 lda bLINK1,x
 sta linkbits
 lda bLINK2,x
 sta linkbits+1
 lda bLINK3,x
 sta linkbits+2

* Three columns, L-R; take each one B-T

drawallsymb1
 lda #0
 sta bethx ;0-2
;XCO already set
:nextcol asl
 sta OFFSET ;0,2,4

 lda loy
 sta YCO

 lda #0
 sta bethy ;0-7

 lda #1
:loop sta bitmask
 ldx bethx
 and linkbits,x
 beq  :nextsym

 jsr drawbethsym1

:nextsym lda YCO
 sec
 sbc #8
 sta YCO

 inc bethy
 lda bitmask
 asl
 bne :loop ;cycle through all 8 bits

 inc XCO

 inc bethx
 lda bethx
 cmp #3
 bcc :nextcol

:done lda #0
 sta OFFSET

:rts rts

*-------------------------------
*
*  D R A W   B E T H   S Y M
*
* Draw a symbol
*
* In: XCO/OFFSET, YCO, bethposn
*
* DRAWBETHSYM1: no layrsave
*
*-------------------------------
drawbethsym1
 jsr setupbmask
 jsr lay

 jmp drawbrest

DRAWBETHSYM
 jsr setupbmask
 jsr layrsave
 jsr addpeel
 jsr lay

 jmp drawbrest

*-------------------------------
setupbmask
 jsr seted

* 1) AND mask1

 lda #bethmask1
 sta IMAGE

 lda #and
 sta OPACITY

]rts rts

*-------------------------------
drawbrest

* 2) OR symbol

 jsr getbsym
 beq ]rts
 sta IMAGE

 lda #ora
 sta OPACITY

 jmp lay

*-------------------------------
*
*  G E T   B E T H   S Y M
*
* in: bethx, bethy
* out: A =symbol #
*
*-------------------------------
getbsym lda bethx
 asl
 asl
 asl ;x8
 clc
 adc bethy
 tax

 lda bethsyms,x
 rts

*-------------------------------
*
*  I N V E R T   B E T H   S Y M
*
*-------------------------------
INVBETHSYM
 jsr DRAWBETHSYM

* (3) EOR mask2

 lda #bethmask2
 sta IMAGE

 lda #eor
 sta OPACITY

 jmp lay

*-------------------------------
*
*  E D G E   A R R O W S
*
*-------------------------------
*  IXYO: image,xco,offset,yco,[opacity]

te db #uparr,19,3,7
be db #dnarr,19,3,191
le db #lftarr,0,0,98
re db #rtarr,39,0,98

TOPEDGE lda #te
 ldx #>te
 bne drawej

BOTEDGE lda #be
 ldx #>be
 bne drawej

LEFTEDGE lda #le
 ldx #>le
 bne drawej

RTEDGE lda #re
 ldx #>re

*-------------------------------
*
*  D R A W   E J
*
*-------------------------------
drawej sta addr
 stx addr+1

 ldy #0
 lda (addr),y
 sta IMAGE

 iny
 lda (addr),y
 sta XCO

 iny
 lda (addr),y
 sta OFFSET

 iny
 lda (addr),y
 sta YCO

* general mask-or  sequence

genmaskor
 jsr seted

 lda OPACITY
 and #$80 ;preserve hi bit
 pha

 ora #mask
 sta OPACITY
 jsr lay

 pla
 ora #ora
 sta OPACITY
 jmp lay

*-------------------------------
seted
 lda #0
 sta TOPCUT
 sta LEFTCUT
 lda #40
 sta RIGHTCUT
 lda #192
 sta BOTCUT

 lda #edtable
 sta TABLE
 lda #>edtable
 sta TABLE+1

 lda #2
 sta BANK
 rts
*-------------------------------
*
*  D R A W   M E N U  S Y M
*
* draw menu symbol
*
* In: OPACITY (hi bit)
*     XCO, YCO; x = symbol #
* 1 = kid
* 2 = eye
* 3 = guard
*
*-------------------------------
msymi db 0,kid,eye,guard
msymx db 0,2,0,0
msymos db 0,4,0,2
msymy db 0,-10,-20,-10

msymxm db 0,5,0,7
msymosm db 0,0,0,4

DRAWMENUSYM
 lda msymi,x
 sta IMAGE

 lda msymy,x
 clc
 adc YCO
 sta YCO

 lda OPACITY
 bmi :mirror

 lda msymos,x
 sta OFFSET

 lda msymx,x
:1 clc
 adc XCO
 sta XCO

 jmp genmaskor

:mirror
 lda msymosm,x
 sta OFFSET

 lda msymxm,x
 jmp :1

*-------------------------------
*
*  S T O R E   M E N U
*
*  Draw menu screen #0 on page 2
*  & store it in "menuscrn" buffer
*  for fast retrieval later
*
*-------------------------------
STOREMENU
 lda PAGE
 pha
 lda SCRNUM
 pha

 jsr noneighs

 lda #$20
 sta PAGE

 lda #0
 sta SCRNUM

 lda #1
 sta inmenu

 jsr zeropeels
 jsr zerolsts
 jsr sure
 jsr drawall

 jsr menuspecial

 lda #0
 sta inmenu ;!
;and store it
 lda #>menuscrn
 sta IMAGE+1
 lda #$40
 sta IMAGE
 jsr copy2000ma ;main to aux

 pla
 sta SCRNUM
 pla
 sta PAGE
 rts

*-------------------------------
*
*  R E T R I E V E   M E N U
*
*  Copy onto both hires scrns
*
*-------------------------------
RETRIEVEMENU
 lda #$20 ;page1
 jsr :copy

 lda #$40 ;page2
:copy sta IMAGE+1

 lda #>menuscrn
 sta IMAGE

 jmp copy2000am ;aux to main

*-------------------------------
*
*  D O   D B L   R O U T I N E S
*
*  Dblhires routines sit in aux l.c.
*
*-------------------------------
DoDblCls
 jmp dblcls

DoDblLay
 jmp dbllay

DoDblFast
 jmp dblfast

DoDblSave
 jmp dblsave

DoDblWipe
 jmp dblwipe

DoDblPrint
 jmp dblprint

DoDblImseek
 jmp dblimseek

DoDblOra
 jmp dblora

*-------------------------------
*
*  P A G E F L I P
*
*-------------------------------
PAGEFLIP
 lda PAGE
 bne :1

 lda #$20
 sta PAGE
 lda $C054 ;show page 1
 rts

:1 lda #0
 sta PAGE
 lda $C055 ;show page 2
 rts

*-------------------------------
*
*  M O V E S T U F F
*
*  Called from BUILDER
*  Enter & exit w/ALTZP on
*
*-------------------------------
MOVESTUFF

* We need to copy HRTABLES from main l.c. to
* aux l.c.--first copy it into loading area

 sta $c008 ;ALTZP off

 lda #$20
 ldx #$e0
 ldy #$ee
 jsr movemem

 sta $c009 ;ALTZP on

* Now move stuff from loading area to aux l.c.
* (MASTER couldn't do this from main l.c.)

 lda #$d0
 ldx #$40
 ldy #$50
 jsr movemem ;aux bank 2

 lda #$e0
 ldx #$20
 ldy #$40
 jmp movemem ;the rest

*-------------------------------
*
*  I N P U T
*
*  Monitor keyboard and joystick for user commands
*  and return command # in A (0 = nothing)
*  Also return keypress, keydown
*
*-------------------------------
INPUT
 lda $C000
 sta keypress

 lda $C010
 sta keydown

 lda keypress
 bpl :nocmd ;no key down

 jsr specialk first check for special keys

* Keyboard control

 lda keypress

 cmp #kleft
 BNE :3
 lda #Cleft
 rts

:3 CMP #kright
 BNE :4
 lda #Cright
 rts

:4 CMP #kup
 BNE :5
 lda #Cup
 rts

:5 CMP #kdown
 BNE :nomove
 lda #Cdown
 rts

:nomove cmp #kbtn0
 bne :6
 lda #Cbtn0
 rts

:6 cmp #kbtn1
 bne :7
 lda #Cbtn1
 rts

:7
:nocmd
 lda joyon ;joystick mode?
 bne joystick ;yes

 lda #0 ;no cmd
]rts rts

*-------------------------------
*
*  J O Y S T I C K
*
* Joystick input
*
*-------------------------------
joystick
 jsr controller
 jsr buttons
 jsr getselect

 lda JSTKX
 bpl :1

 lda #1
 cmp jlast ;Same direction as last move?
 bne :jleft ;No--set timer & go ahead

 lda jcount ;Yes--is time up yet?
 beq :jleft1 ;Yes--go ahead
 dec jcount ;No--keep waiting
 lda #0
 rts

:jleft jsr jmove ;set timer
 lda #Cleft
 rts

:jleft1 jsr jrepeat ;set repeat timer
 lda #Cleft
 rts

:1 beq :2

 lda #2 ;"right"
 cmp jlast
 bne :jright

 lda jcount
 beq :jright1
 dec jcount
 lda #0
 rts

:jright jsr jmove
 lda #Cright
 rts

:jright1 jsr jrepeat
 lda #Cright
 rts

:2 lda JSTKY
 bpl :3

 lda #3
 cmp jlast
 bne :jup

 lda jcount
 beq :jup1
 dec jcount
 lda #0
 rts

:jup jsr jmove
 lda #Cup
 rts

:jup1 jsr jrepeat
 lda #Cup
 rts

:3 beq :nomove

 lda #4
 cmp jlast
 bne :jdown

 lda jcount
 beq :jdown1
 dec jcount
 lda #0
 rts

:jdown jsr jmove
 lda #Cdown
 rts

:jdown1 jsr jrepeat
 lda #Cdown
 rts

:nomove lda #0
 sta jlast

 lda BUTT0
 bpl :nobtn0

 lda #Cbtn0
 rts

:nobtn0 lda BUTT1
 bpl :nobtn1

 lda #Cbtn1
 rts
:nobtn1

:nocmd lda #0
 rts

*-------------------------------
*
* J M O V E
*
*-------------------------------
jmove sta jlast

 lda setupflg
 bne :done ;no delay (scroll's slow enough)

 lda CURSOR
 cmp #blockn
 beq :block ;slight delay

:pointer lda #10
 bne :gotit

:block lda #5

:gotit sta jcount

:done rts


jrepeat lda setupflg
 bne :done ;no delay

 lda CURSOR
 cmp #blockn
 beq :done

 lda #3
 sta jcount

:done rts

*-------------------------------
* no neighbors (for menu)

noneighs
 lda #0
 sta scrnLeft
 sta scrnRight
 sta scrnAbove
 sta scrnBelow
 sta scrnAboveL
 sta scrnBelowL
 sta scrnAboveR
 sta scrnBelowR
 rts

*-------------------------------
*
* C O P Y   A U X   S C R N
*
* Copy one aux hires page to the other
*
* In: PAGE = dest scrn (00/20)
*
*  (Use in conjunction with "copyscrn" in grafix
*  to copy dblhires screen)
*
*-------------------------------
COPYAUXSCRN
 lda PAGE
 clc
 adc #$20
 sta IMAGE+1 ;dest addr

 eor #$60
 sta IMAGE ;org addr

 jmp copyaux2000


*-------------------------------
*
*  C O P Y   A U X   2 0 0 0
*
*  Copy $2000 bytes within auxmem
*
*  In: IMAGE+1 = dest scrn, IMAGE = org scrn
*      (use hi byte of actual memory address)
*
*-------------------------------
copyaux2000
 lda IMAGE+1
 sta :dst+2
 lda IMAGE
 sta :org+2

 ldx #$20

 ldy #0
:loop
:org lda $2000,y
:dst sta $4000,y

 iny
 bne :loop

 inc :org+2
 inc :dst+2

 dex
 bne :loop

]rts rts

*-------------------------------
*
*  U N I N D E X
*
*  In: A = block index (0-29)
*  Out: A = tempblockx, X = tempblocky
*
*-------------------------------
UNINDEX
 ldx #0
:loop cmp #10
 bcc ]rts
 sec
 sbc #10
 inx
 bne :loop
;A = blockx, X = blocky
]rts rts

*-------------------------------
 lst
 ds 1
 usr $a9,23,$000,*-org
 lst off
