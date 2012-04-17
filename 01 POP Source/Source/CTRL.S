* ctrl
org = $3a00
 tr on
 lst off
*-------------------------------
 org org

 jmp PLAYERCTRL
 jmp CHECKFLOOR
 jmp SHADCTRL
 jmp REREADBLOCKS
 jmp CHECKPRESS

 jmp DOIMPALE
 jmp GENCTRL
 jmp CHECKIMPALE

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
jxtemp ds 1
jytemp ds 1
jbtemp ds 1
atemp ds 1
 dend

*-------------------------------
*  Misc. changeable parameters

DeathVelocity = 33
OofVelocity = 22

grabreach = -8
grabspeed = 32 ;max Y-vel to grab ledge
grablead = 25 ;increase to grab ledge earlier
stuntime = 12

jumpupreach = 0
jumpupangle = -6

JumpBackThres = 6
StepOffFwd = 3
StepOffBack = 8

swordthres = 90 ;to go en garde (facing fwd)
swordthresN = -10 ;" " (behind you)
blockthres = 32
graceperiod = 9
gdpatience = 15

gclimbthres = 6

stairthres = 30

plus1 db -1,1
minus1 db 1,-1

*-------------------------------
*
*  If he's passed thru floor plane, change CharBlockY
*  If floor is solid, stop him
*
*-------------------------------
falling
 lda CharY

 ldx CharBlockY
 inx
 cmp FloorY,x
 bcs :1

 jmp fallon ;Hasn't reached floor yet

* Character is passing thru floor plane

:1 jsr getunderft ;Check if there's
 ;solid floor underfoot
 cmp #block
 bne :2 ;Solid block is special case--
 jsr InsideBlock ;reset him to either side of block

:2 jsr cmpspace
 bne hitflr

 inc CharBlockY ;Fall thru floor plane

]rts rts
*-------------------------------
*
*  C H E C K  F L O O R
*
*-------------------------------

CHECKFLOOR
 lda CharAction
 cmp #6 ;hanging?
 beq ]rts

 cmp #5 ;bumped?
 bne :2
 lda CharPosn
 cmp #109 ;crouched (e.g. on loose floor)
 beq :ong
 cmp #185 ;dead
 bne ]rts
:ong jmp onground

:2 cmp #4 ;freefall
 beq falling
 cmp #3
 bne :1
 lda CharPosn
 cmp #102
 bcc ]rts
 cmp #106
 bcs ]rts
 jmp fallon

:1 cmp #2 ;hanging
 beq ]rts
 jmp onground ;7, 0, or 1: on the ground

*-------------------------------
*
*  Floor stops him -- Choose appropriate landing
*
*-------------------------------
hitflr
 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY ;align char w/floor

 jsr getunderft
 cmp #spikes
 beq :hitspikes

* Has he landed too close to edge?

 jsr getinfront
 jsr cmpspace
 bne :cont ;no

 jsr getdist ;# pixels to edge
 cmp #4 ;was 2
 bcs :cont
;Yes--move him back a little
 lda #-3
 jsr addcharx
 sta CharX

:cont jsr addslicers ;trigger slicers on this level

 lda CharLife
 bpl :hardland ;dead before he hits the ground

 jsr getdist
 cmp #12
 bcc :nc
 jsr getbehind
 cmp #spikes
 beq :hitspikes ;check block behind if dist>=12

:nc jsr getunderft ;what has he landed on?
 cmp #spikes
 bne :notspikes

:hitspikes
 jsr getspikes ;are spikes lethal?
 bne :impale ;yes

:notspikes
 lda CharYVel
 cmp #OofVelocity
 bcc :softland

 cmp #DeathVelocity
 bcc :medland

:hardland
 lda #100
 jsr decstr
:hdland1
 lda #Splat
 jsr addsound

 lda #hardland
 bne :doland

:medland
 lda CharID
 cmp #1
 beq :softland ;shad lands easy
 cmp #2
 bcs :hardland ;guards can't survive 2 stories

 lda #1
 jsr decstr
 beq :hdland1

 lda #Splat
 jsr addsound

 lda #medland
 bne :doland

:softland
 lda CharID
 cmp #2
 bcs :gd ;guard always lands en garde
 lda CharSword
 cmp #2
 bne :1
:gd lda #2
 sta CharSword
 lda #landengarde
 bne :doland

:1 lda #softland
 bne :doland

:impale jmp DoImpale

:doland jsr jumpseq
 jsr animchar

 lda #0
 sta CharYVel
]rts rts

*-------------------------------
*
*  Hasn't hit floor yet -- can he grab edge above?
*
*-------------------------------
fallon
 lda btn ;is button down?
 and CharLife ;& is he alive?
 bpl ]rts
 ;yes--can he grab edge?
 lda CharYVel
 cmp #grabspeed
 bcs ]rts ;no--falling too fast

 lda CharY
 clc
 adc #grablead
 ldx CharBlockY
 inx
 cmp FloorY,x
 bcc ]rts  ;not within grabbing range yet

