* ed/textset
org = $d800
 lst off
*-------------------------------
* Text Set Shapes
* courtesy of Robert Cook 1/7/88
*-------------------------------
 org org

 dfb datastart-tabstart/2-1

tabstart
 dw Space
 dw ExcPoint
 dw DblQuote
 dw PoundSign
 dw DollarSign
 dw PercentSgn
 dw Ampersand
 dw Apostrophe
 dw LeftPar
 dw RightPar
 dw Asterisk
 dw PlusSign
 dw Comma
 dw MinusSign
 dw Period
 dw Slash
 dw Char0
 dw Char1
 dw Char2
 dw Char3
 dw Char4
 dw Char5
 dw Char6
 dw Char7
 dw Char8
 dw Char9
 dw Colon
 dw SemiColon
 dw LeftCaret
 dw EqualSign
 dw RightCaret
 dw Question
 dw AtSign
 dw CharA
 dw CharB
 dw CharC
 dw CharD
 dw CharE
 dw CharF
 dw CharG
 dw CharH
 dw CharI
 dw CharJ
 dw CharK
 dw CharL
 dw CharM
 dw CharN
 dw CharO
 dw CharP
 dw CharQ
 dw CharR
 dw CharS
 dw CharT
 dw CharU
 dw CharV
 dw CharW
 dw CharX
 dw CharY
 dw CharZ
 dw LeftBkt
 dw BackSlash
 dw RightBkt
 dw PowerSign
 dw UnderLine
 dw Accent
 dw CharLcA
 dw CharLcB
 dw CharLcC
 dw CharLcD
 dw CharLcE
 dw CharLcF
 dw CharLcG
 dw CharLcH
 dw CharLcI
 dw CharLcJ
 dw CharLcK
 dw CharLcL
 dw CharLcM
 dw CharLcN
 dw CharLcO
 dw CharLcP
 dw CharLcQ
 dw CharLcR
 dw CharLcS
 dw CharLcT
 dw CharLcU
 dw CharLcV
 dw CharLcW
 dw CharLcX
 dw CharLcY
 dw CharLcZ

*-------------------------------
* Data format:
*   Width (hi nibble = bytes, lo nibble = bits)
*   Space above character (in lines)
*   Shape data (width, height, bytes)
*-------------------------------
datastart

Space hex 0400
 hex 0101
 hex 00

ExcPoint hex 0300
 hex 0207
 hex 1C1C1C1C1C001C
 hex 00000000000000

DblQuote hex 1100
 hex 0203
 hex 1C1C1C
 hex 070707

PoundSign hex 2301
 hex 0306
 hex 407C60607E70
 hex 637F71717F38
 hex 010F00000700

DollarSign hex 1500
 hex 0307
 hex 00781C78007800
 hex 033F033F733F03
 hex 00000000000000

PercentSgn hex     1600
      hex     0307
          hex     3C663C40607038
           hex     1C0E07033D663C
           hex     00000000000000

Ampersand  hex     1400
           hex     0307
           hex     781C1C781C1C78
           hex     070E0000381C0F
           hex     00000000000000

Apostrophe hex     0300
           hex     0203
           hex     1C1C1C
           hex     000000

LeftPar    hex     0500
           hex     0207
           hex     70381C1C1C3870
           hex     00000000000000

RightPar   hex     0500
           hex     0207
           hex     1C38707070381C
           hex     00000000000000

Asterisk   hex     1401
           hex     0305
           hex     404C704C40
           hex     03330F3303
           hex     0000000000

PlusSign   hex     1201
           hex     0205
           hex     60607C6060
           hex     01010F0101

Comma      hex     0405
           hex     0204
           hex     1C1C180E
           hex     00000000

MinusSign  hex     1103
           hex     0201
           hex     7C
           hex     07

Period     hex     0305
           hex     0202
           hex     1C1C
           hex     0000

Slash      hex     1200
           hex     0207
           hex     0000406070381C
           hex     0E070301000000

Char0      hex     1200
           hex     0207
           hex     70381C1C1C3870
           hex     03070E0E0E0703

Char1      hex     0500
           hex     0207
           hex     707C7070707070
           hex     00000000000000

Char2      hex     1100
           hex     0207
           hex     780C0060381C7C
           hex     03070701000007

