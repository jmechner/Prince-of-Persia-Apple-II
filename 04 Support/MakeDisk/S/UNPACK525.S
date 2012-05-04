* unpack
ThreeFive = 0
org = $ea00
 lst off
*-------------------------------
*
*  U  N  P  A  C  K
*
*  Sits in main l.c. bank 2
*
*-------------------------------
 org org

 jmp SNGEXPAND
 jmp DBLEXPAND
 jmp DELTAEXPPOP
 jmp INVERTY
 jmp DELTAEXPWIPE

 jmp PURPLE
 jmp PROMPT
 jmp BLACKOUT
 jmp CLR
 jmp TEXT

 jmp SETDHIRES

*-------------------------------
 lst
 put gameeq
 lst
 put eq
 lst off

IOUDISoff = $c07f
IOUDISon = $c07e
DHIRESoff = $c05f
DHIRESon = $c05e
HIRESon = $c057
HIRESoff = $c056
PAGE2on = $c055
PAGE2off = $c054
MIXEDon = $c053
MIXEDoff = $c052
TEXTon = $c051
TEXToff = $c050
ALTCHARon = $c00f
ALTCHARoff = $c00e
ADCOLon = $c00d
ADCOLoff = $c00c
ALTZPon = $c009
ALTZPoff = $c008
RAMWRTaux = $c005
RAMWRTmain = $c004
RAMRDaux = $c003
RAMRDmain = $c002
ADSTOREon = $c001
ADSTOREoff = $c000

RWBANK2 = $c083
RWBANK1 = $c08b

POPside1 = $a9
POPside2 = $ad

*-------------------------------
*
*  Unpack single hi-res screen into page 1
*  (Sorry about the code--it's lifted directly from DRAZ)
*
*-------------------------------
 dum $00

PAC ds 2
PIC ds 2
V2 ds 1
V3 ds 1
V4 ds 1
V5 ds 1
V8 ds 1
V9 ds 1
VA ds 1
VB ds 1
VC ds 1

 dend

*-------------------------------
SNGEXPAND
 sta RAMRDaux
 sta RAMWRTmain

 STA PAC+1 ;org addr

 LDA #$20
 STA PIC+1 ;dest addr

 LDA #0
 STA PAC
 STA PIC

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
*
*  Unpack crunched double hi-res screen
*
*  Robert A. Cook 3/89
*
*  In: A = hi byte of crunched data address
*      RAMRD set to main/aux depending on where crunched
*        data is stored
*
*-------------------------------

 dum $f0

CrnDatPtr ds 2
XClmPos ds 1
YScrPos ds 1
ByteHld ds 1
RepeatCdn ds 1
ScrBasPtr ds 2

 dend

*-------------------------------
DBLEXPAND
 sta CrnDatPtr+1

 lda #1
 sta CrnDatPtr
;(CrnDatPtr),0 is crunch type (unused)
 jmp WipeRgtExp

*-------------------------------
*
*  Wipe Right Expand
*
*-------------------------------
WipeRgtExp
 lda #0
 sta XClmPos

:Loop lda #0
 sta YScrPos
 jsr ExpandClm

 lda #1
 sta YScrPos
 jsr ExpandClm

 inc XClmPos

 lda XClmPos
 cmp #80
 bne :Loop

]rts rts

*-------------------------------
*
*  Delta Expand
*
*  In: A = hi byte of crunched data address (in auxmem)
*
*-------------------------------
DeltaExp
 sta RAMRDaux

 sta CrnDatPtr+1

 lda #0
 sta CrnDatPtr

 sta XClmPos

:Loop ldy #0
 lda (CrnDatPtr),y
 cmp #-1
 beq :Done

 sta ByteHld
 and #$80
 beq :ExpandOne

 lda ByteHld
 and #$7f
 beq :NewCoord

 tax

 ldy #1
 lda (CrnDatPtr),y
 jsr ExpClmSeq1

 clc
 lda CrnDatPtr
 adc #2
 sta CrnDatPtr
 bcc :a4
 inc CrnDatPtr+1
:a4
 jmp :Next

:NewCoord
 ldy #1
 lda (CrnDatPtr),y
 sta XClmPos

 ldy #2
 lda (CrnDatPtr),y
 sta YScrPos

 clc
 lda CrnDatPtr
 adc #3
 sta CrnDatPtr
 bcc :a7
 inc CrnDatPtr+1
:a7
 jmp :Next

:ExpandOne
 lda ByteHld
 ldx #1
 jsr ExpClmSeq1

 inc CrnDatPtr
 bne :sysi8
 inc CrnDatPtr+1
:sysi8

:Next lda XClmPos
 cmp #$80
 bne :Loop

:Done sta RAMRDmain
]rts rts

*-------------------------------
*
*  Expand Column
*
*-------------------------------
ExpandClm

:Loop ldy #0
 lda (CrnDatPtr),y
 sta ByteHld
 and #$80
 beq :ExpandOne

 ldy #1
 lda (CrnDatPtr),y
 tax
 lda ByteHld
 and #$7f
 jsr ExpClmSeq

 clc
 lda CrnDatPtr
 adc #2
 sta CrnDatPtr
 bcc :a4
 inc CrnDatPtr+1
