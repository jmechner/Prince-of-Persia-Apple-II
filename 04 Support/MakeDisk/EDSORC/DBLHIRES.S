* ed/dblhires
org = $ee00
 lst off
*-------------------------------
*
*  D B L   H I R E S
*
*  Sits in aux l.c.
*  Expects dblhires image tables to be in auxmem
*  (We use aux l.c. bank 2)
*  Carrybuf & dpeelbufs must also be in auxmem
*
*  Assume going in that aux l.c. & bank 2 are switched in
*
*-------------------------------
 put hrparams

CARRYBUF = $f700

dblimage = $d000 ;aux l.c. bank 2
textset = $d800

*-------------------------------
 org org

 JMP DBLCLS
 JMP DBLLAY
 JMP DBLFAST
 JMP DBLSAVE
 jmp DBLWIPE

 jmp DBLPRINT
 jmp DBLIMSEEK
 jmp DBLORA

*-------------------------------
* Local vars

locals = $f0
locals2 = $18

 dum locals

BASE ds 2
IMSAVE ds 2
XSAVE ds 1
YSAVE ds 1
WIDTH ds 1
HEIGHT ds 1

INDEX ds 1
RAM ds 1
SCREEN ds 1
AMASK ds 1
BMASK ds 1

dcolor ds 2 ;address of 4-byte color table
colortemp ds 1

 dum locals2

bits ds 1
bytes ds 1
temp ds 1

 dend

*-------------------------------
*
* D B L C L S
*
* Clear screen
*
*-------------------------------
DBLCLS STA $C004 ;RAMWRT main
 JSR CLS

 STA $C005 ;RAMWRT aux

CLS LDA PAGE
 CLC
 ADC #$20
 STA BASE+1

 LDY #0
 STY BASE

:1 LDA #$80 ;black

:2 STA (BASE),Y
 INY
 BNE :2

 INC BASE+1
 LDA BASE+1
 AND #$1F
 BNE :1

 RTS

*-------------------------------
*
*  D B L L A Y
*
*  Same I/O structure as single-hires LAY except:
*  1. Image table is listed by columns (T-B, L-R)
*  2. XCO range is 0-79
*  3. No mirroring
*
*-------------------------------
DBLLAY
 lda OPACITY
 cmp #4 ;4=MASK
 bne :notmask
 jmp DBLMASK

:notmask jsr PREP

 LDA XCO ;0-79
 AND #1
 EOR #1
 STA RAM ;0=main, 1=aux

*  Divide XCO by two

 LDA XCO
 BPL :15

 EOR #$FF
 LSR
 EOR #$FF
 STA XCO ;negative XCO

 JMP :1

:15 LSR XCO ;0-39

*  Self-mod code depending on OFFSET and OPACITY

:1 LDX OFFSET ;0-6

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :92+1
 LDA CARRYH,X
 STA :92+2

 LDA AMASKS,X
 STA AMASK

 LDA BMASKS,X
 STA BMASK

 LDX OPACITY ;0=AND, 1=ORA, 2=STA, 3=EOR
 LDA OPCODE,X
 STA :81
 STA :82

 JSR INITCARRY

* Start new column at top edge of image (YCO)

:2 LDX YSAVE

 LDA #0
 STA INDEX ;Index to image table

 LDY RAM ;0=main, 1=aux
 STA $C004,Y ;RAMWRT main/aux

* Lay column down top-to-bottom

:loop sta $c003 ;RAMRD aux (where img table is)

 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1

 STX YCO

 LDY INDEX ;Indexed from top line of image
 LDA (IMAGE),Y ;Assume MSB is off
 ora #$80 ;turn on MSB
 TAX
:91 LDA $FFFF,X ;SHIFTn
 ORA CARRYBUF,Y

 STA SCREEN

:92 LDA $FFFF,X ;CARRYn
 STA CARRYBUF,Y

 LDX YCO
 cpx TOPCUT
 bcc :5
 CPX #192
 BCS :5 ;Off top or bottom

 LDY XCO
 CPY #40
 BCS :5 ;Off left or right

 lda RAM
 bne :10
 sta $c002 ;mustn't trash y

:10 LDA SCREEN
:81 STA (BASE),Y ;STA/ORA/AND according to OPACITY
 STA (BASE),Y
 
:5 INX
 INC INDEX

 LDA INDEX
 CMP HEIGHT
 BCC :loop ;Next line down

*  Next column over

 LDA IMAGE
 CLC
 ADC HEIGHT
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 LDA RAM
 EOR #1
 STA RAM
 BEQ :7
 INC XCO

:7 DEC WIDTH
 BNE :2

