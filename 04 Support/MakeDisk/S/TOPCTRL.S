* topctrl
org = $2000
EditorDisk = 0
FinalDisk = 1
DemoDisk = 0
ThreeFive = 1 ;3.5" disk?
 tr on
 lst off
*-------------------------------
*
*  PRINCE OF PERSIA
*  Copyright 1989 Jordan Mechner
*
*-------------------------------
 org org

 jmp START
 jmp RESTART
 jmp STARTRESUME
 jmp INITSYSTEM
 jmp showpage

 jmp showpage
 jmp GOATTRACT

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

*-------------------------------
* 18-sector ID bytes

POPside1 = $a9
POPside2 = $ad

FirstSideB = 3 ;1st level on Side B
LastSideB = 14 ;& last

*-------------------------------
* Soft switches

ALTZPon = $c009
ALTZPoff = $c008
RAMWRTaux = $c005
RAMWRTmain = $c004
RAMRDaux = $c003
RAMRDmain = $c002
TEXTon = $c051
PAGE2off = $c054

kresurrect = "R"

*-------------------------------
* Misc. changeable parameters

initmaxstr = 3

BTLtimer = 20 ;back to life
wtlflash = 15 ;weightless

mousetimer = 150

*-------------------------------
* message #s

LevelMsg = 1
ContMsg = 2
TimeMsg = 3

leveltimer = 20 ;level message timer
contflash = 95
contoff = 15
deadenough = 4

*-------------------------------
* Mirror location

mirlevel = 4
mirscrn = 4
mirx = 4
miry = 0

*-------------------------------
*
*  Start a new game
*
*  In: A = level # (0 for demo, 1 for game)
*
*-------------------------------
START
 sta ALTZPon
 jsr StartGame
 jmp RESTART

*-------------------------------
*
*  Resume saved game
*
*-------------------------------
STARTRESUME
 sta ALTZPon
 lda #4 ;arbitrary value >1
 jsr StartGame
 jmp ResumeGame

*-------------------------------
*
*  Initialize system (Called from MASTER upon bootup)
*
*-------------------------------
INITSYSTEM
 sta ALTZPon

 jsr setcenter ;Center joystick

 jsr setfastaux ;bgtable in auxmem

 lda #FinalDisk!1
 sta develment

 jsr initgame

 ldx #0
 txa
:loop sta $0,x
 inx
 bne :loop

 sta ALTZPoff
 rts

*-------------------------------
*
*  Start a game
*
*  In: A = level # (0 for demo, 1 for new game, >1 for
*      resumed game)
*
*-------------------------------
StartGame
 sta level
 sta NextLevel

 cmp #1
 bne :notfirst
 lda #s_Danger
 ldx #25
 jsr cuesong ;Cue "Danger" theme if level 1
:notfirst

 lda #initmaxstr
 sta origstrength ;set initial strength

 jmp initgame

*-------------------------------
*
*  Resume saved game
*
*-------------------------------
ResumeGame
 do DemoDisk
 rts
 else

 jsr flipdisk ;Ask player to flip disk
 lda #POPside2
 sta BBundID ;& expect side 2 from now on

:cont jsr loadgame ;Load saved-game info from disk

 lda SavLevel ;Has a game been saved?
 bpl :ok ;Yes

* No game saved--start new game instead

 jsr flipdisk
 lda #POPside1
 sta BBundID

 lda #1
 sta level
 sta NextLevel
 jmp RESTART

* Restore strength & timer

:ok lda SavStrength
 sta origstrength

 lda SavTimer+1
 sta FrameCount+1
 lda SavTimer
 sta FrameCount

 lda SavNextMsg
 sta NextTimeMsg

* & resume from beginning of level

 lda #1
 sta timerequest ;show time remaining
 lda #$80
 sta yellowflag ;pass copy prot. test
 lda SavLevel
 sta level
 sta NextLevel
 jmp RESTART

 fin

*-------------------------------
*
* Initialize vars before starting game
*
*-------------------------------
initgame
 lda #0
 sta blackflag
 sta redrawflg
 sta inmenu
 sta inbuilder
 sta recheck0
 sta SINGSTEP
 sta ManCtrl
 sta vibes
 sta invert
 sta milestone
 sta timerequest
 sta FrameCount
 sta FrameCount+1
 sta NextTimeMsg

 lda #$ff
 sta MinLeft
 sta SecLeft

 lda #1 ;no delay
 sta SPEED
 rts

