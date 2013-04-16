* draz
org = $800
 lst off
*-------------------------------
*
*   D   R   A   Z
*
*   Hi-res shape table maker (ProDOS/18-sector version)
*   Copyright 1986,1987,1988,1989 Jordan Mechner
*
*   Rev. 3/24/89, 4/10/89
*
*-------------------------------
 dum $20

BASE ds 2
ADDR1 ds 2
ADDR2 ds 2
ADDR3 ds 2
ADDR ds 2
PAC ds 2
PIC ds 2
string ds 2
temper ds 2

VCOUNT ds 1
WIDTH ds 1
DIGIT ds 1
TEMP1 ds 1

CURSOR ds 1
COLOR ds 1
COLRMASK ds 1
BOXON ds 1
UNDERBYTE ds 1
DX ds 1
DY ds 1
VECT ds 1

XFIX ds 1
YFIX ds 1
ALTMASK ds 1

NUMIMS ds 1
CH ds 1
CV ds 1

TABLEND ds 2
MEMFREE ds 2
IMLENG ds 2

IMNUM ds 1

FULSCR ds 1

SEQIND ds 1
SPEED ds 1
FREEZEF ds 1

DIMLENG ds 1

FLICKER ds 1
DELTA ds 1

XCSAVE ds 1
YCSAVE ds 1
OFSAVE ds 1

KIDX ds 1
KIDY ds 1

KEY ds 1

V2 ds 1
V3 ds 1
V4 ds 1
V5 ds 1
V8 ds 1
V9 ds 1
VA ds 1
VB ds 1
VC ds 1

bytechek ds 2
opac ds 1

editmode ds 1
edxfix ds 1
edyfix ds 1
edxco ds 1
edyco ds 1
temp ds 1

 dend
*-------------------------------
  put hrtableq
 put hrparams
hires = $8e00

 dum hires
cls ds 3
lay ds 3
diamond ds 3
 dend

blast18 = $9200

TABSTART = $6000
bufend = $8400

unused = $1D00
ANIMSEQ = $1D80
ANIMDX = $1E00
ANIMDY = $1E80
ZEROBUF = $1F00

bufstart = $4000

IDbyteA = $a9
IDbyteB = $ad
*-------------------------------
 org org

 jmp START
 jmp REENTRY
*-------------------------------
POINT hex 81,82,84,88,90,A0,C0
ODDS hex 80,D5,AA,FF
EVENS hex 80,AA,D5,FF
*-------------------------------
* Hires patches

MLAY lda opac
 ora #$80
 sta OPACITY
 jmp lay

LAY lda opac
 and #$7f
 sta OPACITY
 jmp lay

CLS jmp cls

DIAMOND jmp diamond

*-------------------------------
SPLITSC LDA #$FF
 STA FULSCR
 LDA $C053
 RTS
*-------------------------------
* Prepare for disk load or other upheaval

PREPARE LDA #0
 STA IMLENG
 STA IMLENG+1
 JSR BOX
 JSR BASCALC
 LDA UNDERBYTE
 STA (BASE),Y
 RTS
*-------------------------------
* Reset hi bits

RESETHI LDA #$20
 STA BASE+1
 LDY #0
 STY BASE
:1 LDA #$80
 ORA (BASE),Y
 STA (BASE),Y
 INY
 BNE :1
 INC BASE+1
 LDA BASE+1
 AND #$1F
 BNE :1
 RTS
*-------------------------------
*  Color (0-3) input in X-reg:

GETCOLR LDX COLOR

 LDA XCO
 ROR
 BCC :2

 LDA ODDS,X
 BMI :3

:2 LDA EVENS,X
:3 STA COLRMASK
 RTS
*-------------------------------
BASCALC LDY YCO
 LDA YLO,Y
 STA BASE
 LDA YHI,Y
 STA BASE+1
 LDY XCO
 RTS
*-------------------------------
*  EOR a box from (XFIX,YFIX) to (XCO,YCO) ... IF BOXON=1

BOX LDA BOXON
 BEQ :7

 LDA XCO
 CMP XFIX
 BCC :7
 LDA YCO
 CMP YFIX
 BCC :7

 LDY YFIX
 BEQ :2 ;TOP LINE O.S.
 DEY
 LDA YLO,Y
 STA BASE
 LDA YHI,Y
 STA BASE+1

 LDY XFIX
:1 LDA (BASE),Y
 EOR #$7F
 STA (BASE),Y

 INY
 CPY XCO
 BCC :1
 BEQ :1

* NOW EDGES

:2 LDX YFIX
 DEX
 CPX #191
 BCC :21

:29 INX

:21 LDA YLO,X
 STA BASE
 LDA YHI,X
 STA BASE+1

 LDY XFIX
 BEQ :22 ;LEFT EDGE O.S.
 DEY
 LDA (BASE),Y
 EOR #$40
 STA (BASE),Y

:22 LDY XCO
 CPY #39
 BCS :23 ;RIGHT EDGE O.S.
 INY
 LDA (BASE),Y
 EOR #$01
 STA (BASE),Y

:23 CPX YCO
 BCC :29
 BNE :25

 CPX #191
 BCC :29

* NOW THE BOTTOM

:25 LDX YCO
 CPX #191
 BEQ :7

 INX
 LDA YLO,X
 STA BASE
 LDA YHI,X
 STA BASE+1

 LDY XFIX
:8 LDA (BASE),Y
 EOR #$7F
 STA (BASE),Y

 INY
 CPY XCO
 BCC :8
 BEQ :8

:7 RTS
*-------------------------------
*   S   T   A   R   T

START jsr ZEROSWAP

 jsr RESETHI

 LDA #1
 STA SPEED

 LDA #2
 sta opac

 LDA #0
 sta editmode
 STA IMLENG
 STA IMLENG+1

 JSR NEWTABLE
 LDA #$FF
 STA ANIMSEQ
 bne reenter

REENTRY jsr ZEROSWAP

reenter lda #0
 STA FLICKER
 STA PAGE ;Use page 1
 LDA $C050
 LDA $C052
 LDA $C054
 LDA $C057
 LDA $C010

 LDA #20
 STA XCO
 STA XFIX
 LDX #0
 STX OFFSET
 LDA POINT,X
 STA CURSOR
 LDA #96
 STA YCO ;Center of screen
 STA YFIX

 jsr SPLITSC

START1 LDA #-1
 STA COLOR
 LDA #10
 STA VECT

 JSR BASCALC
 LDA (BASE),Y
 STA UNDERBYTE ;Init

 LDA #0
 STA BOXON ;Box off

 JSR HOME

LOOP1 JSR DISPINFO
*-------------------------------
* Main keyboard-input loop

LOOP LDA $C000
 BMI KEYDOWN

* Blink cursor

BLINK JSR BASCALC
 LDA CURSOR
 EOR (BASE),Y
 ORA #$80
 STA (BASE),Y

 JMP LOOP

* Someone pressed a key

KEYDOWN STA $C010

* Handle cursor movement

 CMP #"Q
 BNE :11
 LDX #-1
 LDY #-1
 JMP MOVE
:11 CMP #"W
 BNE :12
 LDX #0
 LDY #-1
 JMP MOVE
:12 CMP #"E
 BNE :13
 LDX #1
 LDY #-1
 JMP MOVE
:13 CMP #"A
 BNE :14
 LDX #-1
 LDY #0
 JMP MOVE
:14 CMP #"Z
 BNE :15
 LDX #-1
 LDY #1
 JMP MOVE
