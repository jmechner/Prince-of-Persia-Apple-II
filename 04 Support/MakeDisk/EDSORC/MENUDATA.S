* menudata
org = $c00
 lst off
*-------------------------------
 org org
menuType ;(BlueType)
 hex 0d,12,02,0b,06,0f,04,10,11,0e
 hex 01,00,14,14,03,13,00,00,0c,09
 hex 00,00,00,0a,0a,15,16,0c,0c,08

menuSpec  ;(BlueSpec)
 hex 00,00,00,00,00,00,02,00,02,00
 hex 00,00,00,01,00,00,02,01,01,00
 hex 00,00,00,00,00,00,00,02,00,00

menubSpec ;(bLinkIndex)
 hex 00,00,00,00,00,00,00,00,00,00
 hex 00,00,00,00,00,00,00,00,00,00
 hex 02,03,01,00,00,00,00,00,00,00

*-------------------------------
* "menubSpec" is index # of special symbol to
* appear in this space:
*
* 1 = kid
* 2 = eye
* 3 = guard
*
* "menuSpec": for gadgets, initial bluespec value
*
* 1 = "up"
* 2 = "down"
*
* for panels, panel pattern (0,1,2...)
*
*-------------------------------

REDBUF ds 30
FREDBUF ds 30
FLOORBUF ds 30
WIPEBUF ds 30
MOVEBUF ds 30
OBJBUF ds 30
WHITEBUF ds 30
TOPBUF ds 10
FTOPBUF ds 10

*-------------------------------
 lst
 usr $a9,4,$800,*-org
 lst off
