* auto
DemoDisk = 0
org = $5400
 tr on
 lst off
*-------------------------------
*
*  PRINCE OF PERSIA
*  Copyright 1989 Jordan Mechner
*
*-------------------------------
 org org

 jmp AUTOCTRL
 jmp CHECKSTRIKE
 jmp CHECKSTAB
 jmp AUTOPLAYBACK
 jmp CUTCHECK

 jmp CUTGUARD
 jmp ADDGUARD
 jmp CUT

*-------------------------------
 lst
 put eq
 lst
 put gameeq
 lst
 put seqdata
 lst
 put soundnames
 lst
 put movedata
 lst off

 dum $f0
ztemp ds 1
prob ds 1
]cutdir ds 1
ProgStart ds 2
 dend

plus1 db -1,1
minus1 db 1,-1

* Thresholds for cut to new screen

TopCutEdgePl = ScrnTop+10
TopCutEdgeMi = ScrnTop-16
BotCutEdge = ScrnBottom+24

LeftCutEdge = ScrnLeft-4
RightCutEdge = ScrnRight+4

*-------------------------------
* Locations of special objects

flaskscrn = 24
flaskx = 3
flasky = 0

mirscrn = 4
mirx = 4
miry = 0

swordscrn = 15
swordx = 1
swordy = 0

mousetimer = 150 ;from topctrl

*-------------------------------
* Strike/block ranges

strikerange1 = 12
strikerange2 = 29
blockrange1 = 0
blockrange2 = 29 ;from TestStrike

*-------------------------------
* Other constants:

swordthres = 90
engardethres = 60
strikethres1 = strikerange1
strikethres2 = strikerange2
blockthres1 = 10
blockthres2 = blockrange2
tooclose = strikethres1
toofar = strikethres2+6 ;min dist at which you can advance safely
offguardthres = 8
jumpthres = 50
runthres = 40
blocktime = 4

*-------------------------------
*
* Fighter params (indexed by guardprog #)
*
* strikeprob = probability x255 of striking from ready posn
* restrikeprob = prob x 255 of restriking after blocking
* blockprob  = prob x255 of blocking opponent's strike
* advprob = of advancing to within striking range
* refractimer = length of refractory period after being hit
*
*               0   1   2   3   4   5   6   7   8   9   10  11

strikeprob
 db 075,100,075,075,075,050,100,220,000,060,040,060
restrikeprob
 db 000,000,000,005,005,175,020,010,000,255,255,150
blockprob
 db 000,150,150,200,200,255,200,250,000,255,255,255
impblockprob
 db 000,075,075,100,100,145,100,250,000,145,255,175
advprob
 db 255,200,200,200,255,255,200,000,000,255,100,100
refractimer
 db 020,020,020,020,010,010,010,010,000,010,000,000
specialcolor
 db 000,000,000,001,000,001,001,000,000,000,000,001
extrastrength
 db 000,000,000,000,001,000,000,000,000,000,000,000

numprogs = 12

*-------------------------------
* Basic guard strength & uniform color (indexed by level #)

basicstrength
 db 4,3,3,3,3,4,5 ;levels 0-6
 db 4,4,5,5,5,4,6 ;levels 7-13

basiccolor
 db 1,0,0,0,1,1,1 ;0 = blue, 1 = red
 db 0,0,0,1,1,0,0

shadstrength = 4

*-------------------------------
*
* 10: kid (demo)
* 11: enemy (demo)
*
*-------------------------------
*
*  Automatic enemy control routine
*
*  In: Char vars reflect position in PRECEDING frame;
*      Op vars reflect position in UPCOMING frame
*      guardprog = program #
*
*  (Exception: When used by kid fighting in demo, both
*  Char & Op vars reflect preceding frame.)
*
*-------------------------------
]rts rts

AUTOCTRL
 jsr DoRelease

 lda CharID
 beq :5 ;control kid in demo

 lda justblocked
 beq :jb0
 dec justblocked

:jb0 lda gdtimer
 beq :gt0
 dec gdtimer
:gt0
 lda refract ;refractory period after being hit
 beq :2
 dec refract
:2
 lda CharID
 cmp #24 ;mouse?
 beq :6
 cmp #4 ;skel?
 beq :3
 cmp #2 ;guard?
 bcc :1
 lda level
 cmp #13 ;vizier?
 beq :4
 jmp GuardProg
:1 jmp ShadowProg
:3 jmp SkelProg
:4 jmp VizierProg
:5 jmp KidProg
:6 jmp MouseProg

*-------------------------------
*  M O U S E
*-------------------------------
MouseProg
 lda CharFace
 cmp #86
 beq ]rts
 lda CharAction
 beq :1 ;already stopped
 lda CharX
 cmp #166
 bcs ]rts
 lda #Mleave
 jsr jumpseq
 jmp animchar ;sets CharAction = 0