:15 CMP #"X
 BNE :16
 LDX #0
 LDY #1
 JMP MOVE
:16 CMP #"C
 BNE :17
 LDX #1
 LDY #1
 JMP MOVE
:17 CMP #"D
 BEQ :89
 JMP CONT

:89 LDX #1
 LDY #0

MOVE STX DX
 STY DY

 JSR BOX ;Erase box if on
 LDA VECT
 STA VCOUNT

* Leave a trail behind cursor

:25 JSR BASCALC

 LDA COLOR
 BPL :27
 LDA UNDERBYTE
 BMI :28

:27 JSR GETCOLR
 AND CURSOR
 CMP #$80
 BNE :29 ;Turn pixel on

 LDA CURSOR
 EOR #255
 ORA COLRMASK
 AND UNDERBYTE ;Turn pixel off
 BMI :28

:29 ORA UNDERBYTE
:28 STA (BASE),Y

* Move cursor

:26 LDA YCO
 CLC
 ADC DY
 CMP #192
 BCC :80
 CMP #225
 BCC :81
 LDA #0
 BEQ :80
:81 LDA #191
:80 STA YCO

 LDA OFFSET
 CLC
 ADC DX
 BPL :20
 DEC XCO
 CLC
 ADC #7
 BPL :21

:20 CMP #7
 BCC :21
 INC XCO
 SEC
 SBC #7

:21 STA OFFSET

 LDA XCO
 CMP #40
 BCC :82
 CMP #100
 BCS :83
 LDA #39
 STA XCO
 LDA #6
 STA OFFSET
 BNE :82
:83 LDA #0
 STA XCO
 STA OFFSET

* Store new underbyte

:82 JSR BASCALC
 LDA (BASE),Y
 STA UNDERBYTE

 LDX OFFSET
 LDA POINT,X
 STA CURSOR

 DEC VCOUNT
 BNE :25

 JSR PRXY
 JSR BOX

 JMP LOOP
*-------------------------------
* Other keys

* Set vector length 1-10

CONT CMP #"0
 BEQ :13
 BCC :1

 CMP #":
 BCS :1

:11 SEC
 SBC #"0
 BPL :12
:13 LDA #10
:12 STA VECT
 JMP LOOP
*-------------------------------
* Set color

:1 CMP #$88 ;LEFT (BLUE)
 BNE :2
 LDA #2
 BNE :33
:2 CMP #$95 ;RIGHT (RED)
 BNE :3
 LDA #1
 BNE :33
:3 CMP #$8A ;DOWN (BLACK)
 BNE :4
 LDA #0
 BEQ :33
:4 CMP #$8B ;UP (WHITE)
 BNE :5
 LDA #3
 BNE :33
:5 CMP #"S ;TRANSPARENT
 BNE :6
 LDA #-1
:33 STA COLOR

:34 JMP LOOP
*-------------------------------
* Fix a point
*  (as upper left corner of a box)

:6 CMP #"[
 BNE :7

 JSR BOX ;Erase box if on

 LDA XCO
 STA XFIX
 LDA YCO
 STA YFIX

 LDA #1
 STA BOXON
 JSR BOX

 JMP LOOP
*-------------------------------
*  Fill box with color

:7 CMP #"F
 BNE READSH

FILL LDA BOXON
 BEQ :73 ;Idiot-proofing: box must be on
 LDA COLOR
 BMI :73 ;and color must be set
 JSR BOX

 DEC XCO
 JSR GETCOLR
 STA ALTMASK
 INC XCO
 JSR GETCOLR

 LDX YCO

:71 LDA YLO,X
 STA BASE
 LDA YHI,X
 STA BASE+1

 LDY XCO

:72 LDA COLRMASK
 STA (BASE),Y

 PHA
 LDA ALTMASK
 STA COLRMASK
 PLA
 STA ALTMASK

 DEY
 BMI :74
 CPY XFIX
 BCS :72

:74 CPX #0
 BEQ :75
 DEX
 CPX YFIX
 BCS :71

:75 JSR BASCALC
 LDA (BASE),Y
 STA UNDERBYTE

 LDA #0
 STA BOXON
:73 JMP LOOP
*-------------------------------
*  Read shape into buffer

READSH CMP #"]
 BEQ :11
 JMP LAYDOWN
:11 JSR PICKUP
 JSR HOME
 JSR TABLINFO
 JSR NEWIM
 JMP LOOP1

PICKUP JSR BASCALC
 LDA UNDERBYTE
 STA (BASE),Y

PICKUP1 LDA #2
 STA IMLENG
 LDA #0
 STA IMLENG+1

 LDA #bufstart
 STA IMAGE
 LDA #>bufstart
 STA IMAGE+1

 LDA XCO
 SEC
 SBC XFIX
 CLC
 ADC #1
 LDY #0
 STA (IMAGE),Y
 STA WIDTH
 sta bytechek

 LDA YCO
 SEC
 SBC YFIX
 CLC
 ADC #1
 INY
 STA (IMAGE),Y
 sta bytechek+1

 LDA IMAGE
 CLC
 ADC #2
 STA IMAGE
 BCC :0
 INC IMAGE+1

:0 LDX YCO

:1 LDA YLO,X
 CLC
 ADC XFIX
 STA BASE

 LDA YHI,X
 STA BASE+1

 LDY #0

:2 LDA (BASE),Y
 ORA #$80
 STA (IMAGE),Y
 INY
 CPY WIDTH
 BCC :2

 LDA IMAGE
 CLC
 ADC WIDTH
 STA IMAGE
 BCC :21
 INC IMAGE+1

:21 LDA IMLENG
 CLC
 ADC WIDTH
 STA IMLENG
 BCC :3
 INC IMLENG+1

:3 CPX #0
 BEQ :4
 DEX
 CPX YFIX
 BEQ :1
 BCS :1

:4 RTS
*-------------------------------
*  Lay down image

LAYDOWN CMP #"M MIRROR
 BEQ LAYD2

LAYD1 CMP #$8D RETURN
 beq LAYD2

 cmp #"P
 bne BOXOFF

LAYD2 STA KEY

 LDA IMLENG
 ORA IMLENG+1
 BEQ :1 ;Empty image buffer

 JSR BOX
 JSR PLOP
 JSR BOX
 JMP LOOP
:1 JSR BEEP
 JMP LOOP

PLOP LDA #bufstart
 STA IMAGE
 LDA #>bufstart
 STA IMAGE+1

 ldy #0
 lda (IMAGE),y
 cmp bytechek
 bne :skip
 iny
 lda (IMAGE),y
 cmp bytechek+1
 beq :ok

:skip jmp BEEP

:ok LDA KEY
 CMP #"M
 BNE :notm
 JSR MLAY
 JMP :2

:notm cmp #"P
 bne :1
 jsr DIAMOND
 jmp :2

:1 JSR LAY

:2 JSR BASCALC
 LDA (BASE),Y
 STA UNDERBYTE

 RTS
*-------------------------------
BOXOFF CMP #"\
 BNE LEFTSHIFT

 JSR BOX

 LDA #0
 STA BOXON

 JMP LOOP
*-------------------------------
LEFTSHIFT CMP #"{
 BNE IOTAB
 LDA BOXON
 BEQ IOTAB ;Box must be on

*  Shift contents of image box 1 bit left (before ])
*  Step 1: Pick up image

 JSR BOX
 JSR PICKUP

*  Step 2: Save old XCO and OFFSET

 LDA XCO
 PHA
 LDA OFFSET
 PHA