*-------------------------------
*
*  Restart current level
*
*-------------------------------
RESTART
 sta ALTZPon
 sta $c010 ;clr kbd strobe

 ldx #$ff ;
 txs ;added 2/5/90!!!

 do EditorDisk
 jsr reloadblue
 else

 lda #" "
 jsr lrcls
 jsr vblank
 lda PAGE2off
 lda TEXTon

 ldx level
 jsr LoadLevelX ;load blueprint & image sets from disk
 fin

 jsr setinitials ;Set initial states as specified in blueprint

 jsr initialguards ;& guards

* Zero a lot of vars & tables

 lda #0
 sta SINGSTEP
 sta vibes
 sta AMtimer
 sta VisScrn
 sta exitopen
 sta lightning
 sta mergetimer
 sta numtrans
 sta nummob
 sta EnemyAlert
 sta createshad
 sta stunned
 sta heroic
 sta ChgKidStr
 sta OppStrength ;no opponent
 sta msgtimer
 sta PreRecPtr
 sta PlayCount

 ldx SongCue
 cpx #s_Danger
 beq :1st
 sta SongCue
:1st

 jsr zerosound

 jsr zeropeels

 jsr initCDbuf ;initialize collision detection buffers

 jsr initinput

 lda #1
 sta gotsword

 lda #-1
 sta cutorder

 lda #2
 sta ShadID ;default opponent is guard
 lda #86
 sta ShadFace

 jsr startkid

 do EditorDisk
 else

 lda level
 cmp #1
 bne :gotswd
 lda #0
 sta gotsword ;Start Level 1 w/o sword
:gotswd
 fin

 lda level
 beq :nomsg
 cmp #14
 beq :nomsg ;don't announce level 0 or 14
 cmp #13
 bne :1
 lda skipmessage
 beq :1
 lda #0
 sta skipmessage
 beq :nomsg ;skip level 13 message 1st time
:1 lda #LevelMsg
 sta message
 lda #leveltimer
 sta msgtimer
:nomsg

 jsr entrance ;entrance slams shut

 jsr FirstFrame ;Generate & display first frame

 jmp MainLoop

*-------------------------------
*
*  Main loop
*
*-------------------------------
MainLoop
 jsr rnd

 lda #0
 sta ChgKidStr
 sta ChgOppStr

 jsr strobe ;Strobe kbd & jstk

 jsr demokeys
 bpl :4
 lda #1
 jmp START ;During demo, press any key to play
:4
 jsr misctimers

 jsr NextFrame ;Determine what next frame should look like

 jsr flashon

 jsr FrameAdv ;Draw next frame & show it

 jsr playback ;Play sounds
 jsr zerosound ;& zero sound table

 jsr flashoff

 jsr songcues ;Play music

 lda NextLevel
 cmp level
 beq MainLoop ;Continue until we change levels

 jsr yellowcheck ;copy protect!

 jmp LoadNextLevel

*-------------------------------
*
* Load next level
*
* In: NextLevel = # of next level
*     level = # of current level
*
* Out: level = NextLevel
*
*-------------------------------
LoadNextLevel
 lda NextLevel
 cmp #14
 beq LoadNext1
 lda #1
 sta timerequest ;show time remaining

LoadNext1
 lda MaxKidStr
 sta origstrength ;save new strength level
 lda #0
 sta milestone

 do EditorDisk
 lda level
 sta NextLevel
 jmp RESTART
 fin

* NextLevel must be in range 1 - LastSideB

 lda NextLevel
 cmp #LastSideB+1
 bcs :illegal
 cmp #1
 bcs :2
:illegal lda level ;Illegal value--restart current level
 sta NextLevel
 jmp RESTART

* Load from correct side of disk

:2 ldx #POPside2
 cmp #FirstSideB
 bcs :1
 ldx #POPside1
:1 cpx BBundID ;do we need to flip disk?
 beq :ok ;no
 stx BBundID ;yes
 jsr flipdisk

