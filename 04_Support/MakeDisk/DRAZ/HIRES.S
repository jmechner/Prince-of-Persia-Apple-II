* draz hires
org equ $8400
 lst off

 org org

 put hrparams
 put hrtables
*-------------------------------
 ds org+$a00-*

 JMP CLS
 JMP LAY
 jmp DIAMOND

* Local vars

 dum $e0

BASE ds 2
IMSAVE ds 2
XSAVE ds 1
YSAVE ds 1
WIDTH ds 1
HEIGHT ds 1
TOPEDGE ds 1
OFFLEFT ds 1
OFFRIGHT ds 1
YREG ds 1
CARRY ds 1
AMASK ds 1
BMASK ds 1
VISWIDTH ds 1
RMOST ds 1

saveimg ds 3
destheight ds 1
temp1 ds 1
imgline ds 1

 dend

*-------------------------------
*  C L S
*
*  Clear screen to black2

CLS LDA PAGE
 CLC
 ADC #$20
 STA BASE+1

 LDY #$00
 STY BASE

:1 LDA #$80

:2 STA (BASE),Y
 INY
 BNE :2

 INC BASE+1
 LDA BASE+1
 AND #$1F
 BNE :1

 RTS

*-------------------------------
* L A Y
*
* Parameters:
*
* PAGE      $00 = page 1, $20 = page 2
* XCO       byte (0=left, 39=right)
* YCO       line (0=top, 191=bottom)
* OFFSET    # bits to shift right (0-6)
* IMAGE     starting address of image table
* OPACITY   Bits 0-1: 0 = AND, 1 = ORA, 2 = STA, 3 = EOR
*           Bit 7: 0 = normal, 1 = mirror
*
* Image table:
*
* 0:    width (# bytes)
* 1:    height (# lines)
* 2-n:  image reading L-R, T-B
*
*-------------------------------

LAY LDA OPACITY
 BPL :99

 AND #$7F
 STA OPACITY
 JMP MLAY

:99 JSR PREPREP
 JSR PREPARE
 CMP #-1
 BCC :8
 JMP DONE

:8 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 LDA CARRYH,X
 STA :90+2
 STA :92+2

 LDA AMASKS,X
 STA AMASK
 LDA BMASKS,X
 STA BMASK

 LDX OPACITY
 LDA OPCODE,X
 STA :80
 STA :81

 LDY YCO

:0 LDA YLO,Y
 CLC
 ADC XCO
 STA BASE

 LDA YHI,Y
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

*  Take CARRY from off left edge

 DEY
 LDA (IMAGE),Y
 TAX
:90 LDA $FFFF,X ;CARRYn
 STA CARRY

 LDA IMAGE
 CLC
 ADC OFFLEFT
 STA IMAGE
 BCC :1
 INC IMAGE+1

:1 LDY #0

 LDA VISWIDTH
 STA WIDTH
 BNE :3
 BEQ :4 ;Zero width

* Start a new line at left edge

:2 LDA (BASE),Y
 AND AMASK
 STA CARRY

* Lay line down left-to-right fast as you can

:3 LDA (IMAGE),Y
 TAX
:91 LDA $FFFF,X ;SHIFTn
 ORA CARRY ;Combine with carryover from previous byte

:80 STA (BASE),Y ;STA/ORA/AND/EOR depending on OPACITY
 STA (BASE),Y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INY
 CPY VISWIDTH
 BCC :3

*  Extra byte on right (carryover)

 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 LDA (BASE),Y

 AND BMASK
 ORA CARRY
:81 STA (BASE),Y
 STA (BASE),Y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 BNE :0

*  Restore parameters

DONE LDA IMSAVE
 STA IMAGE
 LDA IMSAVE+1
 STA IMAGE+1

 LDA XSAVE
 STA XCO
 LDA YSAVE
 STA YCO

 RTS

*-------------------------------
*  P R E P A R E
*
*  Save parameters

PREPREP LDA IMAGE
 STA IMSAVE
 LDA IMAGE+1
 STA IMSAVE+1

 LDA XCO
 STA XSAVE
 LDA YCO
 STA YSAVE

*  Read first two bytes (width, height) of image table

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
 BCC :3
 INC IMAGE+1

:3 RTS

*-------------------------------
* PREPARE
*
*  Crop top and bottom edges

PREPARE LDA YCO
 SEC
 SBC HEIGHT
 CMP #192
 BCC :4 ;Top is onscreen

 LDA YCO
 CMP #192
 BCS :8 ;Top and bottom o.s. - skip it

 LDA #-1 ;Top is offscreen
:4 STA TOPEDGE ;(Top line -1)

 LDY YCO
:41 CPY #192
 BCC :6 ;Bottom is onscreen

*  Advance pointer past bottom offscreen portion

 LDA IMAGE
 CLC
 ADC WIDTH
 STA IMAGE
 BCC :5
 INC IMAGE+1

:5 DEY
 STY YCO
 BNE :41

*  Crop sides

:6 LDA #0
 STA OFFLEFT
 STA OFFRIGHT
 STA RMOST

 LDA WIDTH
 STA VISWIDTH

 LDA XCO
 BPL :7 ;Left edge is onscreen

*  Left edge is offscreen

 EOR #$FF
 CLC
 ADC #1
 STA OFFLEFT ;Width of o.s. portion

 LDA XCO
 CLC
 ADC WIDTH
 BCC :8 ;Entire image is o.s. - skip it
 STA VISWIDTH ;(Width of onscreen portion)

 LDA #0
 STA XCO
 BEQ LAYON

*  Left edge OK

:7 CMP #40
 BCS :8 ;Entire image is o.s. - skip it

 CLC
 ADC WIDTH
 CMP #40
 BCC LAYON ;Right edge OK - lay on

 SEC
 SBC #39
 STA OFFRIGHT ;Width of o.s. portion

 LDA #40
 SEC
 SBC XCO
 STA VISWIDTH

 LDA WIDTH
 SEC
 SBC VISWIDTH
 STA RMOST

 BPL LAYON

:8 LDA #-1 ;Image is o.s. - skip it

LAYON RTS


*-------------------------------
*  M I R R O R L A Y
*
*  Specified starting byte (XCO,YCO) is image's bottom
*  right corner, not bottom left; bytes are read off image
*  table R-L, T-B and mirrored before printing.

MLAY JSR PREPREP

 LDA XCO
 SEC
 SBC WIDTH
 STA XCO

 JSR PREPARE
 CMP #-1
 BCC :8
 JMP DONE

:8 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 LDA CARRYH,X
 STA :90+2
 STA :92+2

 LDA AMASKS,X
 STA AMASK
 LDA BMASKS,X
 STA BMASK

 LDX OPACITY
 LDA OPCODE,X
 STA :80
 STA :81

* Lay on

 LDY YCO

:0 LDA YLO,Y
 STA BASE

 LDA YHI,Y
 CLC
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

* Take CARRY from off left edge

 LDY VISWIDTH
 LDA (IMAGE),Y
 TAX

 LDA MIRROR-$80,X
 TAX

:90 LDA $FFFF,X ;CARRYn
 STA CARRY

:1 DEY
 BPL :3
 BMI :4

* Start a new line at left edge

:2 LDY XCO
 LDA (BASE),Y
 AND AMASK
 STA CARRY

 LDY WIDTH
 DEY

* Lay line down left-to-right fast as you can

:3 STY YREG
 LDA (IMAGE),Y
 TAX

 LDA MIRROR-$80,X
 TAX

:91 LDA $FFFF,X ;SHIFTn
 ORA CARRY ;Combine with carryover from previous byte

 LDY XCO
:80 STA (BASE),Y ;STA/ORA/AND/EOR depending on OPACITY
 STA (BASE),Y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INC BASE

 LDY YREG
 CPY RMOST
 BEQ :7

 DEY
 BPL :3

*  Extra byte on right (carryover)

:7 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 LDY XCO
 LDA (BASE),Y

 AND BMASK
 ORA CARRY
:81 STA (BASE),Y
 STA (BASE),Y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 BNE :0

 JMP DONE

*-------------------------------
*  F A S T L A Y
*
* Limitations: No offset - no clipping - no mirroring -
* STA only - trashes IMAGE.

FASTLAY LDY #0
 LDA (IMAGE),Y
 STA WIDTH

 INY
 LDA YCO
 SEC
 SBC (IMAGE),Y
 STA TOPEDGE

 LDA IMAGE
 CLC
 ADC #2
 STA IMAGE
 BCC :5
 INC IMAGE+1

:5 LDX YCO

:0 LDA YLO,X
 CLC
 ADC XCO
 STA BASE

 LDA YHI,X
 ADC PAGE
 STA BASE+1

 LDY #0

:1 LDA (IMAGE),Y
 STA (BASE),Y

 INY
 CPY WIDTH
 BCC :1

 TYA
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :2
 INC IMAGE+1

:2 DEX
 CPX TOPEDGE
 BNE :0

 RTS

*-------------------------------
*
*   D I A M O N D
*
*   Works like FASTLAY, but it lays down the image
*   at a slant.
*
*-------------------------------
widtable ;INT(7x/2) for x=0 to 40
 db 0,3,7,10,14,17,21,24,28
 db 31,35,38,42,45,49,52,56,59
 db 63,66,70,73,77,80,84,87,91
 db 94,98,101,105,108,112,115,119,122
 db 126,129,133,136,140
*-------------------------------

DIAMOND
 LDY #0
 LDA (IMAGE),Y
 STA WIDTH

 INY
 LDA (IMAGE),Y ;original image height
 sta HEIGHT

 ldx WIDTH
 clc
 adc widtable,x ;INT(7x/2)
 sta destheight

 LDA YCO
 SEC
 sbc destheight
 STA TOPEDGE

 LDA IMAGE
 CLC
 ADC #2
 STA IMAGE
 BCC :5
 INC IMAGE+1
:5

* Now lay down image (slanted)...L-R, B-T

 ldx YCO ;bottom line of screen dump area

 lda #0 ;bottom line of image
 sta imgline

:loop
 LDA YLO,X
 CLC
 ADC XCO
 STA BASE

 LDA YHI,X
 ADC PAGE
 STA BASE+1 ;get base addr

 lda IMAGE
 sta saveimg
 lda IMAGE+1
 sta saveimg+1

 lda imgline
 sta saveimg+2

 LDY #0

* Do a line (L-R), 2 bytes at a time

:loop1
 jsr getimgbyte ;lda (IMAGE),y
 and #%00000011 ;2 leftmost bits (on this line)
 sta temp1

 jsr onelinedn ;move 1 line down & getimgbyte
 and #%00001100 ;next 2 bits (from line below)
 ora temp1
 sta temp1

 jsr onelinedn
 and #%00110000 ;next 2 bits (from 2 lines down)
 ora temp1
 sta temp1

 jsr onelinedn
 and #%01000000 ;rightmost bit (from 3 lines down)
 ora temp1
 ;Got it
 jsr putbyte

 INY
 CPY WIDTH
 bcs :eol

* Next byte over on this line

 jsr getimgbyte
 and #%00000001 ;leftmost bit (still from 3 lines down)
 sta temp1

 jsr onelinedn
 and #%00000110 ;next 2 bits (from 4 lines down)
 ora temp1
 sta temp1

 jsr onelinedn
 and #%00011000 ;next 2 bits (from 5 lines down)
 ora temp1
 sta temp1

 jsr onelinedn
 and #%01100000 ;rightmost 2 bits (from 6 lines down)
 ora temp1

 jsr putbyte

 jsr onelinedn ;7 lines down (prepare for next 2 bytes)

 INY
 CPY WIDTH
 bcc :loop1 ;next 2 bytes in this line

:eol

* Done with this line
* Up to the next line

 lda saveimg
 sta IMAGE
 lda saveimg+1
 sta IMAGE+1 ;reset IMAGE to point to this line
 lda saveimg+2
 sta imgline

 lda WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :2
 INC IMAGE+1
:2
 inc imgline

 DEX
 CPX TOPEDGE
 beq :rts

 cpx #192
 bcs :rts ;offscreen

 jmp :loop

:rts rts

*-------------------------------
onelinedn
 lda IMAGE
 sec
 sbc WIDTH
 sta IMAGE

 bcs :1
 dec IMAGE+1
:1

 dec imgline

 jmp getimgbyte

*-------------------------------
getimgbyte
 lda imgline
 cmp HEIGHT
 bcs :outside

 lda (IMAGE),y
 rts

:outside lda #$80 ;blank space outside image
 rts
*-------------------------------
putbyte ;in: A
 cpy #40
 bcs :skip

 ora #$80
 sta (BASE),y

:skip rts
*-------------------------------
 lst
eof ds 1
 lst off
*-------------------------------