*  Step 3: Shift 1 bit left

 LDA #6
 STA OFFSET
 LDA XFIX
 SEC
 SBC #1
 STA XCO

*  Step 4: Lay down shape in new position

:1 JSR PLOP

*  Step 5: Restore vars

 PLA
 STA OFFSET
 PLA
 STA XCO

 JSR BOX
 JMP LOOP1
*-------------------------------
*  INPUT TABLE FROM DISK

IOTAB CMP #"I
 BNE IOTAB2

 JSR SPLITSC
 JSR DTABIN
 lda NAMEBUF
 cmp #"@"
 beq :skip

 LDA TABSTART
 STA NUMIMS
 ASL
 TAX
 INX
 LDA TABSTART,X
 STA TABLEND
 LDA TABSTART+1,X
 STA TABLEND+1

 lda #$ff
 sta ANIMSEQ
 lda #0
 sta editmode

:skip JSR HOME
 JMP LOOP1
*-------------------------------
*  OUTPUT TABLE TO DISK

IOTAB2 CMP #"O
 BNE ANIMATE

 LDA NUMIMS
 STA TABSTART
 JSR SPLITSC
 JSR DTABOUT
 JSR HOME
 JMP LOOP1
*-------------------------------
ANIMATE CMP #$81 ;CTRL-A
 BEQ :1
 JMP TABLE

:1 LDA NUMIMS
 BNE :19
 JMP LOOP1

:19 LDA ANIMSEQ
 CMP #$FF ;EMPTY SEQ TABLE
 BNE ANIMRTN

*  Set default sequence (run thru all frames)

 LDX #1
:80 LDA #0
 STA ANIMDX-1,X
 STA ANIMDY-1,X
 TXA
 STA ANIMSEQ-1,X
 INX
 CMP NUMIMS
 BCC :80
 LDA #$FF
 STA ANIMSEQ-1,X

ANIMRTN JSR SPLITSC
 JSR PRNIMS

 LDA #23
 STA CV
 LDX #ANIM1
 LDY #>ANIM1
 JSR PRLINE ;Sequence/X/Y adjust/Playback?

:89 JSR GETCHAR
 CMP #"S
 BNE :90
 JMP SEQUENCE

:90 CMP #"X
 BNE :77
 JMP XENTER
:77 CMP #"Y
 BNE :91
 JMP YENTER

:91 CMP #"P
 BNE :92
 JMP PLAYBACK
:92 CMP #$9B ;ESC
 BEQ :93
 BNE :89

:93 JSR HOME
 JMP LOOP1

*  Enter frame #s in desired sequence, FF to end

SEQUENCE LDX #0
:2 STX SEQIND ;Sequence index
 JSR GETNUM
 LDX SEQIND
 STA ANIMSEQ,X
 CMP #$FF ;End-of-sequence code
 BEQ :1
 LDA #0
 STA ANIMDX,X
 STA ANIMDY,X
 INX
 BNE :2 ;255 frames max
:1 JMP ANIMRTN

*  Enter DX for each frame in seq

XENTER LDX #0
:2 STX SEQIND
 LDA ANIMSEQ,X
 CMP #$FF
 BEQ :1
 JSR GETDELT
 LDX SEQIND
 STA ANIMDX,X
 INX
 BNE :2
:1 JMP ANIMRTN

YENTER LDX #0
:2 STX SEQIND
 LDA ANIMSEQ,X
 CMP #$FF
 BEQ :1
 JSR GETDELT
 LDX SEQIND
 STA ANIMDY,X
 INX
 BNE :2
:1 JMP ANIMRTN

PLAYBACK LDA XCO
 STA XCSAVE
 LDA YCO
 STA YCSAVE
 LDA OFFSET
 STA OFSAVE

*  Get KIDX (0-255)

 LDA #0
 LDX XCO
 CPX #0
 BEQ :51
:50 CLC
 ADC #7
 DEX
 BNE :50
:51 CLC
 ADC OFFSET
 STA KIDX
 LDA YCO
 STA KIDY

 LDA #23
 STA CV
 LDX #ANIM3
 LDY #>ANIM3
 JSR PRLINE
 LDA #0
 STA FREEZEF
 LDA $C010

*  Play back sequence

:1 LDX #0
 STX SEQIND

:2 LDA FREEZEF
 BNE :nextf

*  GO mode only: delay loop

 LDX SPEED
:21 LDY #0
:22 DEY
 BNE :22
 DEX
 BNE :21

 LDA $C000
 BPL :nextf ;Next frame

*  Keydown

 STA $C010
 CMP #$8A ;Down (Slow down)
 BNE :11
 INC SPEED

:11 CMP #$8B ;Up (Speed up)
 BNE :12
 DEC SPEED

:12 CMP #"F ;Freeze-frame
 BNE :14
 LDA #1
 STA FREEZEF

:14 CMP #$9B ;ESC
 BNE :15

*  Escape

:99 LDA XCSAVE
 STA XCO
 LDA YCSAVE
 STA YCO
 LDA OFSAVE
 STA OFFSET

 JSR BASCALC
 LDA (BASE),Y
 STA UNDERBYTE
 JMP ANIMRTN

:15 CMP #"X ;X:clr screen btwn frames
 BNE :nextf
; LDA FLICKER
; EOR #$FF
; STA FLICKER

*  Next frame

:nextf LDA FREEZEF
 BEQ :3
:13 LDA $C000
 BPL :13
 STA $C010
 CMP #"F Frame advance
 BEQ :3
 CMP #$9B ESC
 BEQ :99

*  Adjust

 LDX SEQIND
 DEX
:40
 CMP #$88 LEFT
 BNE :41
 INC ANIMDX,X
 JSR BEEP
:41 CMP #$95 RIGHT
 BNE :42
 DEC ANIMDX,X
 JSR BEEP
:42 CMP #$8A DOWN
 BNE :43
 INC ANIMDY,X
 JSR BEEP
:43 CMP #$8B UP
 BNE :44
 DEC ANIMDY,X
 JSR BEEP
:44 CMP #"G
 BNE :13

 LDA #0
 STA FREEZEF

*  Continue

:3 LDA FLICKER
 BEQ :39
; JSR CLS

:39 LDX SEQIND
 LDA ANIMSEQ,X
 CMP #$FF
 BNE :31
 LDX #0
 STX SEQIND

:31 LDA ANIMSEQ,X
 ASL
 TAX
 DEX
 LDA TABSTART,X
 STA IMAGE
 LDA TABSTART+1,X
 STA IMAGE+1
 JSR CONVX
 LDA KIDY
 STA YCO
 JSR LAY ;Lay down image #SEQIND

 LDX SEQIND
 LDA KIDX
 SEC
 SBC ANIMDX,X
 STA KIDX

 LDA KIDY
 CLC
 ADC ANIMDY,X
 STA KIDY

 INC SEQIND
 TAX

 JMP :2
*-------------------------------
*  Put up table info

TABLE CMP #"T
 BNE :1

 LDA IMLENG
 ORA IMLENG+1
 BEQ :2

 JSR TABLINFO
 JSR CHOICES

:2 JSR HOME
 JMP LOOP1

:1 JMP NEWTAB