:ok lda NextLevel
 sta level ;set new level
 cmp #2
 beq :cut1
 cmp #4
 beq :cut2
 cmp #6
 beq :cut3
 cmp #8
 beq :cut8
 cmp #9
 beq :cut4
 cmp #12
 beq :cut5 ;Princess cuts before certain levels

:cont jmp RESTART ;Start new level

* Princess cuts before certain levels

:cut1 lda #1
]pcut pha
:repeat jsr cutprincess ;cut to princess's room...
 jsr setrecheck0
 jsr recheckyel ;if wrong-disk error, recheck track 0
 bne :repeat ;& repeat
 pla
 jsr playcut ;& play cut #1
 jmp :cont

:cut2 lda #2
 bne ]pcut
:cut3 lda #3
 bne ]pcut
:cut4 lda #4
 bne ]pcut
:cut5 lda #5
 bne ]pcut
:cut8 lda #8
 bne ]pcut

*-------------------------------
*
*  N E X T   F R A M E
*
*  Determine what next frame should look like
*
*  In: All data reflects last (currently displayed) frame.
*
*-------------------------------
NextFrame
 jsr animmobs ;Update mobile objects (MOBs)

 jsr animtrans ;Update transitional objects (TROBs)

 jsr bonesrise ;Bring skeleton to life?

 jsr checkalert ;Determine EnemyAlert value

 jsr DoKid ;Update kid

 jsr DoShad ;Update shadowman (or other opponent)

 jsr checkstrike
 jsr checkstab ;Check for sword strikes
:1
 jsr addsfx ;Add additional sound fx

 jsr chgmeters ;Change strength meters

 jsr cutcheck ;Has kid moved offscreen?
  jsr PrepCut ;If so, prepare to cut to new screen

 jsr cutguard ;If guard has fallen offscreen, vanish him

 do EditorDisk
 rts
 fin

* Level 0 (Demo): When kid exits screen 24, end demo

 lda level
 bne :no0
 lda KidScrn
 cmp #24
 bne :cont
 jmp GOATTRACT

* Level 6: When kid falls off screen 1, cut to next level

:no0 do DemoDisk
 else

 lda level
 cmp #6
 bne :no6
 lda KidScrn
 cmp #1
 bne :cont
 lda KidY
 cmp #20
 bcs :cont
 lda #-1
 sta KidY
 inc NextLevel
 jmp :cont

* Level 12: When kid exits screen 23, cut to next level

:no6 cmp #12
 bne :cont
 lda KidScrn
 cmp #23
 bne :cont
 inc NextLevel
 lda #1
 sta skipmessage ;but don't announce level #
 jmp LoadNext1 ;or show time

 fin

* Continue...

:cont lda level
 cmp #14
 bcs :stopped
 cmp #13
 bcc :ticking
 lda exitopen
 bne :stopped ;Timer stops when you kill Vizier on level 13

:ticking jsr keeptime

:stopped jsr showtime ;if timerequest <> 0

 lda level
 cmp #13
 bcs :safe ;You have one chance to finish Level 13
;after time runs out
 lda MinLeft
 ora SecLeft
 bne :safe
 jmp YouLose ;time's up--you lose
:safe
]rts rts

*-------------------------------
*
*  F R A M E   A D V A N C E
*
*  Draw new frame (on hidden hi-res page) & show it
*
*-------------------------------
FrameAdv
 lda cutplan ;set by PrepCut
 bne :cut

 jsr DoFast
 jmp PageFlip ;Update current screen...

:cut jmp DoCleanCut ;or draw new screen from scratch

*-------------------------------
*
*  F I R S T   F R A M E
*
*  Generate & display first frame
*
*-------------------------------
FirstFrame
 lda KidScrn
 sta cutscrn

 jsr PrepCut

 jmp DoCleanCut

*-------------------------------
*
*  D O   K I D
*
*  Update kid
*
*-------------------------------
DoKid
 jsr LoadKidwOp ;Load kid as character (w/opponent)

 jsr rereadblocks

 jsr unholy ;If shadowman dies, kid dies

 jsr ctrlplayer ;Detect & act on commands from player

 lda invert
 beq :3
 lda CharLife
 bmi :3
 lda #2
 sta redrawflg
 lda #0
 sta invert
 jmp inverty ;Screen flips back rightside up when you're dead