:1 lda CharX
 cmp #200
 bcc ]rts
 jmp VanishChar

*-------------------------------
*  S H A D O W M A N
*-------------------------------
 do DemoDisk
ShadowProg
SkelProg
VizierProg
 brk

 else
ShadowProg
 lda level
 cmp #4
 bne :0
 jmp ShadLevel4

:0 cmp #5
 bne :1
 jmp ShadLevel5

:1 cmp #6
 bne :2
 jmp ShadLevel6

:2 cmp #12
 bne :3
 jmp FinalShad
:3
]rts rts

*-------------------------------
* Level-specific code for:
* Level 6 (plunge)
*-------------------------------
ShadLevel6
 lda CharScrn
 cmp #1
 beq Shad6a
 rts

* Level 6, screen 1
* When kid jumps chasm, step on plate

Shad6a
 lda KidPosn
 cmp #43
 bne ]rts
 lda KidX
 cmp #$80
 bcs ]rts
 jsr DoPress
 jmp DoFwd ;step fwd

*-------------------------------
* Level 5 (THIEF)
*-------------------------------
ShadLevel5
 lda CharScrn
 cmp #flaskscrn
 beq Shad5
]rts rts

* Level 5, screen 24
* When gate opens, steal potion

Shad5
 lda PlayCount
 bne :1 ;continue playback

 lda #flaskscrn
 ldx #1 ;x
 ldy #0 ;y
 jsr rdblock ;gate
 lda (BlueSpec),y
 cmp #20
 bcc ]rts
;begin playback
 lda #0
 sta PreRecPtr

:1 lda #ShadProg5
 ldx #>ShadProg5
 jsr AutoPlayback

 lda CharX
 cmp #15
 bcs ]rts
 jmp VanishChar

*-------------------------------
* Level 4 (mirror)
*-------------------------------
ShadLevel4
 lda CharScrn
 cmp #4
 bne ]rts
 lda CharX
 cmp #80
 bcc :gone
 jmp DoFwd ;run o.s.
:gone jmp VanishChar

*-------------------------------
* Level 12 (final battle)
*-------------------------------
FinalShad

* Screen 15: Jump on top of kid

 lda CharScrn
 cmp #swordscrn
 bne :cont
 lda shadowaction
 bne :cont ;already did it
 lda OpX
 cmp #150
 bcs :hold ;hold shad at top until kid arrives

 lda #1
 sta shadowaction
 bne :cont

:hold lda #shadpos12
 ldx #>shadpos12
 jmp csps
]rts rts

* Continue

:cont lda CharSword
 cmp #2
 bcs :fight
 lda OpSword
 cmp #2
 bcs :hostile
 lda offguard
 bne :face
:hostile
 lda EnemyAlert
 cmp #2
 bcc :2
 jsr getopdist
 cmp #swordthres
 bcs :2 ;wait until kid gets close

 lda CharPosn
 cmp #15
 bne ]rts
 jmp DoEngarde ;draw on kid

* turn to face kid

:2 jsr getopdist
 bpl ]rts
 jmp DoBack

* Normal fighting

:fight
 lda offguard
 beq :1 ;has kid put up sword?
 lda refract
 bne :1 ;yes--wait a moment--
 jmp DoDown ;--then lower your guard

:1 jmp EnGarde ;normal fighting

* Face to face--swords down

:face jsr getopdist
 bmi :merge ;whammo!

 lda EnemyAlert
 cmp #2
 bne :wait
 lda OpPosn
 cmp #3
 bcc :wait
 cmp #15
 bcc :go
 cmp #127
 bcc :wait
 cmp #133
 bcs :wait

* If kid starts moving towards you, reciprocate
* (Accept startrun & stepfwd)

:go jmp DoFwd

* Kid & shadow reunite

:merge
 lda #$ff ;white
 sta lightcolor
 lda #10
 sta lightning

 jsr boostmeter

 lda #s_Rejoin
 ldx #85
 jsr cuesong

 lda #42
 sta mergetimer

 lda #0
 sta CharID
 jsr SaveKid ;shadow turns into kid
 jmp VanishChar
:wait
]rts rts

*-------------------------------
* S K E L E T O N
*-------------------------------
SkelProg
 lda #2
 sta CharSword
 jmp GuardProg

*-------------------------------
* V I Z I E R
*-------------------------------
VizierProg
 jmp GuardProg

 fin ;DemoDisk

*-------------------------------
* K I D (in demo)
*-------------------------------
KidProg
 jmp GuardProg

*-------------------------------
* G U A R D
*-------------------------------
GuardProg
 lda CharSword
 cmp #2 ;Are you already en garde?
 bcc Alert ;no
 jmp EnGarde ;yes
]rts rts

*-------------------------------
*
* Alert (not en garde)
*
*-------------------------------
Alert
 lda KidLife
 bpl ]rts ;kid's dead--relax

