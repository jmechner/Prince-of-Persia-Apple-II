* seqtable
org = $3000
 tr on ;TABS 15,20,40
 lst off
 lstdo off

*-------------------------------
* Seq table instructions:

goto = -1
aboutface = -2
up = -3
down = -4
chx = -5
chy = -6
act = -7
setfall = -8
ifwtless = -9
die = -10
jaru = -11
jard = -12
effect = -13
tap = -14
nextlevel = -15

*-------------------------------
*
*  S E Q U E N C E   T A B L E
*
*-------------------------------
 org org

:1 dw startrun
:2 dw stand
:3 dw standjump
:4 dw runjump
:5 dw turn
:6 dw runturn
:7 dw stepfall
:8 dw jumphangMed
:9 dw hang
:10 dw climbup
:11 dw hangdrop
:12 dw freefall
:13 dw runstop
:14 dw jumpup
:15 dw fallhang
:16 dw jumpbackhang
:17 dw softland
:18 dw jumpfall
:19 dw stepfall2
:20 dw medland
:21 dw rjumpfall
:22 dw hardland
:23 dw hangfall
:24 dw jumphangLong
:25 dw hangstraight
:26 dw rdiveroll
:27 dw sdiveroll
:28 dw highjump
:29 dw step1
:30 dw step2
:31 dw step3
:32 dw step4
:33 dw step5
:34 dw step6
:35 dw step7
:36 dw step8
:37 dw step9
:38 dw step10
:39 dw step11
:40 dw step12
:41 dw step13
:42 dw fullstep
:43 dw turnrun
:44 dw testfoot
:45 dw bumpfall
:46 dw hardbump
:47 dw bump
:48 dw superhijump
:49 dw standup
:50 dw stoop
:51 dw impale
:52 dw crush
:53 dw deadfall
:54 dw halve
:55 dw engarde
:56 dw advance
:57 dw retreat
:58 dw strike
:59 dw flee
:60 dw turnengarde
:61 dw strikeblock
:62 dw readyblock
:63 dw landengarde
:64 dw bumpengfwd
:65 dw bumpengback
:66 dw blocktostrike
:67 dw strikeadv
:68 dw climbdown
:69 dw blockedstrike
:70 dw climbstairs
:71 dw dropdead
:72 dw stepback
:73 dw climbfail
:74 dw stabbed
:75 dw faststrike
:76 dw strikeret
:77 dw alertstand
:78 dw drinkpotion
:79 dw crawl
:80 dw alertturn
:81 dw fightfall
:82 dw efightfall
:83 dw efightfallfwd
:84 dw running
:85 dw stabkill
:86 dw fastadvance
:87 dw goalertstand
:88 dw arise
:89 dw turndraw
:90 dw guardengarde
:91 dw pickupsword
:92 dw resheathe
:93 dw fastsheathe
:94 dw Pstand
:95 dw Vstand
:96 dw Vwalk
:97 dw Vstop
:98 dw Palert
:99 dw Pback
:100 dw Vexit
:101 dw Mclimb
:102 dw Vraise
:103 dw Plie
:104 dw patchfall
:105 dw Mscurry
:106 dw Mstop
:107 dw Mleave
:108 dw Pembrace
:109 dw Pwaiting
:110 dw Pstroke
:111 dw Prise
:112 dw Pcrouch
:113 dw Pslump
:114 dw Mraise

*-------------------------------
* r u n n i n g
*-------------------------------
running
 db act,1
 db goto
 dw runcyc1

*-------------------------------
* s t a r t r u n
*-------------------------------
startrun
 db act,1
runstt1 db 1
runstt2 db 2
runstt3 db 3
runstt4 db 4,chx,8
runstt5 db 5,chx,3
runstt6 db 6,chx,3

runcyc1 db 7,chx,5
runcyc2 db 8,chx,1
runcyc3 db tap,1,9,chx,2
runcyc4 db 10,chx,4
runcyc5 db 11,chx,5
runcyc6 db 12,chx,2
runcyc7 db tap,1,13,chx,3
runcyc8 db 14,chx,4
 db goto
 dw runcyc1