TABLINFO JSR SPLITSC

 JSR PRNIMS

 LDA #21
 STA CV
 LDX #LINE2
 LDY #>LINE2
 JSR PRLINE

 LDA #15
 STA CH
 LDA #21
 STA CV
 LDA #>TABSTART
 JSR PRBYTE
 LDA #TABSTART
 JSR PRBYTE

 LDA #20
 STA CH
 LDA TABLEND+1
 JSR PRBYTE
 LDA TABLEND
 JSR PRBYTE

 LDA #26
 STA CH
 JSR CALCFREE
 LDA MEMFREE+1
 JSR PRBYTE
 LDA MEMFREE
 JSR PRBYTE

 RTS

NEWIM LDA #22
 STA CV
 LDX #LINE3
 LDY #>LINE3
 JSR PRLINE

 LDA #19
 STA CH
 LDA #22
 STA CV
 LDA IMLENG+1
 JSR PRBYTE
 LDA IMLENG
 JMP PRBYTE
*-------------------------------
*  Table editing choices

CHOICES JSR TABLINFO

 JSR NEWIM

 LDA #23
 STA CV
 LDX #LINE4
 LDY #>LINE4
 JSR PRLINE

 lda #0
 sta editmode

:89 JSR GETCHAR

 CMP #"A
 BNE :90
 JMP ADD

:90 CMP #"D
 BNE :91
 JSR GETNUM
 CMP #$FF
 BEQ :94
 JMP DELETE

:91 CMP #"I
 BNE :92
 JSR GETNUM
 CMP #$FF
 BEQ :94
 JMP INSERT

:92 cmp #"R
 bne :notr
;Replace
 jsr GETNUM
 cmp #$ff
 beq :94
 jsr delete
 jmp INSERT

:notr CMP #$9B ;ESC
 BEQ :93
 BNE :89
:93 RTS

:94 JMP CHOICES

LINE1 asc "   images in table@"
LINE2 asc "Table takes up     .     (     free)@"
LINE3 asc "New image takes up      bytes@"
LINE4 asc "Add/Delete/Insert/Replace/ESCape?",60
 asc "@"
LINE5 asc "Image number?@"
INFO asc "Line 00   Byte 00   Offset 00       "
MNEMON asc "STA@"
ANIM1 asc "Sequence/X/Y adjust/Playback/ESCape?",60
 asc "@"
ANIM3 asc "F to freeze and frame-advance, G to go@"
ADJTXT asc "Delta-X or Y:@"
EDITLINE asc "Editing image@"
ot1 asc "AOSE"
ot2 asc "NRTO"
ot3 asc "DAAR"

*  Set opacity mnemonic text

setmnem ldx opac
 lda ot1,x
 sta MNEMON
 lda ot2,x
 sta MNEMON+1
 lda ot3,x
 sta MNEMON+2
 rts

*  Print x,y coordinates

PRXY LDA #5
 STA CH
 LDA #23
 STA CV
 LDA YCO
 JSR PRBYTE

 LDA #15
 STA CH
 LDA XCO
 JSR PRBYTE

 LDA #27
 STA CH
 LDA OFFSET
 JMP PRBYTE

*  Calculate amount of memory free

CALCFREE LDA #0
 SEC
 SBC TABLEND
 STA MEMFREE
 LDA #>bufend ;end of table storage area
 SBC TABLEND+1
 STA MEMFREE+1

 RTS

NEWTAB CMP #$8E ;Ctrl-N
 BEQ :1
 JMP FULLSC
:1 JSR NEWTABLE

 JSR HOME
 JSR TABLINFO
 JMP LOOP1

NEWTABLE LDA #0
 STA NUMIMS
 STA TABSTART
 LDA #TABSTART
 CLC
 ADC #3
 STA TABSTART+1
 STA TABLEND
 LDA #>TABSTART
 ADC #0
 STA TABSTART+2
 STA TABLEND+1

 lda #$ff
 sta ANIMSEQ
 RTS

*  Print "xx images in table"

PRNIMS LDA #20
 STA CV
 LDX #LINE1
 LDY #>LINE1
 JSR PRLINE
 LDA #0
 STA CH
 LDA #20
 STA CV
 LDA NUMIMS
 JMP PRBYTE

*  Wait for a keypress

GETCHAR LDA $C010

:1 LDA $C000
 BPL :1

 STA $C010
 RTS

*  Get 2-digit hex # from keyboard (1-IMNUM)

GETNUM JSR HOME

 JSR PRNIMS

:0 LDA #23
 STA CV
 LDX #LINE5
 LDY #>LINE5
 JSR PRLINE

:1 LDA #13
 STA CH
 JSR GETNYB
 CMP #$FF ;ESC
 BEQ :77
 ASL
 ASL
 ASL
 ASL
 CMP NUMIMS
 BEQ :2
 BCC :2
 JSR BEEP
 JMP :1
:2 STA IMNUM

 LDA DIGIT
 JSR PRCHAR
 JSR GETNYB
 CLC
 ADC IMNUM
 BEQ :3
 CMP NUMIMS
 BEQ :4
 BCS :3
:4 STA IMNUM
 LDA DIGIT
 JSR PRCHAR

 LDA IMNUM
:77 RTS

:3 JSR BEEP
 JMP :0

*  Get delta-X or delta-Y

GETDELT JSR HOME
:0 LDA #23
 STA CV
 LDX #ADJTXT
 LDY #>ADJTXT
 JSR PRLINE

 LDA #13
 STA CH
 JSR GETNYB
 ASL
 ASL
 ASL
 ASL
 STA DELTA

 LDA DIGIT
 JSR PRCHAR
 JSR GETNYB
 CLC
 ADC DELTA

 RTS

GETNYB LDA #$60 ;FLASHING CURSOR
 JSR PRCHAR
 DEC CH
:1 JSR GETCHAR
 CMP #$9B ;ESC
 BEQ :77
 CMP #"0
 BCC :3
 CMP #":
 BCC :2 ;0-9
 CMP #"A
 BCC :3
 CMP #"G
 BCS :3
* A-F
 STA DIGIT
 SEC
 SBC #$B7 ;ASSUME SHIFTLOCK
 RTS
* 0-9
:2 STA DIGIT
 SEC
 SBC #"0
 RTS

:3 JSR BEEP
 JMP :1
:77 LDA #$FF
 RTS
*-------------------------------
* Add image onto end of table
* ADD is equivalent to INSERT NUMIMS+1

NOROOM RTS
ADD LDA NUMIMS
 CLC
 ADC #1
 STA IMNUM
