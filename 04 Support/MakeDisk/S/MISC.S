* misc
org = $f900
DemoDisk = 0
 tr on
 lst off
*-------------------------------
 org org

 jmp VANISHCHAR
 jmp MOVEMUSIC
 clc
 bcc MOVEAUXLC ;relocatable
 jmp FIRSTGUARD
 jmp MARKMETERS

 jmp POTIONEFFECT
 jmp MOUSERESCUE
 jmp STABCHAR
 jmp UNHOLY
 jmp REFLECTION

 jmp MARKKIDMETER
 jmp MARKOPPMETER
 jmp BONESRISE
 jmp DECSTR
 jmp DOSAVEGAME

 jmp LOADLEVELX
 jmp CHECKALERT
 jmp DISPVERSION

*-------------------------------
 lst
 put eq
 lst
 put gameeq
 lst
 put seqdata
 lst
 put movedata
 lst
 put soundnames
 lst off

 dum $f0
]Xcount ds 1
]Xend ds 1
 dend

*-------------------------------
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

FirstSideB = 3

*-------------------------------
*
* Vanish character
*
*-------------------------------
VANISHCHAR
 lda #86
 sta CharFace
 lda #0
 sta CharAction
 sta CharLife
 sec
 sbc OppStrength
 sta ChgOppStr
]rts rts

*-------------------------------
*
*  Move a block of memory
*
*  In: A < X.Y
*
*  20 < 40.60 means 2000 < 4000.5fffm
*  WARNING: If x >= y, routine will wipe out 64k
*
*-------------------------------
 dum locals
]dest ds 2
]source ds 2
]endsourc ds 2
 dend

MOVEMEM sta ]dest+1
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
* Move 1K of music data from $5000 mainmem to aux l.c.
*
*-------------------------------
MOVEMUSIC
 bit RWBANK1
 bit RWBANK1
 sta RAMRDmain

 lda #$d0
 ldx #$50
 ldy #$54
 jsr MOVEMEM

 sta RAMRDaux
]rts rts

*-------------------------------
*
*  Move $2000.5FFF mainmem to auxiliary language card
*  Also sets interrupt vector ($FFFE.FFFF) in both l.c.'s
*
*  NOTE: This code is loaded into mainmem by MASTER
*  and called while still in mainmem.  Once in aux l.c.
*  this routine is useless!
*
*  Returns control to main l.c. bank 1
*
*-------------------------------
Tmovemem = MOVEMEM-$b000

MOVEAUXLC
 sta ALTZPon
 bit RWBANK2
 bit RWBANK2

 lda #$d0
 ldx #$20
 ldy #$50
 jsr Tmovemem

 bit RWBANK1
 bit RWBANK1

 lda #$d0
 ldx #$50
 ldy #$60
 jsr Tmovemem

* & set VBL interrupts

 lda #vbli ;routine in GRAFIX
 sta $FFFE
 lda #>vbli
 sta $FFFF

 sta ALTZPoff

 lda #vbli
 sta $FFFE
 lda #>vbli
 sta $FFFF ;set in main l.c. too

 rts

*-------------------------------
*
* Player can't run or jump past en-garde guard
*
*-------------------------------
FIRSTGUARD
 lda EnemyAlert
 cmp #2
 bcc ]rts
 lda CharSword
 bne ]rts
 lda OpSword
 beq ]rts
 lda OpAction
 cmp #2
 bcs ]rts

 lda CharFace
 cmp OpFace
 beq ]rts

 jsr getopdist
 cmp #-15
 bcc ]rts

* Bump off guard

 ldx CharBlockY
 lda FloorY+1,x
 sta CharY
 lda #bump
 jsr jumpseq
 jmp animchar

*-------------------------------
*
* Mark strength meters
*
*-------------------------------
Mark3 jsr Mark1 ;mark 3 blocks
 iny
Mark2 jsr Mark1 ;mark 2 blocks
 iny
Mark1 lda #4
 sta height
 clc
 lda #2
 jsr markwipe
 jmp markred

MARKMETERS
 jsr MARKKIDMETER
 jmp MARKOPPMETER

MARKKIDMETER
 ldy #20
 bne Mark3

MARKOPPMETER
 ldy #28
 bne Mark2
]rts rts

*-------------------------------
*
* Potion takes effect
*
*-------------------------------
wtlesstimer = 200
vibetimer = 3

POTIONEFFECT
 lda CharID
 bne ]rts

 ldx lastpotion
 beq ]rts
 bpl :notswd

* Sword (-1)

 lda #1
 sta gotsword
 lda #s_Sword
 ldx #25
 jsr cuesong
 lda #$ff
 sta lightcolor
 lda #3
 sta lightning ;3 white flashes
 rts