:3
 jsr wtlessflash

 lda CharScrn
 beq :skip ;Skip all this if kid is on null screen:

 jsr animchar ;Get next frame from sequence table

 jsr gravity ;Adjust Y-velocity
 jsr addfall ;Add falling velocity

 jsr setupchar
 jsr rereadblocks
 jsr getedges

 jsr firstguard ;Check for collision w/guard

 jsr checkbarr ;Check for collisions w/vertical barriers

 jsr collisions ;React to collisions detected above

 jsr checkgate ;Knocked to side by closing gate?

 jsr  checkfloor ;Is there floor underfoot?  If not, fall

 jsr  checkpress ;Is kid stepping on a pressure plate?
;If so, add pressplate (& whatever it
;triggers) to trans list.

 jsr checkspikes  ;Trigger spikes?

 jsr checkimpale ;impaled by spikes?
 jsr checkslice ;sliced by slicer?
:1
 jsr shakeloose ;shake loose floors

:skip jsr SaveKid ;Save all changes to char data
]rts rts

*-------------------------------
*
*  D O   S H A D
*
*  Update shadowman (or other opponent)
*
*-------------------------------
DoShad
 lda ShadFace
 cmp #86
 beq ]rts ;"no character" code

 jsr LoadShadwOp
 jsr rereadblocks

 jsr unholy

 jsr ShadCtrl ;Opponent control module

 lda CharScrn
 cmp VisScrn
 bne :os

 jsr animchar

 lda CharX
 cmp #ScrnLeft-14
 bcc :os
 cmp #ScrnRight+14
 bcs :os ;Skip all this if char is offscreen

 jsr gravity
 jsr addfall

 jsr setupchar
 jsr rereadblocks
 jsr getedges

 jsr enemycoll

 jsr  checkfloor
 jsr  checkpress
 jsr checkspikes
 jsr checkimpale
  jsr checkslice2

:os jmp SaveShad

*-------------------------------
*
*  Add all visible characters to object table
*
*-------------------------------
addchars
 jsr :reflection
 jsr :shadowman
 jsr :kid

 jsr checkmeters

]rts rts

*-------------------------------
* Draw kid's reflection in mirror

:reflection
 jmp reflection

*-------------------------------
* Draw shadowman or other opponent

:shadowman
 lda ShadFace
 cmp #86 ;Is there a shadowman?
 beq ]rts ;no
 lda ShadScrn
 cmp VisScrn ;Is he visible?
 bne ]rts ;no

 jsr setupshad ;Add shadowman to object table

 lda ChgOppStr
 bpl :s1
 jsr setupcomix ;Add impact star if he's been hurt
:s1 jmp setupsword ;Add sword

*-------------------------------
* Draw kid

:kid lda KidScrn
 beq ]rts
 cmp VisScrn
 bne ]rts

 jsr setupkid ;Add kid to obj table

 lda ChgKidStr
 bpl :s2
 jsr setupcomix ;Add impact star
:s2 jmp setupsword ;Add sword

*-------------------------------
*
*  S E T   U P   K I D
*
*  Add kid to object table
*  Crop edges, index char, mark fredbuf/floorbuf
*
*-------------------------------
setupkid
 jsr LoadKid
 jsr rereadblocks

 lda CharPosn
 bne :cont ;Delay loop if CharPosn = 0
 lda #25
 jmp pause

:cont jsr setupchar
 jsr unevenfloor

 jsr getedges
 jsr indexchar
 jsr quickfg
 jsr quickfloor
 jsr cropchar

 jmp addkidobj ;add kid to obj table

*-------------------------------
*
*  S E T   U P   S H A D
*
*  Add shadowman to obj table
*
*-------------------------------
setupshad
 jsr LoadShad
 jsr rereadblocks

 jsr setupchar
 jsr unevenfloor

 jsr getedges
 jsr indexchar
 jsr quickfg
 jsr quickfloor
 jsr cropchar

 lda CharID
 cmp #1 ;Shadowman?
 bne :1 ;no
 lda level
 cmp #mirlevel
 bne :2
 lda CharScrn
 cmp #mirscrn
 bne :2
 lda #mirx ;Clip shadman at L as he jumps out of mirror
 asl
 asl
 clc
 adc #1
 sta FCharCL