Char3      hex     1100
           hex     0207
           hex     7C004070000C78
           hex     07030103070703

Char4      hex     1400
           hex     0207
           hex     406070381C7C00
           hex     0F0F0E0E0E1F0E

Char5      hex     1100
           hex     0207
           hex     7C1C1C7C000C78
           hex     07000003070703

Char6      hex     1200
           hex     0207
           hex     70381C7C1C1C78
           hex     070000070E0E07

Char7      hex     1100
           hex     0207
           hex     7C000040606060
           hex     07070703010101

Char8      hex     1200
           hex     0207
           hex     781C1C781C1C78
           hex     070E0E070E0E07

Char9      hex     1200
           hex     0207
           hex     781C1C78000078
           hex     070E0E0F0E0703

Colon      hex     0301
           hex     0205
           hex     3838003838
           hex     0000000000

SemiColon  hex     0401
           hex     0207
           hex     3838003838301C
           hex     00000000000000

LeftCaret  hex     1001
           hex     0205
           hex     40701C7040
           hex     0300000003

EqualSign  hex     1102
           hex     0203
           hex     7C007C
           hex     070007

RightCaret hex     1001
           hex     0205
           hex     1C7040701C
           hex     0000030000

Question   hex     1200
           hex     0207
           hex     781C0060600060
           hex     070E0701010001

AtSign     hex     2300
           hex     0308
           hex     60381C1C1C1C3860
           hex     7F007E73735E007F
           hex     030E1C1C1C070003

CharA      hex     1200
           hex     0207
           hex     781C1C7C1C1C1C
           hex     070E0E0F0E0E0E

CharB      hex     1200
           hex     0207
           hex     7C1C1C7C1C1C7C
           hex     070E0E030E0E07

CharC      hex     1200
           hex     0207
           hex     781C1C1C1C1C78
           hex     070E0000000E07

CharD      hex     1200
           hex     0207
           hex     7C1C1C1C1C1C7C
           hex     070E0E0E0E0E07

CharE      hex     1100
           hex     0207
           hex     7C1C1C7C1C1C7C
           hex     07000001000007

CharF      hex     1100
           hex     0207
           hex     7C1C1C7C1C1C1C
           hex     07000001000000

CharG      hex     1200
           hex     0207
           hex     781C1C1C1C1C78
           hex     070E000F0E0E07

CharH      hex     1200
           hex     0207
           hex     1C1C1C7C1C1C1C
           hex     0E0E0E0F0E0E0E

CharI      hex     0300
           hex     0207
           hex     1C1C1C1C1C1C1C
           hex     00000000000000

CharJ      hex     1200
           hex     0207
           hex     000000001C1C78
           hex     0E0E0E0E0E0E07

CharK      hex     1300
           hex     0207
           hex     1C1C1C7C1C1C1C
           hex     1C0E0703070E1C

CharL      hex     1100
           hex     0207
           hex     1C1C1C1C1C1C7C
           hex     00000000000007

CharM      hex     1600
           hex     0307
           hex     3C7C7C5C1C1C1C
           hex     70787D6F676060
           hex     01010101010101

CharN      hex     1400
           hex     0307
           hex     3C7C7C5C1C1C1C
           hex     3838393B3F3E3C
           hex     00000000000000

CharO      hex     1200
           hex     0207
           hex     781C1C1C1C1C78
           hex     070E0E0E0E0E07

CharP      hex     1200
           hex     0207
           hex     7C1C1C7C1C1C1C
           hex     070E0E07000000

CharQ      hex     1200
           hex     0208
           hex     781C1C1C1C1C7800
           hex     070E0E0E0E0E030F

CharR      hex     1200
           hex     0207
           hex     7C1C1C7C1C1C1C
           hex     070E0E030E0E0E

CharS      hex     1200
           hex     0207
           hex     781C3C70001C78
           hex     070E00030F0E07

CharT      hex     1200
           hex     0207
           hex     7C606060606060
           hex     0F010101010101

CharU      hex     1200
           hex     0207
           hex     1C1C1C1C1C1C70
           hex     0E0E0E0E0E0E03

CharV      hex     1200
           hex     0207
           hex     1C1C1C1C1C5C7C
           hex     0E0E0E0E070301

