* ed/dialoger
org = $6000
 lst off
*-------------------------------
*
*  D I A L O G E R
*
*-------------------------------
 org org

 jmp PRINT
 jmp DIALOG
 jmp SETMASTERDISK
 jmp SETDATADISK
 jmp READDISK

 jmp DLOADLEVEL
 jmp DSAVELEVEL
 jmp INITGETLNBUF
 jmp DSAVELEVELG
 jmp SETGAMEDISK1
 jmp SETGAMEDISK2

*-------------------------------
getlnbuf ds $10
filelist ds $20

*-------------------------------
 put eq
 put buildereq

 dum locals

savechr ds 3
numfiles ds 1
listptr ds 1

 dend

*-------------------------------
*
* DIRECTORY FORMAT:
*
* $200 bytes: 32 fields, 16 bytes each
*
* diroffset,x is directory offset for field #x (0-21)
*
* Fields #0-29 (max 30 files):
*   Bytes 0-11: file name (12 chars max)
*   Byte 12: blueprint track #
*   Byte 13: blueprint region (0-1)
*   Byte 14: binfo track #
*   Byte 15: binfo region (0-2)
*
* Field #30:
*   Bytes 0-11: disk title
*
* Field #31:
*   Byte 0: disk ID
*
*-------------------------------
dirofflo hex 00,10,20,30,40,50,60,70,80,90,a0,b0,c0,d0,e0,f0
 hex 00,10,20,30,40,50,60,70,80,90,a0,b0,c0,d0,e0,f0

diroffhi hex 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
 hex 01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01

maxfilesDD = 30 ;max # of files on data disk
maxfilesMD = 6 ;& on master disk
maxfilesGD1 = 4 ;& on game disk side 1
maxfilesGD2 = 20 ;& on game disk side 2

fieldleng = 16
fnameleng = 12

titlefield = 30
idfield = 31

*-------------------------------
* RW18 ID bytes (intrinsic to disk)

IDside1 = $a9 ;game disk side 1
IDside2 = $ad ;game disk side 2

* $f5-f6 also available

* NOTE--master & data disks use $a9 (for now)

*-------------------------------
* Builder ID bytes (stored as 31st byte of directory track)

gamedisk1id = $77
gamedisk2id = $99

datadiskid = $dd
masterdiskid = $11

*-------------------------------
*
* DISK FORMAT:
*
* Directory on track 34 ($200 bytes)
*
* Master disk stores 6 levels as follows:
*  BLUEPRINT ($900 bytes) on tracks 30-33 (2 levels/track)
*  BINFO ($600 bytes) on tracks 29-30 (3 levels/track)
*
* Data disk follows same pattern, repeated 5 times,
* to make space for 30 levels on 25 tracks.
*
* Game disk stores only BLUEPRINT, 2 levels/track:
*  Side 1: 4 levels on tracks 32-33
*  Side 2: 20 levels on tracks 24-33
*
*-------------------------------
* Blueprint & binfo TRACK & REGION indexed by level # (0-n)

* game disk

gameTRKlst
 db 33,33,32,32,31,31
 db 30,30,29,29,28,28
 db 27,27,26,26,25,25
 db 24,24

gameREGlst

* master & data disk

bluepREGlst
 db 0,1,0,1,0,1
 db 0,1,0,1,0,1
 db 0,1,0,1,0,1
 db 0,1,0,1,0,1
 db 0,1,0,1,0,1

bluepTRKlst
 db 33,33,32,32,31,31
 db 28,28,27,27,26,26
 db 23,23,22,22,21,21
 db 18,18,17,17,16,16
 db 13,13,12,12,11,11

binfoTRKlst
 db 30,30,30,29,29,29
 db 25,25,25,24,24,24
 db 20,20,20,19,19,19
 db 15,15,15,14,14,14
 db 10,10,10,9,9,9

binfoREGlst
 db 0,1,2,0,1,2
 db 0,1,2,0,1,2
 db 0,1,2,0,1,2
 db 0,1,2,0,1,2
 db 0,1,2,0,1,2

*-------------------------------
kDELETE = $ff
kESC = $9b

*-------------------------------
* Useful background colors:

black = 0
magenta = 1
brown = 2
dkgreen = 4
dkblue = 8

*-------------------------------
*
* Format for box data:
*  Width (80)
*  Height (192)
*  Color (16)
*  XCO (80)
*  YCO (192)
*
*-------------------------------
fnlength = 12 ;including <CR>... max = 16

numnames = 5 ;# of names in box