*  Char is within vertical range, and button is down
*  Is there a ledge within reach?

 lda CharX
 sta savekidx
 lda #grabreach
 jsr addcharx
 sta CharX
 jsr rereadblocks

 jsr :test ;can you grab ledge?
 bne :ok ;yes--do it
 lda savekidx
 sta CharX
 jmp rereadblocks
:ok ;do it!

* Align char with block

 jsr getdist

 jsr addcharx
 sta CharX

 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY

 lda #0
 sta CharYVel

 lda #fallhang
 jsr jumpseq
 jsr animchar

 lda #stuntime
 sta stunned
]rts rts

:test jsr getabove
 sta blockid
 jsr getaboveinf
 jmp checkledge

*-------------------------------
*  Is there floor underfoot?  If not, start to fall

onground
 lda Fcheck
 and #fcheckmark
 beq ]rts ;0--no need to check

 jsr getunderft
 cmp #block
 bne :1
 jsr InsideBlock ;If "inside" block, bump him outside
:1
 jsr cmpspace
 bne ]rts

* Level 12: Phantom bridge

 lda level
 cmp #12
 bne :no
 lda mergetimer
 bpl :no
 lda CharBlockY
 bne :no
 lda CharScrn
 cmp #2
 beq :yes
 cmp #13
 bne :no
 lda tempblockx
 cmp #6
 bcc :no
;Create floorboards on the fly
:yes lda #floor
 sta (BlueType),y
 jsr indexblock
 lda #2
 jsr :sub
 iny
:sub jsr markwipe
 jmp markred
:no
*-------------------------------
*  No floor underfoot--commence falling

startfall
 lda #0
 sta rjumpflag
 sta CharSword ;so you can grab on

 inc CharBlockY ;# of floor just below your feet
 jsr addslicers

 lda CharPosn ;upcoming frame
;(the one we're about to replace
;with first frame of falling seq)
 sta rjumpflag

 cmp #9 ;run-12
 beq :stepfall
 cmp #13 ;run-16
 beq :stepfall2
 cmp #26 ;standjump-19
 beq :jumpfall
 cmp #44 ;runjump-11
 beq :rjumpfall
 cmp #81
 bcc :2
 cmp #86
 bcc :hdropfall
:2 cmp #150
 bcc :1
 cmp #180
 bcc :fightfall ;from fighting stance
:1

:stepfall lda #stepfall
 bne :doit

:stepfall2 lda #stepfall2
 bne :doit

:jumpfall lda #jumpfall
 bne :doit

:rjumpfall lda #rjumpfall
 bne :doit

:hdropfall
 lda #5
 jsr addcharx
 sta CharX
 jsr rereadblocks
 jmp :stepfall2
]rts rts

:fightfall lda CharID
 cmp #2
 bcc :player
 lda CharXVel
 bmi :fb ;did gd step off fwd or bkwd?
 lda #0
 sta droppedout
 lda #efightfallfwd
 bne :doit
:fb lda #efightfall
 bne :doit
:player lda #1
 sta droppedout ;for guard's benefit
 lda #fightfall
 bne :doit

*-------------------------------
:doit jsr jumpseq
 jsr animchar ;advance 1 frame into fall

 jsr rereadblocks
 jsr getunderft
 jsr cmpwall
 beq :bump
 jsr getinfront
 jsr cmpwall
 bne ]rts
 jmp CDpatch

:bump jmp InsideBlock ;If "inside" block, bump him outside

CDpatch
 lda rjumpflag
 cmp #44 ;running jump?
 bne :patchX

 jsr getdist
 cmp #6
 bcs :patchX ;dist >= 6...we're OK

 lda #patchfall
 jsr jumpseq
 jsr animchar
 jmp rereadblocks

:patchX lda #-1
:1 jsr addcharx
 sta CharX
 jmp rereadblocks

*-------------------------------
*
* Char is "inside" a block--bump him outside
* (hopefully the same side from which he entered)
*
* Change Char X & return rdblock results
*
*-------------------------------
InsideBlock
 jsr getdist ;to EOB
 cmp #8
 bcs :bumpback

:bumpfwd
 jsr getinfront
 cmp #block
 beq :bumpback

 jsr getdist ;to EOB
 clc
 adc #4
:reland
 jsr addcharx
 sta CharX
 jsr rereadblocks ;reposition char
 jmp getunderft

:bumpback
 jsr getbehind
 cmp #block
 bne :1
  ;we're screwed
;bump 2 back (what the hell)
 jsr getdist
 clc
 adc #14
 eor #$ff
 clc
 adc #8
 jmp :reland
:1
 jsr getdist
 eor #$ff
 clc
 adc #8
 jmp :reland

*-------------------------------
*
*  S H A D O W   C O N T R O L
*
*-------------------------------
SHADCTRL
 lda CharID
 cmp #24 ;mouse?
 bne :1
 jmp AutoCtrl

:1 lda CharLife
 bpl :dead
;Has char's life run out?
 lda OppStrength
 bne :cont
 lda #0
 sta CharLife
 jsr deadenemy

:dead lda CharID
 cmp #1 ;shadow man?
 bne :cont
 jmp VanishChar

