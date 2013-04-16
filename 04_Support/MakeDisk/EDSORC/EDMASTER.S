* edmaster
edfirst = 1
org = $f900
 lst off
*-------------------------------
*
*   M  A  S  T  E  R
*
*   (version for editor disk)
*
*-------------------------------
 org org

 jmp FIRSTBOOT
 jmp LOADLEVEL
 jmp RELOAD1
 jmp RELOAD2
 jmp RELOAD3 ;1st 5 entry points are same as in game version

 jmp REBOOT
 jmp GOBUILD
 jmp GOGAME
 jmp WRITEDIR
 jmp READDIR

 jmp SAVELEVEL
 jmp SAVELEVELG
 jmp SCREENDUMP

*-------------------------------
 put eq

development = 1

*-------------------------------
* File equates

topctrl = $2000
builder = $8400
Mdebugs = $4c00 ;mainmem, destined for $fc00 aux

coldgame = topctrl
warmgame = coldgame+3

coldbuild = builder
warmbuild = coldbuild+3

 dum Mdebugs
showpage ds 3
debugkeys ds 3
moveauxlc ds 3
 dend

BbundID = BBundID

POPside1 = $a9
POPside2 = $ad ;game

*-------------------------------
break = $fa59

realreset = $300

*-------------------------------
* RW18 zero page vars

slot = $fd
track = $fe
lastrack = $ff

*-------------------------------
* local vars

locals = $f0

 dum locals

]dest ds 2
]source ds 2
]endsourc ds 2

 dend

params = $3f0

*-------------------------------
* Coordinates of default load-in level

firstlevel db 33,0,30,0

*-------------------------------
*
* Notes:
*
* Game & builder code sits in auxmem & aux l.c. and uses
* aux z.p.
*
* Routines in main l.c. (including MASTER and HIRES)
* are called via intermediary routines in GRAFIX (in auxmem).
*
* RW18 sits in bank 1 of main language card;
* driveon switches it in, driveoff switches it out.
*
*-------------------------------
*
*  F I R S T B O O T
*
*-------------------------------
FIRSTBOOT
 jsr setaux
 jsr setreset ;in auxmem

 jsr setmain
 jsr setreset ;in maimmem

boot
 jsr setaux

 lda #$a9 ;side 1
 sta BbundID

 jsr loadcommon1 ;tracks 2-3 (2 tracks)

* boot builder

 jsr bootbuilder
 jsr xtitle
 jmp coldbuild

*-------------------------------
* coldstart builder

bootbuilder
 jsr loadbuild1 ;tracks 4-6 (3 tracks)
 jsr loadcommon2 ;tracks 11-12 (chtable3; 2 tracks)
 jsr loadbuild2 ;tracks 22-28 (7 tracks)
 jsr loadgame4

 jmp driveoff

*-------------------------------
*
*  G O   B U I L D
*
*-------------------------------
GOBUILD
 jsr driveon

 jsr copybgmain ;copy bgtable to mainmem

 jsr loadbuild2 ;tracks 22-28 (7 tracks)

 jsr driveoff

 jmp warmbuild

*-------------------------------
*
*  G O   G A M E
*
*-------------------------------
GOGAME
 jsr driveon

 jsr copybgaux ;copy bgtable to auxmem

 jsr loadgame1a
 jsr xfergame
 jsr loadgame3
 jsr loadgame4

 jsr driveoff

ColdstartGame
 lda #1
 jmp coldgame

*-------------------------------
*
*  R E B O O T
*
*-------------------------------
REBOOT jsr driveon

 jsr bootbuilder
 jmp warmbuild

*-------------------------------
*
*   Q U I C K   R E L O A D S
*
*   (for game development)
*
*-------------------------------
*   Reload 1: reload images

RELOAD1
 jsr driveon

 jsr loadgame2

 jmp driveoff

*-------------------------------
*   Reload 2: reload code

RELOAD2
 jsr driveon

 jsr loadgame1
 jsr loadgame3
 jsr loadgame4

 jmp driveoff

*-------------------------------
*   Reload 3: reload everything but blueprint
*   (& restart level)

RELOAD3
 jsr driveon

 jsr loadgame1
 jsr loadgame2
 jsr loadgame3
 jsr loadgame4

 jsr driveoff
 jmp warmgame

*-------------------------------
*
* L O A D   C O M M O N
*
*-------------------------------
* load common 1: tracks 1-3 (code)

loadcommon1
 jsr setmain

 lda #1
 sta track

 jsr rw18
 hex c3,ee

 jsr rw18
 hex c4
 hex e0,e1,e2,e3,e4,e5,e6,e7,e8
 hex e9,ea,eb,ec,ed,00,00,00,00

 jsr setaux

 jsr rw18
 hex c3,0e

 rts

*-------------------------------
* load common 2: tracks 11-12 (chtable3)