boxmarg = 5
boxwid = 80-boxmarg-boxmarg
boxrt = 79-boxmarg
boxtop = 33
topline = 36
firstname = 49
linespace = 10
boxheight = 65
boxbottom = boxtop+boxheight
boxcolor = dkblue
okx = 425
oky = firstname+30

fnwid = 52
okwid = boxwid-fnwid
okleft = boxmarg+fnwid

msgline = 53

fnamey db firstname,firstname+10,firstname+20
 db firstname+30,firstname+40

loadbox db boxwid,boxheight-1,boxcolor,boxmarg,boxtop+1
loadbord1 db boxwid,1,15,boxmarg,boxtop
loadbord2 db boxwid,1,15,boxmarg,boxtop+13
loadbord3 db boxwid,1,15,boxmarg,boxbottom
loadbordL db 1,boxheight+1,$f0,boxmarg-1,boxtop
loadbordM db 1,boxheight-14,$0f,okleft,boxtop+14
loadbordR db 1,boxheight+1,$0f,boxrt+1,boxtop

okfix db 1,11,$0f,okleft,oky

msgbox db boxwid,boxheight-1,boxcolor,boxmarg,boxtop+1
msgbord1 db boxwid,1,15,boxmarg,boxtop
msgbord3 db boxwid,1,15,boxmarg,boxbottom
msgbordL db 1,boxheight+1,$f0,boxmarg-1,boxtop
msgbordM db 1,boxheight-1,$0f,okleft,boxtop+1
msgbordR db 1,boxheight+1,$0f,boxrt+1,boxtop

listwipe1 db 46,38,boxcolor,10,firstname+10
listwipe2 db 46,38,boxcolor,10,firstname

fnwipe db fnwid,11,black,5,firstname
fnunwipe db fnwid,11,boxcolor,5,firstname

okwipe db okwid,11,black,okleft,oky
okunwipe db okwid,11,boxcolor,okleft,oky

linewipe db 35,9,boxcolor,40,topline

*-------------------------------
loadwhat asc 'Load level named: ',8d
savewhat asc 'Save level named: ',8d
deletewhat asc 'Delete level named: ',8d
okmsg asc 'OK',8d
cancelmsg asc 'Cancel',8d
askMD asc 'Put master disk in drive 1',8d
askGD asc 'Put game disk in drive 1',8d
askDD asc 'Put data disk in drive 1',8d
createwarn asc 'WARNING!  Directory track',8d
createwarn2 asc 'will be erased',8d

*-------------------------------
*
* I N I T  G E T L N  B U F
*
*-------------------------------
INITGETLNBUF
 lda #$8d ;RETURN
 sta getlnbuf
 rts

*-------------------------------
*
*   P R I N T
*
*   Print a character & advance cursor
*
*   In:  charx (560), chary (192)
*        A = ASCII value of character
*   Out: new charx
*
*-------------------------------
PRINT

* convert ASCII to textset index
* Text set covers ASCII 32-122

 and #$7f
 cmp #32
 bcc :braap
 cmp #123
 bcs :braap

 sec
 sbc #31

* call dblhires print routine

 sta IMAGE

 lda chary
 sta YCO
 lda charx
 sta XCO
 lda charx+1
 sta OFFSET
 jsr cvtx

 jsr dodblprint

* advance cursor

 ldx XCO
 lda Mult7,x
 clc
 adc OFFSET ;convert bits & bytes to 560-res
 clc
 adc #3 ;fudge factor
 clc
 adc charx
 sta charx

 lda #0
 adc charx+1
 sta charx+1

 lda #0 ;pl = "ok"
 rts

:braap lda #$ff ;mi = "braap"
 rts
*-------------------------------
*
* D I A L O G
*
* Dialog box # passed in accumulator:
*  0 = PLAY LEVEL, 1 = LOAD LEVEL, 2 = SAVE LEVEL,
*  3 = DELETE LEVEL, 4 = CLEAR LEVEL, 5 = CREATE DISK
*
* Steps:
*  (1) Draw dialog box on hidden page
*  (2) Page-flip to show dialog box
*  (3) Have the dialog on visible page
*  (4) Page-flip to hide dialog box
*
*-------------------------------
DIALOG
 cmp #0
 bne :1
 jsr diaplay
 jmp return

:1 cmp #1
 bne :2
 jsr diaload
 jmp return

:2 cmp #2
 bne :3
 jsr diasave
 jmp return

:3 cmp #3
 bne :4
 jsr diadelete
 jmp return