* If kid is behind you, turn to face him

 jsr getopdist
 ldx OpBlockY
 cpx CharBlockY
 bne :difflevel
 cmp #-8 ;if kid is right on top of you, go en garde!
 bcs :eng
:difflevel
 ldx alertguard
 beq :ok ;otherwise wait for a sound to alert you
 ldx #0
 stx alertguard
:alert
 cmp #128
 bcc :eng
 cmp #-4
 bcs :ok ;overlapping--stand still
 jmp DoTurn ;turn around

* If you can see kid, go en garde

:ok cmp #128
 bcs ]rts ;kid is behind you

:eng lda EnemyAlert
 beq ]rts

 lda level
 cmp #13
 bne :1 ;Vizier only: wait for music to finish
 lda SongCue
 bne ]rts

:1 jmp DoEngarde
]rts rts

*-------------------------------
*
* En garde
*
*-------------------------------
EnGarde
 lda CharPosn
 cmp #166
 beq ]rts
 cmp #150
 bcc ]rts ;wait till you're ready

 lda EnemyAlert
 cmp #2
 bcs :ea2
 cmp #1 ;EnemyAlert = 1: Kid is in sight, but a
 beq ]rts ;gap or barrier separates you--stay put

* Kid is out of sight (EnemyAlert = 0)
* If kid has "dropped out" of fight, follow him down

 lda droppedout ;flag set by CHECKFLOOR
 beq :1
 jmp FollowKid

* else return to alert position

:1 lda CharID
 cmp #4
 beq ]rts ;(except skeleton)
 jmp DoDropguard

* EnemyAlert = 2: Clear stretch of floor to player

* If kid is stunned, let him recover...

:ea2 jsr getopdist
 bmi :norec
 cmp #12
 bcc :norec ;unless he's right on top of you
 lda OpPosn
 cmp #102
 bcc :norec
 cmp #118
 bcs :norec
 lda OpAction
 cmp #5
 beq ]rts
:norec

* Advance to closest safe distance

 jsr getopdist
 cmp #toofar
 bcs :outofrange

 ldx CharSword
 cpx #2
 bcc :offg

 cmp #tooclose
 bcc :tooclose
 jmp InRange

:offg cmp #offguardthres
 bcc :tooclose
 jmp InRange
]rts rts

* Out of range

:outofrange
 lda refract
 bne ]rts

 lda CharFace
 cmp OpFace
 beq :nojump ;chase him

 lda OpPosn
 cmp #7
 bcc :norun
 cmp #15
 bcc :runwait
:norun
 cmp #34
 bcc :nojump
 cmp #44
 bcc :jumpwait ;If kid is running towards you, stay put
:nojump
 jsr getinfront
 jsr cmpspace ;Don't advance unless solid floor
 beq :gap
 jsr get2infront
 jsr cmpspace
 bne :solid

:gap jmp DoRetreat
:solid jmp DoAdvance

* Kid is trying to get past you--cut him down!

:jumpwait
 jsr getopdist
 cmp #jumpthres
 bcs ]rts ;wait
 jmp DoStrike

:runwait
 jsr getopdist
 cmp #runthres
 bcs ]rts
:strike jmp DoStrike

* Too close to hit him

:tooclose
 lda CharFace
 cmp OpFace
 beq :ret
 jmp DoAdvance
:ret jmp DoRetreat

*-------------------------------
*
*  Kid has "dropped out" of fight
*  Advance until you run out of floor--
*  then decide whether to jump down after him
*
*-------------------------------
FollowKid
 lda OpAction
 cmp #2
 beq :hanging
 cmp #6
 beq :hanging ;wait--kid is hanging on ledge

 jsr getinfront
 sta ztemp
 jsr cmpbarr
 bne :stopped
 lda ztemp
 jsr cmpspace
 beq :atedge
 jmp DoAdvance

* At edge of floor.  Follow kid down ONLY if:
* (1) it's a 1-story drop to solid floor
* (2) kid is still down there

:atedge
 jsr getinfront
 inc tempblocky
 jsr rdblock1
 sta ztemp ;is it safe?
 cmp #spikes
 beq :stopped
 cmp #loose
 beq :stopped
 jsr cmpbarr
 bne :stopped
 lda ztemp
 jsr cmpspace
 beq :stopped

 lda CharBlockY
 clc
 adc #1
 cmp OpBlockY
 bne :stopped ;kid's not down there

* It looks safe--follow him down

 jmp DoAdvance

:stopped lda #0
 sta droppedout
 jmp DoRetreat ;so you can kill him if he climbs up
:hanging
]rts rts

*-------------------------------
*
*  In range
*
*-------------------------------
InRange
 lda OpSword ;is opponent armed & en garde?
 cmp #2
 beq :fight ;yes

