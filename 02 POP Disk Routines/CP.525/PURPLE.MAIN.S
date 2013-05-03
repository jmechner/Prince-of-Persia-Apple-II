* purple.main

 lst off

* The job of this routine is to set $DA to $01
*                                ( in aux-zpage!!! )

slot = $FD

*-------------------------------------------------
*
* HLS APPLE COPY PROTECTION
* COPYRIGHT (C) 1987 HLS DUPLICATION
*
* HLS 408-773-1500
*
* Modified by Roland Gustafsson 8/25/89
* for Prince of Persia copy protection.
*
*-------------------------------------------------

* ZERO PAGE

OBJSCT = $07 ;PHYSICAL SECTOR #

HDRC = $40
HDRS = HDRC+1
HDRT = HDRC+2
HDRV = HDRC+3 HEADER SECTOR
LSRETRY = HDRC+4 ;NIB READ RETRIES
PRETRY = HDRC+5 ;OBJSCT RETRIES
NPTR = HDRC+6
NPTRH = HDRC+7
MEM1 = HDRC+8
MEM2 = HDRC+9

zpage = HDRC
zpagelen = 13

*-------------------------------------------------
*
* Here is the code that ends up at $6321.
* Assemble it and run "make.purple.hex" which
* reverses the code and puts it in a text file.
*
*-------------------------------------------------

 org $2000

 da len6321

 dum $6254
zpagebuf ds zpagelen
 dend

 org $6321

strt6321 jsr swapzpage
 lda #10
 sta LSRETRY
 ldx slot
 lda $C089,X
 lda $C08E,X
 lda #:NIBS ; !!!!! LOW BYTE
 sta NPTR
 lda #>:NIBS ; !!!!! HIGH BYTE
 sta NPTRH
:AGAIN lda #$80
 sta PRETRY
:M1 dec PRETRY
 beq :LSFAIL
 jsr RADR16
 bcs :LSFAIL
 lda HDRS
 cmp #OBJSCT
 bne :M1

 ldy #0
:M2 lda $C08C,X
 bpl :M2
 dey
 beq :LSFAIL
 cmp #$D5
 bne :M2
 ldy #0

:M3 lda $C08C,X
 bpl :M3
 dey
 beq :LSFAIL
 cmp #$E7
 bne :M3

:M4 lda $C08C,X
 bpl :M4
 cmp #$E7
 bne :LSFAIL

:M5 lda $C08C,X
 bpl :M5
 cmp #$E7
 bne :LSFAIL

 lda $C08D,X
 ldy #$10
 bit $6 ;3 US. ( FOR //C)
:M6 lda $C08C,X
 bpl :M6
 dey
 beq :LSFAIL
 cmp #$EE
 bne :M6

* NOW AT 1/2 NIBBLES

 ldy #7
:M7 lda $C08C,X * READ DISK DATA
 bpl :M7
 cmp (NPTR),Y * COMPARE AGAINST TABLE
 bne :LSFAIL
 dey
 bpl :M7
 bmi :GOOD
:LSFAIL jmp :LSFAIL1

* A O K

:GOOD jsr swapzpage
 lda #0
 sta $C009-zpagelen,x
 rol
 sta $DA-zpagelen,x
 sta $C008-zpagelen,x
 clc
 rts

* FAILED

:LSFAIL1 dec LSRETRY
 beq :ERROR
 jmp :AGAIN

:NIBS db $FC,$EE,$EE,$FC
 db $E7,$EE,$FC,$E7

* Note that drive motor is still on

:ERROR
swapzpage ldx #0
:0 ldy zpagebuf,x
 lda zpage,x
 sty zpage,x
 sta zpagebuf,x
 inx
 cpx #zpagelen
 bne :0
 rts

*-------------------------------------------------
*
* Read address mark
*

RADR16 ldy #$FD ;READ ADR HDR
 sty MEM1
:RA1 iny
 bne :RA2
 inc MEM1
 beq :RAEXIT
:RA2 lda $C08C,X
 bpl :RA2
:RA3 cmp #$D5
 bne :RA1
 nop
:RA4 lda $C08C,X
 bpl :RA4
 cmp #$AA
 bne :RA3
 ldy #3
:RA5 lda $C08C,X
 bpl :RA5
 cmp #$96
 bne :RA3
 lda #0
:RA6 sta MEM2
:RA7 lda $C08C,X
 bpl :RA7
 rol
 sta MEM1
:RA8 lda $C08C,X
 bpl :RA8
 and MEM1
 sta HDRC,Y
 eor MEM2
 dey
 bpl :RA6
 tay
 nop
 clc
 rts

:RAEXIT sec
 rts

len6321 = *-strt6321

 org

*------------------------------------------------- EOF

 sav purple.main
