* framedef
bof = $2800
 tr on ;TABS 15,20,40
 lst off
 lstdo off

*-------------------------------
 dum bof

org ds 1200
altset1 ds 200
altset2 ds 450
swordtab ds 192

 dend

*-------------------------------
 org org
Fdef

*  Fimage, Fsword, Fdx, Fdy, Fcheck

:1 db $01,0,1,0,$c0+4 ;run-4
:2 db $02,0,1,0,$40+4 ;run-5
:3 db $03,0,3,0,$40+7 ;run-6
:4 db $04,0,4,0,$40+8 ;run-7
:5 db $05,0,0,0,$c0+$20+6 ;run-8
:6 db $06,0,0,0,$40+9 ;run-9
:7 db $07,0,0,0,$40+10 ;run-10
:8 db $08,0,0,0,$c0+5 ;run-11
:9 db $09,0,0,0,$40+4 ;run-12
:10 db $0a,0,0,0,$40+7 ;run-13
:11 db $0b,0,0,0,$40+11 ;run-14
:12 db $0c,0,0,0,$40+3 ;run-15
:13 db $0d,0,0,0,$c0+3 ;run-16
:14 db $0e,0,0,0,$40+7 ;run-17
:15 db $0f,9,0,0,$40+3 ;stand
:16 db $10,0,0,0,$c0+3 ;standjump-9
:17 db $11,0,0,0,$40+4 ;standjump-10
:18 db $12,0,0,0,$40+6 ;standjump-11
:19 db $13,0,0,0,$40+8 ;standjump-12
:20 db $14,0,0,0,$80+9 ;standjump-13
:21 db $15,0,0,0,$00+11 ;standjump-14
:22 db $16,0,0,0,$80+11 ;standjump-15
:23 db $17,0,0,0,$00+17 ;standjump-16
:24 db $18,0,0,0,$00+7 ;standjump-17
:25 db $19,0,0,0,$00+5 ;standjump-18
:26 db $1a,0,0,0,$c0+1 ;standjump-19
:27 db $1b,0,0,0,$c0+6 ;standjump-20
:28 db $1c,0,0,0,$40+3 ;standjump-21
:29 db $1d,0,0,0,$40+8 ;standjump-22
:30 db $1e,0,0,0,$40+2 ;standjump-23
:31 db $1f,0,0,0,$40+2 ;standjump-24
:32 db $20,0,0,0,$c0+2 ;standjump-25
:33 db $21,0,0,0,$c0+2 ;standjump-26
:34 db $22,0,0,0,$40+3 ;runjump-1
:35 db $23,0,0,0,$40+8 ;runjump-2
:36 db $24,0,0,0,$c0+14 ;runjump-3
:37 db $25,0,0,0,$c0+1 ;runjump-4
:38 db $26,0,0,0,$40+5 ;runjump-5
:39 db $27,0,0,0,$80+14 ;runjump-6
:40 db $28,0,0,0,$00+11 ;runjump-7
:41 db $29,0,0,0,$80+11 ;runjump-8
:42 db $2a,0,0,0,$80+10 ;runjump-9
:43 db $2b,0,0,0,$00+1 ;runjump-10
:44 db $2c,0,0,0,$c0+4 ;runjump-11
:45 db $2d,0,0,0,$c0+3 ;turn-2
:46 db $2e,0,0,0,$c0+3 ;turn-3
:47 db $2f,0,0,0,$80+$20+5 ;turn-4
:48 db $30,0,0,0,$80+$20+4 ;turn-5
:49 db $31,0,0,0,$40+$20+6 ;turn-6
:50 db $32,0,4,0,$40+$20+7 ;turn-7
:51 db $33,0,3,0,$40+$20+6 ;turn-8
:52 db $34,0,1,0,$40+4 ;turn-10
:53 db $01,$40,0,0,$c0+2 ;runturn-8
:54 db $02,$40,0,0,$40+1 ;runturn-9
:55 db $03,$40,0,0,$40+2 ;runturn-10
:56 db $04,$40,0,0,$00 ;runturn-11
:57 db $05,$40,0,0,$00 ;runturn-12
:58 db $06,$40,0,0,$80 ;runturn-13
:59 db $07,$40,0,0,$00 ;runturn-14
:60 db $08,$40,0,0,$80 ;runturn-15
:61 db $09,$40,0,0,$00 ;runturn-16
:62 db $0a,$40,0,0,$80 ;runturn-17
:63 db $0b,$40,0,0,$00 ;runturn-18
:64 db $0c,$40,0,0,$00 ;runturn-19
:65 db $0d,$40,0,0,$80 ;runturn-20
:66 db 0,0,0,0,0
:67 db $11,$40,-2,0,$40+1 ;jumphang-2
:68 db $12,$40,-2,0,$40+1 ;jumphang-3
:69 db $13,$40,-1,0,$c0+2 ;jumphang-4
:70 db $14,$40,-2,0,$40+2 ;jumphang-5
:71 db $15,$40,-2,0,$40+1 ;jumphang-6
:72 db $16,$40,-2,0,$40+1 ;jumphang-7
:73 db $17,$40,-2,0,$40+1 ;jumphang-8
:74 db $18,$40,-1,0,$00+7 ;jumphang-9
:75 db $19,$40,-1,0,$00+5 ;jumphang-10
:76 db $1a,$40,2,0,$00+7 ;jumphang-11
:77 db $1b,$40,2,0,$00+7 ;jumphang-12
:78 db $1c,$40,2,-3,$00 ;jumphang-13
:79 db $1d,$40,2,-10,$00 ;jumphang-14
:80 db $1e,$40,2,-11,$80 ;jumphang-15
:81 db $1f,$40,3,-2,$40+3 ;hangdrop-4
:82 db $20,$40,3,0,$c0+3 ;hangdrop-5
:83 db $21,$40,3,0,$c0+3 ;hangdrop-6
:84 db $22,$40,3,0,$40+$20+3 ;hangdrop-7
:85 db $23,$40,4,0,$c0+$20+3 ;hangdrop-8
:86 db $1d,0,0,0,$00  ;test w/foot
:87 db $25,$40,7,-14,$80 ;jumphang-22
:88 db $26,$40,7,-12,$80 ;jumphang-23
:89 db $27,$40,4,-12,$00 ;jumphang-24
:90 db $28,$40,3,-10,$80 ;jumphang-25
:91 db $29,$40,2,-10,$80 ;jumphang-26
:92 db $2a,$40,1,-10,$80 ;jumphang-27
:93 db $2b,$40,0,-11,$00 ;jumphang-28
:94 db $2c,$40,-1,-12,$00 ;jumphang-29
:95 db $2d,$40,-1,-14,$00 ;jumphang-30
:96 db $2e,$40,-1,-14,$00 ;jumphang-31
:97 db $2f,$40,-1,-15,$80 ;jumphang-32
:98 db $30,$40,-1,-15,$80 ;jumphang-33
:99 db $31,$40,0,-15,$00 ;jumphang-34
:100 db 0,0,0,0,0
:101 db 0,0,0,0,0
:102 db $32,$40,0,0,$c0+6 ;jumpfall-2
:103 db $33,$40,0,0,$40+6 ;jumpfall-3
:104 db $34,$40,0,0,$c0+5 ;jumpfall-4
:105 db $35,$40,0,0,$40+5 ;jumpfall-5
:106 db $36,$40,0,0,$c0+2 ;jumpfall-6
:107 db $37,$40,0,0,$c0+4 ;jumpfall-7
:108 db $38,$40,0,0,$c0+5 ;jumpfall-8
:109 db $39,$40,0,0,$40+6 ;jumpfall-9
:110 db $3a,$40,0,0,$40+7 ;jumpfall-10
:111 db $3b,$40,0,0,$40+7 ;jumpfall-11
:112 db $3c,$40,0,0,$40+9 ;jumpfall-12
:113 db $3d,$40,0,0,$c0+8 ;jumpfall-13
:114 db $3e,$40,0,0,$c0+9 ;jumpfall-14
:115 db $3f,$40,0,0,$40+9 ;jumpfall-15
:116 db $40,$40,0,0,$40+5 ;jumpfall-16
:117 db $41,$40,2,0,$40+5 ;jumpfall-17
:118 db $42,$40,2,0,$c0+5 ;jumpfall-18
:119 db $43,$40,0,0,$c0+3 ;jumpfall-19
:120 db 0,0,0,0,0
:121 db $01,$80,0,0,$40+3 ;stepfwd-1
:122 db $02,$80,0,0,$c0+4 ;stepfwd-2
:123 db $03,$80,0,0,$c0+5 ;stepfwd-3
:124 db $04,$80,0,0,$40+8 ;stepfwd-4
:125 db $05,$80,0,0,$40+$20+12 ;stepfwd-5
:126 db $06,$80,0,0,$c0+$20+15 ;stepfwd-6
:127 db $07,$80,0,0,$40+$20+3 ;stepfwd-7
:128 db $08,$80,0,0,$c0+3 ;stepfwd-8
:129 db $09,$80,0,0,$40+3 ;stepfwd-9
:130 db $0a,$80,0,0,$40+3 ;stepfwd-10
:131 db $0b,$80,0,0,$40+4 ;stepfwd-11
:132 db $0c,$80,0,0,$40+4 ;stepfwd-12
:133 db $3e,$80,00,1,$c0+1 ;sheathe34
:134 db $3f,$80,00,1,$c0+7 ;sheathe37
:135 db $0d,$80,-5+5,51-63,$00+1 ;climbup-int1
:136 db $0e,$80,-5+5,42-63,$00 ;climbup-int2
:137 db $0f,$80,-4+5,37-63,$80 ;climbup-8
:138 db $10,$80,-1+5,31-63,$80 ;climbup-10
:139 db $11,$80,1+5,27-63,$80+1 ;climbup-14
:140 db $12,$80,2+5,22-63,$80+2 ;climbup-16
:141 db $13,$80,2,17,$40+2 ;climbup-22
:142 db $14,$80,4,9,$c0+4 ;climbup-28
:143 db $15,$80,4,5,$c0+9 ;climbup-30
:144 db $16,$80,4,4,$c0+8 ;climbup-32
:145 db $17,$80,5,0,$40+$20+9 ;climbup-34
:146 db $18,$80,5,0,$c0+$20+9 ;climbup-35
:147 db $19,$80,5,0,$c0+$20+8 ;climbup-36
:148 db $1a,$80,5,0,$40+$20+9 ;climbup-37
:149 db $1b,$80,5,0,$40+$20+9 ;climbup-38
:150 db $8b,16,0,2,$80 ;missed block
:151 db $81,26,0,2,$80
:152 db $82,18,3,2,$00 ;guy4/rob20
:153 db $83,22,7,2,$c0+4
:154 db $84,21,10,2,$00 ;full ext.
:155 db $85,23,7,2,$80 ;guy-7
:156 db $86,25,4,2,$80 ;guy-8
:157 db $87,24,0,2,$c0+14 ;guy-9
:158 db $88,15,0,2,$c0+13 ;guy10/rob15 (ready)
:159 db $89,20,3,2,$00 ;guy19/rob22
:160 db $8a,31,3,2,$00 ;guy20/rob23
:161 db $8b,16,0,2,$80 ;guy21/rob18 (blocking)
:162 db $8c,17,0,2,$80 ;guy22/rob19 (block-to-strike)
:163 db $8d,32,0,2,$00 ;guy-31 (advance)
:164 db $8e,33,0,2,$80 ;guy-32
:165 db $8f,34,2,2,$c0+3 ;guy-33
:166 db $0f,0,0,0,$40+3 ;stand
:167 db $91,19,7,2,$80 ;guy18/rob21 (blocked)
:168 db $92,14,1,2,$80 ;pre-strike
:169 db $93,27,0,2,$80 ;rob17 (begin block)
:170 db $88,15,0,2,$c0+13 ;guy10/rob15 (ready)
:171 db $88,15,0,2,$c0+13 ;guy10/rob15 (ready)
:172 db $32,$40+43,0,0,$c0+6 ;jumpfall-2
:173 db $33,$40+44,0,0,$40+6 ;jumpfall-3
:174 db $34,$40+45,0,0,$c0+5 ;jumpfall-4
:175 db $35,$40+46,0,0,$40+5 ;jumpfall-5
:176 db $34,$40,0,0,$c0+5
:177 db $0f,$40,0,3,$80+10 ;impaled
:178 db $0e,$40,4,3,$80+7 ;halves
:179 db $a8,0,0,1,$40+4 ;collapse15
:180 db $a9,0,0,1,$40+4 ;collapse16
:181 db $aa,0,0,1,$40+4 ;collapse17
:182 db $ab,0,0,1,$40+7 ;collapse18
:183 db $ac,0,0,7,$40+11 ;collapse19
:184 db 0,0,0,0,0
:185 db $10,$40,4,7,$40+9 ;dead
:186 db $44,$40,0,0,$40+4 ;mouse-1
:187 db $45,$40,0,0,$40+4 ;mouse-2
:188 db $46,$40,0,2,$40+4 ;mouse crouch
:189 db 0,0,0,0,0
:190 db 0,0,0,0,0
:191 db $94,0,0,0,$00 ;drink4
:192 db $95,0,0,1,$00 ;drink5
:193 db $96,0,0,0,$80 ;drink6
:194 db $97,0,0,0,$00 ;drink7
:195 db $98,0,-1,0,$00 ;drink8
:196 db $99,0,-1,0,$00 ;drink9
:197 db $9a,0,-1,0,$00 ;drink10
:198 db $9b,0,-4,0,$00 ;drink11
:199 db $9c,0,-4,0,$80 ;drink12
:200 db $9d,0,-4,0,$00 ;drink13
:201 db $9e,0,-4,0,$00 ;drink14
:202 db $9f,0,-4,0,$00 ;drink15
:203 db $a0,0,-4,0,$00 ;drink16
:204 db $a1,0,-5,0,$00 ;drink17
:205 db $a2,0,-5,0,$00 ;drink18
:206 db $a3,0,0,0,0 ;unused
:207 db $a4,0,0,1,$40+6 ;draw5
:208 db $a5,0,0,1,$c0+6 ;draw6
:209 db $a6,0,0,1,$c0+8 ;draw7
:210 db $a7,0,0,1,$40+10 ;draw8
:211 db 0,0,0,0,$00
:212 db 0,0,0,0,$00
:213 db 0,0,0,0,$00
:214 db 0,0,0,0,$00
:215 db 0,0,0,0,$00
:216 db 0,0,0,0,$00
:217 db $35,0,0,0,$80 ;climbst2
:218 db $36,0,0,0,$00 ;climbst3
:219 db $37,0,0,0,$00 ;climbst4
:220 db $38,0,0,0,$00 ;climbst5
:221 db $39,0,0,0,$80 ;climbst6
:222 db $3a,0,0,0,$00 ;climbst7
:223 db $3b,0,0,0,$00 ;climbst8
:224 db $3c,0,0,0,$00 ;climbst9
:225 db $3d,0,0,0,$80 ;climbst10
:226 db $3e,0,0,0,$00 ;climbst11
:227 db $3f,0,0,0,$80 ;climbst12
:228 db $40,0,0,0,$00 ;climbst13
:229 db $32,$80+35,1,1,$c0+3 ;sheathe22
:230 db $33,$80+36,0,1,$40+9 ;sheathe23
:231 db $34,$80+37,0,1,$c0+3 ;sheathe24
:232 db $35,$80+38,0,1,$40+9 ;sheathe25
:233 db $36,$80+39,0,1,$c0+3 ;sheathe26
:234 db $37,$80+40,1,1,$40+9 ;sheathe27
:235 db $38,$80+41,1,1,$40+3 ;sheathe28
:236 db $39,$80+42,1,1,$c0+9 ;sheathe29
:237 db $3a,$80,4,1,$c0+6 ;sheathe30
:238 db $3b,$80,3,1,$c0+10 ;sheathe31
:239 db $3c,$80,1,1,$40+3 ;sheathe32
:240 db $3d,$80,1,1,$c0+8 ;sheathe33 (-->133)