* Recharge meter (1)

:notswd cpx #1
 bne :2

 lda KidStrength
 cmp MaxKidStr
 beq ]rts ;already at full strength

 lda #$99
 sta lightcolor
 lda #2
 sta lightning ;2 orange flashes
 lda #s_ShortPot
 ldx #25
 jsr cuesong
 lda #1
 sta ChgKidStr
 rts

* Boost meter (2)

:2 cpx #2
 bne :3
 lda #$99
 sta lightcolor
 lda #5
 sta lightning ;5 orange flashes
 lda #s_Potion
 ldx #25
 jsr cuesong
 jmp boostmeter

* Weightless (3)

:3 cpx #3
 bne :4
 lda #s_ShortPot
 ldx #25
 jsr cuesong
 lda #wtlesstimer
 sta weightless
 lda #vibetimer
 sta vibes
 rts

* Upside down (4)

:4 cpx #4
 bne :5
 lda invert
 eor #$ff
 sta invert
 lda #2
 sta redrawflg
 jmp inverty

* Yecch (5)

:5 cpx #5
 bne :6
 lda #Splat ;yecch
 jsr addsound
 lda #-1
 sta ChgKidStr
 rts
:6
]rts rts

*-------------------------------
*
* Mouse rescues you
*
*-------------------------------
MOUSERESCUE
 jsr LoadKid

 lda #24 ;mouse
 sta CharID
 lda #200
 sta CharX
 ldx #0
 stx CharBlockY
 lda FloorY+1,x
 sta CharY
 lda #-1
 sta CharFace
 sta CharLife
 lda #1
 sta OppStrength

 lda #Mscurry
 jsr jumpseq
 jsr animchar

 jmp SaveShad

*-------------------------------
*
* Stab character
*
*-------------------------------
STABCHAR
 lda CharLife
 bpl ]rts ;already dead
 lda CharSword
 cmp #2
 bne :DL ;defenseless
 lda CharID
 cmp #4
 beq :wounded ;skel has no life points

 lda #1
 jsr decstr
 bne :wounded

 ldx CharID
 beq :killed

 ldx CharID
 cpx #4 ;skeleton
 bne :killed
 lda #0
 sta ChgOppStr ;skel is invincible
]rts rts

:killed jsr getbehind
 cmp #space
 bne :onground
 jsr getdist ;to EOB
 cmp #4
 bcc :onground
;if char is killed at edge, knock him off
 sec
 sbc #14
 jsr addcharx
 sta CharX
 inc CharBlockY
 lda #fightfall
 jsr jumpseq
 jmp :3

:onground lda #stabkill
 bne :2

:wounded lda #stabbed
:2 jsr jumpseq

:1 ldx CharBlockY
 lda FloorY+1,x
 sta CharY
 lda #0
 sta CharYVel

:3 lda #Splat
 jsr addsound

 jmp animchar

* stabbed when defenseless

:DL lda #100
 jsr decstr

 lda #stabkill ;dropdead?
 jmp :killed

*-------------------------------
*
* If shadow dies, you die (& vice versa)
*
*-------------------------------
UNHOLY
 lda level
 cmp #12
 bne ]rts

 lda OpID
 ora CharID
 cmp #1 ;kid & shadow?
 bne ]rts

 lda CharLife
 bpl ]rts
 lda OpLife
 bmi ]rts
;live char, dead opponent
 lda #$ff
 sta lightcolor
 lda #5
 sta lightning
 lda #Splat
 jsr addsound
 lda #100
 jmp decstr
]rts rts

*-------------------------------
*
*  R E F L E C T I O N
*
*-------------------------------
 do DemoDisk
REFLECTION
BONESRISE
 brk
 else

REFLECTION
 jsr LoadKid
 jsr GetFrameInfo

 lda createshad ;flag set?
 cmp #$ff
 beq CreateShad ;yes--reflection comes to life

 jsr getunderft
 cmp #mirror ;is kid standing before mirror?
  bne ]rts ;no

 jsr getreflect ;get char data for reflection

 lda dmirr ;if kid is on wrong side of mirror,
 bmi ]rts ;don't draw reflection

*  Draw kid's reflection (as a pseudo-character)

 jsr setupchar

*  Crop edges

 ldx CharBlockY
 inx
 lda BlockTop,x
 cmp FCharY
 bcs ]rts
 sta FCharCU

 lda CharBlockX ;of mirror
 asl
 asl ;x 4
 clc
 adc #1
 sta FCharCL

 jmp addreflobj ;normal reflection

*-------------------------------
* Get char data for kid's reflection

