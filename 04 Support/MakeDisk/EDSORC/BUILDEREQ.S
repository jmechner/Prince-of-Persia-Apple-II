* buildereq
 lst off
*-------------------------------
*
*  B U I L D E R   E Q U A T E S
*
*-------------------------------mainmem
bgtable = $6000
edtable = $ae00

dblimage = $d000
textset = $d800

*-------------------------------auxmem
menuscrn = $2000 ;length = $2000

dialoger = $6000
directory = $7000
bsubs = $7200
builder = $8400
editor = $9600

MATBASE = $8000 ;length = $400 = 32x32
ENDMAT = MATBASE+$400

builderinfo = $a600 ;length = $600

*-------------------------------aux l.c.
eddebugs = $ea00
dblhires = $ee00
dcarrybuf = $f700
dpeelbuf1 = $fa00
dpeelbuf2 = $fd00

*-------------------------------
*
*  J U M P   T A B L E S
*
*-------------------------------
 dum eddebugs

showpage ds 3
debugkeys ds 3
moveauxlc ds 3
titlescreen ds 3

 dum builderinfo

bINFO ds 256 ;unused
bLINK1 ds 128
bLINK2 ds 128
bLINK3 ds 128
bLINK4 ds 128
bLINDEX ds 24*30

 dum dblhires

dblcls ds 3
dbllay ds 3
dblfast ds 3
dblsave ds 3
dblwipe ds 3

dblprint ds 3
dblimseek ds 3
dblora ds 3

 dum editor

edstart ds 3
clrblock ds 3
relink ds 3
 ds 3
 ds 3

 dum bsubs

dblhgr ds 3
dbldraw ds 3
moveblok ds 3
swsingle ds 3
swdouble ds 3

specialk ds 3
bcalcblue ds 3
topedge ds 3
botedge ds 3
leftedge ds 3

rtedge ds 3
prblokno ds 3
prscrnum ds 3
menuspecial ds 3
drawbethsym ds 3

invbethsym ds 3
drawallsymb ds 3
storemenu ds 3
dodblcls ds 3
dodbllay ds 3

dodblfast ds 3
dodblsave ds 3
dodblwipe ds 3
dodblprint ds 3
dodblimseek ds 3

pageflip ds 3
input ds 3
dblpeel ds 3
retrievemenu ds 3
movestuff ds 3

dodblora ds 3
copyauxscrn ds 3
drawmenusym ds 3
unindex ds 3
superguards ds 3

initinput ds 3
drawflaskno ds 3
prgdprog ds 3

 dum dialoger

print ds 3
dialog ds 3
setmasterdisk ds 3
setdatadisk ds 3
readdisk ds 3

dloadlevel ds 3
dsavelevel ds 3
initgetlnbuf ds 3
dsavelevelg ds 3
setgamedisk1 ds 3
setgamedisk2 ds 3

 dum builder

coldbuild ds 3
warmbuild ds 3
rtnbuild ds 3
mleft ds 3
mright ds 3

mdown ds 3
mup ds 3
getneigh ds 3
calcmat1 ds 3
clrlinks ds 3

restartbldr ds 3

*-------------------------------
*
*  Z E R O   P A G E
*
*-------------------------------
*  $00-17: Hires params
*  $18-3f: Common globals
*  $e0-fc: Locals
*  $fd-ff: RW18
*-------------------------------
locals = $e0

*-------------------------------
*  $40-df: Builder globals
*-------------------------------
 dum $40

MATPTR ds 2
ZTEMP ds 6
ULX ds 1
ULY ds 1

charx ds 2
chary ds 1
globtemp ds 2
stringptr ds 2

linkmode ds 1
number ds 1

bLinkIndex ds 2
nextlink ds 1

linkindex ds 1
bethx ds 1
bethy ds 1
bethstatus ds 1
gspecad ds 2

heldspec ds 1

ytemp ds 1
getlnptr ds 1
chartemp ds 1
linenum ds 1
direcptr ds 1

diskid ds 1
topolist ds 1
okcancel ds 1

saveim ds 2
objspec ds 1
linkbits ds 3
addr ds 2
ysave ds 1
blockthresh ds 1
gateposn ds 1

BLOCKX ds 2
BLOCKY ds 1
BLACKX ds 2
BLACKY ds 1

MATX ds 1
MATY ds 1

PTRX ds 1
PTRY ds 1

BUFFLAG ds 1
BUFFX ds 2
BUFFY ds 2

TEMP ds 4

CURSOR ds 1
RMARGIN ds 1
BLOCKNUM ds 1
NUMNEXT ds 1

setupflg ds 1
savecurs ds 1
saveby ds 1
menuindx ds 1
menuflg ds 1

jcount ds 1
jlast ds 1
objid ds 1

THIRD ds 1
HELD ds 1
POINTX ds 1
POINTY ds 1

antcount ds 1
savescrn ds 1
savepx ds 1
savepy ds 1
nextscrn ds 1

size ds 1
dright ds 1
dup ds 1

virgin ds 1

barx ds 1
bary ds 1

shownums ds 1
idcompare ds 1
special ds 1
loy ds 1
maxfiles ds 1

 dend
*-------------------------------
*  Command list

Cleft = 1
Cright = 2
Cup = 3
Cdown = 4
Cbtn0 = 5
Cbtn1 = 6

*-------------------------------
RETURN = $8d

rawbtn0 = $c061
rawbtn1 = $c062