* Opponent is unarmed or off guard--maul him!

 lda refract
 bne ]rts

 jsr getopdist
 cmp #strikethres2
 bcc :1
 jmp DoAdvance ;advance until within range...
:1 jmp DoStrike ;then strike

* Opponent is en garde--use strategy

:fight
 jmp GenFight

*-------------------------------
*
* General Fighting Routine
*
* (Fighters are en garde, face to face, and too close to
* advance safely)
*
*-------------------------------
GenFight
 jsr getopdist
 cmp #blockthres1
 bcc :outofrange
 cmp #blockthres2
 bcs :outofrange

 jsr MaybeBlock ;block opponent's strike?

 lda refract
 bne ]rts

 jsr getopdist
 cmp #strikethres1
 bcc :outofrange
 cmp #strikethres2
 bcs :outofrange

 jmp MaybeStrike ;strike?

:outofrange
 jmp MaybeAdvance ;advance to within strike range?
]rts rts

*-------------------------------
*
* Advance to within strike range?
* (Only consider it if gdtimer = 0)
*
*-------------------------------
MaybeAdvance
 lda guardprog
 beq :dumb ;Guard #0 is too dumb to care
 lda gdtimer
 bne ]rts

:dumb jsr rndp
 cmp advprob,x
 bcs ]rts

 jmp DoAdvance

*-------------------------------
*
* Block opponent's strike?
*
*-------------------------------
MaybeBlock
 lda OpPosn
 cmp #152 ;guy4
 beq :99
 cmp #153 ;guy5
 beq :99
 cmp #162 ;guy22 (block to strike)
 bne ]rts

:99 lda justblocked
 bne :impaired
 jsr rndp
 cmp blockprob,x
 bcc :block
]rts rts

:impaired
 jsr rndp
 cmp impblockprob,x
 bcs ]rts
:block jmp DoBlock

*-------------------------------
*
* Strike?
*
*-------------------------------
MaybeStrike
 ldx OpPosn
 cpx #169
 beq ]rts
 cpx #151 ;opponent starting to strike?
 beq ]rts ;yes--don't strike

 ldx CharPosn
 cpx #161 ;have I just blocked?
 beq :restrike
 cpx #150
 beq :restrike ;yes--restrike?

 jsr rndp
 cmp strikeprob,x
 bcs ]rts
 jmp DoStrike

:restrike
 jsr rndp
 cmp restrikeprob,x
 bcs ]rts
 jmp DoStrike

*-------------------------------
DoRelease
 lda #0
 sta clrF
 sta clrB
 sta clrU
 sta clrD
 sta clrbtn
 sta JSTKX
 sta JSTKY
 sta btn
 rts

DoAdvance
DoFwd
 lda #-1
 sta clrF
 sta JSTKX
 rts

DoRetreat
DoBack
 lda #-1
 sta clrB
 lda #1
 sta JSTKX
 rts

DoBlock
DoUp lda #-1
 sta clrU
 sta JSTKY
 rts

DoTurn
DoDown lda #-1
 sta clrD
 lda #1
 sta JSTKY
 rts

DoStandup
 lda #-1
 sta clrU
 jmp DoBack

DoDropguard
DoRunaway
 lda #-1
 sta clrD
 jmp DoBack

DoEngarde
 lda #-1
 sta clrD
 jmp DoFwd

DoStrike
DoPress
 lda #-1
 sta clrbtn
 sta btn
 rts

DoRelBtn
 lda #0
 sta btn
]rts rts

*-------------------------------
*
*  R N D P
*
*  Return X = guardprog, A = rnd #
*
*-------------------------------
rndp
 ldx guardprog
 jmp rnd

*-------------------------------
*
*  C H E C K   S T R I K E
*
*  Check for sword contact
*
*  Going in: Kid & Shad vars represent position in
*   UPCOMING frame
*
*  Out: Kid & Shad vars
*  (Return Action = 99 if stabbed)
*
*-------------------------------
CHECKSTRIKE
 lda KidPosn
 beq ]rts
 cmp #219
 bcc :noclimb
 cmp #229
 bcc ]rts ;on staircase
:noclimb
 jsr LoadShadwOp
 jsr TestStrike
 jsr SaveShadwOp

 jsr LoadKidwOp
 jsr TestStrike
 jsr SaveKidwOp

]rts rts

*-------------------------------
TestStrike

 lda CharSword
 cmp #2 ;in fighting mode?
 bne ]rts ;no

 lda CharBlockY
 cmp OpBlockY
 bne ]rts

* Am I on a test (strike) frame?

 lda CharPosn
 cmp #153 ;guy5 (frame before full ext.)
 beq :test
 cmp #154 ;guy6 (full ext.)
 bne ]rts

* I'm striking--is opponent blocking?