*-------------------------------
* Insert image into table in position #IMNUM
* (pushing the current image
* #IMNUM forward and making it image #IMNUM+1)

* Move entire image data block ahead 2 bytes

INSERT LDA NUMIMS
 CMP #127
 BCS NOROOM ;NO ROOM FOR ANOTHER IMAGE

 CLC
 ADC #1
 STA NUMIMS ;NUMIMS:=NUMIMS+1

 ASL
 ADC #1
 STA TEMP1 ;TEMP1:start of image data (2xNUMIMS +1)

 ADC #TABSTART
 STA ADDR1

 LDA #0
 ADC #>TABSTART
 STA ADDR1+1

 LDA TABLEND
 STA ADDR2
 LDA TABLEND+1
 STA ADDR2+1

 LDA ADDR2
 CLC
 ADC #2
 STA ADDR3

 LDA ADDR2+1
 ADC #0
 STA ADDR3+1

 JSR MOVE2

* For Y=NUMIMS+1 to IMNUM+1 step -1:
* TABSTART(Y) := TABSTART(Y-1) + 2 + IMLENG

 LDY NUMIMS ;Y is image #
 INY
 TYA
 ASL
 TAX
 DEX ;X is corresponding index (2y-1)

:1 LDA TABSTART-2,X
 CLC
 ADC #2
 STA temper

 LDA TABSTART-1,X
 ADC #0
 STA temper+1

 LDA temper
 CLC
 ADC IMLENG
 STA TABSTART,X

 LDA temper+1
 ADC IMLENG+1
 STA TABSTART+1,X

 DEY
 DEX
 DEX
 CPY IMNUM
 BNE :1

* For Y=IMNUM to 1 step -1: TABSTART(Y):=TABSTART(Y)+2

:3 LDA TABSTART,X
 CLC
 ADC #2
 STA TABSTART,X

 LDA TABSTART+1,X
 ADC #0
 STA TABSTART+1,X

 DEX
 DEX
 DEY
 BNE :3

* If this is an insert (i:e:, if IMNUM<NUMIMS), then
* make room for new image

 LDA IMNUM
 ASL
 TAX
 DEX
 LDA TABSTART,X
 STA ADDR1
 LDA TABSTART+1,X
 STA ADDR1+1

 LDA TABLEND
 CLC
 ADC #2
 STA ADDR2
 STA TABLEND

 LDA TABLEND+1
 ADC #0
 STA ADDR2+1
 STA TABLEND+1

* Move TABLEND pointer to where new end of table will be
* (last byte +1)

 LDX TEMP1
 LDA TABLEND
 CLC
 ADC IMLENG
 STA TABLEND
 STA ADDR3
 STA TABSTART,X

 LDA TABLEND+1
 ADC IMLENG+1
 STA TABLEND+1
 STA ADDR3+1
 STA TABSTART+1,X

 LDA IMNUM
 CMP NUMIMS
 BCS :5
 JSR MOVE2

:5 jsr copyimg

 JSR BEEP
 JSR TABLINFO
 lda #$ff
 sta ANIMSEQ
 JMP LOOP1
*-------------------------------
*  Copy image from buffer to table

copyimg LDA IMNUM
 ASL
 TAX
 DEX
 LDA TABSTART,X
 STA ADDR3
 LDA TABSTART+1,X
 STA ADDR3+1

 LDA #bufstart
 STA ADDR1
 LDA #>bufstart
 STA ADDR1+1

 LDA #bufstart
 CLC
 ADC IMLENG
 STA ADDR2

 LDA #>bufstart
 ADC IMLENG+1
 STA ADDR2+1

 LDA ADDR2
 SEC
 SBC #1
 STA ADDR2

 LDA ADDR2+1
 SBC #0
 STA ADDR2+1

 JMP MOVE1
*-------------------------------
*  ADDR3 < ADDR1.ADDR2 M
*  (DESTROYS ADDR1-3)
*  USE MOVE1 WHEN CLOSING A SPACE

MOVE1 LDY #0

:1 LDA (ADDR1),Y
 STA (ADDR3),Y

 LDA ADDR1+1
 CMP ADDR2+1
 BCC :11
 LDA ADDR1
 CMP ADDR2
 BCS :5

:11 INC ADDR3
 BNE :2
 INC ADDR3+1

:2 INC ADDR1
 BNE :3
 INC ADDR1+1

:3 BNE :1
:5 RTS

*  USE MOVE2 WHEN OPENING A SPACE
*  ADDR3 IS LAST BYTE OF DEST BLOCK

MOVE2 LDY #0

:1 LDA (ADDR2),Y
 STA (ADDR3),Y

 LDA ADDR1+1
 CMP ADDR2+1
 BCC :11
 LDA ADDR1
 CMP ADDR2
 BCS :5

:11 DEC ADDR3
 LDA ADDR3
 CMP #$FF
 BNE :2
 DEC ADDR3+1

:2 DEC ADDR2
 LDA ADDR2
 CMP #$FF
 BNE :3
 DEC ADDR2+1

:3 BNE :1
:5
]rts rts
*-------------------------------
*  Delete image #IMNUM from table
*  Rev. 10/2/88

delete LDX NUMIMS
 BEQ ]rts

 CPX IMNUM
 BEQ :2

*  If IMNUM<NUMIMS, pull in chunk of table following
*  deleted image
*  ADDRn < ADDRn+1 . TABLEND M

 LDA IMNUM
 ASL
 TAX
 DEX

 LDA TABSTART,X
 STA ADDR3
 LDA TABSTART+1,X
 STA ADDR3+1

 LDA TABSTART+2,X
 STA ADDR1
 LDA TABSTART+3,X
 STA ADDR1+1

 LDA TABLEND
 STA ADDR2
 LDA TABLEND+1
 STA ADDR2+1

 JSR MOVE1

*  DIMLENG := TABSTART(IMNUM+1) - TABSTART(IMNUM) + 2

 LDA IMNUM
 ASL
 TAX
 DEX

 LDA TABSTART,X
 STA ADDR1
 LDA TABSTART+1,X
 STA ADDR1+1

 LDA TABSTART+2,X
 SEC
 SBC ADDR1
 STA DIMLENG

 LDA TABSTART+3,X
 SBC ADDR1+1
 STA DIMLENG+1

 LDA DIMLENG
 CLC
 ADC #2
 STA DIMLENG

 LDA DIMLENG+1
 ADC #0
 STA DIMLENG+1

*  For Y=IMNUM+1 to NUMIMS: TABSTART(Y):=TABSTART(Y+1)-DIMLENG

 LDY IMNUM
 INY ;Y is image #
 TYA
 ASL
 TAX
 DEX ;X is index # (2y-1)

:1 LDA TABSTART+2,X
 SEC
 SBC DIMLENG
 STA TABSTART,X

 LDA TABSTART+3,X
 SBC DIMLENG+1
 STA TABSTART+1,X

 INX
 INX
 INY
 CPY NUMIMS
 BCC :1
 BEQ :1

*  For Y=IMNUM to 1 step -1: TABSTART(Y) := TABSTART(Y)-2

:2 LDA IMNUM
 ASL
 TAX
 DEX

:3 LDA TABSTART,X
 SEC
 SBC #2
 STA TABSTART,X

 LDA TABSTART+1,X
 SBC #0
 STA TABSTART+1,X

 DEX
 DEX
 cpx #$ff
 bne :3

*  TABLEND := TABSTARTnumims

:4 LDA NUMIMS
 ASL
 TAX
 DEX
 LDA TABSTART,X
 STA TABLEND
 LDA TABSTART+1,X
 STA TABLEND+1

 DEC NUMIMS

*  Move data block 2 bytes to left
*  TABSTART(1) < TABSTART(1) + 2 : TABLEND+2 M

 LDA TABSTART+1
 STA ADDR3
 CLC
 ADC #2
 STA ADDR1

 LDA TABSTART+2
 STA ADDR3+1
 ADC #0
 STA ADDR1+1

 LDA TABLEND
 CLC
 ADC #2
 STA ADDR2

 LDA TABLEND+1
 ADC #0
 STA ADDR2+1

 JSR MOVE1

 rts
*-------------------------------
DELETE
 ldx NUMIMS
 beq :rts

 jsr delete

 JSR BEEP
 JSR TABLINFO
 lda #$ff
 sta ANIMSEQ
 JMP LOOP1

:rts rts
*-------------------------------
*  Info display line across bottom of screen

DISPINFO jsr setmnem

 LDA #23
 STA CV
 LDX #INFO
 LDY #>INFO
 JSR PRLINE
 JSR PRXY

 lda editmode
 beq :skip

 lda #22
 sta CV
 ldx #EDITLINE
 ldy #>EDITLINE
 jsr PRLINE

 lda #14
 sta CH
 lda #22
 sta CV
 lda IMNUM
 jsr PRBYTE

