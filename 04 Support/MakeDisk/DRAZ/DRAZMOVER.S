* drazmover
org = $6000
 lst off
*-------------------------------
 dum $00

dest ds 2
source ds 2
endsourc ds 2

 dend
*-------------------------------
 dum org

mover ds $100

rw18buf ds $500
endrwbuf
hiresbuf ds $1000
endhrbuf
drazbuf ds $1500
enddrbuf
endfile dend
*-------------------------------
hires = $8400 ;blast18 = $9200
draz = $800
rw18 = $d000
*-------------------------------
 org org
*-------------------------------
* move rw18 to l.c.

 sta $c081 ;read ROM--write RAM

 lda #>rw18
 ldx #>rw18buf
 ldy #>endrwbuf
 jsr movemem

* move draz and hires
* Draz first!

 lda #>draz
 ldx #>drazbuf
 ldy #>enddrbuf
 jsr movemem

 lda #>hires
 ldx #>hiresbuf
 ldy #>endhrbuf
 jsr movemem

* All done

 jmp draz
*-------------------------------
movemem sta dest+1
 stx source+1
 sty endsourc+1

 ldy #0
 sty dest
 sty source
 sty endsourc

:loop lda (source),y
 sta (dest),y

 iny
 bne :loop

 inc source+1
 inc dest+1

 lda source+1
 cmp endsourc+1
 bne :loop

 rts
*-------------------------------
eof