:2 jmp addshadobj

:1 jmp addguardobj

*-------------------------------
*
*  Cut to new screen
*
*  DoQuickCut: Show bg before adding characters
*  DoCleanCut: Show frame only when complete
*
*-------------------------------
UseQuick = 0

 do UseQuick

DoQuickCut
 jsr fastspeed ;IIGS

 lda #0
 sta PAGE
 jsr drawbg ;draw bg on p1

 jsr PageFlip

 jsr copyscrn ;copy bg to p2
 jsr DoFast ;add chars

 jsr PageFlip ;show complete frame
 jmp normspeed

 else

DoCleanCut
 jsr fastspeed ;IIGS

 lda #$20
 sta PAGE
 jsr drawbg ;draw bg on p2

 lda #0
 sta PAGE
 jsr copyscrn ;copy bg to p1

 jsr DoFast ;add chars

;jsr vblank2
 jsr PageFlip
 jmp normspeed

 fin

*-------------------------------
*
*  D R A W   B G
*
*  Clear screen & draw background (on hidden hi-res page)
*  Show black lo-res screen to cover transition
*
*-------------------------------
drawbg
 lda #0
 sta cutplan

 lda #2
 sta CUTTIMER ;min # of frames between cuts

 lda #" "
 jsr lrclse
 jsr vblank
 lda PAGE2off
 lda TEXTon

 jsr DoSure ;draw b.g. w/o chars

 jmp markmeters ;mark strength meters

*-------------------------------
*
*  D O   S U R E
*
*  Clear screen and redraw entire b.g. from scratch
*
*-------------------------------
DoSure
 lda VisScrn
 sta SCRNUM

 jsr zerolsts ;zero image lists

 jsr sure ;Assemble image lists

 jsr zeropeels ;Zero peel buffers
 jsr zerored ;and redraw buffers
;(for next DoFast call)

 jmp drawall ;Dump contents of image lists to screen

*-------------------------------
*
*  D O  F A S T
*
*  Do a fast screen update
*  (Redraw objects and as little of b.g. as possible)
*
*-------------------------------
DoFast
 jsr zerolsts ;zero image lists

 lda VisScrn
 sta SCRNUM

 jsr develpatch

 jsr addmobs ;Add MOBS to object list

 jsr addchars ;Add characters to object list
;(incl. strength meters)

 jsr fast ;Assemble image lists (including objects
;from obj list and necessary portions of bg)

 jsr dispmsg ;Superimpose message (if any)
:1
 jmp drawall ;Dump contents of image lists to screen
]rts rts

*-------------------------------
*
*  Lightning flashes
*
*-------------------------------
flashon
 lda lightning
 beq :1
 lda lightcolor
 bne :2
:1 lda ChgKidStr
 bpl ]rts
 lda #$11 ;Flash red if kid's been hurt
:2 jmp doflashon

flashoff
 lda lightning
 beq :1
 dec lightning
 bpl :2

:1 lda ChgKidStr
 bpl ]rts
:2 jmp doflashoff

*-------------------------------
*
*  Initialize collision detection buffers
*
*-------------------------------
initCDbuf
 ldx #9
 lda #$ff
:zloop sta SNlastframe,x
 sta SNthisframe,x
 sta SNbelow,x
 sta SNabove,x
 dex
 bpl :zloop

 sta BlockYlast
]rts rts

*-------------------------------
*
*  Prepare to cut?
*
*  In: VisScrn = current screen
*      cutscrn = screen we want to be on
*
*  If cutscrn <> VisScrn, make necessary preparations
*  & return cutplan = 1
*
*-------------------------------
PrepCut
 lda cutscrn
 beq ]rts ;never cut to screen 0
 cmp VisScrn
 beq ]rts ;If cutscrn = VisScrn, we don't need to cut

 lda cutscrn
 sta VisScrn
 cmp #5
 bne :1
 lda level
 cmp #14
 bne :1
 jmp YouWin ;Level 14, screen 5 is princess's room--you win!

:1 lda #1
 sta cutplan

 jsr getscrns ;Get neighboring screen #s

 jsr LoadKid
 jsr addslicers
 jsr addtorches
 jsr crumble ;Activate slicers, torches, etc.

 jmp addguard ;Add guard (if any)