loadcommon2
 lda #11
 sta track

 jsr setmain

 jsr rw18
 hex c3,08

 jsr rw18
 hex c4
 hex 1a,1b,1c,1d,1e,1f,00,00,00
 hex 00,00,00,00,00,00,00,00,00

 rts

*-------------------------------
*
*  L O A D   G A M E
*
*-------------------------------
* load game 1: tracks 3 & 4 (code)

loadgame1
 lda #3
 sta track

 jsr setaux

 jsr rw18
 hex c3,0e

*-------------------------------
* load game 1a: track 4 (code)

loadgame1a
 lda #4
 sta track

 jsr setaux

 jsr rw18
 hex c4
 hex 04,05,06,07,08,09,0a,0b,0c
 hex 0d,20,21,22,23,24,25,26,27

 rts

*-------------------------------
* load game 2: tracks 5-13 (all image tables)

loadgame2
 lda #5
 sta track

 jsr setaux

 jsr rw18
 hex c3,60

 jsr rw18
 hex c3,72
 ;bgtable goes in aux
 jsr setmain

 jsr rw18
 hex c3,60

 jsr rw18
 hex c3,72

 jsr rw18
 hex c3,84

 jsr rw18
 hex c3,96

 jsr rw18
 hex c3,08

 jsr rw18
 hex c4
 hex 1a,1b,1c,1d,1e,1f,a8,a9,aa
 hex ab,ac,ad,ae,af,b0,b1,b2,b3

 jsr rw18
 hex c4
 hex b4,b5,b6,b7,b8,b9,ba,bb,bc
 hex bd,be,bf,00,00,00,00,00,00

 rts

*-------------------------------
* load game 3: tracks 13-18 (aux code, chtab4, bgtab2)

loadgame3
 jsr setaux

 lda #13
 sta track

 jsr rw18
 hex c4
 hex 00,00,00,00,00,00,00,00,00
 hex 00,00,00,96,97,98,99,9a,9b
 jsr rw18
 hex c3,9c ;chtable4.gd

 jsr rw18
 hex c3,28

 jsr rw18
 hex c3,3a

 jsr rw18
  hex c3,4c

 jsr rw18
 hex c3,84 ;bgtable2

 rts

*-------------------------------
* load game 4: tracks 19-21 (aux l.c. bank 2)
*
* We can't reach aux l.c. from here, so load code
* into mainmem hires area

loadgame4
 jsr setmain

 lda #19
 sta track

 jsr rw18
 hex c4
 hex 00,00,20,21,22,23,24,25,26
 hex 27,28,29,2a,2b,2c,2d,2e,2f

 jsr rw18
 hex c4
 hex 00,00,00,00,30,31,32,33,34
 hex 35,36,37,38,39,3a,3b,3c,3d

 jsr rw18
 hex c3,3e

* Now have it move itself to aux l.c.

 jmp moveauxlc ;still in mainmem

*-------------------------------
* xfer game:
* load tracks 7-10 & 12-13 (chtables 1,2 & 5)

xfergame
 lda #7
 sta track

 jsr setmain

 jsr rw18
 hex c3,60

 jsr rw18
 hex c3,72

 jsr rw18
 hex c3,84

 jsr rw18
 hex c3,96

 lda #12
 sta track

 jsr rw18
 hex c4
 hex 1a,1b,1c,1d,1e,1f,a8,a9,aa
 hex ab,ac,ad,ae,af,b0,b1,b2,b3

 jsr rw18
 hex c4
 hex b4,b5,b6,b7,b8,b9,ba,bb,bc
 hex bd,be,bf,00,00,00,00,00,00

 rts

*-------------------------------
*
*  L O A D   B U I L D E R
*
*-------------------------------
* load builder 1: tracks 4-6 (common code & bgtable)

loadbuild1
 lda #4
 sta track

 jsr setaux

 jsr rw18
 hex c4
 hex 04,05,06,07,08,09,0a,0b,0c
 hex 0d,00,00,00,00,00,00,00,00

 jsr setmain

 jsr rw18
 hex c3,60

 jsr rw18
 hex c3,72
;bgtable goes in main, not aux

 lda #18
 sta track

 jsr rw18
 hex c3,84 ;bgtable2

 rts

*-------------------------------
* load builder 2: tracks 22-28

loadbuild2
 lda #22
 sta track

 jsr setaux

 jsr rw18
 hex c3,60

 jsr rw18
 hex c3,72

 jsr rw18
 hex c3,84

 jsr rw18
 hex c3,96

 jsr setmain

 jsr rw18
 hex c3,ae

 jsr setaux

 jsr rw18
 hex c4
 hex 2e,2f,30,31,32,33,34,35,36
 hex 00,00,00,00,00,00,00,00,00

 jsr rw18
 hex c4
 hex 40,41,42,43,44,45,46,47,48
 hex 49,4a,4b,4c,4d,4e,4f,00,00

 rts