:skip rts
*-------------------------------
*  Full screen graphics

FULLSC CMP #"H
 BNE GET
 LDA FULSCR
 EOR #$FF
 STA FULSCR
 BNE :1
 LDA $C052
 JMP LOOP
:1 LDA $C053
 JMP LOOP
*-------------------------------
*  BEEP speaker

BEEP LDA #$40
 JSR :1
 LDY #$C0
:4 LDA #$0C
 JSR :1
 LDA $C030
 DEY
 BNE :4
 RTS
:1 SEC
:2 PHA
:3 SBC #1
 BNE :3
 PLA
 SBC #1
 BNE :2
 RTS
*-------------------------------
*  GET image from table - load into buffer

GET CMP #"G
 BNE TEMP

 JSR SPLITSC
 LDA NUMIMS
 BEQ :81

 JSR GETNUM
 CMP #$FF
 BEQ :81

 jsr retrieve

:81 JMP LOOP1
*-------------------------------
* Clear screen

TEMP CMP #$80 ;CTRL-@
 BNE GOWAN1
 JSR CLS
 JMP START1
*-------------------------------
*  Copy image #IMNUM into buffer

retrieve LDA IMNUM
 ASL
 TAX
 DEX
 LDA TABSTART,X
 STA ADDR1
 LDA TABSTART+1,X
 STA ADDR1+1

 INX
 INX
 LDA TABSTART,X
 STA ADDR2
 SEC
 SBC ADDR1
 STA IMLENG

 LDA TABSTART+1,X
 STA ADDR2+1
 SBC ADDR1+1
 STA IMLENG+1

 LDA #bufstart
 STA ADDR3
 LDA #>bufstart
 STA ADDR3+1

 JSR MOVE1

 lda bufstart
 sta bytechek
 lda bufstart+1
 sta bytechek+1

 rts
*-------------------------------
*  UNPACK

GOWAN1 CMP #"U
 BNE GOWAN2

 JSR PREPARE
 JSR SPLITSC
 JSR DUNPAC
 JMP START1
*-------------------------------
*  QUIT

GOWAN2 CMP #$91 ;CTRL-Q
 BNE GOWAN3

 JSR ZEROSWAP
 LDA $C051
 LDA $C053
 JSR $FC58 ;HOME
 JMP $FF66 ;MON
*-------------------------------
*  CATALOG

GOWAN3 CMP #$83 ;CTRL-C
 BNE GOWAN35

 LDA $C051
 JSR CATALOG

 LDA $C010
:1 LDA $C000
 BPL :1
 LDA $C010

 LDA $C050

 JSR HOME
 JMP LOOP1
*-------------------------------
* DISK CMD

GOWAN35 CMP #$84 ;CTRL-D
 BNE GOWAN4

 JSR PREPARE
 JSR SPLITSC
 JSR DISKCMD
 JMP START1
*-------------------------------
*  RESET HI BITS

GOWAN4 CMP #"R
 BNE GOWAN5

 JSR RESETHI
 JMP LOOP
*-------------------------------
*  PACK

GOWAN5 CMP #$90 ;CTRL-P
 BNE GOWAN6

 JSR BASCALC
 LDA UNDERBYTE
 STA (BASE),Y

 JSR SPLITSC
 JSR DPAC
 JSR HOME
 JMP LOOP1
*-------------------------------
* Blast image table onto 18-sector disk in drive 2

GOWAN6 cmp #$82 ;ctrl-B
 bne gowan7

 lda NUMIMS
 sta TABSTART
 jsr SPLITSC

 jsr BLAST

 jsr HOME
 jmp LOOP1
*-------------------------------
* Change opacity (0-3)

gowan7 cmp #"="
 bne gowan8

 lda opac
 cmp #3
 bne :1
 lda #-1
:1 clc
 adc #1
 sta opac

 jmp LOOP1
*-------------------------------
* Edit an image

gowan8 cmp #$85 ;ctrl-E
 beq edit
 cmp #$86 ;ctrl-F
 beq finished
 cmp #$98 ;ctrl-X
 beq exit
 jmp gowan9

* Enter (or reenter) edit mode

edit jsr SPLITSC
 lda NUMIMS
 beq :skip
 jsr GETNUM
 cmp #$ff
 beq :skip

 lda IMNUM
 asl
 tax
 dex
 lda TABSTART,x
 sta IMAGE
 lda TABSTART+1,x
 sta IMAGE+1

 lda #0
 sta OFFSET
 jsr lay ;lay down orig. image

 jsr BASCALC
 lda (BASE),y
 sta UNDERBYTE

 ldy #0
 lda XCO
 sta edxfix
 clc
 adc (IMAGE),y
 sec
 sbc #1
 sta edxco

 iny
 lda YCO
 sta edyco
 sec
 sbc (IMAGE),y
 clc
 adc #1
 sta edyfix ;get boundaries

 lda #$ff
 sta editmode

:skip jmp LOOP1

* Exit edit mode

exit lda #0
 sta editmode
 jsr HOME
 jmp LOOP1

* Finished editing

finished lda editmode
 beq :skip

 jsr BASCALC
 lda UNDERBYTE
 sta (BASE),y

 lda XCO
 pha
 lda YCO
 pha
 lda XFIX
 pha
 lda YFIX
 pha

 lda edxco
 sta XCO
 lda edyco
 sta YCO
 lda edxfix
 sta XFIX
 lda edyfix
 sta YFIX

 jsr PICKUP1

 pla
 sta YFIX
 pla
 sta XFIX
 pla
 sta YCO
 pla
 sta XCO

 jsr copyimg ;copy img from buffer to table
 jsr BEEP
:done jmp exit

:skip jmp LOOP1

*-------------------------------
gowan9 jmp LOOP
*-------------------------------
*  Convert KIDX (0-255) to XCO & OFFSET

CONVX LDA KIDX

 LDY #0
:3 CMP #7
 BCC :4
 SEC
 SBC #7
 INY
 BNE :3
:4 STA OFFSET
 STY XCO
 RTS
*===============================
UNPACK LDA #0
 STA PAC
 LDA #$40
 STA PAC+1
 LDA #$FE
 STA V8
 LDA #0
 STA VA
 LDY #$27
:4 LDA #$78
 STA V2
 LDA #$20
 STA V3
:0 LDA V2
 SEC
 SBC #$28
 STA V2
 BCS :1
 DEC V3
:1 LDA V2
 STA V4
 LDA V3
 CLC
 ADC #4
 STA V5
:2 LDA V4
 SEC
 SBC #$80
 STA V4
 BCS :3
 DEC V5
:3 LDA V4
 STA PIC
 LDA V5
 CLC
 ADC #$20
 STA PIC+1
:5 LDA PIC+1
 SEC
 SBC #4
 STA PIC+1
 CLC
 BCC :6
:13 LDA PIC+1
 CMP V5
 BNE :5
 LDA V4
 CMP V2
 BNE :2
 LDA V5
 CMP V3
 BNE :2
 LDA V2
 BNE :0
 DEY
 BPL :4
 RTS
:6 BIT VA
 BMI :11
 LDX #0
 LDA (PAC,X)
 STA VB
 CMP V8
 BNE :10
 INC PAC
 BNE :7
 INC PAC+1
:7 LDA (PAC,X)
 STA V9
 INC PAC
 BNE :8
 INC PAC+1