:cont lda ManCtrl
 bne :manualctrl

 jsr AutoCtrl

 jmp GenCtrl

* Manual ctrl: enemy controlled by deselected device

:manualctrl
 jsr LoadDesel

 jsr getdesel

 jsr clrjstk

 jsr UserCtrl

 jmp SaveDesel

*-------------------------------
*
*  P L A Y E R   C O N T R O L
*
*-------------------------------
PLAYERCTRL
 lda CharLife
 bpl :cont1 ;dead
 lda KidStrength
 bne :cont1
 lda #0
 sta CharLife
:cont1
 lda stunned
 beq :cont
 dec stunned

:cont lda level
 bne :game
:demo jsr DemoCtrl
 jmp GenCtrl

* Character controlled by selected device

:game jsr LoadSelect ;load jstk-push flags for selected device

 jsr getselect ;get current input from selected device

 jsr clrjstk ;clear appropriate jstk-push flags

 lda #2
 jsr UserCtrl

 jmp SaveSelect ;save updated jstk-push flags

*-------------------------------
* Player ctrl in demo

DemoCtrl
 lda milestone
 bne :finish
 lda CharSword
 beq :preprog

 lda #10
 sta guardprog
 jsr AutoCtrl
 lda #11
 sta guardprog
 rts

:preprog jmp demo

:finish jsr clrall
 sta clrbtn
 lda #-1
 sta clrF
 sta JSTKX ;run o.s.
]rts rts

*-------------------------------
UserCtrl
 lda CharFace
 bpl :faceL

 jmp GenCtrl

* If char is facing right, reverse JSTK & clrF/clrB

:faceL jsr facejstk

 jsr GenCtrl

 jmp facejstk

*-------------------------------
clrall
 lda #0
 sta clrB
 sta clrF
 sta clrU
 sta clrD
 lda #1
]rts rts

*-------------------------------
*
*  G E N E R A L   C O N T R O L
*
*  In: Raw input
*        JSTKX (- fwd, + back, 0 center)
*        JSTKY (- up, + down, 0 center)
*        btn (- down, + up)
*      Smart input
*        clrF-B-U-D-btn (- = fresh press)
*
*  Set clr = 1 after using a press
*
*-------------------------------
GENCTRL
 lda CharLife
 bmi :alive

* Dead character (If he's standing, collapse)

:dead lda CharPosn
 cmp #15
 beq :drop
 cmp #166
 beq :drop
 cmp #158
 beq :drop
 cmp #171
 bne ]rts
:drop lda #dropdead
 jmp jumpseq

* Live character

:alive lda CharAction
 cmp #5 ;is char in mid-bump?
 beq :clr
 cmp #4 ;or falling?
 beq :clr
 bne :underctrl
:clr
]clr jmp clrall

:underctrl
 lda CharSword
 cmp #2 ;in fighting mode?
 beq FightCtrl ;yes

 lda CharID
 cmp #2 ;kid or shadowman?
 bcc :cont
 jmp GuardCtrl ;no

* First question: what is char doing now?

:cont ldx CharPosn ;previous frame #

 cpx #15
 beq :standing

 cpx #48
 beq :turning

 cpx #50
 bcc :0
 cpx #53
 bcc :standing ;turn7-8-9/crouch
:0
 cpx #4
 bcc :starting ;run4-5-6

 cpx #67
 bcc :4
 cpx #70
 bcc :stjumpup ;starting to jump up

:4 cpx #15
 bcs :2
 jmp :running ;run8-17

:2 cpx #87
 bcc :1
 cpx #100
 bcs :1
 jmp :hanging ;jumphang22-34

:1 cpx #109 ;crouching?
 beq :crouching
:3
]rts rts

:standing jmp standing
:starting jmp starting
:stjumpup jmp stjumpup
:running jmp arunning
:hanging jmp hanging
:turning jmp turning
:crouching jmp crouching

*-------------------------------
* Similar routine for guard

GuardCtrl
 ldx CharPosn
 cpx #166 ;standing?
 beq :alert
]rts rts

:alert
 lda clrD
 bpl ]rts
 lda clrF
 bmi :engarde
 bpl :turn

:engarde jmp DoEngarde

:turn lda #1
 sta clrD
 lda #alertturn
 jmp jumpseq

*-------------------------------
* Char is en garde (CharSword = 2)

FightCtrl
 lda CharAction
 cmp #2
 bcs ]rts ;Must be on level ground (Action = 1)

* If Enemy Alert is over, put away your sword

 jsr getunderft
 cmp #loose
 beq :skip ;unless you're standing on loose floor

 lda EnemyAlert
 cmp #2
 bcc :dropgd

* If opponent is behind you, turn to face him

:skip jsr getopdist ;fwd distance to opponent
 cmp #swordthres
 bcc :onalert
 cmp #128
 bcc :dropgd
 cmp #-4
 bcs :onalert ;overlapping
 jmp DoTurnEng

* Enemy out of range--drop your guard
* (kid & shadman only)

:dropgd lda CharID
 bne :1
 sta heroic
 beq :2
:1 cmp #2
 bcs :onalert ;guard: remain en garde