:4 cmp #4
 bne :5
 jsr diaclear
 jmp return

:5 cmp #5
 bne :6
 jsr diacreate
 jmp return

:6 rts
*-------------------------------
return
 sta $c010
 rts
*-------------------------------
*
*  Set idcompare (disk we expect to be in drive)
*  & corresponding maxfiles value
*
*-------------------------------
SETDATADISK
 lda #datadiskid
 ldx #maxfilesDD
]si sta idcompare
 stx maxfiles
 rts

SETMASTERDISK
 lda #masterdiskid
 ldx #maxfilesMD
 bne ]si

SETGAMEDISK1
 lda #gamedisk1id
 ldx #maxfilesGD1
 bne ]si

SETGAMEDISK2
 lda #gamedisk2id
 ldx #maxfilesGD2
 bne ]si

*-------------------------------
dmsgbox
 ldx #msgbox
 ldy #>msgbox
 jsr drawbox
 ldx #msgbord1
 ldy #>msgbord1
 jsr drawbox
 ldx #msgbord3
 ldy #>msgbord3
 jsr drawbox

 ldx #msgbordL
 ldy #>msgbordL
 jsr drawline
 ldx #msgbordM
 ldy #>msgbordM
 jsr drawline
 ldx #msgbordR
 ldy #>msgbordR
 jsr drawline

 jsr okcan
 jmp flipshow

dloadbox
 ldx #loadbox
 ldy #>loadbox
 jsr drawbox
 ldx #loadbord1

 ldy #>loadbord1
 jsr drawbox
 ldx #loadbord2
 ldy #>loadbord2
 jsr drawbox
 ldx #loadbord3
 ldy #>loadbord3
 jsr drawbox

 ldx #loadbordL
 ldy #>loadbordL
 jsr drawline
 ldx #loadbordM
 ldy #>loadbordM
 jsr drawline
 ldx #loadbordR
 ldy #>loadbordR
 jsr drawline

 jsr okcan
 jmp flipshow

okcan ;OK/cancel
 lda #okx
 sta charx
 lda #>okx
 sta charx+1
 lda #oky
 sta chary

 lda #okmsg
 sta stringptr
 lda #>okmsg
 sta stringptr+1
 jsr printline

 lda #okx
 sta charx
 lda #>okx
 sta charx+1

 jsr nextline

 lda #cancelmsg
 sta stringptr
 lda #>cancelmsg
 sta stringptr+1
 jmp printline

*-------------------------------
* dialog: wrong disk is in drive--ask for right one

askfordisk
 lda idcompare
 cmp #gamedisk1id
 beq askforgame
 cmp #gamedisk2id
 beq askforgame
 cmp #masterdiskid
 beq askformaster
 bne askfordata

]t1 jsr dmsgbox
 jmp setmsg

askfordata
 jsr ]t1
 lda #askDD
 ldx #>askDD
]t2 sta stringptr
 stx stringptr+1
 jsr printline
 jsr canok
 ldx okcancel
]rts rts

askforgame
 jsr ]t1
 lda #askGD
 ldx #>askGD
 bne ]t2

askformaster
 jsr ]t1
 lda #askMD
 ldx #>askMD
 bne ]t2

*-------------------------------
* d i a l o g : p l a y

diaplay
 jsr setmasterdisk ;we want master disk

* is it the right disk?

 jsr readdisk
 beq ]rts ;yes--no dialog necessary

* no-- print switch-disks msg

:again
 jsr askformaster
 cpx #$ff
 beq :done ;cancelled--no need to check disk

* now is it the right disk?

 jsr readdisk
 bne :again

:done jsr fliphide
 ldx okcancel
 rts

*-------------------------------
* d i a l o g : l o a d
*
* only from data & master disks
*-------------------------------
diaload
 jsr dloadbox

* print prompt message

 jsr setprompt
 lda #loadwhat
 sta stringptr
 lda #>loadwhat
 sta stringptr+1
 jsr printline

* print directory

 jsr readanydisk

 lda idcompare
 cmp #datadiskid
 beq :ok
 cmp #masterdiskid
 bne :notadatadisk

:ok jsr makelist
 jsr listfiles

* get filename

 jsr setcursor
 jsr setbar

 lda #$8d
 sta getlnbuf
 jsr printbuf

 jsr getline
 ldx okcancel ;1/-1
 bmi :done

* search for filename

 jsr searchfile

:done jsr clrbuf ;clear getlnbuf if x=ff
 jsr fliphide
 rts ;with file# or ff in x-reg

