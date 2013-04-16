* purple (put this file!!!)

* This code sets $DA in aux mem to 1
* if signature is found on track zero.

PURPrun = $6321

PURPLE
 ldy #PURPrun
 lda #>PURPrun

 jsr PURPsub
 jsr PURPjmp

* Note: first byte of next junk must be $60 (rts)
*-------------------------------------------------

PURPcode
 hex 60386018EAA8E7108849450040994825
 hex FB10C08CBD48852AFB10C08CBD498500
 hex A9E7D096C9FB10C08CBD03A0F2D0AAC9
 hex FB10C08CBDEAF0D0D5C9FB10C08CBD3D
 hex F048E604D0C84884FDA060F1D00DE0E8
 hex 62549D409440B56254BC00A2E7FCEEE7
 hex FCEEEEFC63384C0BF044C66018BFFB9D
 hex CD952ABFFC9D00A963BE2063AF4C0330
 hex F4108805D046D1FB10C08CBD07A0F4D0
 hex EEC914F088FB10C08CBD062410A0C08D
 hex BD23D0E7C9FB10C08CBD2CD0E7C9FB10
 hex C08CBDF4D0E7C939F088FB10C08CBD00
 hex A0F4D0D5C947F088FB10C08CBD00A0F1
 hex D007C941A557B063D0205CF045C64585
 hex 80A9478563A94685B6A9C08EBDC089BD
 hex FDA644850AA963BE20

*-------------------------------------------------

PURPlen = *-PURPcode

* Routine to decode code

 hex 20

PURPsub
 sty 4
 sta 5

 ldy #0

 ldx #PURPlen
:0 dex
 lda PURPcode,x
 sta (4),y
 iny
 bne :0

 rts

 hex 2c

PURPjmp jmp (4)

*------------------------------------------------- EOF