*-------------------------------
*  s t a n d
*-------------------------------
stand
 db act,0
 db 15
 db goto
 dw stand

*-------------------------------
* a l e r t   s t a n d
*-------------------------------
goalertstand
 db act,1
alertstand
:loop db 166
 db goto
 dw :loop

*-------------------------------
* a r i s e (skeleton)
*-------------------------------
arise
 db act,5
 db chx,10,177
 db 177
 db chx,-7,chy,-2,178
 db chx,5,chy,2,166
 db chx,-1
 db goto
 dw ready

*-------------------------------
* g u a r d e n g a r d e
*-------------------------------
guardengarde
 db goto
 dw ready

*-------------------------------
* e n  g a r d e
*-------------------------------
engarde
 db act,1
 db chx,2
 db 207
 db 208,chx,2
 db 209,chx,2
 db 210,chx,3
ready
 db act,1
 db tap,0
 db 158
 db 170
:loop db 171

 db goto
 dw :loop

*-------------------------------
* s t a b b e d
*-------------------------------
stabbed
 db act,5
 db setfall,-1,0
 db 172,chx,-1,chy,1
 db 173,chx,-1
 db 174,chx,-1,chy,2
; db 175
 db chx,-2,chy,1
 db chx,-5,chy,-4
 db goto
 dw guy8

*-------------------------------
* s t r i k e - a d v a n c e
*-------------------------------
;from guy6 (154)
strikeadv
 db act,1
 db setfall,1,0
 db 155
 db chx,2,165
 db chx,-2
 db goto
 dw ready

*-------------------------------
* s t r i k e - r e t r e a t
*-------------------------------
 ;from guy6 (154)
strikeret
 db act,1
 db setfall,-1,0
 db 155,156,157
 db 158
 db goto
 dw retreat

*-------------------------------
* a d v a n c e
*-------------------------------
advance
 db act,1
 db setfall,1,0
 db chx,2,163
 db chx,4,164
 db 165

 db goto
 dw ready

*-------------------------------
* f a s t   a d v a n c e
*-------------------------------
fastadvance
 db act,1
 db setfall,1,0
 db chx,6,164
 db 165

 db goto
 dw ready

*-------------------------------
* r e t r e a t
*-------------------------------
retreat
 db act,1
 db setfall,-1,0
 db chx,-3,160
 db chx,-2,157

 db goto
 dw ready

*-------------------------------
* s t r i k e
*-------------------------------
strike
 db act,1
 db setfall,-1,0
 db 168

faststrike
 db act,1
guy3 db 151
guy4 db act,1
 db 152
;-->blockedstrike
guy5 db 153
guy6 db 154
guy7 db act,5 ;clr flags to avoid repeat strike
 db 155
guy8 db act,1
 db 156
guy9 db  157

 db goto
 dw ready

*-------------------------------
* b l o c k e d   s t r i k e
*-------------------------------
blockedstrike
 db act,1
 db 167
;--> strikeblock
 db goto
 dw guy7

*-------------------------------
* b l o c k   t o   s t r i k e
*-------------------------------
blocktostrike
 db 162
 db goto
 dw guy4

*-------------------------------
* r e a d y   b l o c k
*-------------------------------
readyblock
 db 169
blocking
 db 150
 ;--> blocktostrike/retreat
 db goto
 dw ready

*-------------------------------
* s t r i k e   t o   b l o c k
*-------------------------------
strikeblock
 db 159
 db 160
 db goto
 dw blocking

*-------------------------------
* l a n d   e n   g a r d e
*-------------------------------
landengarde
 db act,1
 db jard

 db goto
 dw ready

*-------------------------------
* b u m p   e n   g a r d e   ( f o r w a r d )
*-------------------------------
bumpengfwd
 db act,5
 db chx,-8

 db goto
 dw ready

*-------------------------------
* b u m p   e n   g a r d e   ( b a c k )
*-------------------------------
bumpengback
 db act,5
 db 160
 db 157
 db goto
 dw ready