* err--not a data disk

:notadatadisk
 jsr askfordata ;or master
 ldx okcancel
 bpl :tryagain
 rts ;cancelled

:tryagain jmp diaload

*-------------------------------
* d i a l o g : s a v e
*
* In: idcompare
*-------------------------------
diasave
 jsr dloadbox

* print prompt message

 jsr setprompt
 lda #savewhat
 sta stringptr
 lda #>savewhat
 sta stringptr+1
 jsr printline

* print directory

 jsr readdisk
 bpl :rightdisk ;Disk must match idcompare

 lda idcompare
 cmp #masterdiskid
 bne :wrongdisk
 jsr GETIDBYTE
 cmp #datadiskid
 bne :wrongdisk ;Exception:
  jsr setdatadisk ;Data disk can sub for master disk

:rightdisk
 jsr makelist
 jsr listfiles

* get filename

 jsr setcursor
 jsr setbar

 jsr printbuf ;current file name in buffer
 jsr getline

 lda getlnptr
 bne :cont ;fname must be at least 1 char

 lda #-1
 sta okcancel
:cont
 ldx okcancel
 bmi :done ;cancel

* search for filename

 jsr searchfile
 cpx #$ff
 bne :done ;save level as file #x

 jsr namefile

:done jsr clrbuf
 jsr fliphide
 rts

* err: wrong disk

:wrongdisk
 jsr askfordisk
 ldx okcancel
 cpx #-1
 bne :tryagain
 rts ;cancelled

:tryagain jmp diasave

*-------------------------------
* d i a l o g : d e l e t e

diadelete
 jsr dloadbox

* print prompt message

 jsr setprompt
 lda #deletewhat
 sta stringptr
 lda #>deletewhat
 sta stringptr+1
 jsr printline

* print directory

 jsr readanydisk
 bmi :notadatadisk

 jsr makelist
 jsr listfiles

* get filename

 jsr setcursor
 jsr setbar

 lda #$8d
 sta getlnbuf
 jsr printbuf

 jsr getline

 ldx okcancel
 bmi :done ;cancel

* search for filename

 jsr searchfile

 jsr clrbuf ;clear getlnbuf if x=ff
 jsr deletefile ;delete file if x<>ff

:done lda #$8d
 sta getlnbuf

 jsr fliphide
 rts

* err--not a data disk

:notadatadisk
 jsr askfordata
 ldx okcancel
 cpx #-1
 bne :tryagain
 rts ;cancelled

:tryagain jmp diadelete
*-------------------------------
* d i a l o g : c l e a r

diaclear
 ldx #0 ;not $ff
 rts

*-------------------------------
*
* d i a l o g : c r e a t e
*
* (i.e., zero directory)
*
* In: idcompare = desired disk id
*
*-------------------------------
diacreate
 jsr dmsgbox
 jsr setmsg

* game disk, data disk or master disk?

 lda idcompare
 cmp #datadiskid
 beq :dd
 cmp #gamedisk1id
 beq :gd
 cmp #gamedisk2id
 beq :gd
 cmp #masterdiskid
 bne :done

:md lda #askMD
 ldx #>askMD
]ask sta stringptr
 stx stringptr+1
 jsr printline
 jmp :cont

:gd lda #askGD
 ldx #>askGD
 bne ]ask

:dd lda #askDD
 ldx #>askDD
 bne ]ask

* print warning message

:cont jsr nextline
 jsr setleftej

 lda #createwarn
 sta stringptr
 lda #>createwarn
 sta stringptr+1
 jsr printline

 jsr nextline
 jsr setleftej

 lda #createwarn2
 sta stringptr
 lda #>createwarn2
 sta stringptr+1
 jsr printline

* OK/cancel

 jsr canok
 ldx okcancel
 cpx #-1
 beq :done

* zero directory

 jsr ZERODIR

* set id byte to "idcompare"

 jsr GETIDBYTE
 lda idcompare
 sta (stringptr),y

* write out directory

 jsr writedir

:done jsr fliphide
 rts ;with file# or ff in x-reg

*===============================
GETIDBYTE
 ldx #idfield ;disk id field

getfield ;X = field # (0-31)
 lda #directory
 clc
 adc dirofflo,x
 sta stringptr

 lda #>directory
 adc diroffhi,x
 sta stringptr+1 ;set stringptr

 ldy #0 ;first char
 lda (stringptr),y
 rts
*-------------------------------
* delete file #x if x <> ff