:2
 ldx CharPosn
 cpx #171 ;wait for ready posn
 bne ]rts

 lda #0
 sta CharSword

 lda #resheathe
 jmp jumpseq
]rts rts

*-------------------------------
* Remain en garde

:onalert
 ldx CharPosn ;prev frame #
 cpx #161 ;successful block?
 bne :nobloc
 lda clrbtn ;yes--restrike or retreat?
 bmi :bts
 lda #retreat
 jmp jumpseq

* Fresh button press to strike

:nobloc lda clrbtn
 bpl :10
:bts
 lda CharID
 bne :11
 lda #gdpatience
 sta gdtimer

:11 jsr DoStrike

 lda clrbtn
 cmp #1
 beq ]rts ;struck
:10 ;else didn't strike

* Down to lower your sword

 lda clrD
 bpl :nodrop

 ldx CharPosn
 cpx #158 ;ready
 beq :ready1
 cpx #170
 beq :ready1
 cpx #171
 bne ]rts
:ready1
 lda #1
 sta clrD

 lda #0
 sta CharSword

 lda CharID
 beq :drop ;for kid
 cmp #1
 beq :sstand ;for shadman

:alert lda #goalertstand
 jmp jumpseq ;for guard

:drop lda #1
 sta offguard
 lda #graceperiod
 sta refract
 lda #0
 sta heroic
 lda #fastsheathe
 jmp jumpseq

:sstand lda #resheathe
 jmp jumpseq

* Fwd to advance, up to block, back to retreat

:nodrop
 lda clrU
 bmi :up
 lda clrF
 bmi :fwd
 lda clrB
 bmi :back

]rts rts

:fwd jmp DoAdvance
:up jmp DoBlock
:back jmp DoRetreat

*-------------------------------
DoTurnEng
 lda #turnengarde
 jmp jumpseq

*-------------------------------
DoBlock
 ldx CharPosn
 cpx #158 ;ready
 beq :2
 cpx #170
 beq :2
 cpx #171
 beq :2
 cpx #168 ;guy-2
 beq :2

 cpx #165 ;adv
 beq :2
 cpx #167 ;blocked strike
 beq :3

]rts rts

* From ready position: Block if appropriate

:2 jsr getopdist
 cmp #blockthres
 bcs :blockmiss ;too far

 lda #readyblock
 ldx CharID
 beq :kid
 ldx OpPosn ;enemy sees kid 1 frame ahead
 cpx #152 ;guy4
 beq :doit
]rts rts

:kid ldx OpPosn
 cpx #168 ;1 frame too early?
 beq ]rts  ;yes--wait 1 frame

 cpx #151 ;guy3
 beq :doit
 cpx #152 ;guy4
 beq :doit
 cpx #162 ;guy22
 beq :doit

 cpx #153 ;1 frame too late?
 bne :blockmiss
  ;yes--skip 1 frame
 jsr :doit
 jmp animchar

* Strike-to-block

:3 lda #strikeblock
:doit ldx #1
 stx clrU
 jmp jumpseq
:blockmiss
 lda CharID
 bne DoRetreat ;enemy doesn't waste blocks
 lda #readyblock
 bne :doit

*-------------------------------
DoStrike
 cpx #157
 beq :1
 cpx #158
 beq :1
 cpx #170
 beq :1
 cpx #171
 beq :1 ;strike from ready posn
 cpx #165
 beq :1 ;from advance
 cpx #150
 beq :2 ;from missed block
 cpx #161
 beq :2 ;from successful block

]rts rts

:1 lda CharID
 bne :slo ;kid is fast, others slow

 lda #faststrike
 bne :dostr

:slo lda #strike
:dostr ldx #1
 stx clrbtn
 jmp jumpseq

:2 lda #blocktostrike
 bne :dostr

*-------------------------------
DoRetreat
 ldx CharPosn
 cpx #158
 beq :1 ;strike from ready posn
 cpx #170
 beq :1
 cpx #171
 beq :1
]rts rts

:1 lda #retreat
 ldx #1
 stx clrB
 jmp jumpseq

*-------------------------------
DoAdvance
 ldx CharPosn
 cpx #158
 beq :1
 cpx #170
 beq :1
 cpx #171
 beq :1
]rts rts

:1 lda CharID
 bne :slo ;kid is faster
 lda #fastadvance
 bne :doit
:slo lda #advance
:doit ldx #1
 stx clrF
 jmp jumpseq

*-------------------------------
*
*  S T A N D I N G
*
*-------------------------------
standing

* Fresh button click: pick up object?

 lda clrbtn
 bpl :noclick
 lda btn
 bpl :noclick
 jsr TryPickup
 bne ]rts ;yes
:noclick

* Shadman only: down & fwd to go en garde

 lda CharID
 beq :kid
 lda clrD
 bpl :1
 lda clrF
 bpl :1
 jmp DoEngarde

* If opponent is within range, go en garde
* (For kid only)

:kid lda gotsword
 beq :1 ;no sword

 lda offguard
 beq :notoffg
 lda btn ;off guard--push btn to draw sword
 bpl :btnup