*-------------------------------
* f l e e
*-------------------------------
flee
 db act,7
 db chx,-8

 db goto
 dw turn

*-------------------------------
* t u r n   e n   g a r d e
*-------------------------------
turnengarde
 db act,5
 db aboutface,chx,5

 db goto
 dw retreat

*-------------------------------
*  a l e r t  t u r n (for enemies)
*-------------------------------
alertturn
 db act,5

 db aboutface,chx,18

 db goto
 dw goalertstand

*-------------------------------
*  s t a n d j u m p
*-------------------------------
standjump
 db act,1
 db 16
 db 17,chx,2
 db 18,chx,2
 db 19,chx,2
 db 20,chx,2
 db 21,chx,2
 db 22,chx,7
 db 23,chx,9
 db 24,chx,5,chy,-6 ;chx 6?
sjland db 25,chx,1,chy,6
 db 26,chx,4
 db jard
 db tap,1,27,chx,-3
 db 28,chx,5
 db 29
 db tap,1,30
 db 31
 db 32
 db 33,chx,1
 db goto
 dw stand

*-------------------------------
*  r u n j u m p
*-------------------------------
runjump
 db act,1
 db tap,1,34,chx,5
 db 35,chx,6
 db 36,chx,3
 db 37,chx,5
 db tap,1,38,chx,7
 db 39,chx,12,chy,-3
 db 40,chx,8,chy,-9
 db 41,chx,8,chy,-2
 db 42,chx,4,chy,11
 db 43,chx,4,chy,3
rjlandrun
 db 44,chx,5
 db jard,tap,1
 db goto
 dw runcyc1

*-------------------------------
*  r u n  d i v e  r o l l
*-------------------------------
rdiveroll
 db act,1

 db chx,1
 db 107,chx,2
 db chx,2
 db 108
 db chx,2
 db 109
 db chx,2
 db 109
 db chx,2
:crouch db 109
 db goto
 dw :crouch

*-------------------------------
*  s t a n d  d i v e  r o l l
*-------------------------------
sdiveroll

*-------------------------------
*  c r a w l
*-------------------------------
crawl
 db act,1
 db chx,1,110
 db 111,chx,2
 db 112

 db chx,2
 db 108
 db chx,2
:crouch db 109
 db goto
 dw :crouch

*-------------------------------
*  t u r n  d r a w
*-------------------------------
turndraw
 db act,7
 db aboutface,chx,6
 db 45,chx,1
 db 46
 db goto
 dw engarde

*-------------------------------
*  t u r n
*-------------------------------
turn
 db act,7
 db aboutface,chx,6
 db 45,chx,1
 db 46,chx,2
 db 47,chx,-1
finishturn
 db 48,chx,1
 db 49,chx,-2
 db 50,51,52
 db goto
 dw stand

*-------------------------------
*  t u r n r u n
*  (from frame 48)
*-------------------------------
turnrun
 db act,1
 db chx,-1
 db goto
 dw runstt1

*-------------------------------
*  r u n t u r n
*-------------------------------
runturn
 db act,1
 db chx,1
 db  53,chx,1
 db tap,1,54,chx,8
 db 55
 db tap,1,56,chx,7
 db 57,chx,3
 db 58,chx,1
 db 59
 db 60,chx,2
 db 61,chx,-1
 db 62
 db 63
 db 64,chx,-1
 db 65,chx,-14
 db aboutface,goto
 dw runcyc7

*-------------------------------
*  f i g h t f a l l  (backward)
*-------------------------------
fightfall
 db act,3
 db chy,-1

 db 102,chx,-2,chy,6
 db 103,chx,-2,chy,9
 db 104,chx,-1,chy,12
 db 105,chx,-3

 db setfall,0,15
 db goto
 dw freefall

*-------------------------------
*  e n e m y  f i g h t  f a l l
*-------------------------------
efightfall
 db act,3
 db chy,-1,chx,-2

 db 102,chx,-3,chy,6
 db 103,chx,-3,chy,9
 db 104,chx,-2,chy,12
 db 105,chx,-3