:test
 jsr getopdist
 cmp #blockrange1
 bcc :nobloc

 cmp #blockrange2
 bcs :nobloc

 lda OpPosn
 cmp #161
 beq :11
 cmp #150 ;blocking?
 bne  :nobloc ;no

* Yes -- opponent blocks my strike

:1 lda #161
 sta OpPosn ;change opp to "successful block"

:11 lda CharID
 beq :12 ;am I a guard?
 lda #blocktime ;yes--impair my blocking ability for a while
 sta justblocked

:12 lda #blockedstrike
 jsr jumpseq
 jmp animchar

* Skewer opponent?

:nobloc
 lda CharPosn
 cmp #154 ;full ext
 bne ]rts

 jsr getopdist

 ldx OpSword
 cpx #2
 bcs :ong
 cmp #offguardthres
 bcs :cont1
 rts
:ong cmp #strikerange1
 bcc ]rts

:cont1 cmp #strikerange2
 bcs ]rts

 lda #99 "stabbed"
 sta OpAction
]rts rts

*-------------------------------
*  C H E C K   S T A B
*-------------------------------
CHECKSTAB
 lda ShadAction
 cmp #99
 bne :1

 lda KidAction
 cmp #99
 beq :doublestab
:2
 jsr LoadShad
 jsr StabChar
 jsr SaveShad

 jsr rndp
 lda refractimer,x
 sta refract

:1 lda KidAction
 cmp #99
 bne ]rts

 jsr LoadKid
 jsr StabChar
 jmp SaveKid

* Both chars finish lunge simultaneously

:doublestab
 lda #1
 sta KidAction
 bne :2 ;player wins a tie
]rts rts

*-------------------------------
* Change shadowman posn
* In: A-X = shadpos L-H
* Out: Char data
*-------------------------------
chgshadposn
 sta ztemp
 stx ztemp+1
 ldy #6
:loop lda (ztemp),y
 sta Char,y
 dey
 bpl :loop

 ldy #7
 lda (ztemp),y
 jsr jumpseq

 lda #1
 sta CharID

 lda #0
 sta PlayCount ;zero playback counter
 rts

* ... & save

csps jsr chgshadposn

 lda #3
 sta guardprog

 lda #shadstrength
 sta MaxOppStr
 sta OppStrength

 jmp SaveShad

*-------------------------------
* (Posn, X, Y, Face, BlockX, BlockY, Action)
*               0  1  2  3  4  5  6

shadpos6a hex 0f,51,76,00,00,01,00
 db stand

shadpos5 hex 0f,37,37,00,ff,00,00
 db stand ;just o.s. to L

shadpos12 hex 0f,51,f0,00,00,00,00
 db stepfall

*-------------------------------
EndProg = -2
EndDemo = -1
Ctr = 0
Fwd = 1
Back = 2
Up = 3
Down = 4
Upfwd = 5
Press = 6
Release = 7

* Commands:
*
* -2 - end of programmed sequence
* -1 - end of demo
*  0 - center jstk & release btn
*  1 - jstk fwd
*  2 - jstk back
*  3 - jstk up
*  4 - jstk down
*  5 - jstk up & fwd
*  6 - press & hold btn
*  7 - release btn

*-------------------------------
*
* Prerecorded sequence format:
*
*  1.  Frame # (1 byte)
*  2.  Command (1 byte)
*
* 255 frames = approx. 25-30 seconds
*
*-------------------------------
* Level 5 (THIEF): Steal potion

ShadProg5
 db 0,Ctr
 db 1,Fwd
 db 14,Ctr
 db 18,Press
 db 29,Release
 db 45,Back
 db 49,Fwd
 db 255,EndProg

*-------------------------------
*
*  Play back prerecorded movement sequence
*
*  In: A-X = program start addr
*      PlayCount = frame #
*      PreRecPtr = pointer to next command
*
*-------------------------------
AUTOPLAYBACK
 sta ProgStart
 stx ProgStart+1

* Inc frame counter

 lda PlayCount
 cmp #254
 bcs :rts
 inc PlayCount

* Look up time of next command

 ldy PreRecPtr

 lda PlayCount
 cmp (ProgStart),y
 bcs :next

* Not there yet--repeat last command

 dey
 lda (ProgStart),y
 jmp :ex

* We're there--

:next iny
 lda (ProgStart),y ;command
 iny
 sty PreRecPtr

* Execute command

:ex cmp #-1
 beq :enddemo
 cmp #0
 beq :ctr
 cmp #1
 beq :fwd
 cmp #2
 beq :back
 cmp #3
 beq :up
 cmp #4
 beq :down
 cmp #5
 beq :upfwd
 cmp #6
 beq :press
 cmp #7
 beq :release
:rts
]rts rts

* Commands

:ctr jmp DoRelease
:fwd jmp DoFwd
:back jmp DoBack
:up jmp DoUp
:down jmp DoDown
:upfwd jsr DoUp
 jmp DoFwd