* Extra column on right (carryover)

 LDX YSAVE

 LDA #0
 STA INDEX ;Index to image table

 LDY RAM ;0=main, 1=aux
 STA $C004,Y ;RAMWRT
 STA $C002,Y ;RAMRD

* Lay column down top-to-bottom

:30 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1

 STX YCO

 LDY INDEX ;Indexed from top line of image
 
 LDA CARRYBUF,Y
 STA SCREEN

 LDX YCO
 cpx TOPCUT
 bcc :50
 CPX #192
 BCS :50 ;Off top or bottom

 LDY XCO
 CPY #40
 BCS :50 ;Off left or right

 LDA (BASE),Y

 AND BMASK
 ORA SCREEN
:82 STA (BASE),Y ;STA/ORA/AND according to OPACITY
 STA (BASE),Y
 
:50 INX
 INC INDEX

 LDA INDEX
 CMP HEIGHT
 BCC :30 ;Next line down

DONE
 STA $C003
 STA $C005 ;RAMWRT and RAMRD aux

 LDA IMSAVE
 STA IMAGE
 LDA IMSAVE+1
 STA IMAGE+1

 LDA XSAVE
 STA XCO
 LDA YSAVE
 STA YCO

 RTS

*-------------------------------
*
* D B L M A S K
*
*-------------------------------
DBLMASK jsr PREP

 LDA XCO ;0-79
 AND #1
 EOR #1
 STA RAM ;0=main, 1=aux

*  Divide XCO by two
 
 LDA XCO
 BPL :15

 EOR #$FF
 LSR
 EOR #$FF
 STA XCO ;negative XCO

 JMP :1
 
:15 LSR XCO ;0-39

*  Self-mod code depending on OFFSET and OPACITY

:1 LDX OFFSET ;0-6

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :92+1
 LDA CARRYH,X
 STA :92+2

 LDA AMASKS,X
 STA AMASK

 LDA BMASKS,X
 STA BMASK

 JSR INITCARRY

* Start new column at top edge of image (YCO)

:2 LDX YSAVE

 LDA #0
 STA INDEX ;Index to image table

 LDY RAM ;0=main, 1=aux
 STA $C004,Y

* Lay column down top-to-bottom

:loop sta $c003 ;RAMRD aux

 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1

 STX YCO

 LDY INDEX ;Indexed from top line of image

 LDA (IMAGE),Y ;Assume MSB is off
 TAX
 lda   masktabl,x
 ora #$80 ;turn on MSB
 tax

:91 LDA $FFFF,X ;SHIFTn
 ORA CARRYBUF,Y

 STA SCREEN

:92 LDA $FFFF,X ;CARRYn
 STA CARRYBUF,Y
 
 LDX YCO
 cpx TOPCUT
 bcc :5
 CPX #192
 BCS :5 ;Off top or bottom

 LDY XCO ;ironic, isn't it?
 CPY #40
 BCS :5 ;Off left or right
 
 lda RAM
 bne :10
 sta $c002 ;mustn't trash y

:10 LDA SCREEN
:81 AND (BASE),Y ;STA/ORA/AND according to OPACITY
 STA (BASE),Y

:5 INX
 INC INDEX

 LDA INDEX
 CMP HEIGHT
 BCC :loop ;Next line down
 
*  Next column over
 
 LDA IMAGE
 CLC
 ADC HEIGHT
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 LDA RAM
 EOR #1
 STA RAM
 BEQ :7
 INC XCO
 
:7 DEC WIDTH
 BNE :2

* Extra column on right (carryover)
 
 LDX YSAVE
 
 LDA #0
 STA INDEX ;Index to image table
 
 LDY RAM ;0=main, 1=aux
 STA $C004,Y
 STA $C002,Y

* Lay column down top-to-bottom

:30 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1

 STX YCO

 LDY INDEX ;Indexed from top line of image

 LDA CARRYBUF,Y
 STA SCREEN

 LDX YCO
 cpx TOPCUT
 bcc :50
 CPX #192
 BCS :50 ;Off top or bottom
 
 LDY XCO
 CPY #40
 BCS :50 ;Off left or right

 LDA (BASE),Y
 
 AND BMASK
 ORA SCREEN
:82 AND (BASE),Y ;STA/ORA/AND according to OPACITY
 STA (BASE),Y

:50 INX
 INC INDEX

 LDA INDEX
 CMP HEIGHT
 BCC :30 ;Next line down

 JMP DONE

*-------------------------------
*
* P R E P A R E
*
*-------------------------------
PREP LDA IMAGE
 STA IMSAVE
 LDA IMAGE+1
 STA IMSAVE+1
 
 LDA XCO
 STA XSAVE
 LDA YCO
 STA YSAVE

 LDY #0
 LDA (IMAGE),Y
 STA WIDTH
 
 INY
 LDA (IMAGE),Y
 STA HEIGHT

 LDA IMAGE
 CLC
 ADC #2
 STA IMAGE
 BCC :1
 INC IMAGE+1
 