;for now--ultimately we want enemy
;shapes in here
 db setfall,0,15
 db goto
 dw freefall

*-------------------------------
*  e n e m y  f i g h t  f a l l  f w d
*-------------------------------
efightfallfwd
 db act,3
 db chx,1,chy,-1

 db 102,chx,2,chy,6
 db 103,chx,-1,chy,9
 db 104,chy,12
 db 105,chx,-2
;for now--ultimately we want enemy
;shapes in here
 db setfall,1,15
 db goto
 dw freefall


*-------------------------------
*  s t e p f a l l
*-------------------------------
stepfall ;from #8 (run-11)
 db act,3
 db chx,1,chy,3

 db ifwtless
 dw stepfloat
fall1
 db 102,chx,2,chy,6
 db 103,chx,-1,chy,9
 db 104,chy,12
 db 105,chx,-2

 db setfall,1,15
 db goto
 dw freefall

*-------------------------------
* p a t c h f a l l
*-------------------------------
patchfall
 db chx,-1,chy,-3
 db goto
 dw fall1

*-------------------------------
* s t e p f a l l 2
*-------------------------------
stepfall2 ;from #12 (run-15)
 db chx,1
 db goto
 dw stepfall

*-------------------------------
*  s t e p f l o a t
*-------------------------------
stepfloat
 db 102,chx,2,chy,3
 db 103,chx,-1,chy,4
 db 104,chy,5
 db 105,chx,-2

 db setfall,1,6
 db goto
 dw freefall

*-------------------------------
*  j u m p  f a l l
*-------------------------------
jumpfall ;from standjump-18
 db act,3
 db chx,1,chy,3
 db 102,chx,2,chy,6
 db 103,chx,1,chy,9
 db 104,chx,2,chy,12
 db 105

 db setfall,2,15
 db goto
 dw freefall

*-------------------------------
*  r u n n i n g   j u m p   f a l l
*-------------------------------
rjumpfall ;from runjump-43
 db act,3
 db chx,1,chy,3
 db 102,chx,3,chy,6
 db 103,chx,2,chy,9
 db 104,chx,3,chy,12
 db 105

 db setfall,3,15
 db goto
 dw freefall

*-------------------------------
*  j u m p h a n g
*-------------------------------
;Med: DX = 0
jumphangMed
 db act,1
 db 67,68,69,70,71,72,73,74,75,76,77
 db act,2
 db 78,79,80
 db goto
 dw hang

;Long: DX = +4
jumphangLong
 db act,1
 db 67,68,69,70,71,72,73,74,75,76,77
 db act,2
 db chx,1,78
 db chx,2,79
 db chx,1,80

 db goto
 dw hang

*-------------------------------
* j u m p b a c k h a n g
*-------------------------------
jumpbackhang
 db act,1
 db 67,68,69,70,71,72,73,74,75,76
 db chx,-1,77
 db act,2
 db chx,-2,78
 db chx,-1,79
 db chx,-1,80

 db goto
 dw hang

*-------------------------------
*  h a n g
*-------------------------------
hang
 db act,2
; db jaru
 db 91
hang1
 db 90,89,88,87,87,87,88,89,90,91,92,93,94,95
 db 96,97,98,99,97,96,95,94,93,92
 db 91,90,89,88,87,88,89,90,91,92,93,94,95,96
 db 95,94,93,92
 db goto
 dw hangdrop

*-------------------------------
*  h a n g s t r a i g h t
*-------------------------------
hangstraight
 db act,6
 db tap,2
 db 92,93,93,92,92
:loop db 91
 db goto
 dw :loop

*-------------------------------
*  c l i m b f a i l
*-------------------------------
climbfail
 db 135
 db 136
 db 137,137
 db 138,138,138,138
 db 137,136,135
 db chx,-7

 db goto
 dw hangdrop

*-------------------------------
*  c l i m b d o w n
*-------------------------------
climbdown
 db act,1

 db 148
 db 145,144,143,142,141

 db chx,-5
 db chy,63
 db down
 db act,3 ;to prevent a cut to scrn above

 db 140,138,136
 db 91
 db goto
 dw hang1

