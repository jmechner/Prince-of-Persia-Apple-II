 tr on
 lst off
* gameeq
*-------------------------------
*
*  Equates
*
*-------------------------------
chtable1 = $6000
chtable2 = $8400
chtable3 = $0800
chtable4 = $9600
chtable5 = $a800
chtable6 = $6000
chtable7 = $9f00

bgtable1 = $6000
bgtable2 = $8400

topctrl = $2000
seqtable = $2800
seqtab = $3000
ctrl = $3a00
coll = $4500
gamebg = $4c00
auto = $5400

mobtables = $b600
savedgame = $b6f0

msys = $d400
ctrlsubs = $d000
specialk = $d900
textline = $dfd8
subs = $e000
sound = $ea00
mover = $ee00
misc = $f900
debugs = $fc00

*-------------------------------
*
*  Jump tables
*
*-------------------------------
 dum mobtables

trobspace = $20
mobspace = $10
maxsfx = $20

trloc ds trobspace
trscrn ds trobspace
trdirec ds trobspace

mobx ds mobspace
moby ds mobspace
mobscrn ds mobspace
mobvel ds mobspace
mobtype ds mobspace
moblevel ds mobspace

soundtable ds maxsfx

trobcount ds 1

 dum savedgame

SavLevel ds 1
SavStrength ds 1
SavMaxed ds 1
SavTimer ds 2
 ds 1
SavNextMsg ds 1

 dum topctrl

start ds 3
restart ds 3
startresume ds 3
initsystem ds 3
 ds 3

docrosscut ds 3
goattract ds 3

 dum ctrl

PlayerCtrl ds 3
checkfloor ds 3
ShadCtrl ds 3
rereadblocks ds 3
checkpress ds 3

DoImpale ds 3
GenCtrl ds 3
checkimpale ds 3

 dum auto

AutoCtrl ds 3
checkstrike ds 3
checkstab ds 3
AutoPlayback ds 3
cutcheck ds 3

cutguard ds 3
addguard ds 3
cut ds 3

 dum coll

checkbarr ds 3
collisions ds 3
getfwddist ds 3
checkcoll ds 3
animchar ds 3

checkslice ds 3
checkslice2 ds 3
 ds 3
checkgate ds 3
 ds 3

enemycoll ds 3

 dum gamebg

updatemeters ds 3
DrawKidMeter ds 3
DrawSword ds 3
DrawKid ds 3
DrawShad ds 3

setupflame ds 3
continuemsg ds 3
addcharobj ds 3
setobjindx ds 3
printlevel ds 3

DrawOppMeter ds 3
flipdiskmsg ds 3
timeleftmsg ds 3
DrawGuard ds 3
DrawGuard2 ds 3

setupflask ds 3
setupcomix ds 3
psetupflame ds 3
drawpost ds 3
drawglass ds 3

initlay ds 3
twinkle ds 3
flow ds 3
pmask ds 3
yellow ds 3

setrecheck0 ds 3
recheckyel ds 3

 dum specialk

keys ds 3
clrjstk ds 3
zerosound ds 3
addsound ds 3
facejstk ds 3

SaveSelect ds 3
LoadSelect ds 3
SaveDesel ds 3
LoadDesel ds 3
initinput ds 3

demokeys ds 3
listtorches ds 3
burn ds 3
getminleft ds 3
keeptime ds 3

shortentime ds 3
cuesong ds 3
 ds 3
 ds 3
 ds 3

dloop ds 3
strobe ds 3

 dum mover

animtrans ds 3
trigspikes ds 3
pushpp ds 3
breakloose1 ds 3
breakloose ds 3

animmobs ds 3
addmobs ds 3
closeexit ds 3
getspikes ds 3
shakem ds 3

trigslicer ds 3
trigtorch ds 3
getflameframe ds 3
smashmirror ds 3
jamspikes ds 3

trigflask ds 3
getflaskframe ds 3
trigsword ds 3
jampp ds 3

 dum ctrlsubs

getframe ds 3
getseq ds 3
getbasex ds 3
getblockx ds 3
getblockxp ds 3

getblocky ds 3
getblockej ds 3
addcharx ds 3
getdist ds 3
getdist1 ds 3

getabovebeh ds 3
rdblock ds 3
rdblock1 ds 3
setupsword ds 3
getscrns ds 3

addguardobj ds 3
opjumpseq ds 3
getedges ds 3
indexchar ds 3
quickfg ds 3