:1 RTS

*-------------------------------
*
* I N I T C A R R Y
*
* Initialize carry buffer
*
*-------------------------------
INITCARRY
 LDY RAM
 STA $C004,Y
 STA $C002,Y

 LDX #0
 
 LDY XCO
 BPL ZZYK

* Take black from offscreen
 
 LDY HEIGHT
 
 LDA #0
:1 STA CARRYBUF,Y
 DEY
 BNE :1
 STA CARRYBUF

 JMP DUN
 
ZZYK STX INDEX
 
 LDX YCO

 LDA YLO,X
 STA BASE
 
 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1
 
 INC YCO

 LDA (BASE),Y
 AND AMASK
 
 LDX INDEX
 STA CARRYBUF,X
 
 INX
 CPX HEIGHT
 BCC ZZYK

DUN STA $C002
 STA $C004
 
 RTS

*-------------------------------
*
* D B L F A S T
*
* No offset - no clipping - no mirroring - STA only -
* trashes vars
*
*-------------------------------
DBLFAST JSR PREP
 
 LDA XCO
 AND #1
 EOR #1
 STA RAM

 LSR XCO

:2 LDX YSAVE

 LDA #0
 STA INDEX
 
 LDY RAM
 STA $C004,Y ;RAMWRT main/aux

:3 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1
 
 LDY INDEX
 LDA (IMAGE),Y
 
 LDY XCO
 STA (BASE),Y

 INX
 INC INDEX
 
 LDA INDEX
 CMP HEIGHT
 BCC :3
 
 LDA IMAGE
 CLC
 ADC HEIGHT
 STA IMAGE
 BCC :6
 INC IMAGE+1
 
:6 LDA RAM
 EOR #1
 STA RAM
 BEQ :7
 INC XCO

:7 DEC WIDTH
 BNE :2
 
 sta $c003
 sta $c005

 RTS

*-------------------------------
*
* D B L O R A
*
* Same as DBLWIPE except 1 image table byte
* is ORed with screen (e.g. to draw a vertical line)
*
*-------------------------------
DBLORA
 jsr PREP
 
 ldy #0
 lda (IMAGE),y
 sta dcolor

 LDA XCO
 AND #1
 EOR #1
 STA RAM

 LSR XCO

:2 LDX YSAVE

 LDA #0
 STA INDEX

 LDY RAM
 sta $c002,y
 STA $C004,Y ;RAMRD/WRT main/aux

 lda XCO
 and #1
 asl
 ora RAM
 eor #1
 tay

:3 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1
 
 LDY XCO

 lda dcolor
 ora (BASE),y
 sta (BASE),y

 INX
 INC INDEX

 LDA INDEX
 CMP HEIGHT
 BCC :3

 LDA RAM
 EOR #1
 STA RAM
 BEQ :7
 INC XCO

:7 DEC WIDTH
 BNE :2

 STA $C003
 STA $C005

 RTS

*-------------------------------
*
* D B L W I P E
*
* Same as DBLFAST except only 1st byte of image table
* is used (to represent color: 0-15)
*
*-------------------------------
DBLWIPE
 jsr PREP
 
 ldy #0
 lda (IMAGE),y
 and #$0f ;color: 0-15
 asl
 asl
 clc
 adc #colortab
 sta dcolor
 lda #0
 adc #>colortab
 sta dcolor+1 ;address of 4-byte color pattern

 LDA XCO
 AND #1
 EOR #1
 STA RAM

 LSR XCO

:2 LDX YSAVE

 LDA #0
 STA INDEX

 LDY RAM
 STA $C004,Y ;RAMWRT main/aux

 lda XCO
 and #1
 asl
 ora RAM
 eor #1
 tay
 lda (dcolor),y
 sta colortemp

:3 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1
 
 lda colortemp
 LDY XCO
 STA (BASE),Y

 INX
 INC INDEX

 LDA INDEX
 CMP HEIGHT
 BCC :3

 LDA RAM
 EOR #1
 STA RAM
 BEQ :7
 INC XCO

:7 DEC WIDTH
 BNE :2

 STA $C003
 STA $C005

 RTS

*-------------------------------
*
* D B L S A V E
*
* Save underlayer in BUFFER (replace with DBLFAST)
*
* PEELBUF is permanent 2-byte ptr to first available byte
* in peel buffer for each page.
*
* In: params set for LAY
* Out: PEELIMG (2b), PEELXCO, PEELYCO, PEELBUF (2b)
*   PEELIMG+1 = 0 means no image has been stored
*
*-------------------------------
DBLSAVE JSR PREP

 LDY #0
 
 LDA OFFSET
 BEQ :1
 LDA #1 ;To cover carryover