:notoffg
 lda EnemyAlert
 cmp #2
 bcc :safe
 jsr getopdist ;fwd distance to opponent
 cmp #swordthresN
 bcs :danger
 cmp #swordthres
 bcs :safe

:danger ldx #1
 stx heroic
 cmp #-6
 bcs :behindyou

 lda OpID
 cmp #1
 bne :engarde
 lda OpAction
 cmp #3
 beq :safe
 lda OpPosn
 cmp #107
 bcc :engarde
 cmp #118
 bcc :safe ;let shadow land
:engarde jmp DoEngarde

:behindyou jmp DoTurn

:safe lda #0
 sta offguard

:1 lda btn
 bpl :btnup

*-------------------------------
* Standing, button down

:2 lda clrB
 bmi :backB

 lda clrU
 bmi :up

 lda clrD
 bmi :down

 lda JSTKX
 bpl :rts

 lda clrF
 bmi :fwdB
:rts
]rts rts

*-------------------------------
* Standing, button up

:btnup
 lda clrF
 bmi :fwd
 lda clrB
 bmi :back
 lda clrU
 bmi :up
 lda clrD
 bmi :down

 lda JSTKX
 bmi :fwd

]rts rts

:fwd jmp DoStartrun
:fwdB jmp DoStepfwd

:back jmp DoTurn
:backB jmp DoTurn

:fwdup jmp DoStandjump

*-------------------------------
* Standing, joystick up

:up

* In front of open stairs?

 jsr getunderft
 cmp #exit
 beq :stairs
 jsr getbehind
 cmp #exit
 beq :stairs
 jsr getinfront
 cmp #exit
 bne :nostairs

:stairs lda (BlueSpec),y
 lsr
 lsr
 cmp #stairthres
 bcc :nostairs

 jmp Stairs

* No -- normal control

:nostairs
 lda JSTKX
 bmi :fwdup

* Straight up...jump up & grab ledge if you can

 jmp DoJumpup

*-------------------------------
* Standing, joystick down

:down
 lda #1
 sta clrD

* If you're standing w/back to edge, down
* means "climb down & hang from ledge"

* If facing edge, "down" means "step off"

 jsr getinfront
 jsr cmpspace
 bne :notfwd ;no cliff in front of you

 jsr getdist
 cmp #StepOffFwd
 bcs :notfwd ;not close enough to edge
 lda #5
 jsr addcharx
 sta CharX
 jmp rereadblocks ;move fwd

:notfwd jsr getbehind
 jsr cmpspace
 bne :no ;no cliff behind you

 jsr getdist
 cmp #StepOffBack
 bcc :no ;not close enough to edge

* Climb down & hang from ledge

 jsr getbehind
 sta blockid
 jsr getunderft
 jsr checkledge
 beq :no

 ldx CharFace
 bpl :succeed
 jsr getunderft
 cmp #gate
 bne :succeed

 lda (BlueSpec),y
 lsr
 lsr
 cmp #gclimbthres
 bcc :no

:succeed jsr getdist
 sec
 sbc #9

 jsr addcharx
 sta CharX

 lda #climbdown
 jmp jumpseq

* Otherwise "down" means "crouch"

:no jmp DoCrouch

*-------------------------------
* Climb stairs

Stairs
 lda tempblockx ;stairs block
 jsr getblockej
 clc
 adc #10
 sta CharX
 lda #-1
 sta CharFace

 lda #climbstairs
 jmp jumpseq

]rts rts

*-------------------------------
*
*  C R O U C H I N G
*
*-------------------------------
crouching

* Fresh button click?

 lda clrbtn
 bpl :noclick

 jsr TryPickup
 bne ]rts

* Still crouching?

:noclick
 lda JSTKY
 cmp #1
 beq :1
 lda #standup
 jmp jumpseq

:1 lda clrF
 bpl ]rts
 lda #1
 sta clrF
 lda #crawl
 jmp jumpseq

*-------------------------------
*
*  S T A R T I N G
*
*  First few frames of "startrun"
*
*-------------------------------
starting
 lda JSTKY
 bmi :jump
]rts rts

:jump
 lda JSTKX
 bpl ]rts

 jmp DoStandjump

*-------------------------------
* First few frames of "jumpup"

stjumpup
 lda JSTKX
 bmi :fwd
 lda clrF
 bmi :fwd
]rts rts
:fwd jmp DoStandjump

*-------------------------------
*
* T U R N I N G
*
*-------------------------------
turning
 lda btn
 bmi ]rts

 lda JSTKX
 bpl ]rts

 lda JSTKY
 bmi ]rts

* Jstk still fwd--convert turn to turnrun

 lda #turnrun
 jmp jumpseq

*-------------------------------
*
*  R U N N I N G
*
*-------------------------------
arunning
 lda JSTKX
 beq :runstop ;jstk centered...stop running
 bpl :runturn ;jstk back...turn around

* Jstk is forward... keep running
* & wait for signal to runjump or diveroll

 lda JSTKY
 bmi :runjump ;jstk up... take a running jump

 lda clrD
 bmi :diveroll ;jstk down... running dive & roll

]rts rts