*-------------------------------
*
*  Time's up--you lose
*
*-------------------------------
YouLose
 jsr cutprincess ;cut to princess's room...
 lda #6
 jsr playcut ;& play cut #6

 jmp GOATTRACT ;go to title sequence

*-------------------------------
*
*  You win
*
*-------------------------------
YouWin jsr cutprincess
 lda #7
 jsr playcut ;Play cut #7
 jmp epilog ;Play epilog (& hang)

*-------------------------------
*
*  Control player
*
*  In/out: Char vars
*
*-------------------------------
ctrlplayer
 jsr kill0 ;If char is on screen 0, kill him off

 jsr PlayerCtrl ;Control player

 lda CharLife
 bmi ]rts ;If char is still alive, return

* When player dies, CharLife is set to 0.
* Inc CharLife until = #deadenough; then put up message

:dead lda CharPosn
 jsr cold?
 bne ]rts ;wait till char has stopped moving

 lda CharLife
 bne :inc
 jsr deathsong ;cue death music

:inc lda CharLife
 cmp #deadenough
 bcs :deadenough
 inc CharLife
]rts rts

:deadenough
 lda level
 beq :gameover ;Your death ends demo

 lda SongCue
 bne ]rts ;wait for song to finish before putting up msg

 lda MinLeft
 ora SecLeft
 bne :timeleft
 jmp YouLose ;if you die with time = 0, you lose

* Otherwise: "Press Button to Continue"

:timeleft
 lda message
 cmp #ContMsg
 bne :1
 lda msgtimer
 bne :ok

:1 lda #ContMsg
 sta message
 lda #255
 sta msgtimer ;Put up continue message

:ok cmp #1
 beq :gameover ;End game when msgtimer = 1

 do FinalDisk
 else

 lda develment
 beq :nodevel
 lda keypress
 cmp #kresurrect
 beq :raise ;TEMP!
:nodevel
 fin

 lda BTN0
 ora BTN1
 bpl ]rts
 jmp RESTART ;Button press restarts level

:gameover
 do EditorDisk
 jmp RESTART
 else
 jmp GOATTRACT
 fin

* Raise kid from the dead (TEMP!)

 do FinalDisk
 else
:raise
 lda #0
 sta msgtimer
 sta SongCue

 lda #BTLtimer
 sta backtolife

 jsr LoadKid

 lda MaxKidStr
 sta ChgKidStr

 lda #stand
 jsr jumpseq
 jmp startkid1

 fin

*-------------------------------
*
* Play death song
*
*-------------------------------
deathsong
 lda ShadID
 cmp #1
 beq :shad ;if opponent was shadowman
 lda heroic ;was kid engaged in battle at time of death?
 bne :1 ;yes--"heroic death" music
 lda #s_Accid ;no--"accidental death" music
 bne :2
:shad lda #s_Shadow
 bne :2
:1 lda #s_Heroic
:2 ldx #255
 jmp cuesong
]rts rts

*-------------------------------
*
* If char is on screen 0, kill him off
*
*-------------------------------
kill0
 lda CharLife
 bpl ]rts
 lda CharScrn
 bne ]rts
 lda #Splat
 jsr addsound
 lda #100
 jsr decstr
 lda #0
 sta msgtimer
 sta CharLife
 lda #185
 sta CharPosn
]rts rts

*-------------------------------
*
* Go to attract mode
*
*-------------------------------
GOATTRACT
 do DemoDisk
 else

 lda BBundID
 cmp #POPside1 ;does he need to flip disk?
 beq :ok ;no

 do ThreeFive
 else
 lda BGset1
 bpl :flip
 ldx #4
 jsr LoadLevelX ;get "FLIP DISK" msg into memory
 fin

:flip jsr flipdisk ;ask him to flip disk

 fin

 lda #POPside1
 sta BBundID

:ok jmp attractmode

*-------------------------------
*
*  Shake loose floors when character jumps
*
*-------------------------------
shakeloose
 lda jarabove
 bmi :jarbelow
 bne :jarabove
]rts rts

:jarbelow
 lda #0
 sta jarabove

 lda CharBlockY
 jmp shakem ;shake every loose floorboard on level