getreflect
 lda CharBlockX
 jsr getblockej
 clc
 adc #angle+3 ;fudge factor
 sta mirrx ;mirror x-coord (0-139)

 jsr getdist

 ldx CharFace
 bmi :left

 eor #$ff ;facing right--
 clc
 adc #14 ;get dist to back of block

:left sec
 sbc #2 ;another fudge factor
 sta dmirr ;distance from mirror

 lda mirrx
 asl
 sec
 sbc CharX
 sta CharX ;reflection x-coord

 lda CharFace
 eor #$ff
 sta CharFace

]rts rts

*-------------------------------
* Bring reflection to life as shadowman

CreateShad
 jsr getreflect ;get char data for reflection

 lda #0
 sta createshad

 lda #1 ;shadman
 sta CharID

 lda #MirrorCrack
 jsr addsound

 jsr SaveShad

 lda MaxKidStr
 sta MaxOppStr
 sta OppStrength
 lda #1
 sta KidStrength
 jmp markmeters

*-------------------------------
*
* Bones rise
*
*-------------------------------
skelscrn = 1
skelx = 5
skely = 1
skeltrig = 2
skelprog = 2

BONESRISE
 lda level
 cmp #3
 bne ]rts

 lda ShadFace
 cmp #86
 bne ]rts
 lda VisScrn
 cmp #skelscrn
 bne ]rts
 lda exitopen
 beq ]rts
 lda KidBlockX
 cmp #skeltrig
 beq :trig
 cmp #skeltrig+1
 bne ]rts

* Remove dead skeleton

:trig lda VisScrn
 ldx #skelx
 ldy #skely
 jsr rdblock
 pha
 lda #floor
 sta (BlueType),y
 lda #24
 sta height
 lda #2
 jsr markred
 jsr markwipe
 iny
 jsr markred
 jsr markwipe
 pla
 cmp #bones
 bne ]rts

* Create live skeleton

 lda VisScrn
 sta CharScrn

 ldx #skely
 stx CharBlockY
 lda FloorY+1,x
 sta CharY

 lda #skelx
 sta CharBlockX
 jsr getblockej
 clc
 adc #angle+7
 sta CharX

 lda #-1 ;left
 sta CharFace

 lda #arise
 jsr jumpseq
 jsr animchar

 lda #skelprog
 sta guardprog

 lda #-1
 sta CharLife
 lda #3
 sta OppStrength

 lda #0
 sta alertguard
 sta refract
 sta CharXVel
 sta CharYVel

 lda #2
 sta CharSword

 lda #4 ;skeleton
 sta CharID

 jmp SaveShad ;save ShadVars

 fin

*-------------------------------
*
* Decrease strength by A (non-0)
*
* Out: non-0 if char lives, 0 if he dies
*      ChgStrength
*
*-------------------------------
DECSTR
 ldx CharID
 bne :enemy

 cmp KidStrength
 bcs killkid

 eor #$ff
 clc
 adc #1 ;negate
 sta ChgKidStr
 rts

:enemy
 cmp OppStrength
 bcs killopp

 eor #$ff
 clc
 adc #1
 sta ChgOppStr
 rts

*-------------------------------
* Kill character (or opponent)
* Return A = 0
*-------------------------------
killkid
 lda #0
 sec
 sbc KidStrength
 sta ChgKidStr

 lda #0
]rts rts

*-------------------------------
killopp
 lda #0
 sec
 sbc OppStrength
 sta ChgOppStr

 lda #0
]rts rts


*-------------------------------
* Save current game to disk
*
* In: SavLevel = level ($ff to erase saved game)
*-------------------------------
DOSAVEGAME
 lda level
 cmp #FirstSideB
 bcs :doit ;must have reached side B
 lda #Splat
 jmp addsound
:doit

* Put data into save-game data area

 lda origstrength
 sta SavStrength

 lda FrameCount
 sta SavTimer
 lda FrameCount+1
 sta SavTimer+1

 lda NextTimeMsg
 sta SavNextMsg

* Write to disk

 jmp savegame

*-------------------------------
* alt bg & char set list
* Level #:      0  1  2  3  4  5  6  7  8  9 10 11 12 13 14

bgset1 db 00,00,00,00,01,01,01,02,02,02,01,01,02,02,01
bgset2 db 00,00,00,00,01,01,01,02,02,02,01,01,02,02,01
chset db 00,00,00,01,02,02,03,02,02,02,02,02,04,05,05