*  Running dive & roll

:diveroll lda #1
 sta clrD

 lda #rdiveroll
 jmp jumpseq

*  Running jump

:runjump
 lda clrU
 bpl ]rts

 jmp DoRunjump

*  Stop running

:runstop lda CharPosn
 cmp #7 ;run-10
 beq :rs
 cmp #11 ;run-14
 bne ]rts

:rs jsr ]clr
 sta clrF

 lda #runstop
 jmp jumpseq

*  Turn around & run the other way

:runturn
 jsr ]clr
 sta clrB

 lda #runturn
 jmp jumpseq

*-------------------------------
*
*  H A N G I N G
*
*-------------------------------
hanging
 lda stunned
 bne :9 ;can't climb up

 lda JSTKY
 bmi :climbup ;jstk up-->climb up
:9
 lda btn
 bpl :drop

* If hanging on right-hand side of a panel
* or either side of block,
* switch to "hangstraight"

 lda CharAction
 cmp #6
 beq :cont ;already hanging straight

 jsr getunderft
 cmp #block
 beq :hangstrt

 ldx CharFace
 cpx #-1 ;left
 bne :cont

 cmp #panelwif
 beq :hangstrt
 cmp #panelwof
 beq :hangstrt

* If ledge crumbles away, fall with it

:cont
 jsr getabove

 jsr cmpspace ;still there?
 beq :drop ;no

* just keep swinging

:rts
]rts rts

:hangstrt lda #hangstraight
 jmp jumpseq

*-------------------------------
* climb up (if you can)

:climbup
 jsr ]clr
 sta clrU
 sta clrbtn

 jsr getabove

 cmp #mirror
 beq :10
 cmp #slicer
 bne :1

:10 ldx CharFace
 beq :fail
 bne :succeed ;can only mount mirror facing L

:1 cmp #gate
 bne :2

 ldx CharFace
 beq :succeed
;can only mount closed gate facing R
 lda (BlueSpec),y
 lsr
 lsr
 cmp #gclimbthres
 bcc :fail
 bcs :succeed

:2
:succeed lda #climbup
 jmp jumpseq

:fail lda #climbfail
 jmp jumpseq


*-------------------------------
:drop
 jsr ]clr
 sta clrD ;clrD = 1, all others = 0

 jsr getbehind
 jsr cmpspace
 bne :hangdrop

 jsr getunderft
 jsr cmpspace
 beq :hangfall

:hangdrop
 jsr getunderft
 cmp #block
 beq :sheer

 ldx CharFace
 bpl :clear
 cmp #panelwof
 beq :sheer
 cmp #panelwif
 bne :clear

:sheer lda #-7
 jsr addcharx
 sta CharX

:clear lda #hangdrop
 jmp jumpseq

:hangfall
 lda #hangfall
 jmp jumpseq
]rts rts

*-------------------------------
*
*  D o  S t a r t r u n
*
*-------------------------------
DoStartrun

* If very close to a barrier, do a Stepfwd instead
* (Exceptions: slicer & open gate)

 jsr getfwddist
 cpx #1 ;barrier?
 bne :startrun ;no

 cpy #slicer
 beq :startrun

:solidbarr
 jsr getfwddist
 cmp #8
 bcs :startrun

 lda clrF
 bpl ]rts

 jmp DoStepfwd

:startrun
 lda #startrun
 jmp jumpseq ;...start running

DoTurn jsr ]clr
 sta clrB
;if enemy is behind you, draw as you turn
 lda gotsword
 beq :1
 lda EnemyAlert
 cmp #2
 bcc :1
 jsr getopdist
 bpl :1
 jsr getdist ;to EOB
 cmp #2
 bcc :1

 lda #2
 sta CharSword ;en garde
 lda #0
 sta offguard
 lda #turndraw
 bne :2
:1 lda #turn
:2 jmp jumpseq ;...turn around

DoStandjump lda #1
 sta clrU
 sta clrF

 lda #standjump
 jmp jumpseq ;...standing jump

DoSdiveroll lda #1
 sta clrD

 lda #sdiveroll
 jmp jumpseq ;...standing dive & roll

DoCrouch
 lda #stoop
 jsr jumpseq

 jsr ]clr
 sta clrD
 rts

DoEngarde
 jsr ]clr
 sta clrF
 sta clrbtn

 lda #2
 sta CharSword ;en garde

 lda CharID
 beq :1
 cmp #1
 beq :3 ;shad
 lda #guardengarde
 bne :2
:1 lda #0
 sta offguard
:3 lda #engarde
:2 jmp jumpseq

*-------------------------------
*
*  D o  J u m p u p
*
*  & grab ledge if you can
*
*-------------------------------
DoJumpup
 jsr ]clr
 sta clrU

 jsr getabove
 sta blockid

 jsr getaboveinf

 jsr checkledge ;Can you jump up & grab ledge?
 ;Returns 1 if you can, 0 if you can't
 bne  DoJumphang ;yes--do it

 jsr getabovebeh
 sta blockid

 jsr getabove

 jsr checkledge ;could you do it if you were 1 space back?
 bne :jumpback ;yes--move back & do it