:1 CLC
 ADC WIDTH
 STA WIDTH
 STA (PEELBUF),Y

 INY
 LDA HEIGHT
 STA (PEELBUF),Y

 LDA YCO
 STA PEELYCO
 LDA XCO
 STA PEELXCO

 lda PEELBUF+1
 sta PEELIMG+1

 lda PEELBUF
 sta PEELIMG

 CLC
 ADC #2
 STA PEELBUF

 bcc :ok
 inc PEELBUF+1
:ok

* Buffer's set up; now fill it
 
 LDA XCO
 AND #1
 EOR #1
 STA RAM

 LSR XCO

:2 LDX YSAVE

 LDA #0
 STA INDEX
 
 LDY RAM
 STA $C002,Y ;RAMRD

:3 LDA YLO,X
 STA BASE

 LDA YHI,X
 CLC
 ADC PAGE
 STA BASE+1

 LDY XCO
 LDA (BASE),Y

 LDY INDEX
 STA (PEELBUF),Y

 INX
 INC INDEX
 
 LDA INDEX
 CMP HEIGHT
 BCC :3

 LDA PEELBUF
 CLC
 ADC HEIGHT
 STA PEELBUF
 BCC :6
 INC PEELBUF+1

:6 LDA RAM
 EOR #1
 STA RAM
 BEQ :7
 INC XCO

:7 DEC WIDTH
 BNE :2
 
 JMP DONE

SKIPIT LDA #0
 sta PEELIMG+1 ;no image saved

 JMP DONE

*-------------------------------
*
* D B L P R I N T
*
* print a dblhires character
* In: XCO/OFFSET = x; YCO = y; IMAGE = textset index
* Out: XCO/OFFSET = space to next char
*
*-------------------------------
DBLPRINT

* get start of image table

 lda IMAGE
 asl
 sec
 sbc #1
 tay
 lda textset,y
 sta IMAGE
 lda textset+1,y
 sta IMAGE+1

* swallow first 2 bytes

 ldy #0
 lda (IMAGE),y ;width in bytes & bits
 pha
 and #$0f
 sta bits
 pla
 lsr
 lsr
 lsr
 lsr
 sta bytes

 iny
 lda (IMAGE),y ;y-offset
 clc
 adc YCO
 sta YCO

 lda IMAGE
 clc
 adc #2
 sta IMAGE
 lda IMAGE+1
 adc #0
 sta IMAGE+1 ;advance 2 bytes

* dump image to screen

 lda #4
 sta OPACITY ;"MASK"
 jsr DBLLAY

 lda #1
 sta OPACITY ;"OR"
 jsr DBLLAY

* return char shift

 lda bits
 sta OFFSET
 lda bytes
 sta XCO

 rts

*-------------------------------
*
* D B L I M S E E K
*
* In: TABLE = image table start addr
*     IMAGE = image #
*
* Out: IMAGE (2 bytes) = image start addr
*
*-------------------------------
DBLIMSEEK
 lda IMAGE
 asl
 tay
 dey

 lda (TABLE),y
 sta IMAGE

 iny
 lda (TABLE),y
 sta IMAGE+1

 rts

*-------------------------------
*
*  C O L O R T A B
*
* 4-byte color patterns for 16 dblhires colors
*
*-------------------------------
colortab hex 00,00,00,00
 hex 08,11,22,44
 hex 44,08,11,22
 hex 4c,19,33,66

 hex 22,44,08,11
 hex 2a,55,2a,55
 hex 66,4c,19,33
 hex 6e,5d,3b,77

 hex 11,22,44,08
 hex 19,33,66,4c
 hex 55,2a,55,2a
 hex 5d,3b,77,6e

 hex 33,66,4c,19
 hex 3b,77,6e,5d
 hex 77,6e,5d,3b
 hex 7f,7f,7f,7f

*-------------------------------
*
*  M A S K T A B
*
*-------------------------------
masktabl
 hex 7F706060404040400000000000000000
         hex  01000000000000000000000000000000
         hex  03000000000000000000000000000000
         hex  01000000000000000000000000000000
         hex  07000000000000000000000000000000
         hex  01000000000000000000000000000000
         hex  03000000000000000000000000000000
         hex  01000000000000000000000000000000

 do 0
masktabh
 hex 7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F
 hex 7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7F
 hex 7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C
 hex 7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C7C
 hex 78787878787878787878787878787878
 hex 78787878787878787878787878787878
  hex 78787878787878787878787878787878
 hex 78787878787878787878787878787878

 fin

*-------------------------------
 lst
eof ds 1
 usr $a9,27,$0000,*-org
 lst off
