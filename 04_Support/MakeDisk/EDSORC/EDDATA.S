* eddata
 lst off
*-------------------------------
*                           5
* sizes:  1  22  333  4444  5
*
*                           1
* posns:  0  01  012  0123  0
*
* base: id # of lower-leftmost section in composite object
*
* link: ff = end, fe = requires floorpiece above, # = obj id
*
*-------------------------------
* Obj id #:     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
*              10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f

sizelist hex 01,01,01,01,01,00,01,01,05,05,01,01,01,01,01,01
 hex 02,02,01,01,01,01,01,02,02,01,01,01,02,02

baselist hex 00,01,02,03,04,00,06,07,08,08,0a,0b,0c,0d,0e,0f
 hex 10,10,12,13,14,15,16,17,17,19,1a,1b,1c,1c

posnlist hex 00,00,00,00,00,00,00,00,00,01,00,00,00,00,00,00
 hex 00,01,00,00,00,00,00,00,01,00,00,00,00,01

linklist hex ff,ff,ff,fe,ff,00,ff,fe,09,fe,ff,ff,fe,fe,ff,ff
 hex 11,ff,fe,ff,fe,ff,ff,18,ff,ff,ff,ff,1d,ff

*-------------------------------
* Linkable? 00 = no, 01 = controller, 02 = gadget

linkable hex 00,00,00,00,02,00,01,00,00,00,00,00,00,00,00,01
 hex 02,00,00,00,00,00,00,00,00,00,00,00,00,00

*-------------------------------