:jumphi jmp DoJumphigh

*-------------------------------
* Jump up & back to grab block directly overhead

:jumpback
 jsr getdist ;dist to front of block
 cmp #JumpBackThres
 bcc :jumphi ;too far to fudge

 jsr getbehind
 jsr cmpspace ;floor behind you?
 beq DoJumpedge ;no

* "Jump back" to block behind you & then proceed as usual

 jsr getdist
 sec
 sbc #14
 jsr addcharx
 sta CharX

 jsr rereadblocks

 jmp DoJumphang

*-------------------------------
* Your back is to ledge -- so do a "jumpbackhang"

DoJumpedge
 jsr getabove

* Get all the way back on this block

 jsr getdist
 sec
 sbc #10

 jsr addcharx
 sta CharX

* now jump

 lda #jumpbackhang
 jmp jumpseq

*-------------------------------
DoJumphang
 jsr getaboveinf

*  Choose the jumphang sequence (Long/Med) that
*  will bring us closest to edge, then fudge the X-coord
*  to make it come out exactly

 jsr getdist ;get distance to front of block
 sta atemp ;# pixels (0-13) returned in A

 cmp #4
 bcc :Med

:Long lda atemp
 sec ;"Long" will add 4 to CharX
 sbc #4
 jsr addcharx
 sta CharX

 lda #jumphangLong
 jmp jumpseq
:Med
 jsr getfwddist
 cmp #4
 bcs :okMed

 cpx #1 ;close to wall?
 beq :Long ;yes--step back & do Long

:okMed lda atemp
 jsr addcharx
 sta CharX

 lda #jumphangMed
 jmp jumpseq

]rts rts

*-------------------------------
*
*  D o  R u n  J u m p
*
*  Calibrate jump so that foot will push off at edge.
*
*-------------------------------
RJChange = 4 ;projected change in CharX
RJLookahead = 1 ;# blocks you can look ahead
RJLeadDist = 14 ;required leading distance in pixels
RJMaxFujBak = 8 ;# pixels we're willing to fudge back
RJMaxFujFwd = 2 ;and forward

DoRunjump
 lda CharPosn
 cmp #7
 bcc ]rts ;must be in full run

* Count # of blocks to edge
* (Use actual CharX)

 lda #0
 sta bufindex ;block counter

 lda #RJChange
 jsr addcharx
 sta ztemp ;projected CharX

 jsr getblockxp
 sta blockx

:loop lda blockx
 ldx CharFace
 inx
 clc
 adc plus1,x
 sta blockx

 tax
 ldy CharBlockY
 lda CharScrn
 jsr rdblock

 cmp #spikes
 beq :done

 jsr cmpspace
 beq :done

 inc bufindex

 lda bufindex
 cmp #RJLookahead+1
 bcc :loop
 bcs :noedge ;no edge in sight--jump anyway
:done

* Calculate # of pixels to end of floor

 lda ztemp
 jsr getdist1 ;# pixels to end of block

 ldx bufindex ;# of blocks to end of floor
 clc
 adc Mult7,x
 clc
 adc Mult7,x ;# of pixels to end of floor

 sec
 sbc #RJLeadDist
;A = difference between actual dist to edge
;and distance covered by RunJump
 cmp #-RJMaxFujBak
 bcs :ok ;move back a little & jump

 cmp #RJMaxFujFwd
 bcc  :ok ;move fwd a little & jump

 cmp #$80
 bcc ]rts ;still too far away--wait till next frame

 lda #-3 ;He jumped too late; he'll miss edge
;But let's make it look good anyway
:ok clc
 adc #RJChange

 jsr addcharx
 sta CharX

* No edge in sight -- just do any old long jump

:noedge
 jsr ]clr
 sta clrU

 lda #runjump
 jmp jumpseq

]rts rts

*-------------------------------
*
*  D o  S t e p  F o r w a r d
*
*-------------------------------

DoStepfwd
 lda #1
 sta clrF
 sta clrbtn

 jsr getfwddist ;returns A = distance to step (0-13)

 cmp #0
 beq :1

:2 sta CharRepeat ;non-0 value

 clc
 adc #stepfwd1-1
 jmp jumpseq

:1 cpx #1
 beq :thru ;If barrier, step thru

 cmp CharRepeat
 bne :3 ;First time, test w/foot

:thru lda #11
 bne :2 ;Second time, step off edge

:3 sta CharRepeat ;0

 lda #testfoot
 jmp jumpseq

*-------------------------------
*
*  D o  J u m p  H i g h
*
*-------------------------------
DoJumphigh
 jsr ]clr
 sta clrU

 jsr getfwddist
 cmp #4
 bcs :ok
 cpx #1 ;barrier?
 bne :ok ;no

 sec
 sbc #3
 jsr addcharx
 sta CharX
