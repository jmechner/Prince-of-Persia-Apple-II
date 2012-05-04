* hrtableq

 lst off

HRTABLES dum $8400

YLO ds $C0
YHI ds $C0

SHIFT0 ds $80
SHIFT1 ds $80
SHIFT2 ds $80
SHIFT3 ds $80
SHIFT4 ds $80
SHIFT5 ds $80
SHIFT6 ds $80

CARRY0 ds $80
CARRY1 ds $80
CARRY2 ds $80
CARRY3 ds $80
CARRY4 ds $80
CARRY5 ds $80
CARRY6 ds $80

MIRROR ds $80

SHIFTL dfb #SHIFT0-$80
DSHIFTL dfb #SHIFT0
 dfb #SHIFT1
 dfb #SHIFT2
 dfb #SHIFT3
 dfb #SHIFT4
 dfb #SHIFT5
 dfb #SHIFT6

SHIFTH dfb /SHIFT0-$80
DSHIFTH dfb /SHIFT0
 dfb /SHIFT1
 dfb /SHIFT2
 dfb /SHIFT3
 dfb /SHIFT4
 dfb /SHIFT5
 dfb /SHIFT6

CARRYL dfb #CARRY0-$80
DCARRYL dfb #CARRY0
 dfb #CARRY1
 dfb #CARRY2
 dfb #CARRY3
 dfb #CARRY4
 dfb #CARRY5
 dfb #CARRY6

CARRYH dfb /CARRY0-$80
DCARRYH dfb /CARRY0
 dfb /CARRY1
 dfb /CARRY2
 dfb /CARRY3
 dfb /CARRY4
 dfb /CARRY5
 dfb /CARRY6

AMASKS dfb %10000000
 dfb %10000001
 dfb %10000011
 dfb %10000111
 dfb %10001111
 dfb %10011111
 dfb %10111111

BMASKS dfb %11111111
 dfb %11111110
 dfb %11111100
 dfb %11111000
 dfb %11110000
 dfb %11100000
 dfb %11000000

OPCODE dfb $31 ;and (oper),Y
 dfb $11 ;ora
 dfb $91 ;sta
 dfb $51 ;eor

 dend