:press jmp DoPress
:release jmp DoRelBtn

:enddemo ; lda autopilot
; bne :endpb
 jmp attractmode ;Game: end demo
:endpb ; lda #0 ;Editor: end playback
; sta autopilot
; rts

*-------------------------------
*
*  C U T   C H E C K
*
*  Cut with kid
*
*-------------------------------
CUTCHECK
 lda CUTTIMER
 beq :ok

 dec CUTTIMER
]rts rts

:ok
 jsr LoadKid
 jsr setupchar
 jsr getedges
 jsr cutchar ;cut with character
 bmi ]rts ;no cut
 sta ]cutdir

 jsr SaveKid

 lda CharScrn
 sta cutscrn

 lda ShadFace
 cmp #86 ;is there a guard on old screen?
 beq ]rts ;no

* What to do with guard?  Two choices:
*
*  (1) UPDATE -- leave guard behind on old screen (& update
*      his coords so he'll still be there when we come back)
*  (2) TRANSFER -- transfer guard to new screen (& delete his
*      coords from old screen)

 lda ShadLife
 bpl :update ;dead guard on old screen--leave him behind

 lda ShadSword
 cmp #2
 bne :update

* Is there a live guard on new screen?

 ldx KidScrn
 lda GdStartBlock-1,x
 cmp #30
 bcs :nonew ;no

 lda GdStartSeqH-1,x
 beq :update ;yes

* If guard is too far o.s., leave him behind

:nonew
 lda ]cutdir
 beq :left
 cmp #1
 beq :right
 cmp #2
 beq :up

:down lda ShadBlockY
 cmp #3
 bcs :transfer
 bcc :update

:up lda ShadBlockY
 bmi :transfer
 bpl :update

:right lda ShadX
 cmp #ScrnWidth+25 ;25 is safety factor
 bcc :update
 bcs :transfer

:left lda ShadX
 cmp #256-ScrnWidth-25
 bcs :update

* Take him with us

:transfer jmp transferguard

* Leave him behind

:update jmp updateguard

*-------------------------------
*
* Transfer guard from old screen to new screen
* (Also remove any dead guards from new scrn)
*
*-------------------------------
transferguard
 lda #-1
 ldx KidScrn ;new scrn
 sta GdStartBlock-1,x
 ldx ShadScrn ;old scrn
 sta GdStartBlock-1,x

 jsr LoadShad

 lda ]cutdir
 jsr cut

 jmp SaveShad

]rts rts

*-------------------------------
*
* Leaving guard behind on old screen--
* update guard coords
*
*-------------------------------

updateguard
 lda ShadFace
 cmp #86
 beq ]rts ;no guard
 lda ShadID
 cmp #1
 beq ]rts ;not for shadman
 cmp #24
 beq ]rts ;or mouse
:gd
 lda #0 ;arbitrary--ADDGUARD will reconstruct
 sta tempblockx ;CharBlockX from CharX
 lda ShadBlockY
 sta tempblocky
 jsr indexblock
 tya
 ldx ShadScrn
 sta GdStartBlock-1,x

 lda ShadX
 sta GdStartX-1,x

 lda ShadFace
 sta GdStartFace-1,x

 lda guardprog
 sta GdStartProg-1,x

 lda ShadLife
 bpl :ok
 lda #0
 sta GdStartSeqH-1,x
 beq :cont

:ok lda ShadSeq
 sta GdStartSeqL-1,x
 lda ShadSeq+1
 sta GdStartSeqH-1,x

* and deactivate enemy char

:cont lda #86
 sta ShadFace

 lda #0
 sta OppStrength
]rts rts

*-------------------------------
*
* If enemy has fallen to screen below, catch him before
* he wraps around to top of VisScrn
*
*-------------------------------
CUTGUARD
 lda ShadFace
 cmp #86
 beq ]rts

 lda ShadY
 cmp #BotCutEdge
 bcc ]rts

* If guard, remove him altogether

 lda ShadID
 cmp #4
 beq :skel
 cmp #1
 beq :shad

]RemoveGd
 jsr deadenemy ;music, etc.

 ldx VisScrn
 lda #-1
 sta GdStartBlock-1,x
 lda #86
 sta ShadFace
 lda #0
 sta OppStrength
 lda #-1
 sta ChgOppStr
]rts rts

* If shad, vanish him

:shad lda ShadAction
 cmp #4
 bne ]rts
 jsr LoadShad
 jsr VanishChar
 jmp SaveShad

* If skel, change scrn

:skel lda ShadScrn
 jsr getdown
 sta ShadScrn
 cmp #3
 bne ]RemoveGd

* Skel lands on scrn 3

 lda #Splat
 jsr addsound
 lda #$85
 sta ShadX
 lda #1
 sta ShadBlockY
 lda #0
 sta ShadFace
 lda #-1
 sta ShadLife
 jmp updateguard