:ok
 lda #jumpupreach
 jsr facedx
 sta ztemp

 jsr getbasex ;assume char standing still
 clc
 adc #jumpupangle
 clc
 adc ztemp ;get X-coord at which hand touches ceiling

 jsr getblockx
 tax

 ldy CharBlockY
 dey

 lda CharScrn
 jsr rdblock ;read this block

 cmp #block
 beq :jumpup
 jsr cmpspace
 bne :jumpup

 lda #highjump
 jmp jumpseq ;no ceiling above

:jumpup lda #jumpup
 jsr jumpseq ;touch ceiling
]rts rts ;& don't forget to crop top

*-------------------------------
*  reread blocks
*-------------------------------
REREADBLOCKS
 jsr GetFrameInfo
 jmp GetBaseBlock

*-------------------------------
*
*  Is character stepping on a pressure plate?
*  or on loose floor?
*
*-------------------------------
CHECKPRESS
 lda CharPosn
 cmp #87
 bcc :1
 cmp #100
 bcc :hanging ;87-99: jumphang22-34
 cmp #135
 bcc :1
 cmp #141
 bcc :hanging ;135-140: climb up/down
:1
 lda CharAction
 cmp #7
 beq :ground ;turning
 cmp #5
 beq :ground ;bumped
 cmp #2
 bcs ]rts

* Action code 7, 0 or 1: on the ground

:ground
 lda CharPosn
 cmp #79 ;jumpup/touch ceiling
 beq :touchceil

 lda Fcheck
 and #fcheckmark
 beq ]rts ;foot isn't touching floor

*  Standing on a pressplate?

 jsr getunderft
:checkit
 cmp #upressplate
 beq :PP
 cmp #pressplate
 bne :notPP

:PP lda CharLife
 bmi :push
 jmp jampp ;dead weight
:push jmp pushpp

:notPP cmp #loose
 bne ]rts

 lda #1
 sta alertguard
 jmp breakloose

*  Hanging on a pressplate?

:hanging
 jsr getabove
 jmp :checkit
]rts rts

* Jumping up to touch ceiling?

:touchceil
 jsr getabove

 cmp #loose
 bne ]rts

 jmp breakloose

*-------------------------------
*
*  C H E C K   I M P A L E
*
*  Impalement by running or jumping onto spikes
*  (Impalement by landing on spikes is covered by
*  CHECKFLOOR:falling)
*
*-------------------------------
CHECKIMPALE
 ldx CharBlockX
 ldy CharBlockY
 lda CharScrn
 jsr rdblock
 cmp #spikes
 bne ]rts ;not spikes

 ldx CharPosn

 cpx #7
 bcc ]rts

 cpx #15
 bcs :2
 jmp :running

:2 cpx #43 ;runjump-10
 beq :jumpland

 cpx #26 ;standjump-19
 beq :jumpland

]rts rts

:running
 jsr getspikes
 cmp #2
 bcc ]rts ;must be springing
 bcs :impale

:jumpland
 jsr getspikes ;are spikes lethal?
 beq ]rts ;no

:impale jmp DoImpale

*-------------------------------
* Impale char on spikes
*
* In: rdblock results
*-------------------------------
DOIMPALE
 jsr jamspikes

 ldx CharBlockY
 inx
 lda FloorY,x
 sta CharY ;align char w/floor

 lda tempblockx
 jsr getblockej ;edge of spikes
 clc
 adc #10
 sta CharX
 lda #8
 jsr addcharx
 sta CharX ;center char on spikes

 lda #0
 sta CharYVel

 lda #Impaled
 jsr addsound

 lda #100
 jsr decstr

 lda #impale
 jsr jumpseq
 jmp animchar

*-------------------------------
*
*  Pick up object
*  Return 0 if no result
*
*-------------------------------
TryPickup
 jsr getunderft
 cmp #flask
 beq :2
 cmp #sword
 bne :1
:2 jsr getbehind
 jsr cmpspace
 beq :no
 lda CharX
 lda #-14
 jsr addcharx
 sta CharX ;move char 1 block back
 jsr rereadblocks
:1 jsr getinfront
 cmp #flask
 beq :pickup
 cmp #sword
 beq :pickup
:no lda #0
 rts

:pickup jsr PickItUp
 lda #1
 rts

*-------------------------------
*
* Pick something up
*
* In: rdblock results for object block ("infront")
*
*-------------------------------
PickItUp
 ldx CharPosn
 cpx #109 ;crouch first, then pick up obj
 beq :ok
 jsr getfwddist
 cpx #2
 beq :0 ;right at edge
 jsr addcharx
 sta CharX
:0 lda CharFace
 bmi :1
 lda #-2
 jsr addcharx
 sta CharX ;put char within reach of obj
:1 jmp DoCrouch

:ok cmp #sword
 beq :PickupSword

 lda (BlueSpec),y
 lsr
 lsr
 lsr
 lsr
 lsr ;potion # (0-7)
 jsr RemoveObj

 lda #drinkpotion ;pick up & drink potion
 jmp jumpseq

:PickupSword
 lda #-1 ;sword
 jsr RemoveObj

 lda #pickupsword
 jmp jumpseq ;pick up, brandish & sheathe sword

*-------------------------------
 lst
 ds 1
 usr $a9,16,$00,*-org
 lst off