*-------------------------------
*  c l i m b u p
*-------------------------------
climbup
 db act,1

 db 135
 db 136
 db 137
 db 138
 db 139
 db 140

 db chx,5
 db chy,-63
 db up

 db 141
 db 142
 db 143
 db 144
 db 145
 db 146
 db 147
 db  148
 db act,5 ;to clr flags
 db 149
 db act,1

 db 118,119
 db chx,1
 db goto
 dw stand

*-------------------------------
*  h a n g d r o p
*-------------------------------
hangdrop ;1/2 story

 db act,0 ;NOTE -- hangdrop is an action relating
;to the ground, not to the ledge
 db 81,82
 db act,5 ;to zero clrflags
 db 83
 db act,1
 db jard,tap,0
 db 84,85
 db chx,3
 db goto
 dw stand

*-------------------------------
*  h a n g f a l l
*-------------------------------
hangfall ;1/2 story

 db act,3
 db 81,chy,6
 db 81,chy,9
 db 81,chy,12
 db chx,2

 db setfall,0,12
 db goto
 dw freefall

*-------------------------------
*  f r e e f a l l
*-------------------------------
freefall
 db act,4
:loop db 106
 db goto
 dw :loop

*-------------------------------
*  r u n s t o p
*-------------------------------
runstop
 db act,1
 db 53,chx,2
 db tap,1,54,chx,7
 db 55
 db tap,1,56,chx,2
 db 49,chx,-2
 db 50,51,52
 db goto
 dw stand

*-------------------------------
*  j u m p  u p  (& touch ceiling)
*-------------------------------
jumpup
 db act,1
 db 67,68,69,70,71,72,73,74,75,76,77,78
 db act,0 ;for cropchar
 db jaru,79

 db goto
 dw hangdrop

*-------------------------------
*  h i g h j u m p  (no ceiling above)
*-------------------------------
highjump
 db act,1
 db 67,68,69,70,71,72,73,74,75,76,77,78
 db 79,chy,-4
 db 79,chy,-2
 db 79
 db 79,chy,2
 db 79,chy,4
 db goto
 dw hangdrop

*-------------------------------
*  s u p e r h i j u m p  (when weightless)
*-------------------------------
superhijump
 db 67,68,69,70,71,72,73,74,75,76
 db chy,-1,77
 db chy,-3,78
 db chy,-4,79
 db chy,-10,79
 db chy,-9,79
 db chy,-8,79
 db chy,-7,79
 db chy,-6,79
 db chy,-5,79
 db chy,-4,79
 db chy,-3,79
 db chy,-2,79
 db chy,-2,79
 db chy,-1,79
 db chy,-1,79
 db chy,-1,79
 db 79,79,79
 db chy,1,79
 db chy,1,79
 db chy,2,79
 db chy,2,79
 db chy,3,79
 db chy,4,79
 db chy,5,79
 db chy,6,79

 db setfall,0,6
 db goto
 dw freefall

*-------------------------------
*  f a l l  h a n g
*-------------------------------
fallhang
 db act,3
 db 80
 db tap,1
 db goto
 dw hang

*-------------------------------
*  b u m p
*-------------------------------
bump
 db act,5
 db chx,-4

 db 50,51,52
 db goto
 dw stand

*-------------------------------
*  b u m p f a l l
*-------------------------------
bumpfall
 db act,5
 db chx,1,chy,3

 db ifwtless
 dw bumpfloat

 db 102,chx,2,chy,6
 db 103,chx,-1,chy,9
 db 104,chy,12
 db 105,chx,-2

 db setfall,0,15
 db goto
 dw freefall

*-------------------------------
*  b u m p f l o a t
*-------------------------------
bumpfloat
 db 102,chx,2,chy,3
 db 103,chx,-1,chy,4
 db 104,chy,5
 db 105,chx,-2

 db setfall,0,6
 db goto
 dw freefall