CharW      hex     2100
           hex     0307
           hex     1C1C1C1C1C1C7C
           hex     0E0E0E0E0E4E7F
           hex     07070707070300

CharX      hex     1200
           hex     0207
           hex     1C1C1C701C1C1C
           hex     0E0E0E030E0E0E

CharY      hex     1200
           hex     0207
           hex     1C1C1C78606060
           hex     0E0E0E07010101

CharZ      hex     1200
           hex     0207
           hex     7C000060381C7C
           hex     0F0E070100000F

LeftBkt    hex     1000
           hex     0207
           hex     7C1C1C1C1C1C7C
           hex     03000000000003

BackSlash  hex     1200
           hex     0207
           hex     1C387060400000
           hex     0000000103070E

RightBkt   hex     1000
           hex     0207
           hex     7C40404040407C
           hex     03030303030303

PowerSign  hex     1300
           hex     0203
           hex     40701C
           hex     01071C

UnderLine  hex     1506
           hex     0201
           hex     7F
           hex     1F

Accent     hex     0500
           hex     0203
           hex     70381C
           hex     000000

CharLcA    hex     1202
           hex     0205
           hex     7800781C78
           hex     070E0F0E0F

CharLcB    hex     1200
           hex     0207
           hex     1C1C7C1C1C1C7C
           hex     0000070E0E0E07

CharLcC    hex     1202
           hex     0205
           hex     781C1C1C78
           hex     070E000E07

CharLcD    hex     1200
           hex     0207
           hex     0000781C1C1C78
           hex     0E0E0F0E0E0E0F

CharLcE    hex     1202
           hex     0205
           hex     781C7C1C78
           hex     070E0F0007

CharLcF    hex     1100
           hex     0207
           hex     60707C70707070
           hex     07000300000000

CharLcG    hex     1202
           hex     0207
           hex     781C1C1C780078
           hex     0F0E0E0E0F0E07

CharLcH    hex     1200
           hex     0207
           hex     1C1C7C1C1C1C1C
           hex     0000070E0E0E0E

CharLcI    hex     0300
           hex     0207
           hex     1C001C1C1C1C1C
           hex     00000000000000

CharLcJ    hex     0600
           hex     0209
           hex     38003838383838381F
           hex     000000000000000000

CharLcK    hex     0900
           hex     0207
           hex     1C1C1C1C7C1C1C
           hex     00000E0703070E

CharLcL    hex     0300
           hex     0207
           hex     1C1C1C1C1C1C1C
           hex     00000000000000

CharLcM    hex     2102
           hex     0305
           hex     7C1C1C1C1C
           hex     7F0E0E0E0E
           hex     0307070707

CharLcN    hex     1202
           hex     0205
           hex     7C1C1C1C1C
           hex     070E0E0E0E

CharLcO    hex     1202
           hex     0205
           hex     781C1C1C78
           hex     070E0E0E07

CharLcP    hex     1202
           hex     0207
           hex     7C1C1C1C7C1C1C
           hex     070E0E0E070000

CharLcQ    hex     1202
           hex     0207
           hex     781C1C1C780000
           hex     070E0E0E0F0E0E

CharLcR    hex     1102
           hex     0205
           hex     1C7C1C1C1C
           hex     0700000000

CharLcS    hex     1102
           hex     0205
           hex     781C70007C
           hex     0300010703

CharLcT    hex     1000
           hex     0207
           hex     70707C70707060
           hex     00000300000003

CharLcU    hex     1202
           hex     0205
           hex     1C1C1C1C78
           hex     0E0E0E0E0F

CharLcV    hex     1202
           hex     0205
           hex     1C1C1C5C7C
           hex     0E0E070301

CharLcW    hex     2102
           hex     0305
           hex     1C1C1C1C7C
           hex     0E0E0E4E7F
           hex     0707070301

CharLcX    hex     1202
           hex     0205
           hex     1C1C701C1C
           hex     0E0E030E0E

CharLcY    hex     1202
           hex     0207
           hex     1C1C1C1C780078
           hex     0E0E0E0E0F0E07

CharLcZ    hex     1202
           hex     0205
           hex     7C0060387C
           hex     0F0701000F
*-------------------------------
 lst
 usr $a9,28,$800,*-org
 lst off