cropchar ds 3
getleft ds 3
getright ds 3
getup ds 3
getdown ds 3

cmpspace ds 3
cmpbarr ds 3
addkidobj ds 3
addshadobj ds 3
addreflobj ds 3

LoadKid ds 3
LoadShad ds 3
SaveKid ds 3
SaveShad ds 3
setupchar ds 3

GetFrameInfo ds 3
indexblock ds 3
markred ds 3
markfred ds 3
markwipe ds 3

markmove ds 3
markfloor ds 3
unindex ds 3
quickfloor ds 3
unevenfloor ds 3

markhalf ds 3
addswordobj ds 3
getblocky1 ds 3
checkledge ds 3
get2infront ds 3

checkspikes ds 3
rechargemeter ds 3
addfcharx ds 3
facedx ds 3
jumpseq ds 3

GetBaseBlock ds 3
LoadKidwOp ds 3
SaveKidwOp ds 3
getopdist ds 3
LoadShadwOp ds 3

SaveShadwOp ds 3
boostmeter ds 3
getunderft ds 3
getinfront ds 3
getbehind ds 3

getabove ds 3
getaboveinf ds 3
cmpwall ds 3

 dum subs

addtorches ds 3
doflashon ds 3
PageFlip ds 3
demo ds 3
showtime ds 3

doflashoff ds 3
lrclse ds 3
 ds 3
 ds 3
 ds 3

addslicers ds 3
pause ds 3
 ds 3
deadenemy ds 3
playcut ds 3

addlowersound ds 3
RemoveObj ds 3
addfall ds 3
setinitials ds 3
startkid ds 3

startkid1 ds 3
gravity ds 3
initialguards ds 3
mirappear ds 3
crumble ds 3

 dum sound

playback ds 3

 dum msys

_minit ds 3
_mplay ds 3

 dum seqtable

Fdef ds 1200
altset1 ds 200
altset2 ds 450
swordtab ds 192

 dum misc

VanishChar ds 3
movemusic ds 3
moveauxlc ds 3
firstguard ds 3
markmeters ds 3

potioneffect ds 3
mouserescue ds 3
StabChar ds 3
unholy ds 3
reflection ds 3

MarkKidMeter ds 3
MarkOppMeter ds 3
bonesrise ds 3
decstr ds 3
DoSaveGame ds 3

LoadLevelX ds 3
checkalert ds 3
dispversion ds 3

 dum debugs

showpage ds 3
debugkeys ds 3
 ds 3
titlescreen ds 3

*-------------------------------
*
*  Zero page
*
*-------------------------------
locals = $e8

*-------------------------------
*  $40-e7: Game globals
*-------------------------------
 dum $40

Char ds $10
Kid ds $10
Shad ds $10
FCharVars ds 12
yellowflag ds 1
timebomb ds 1
justblocked ds 1
gdtimer ds 1
framepoint ds 2
Fimage ds 1
Fdx ds 1
Fdy ds 1
Fcheck ds 1
exitopen ds 1
collX ds 1
lightning ds 1
lightcolor ds 1
offguard ds 1
blockid ds 1
blockx ds 1
blocky ds 1
infrontx ds 1
behindx ds 1
abovey ds 1
tempblockx ds 1
tempblocky ds 1
tempscrn ds 1
tempid ds 1
numtrans ds 1
tempnt ds 1
redrawflg ds 1
xdiff ds 2
ydiff ds 2
xdir ds 1
ydir ds 1
RNDseed ds 1
invert ds 1
PlayCount ds 1
refract ds 1
backtolife ds 1
cutplan ds 1
lastcmd ds 1
distfallen ds 1
cutscrn ds 1
waitingtojump ds 1
trigppabove ds 1
direcpp ds 1
blockaddr ds 2
delay ds 1
XCOORD ds 2
savekidx ds 1
mirrx ds 1
dmirr ds 1
barrdist ds 1
barrcode ds 1
imwidth ds 1
imheight ds 1
leadedge ds 1
leftej ds 1
rightej ds 1
topej ds 1
leftblock ds 1
rightblock ds 1
topblock ds 1
bottomblock ds 1
CDLeftEj ds 1
CDRightEj ds 1
endrange ds 1
bufindex ds 1
blockedge ds 1
collideL ds 1
collideR ds 1
weightless ds 1
cutorder ds 1
AMtimer ds 1
begrange ds 1
scrn ds 1
keybufptr ds 1
VisScrn ds 1
OppStrength ds 1
jarabove ds 1
KidStrength ds 1
ChgKidStr ds 1
MaxKidStr ds 1
EnemyAlert ds 1
ChgOppStr ds 1
heroic ds 1
clrF ds 1
clrB ds 1
clrU ds 1
clrD ds 1
clrbtn ds 1
Fsword ds 1
purpleflag ds 1 ;$da
msgtimer ds 1
MaxOppStr ds 1
guardprog ds 1
ManCtrl ds 1
mergetimer ds 1
lastpotion ds 1
origstrength ds 1
jmpaddr ds 2
alertguard ds 1
createshad ds 1
stunned ds 1
droppedout ds 1