:jarabove
 lda #0
 sta jarabove

 lda CharBlockY
 sec
 sbc #1
 jmp shakem

*-------------------------------
*
* If strength meters have changed, mark affected
* blocks for redraw
*
*-------------------------------
checkmeters
 lda ChgKidStr
 beq :1
 jsr MarkKidMeter

:1 lda ChgOppStr
 beq ]rts
 jmp MarkOppMeter

*-------------------------------
*
* Change strength meters as specified
*
*-------------------------------
chgmeters
 lda level
 cmp #12
 bne :cont
 lda OpID
 ora CharID
 cmp #1 ;kid vs. shadowman?
 bne :cont
 ;yes
 lda ChgKidStr
 bpl :1
 sta ChgOppStr
 bne :cont

:1 lda ChgOppStr
 bpl :cont
 sta ChgKidStr

* Kid's meter

:cont lda KidStrength
 clc
 adc ChgKidStr

 cmp MaxKidStr
 beq :ok1
 bcs :opp

:ok1 sta KidStrength

* Opponent's meter

:opp lda OppStrength
 clc
 adc ChgOppStr

 cmp MaxOppStr
 beq :ok2
 bcs ]rts

:ok2 sta OppStrength
]rts rts

*-------------------------------
*
* Slam player's entrance shut (add it to trans list)
*
*-------------------------------
entrance
 lda KidScrn
 jsr calcblue

 ldy #29

:loop lda (BlueType),y
 and #idmask
 cmp #exit
 bne :cont ;find player's entrance

 lda KidScrn
 jmp closeexit ;& return

:cont dey
 bpl :loop

]rts rts

*-------------------------------
*
* Play song cues
*
* In: SongCue (0 = none, non0 = song #)
*     SongCount
*
*-------------------------------
songcues
 do EditorDisk
 rts
 fin

 ldx SongCue
 beq ]rts
 lda level
 beq ]rts ;no music in demo

 lda SongCount
 bne :cont
 lda #0
 sta SongCue ;when SongCount reaches 0, forget it
]rts rts
:cont dec SongCount

 lda KidPosn
 bne :1
 lda NextLevel
 cmp level
 beq ]rts ;Play only one song once kid has reached stairs

:1 lda KidPosn
 jsr static?
 bne ]rts

 lda ShadFace
 cmp #86
 beq :ok
 lda ShadScrn
 cmp VisScrn
 bne :ok
 lda ShadPosn
 jsr static?
 bne ]rts
:ok
 lda trobcount ;(set by animtrans if there are any
 bne ]rts ;slicers or other fast-moving objects
;that it wouldn't look good to freeze)
 lda nummob
 bne ]rts
 lda lightning
 bne ]rts ;wait for no MOBs and no lightning
 lda mergetimer
 bmi :ok2
 bne ]rts
 lda ChgKidStr
 ora ChgOppStr
 bne ]rts ;& no impact stars
:ok2

* Prepare for minimal animation

 lda PAGE
 eor #$20
 sta PAGE

 jsr listtorches

* Play song

 lda SongCue
 jsr minit

 sta $c010 ;clr kbd

:loop jsr burn
 jsr musickeys

 jsr mplay
 cmp #0
 bne :loop

:done lda #0
 sta SongCue

:rtn lda PAGE
 eor #$20
 sta PAGE

 jmp clearjoy

*-------------------------------
*
* Add additional sound fx
*
*-------------------------------
addsfx
 lda #167 ;blocked strike
 cmp KidPosn ;if char is striking...
 bne :1
 lda #SwordClash1
 bne :clash
:1 cmp ShadPosn
 bne :2
 lda #SwordClash2
:clash jmp addsound
:2
]rts rts

*-------------------------------
*
* Display message ("Press button to continue" or "Level #"
* or "# minutes left")
*
*-------------------------------
dispmsg
 lda msgtimer
 beq ]rts
 dec msgtimer

 lda KidLife
 bmi :alive

* Kid is dead -- message is "Press button to continue"

 lda msgtimer
 cmp #contoff
 bcc ]rts

 cmp #contflash
 bcs :steady

 and #7
 cmp #3
 bcs ]rts
 cmp #2
 bne :steady

 lda soundon
 bne :2
 jsr gtone ;if sound off