*-------------------------------
* h a r d   b u m p
*-------------------------------
hardbump
 db act,5

 db chx,-1,chy,-4,102
 db chx,-1,chy,3 ;,104
 db chx,-3,chy,1

 db jard
 db chx,1
 db tap,1
 db 107,chx,2
 db 108
 db tap,1

 db 109
 db goto
 dw standup

*-------------------------------
*  t e s t   f o o t
*-------------------------------
testfoot
 db 121,chx,1
 db 122
 db 123,chx,2
 db 124,chx,4
 db 125,chx,3
 db 126

 db chx,-4,86
 db tap,1,jard
 db chx,-4,116
 db chx,-2
 db 117,118,119
 db goto
 dw stand

*-------------------------------
*  s t e p   b a c k
*-------------------------------
stepback
 db chx,-5
 db goto
 dw stand

*-------------------------------
*  s t e p   f o r w a r d
*
*  (1 - 14 pixels)
*-------------------------------
fullstep
step14
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,3
 db 124,chx,4
 db 125,chx,3
 db 126,chx,-1

 db chx,3

 db 127,128,129,130,131,132
 db goto
 dw stand

step13
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,3
 db 124,chx,4
 db 125,chx,3
 db 126,chx,-1

 db chx,2

 db 127,128,129,130,131,132
 db goto
 dw stand

step12
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,3
 db 124,chx,4
 db 125,chx,3
 db 126,chx,-1

 db chx,1

 db 127,128,129,130,131,132
 db goto
 dw stand

step11 ;corresponds directly to filmed sequence
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,3
 db 124,chx,4
 db 125,chx,3
 db 126,chx,-1
 db 127,128,129,130,131,132
 db goto
 dw stand

step10
 db act,1
 db 121,chx,1
step10a db 122,chx,1
 db 123,chx,3
 db 124,chx,4
 db 125,chx,3
 db 126,chx,-2
 db 128,129,130,131,132
 db goto
 dw stand

step9
 db act,1
 db 121
 db goto
 dw step10a

step8
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,3
 db 124,chx,4
 db 125,chx,-1
 db 127,128,129,130,131,132
 db goto
 dw stand

step7
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,3
 db 124,chx,2

 db 129,130,131,132
 db goto
 dw stand

step6
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,2
 db 124,chx,2

 db 129,130,131,132
 db goto
 dw stand

step5
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,2
 db 124,chx,1

 db 129,130,131,132
 db goto
 dw stand

step4
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,2

 db 131,132
 db goto
 dw stand

step3
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 123,chx,1

 db 131,132
 db goto
 dw stand

step2
 db act,1
 db 121,chx,1
 db 122,chx,1
 db 132
 db goto
 dw stand

step1
 db act,1
 db 121,chx,1
 db 132
 db goto
 dw stand

*-------------------------------
*  s t o o p
*-------------------------------
stoop
 db act,1

 db chx,1
 db 107,chx,2
 db 108

:crouch db 109
 db goto
 dw :crouch

*-------------------------------
*  s t a n d u p
*-------------------------------
standup
 db act,5
 db chx,1,110
 db 111,chx,2
 db 112
 db 113,chx,1
 db 114
 db 115
 db 116,chx,-4
 db 117,118,119

 db goto
 dw stand

*-------------------------------
*  p i c k  u p  s w o r d
*-------------------------------
pickupsword
 db act,1
 db effect,1
 db 229,229,229,229,229,229
 db 230,231,232

 db goto
 dw resheathe

*-------------------------------
*  r e s h e a t h e
*-------------------------------
resheathe
 db act,1
 db chx,-5
 db 233,234,235
 db 236,237,238,239,240,133,133
 db 134,134,134
 db 48,chx,1
 db 49,chx,-2
 db act,5,50,act,1
 db 51,52
 db goto
 dw stand

*-------------------------------
*  f a s t   s h e a t h e
*-------------------------------
fastsheathe
 db act,1
 db chx,-5
 db 234,236,238,240,134
 db chx,-1
 db goto
 dw stand

*-------------------------------
*  d r i n k   p o t i o n
*-------------------------------
drinkpotion
 db act,1
 db chx,4
 db 191,192,193,194,195,196,197,198,199,200
 db 201,202,203,204