*===============================
*
*  C O P Y   B G   T A B L E
*
*  BGTABLE is loaded into $6000-$9600
*  Mainmem for builder, aux for game
*
*-------------------------------
copybgmain
 sta $c003
 sta $c004 ;read aux, write main
copybg
 lda #$60
 ldx #$60
 ldy #$96
 jmp MOVEMEM

copybgaux
 sta $c002
 sta $c005 ;read main, write aux

 jmp copybg

*-------------------------------
setaux sta $c003
 sta $c005 ;rd/write aux
 rts

setmain sta $c002
 sta $c004 ;rd/write main
 rts

*-------------------------------
*
*  S E T   R E S E T   V E C T O R
*
*-------------------------------
setreset
 ldx #0
:loop lda resetroutine,x
 sta realreset,x
 inx
 bne :loop ;move reset routine

 lda #realreset
 sta $3f2

 lda #>realreset
 sta $3f3 ;reset vector
;(for development)
 eor #$a5
 sta $3f4 ;power-up byte

 lda #break
 sta $3f0

 lda #>break
 sta $3f1

 rts

*-------------------------------
resetroutine
 sta $c004 ;RAMWRT off
 sta $c002 ;RAMRD off

 lda #break
 sta $3f2

 lda #>break
 sta $3f3 ;$fa59: monitor break routine

 eor #$a5
 sta $3f4

 jmp $fa62 ;reset

*-------------------------------
*
*  D R I V E   O N
*
*-------------------------------
driveon

 jsr setaux

* switch in bank 1 (RW18)

 bit $c08b
 bit $c08b ;1st 4k bank

* set Bbund ID

 lda BbundID
 sta :idbyte

 jsr rw18
 hex 07
:idbyte hex a9

* turn on drive 1

 jsr rw18
 hex 00
drive hex 01
delay hex 00
 rts

*-------------------------------
*
*  D R I V E   O F F
*
*-------------------------------
driveoff jsr rw18
 hex 01

* switch in bank 2

  bit $c083
 bit $c083 ;2nd 4k bank

 jmp setaux ;& set auxmem

*-------------------------------
*
*  R E A D / W R I T E   D I R E C T O R Y
*
*-------------------------------
READDIR lda #0
 sta delay

 jsr driveon

 lda #34
 sta track

 jsr rw18
 hex 84 ;readgroup
 hex 70,71,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00

 jmp driveoff

*-------------------------------
WRITEDIR lda #10
 sta delay

 jsr driveon

 lda #34
 sta track

 jsr rw18
 hex 84 ;read unused regions into scratch buffer
 hex 00,00,20,21,22,23,24,25,26
 hex 27,28,29,2a,2b,2c,2d,2e,2f

 jsr rw18
 hex 86 ;then write it all out
 hex 70,71,20,21,22,23,24,25,26
 hex 27,28,29,2a,2b,2c,2d,2e,2f

 jmp driveoff

*-------------------------------
*
*  S E T   1 s t   L E V E L
*
*-------------------------------
set1stlevel

 ldx #3
:loop lda firstlevel,x
 sta params,x
 dex
 bpl :loop

 rts

*-------------------------------
*
* L O A D / S A V E   L E V E L
*
* 2 routines: loadlevel & savelevel
*
* These in turn call 4 routines:
*   rdbluep & wrtbluep (load & save 9-sector blueprint)
*   rdbinfo & wrtbinfo (load & save 6-sector binfo)
*
* In: bluepTRK, bluepREG, binfoTRK, binfoREG
*
*   TRK = track # (1-33)
*   REG = region on track (0-1 for blueprint, 0-2 for binfo)
*
* Use $2000 auxmem as scratchpad
*
* Load level into "working blueprint" buffer in auxmem;
* game code will make a "backup copy" into aux l.c.
* (which we can't reach from here).
*
*-------------------------------
LOADLEVEL
 lda #0
 sta delay
 jsr driveon

 jsr rdbluep
 jsr rdbinfo

 jmp driveoff

]sl lda #10
 sta delay
 jsr driveon

 jmp wrtbluep

SAVELEVEL
 jsr ]sl
 jsr wrtbinfo

 jmp driveoff

SAVELEVELG
 jsr ]sl
 jmp driveoff

*-------------------------------
* read blueprint
*-------------------------------
rdbluep
 jsr setbluep
 bne :reg1

:reg0 jsr rw18
 hex 84
 hex b7,b8,b9,ba,bb,bc,bd,be,bf
 hex 00,00,00,00,00,00,00,00,00
 rts

:reg1 jsr rw18
 hex 84
 hex 00,00,00,00,00,00,00,00,00
 hex b7,b8,b9,ba,bb,bc,bd,be,bf
 rts