deletefile
 cpx #$ff
 beq :skip

 jsr getfield

 lda #$ff
 sta (stringptr),y ;first char of filename

 jsr writedir

:skip rts
*-------------------------------
* clear getln buffer

clrbuf cpx #$ff
 bne :rts
 lda #$8d
 sta getlnbuf
:rts rts
*-------------------------------
* p r i n t b u f

* print current contents of getln buffer
* return getlnptr

printbuf
 ldx #0
:loop lda getlnbuf,x
 cmp #$8d
 beq :done
 inx
 cpx #fnlength
 bcc :loop
 jsr gtone

:done stx getlnptr
 cpx #0
 beq :rts

 lda #getlnbuf
 sta stringptr
 lda #>getlnbuf
 sta stringptr+1

 jsr printline

:rts rts
*-------------------------------
* n a m e f i l e

* In: filename in getln buffer
* Search directory for blank space, and name it
* Return in x: # (0-19); if direc full, return #$ff

namefile
 lda #directory
 sta stringptr

 lda #>directory
 sta stringptr+1 ;set stringptr

 ldx #0 ;file # (0-19)

:nextfile
 ldy #0
 lda (stringptr),y
 cmp #$ff ;empty code
 beq :foundblank

 lda stringptr
 clc
 adc #fieldleng
 sta stringptr

 lda stringptr+1
 adc #0
 sta stringptr+1 ;next direc entry

 inx
 cpx maxfiles
 bcc :nextfile

:dirfull jsr gtone

 ldx #$ff
 rts

* name blank file with getlnbuf

:foundblank
 ldy #0
:nextchar lda getlnbuf,y
 sta (stringptr),y
 iny
 cpy #fnameleng
 bcc :nextchar

* add track & region data bytes

 lda bluepTRKlst,x
 sta (stringptr),y

 iny
 lda bluepREGlst,x
 sta (stringptr),y

 iny
 lda binfoTRKlst,x
 sta (stringptr),y

 iny
 lda binfoREGlst,x
 sta (stringptr),y

 rts ;with level # in x-reg.

*-------------------------------
* s e a r c h f i l e

* In: filename in getln buffer
* Search directory for this filename
* Return in x: # (0-19); if not found, return #$ff

searchfile
 lda #directory
 sta stringptr

 lda #>directory
 sta stringptr+1 ;set stringptr

 ldx #0 ;file # (0-19)

:nextfile
 ldy #0
:nextchar
 lda (stringptr),y ;next char of filename
 cmp getlnbuf,y
 bne :miss
 cmp #$8d ;return
 beq :match

 iny
 cpy #fnameleng
 bcc :nextchar
 jsr gtone ;kludge errcheck

:miss lda stringptr
 clc
 adc #fieldleng
 sta stringptr

 lda stringptr+1
 adc #0
 sta stringptr+1 ;next direc entry

 inx
 cpx maxfiles
 bcc :nextfile

:notfound ldx #$ff
 rts

:match rts
*-------------------------------
*
* R E A D  D I S K
*
* Read directory
*
* READANYDISK: change idcompare to match disk in drive--
*  return 0
*
* READDISK: look for desired idcompare--return 0 if disk
*   matches, ff if it doesn't
*
*-------------------------------
READANYDISK
readanydisk
 lda #0
 sta idcompare
READDISK
 jsr readdir ;read directory from disk

 lda idcompare
 bne :mustmatch

 jsr GETIDBYTE
 sta idcompare

 cmp #datadiskid
 bne :1
 jsr setdatadisk
 jmp :ok

:1 cmp #masterdiskid
 bne :2
 jsr setmasterdisk
 jmp :ok

:2 cmp #gamedisk1id
 bne :3
 jsr setgamedisk1
 jmp :ok

:3 cmp #gamedisk2id
 bne :notok
 jsr setgamedisk2
 jmp :ok

:mustmatch
 jsr GETIDBYTE
 cmp idcompare
 bne :notok

:ok lda #0
 rts

:notok lda #$ff
 rts

*-------------------------------
* m a k e l i s t

* Transfer file numbers (0-29) from directory to
* file list, leaving out "empty" files

makelist

:ok jsr zerofilelist ;set every slot to ff

 ldx #0
 stx direcptr
 jsr getfield

 ldx #0 ;filelist index

 ldy #0

:loop lda (stringptr),y ;first char
 cmp #$ff ;"empty" code
 beq :skip

 lda direcptr
 sta filelist,x
 inx