;if pressed for memory try
;cutting frames 202/204 or 201/203
 db 205,205,205
 db effect,1
 db 205,205
 db 201,198

 db chx,-4
 db goto
 dw stand

*-------------------------------
*  s o f t   l a n d
*-------------------------------
softland ;1 story
 db act,5

 db jard
 db chx,1
 db tap,1,107,chx,2
 db 108
 db tap,1

 db act,1
:crouch db 109
 db goto
 dw :crouch

*-------------------------------
*  l a n d   r u n
*-------------------------------
landrun
 db act,1
 db chy,-2,chx,1
 db 107,chx,2
 db 108
 db 109,chx,1
 db 110
 db 111,chx,2
 db 112
 db 113,chx,1,chy,1
 db 114,chy,1
 db 115,chx,-2

 db goto
 dw runstt4

*-------------------------------
*  m e d i u m   l a n d
*-------------------------------
medland ;1 1/2 - 2 stories
 db act,5
 db jard
 db chy,-2,chx,1
; db 107
 db chx,2
 db 108
 db 109,109,109,109,109,109,109,109,109
 db 109,109,109,109,109,109,109,109,109
 db 109,109,109,109,109,109,109,109,109
 db 109,109,chx,1
 db 110,110,110
 db 111,chx,2
 db 112
 db 113,chx,1,chy,1
 db 114,chy,1
 db 115
 db 116,chx,-4
 db 117
 db 118
 db 119
 db goto
 dw stand

*-------------------------------
*  h a r d   l a n d   (Splat!)
*-------------------------------
hardland ;> 2 stories
 db act,5
 db jard
 db chy,-2,chx,3
 db 185
 db die

:dead db 185
 db goto
 dw :dead

*-------------------------------
*  s t a b k i l l
*-------------------------------
stabkill
 db act,5
 db goto
 dw dropdead

*-------------------------------
*  d r o p d e a d
*-------------------------------
dropdead
 db act,1
 db die

 db 179
 db 180
 db 181
 db 182,chx,1
 db 183,chx,-4
:dead db 185
 db goto
 dw :dead

*-------------------------------
*  i m p a l e
*-------------------------------
impale
 db act,1
 db jard

 db chx,4
 db 177
 db die

:dead db 177
 db goto
 dw :dead

*-------------------------------
*  h a l v e
*-------------------------------
halve
 db act,1

 db 178
 db die

:dead db 178
 db goto
 dw :dead

*-------------------------------
*  c r u s h
*-------------------------------
crush
 db goto
 dw medland

*-------------------------------
*  d e a d f a l l
*-------------------------------
deadfall
 db setfall,0,0
 db act,4
:loop db 185
 db goto
 dw :loop

*-------------------------------
*  c l i m b   s t a i r s
*-------------------------------
;facing L
climbstairs
 db act,5
 db chx,-5,chy,-1
 db tap,1,217
 db 218
 db 219,chx,1
 db 220,chx,-4,chy,-3
 db tap,1,221,chx,-4,chy,-2
 db 222,222,chx,-2,chy,-3
 db 223,223,chx,-3,chy,-8
 db tap,1,224,224,chx,-1,chy,-1
 db 225,225,chx,-3,chy,-4
 db 226,226,chx,-1,chy,-5
 db tap,1,227,227,chx,-2,chy,-1
 db 228,228
 db 0,tap,1
 db 0,0,0,0,tap,1
 db 0,0,0,0,tap,1
 db 0,0,0,0,tap,1

 do 0
 db chx,10,chy,28
 db goto
 dw stand
 fin

 db nextlevel
:loop db 0,goto
 dw :loop

*-------------------------------
* Vizier: stand
*-------------------------------
Vstand
 db 54,goto
 dw Vstand

*-------------------------------
* Vizier: raise arms
*-------------------------------
Vraise
 db 85,67,67,67,67,67,67
 db 68,69,70,71,72,73,74,75,83,84
:loop db 76
 db goto
 dw :loop