*-------------------------------
*
*  C U T   C H A R
*
*  Is character passing o.s.?  If so, cut with him to next scrn
*
*  Change CharX,Y,BlockY,Scrn to reflect posn on new scrn
*
*  Return A = direction of cut, -1 if no cut
*
*-------------------------------
cutchar
 lda CharY

 ldx CharAction
 cpx #5
 beq :notup
 cpx #4
 beq :notup ;In freefall--cut only down
 cpx #3
 beq :notup

*  Cut up/down?

 cmp #TopCutEdgePl
 bcc :CUTUP

 cmp #TopCutEdgeMi
 bcs :CUTUP
:notup
 cmp #BotCutEdge
 bcs :CUTDOWN

*  Cut left/right?

 ldx CharPosn
 cpx #135
 bcc :nocu
 cpx #150
 bcc :nocut ;don't cut L/R on climbup
:nocu cpx #110
 bcc :nosu
 cpx #120
 bcc :nocut ;or on standup
:nosu cpx #150
 bcc :nost
 cpx #163
 bcc :nocut
 cpx #166
 bcc :nost
 cpx #169
 bcc :nocut ;or on strike/block
:nost lda CharAction
 cmp #7
 beq :nocut ;or on turning

 ldx CharFace ;-1=left, 0=right
 beq :faceR
;facing left
 lda leftej
 cmp #LeftCutEdge
 bcc :CUTLEFT
 beq :CUTLEFT

 cmp #ScrnRight+1
 bcs :CUTRIGHT
 bcc :nocut

:faceR
 lda CharScrn
 ldx #9
 ldy CharBlockY
 jsr rdblock

 cmp #panelwif
 beq :nocutr
 cmp #panelwof
 beq :nocutr ;don't cut R if a panel blocks view

 lda rightej
 cmp #RightCutEdge
 bcs :CUTRIGHT

:nocutr lda rightej
 cmp #ScrnLeft-1
 bcc :CUTLEFT
 beq :CUTLEFT

:nocut lda #-1
 rts

:CUTLEFT jsr mirrmusic
 jsr milestone3
 lda #0
 bpl :cut

:CUTRIGHT jsr stealsword
 jsr jaffmusic
 lda #1
 bpl :cut

:CUTUP lda #2
 bpl :cut

* Level 6 ("Plunge"): Kid falls off screen 1 into next level

:CUTDOWN
 jsr infinity

 lda level
 cmp #6
 bne :no6
 lda CharScrn
 cmp #1
 beq :nocut
:no6
 lda #3
:cut pha
 jsr cut
 pla
]rts rts

*-------------------------------
* Level 12--fall off into infinity
*-------------------------------
infinity rts

*-------------------------------
* Passed Level 3 milestone?
*-------------------------------
milestone3
 lda level
 cmp #3
 bne ]rts
 lda #7 ;scrn to R of gate
]mcheck cmp CharScrn
 bne ]rts
 lda #1
 sta milestone
 lda MaxKidStr
 sta origstrength
 rts

*-------------------------------
* Level 12: Shadow steals sword
*-------------------------------
stealsword
 lda level
 cmp #12
 bne ]rts
 lda CharScrn
 cmp #18 ;scrn below swordscrn
 bne ]rts
 lda #swordscrn
 ldx #swordx
 ldy #swordy
 jsr rdblock
 lda #floor
 sta (BlueType),y
 rts

*-------------------------------
* Level 13: Play Jaffar's Theme
*-------------------------------
jaffmusic
 lda level
 cmp #13
 bne ]rts
 lda exitopen
 bne ]rts
 lda CharScrn
 cmp #3
 bne ]rts
 lda #s_Jaffar
 ldx #25
 jmp cuesong

*-------------------------------
* Level 4 ("Mirror"): Play danger theme for mirror
*-------------------------------
mirrmusic
 lda exitopen
 beq :no4
 cmp #77
 beq :no4
 lda level
 cmp #4
 bne :no4
 lda CharBlockY
 cmp #miry
 bne :no4
 lda CharScrn
 cmp #11 ;scrn to R of mirscrn
 bne :no4
 lda #s_Danger
 ldx #50
 jsr cuesong
 lda #77
 sta exitopen ;so we don't repeat theme
:no4
]rts rts

*-------------------------------
*
*  C U T
*
*  Move char from CharScrn to adjacent screen
*
*  In: A = cut dir: 0 = left, 1 = right, 2 = up, 3 = down
*
*-------------------------------
CUT
 cmp #3
 beq Cdown
 cmp #1
 beq Cright
 cmp #2
 beq Cup

Cleft
 lda CharScrn
 jsr getleft ;get new screen #
 sta CharScrn

 lda #140
 clc
 adc CharX
 sta CharX

 ldx #1 ;new FromDir
 rts