:skip inc direcptr
 lda direcptr
 cmp maxfiles
 bcs :done

 lda stringptr
 clc
 adc #fieldleng
 sta stringptr

 lda stringptr+1
 adc #0
 sta stringptr+1 ;next direc entry
 bne :loop

:done stx numfiles ;# of files in filelist (0-20)

 lda #0
 sta topolist ;start with 1st file in dir
 rts

*-------------------------------
* l i s t f i l e s

* Starting with file #topolist,
* print names of next five files in file list

listfiles
 lda topolist
 sta listptr ;list ptr (0-19)

 lda #1
 sta linenum

 jsr setlist ;set cursor to top of list area

:nextfile
 ldx listptr
 cpx maxfiles
 bcs :rts ;out of files

 lda filelist,x ;get direcptr
 bmi :rts ;out of files

 tax
 jsr getfield ;get stringptr

 jsr printfname

 jsr nextline ;next line down

 inc linenum
 inc listptr

 lda linenum
 cmp #numnames+1
 bcc :nextfile

:rts rts
*-------------------------------
* zero filelist
* (put ff in every slot)

zerofilelist
 ldx #0
 lda #$ff ;"no file" code
:loop sta filelist,x
 inx
 cpx maxfiles
 bne :loop
 rts
*-------------------------------
* print filename
*
* In: stringptr, chary

printfname
 ldy #0
 lda (stringptr),y ;first char of filename
 cmp #$ff ;"empty" code
 beq :rts

 jsr setleftej
 jsr printline
:rts rts

*-------------------------------
* wipe filename
*
* In: chary

wipefname
 ldx #fnwipe
 ldy #>fnwipe
wipe1 jsr setupbox

 lda chary
 sec
 sbc #2
 sta YCO
 jmp dodblwipe

unwipefname
 ldx #fnunwipe
 ldy #>fnunwipe
 jmp wipe1

wipe2 jsr setupbox

 lda chary
 sec
 sbc #2
 sta YCO
 jmp dodblora

*-------------------------------
* wipe ok/cursor

wipeok
 ldx #okwipe
 ldy #>okwipe
 jsr wipe1

 ldx #okfix
 ldy #>okfix
 jmp wipe2

unwipeok
 ldx #okunwipe
 ldy #>okunwipe
 jsr wipe1

 ldx #okfix
 ldy #>okfix
 jmp wipe2

*-------------------------------
* Set cursor to beginning of entry field

setcursor lda #280
 sta charx
 lda #>280
 sta charx+1
 lda #topline
 sta chary
 rts
*-------------------------------
* Set bar to top of filename list

* bary: 0 = top, 4 = bottom
* barx: 0 = left (filenames), 1 = right (OK/cancel)

setbar
 lda #0
 sta bary
 sta barx
 sta okcancel

 lda numfiles
 beq setbarok ;no files in list

:rts rts

*-------------------------------
* Set bar to "OK"

setbarok
 lda #3
 sta bary
 lda #1
 sta barx

 lda #0
 sta okcancel ;1 = ok, -1 = cancel, 0 = waiting
 rts
*-------------------------------
setprompt lda #78
 sta charx
 lda #0
 sta charx+1
 lda #topline
 sta chary
 rts
*-------------------------------
setmsg lda #78
 sta charx
 lda #0
 sta charx+1
 lda #msgline
 sta chary
 rts
*-------------------------------
setlist lda #firstname
 sta chary
setleftej
 lda #78
 sta charx
 lda #0
 sta charx+1
 rts
*-------------------------------
nextline lda chary
 clc
 adc #linespace
 sta chary
 rts
*-------------------------------
flipshow lda $c055
 lda PAGE
 bne :rts
 lda $c054
:rts rts

fliphide lda $c054
 lda PAGE
 bne :rts
 lda $c055
:rts rts
*-------------------------------
* print line of text

printline
 ldy #0
:loop sty ytemp
 lda (stringptr),y
 jsr print
 bmi :rts ;"braap"
 ldy ytemp
 iny
 bne :loop
:rts rts
*-------------------------------
savechrs lda charx
 sta savechr
 lda charx+1
 sta savechr+1
 lda chary
 sta savechr+2 ;save current charx/chary
 rts

retrievechrs lda savechr+2
 sta chary
 lda savechr+1
 sta charx+1
 lda savechr
 sta charx ;retrieve charx/chary
 rts
*-------------------------------
* get cancel/OK
*
* Return okcancel: 1 = OK, ff = cancel

canok
 jsr setbarok
 jsr drawbar