*-------------------------------
*
*  Alternate character set 1 (chtable4)
*
*  200 bytes allocated -- 40 frames (150-189)
*
*  Frame def list shows kid, sword in RIGHT hand
*  Altset1 shows enemy, sword in LEFT hand (to be mirrored)
*  (Image tables always show character facing LEFT)
*
*-------------------------------
 ds altset1-*

ALTSET1

:150 db $0b,$c0+13,2,1,$00 ;missed block
:151 db $01,$c0+1,3,1,$00 ;guy-3
:152 db $02,$c0+2,4,1,$00 ;guy-4
:153 db $03,$c0+3,7,1,$40+4 ;guy-5
:154 db $04,$c0+4,10,1,$00 ;guy-6 (full ext)
:155 db $05,$c0+5,7,1,$80 ;guy-7
:156 db $06,$c0+6,4,1,$80 ;guy-8
:157 db $07,$c0+7,0,1,$80 ;guy-9
:158 db $08,$c0+8,0,1,$c0+13 ;guy-10 (ready)
:159 db $09,$c0+11,7,1,$80 ;guy-19
:160 db $0a,$c0+12,3,1,$00 ;guy-20
:161 db $0b,$c0+13,2,1,$00 ;guy-21 (blocking)
:162 db $0c,$c0,2,1,$00 ;guy-22
:163 db $0d,$c0+28,0,1,$00 ;guy-31 (advance)
:164 db $0e,$c0+29,0,1,$80 ;guy-32
:165 db $0f,$c0+30,2,1,$c0+3 ;guy-33
:166 db $10,$c0+9,-1,1,$40+8 ;alertstand
:167 db $11,$c0+10,7,1,$80 ;guy-18 (blocked)
:168 db $12,$c0+14,3,1,$80 ;guy-15
:169 db $08,$c0+8,0,1,$80 ;?? (ready-->block)
:170 db $13,$c0+8,0,1,$c0+13 ;guy-11/12 (ready)
:171 db $14,$c0+8,0,1,$c0+13 ;guy-13/14 (ready)
:172 db $15,$c0+47,0,0,$c0+6 ;jumpfall-2 (stabbed)
:173 db $16,$c0+48,0,0,$40+6 ;jumpfall-3
:174 db $17,$c0+49,0,0,$c0+5 ;jumpfall-4
:175 db $17,$c0+49,0,0,$c0+5 ;for jumpfall-5
:176 db $17,$c0+49,0,0,$c0+5 ;for jumpfall-6
:177 db $19,$c0,0,3,$80+10 ;impaled
:178 db $1a,$c0,4,4,$80+7 ;halves
:179 db $1b,$c0,-2,1,$40+4 ;collapse15
:180 db $1c,$c0,-2,1,$40+4 ;collapse16
:181 db $1d,$c0,-2,1,$40+4 ;collapse17
:182 db $1e,$c0,-2,2,$40+7 ;collapse18
:183 db $1f,$c0,-2,2,$40+10 ;collapse19
:184 db 0,0,0,0,0
:185 db $20,$c0,3,4,$c0+9 ;dead
:186 db 0,0,0,0,0
:187 db 0,0,0,0,0
:188 db 0,0,0,0,0
:189 db 0,0,0,0,0