:8 LDA (PAC,X)
 STA VB
 INC PAC
 BNE :9
 INC PAC+1
:9 LDA #$80
 STA VA
 CLC
 BCC :11
:10 LDA VB
 ORA #$80
 STA (PIC),Y
 INC PAC
 BNE :12
 INC PAC+1
:12 CLC
 BCC :13
:11 LDA VB
 ORA #$80
 STA (PIC),Y
 DEC V9
 BNE :13
 LDA #0
 STA VA
 BEQ :13
*-------------------------------
PACK LDA #0
 STA PAC
 LDA #$40
 STA PAC+1
 LDA #$FE
 STA V9
 LDA #$80
 STA VB
 LDA #0
 STA VC
 LDY #$27
:1 LDA #$78
 STA V2
 LDA #$20
 STA V3
:2 LDA V2
 SEC
 SBC #$28
 STA V2
 BCS :3
 DEC V3
:3 LDA V2
 STA V4
 LDA V3
 CLC
 ADC #4
 STA V5
:4 LDA V4
 SEC
 SBC #$80
 STA V4
 BCS :5
 DEC V5
:5 LDA V4
 STA PIC
 LDA V5
 CLC
 ADC #$20
 STA PIC+1
:6 LDA PIC+1
 SEC
 SBC #4
 STA PIC+1
 CLC
 BCC :7
:8 LDA PIC+1
 CMP V5
 BNE :6
 LDA V4
 CMP V2
 BNE :4
 LDA V5
 CMP V3
 BNE :4
 LDA V2
 BNE :2
 DEY
 BPL :1
 LDA #$80
 STA VC
 CLC
 BCC :15
:7 LDA (PIC),Y
 BIT VB
 BMI :15
 CMP V8
 BNE :15
 LDX VA
 CPX #$FF
 BEQ :15
 INC VA
 INX
 CPX #4
 BCS :10
:9 CMP V9
 BEQ :10
 LDX #0
 STA (PAC,X)
 INC PAC
 BNE :10
 INC PAC+1
:10 STA V8
 CLC
 BCC :8
:15 TAX
 PHA
 TYA
 PHA
 TXA
 LDX #0
 CMP V9
 BNE :11
 LDY #2
 STA (PAC),Y
 INX
:11 LDA PAC
 SEC
 SBC #3
 STA PAC
 BCS :12
 DEC PAC+1
:12 BIT VB
 BMI :14
 LDA VA
 CMP #4
 BCS :13
 LDA V8
 CMP V9
 BNE :14
:13 LDY #0
 LDA V9
 STA (PAC),Y
 INY
 LDA VA
 STA (PAC),Y
:14 STX VB
 LDA PAC
 CPX #1
 CLC
 BNE :16
 ADC #6
 CLV
 BVC :17
:16 ADC #3
:17 STA PAC
 BCC :18
 INC PAC+1
:18 LDA #1
 STA VA
 PLA
 TAY
 PLA
 BIT VC
 BPL :9
 RTS
*===============================
* Text & disk routines

TYLO hex 0080008000800080
 hex 28A828A828A828A8
 hex 50D050D050D050D0

TYHI hex 0404050506060707
 hex 0404050506060707
 hex 0404050506060707
*-------------------------------
HOME LDY #$F7
 LDA #$A0
:2 STA $400,Y
 STA $500,Y
 STA $600,Y
 STA $700,Y
 DEY
 CPY #$80
 BNE :3
 LDY #$77
:3 CPY #$FF
 BNE :2
 RTS
*-------------------------------
SETLINE LDY CV
 LDX TYLO,Y
 STX BASE
 LDX TYHI,Y
 STX BASE+1
 RTS
*-------------------------------
PRCHAR LDY CH
 STA (BASE),Y
 INY
 CPY #40
 BCC :1
 LDX CV
 CPX #23
 BCS :2
 INC CV
 JSR SETLINE
:2 LDY #0
:1 STY CH
 RTS
*-------------------------------
PRBYTE JSR SETLINE
 PHA
 LSR
 LSR
 LSR
 LSR
 JSR :1
 PLA
 AND #$0F
:1 ORA #$B0
 CMP #$BA
 BCC PRCHAR
 ADC #$06
 SEC
 BCS PRCHAR
*-------------------------------
PRLINE STX ADDR
 STY ADDR+1

 JSR SETLINE

 LDY #0

:1 LDA (ADDR),Y
 cmp #"@"
 beq :eol
 STA (BASE),Y

 INY
 CPY #40
 BCC :1

:newline LDA #0
 STA CH

 LDA CV
 CMP #23
 BEQ :2

 INC CV

:2 RTS

:eol lda #$a0
:loop sta (BASE),y
 iny
 cpy #40
 bcc :loop
 bcs :newline
*-------------------------------
*  ProDOS interface

GETLN = $FD6A
MONHOME = $FC58
out = $200
*-------------------------------
* Swap zpage & ZEROBUF

ZEROSWAP LDX #0
:1 LDA ZEROBUF,X
 TAY
 LDA $0,X
 STA ZEROBUF,X
 STY $0,X
 INX
 BNE :1
 RTS
*-------------------------------
SETWIND LDA #$FF
 STA $32 ;MASK

 LDA #0
 STA $20
 STA $22
 LDA #40
 STA $21
 LDA #24
 STA $23

 RTS
*-------------------------------
*  Accept a line of input

GETLINE JSR SETWIND
 LDA #23
 STA $22
 JSR MONHOME

 LDA #">
 STA $33 ;PROMPT
 JMP GETLN
*-------------------------------
*  Print catalog

CATALOG JSR ZEROSWAP

 JSR SETWIND
 JSR MONHOME

 lda $bf00
 cmp #$4c
 bne :noprods

 ldx #0
 lda #cat
 sta string
 lda #>cat
 sta string+1
 jsr strout
 jsr crout

:noprods JMP ZEROSWAP
*-------------------------------
UTEXT asc "Unpacking picture from disk@"
PTEXT asc "Packing picture to disk@"
ITEXT asc "Loading image table from disk@"
OTEXT asc "Saving image table to disk@"
PROMPT asc "Enter file name without extension@"
blasttxt asc "Blasting image table to drive 2@"
blastq4 asc "Offset?@"
blastq3 asc "ID byte?@"
blastq2 asc "Track (00-22)?@"
blastq1 asc "Image table destination (hi byte)?@"
cat asc "CAT@"
saveimg1 asc "BSAVEIMG.@"
saveimg2 asc ",A$6000,L$@"
loadimg1 asc "BLOADIMG.@"
loadimg2 asc ",A$6000@"
savepac1 asc "BSAVEPAC.@"
savepac2 asc ",A$4000,L$@"
loadpac1 asc "BLOADPAC.@"
loadpac2 asc ",A$4000@"
NAMEBUF ds 40
*-------------------------------
pray jsr :prbyte
 tya
:prbyte PHA
 LSR
 LSR
 LSR
 LSR
 JSR :prdig
 PLA
 AND #$0F
:prdig ORA #$B0
 CMP #$BA
 BCC :prchar
 ADC #$06
 SEC
:prchar sta out,x
 inx
 rts
*-------------------------------
* Add (string) to $200 GETLN buffer
* Going in: X is GETLN index

strout ldy #0
:loop lda (string),y
 cmp #"@" ;string delimiter
 beq :done
 sta out,x
 inx
 iny
 bne :loop ;255 chars max
:done rts