:loop jsr input ;get kbd or jstk cmd (in A)

 cmp #Cdown
 bne :1
 jsr bardown
 jmp :loop

:1 cmp #Cup
 bne :2
 jsr barup
 jmp :loop

:2 cmp #Cbtn0
 bne :3
 jmp select

:3 cmp #Cbtn1
 bne :4
 jmp select
:4
 jmp :loop

*-------------------------------
* Get line of input

* In: getlnptr (0=beginning)

* Out: A = okcancel = 1 (OK) or -1 (cancel)

getline
 jsr savechrs
 jsr drawbar
 jsr retrievechrs

 lda $c010

:loop jsr savechrs
 jsr ctrlbar ;while we're waiting for user to
;type in a line, he can use jstk
;or kbd to control hilite bar
 jsr retrievechrs

 lda okcancel
 bne :eol ;OK/cancel was selected

 lda $c000
 bpl :loop
 sta chartemp

 cmp #kDELETE
 beq :bkspace

 ldx getlnptr
 cpx #fnlength-1
 bcs :rtncheck

 jsr print
 bmi :rtncheck ;braap--nogood char

 ldx getlnptr
 lda chartemp
 sta getlnbuf,x
 inc getlnptr

:rtncheck lda chartemp
 cmp #$8d ;return
 bne :loop

 lda #1
 sta okcancel ;<CR> means OK

* Detected a <CR> or OK/cancel

:eol lda #$8d
 ldx getlnptr
 sta getlnbuf,x ;put <CR> at end of fname

 lda okcancel ;-1 = cancel, 1 = OK
 rts

:bkspace ldx getlnptr
 beq :loop ;buffer empty--nothing to delete

 dec getlnptr

 jsr redoline ;wipe & reprint entire line
 jmp :loop

*-------------------------------
*
*  C O N T R O L   H I L I T E   B A R
*  with jstk or kbd
*
*-------------------------------
ctrlbar
 jsr input ;get kbd or jstk cmd (in A)

 cmp #Cdown
 bne :1
 jmp bardown

:1 cmp #Cup
 bne :2
 jmp barup

:2 cmp #Cbtn0
 bne :3
 jmp select

:3 cmp #Cbtn1
 bne :4
 jmp select

:4 cmp #Cright
 bne :5
 jmp barright

:5 cmp #Cleft
 bne :6
 jmp barleft

:6
:rts rts
*-------------------------------
barleft lda barx
 beq :rts

 lda numfiles ;no files in list
 beq :rts ;--limit bar to OK/cancel

 jsr erasebar

 lda numfiles
 sec
 sbc topolist
 sbc #1 ;bary of bottommost file

 cmp bary
 bcs :ok

 sta bary ;move bar to bottommost file
:ok
 dec barx
 jmp drawbar

:rts rts
*-------------------------------
barright lda barx
 bne :rts

 jsr erasebar
 inc barx

 lda bary ;Filename column has 5 choices (bary = 0-4)
 cmp #4
 beq :can
 lda #3 ;OK/cancel column has only 2 choices:
 sta bary ;bary = 3 (OK) or 4 (cancel)
:can
 jmp drawbar

:rts rts
*-------------------------------
bardown lda barx
 beq :fn

:ok lda bary
 cmp #4
 bcc :movebar
 rts

:movebar jsr erasebar
 inc bary
 jmp drawbar

:fn lda bary
 cmp #4
 bcs :offbot

 clc
 adc topolist
 clc
 adc #1 ;# of next file
 cmp numfiles
 bcc :movebar
 rts ;no more files

* move bar off bottom

:offbot lda topolist
 clc
 adc #5 ;# of next offscreen file
 cmp numfiles
 bcs :rts ;no more files

 inc topolist

 jsr drawbar

 ldx #listwipe2
 ldy #>listwipe2
 jsr drawbox

 jsr listfiles

:rts rts
*-------------------------------
barup lda barx
 beq :fn

:ok lda bary
 cmp #4
 bcs :movebar
 rts

:movebar jsr erasebar
 dec bary
 jmp drawbar

:fn lda bary
 bne :movebar

* move bar off top

:offtop lda topolist
 beq :rts ;no more files

 dec topolist

 jsr drawbar

 ldx #listwipe1
 ldy #>listwipe1
 jsr drawbox

 jsr listfiles

:rts rts
*-------------------------------
*
*  Select what's highlighted
*
*-------------------------------
select
 lda barx
 beq selectfn ;select filename
 bne selectok ;select OK/cancel

*-------------------------------
* select filename

selectfn

