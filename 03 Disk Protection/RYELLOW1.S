* Ryellow1 (put this file!!!)

* This code sets the high bit of $7C in aux mem
* if signature is found on track zero.

* NOTE: make sure the x register has a number
* greater than 4 when calling YELLOW.

YELLrun = $AAAA

YELLOW
:0 sec
 rol
 clc
 rol
 dex
 bne :0
 sta 4

 jsr YELLsub
 jmp YELLnothing

*-------------------------------------------------

YELLcode
 hex 27A26A0C5717236A8AAD0603AA8A3401
 hex 03A02F9E0C5717246A03012F9D03E92F
 hex 9C032A2F9F6C9F5AF68AF8011AFD0F9B
 hex 63AD7A5B0AAA17266ABA51225AED637F
 hex 7A5E0AAA17266ABA51225A93634D7A5E
 hex 17266ABA51634D7A8617266ABA51634D
 hex 7A8917276A0ABA8EAC17266ABA51225A
 hex BE63447A5E0AAD17266ABA517B9C7AAF
 hex 22BA5E9AA9E696018AAD06374215DCF1
 hex B2CA6C9E5AA1E66100564444564D4456
 hex 4D8AAD06374215CA0A572E92627AAE4C
 hex 925A9717266ABA51637F7A5A4017266A
 hex BA5163007A580AA917266ABA51633C7A
 hex 4D03AA2F9317266ABA51802F9217266A
 hex BA518F92339AAAEF9322BA4D0240B2CA
 hex 92CA03AE27620E6F555AFC03AA27670E
 hex 0F55276F0E9247620E5A9F1AACE3554C
 hex 553AAEC3546C5567670E3AA907670E63
 hex A61AAB02928A440113B3068A5601076F
 hex 0EB28A5A01138F068A560144670E7A6A
 hex 8A5601B20F5583A980AF5700172A6A0C
 hex 57CA08B8607A579243AB7A5CCA08AA16
 hex 0E0E1F9A3E9A370E0E424A8B7A5BCAAB
 hex 9A828E8AB4B7B6B6B6B6B6DA868C88B5
 hex B4B7B6B6B6B6B655A9

*-------------------------------------------------

YELLlen = *-YELLcode

* Routine to decode code

 hex 20 ;jsr

YELLsub sta 5
 ldy #0
:0 lda YELLcode,y
 eor 4
 sta (4),y
 inc 5
 lda YELLcode+256,y
 eor 4
 sta (4),y
 dec 5
 iny
 bne :0
 lda 4
 eor #$4C!$AA ;jmp instruction
 sta 3
 jmp 3

*-------------------------------------------------

 hex a9 ;lda #imm

YELLnothing ldy #0
 inc 5
:0 tya
:1 sta (4),y
 iny
 bne :1
 rts


*------------------------------------------------- EOF