* blueprint track & region lists (indexed by level #)
* NOTE--make sure these match lists in DIALOGER

bluepTRKlst
 db 33,33,32         ;3 levels on side A
 db 33,33,32,32,31,31   ;12 levels on side B
 db 30,30,29,29,28,28

bluepREGlst
 db 0,1,1
 db 0,1,0,1,0,1
 db 0,1,0,1,0,1

*-------------------------------
*
* Load level from disk
* In: X = level # (0-14)
*
*-------------------------------
LOADLEVELX
 lda bluepTRKlst,x
 sta bluepTRK
 lda bluepREGlst,x
 sta bluepREG

 lda bgset1,x ;A
 pha
 lda bgset2,x ;X
 ldy chset,x ;Y
 tax
 pla

 jmp loadlevel ;in MASTER
]rts rts

*-------------------------------
*
* In: Kid & Shad data
* Out: EnemyAlert
*   2: kid & shad are on same stretch of floor
*   1: slicer, gaps in floor, or other obstacles, but
*      line of sight is clear
*   0: can't see each other
*
*-------------------------------
gfightthres = 28*4

]safe lda #0
 sta EnemyAlert
]rts rts

CHECKALERT
 lda ShadID
 cmp #24 ;mouse?
 beq ]rts
 cmp #1 ;shadowman?
 bne :notshad
 lda level
 cmp #12
 bne ]safe ;fight shadow only on level 12

:notshad
 lda KidPosn
 beq ]safe
 cmp #219
 bcc :noclimb
 cmp #229
 bcc ]safe ;on staircase
:noclimb
 lda ShadFace
 cmp #86
 beq ]safe

 lda KidLife
 and ShadLife
 bpl ]safe ;one is dead

 lda KidScrn
 cmp ShadScrn
 bne ]safe

 lda KidBlockY
 cmp ShadBlockY
 bne ]safe

 lda #2 ;clear path
 sta EnemyAlert

* Get range of blocks to scan (]Xcount --> ]Xend)

 lda KidBlockX
 jsr getblockej
 clc
 adc #7 ;middle of block
 sta ]Xcount

 lda ShadBlockX
 jsr getblockej
 clc
 adc #7
 sta ]Xend

 do 0
 lda ]Xcount
 jsr getblockxp
 ldx #1
 jsr showpage
 lda ]Xend
 jsr getblockxp
 ldx #2
 jsr showpage
 fin

 lda ]Xend
 cmp ]Xcount
 bcs :cont
 tax
 lda ]Xcount
 sta ]Xend
 stx ]Xcount
:cont

* If leftmost block is a slicer, skip it

 lda ]Xcount
 jsr :rdblock
 cmp #slicer
 bne :1
 lda #14
 clc
 adc ]Xcount
 sta ]Xcount

* If rightmost block is a gate, skip it

:1 lda ]Xend
 jsr :rdblock
 cmp #gate
 bne :20
 lda ]Xend
 sec
 sbc #14
 sta ]Xend

:20 lda ]Xend
 cmp ]Xcount
 bcc :rts

* Scan from ]Xcount to ]Xend (left to right)

 lda ]Xcount
:loop cmp ]Xend
 beq :9
 bcs :rts

:9 jsr :rdblock

 cmp #block
 beq :safe
 cmp #panelwif
 beq :safe
 cmp #panelwof
 beq :safe ;solid barrier blocks view

 cmp #loose
 beq :view
 cmp #gate
 bne :2
 lda (BlueSpec),y
 cmp #gfightthres
 bcs :clear
 bcc :view

:2 cmp #slicer
 beq :view

 jsr cmpspace
 bne :clear ;closed gate, slicer, gap in floor, etc.
;are obstacles but don't block view
:view lda #1
 sta EnemyAlert

:clear lda ]Xcount
 clc
 adc #14
 sta ]Xcount
 bne :loop
:rts
]rts rts

:safe lda #0
 sta EnemyAlert
]rts rts

*-------------------------------
* In: A = X-coord
* Out: rdblock results
*-------------------------------
:rdblock jsr getblockxp
 tax
 ldy KidBlockY
 lda KidScrn
 jmp rdblock

*-------------------------------
*
*  Display version # on text page 1 (& wait for keypress)
*
*-------------------------------
DISPVERSION
 lda #" "
 jsr lrcls

 sta RAMWRTmain

 ldx #0
:loop lda textline,x
 cmp #"@"
 beq :done
 sta $400,x ;top line of screen
 inx
 bpl :loop
:done
 lda RAMWRTaux
 sta $c054 ;PAGE2 off
 sta $c051 ;TEXT on

* Wait for keypress

:wloop lda $c000
 bpl :wloop
 sta $c010

 lda $c057 ;HIRES on
 lda $c050 ;TEXT off
 lda PAGE
 bne :1
 lda $c055 ;PAGE2 on
:1
 lda #" "
 jmp lrcls

*-------------------------------
 lst
 ds 1
 usr $a9,21,$b00,*-org
 lst off