:a4
 jmp :Next

:ExpandOne
 lda ByteHld
 ldx #1
 jsr ExpClmSeq

 inc CrnDatPtr
 bne :sysi5
 inc CrnDatPtr+1
:sysi5

:Next lda YScrPos
 cmp #192
 bcc :Loop

 rts

*-------------------------------
*
*  Expand Column Sequence
*
*-------------------------------
*
*  In: XClmPos
*      YScrPos
*      A (byte pattern)
*      X (repeat count)
*
*  Out: YScrPos (modified)
*
*-------------------------------
ExpClmSeq
 sta ByteHld
 stx RepeatCdn

:Loop ldx XClmPos
 ldy YScrPos
 lda ByteHld
 jsr PutScrByte

 lda YScrPos
 clc
 adc #2
 sta YScrPos

 dec RepeatCdn
 bne :Loop

 rts

*-------------------------------
*
* Expand Column Sequence 1
*
*-------------------------------
ExpClmSeq1
 sta ByteHld
 stx RepeatCdn

:Loop ldx XClmPos
 ldy YScrPos
 lda ByteHld
 bmi :Next

 jsr PutScrByte

:Next inc YScrPos

 lda YScrPos
 cmp #192
 bne :SkipXInc

 lda #0
 sta YScrPos

 inc XClmPos

:SkipXInc
 dec RepeatCdn
 bne :Loop

 rts

*-------------------------------
*
*  Put DHires Byte Value
*
*-------------------------------
*
*  In:  X (XClmPos)
*       Y (YScrPos)
*       A (Byte value)
*
*-------------------------------
PutScrByte
 sta ByteHld
 ;YScrPos in Y
 lda YLO,y
 sta ScrBasPtr
 lda YHI,y
 ora #$20 ;DHires page 1
 sta ScrBasPtr+1

 txa ;XClmPos in X
 lsr
 tay
 bcs NoAuxSet

 sta RAMWRTaux

NoAuxSet lda ByteHld
 sta (ScrBasPtr),y

 sta RAMWRTmain

]rts rts

*-------------------------------
*
* P U R P L E
*
*-------------------------------
 do ThreeFive
PURPLE rts

 else
 put purple
 fin

*-------------------------------
*
*  Delta Expand (Pop or Wipe)
*
*  In: A = hi byte of crunched data address (in auxmem)
*
*-------------------------------
DELTAEXPPOP
 sta PAGE2on
]DE jsr DeltaExp
 sta PAGE2off
 sta RAMRDaux
 sta RAMWRTaux
]rts rts

DELTAEXPWIPE
 sta PAGE2off
 jmp ]DE

*-------------------------------
*
* Invert Y-tables
*
*-------------------------------
INVERTY
 ldx #191 ;low line
 ldy #0 ;high line

* Switch low & high lines

:loop lda YLO,x
 pha
 lda YLO,y
 sta YLO,x
 pla
 sta YLO,y

 lda YHI,x
 pha
 lda YHI,y
 sta YHI,x
 pla
 sta YHI,y

* Move 1 line closer to ctr

 dex
 iny
 cpy #96
 bcc :loop
]rts rts

*-------------------------------
*
* Prompt user to insert correct disk side
*
*-------------------------------
 do ThreeFive
msg1 asc "    Insert Prince of Persia Disk@"
 else
msg1 asc "Insert Prince of Persia Disk, Side "
 fin

msg2 asc "C@"

*-------------------------------
PROMPT
 lda #"A"
 ldx BBundID
 cpx #POPside1
 beq :1
 lda #"B"
:1 sta msg2 ;side A or B?

 jsr blackout

 sta RAMWRTmain

 ldx #0
:loop lda msg1,x
 cmp #"@"
 beq :done
 sta $528+2,x ;midscrn
 inx
 bpl :loop

:done sta RAMWRTaux
 jsr whoop ;whoop spkr

:wloop lda $c000
 ora $c061
 ora $c062
 bpl :wloop
 sta $c010

 jmp clr ;clear screen

*-------------------------------
CLR bit RWBANK2
 bit RWBANK2

 sta $c010

 lda #" "
 jmp _lrcls ;in hires

*-------------------------------
*
* Show black screen (text page 1)
*
*-------------------------------
BLACKOUT
 jsr CLR

TEXT sta RAMRDaux
 jsr vblank
 sta TEXTon
 sta ADCOLoff
 sta PAGE2off
]rts rts

*-------------------------------
* Set dbl hires
*-------------------------------
SETDHIRES
 sta RAMRDaux
 sta RAMWRTaux
 jsr vblank
 sta ADCOLon
 bit HIRESon

 bit DHIRESon
 bit DHIRESoff
 bit DHIRESon
 bit DHIRESoff
 bit DHIRESon ;for old Apple RGB card

 sta TEXToff
 rts

*-------------------------------
 lst
eof ds 1
 usr $a9,2,$a00,*-org
 lst off