nameout lda #NAMEBUF
 sta string
 lda #>NAMEBUF
 sta string+1
 jmp strout
*-------------------------------
* <CR> and call ProDOS BI

crout lda #0
 sta $be0f

 lda #$8d
 sta out,x
 jsr $be03

 lda $be0f ;BI error code
 beq :ok
 jsr BEEP
 jsr BEEP
:ok rts
*-------------------------------
* Input filename

ASKNAME LDA #22
 STA CV
 LDX #PROMPT
 LDY #>PROMPT
 JMP PRLINE

GETNAME JSR GETLINE

 LDY #0
:1 LDA $200,Y
 STA NAMEBUF,Y
 INY
 cpy #39
 beq :longnuf
 CMP #$8D
 BNE :1
 dey
:longnuf lda #"@"
 sta NAMEBUF,Y
 rts
*-------------------------------
* DISK CMD

DISKCMD JSR HOME
 LDA $C053

 JSR ZEROSWAP

 JSR GETNAME

 ldx #0
 jsr nameout
 jsr crout

 JMP ZEROSWAP
*-------------------------------
*  Unpack a picture from disk

DUNPAC JSR HOME
 LDA $C053

 LDA #20
 STA CV
 LDX #UTEXT
 LDY #>UTEXT
 JSR PRLINE

 JSR ASKNAME

 JSR ZEROSWAP

 JSR GETNAME
 LDA NAMEBUF
 CMP #"@"
 BEQ :1

 ldx #0
 lda #loadpac1
 sta string
 lda #>loadpac1
 sta string+1
 jsr strout

 jsr nameout

 lda #loadpac2
 sta string
 lda #>loadpac2
 sta string+1
 jsr strout

 jsr crout

 lda $be0f
 bne :1 ;BI error

 JSR ZEROSWAP
 JMP UNPACK

:1 JMP ZEROSWAP

*  Pack a picture to disk

DPAC JSR HOME
 LDA $C053

 LDA #20
 STA CV
 LDX #PTEXT
 LDY #>PTEXT
 JSR PRLINE

 JSR PACK
 lda PAC
 sta $300
 lda PAC+1
 sta $301 ;outside z.p.

 JSR ASKNAME

 JSR ZEROSWAP

 JSR GETNAME
 LDA NAMEBUF
 CMP #"@"
 BEQ :1

 ldx #0
 lda #savepac1
 sta string
 lda #>savepac1
 sta string+1
 jsr strout

 jsr nameout

 lda #savepac2
 sta string
 lda #>savepac2
 sta string+1
 jsr strout

 LDA $300
 CLC
 ADC #1
 tay
 LDA $301
 ADC #0
 SEC
 SBC #$40
 jsr pray

 jsr crout

:1 JMP ZEROSWAP
*-------------------------------
*  Output image table to disk

DTABOUT JSR HOME
 LDA $C053

 LDA #20
 STA CV
 LDX #OTEXT
 LDY #>OTEXT
 JSR PRLINE

 JSR ASKNAME

 LDA TABLEND
 sta $300
 LDA TABLEND+1
 sta $301

 JSR ZEROSWAP

 JSR GETNAME
 LDA NAMEBUF
 CMP #"@"
 BEQ :1

 ldx #0
 lda #saveimg1
 sta string
 lda #>saveimg1
 sta string+1
 jsr strout

 jsr nameout

 lda #saveimg2
 sta string
 lda #>saveimg2
 sta string+1
 jsr strout

 ldy $300
 LDA $301
 SEC
 SBC #>TABSTART
 jsr pray

 jsr crout

:1 JMP ZEROSWAP
*-------------------------------
*  Input image table from disk

DTABIN JSR HOME
 LDA $C053

 LDA #20
 STA CV
 LDX #ITEXT
 LDY #>ITEXT
 JSR PRLINE

 JSR ASKNAME

 JSR ZEROSWAP

 JSR GETNAME
 LDA NAMEBUF
 CMP #"@"
 BEQ :1

 ldx #0
 lda #loadimg1
 sta string
 lda #>loadimg1
 sta string+1
 jsr strout

 jsr nameout

 lda #loadimg2
 sta string
 lda #>loadimg2
 sta string+1
 jsr strout

 jsr crout

:1 JMP ZEROSWAP
*-------------------------------
track = $302
imdest = $303
IDbyte = $304
offset = $305

* Blast image table onto 18-sector disk in drive 2

BLAST JSR HOME

 LDA #20
 STA CV
 LDX #blasttxt
 LDY #>blasttxt
 JSR PRLINE

 jsr askblast
 cmp #$ff
 beq :skip
 sta imdest

 jsr relocate

 jsr asktrack
 cmp #$ff
 beq :undo

 jsr askoffset
 cmp #$ff
 beq :undo

 jsr askID
 cmp #$ff
 beq :undo
 sta IDbyte

 lda TABLEND+1
 sta $300
 lda #>TABSTART
 sta $301

* In: >TABLEND ($300), >TABSTART ($301), track ($302)
* imdest ($303), IDbyte ($304), >offset ($305)

 jsr blast18

:undo jsr undo ;unrelocate

:skip rts

* get img table dest addr

askblast lda #22
 sta CV
 ldx #blastq1
 ldy #>blastq1
 jsr PRLINE

 lda #34
 sta CH
 jmp getbyte

* Get byte from kbd, return in A (ff = esc)

getbyte jsr GETNYB
 cmp #$ff ;esc
 beq :rts
 asl
 asl
 asl
 asl
 sta temp
 lda DIGIT
 jsr PRCHAR
 jsr GETNYB
 clc
 adc temp
 sta temp
 lda DIGIT
 jsr PRCHAR
 lda temp
:rts rts

* get track #

asktrack lda #22
 sta CV
 ldx #blastq2
 ldy #>blastq2
 jsr PRLINE

 lda #14
 sta CH
 jsr getbyte
 cmp #$ff
 beq :rts
 cmp #$23
 bcc :ok
 jsr BEEP
 jmp asktrack
:ok sta track
 lda DIGIT
 jsr PRCHAR
 lda track
:rts rts

* get offset

askoffset lda #22
 sta CV
 ldx #blastq4
 ldy #>blastq4
 jsr PRLINE

 lda #7
 sta CH
 jsr getbyte
 cmp #$ff
 beq :rts
 cmp #$11
 bcc :ok
 jsr BEEP
 jmp askoffset
:ok sta offset
 lda DIGIT
 jsr PRCHAR
 lda offset
:rts rts

* get ID byte

askID lda #22
 sta CV
 ldx #blastq3
 ldy #>blastq3
 jsr PRLINE

 lda #8
 sta CH
 jsr getbyte
 cmp #$ff
 beq :rts
 cmp #IDbyteA
 beq :rts
 cmp #IDbyteB
 bne :3
:rts rts
:3 JSR BEEP
 jmp askID

*-------------------------------
* Relocate image table

relocate ldx TABSTART ;# of images
 inx
 txa
 asl
 tax  ;2(n+1)

:loop lda TABSTART,x
 sec
 sbc #>TABSTART
 clc
 adc imdest
 sta TABSTART,x

 dex
 dex
 bne :loop
 rts

* Unrelocate

undo ldx TABSTART
 inx
 txa
 asl
 tax

:loop lda TABSTART,x
 sec
 sbc imdest
 clc
 adc #>TABSTART
 sta TABSTART,x

 dex
 dex
 bne :loop
 rts
*-------------------------------
 lst on
EOF ds 1
 lst off
 sav draz