*-------------------------------
*
*  Alternate character set 2 (chtable6)
*
*  (450 bytes allocated -- 90 frames)
*
*-------------------------------
 ds altset2-*

ALTSET2

:1 db $8a,$40,0,0,$00 ;pslump-1
:2 db $9a,$40,0,0,$80 ;pturn-4
:3 db $9b,$40,0,0,$80 ;pturn-5
:4 db $9c,$40,0,0,$80 ;pturn-6
:5 db $9d,$40,-1,0,$00 ;pturn-7
:6 db $9e,$40,2,0,$80 ;pturn-8
:7 db $9f,$40,2,0,$00 ;pturn-9
:8 db $a0,$40,0,0,$80 ;pturn-10
:9 db $a1,$40,1,0,$80 ;pturn-11
:10 db $a2,$40,2,0,$80 ;unused
:11 db $99,$40,0,0,$80 ;pturn-15 (stand)
:12 db $a3,$40,0,0,$80 ;pback-3
:13 db $a4,$40,0,0,$00 ;pback-5
:14 db $a5,$40,0,0,$80 ;pback-7
:15 db $a6,$40,0,0,$80 ;pback-9
:16 db $a7,$40,0,0,$80 ;pback-11
:17 db $a8,$40,0,0,$00 ;pback-13 (stand)
:18 db $8b,$40,0,0,$00 ;pslump-1
:19 db $a9,$40,0,0,$00 ;plie
:20 db $ad,$40,0,0,$00 ;embrace-1
:21 db $ae,$40,0,0,$00 ;embrace-2
:22 db $af,$40,0,0,$80 ;embrace-3
:23 db $b0,$40,0,0,$00 ;embrace-4
:24 db $b1,$40,0,0,$80 ;embrace-5
:25 db $b2,$40,0,0,$80 ;embrace-6
:26 db $b3,$40,0,0,$00 ;embrace-7
:27 db $b4,$40,0,0,$00 ;embrace-8
:28 db $b5,$40,0,0,$00 ;embrace-9
:29 db $b6,$40,0,0,$00 ;embrace-10
:30 db $b7,$40,0,0,$00 ;embrace-11
:31 db $b8,$40,0,0,$00 ;embrace-12
:32 db $b9,$40,0,0,$00 ;embrace-13
:33 db $ba,$40,0,0,$00 ;embrace-14
:34 db $bb,$40,0,0,$00 ;prise-1
:35 db $bc,$40,0,0,$00 ;prise-2
:36 db $bd,$40,0,0,$00 ;prise-3
:37 db $be,$40,0,0,$00 ;prise-4
:38 db $bf,$40,0,0,$80 ;prise-5
:39 db $bf,$40,0,0,$80 ;prise-6
:40 db $c1,$40,1,0,$00 ;prise-7
:41 db $c2,$40,-1,0,$00 ;prise-8
:42 db $c3,$40,2,0,$00 ;prise-9
:43 db $c4,$40,1,0,$80 ;prise-10
:44 db $c5,$40,0,0,$80 ;prise-11
:45 db $c6,$40,0,0,$80 ;prise-12
:46 db $c7,$40,0,0,$80 ;prise-13
:47 db $c8,$40,-1,0,$00 ;prise-14
:48 db $ca,$40,0,0,$80 ;vwalk-8
:49 db $cb,$40,0,0,$80 ;vwalk-9
:50 db $cc,$40,0,0,$80 ;vwalk-10
:51 db $cd,$40,0,0,$00 ;vwalk-11
:52 db $ce,$40,0,0,$00 ;vwalk-12
:53 db $cf,$40,0,0,$80 ;vwalk-13
:54 db $d0,$40,0,0,$80 ;vstand-3
:55 db $d1,$40,0,0,$80 ;vstand-2
:56 db $d2,$40,0,0,$80 ;vstand-1
:57 db $d3,$40,0,0,$80 ;vturn-5
:58 db $d4,$40,0,0,$80 ;vturn-6
:59 db $d5,$40,0,0,$80 ;vturn-7
:60 db $d6,$40,0,0,$80 ;vturn-8
:61 db $d7,$40,0,0,$00 ;vturn-9
:62 db $d8,$40,0,0,$80 ;vturn-10
:63 db $d9,$40,0,0,$00 ;vturn-11
:64 db $da,$40,0,0,$00 ;vturn-12
:65 db $db,$40,0,0,$80 ;vturn-13
:66 db $dc,$40,0,0,$00 ;vturn-14
:67 db $dd,$40,3,0,$00 ;vcast-2
:68 db $de,$40,3,0,$00 ;vcast-3
:69 db $df,$40,3,0,$00 ;vcast-4
:70 db $e0,$40,2,0,$00 ;vcast-5
:71 db $e1,$40,3,0,$80 ;vcast-6
:72 db $e2,$40,5,0,$00 ;vcast-7
:73 db $e3,$40,5,0,$00 ;vcast-8
:74 db $e4,$40,1,0,$80 ;vcast-9
:75 db $e5,$40,2,0,$80 ;vcast-10
:76 db $e6,$40,2,0,$80 ;vcast-11 (held)
:77 db $e7,$40,1,0,$80 ;vcast-13
:78 db $81,$80,1,0,$00 ;vcast-14
:79 db $82,$80,2,0,$00 ;vcast-15
:80 db $83,$80,3,0,$00 ;vcast-16
:81 db $84,$80,3,0,$00 ;vcast-17
:82 db $85,$80,0,0,$80 ;vcast-18
:83 db $86,$80,2,0,$80 ;vcast-10a
:84 db $87,$80,2,0,$80 ;vcast-10b
:85 db $88,$80,1,0,$00 ;vcast-1