*-------------------------------
* Vizier: walk
*-------------------------------
Vwalk
 db chx,1
Vwalk1 db 48,chx,2
Vwalk2 db 49,chx,6
 db 50,chx,1
 db 51,chx,-1
 db 52,chx,1
 db 53,chx,1
 db goto
 dw Vwalk1

*-------------------------------
* Vizier: stop
*-------------------------------
Vstop
 db chx,1
 db 55,56
 db goto
 dw Vstand

*-------------------------------
* Vizier: lower arms, turn & exit
*-------------------------------
Vexit
 db 77,78,79,80,81,82
 db chx,1
 db 54,54,54,54,54,54 ;standing
 db 57
 db 58
 db 59
 db 60
 db 61,chx,2
 db 62,chx,-1
 db 63,chx,-3
 db 64
 db 65,chx,-1
 db 66
 db aboutface,chx,16
 db chx,3
 db goto
 dw Vwalk2

*-------------------------------
* Princess: stand
*-------------------------------
Pstand
 db 11,goto
 dw Pstand

*-------------------------------
* Princess: alert
*-------------------------------
Palert
 db 2,3,4,5,6,7,8,9
 db aboutface,chx,9
 db 11,goto
 dw  Pstand

*-------------------------------
* Princess: step back
*-------------------------------
Pback
 db aboutface,chx,11
 db 12
 db chx,1,13
 db chx,1,14
 db chx,3,15
 db chx,1,16
:loop db 17
 db goto
 dw :loop

*-------------------------------
* Princess lying on cushions
*-------------------------------
Plie
 db 19
 db goto
 dw Plie

*-------------------------------
* Princess: waiting
*-------------------------------
Pwaiting
:loop db 20
 db goto
 dw :loop

*-------------------------------
* Princess: embrace
*-------------------------------
Pembrace
 db 21
 db chx,1,22
 db 23
 db 24
 db chx,1,25
 db chx,-3,26
 db chx,-2,27
 db chx,-4,28
 db chx,-3,29
 db chx,-2,30
 db chx,-3,31
 db chx,-1,32
:loop db 33
 db goto
 dw :loop

*-------------------------------
* Princess: stroke mouse
*-------------------------------
Pstroke
:loop db 37
 db goto
 dw :loop

*-------------------------------
* Princess: rise
*-------------------------------
Prise
 db 37,38,39,40,41,42,43,44,45,46,47
 db aboutface,chx,13
:loop db 11,goto
 dw :loop

*-------------------------------
* Princess: crouch & stroke mouse
*-------------------------------
Pcrouch
 db 11,11
 db aboutface,chx,13
 db 47,46,45,44,43,42,41,40,39,38,37
 db 36,36,36,35,35,35
 db 34,34,34,34,34,34,34
 db 35,35,36,36,36,35,35,35
 db 34,34,34,34,34,34,34
 db 35,35,36,36,36,35,35,35
 db 34,34,34,34,34,34,34,34,34
 db 35,35,35
:loop db 36
 db goto
 dw :loop

*-------------------------------
* Princess: slump shoulders
*-------------------------------
Pslump
 db 1
:loop db 18
 db goto
 dw :loop

*-------------------------------
* Mouse: scurry
*-------------------------------
Mscurry
 db act,1
Mscurry1
:loop db 186,chx,5
 db 186,chx,3
 db 187,chx,4
 db goto
 dw :loop

*-------------------------------
* Mouse: stop
*-------------------------------
Mstop
:loop db 186
 db goto
 dw :loop

*-------------------------------
* Mouse: raise head
*-------------------------------
Mraise
:loop db 188
 db goto
 dw :loop

*-------------------------------
* Mouse: leave
*-------------------------------
Mleave
 db act,0
 db 186,186,186
 db 188,188,188,188,188,188,188,188
 db aboutface,chx,8
 db goto
 dw Mscurry1

*-------------------------------
* Mouse: climb
*-------------------------------
Mclimb
 db 186
 db goto
 dw Mclimb

*-------------------------------
 lst
 ds 1
 usr $a9,15,$800,*-org
 lst off