:2 lda #FlashMsg
 jsr addsound

:steady jmp continuemsg ;Kid is dead--superimpose continue msg

* Kid is alive -- message is "Level #" or "# Minutes"

:alive lda msgtimer
 cmp #leveltimer-2
 bcs ]rts

 lda message
 cmp #LevelMsg
 bne :1
 jmp printlevel

:1 cmp #TimeMsg
 bne ]rts
 jmp timeleftmsg

*-------------------------------
*
* Display "Turn disk over" and wait for button press
*
*-------------------------------
flipdisk
 do ThreeFive
 lda #1
 sta purpleflag ;pass copy-protect!
 rts
 fin

 do DemoDisk
 jmp GOATTRACT
 else

* 1st copy protection check

 lda redherring
 eor redherring2
 cmp #POPside1 ;passed 1st check?
 beq :1
 lda #POPside1
 sta BBundID
  jmp attractmode

* Passed copy protection--continue

:1 lda #" "
 jsr lrcls

 jsr zerolsts
 jsr zeropeels
 lda #1
 sta genCLS

 jsr flipdiskmsg

 jsr drawall

 jsr vblank
 jsr PageFlip

 lda $c010 ;clr kbd strobe
:loop
 lda $c061
 ora $c062
 ora $c000
 bpl :loop

 fin

* Flip to clr text scrn

showtext jsr vblank
 lda PAGE2off
 lda TEXTon
]rts rts

*-------------------------------
*
* Is character moving?
*
* In: A = CharPosn
* Out: 0 if static, 1 if moving
*
*-------------------------------
static?
 cmp #0
 beq ]ok
 cmp #15 ;stand
 beq ]ok
 cmp #229 ;brandish sword
 beq ]ok
 cmp #109 ;crouching
 beq ]ok
 cmp #171 ;en garde
 beq ]ok
 cmp #166 ;alert stand (for gd.)
 beq ]ok
cold?
 cmp #185 ;dead
 beq ]ok
 cmp #177 ;impaled
 beq ]ok
 cmp #178 ;halves
 beq ]ok
 lda #1
 rts
]ok lda #0
]rts rts

*-------------------------------
*
* Clear all jstk flags
*
*-------------------------------
clearjoy
 jsr LoadSelect
 lda #0
 sta clrF
 sta clrB
 sta clrU
 sta clrD
 jmp SaveSelect

*-------------------------------
*
*  Misc. timers (Call every cycle)
*
*-------------------------------
misctimers
 lda mergetimer
 beq :3
 bmi :3
 dec mergetimer
 bne :3
 dec mergetimer ;goes from 1 to -1
:3

* Level 8: When you've spent a certain amount of time on
* screen 16 once exit is open, mouse rescues you

 lda level
 cmp #8 ;mouse level
 bne :12
 lda CharScrn
 cmp #16
 bne :12
 lda exitopen
 beq :12
 cmp #mousetimer
 bcc :11
 bne :12
:10 jsr mouserescue
:11 inc exitopen
:12
]rts rts

*-------------------------------
*
*  Screen flashes towards end of weightlessness period
*
*-------------------------------
wtlessflash
 lda weightless
 beq ]rts
 ldx #0
 sec
 sbc #1
 sta weightless
 beq :3
 ldx #$ff
 cmp #wtlflash
 bcs :3
 lda vibes
 eor #$ff
 tax
:3 stx vibes ;Screen flashes as weightlessness ends
]rts rts

*-------------------------------
* yellow copy protection
* (call right before 1st princess cut)
* In: A = next level
*-------------------------------
yellowcheck
 cmp #2
 bne ]rts
 jsr showtext
 ldx #10
 jmp yellow ;in gamebg
 ;sets yellowflag ($7c) hibit

*-------------------------------
*
*  Temp development patch for screen redraw
*  (also used for invert Y)
*
*-------------------------------
develpatch
 do 0
 lda blackflag ;blackout?
 beq :1
 lda #1
 sta genCLS
 fin

:1 lda redrawflg ;forced redraw?
 beq ]rts
 dec redrawflg

 jsr markmeters
 jmp sure

*-------------------------------
 lst
 ds 1
 usr $a9,4,$a00,*-org
 lst off