*-------------------------------
*
*  S W O R D   T A B L E
*
*  (192 bytes allocated -- 64 swords)
*
*  Sword images are taken from chtable3
*
*-------------------------------
 ds swordtab-*

SWORDTAB

* (Image, DX, DY)

:1 db $1d,0,-9
:2 db $22,-9,-29
:3 db $1e,7,-25
:4 db $1f,17,-26
:5 db $23,7,-14
:6 db $24,0,-5
:7 db $20,17,-16
:8 db $21,16,-19
:9 db $4b,12,-9 ;alertstand
:10 db $26,13,-34
:11 db $27,7,-25
:12 db $28,10,-16
:13 db $29,10,-11
:14 db $2a,22,-21
:15 db $2b,28,-23
:16 db $2c,13,-35
:17 db $2d,0,-38
:18 db $2e,0,-29
:19 db $2f,21,-19
:20 db $30,14,-23
:21 db $31,21,-22
:22 db $31,22,-23
:23 db $2f,7,-13
:24 db $2f,15,-18 ;$20,17,-19 for flash
:25 db $24,0,-8
:26 db $1e,7,-27
:27 db $48,14,-28
:28 db $26,7,-27
:29 db $21,6,-23
:30 db $21,9,-21
:31 db $28,11,-18
:32 db $2b,24,-23
:33 db $2b,19,-23
:34 db $2b,21,-23
;sheathing
:35 db $40,7,-32
:36 db $41,14,-32
:37 db $42,14,-31
:38 db $43,14,-29
:39 db $44,28,-28
:40 db $45,28,-28
:41 db $46,21,-25
:42 db $47,14,-22

:43 db 0,14,-25 ;43-46: kid stabbed
:44 db 0,21,-25
:45 db $4a,0,-16
:46 db $26,8,-37
:47 db $4c,14,-24 ;47-50: enemy stabbed
:48 db $4d,14,-24
:49 db $4e,7,-14
:50 db $26,8,-37

*-------------------------------
 lst
 ds 1
 usr $a9,15,$00,*-org
 lst off