Cright
 lda CharScrn
 jsr getright
 sta CharScrn

 lda CharX
 sec
 sbc #140
 sta CharX

 ldx #0
 rts

Cup
 lda CharScrn
 jsr getup
 sta CharScrn

 lda CharBlockY
 clc
 adc #3
 sta CharBlockY

 lda CharY
 clc
 adc #189
 sta CharY

 ldx #3
 rts

Cdown
 lda CharScrn
 jsr getdown
 sta CharScrn

 lda CharBlockY
 sec
 sbc #3
 sta CharBlockY

 lda CharY
 sec
 sbc #189
 sta CharY

 ldx #2
]rts rts

*-------------------------------
*
* A D D  G U A R D
*
* On cut to new screen--if guard is there, bring him to life
* Also handles hard-wired shadowman appearances
*
* In: VisScrn
*
*-------------------------------
ADDGUARD
 lda #0
 sta offguard

* Level 12

 lda level
 cmp #12
 bne :not12
 lda exitopen ;set when shadow drops
 bne ]rts
 lda mergetimer
 bne :1 ;shadow has been reabsorbed
 lda VisScrn
 cmp #swordscrn
:1 bne ]rts
 sta CharScrn

 ldx #swordx
 ldy #swordy
 jsr rdblock
 cmp #sword
 beq ]rts ;sword is still there
 lda #0
 sta shadowaction
 lda #1
 sta exitopen
 lda #shadpos12
 ldx #>shadpos12
 jmp csps

* Level 6 (Plunge)

:not12
 lda level
 cmp #6 ;plunge
 bne :not6

 lda VisScrn
 sta CharScrn
 cmp #1
 bne AddNormalGd

 lda exitopen
 cmp #77
 beq :norepeat
 lda #s_Danger
 ldx #50
 jsr cuesong
 lda #77
 sta exitopen
:norepeat
 lda #shadpos6a
 ldx #>shadpos6a
 jmp csps

* Level 5 (Thief)

:not6 lda level
 cmp #5 ;thief
 bne :not5

 lda VisScrn
 sta CharScrn
 cmp #flaskscrn
 bne AddNormalGd

 ldx #flaskx
 ldy #flasky
 jsr rdblock
 cmp #flask
 bne ]rts ;potion is gone

 lda #shadpos5
 ldx #>shadpos5
 jmp csps
]rts rts
:not5

*-------------------------------
AddNormalGd
 ldx VisScrn
 lda GdStartBlock-1,x
 cmp #30
 bcs ]rts ;no guard on this scrn

* Bring guard to life (or death)

 stx CharScrn

 jsr unindex ;return A = blockx, X = blocky
 stx CharBlockY

 lda FloorY+1,x
 sta CharY

 ldx VisScrn
 lda GdStartX-1,x
 sta CharX
 jsr getblockxp
 sta CharBlockX

 ldx VisScrn
 lda GdStartFace-1,x
 sta CharFace

 lda level
 cmp #3
 bne :3

 lda #4 ;skel
 bne :4
:3 lda #2 ;guard
:4 sta CharID

 lda GdStartSeqH-1,x
 bne :1 ;0 is code for fresh start

 lda CharID
 cmp #4
 bne :5
 lda #2
 sta CharSword
 lda #landengarde ;skel (ready)
 bne :6
:5 lda #0
 sta CharSword
 lda #alertstand ;guard
:6 jsr jumpseq
 jmp :2

:1 sta CharSeq+1
 lda GdStartSeqL-1,x
 sta CharSeq

:2 jsr animchar

 lda CharPosn
 cmp #185 ;killed
 beq :dead
 cmp #177 ;impaled
 beq :dead
 cmp #178 ;halved
 beq :dead

* Live guard

 lda #-1
 sta CharLife

 lda #0
 sta alertguard
 sta refract
 sta justblocked

 jsr getgdstrength
 jmp :cont

* Dead guard

:dead lda #1
 sta CharLife
 lda #0
 sta OppStrength

* Continue

:cont lda #0
 sta CharXVel
 sta CharYVel
 lda #1
 sta CharAction

 ldx VisScrn
 lda GdStartProg-1,x
 cmp #numprogs
 bcc :ok
 lda #3 ;default
:ok sta guardprog

 ldx level
 lda basiccolor,x
 ldx guardprog
 eor specialcolor,x ;0 = normal, 1 = special
 sta GuardColor  ;0 = blue, 1 = red

 jmp SaveShad ;save ShadVars

*-------------------------------
* Get guard fighting strength
*-------------------------------
getgdstrength
 ldx level
 lda basicstrength,x
 ldx guardprog
 clc
 adc extrastrength,x
 sta MaxOppStr
 sta OppStrength
]rts rts

*-------------------------------
 lst
 ds 1
 usr $a9,17,$800,*-org
 lst off