*-------------------------------
*
*  Page 2-3
*
*-------------------------------
 dum $212

milestone ds 1
GlassState ds 1
redrawglass ds 1
doortop ds 1
GuardColor ds 1
shadowaction ds 1
skipmessage ds 1
savezp ds 32
MSset ds 1
rjumpflag ds 1
redherring ds 1

 dum $300

MinLeft ds 1
NextTimeMsg ds 1
SecLeft ds 1
BGset1 ds 1
BGset2 ds 1
CHset ds 1
FrameCount ds 2
SongCount ds 1
PreRecPtr ds 1
gotsword ds 1
message ds 1
SPEED ds 1
nummob ds 1
clrSEL ds 5
clrDESEL ds 5
vibes ds 1
SongCue ds 1
musicon ds 1
redkidmeter ds 1
NextLevel ds 1
scrncolor ds 1
redoppmeter ds 1
timerequest ds 1

 dum $320

CDthisframe ds $10
CDlastframe ds $10
CDbelow ds $10
CDabove ds $10
SNthisframe ds $10
SNlastframe ds $10
SNbelow ds $10
SNabove ds 10
BlockYthis ds 1
BlockYlast ds 1

Op ds $10

keybuflen = 10
keybuf ds keybuflen

*-------------------------------
*
*  Character data
*
*-------------------------------
 dum Char
CharPosn ds 1
CharX ds 1
CharY ds 1
CharFace ds 1
CharBlockX ds 1
CharBlockY ds 1
CharAction ds 1
CharXVel ds 1
CharYVel ds 1
CharSeq ds 2
CharScrn ds 1
CharRepeat ds 1
CharID ds 1
CharSword ds 1
CharLife ds 1

 dum Op
OpPosn ds 1
OpX ds 1
OpY ds 1
OpFace ds 1
OpBlockX ds 1
OpBlockY ds 1
OpAction ds 1
OpXVel ds 1
OpYVel ds 1
OpSeq ds 2
OpScrn ds 1
OpRepeat ds 1
OpID ds 1
OpSword ds 1
OpLife ds 1

 dum Kid
KidPosn ds 1
KidX ds 1
KidY ds 1
KidFace ds 1
KidBlockX ds 1
KidBlockY ds 1
KidAction ds 1
KidXVel ds 1
KidYVel ds 1
KidSeq ds 2
KidScrn ds 1
KidRepeat ds 1
KidID ds 1
KidSword ds 1
KidLife ds 1

 dum Shad
ShadPosn ds 1
ShadX ds 1
ShadY ds 1
ShadFace ds 1
ShadBlockX ds 1
ShadBlockY ds 1
ShadAction ds 1
ShadXVel ds 1
ShadYVel ds 1
ShadSeq ds 2
ShadScrn ds 1
ShadRepeat ds 1
ShadID ds 1
ShadSword ds 1
ShadLife ds 1

 dum FCharVars
FCharImage ds 1
FCharX ds 2
FCharY ds 1
FCharFace ds 1
FCharIndex ds 1
FCharCU ds 1
FCharCD ds 1
FCharCL ds 1
FCharCR ds 1
FCharTable ds 1

 dend

*-------------------------------
*
*  Misc. data
*
*-------------------------------
Fcheckmark = %01000000
Fthinmark = %00100000
Ffootmark = %00011111

floorheight = 15
angle = 7
VertDist = 11

UseFastlay = 0
UseLay = 1
UseLayrsave = 2

TypeKid = 0
TypeShad = 1
TypeGd = 2
TypeSword = 3
TypeReflect = 4
TypeComix = 5
TypeFF = $80

 lst off