*-------------------------------
* write blueprint
*-------------------------------
wrtbluep
 jsr setbluep
 bne :reg1

:reg0 jsr rw18
 hex 84 ;read unused regions into scratch buffer
 hex 00,00,00,00,00,00,00,00,00
 hex 24,25,26,27,28,29,2a,2b,2c

 jsr rw18
 hex 86 ;then write it all out
 hex b7,b8,b9,ba,bb,bc,bd,be,bf ;new data
 hex 24,25,26,27,28,29,2a,2b,2c ;old data
 rts

:reg1 jsr rw18
 hex 84
 hex 24,25,26,27,28,29,2a,2b,2c
 hex 00,00,00,00,00,00,00,00,00

 jsr rw18
 hex 86
 hex 24,25,26,27,28,29,2a,2b,2c ;old data
 hex b7,b8,b9,ba,bb,bc,bd,be,bf ;new data
 rts

*-------------------------------
setbluep
 lda bluepTRK
 sta :track

 jsr rw18 ;seek track
 db 2,1
:track db 34

 lda bluepREG
 rts

*-------------------------------
* read binfo
*-------------------------------
rdbinfo
 lda binfoTRK
 sta track ;assume rdbluep has already sought it

 lda binfoREG
 beq :reg0

 cmp #1
 beq :reg1

:reg2 jsr rw18
 hex 84
 hex 00,00,00,00,00,00
 hex 00,00,00,00,00,00
 hex a6,a7,a8,a9,aa,ab
 rts

:reg1 jsr rw18
 hex 84
 hex 00,00,00,00,00,00
 hex a6,a7,a8,a9,aa,ab
 hex 00,00,00,00,00,00
 rts

:reg0 jsr rw18
 hex 84
 hex a6,a7,a8,a9,aa,ab
 hex 00,00,00,00,00,00
 hex 00,00,00,00,00,00
 rts

*-------------------------------
* write binfo
*-------------------------------
wrtbinfo
 lda binfoTRK
 sta track ;assume rdbluep has already sought it

 lda binfoREG
 beq :reg0

 cmp #1
 beq :reg1

:reg2 jsr rw18
 hex 84 ;first read into scratchpad...
 hex 24,25,26,27,28,29
 hex 2a,2b,2c,2d,2e,2f
 hex 00,00,00,00,00,00

 jsr rw18
 hex 86 ;...then write it all out
 hex 24,25,26,27,28,29
 hex 2a,2b,2c,2d,2e,2f
 hex a6,a7,a8,a9,aa,ab
 rts

:reg1 jsr rw18
 hex 84 ;first read into scratchpad...
 hex 24,25,26,27,28,29
 hex 00,00,00,00,00,00
 hex 2a,2b,2c,2d,2e,2f

 jsr rw18
 hex 86 ;...then write it all out
 hex 24,25,26,27,28,29
 hex a6,a7,a8,a9,aa,ab
 hex 2a,2b,2c,2d,2e,2f
 rts

:reg0 jsr rw18
 hex 84 ;first read into scratchpad...
 hex 00,00,00,00,00,00
 hex 24,25,26,27,28,29
 hex 2a,2b,2c,2d,2e,2f

 jsr rw18
 hex 86 ;...then write it all out
 hex a6,a7,a8,a9,aa,ab
 hex 24,25,26,27,28,29
 hex 2a,2b,2c,2d,2e,2f
 rts

*-------------------------------
*
*  M O V E M E M
*
*-------------------------------
MOVEMEM
 sta ]dest+1
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

*-------------------------------
*
*  T O N E
*
*-------------------------------
 dum locals
]dur ds 1
 dend

]setdur = 10
]setpitch = 20

TONE
 lda #]setdur
 sta ]dur
:outloop lda $c030
 ldx #]setpitch
:midloop ldy #64
:inloop dey
 bne :inloop
 dex
 bne :midloop
 dec ]dur
 bne :outloop
 rts

*-------------------------------
* Hires screen dump
*
* Dump hires screen to tracks 22-23
* In: A = page # (00/20)
*-------------------------------
SCREENDUMP
 clc
 adc #$20
 sta :sm1
 adc #$12
 sta :sm2

 lda BBundID
 pha
 lda #POPside2
 sta BBundID

 jsr driveon
 jsr setmain

 lda #22
 sta track
 jsr checkdisk

 jsr rw18
 hex c5
:sm1 hex 20
 jsr rw18
 hex c5
:sm2 hex 32

 jsr driveoff
 pla
 sta BBundID
 rts

*-------------------------------
* check track to make sure it's the right disk
*-------------------------------
checkdisk
 jsr rw18
 hex 84 ;don't advance
 hex 05,00,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00
 rts

*-------------------------------

 lst
eof ds 1
 usr $a9,1,$b00,*-org
 lst off