* copy hilited filename into getlnbuf

 jsr setupfnwipe
 jsr copyfname

* print filename in entry field

 jsr redoline

 jmp savechrs
*-------------------------------
* select OK/cancel

selectok
 lda bary
 cmp #3
 beq :ok

:cancel lda #-1
 sta okcancel
 rts

:ok lda #1
 sta okcancel
 rts
*-------------------------------
* read filename under hilite & copy into getlnbuf
* In: stringptr

copyfname
 ldy #0
:loop lda (stringptr),y
 sta getlnbuf,y
 cmp #$8d
 beq :done

 iny
 cpy #fnameleng
 bcc :loop
 jsr gtone

:done sty getlnptr
 rts

*-------------------------------
redoline
 ldx #linewipe
 ldy #>linewipe
 jsr drawbox

 lda #getlnbuf
 sta stringptr
 lda #>getlnbuf
 sta stringptr+1

 ldx getlnptr
 lda #$8d ;return
 sta getlnbuf,x

 jsr setcursor
 jsr printline

 rts
*-------------------------------
* Draw a blank dialog box
* In: x = addr lo, y = addr hi

setupbox
 stx IMAGE
 sty IMAGE+1

 ldy #3
 lda (IMAGE),y
 sta XCO
 iny
 lda (IMAGE),y
 sta YCO
 lda #0
 sta OFFSET
 lda #2 sta
 sta OPACITY

 rts

drawbox jsr setupbox
 jmp dodblwipe

drawline jsr setupbox
 jmp dodblora

*-------------------------------
* zero directory (development routine)

ZERODIR ldy #0
 ldx maxfiles
 dex
:loop jsr getfield
 lda #$ff
 sta (stringptr),y
 dex
 bpl :loop
 rts
*-------------------------------
* erase hilite bar
* In: barx, bary

erasebar lda barx
 bne :okcan

 jmp unhilitename

:okcan jmp unhiliteok
*-------------------------------
* draw hilite bar
* In: barx, bary

drawbar lda barx
 bne :okcan

 jmp hilitename

:okcan jmp hiliteok
*-------------------------------
hilitename
 lda numfiles
 beq :rts

 jsr setupfnwipe
 jsr wipefname
 jmp printfname

:rts rts

unhilitename
 jsr setupfnwipe
 jsr unwipefname
 jmp printfname

:rts rts

setupfnwipe
 lda topolist ;filelist # of top filename in window
 clc
 adc bary
 tax ;filelist # of hilited filename
 lda filelist,x
 tax ;direcptr

 jsr getfield ;get stringptr

 ldx bary
 lda fnamey,x
 sta chary ;get screen y-cooord

 rts
*-------------------------------
hiliteok
 jsr setupokwipe
 jsr wipeok
 jmp printline

unhiliteok
 jsr setupokwipe
 jsr unwipeok
 jmp printline

setupokwipe
 lda #oky
 sta chary

 lda #okx
 sta charx
 lda #>okx
 sta charx+1

 lda bary ;0=ok, 1=cancel
 cmp #4
 beq :can

 lda #okmsg
 sta stringptr
 lda #>okmsg
 sta stringptr+1
 rts

:can jsr nextline

 lda #cancelmsg
 sta stringptr
 lda #>cancelmsg
 sta stringptr+1
 rts

*===============================
*
*
*    D   I   S   K
*
*
*-------------------------------
*
*  S A V E   L E V E L
*
*  In: level (0-n)
*
*-------------------------------
DSAVELEVEL
 jsr setlevel

 jmp savelevel ;in master

*-------------------------------
*
*  Save level to game disk
*
*-------------------------------
DSAVELEVELG
 jsr setlevelg

 jmp savelevelg ;in master

*-------------------------------
*
*  L O A D   L E V E L
*
*  In: level (0-n)
*
*-------------------------------
DLOADLEVEL
 jsr setlevel

 jmp loadlevel

*-------------------------------
* Set level (for master & data disk)

setlevel
 ldx level

 lda bluepTRKlst,x
 sta bluepTRK
 lda bluepREGlst,x
 sta bluepREG

 lda binfoTRKlst,x
 sta binfoTRK
 lda binfoREGlst,x
 sta binfoREG

 rts

*-------------------------------
* Set level (for game disk)

setlevelg
 ldx level

 lda gameTRKlst,x
 sta bluepTRK
 lda gameREGlst,x
 sta bluepREG

 rts

*-------------------------------
 lst
eof ds 1
 usr $a9,22,$00,*-org
 lst off
