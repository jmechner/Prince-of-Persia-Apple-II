*-------------------------------------------------
*
* 18 sector read/write routine
*
*  Copyright 1985
*  by Roland Gustafsson
*
*  Comments and labels provided in 2013
*  by Adam Green
*
*-------------------------------------------------
        org $D000

*-------------------------------------------------
* Game code will jsr to this entry point when it
* wants to interact with RW18 contents on the
* disk.  It jumps over the core disk handling
* code and jumps to the actual RW18 entry point
* which will dispatch to the correct command
* handler.
*-------------------------------------------------
entry   jmp RW18


*-------------------------------------------------
* Zero Page Variables.
*-------------------------------------------------
        dum $00

* Don't make use of the first $e0 zero page bytes
        ds $e0-*

* Beginning of zero page area used by RW18.
* The next 16 bytes will be saved on RW18 entry
* and restore on RW18 exit so the game can use
* them as well.
zpArea  equ *

* 16-bit pointer to first page for current sector.
pg0Ptr  ds 2

* 16-bit pointer to second page for current sector.
pg1Ptr  ds 2

* 16-bit pointer to third page for current sector.
pg2Ptr  ds 2

* 16-bit pointer to page of aux bytes for current
* sector.
auxPtr  ds 2

* Actual track number read from disk.
actTrk  ds 1

* Current sector. (0 - 5)
sector  ds 1

* Retries left.
retries ds 1

* An inner retry count.  Used from within code
* which is using the above retries counter
* already.
* 
* Also used in read path to store current aux
* byte containing most significant bits of the
* 3 pages.
auxByte equ *
retrys_ ds 1

* Running XOR checksum used in write path.
chksum  ds 1

* Running XOR checksum used in read path.
chksum2 ds 1

* Temporary variable.
temp    ds 1

* RW18 command being executed.
cmd     ds 1

* Skip over unused zero page area.
        ds $fd-*

* The 3 following zero page variables can't be
* re-used by the game.  They game can set slot
* and track before calling into RW18.
        
* Slot for disk drive.  This slot index is the
* slot number shifted to the left by 4 bits to
* make it more convenient for indexing into I/O
* memory space.
slot    ds 1

* Track to be used for read/write.
track   ds 1

* Actual track where head is located (multiplied
* by 2 to account for 2 steps per track).
currTrk ds 1

        dend


*-------------------------------------------------
* This is the 6to8 encoding table.  It provides
* the same 6-bit to 8-bit encoding scheme used by
* ProDOS.  Using a 6-bit data value to index into
* this table will provide the 8-bit value that
* should be encoded on the disk.
*-------------------------------------------------
encTab  db $96,$97,$9a,$9b,$9d,$9e,$9f,$a6
        db $a7,$ab,$ac,$ad,$ae,$af,$b2,$b3
        db $b4,$b5,$b6,$b7,$b9,$ba,$bb,$bc
        db $bd,$be,$bf,$cb,$cd,$ce,$cf,$d3
        db $d6,$d7,$d9,$da,$db,$dc,$dd,$de
        db $df,$e5,$e6,$e7,$e9,$ea,$eb,$ec
        db $ed,$ee,$ef,$f2,$f3,$f4,$f5,$f6
        db $f7,$f9,$fa,$fb,$fc,$fd,$fe,$ff


*-------------------------------------------------
* Address field to be placed at beginning of
* sectors.  Sector 5 will include all of
* the following data.  Sectors 0 - 4 address
* field starts on the second line and skips the
* first 12 bytes.  The adrTrk, adrSec, and adrChk
* are filled with 6to8 encoded data representing
* the track, sector, and XOR checksum of track
* and sector values.  The sector write routine
* will stop writing the address field when the
* NULL terminator is encountered.
*-------------------------------------------------
adrFld
        db $a5,$96,$bf,$ff,$fe,$aa,$bb,$aa,$aa,$ff,$ef,$9a
        db $d5,$9d
adrTrk  db $96
adrSec  db $96
adrChk  db $96
        db $aa,$ff,$ff
        db $00


*-------------------------------------------------
* Write sector to disk.
* The sector will contain an address field and
* a data field which contains 3 pages of data
* plus an additional page of aux bytes.
*
* Note: This code is very timing sensitive so
* that is why it contains 'extra' instructions to
* eat cycles.
*
* Inputs:
*   X - Slot number for disk drive. Placed there
*       by call to zpInit.
*   Y - Number of additional SYNC bytes to write.
*   slot - Set to indicate disk drive slot.
*   adrBeg - Set to 0 for sector 5 and 12 for
*            other sectors to indicate how much
*            of adrFld should be written to disk.
*   adrTrk - 6to8 encoded track # being written.
*   adrSec - 6to8 encoded sector # being written.
*   adrChk - 6to8 checksum of adrTrk and adrSec.
*   bndId - Set to bundle id to indicate side of
*           disk ($a9 for side 1 and $ad for
*           side2).
*   auxPtr - Points to pre-filled page of aux
*            bytes.
*   pg0Ptr - Points to first page of user data.
*   pg1Ptr - Points to second page of user data.
*   pg2Ptr - Points to third page of user data.
*-------------------------------------------------
wrSect  
* Write out SYNC byte.
        lda #$ff
        sta $c08f,x
        ora $c08c,x
        rol auxByte ; delay
* Enter loop to produce additional SYNC bytes.
* Y register specifies desired count.
:1      nop ; delay
        jsr rts
        jsr rts
        sta $c08d,x
        ora $c08c,x
        dey
        bne :1
* Write out address field.  The adrTrk, adrSec,
* and adrChk bytes will already have been filled
* in before wrSect is called.  adrBeg will
* indicate if first 12 bytes of adrFld should be
* skipped or not.
adrBeg   = *+1 ; Instruction immediate value accessed.
        ldy #$00
:2      lda adrFld,y
        beq :3 ; Stop on NULL terminator.
        iny
        nop ; delays
        nop
        nop
        ldx slot
        sta $c08d,x
        ora $c08c,x
        ldx slot ; delay
        bne :2
:3      nop ; delays
        nop
        nop
        nop
* Write out bundle id.  bndId will have been set
* from earlier RW18 command.
bndId   = *+1 ; Instruction immediate value accessed.
        lda #$96
        sta $c08d,x
        ora $c08c,x
* Initialize loop index and checksum to 0.
        ldy #$00
        sty chksum
* Loop over all 256 bytes in aux, page0, page1
* and page2.
]nxtByt
* Process byte from aux page.  Load, checksum,
* encode, and write to disk.
        lda (auxPtr),y
        tax
        eor chksum
        sta chksum
        lda encTab,x
        nop ; delay
slotUp0 = *+1 ; Instruction address accessed.
        sta $c0ed
slotUp1 = *+1 ; Instruction address accessed.
        ora $c0ec
* Process byte from page0.  Load, mask off upper
* 2 bits, checksum, encode, and write to disk.
        lda (pg0Ptr),y
        and #$3f
        tax
        eor chksum
        sta chksum
        lda encTab,x
        db $ae,slot,00 ; UNDONE: ldx !$00fd
        sta $c08d,x
        ora $c08c,x
* Process byte from page1.  Load, mask off upper
* 2 bits, checksum, encode, and write to disk.
        lda (pg1Ptr),y
        and #$3f
        tax
        eor chksum
        sta chksum
        lda encTab,x
        db $ae,slot,00 ; UNDONE: ldx !$00fd
        sta $c08d,x
        ora $c08c,x
* Process byte from page2.  Load, mask off upper
* 2 bits, checksum, encode, and write to disk.
        lda (pg2Ptr),y
        and #$3f
        tax
        eor chksum
        sta chksum
        lda encTab,x
        db $ae,slot,00 ; UNDONE: ldx !$00fd
        sta $c08d,x
        ora $c08c,x
* Increment index and loop.
        iny
        bne ]nxtByt
* All data bytes have been written so now
* encode and write out checksum byte.
        ldx chksum
        lda encTab,x
        ldx slot
        jsr wrByte
* Encode and write out $d4 data field epilog.
        lda #$d4
        jsr wrByte_
* Encode and write out $ff sync byte.
        lda #$ff
        jsr wrByte_
* Tell drive that we are done writing.
        lda $c08e,x
        lda $c08c,x
        rts


*-------------------------------------------------
* Write out byte in A to disk but first insert
* some delay cycles and then fall through to
* wrByte function.
*
* Input:
*   A is encoded byte to write to disk.
* Output:
*   X is disk drive slot.
*-------------------------------------------------
wrByte_ nop ; delays
        nop
        clc ; Now fall through to wrByte


*-------------------------------------------------
* Write out byte in A to disk.
*
* Input:
*   A is encoded byte to write to disk.
* Output:
*   X is disk drive slot.
*-------------------------------------------------
wrByte  ldx slot
        sta $c08d,x
        ora $c08c,x
        rts


*-------------------------------------------------
* Write out a complete track of 6 sectors to disk.
*
* Input:
*   track - the track to be written out.
*   pages - This 18 element array should be
*           filled in with the page numbers of
*           the pages to be written.  Filled in
*           by prev call to prepPgs.
*   auxPgs - 6 pages of aux bytes pre-extracted.
*            Filled in by prev call to bldAux.
*-------------------------------------------------
wrTrack 
* Initialize zero page registers: page pointers
* and current sector = 5.  Also sets X register
* to disk drive slot number.
        jsr zpInit
* Encode current track number and store in the
* correct place in the address field.
        ldy track
        lda encTab,y
        sta adrTrk
* Loop through all 6 sectors in descending order
* (5 to 0).
:loop   
* XOR checksum track and sector number together.
* Encode the result and place in address field.
        lda sector
        eor track
        tay
        lda encTab,y
        sta adrChk
* Update pointers for page0, page1, and page2
* data to be placed on the disk for the current
* sector.
        jsr pgPtrUp ; Also sets Y to sector.
* Encode sector number and place in address
* field.
        lda encTab,y
        sta adrSec
* If sector is 5:
*   Set Y, additional SYNC bytes, to $c8
*   Set adrBeg to $00 to use full address field
* If sector is 0 - 4:
*   Set Y, additional SYNC bytes, to $04
*   Set adrBeg to $0c to use short address field
        cpy #$05
        beq :1
        lda #$0c
        ldy #$04
        bne :2
:1      lda #$00
        ldy #$c8
:2      sta adrBeg
* Flip soft-switches to prepare for writing to
* disk. X was set to slot # by earlier call to
* zpInit.
        lda $c08d,x
        lda $c08e,x
* I think these are just here to introduce a
* delay.
        sec
        bmi :rts
* Now write out this sector's data.
        jsr wrSect
* Increment to next aux page.
        inc auxPtr+1
* Decrement sector number and loop to write out
* next sector.
        dec sector
        bpl :loop
:rts    rts


*-------------------------------------------------
* Initializes the zero page registers.
*
* Output:
*   sector - Initialized to 5.
*   pg0Ptr - Initialize offset within page to 0.
*   pg1Ptr - Initialize offset within page to 0.
*   pg2Ptr - Initialize offset within page to 0.
*   auxPtr - Initialize first aux page which
*            follows the RW18 code in memory.
*   X is equal to the disk drive slot.
*-------------------------------------------------
zpInit  lda #$05
        sta sector
        ldy #$00
        sty pg0Ptr
        sty pg1Ptr
        sty pg2Ptr
        lda #>auxPgs
        sty auxPtr
        sta auxPtr+1
        ldx slot
        rts


*-------------------------------------------------
* Read next byte from disk drive and decode it.
*
* Output:
*   A - the decoded 6-bit value.
*   X - the encoded 8-bit value read from disk.
*-------------------------------------------------
* Keep reading byte from disk until msb is high.
rdByte
slotUp2   = *+1 ; Instruction address accessed.
        ldx $c0ec
        bpl rdByte
* Decode byte.
        lda decTab,x
        rts


*-------------------------------------------------
* Attempt to read in all 18 pages of track.
* The head must already be sitting on correct
* track.
*
* Input:
*   track - set to the expected track value.
*   pages - list of 18 pages where each page from
*           track should be placed in RAM.
*
* Output:
*   Track contents will be transferred into pages
*   specified in the pages array.
*   Sets carry bit when retry attempts fail.
*   If carry bit is clear:
*     A = 0 indicates successful read.
*     A != 0 indicates track mismatch and A will
*       be the actual track under drive head.
*-------------------------------------------------
rdTrack 
* Intialize page address pointers.
        jsr zpInit
* Fill buffer with 6 non-zero values.  Each
* element in this buffer is zeroed as the sector
* is read.
* Also sets retry count to $30.
        ldy #$05
        lda #$30
        sta retries
:1      sta secSeen,y
        dey
        bpl :1
* Main retry loop.  $30 retries are allowed to
* obtain all 6 sectors successfully.
:retry  dec retries
        beq failRTS
* Read address field and retry on error.
        jsr rdAdr
        bcs :retry
* Compare actual track value read from disk to
* expected track and return if they don't match.
        lda actTrk
        cmp track
        clc
        bne rts
* If this sector has already been seen, retry.
        lda secSeen,y
        beq :retry
* Read in the data field for this sector and
* retry if an error was encountered.
        jsr rdData
        bcs :retry
* Flag that this sector has been seen.
        lda #$00
        ldy sector
        sta secSeen,y
* Loop through and see if all 6 sectors have now
* been read successully   Retry if still more
* sectors to read or return otherwise.
        ldy #$05
:2      lda secSeen,y
        bne :retry
        dey
        bpl :2
        iny
rts     rts


*-------------------------------------------------
* Set carry bit to flag error and return.
*-------------------------------------------------
failRTS sec
        rts


*-------------------------------------------------
* Searches for the start of the next sector's
* address field and then reads it.
*
* Input:
*   pages - This 18 element array should be
*           filled in with the page numbers of
*           the pages to be read/written.
*
* Output:
*   actTrk - is set to actual track value read
*            from disk at current head location.
*   sector - current sector number.
*   pg0Ptr - Initialize page portion for sector.
*   pg1Ptr - Initialize page portion for sector.
*   pg2Ptr - Initialize page portion for sector.
*   Y is equal to sector.
*   Sets carry bit if retry count is exceeded.
*-------------------------------------------------
* Initialize 2D retry counters to -6.
* It appears that this should allow for 
* 5 + 5*256 = 1285 retries which is longer than
* a sector.
rdAdr   ldy #$fa
        sty retrys_
:retry  iny
        bne :1
        inc retrys_
        beq failRTS
:1
* Search for address field prolog of $d5,$9d
        jsr rdByte
:2      cpx #$d5
        bne :retry
        jsr rdByte
        cpx #$9d
        bne :2
* Read in actual track number from address field.
        jsr rdByte
        sta actTrk
* Read in sector number from address field.
        jsr rdByte
        sta sector
* Read in checksum and XOR it with previously
* read track and sector to verify.
        jsr rdByte
        eor actTrk
        eor sector
        bne :retry
* Checksum was valid to get here.  Now read in
* and verify that expected address field epilog
* of $aa is next.
        jsr rdByte
        cpx #$aa
        bne :retry
* Clear carry to indicate that address field has
* been read successfully.
        clc
* FALL THROUGH to pgPtrUp to update page pointers


*-------------------------------------------------
* Updates page pointers based on current sector
* number.  This just needs to update the upper
* byte, page, of the pointers since the lower
* byte, offset, will be taken care of elsewhere,
* in zpInit for example.
*
* Input:
*   sector - The current sector.  This will
*            specify what the page pointers
*            should be initialized to.
*   pages - This 18 element array should be
*           filled in with the page numbers of
*           the pages to be read.
*
* Output:
*   pg0Ptr - Initialize page portion for sector.
*   pg1Ptr - Initialize page portion for sector.
*   pg2Ptr - Initialize page portion for sector.
*   Y is equal to sector.
*-------------------------------------------------
pgPtrUp ldy sector
        lda pages,y
        sta pg0Ptr+1
        lda pages+6,y
        sta pg1Ptr+1
        lda pages+12,y
        sta pg2Ptr+1
        rts


*-------------------------------------------------
* Read in the data field for the current sector.
*
* Input:
*   bndId2 - Set to bundle id to indicate side of
*           disk ($a9 for side 1 and $ad for
*           side2).
*   pages - This 18 element array should be
*           filled in with the page numbers of
*           the pages to be read.
*
* Output:
*   The 3 pages appropriate to this sector
*   according to the pages variable will be
*   filled in with read data.
*
*   Carry bit is set on checksum error or failure
*   to find expected data field prolog or epilog
*   bytes.
*-------------------------------------------------
rdData
* Setup for a 4x retry.
        ldy #$04
]retry  dey
        beq failRTS
* Read first byte and verify it matches the
* bundle id set by the application.  If not,
* retry.  This will allow for skipping the
* 2 SYNC bytes.
        jsr rdByte
bndId2  = *+1 ; Instruction immediate value accessed.
        cpx #$96
        bne ]retry
* This is the start of the loop which will read
* in the complete sector of data.  A sector is
* composed of 6to8 modulated stream of 3 pages
* (256 bytes) of data.  The decoding happens 4
* bytes at a time.  The first byte contains the
* high bits for the next following 3 bytes.
* Y = 0 - used to count through the 256 bytes.
* Preload A with the contents of chksum2 which
* will cause A to be zeroed out first time
* through the upcoming loop.
        ldy #$00
        lda chksum2
]nxtByt
* Read in aux byte from floppy drive.  This byte
* has the top two bits for the next 3 bytes to be
* read from the floppy.
* The byte read from disk is decoded from 8-bit
* to 6-bit, update checksum, and shift 2-bits for
* page 0 into the higher bits.
slotUp3   = *+1 ; Instruction address accessed.
        ldx $c0ec
        bpl ]nxtByt
        eor chksum2
        eor decTab,x
        sta chksum
        lda decTab,x
        asl
        asl
        sta auxByte
* Read in next byte from floppy drive.  This will
* contain the lower 6 bits for the first page in
* this sector.  OR in the upper 2 bits from the
* aux byte.  Update cecksum.
]again
slotUp4   = *+1 ; Instruction address accessed.
        ldx $c0ec
        bpl ]again
        and #$c0
        ora decTab,x
        sta (pg0Ptr),y
        sta chksum2
        lda auxByte
        asl
        asl
* Read in next byte from floppy drive.  This will
* contain the lower 6 bits for the second page in
* this sector.  OR in the next 2 bits from the
* aux byte.
]again
slotUp5   = *+1 ; Instruction parameter accessed.
        ldx $c0ec
        bpl ]again
        sta auxByte
        and #$c0
        ora decTab,x
        sta (pg1Ptr),y
        sta temp
        lda auxByte
        asl
* Read in next byte from floppy drive.  This will
* contain the lower 6 bits for the third page in
* this sector.  OR in the next 2 bits from the
* aux byte.  Update checksum.
]again
slotUp6   = *+1 ; Instruction parameter accessed.
        ldx $c0ec
        bpl ]again
l5045   asl
        ora decTab,x
        sta (pg2Ptr),y
        eor temp
        eor chksum
* Increment Y byte index and loop over 256 bytes.
        iny
        bne ]nxtByt
* Read in checksum byte, decode it and verify
* that the data is valid.  Set carry bit on
* error.
]again
slotUp7   = *+1 ; Instruction parameter accessed.
        ldx $c0ec
        bpl ]again
        eor decTab,x
        eor chksum2
        and #$3f
        bne :fail
* Read last byte and validate that it is the
* expected $d4 epilog byte.  Set carry bit on
* error.
        jsr rdByte
        cpx #$d4
        bne :fail
* Clear carry bit and return on success.
        clc
        rts
* Set carry bit and return on failure.
:fail   sec
        rts


*-------------------------------------------------
* Build up the aux byte pages.  Each of the 6
* sectors requires an aux byte.  The aux bytes
* are constructed from the top 2 bits of the 3
* data pages.
*
* Input:
*   pages - This 18 element array should be
*           filled in with the page numbers of
*           the pages to be written.
*
* Output:
*   auxPgs - These 6 pages of aux bytes will be
*            filled with the bytes based on the
*            18 data sectors being written.
*-------------------------------------------------
bldAux  
* Initialize page pointers and sector to 5.
        jsr zpInit
* Loop over all 6 sectors.
:loop
* Init page pointers to the pages specified in
* pages array for the current sector.
        jsr pgPtrUp
* Now that page numbers for this sector have been
* setup correctly in the ZP bank, push them into
* the code below where they are used for loading
* each byte from the pages to build up the aux 
* page.
        lda pg0Ptr+1
        sta ]pg0Up
        lda pg1Ptr+1
        sta ]pg1Up
        lda pg2Ptr+1
        sta ]pg2Up
        ldy #$00
* Loop through the data and use the auxLUT*
* tables to quickly build up the 6-bit aux value
* from the 3 data bytes by ORing together the 3
* lookup values.
:nxtByt
]pg0Up  = *+2 ; Instruction address accessed.
        ldx $ff00,y
        lda auxLUT0,x
]pg1Up  = *+2 ; Instruction address accessed.
        ldx $ff00,y
        ora auxLUT1,x
]pg2Up  = *+2 ; Instruction address accessed.
        ldx $ff00,y
        ora auxLUT2,x
* Store the resulting aux byte.
        sta (auxPtr),y
* Loop through 256 bytes.
        iny
        bne :nxtByt
* Loop to next sector.
* Increment to next aux byte page and decrement
* sector number.
        inc auxPtr+1
        dec sector
        bpl :loop
* Return to caller.
        rts


*-------------------------------------------------
* Initialize LUTs and modify code addresses to
* match the slot to be used for the disk drive.
*
* Called automatically the first time RW18
* routines are used.
*
* Input:
*   A contains the disk drive slot number.
*
* Output:
*   decTab - Init to map 8-bit encoded bytes to
*            6-bit decoded value.
*   auxLUT0, auxLUT1, auxLUT2
*-------------------------------------------------
init    
* Store slot number in main RW18 routine so that
* it knows it need not to call this function again.
        sta iniSlot
* Flip the $8c bits on in the slot number to
* convert it into the drive shift register
* address.  Update address fields in various
* instructions to use this address.
        ora #$8c
        sta slotUp2
        sta slotUp1
        sta slotUp3
        sta slotUp4
        sta slotUp5
        sta slotUp6
        sta slotUp7
* Do the same for load data register.
        ora #$01
        sta slotUp0
* Create decTab by inverting the data in the
* encTab.  This LUT can then be used to decode
* 8-bit values from the disk to 6-bit values.
        ldy #$3f
:1      ldx encTab,y
        tya
        sta decTab,x
        dey
        bpl :1
* Init LUTs which can be used to extract the two
* most significant bits from the 3 data pages
* shifted to the correct position to be ORed into
* the aux byte.
        ldy #$00
:2      tya
        and #$c0
        lsr
        lsr
        sta auxLUT0,y
        lsr
        lsr
        sta auxLUT1,y
        lsr
        lsr
        sta auxLUT2,y
        iny
        bne :2
        rts


*-------------------------------------------------
* Seek by moving head to new track.
*
* Input:
*   A contains the track to move to.
*   currTrk contains the actual current track * 2.
*
* Output:
*   currTrk will be update to new track * 2.
*   X contains the slot number.
*-------------------------------------------------
seek
* EQUates to zero page variables that are re-used
* by this function.
i       equ zpArea
savTrk  equ zpArea+1
tmpTrk  equ zpArea+2

* Multiply track number by 2 since there are two
* steps per track.
        asl
        sta tmpTrk
* If already on this track, then return.
        cmp currTrk
        beq :rts
* Initialize iteration count to 0.
        lda #$00
        sta i
* Keep stepping the head until it matches the
* desired track.
:loop
* Calculate difference between the current head
* position and the desired position.
        lda currTrk
        sta savTrk
        sec
        sbc tmpTrk
* Jump ahead to return if head now at desired
* track.
        beq :done
        bcs :1
* If currTrk is less than desired then take 1's
* complement of difference and increment currTrk.
        eor #$ff
        inc currTrk
        bcc :2
* If currTrk is greater than desired then
* subtract 2 from difference and decrement
* currTrk.
:1      adc #$fe
        dec currTrk
* This code modifies the timing between stepper
* pulses to  accelerate up to a maximum velocity
* and then decelerate as it gets closer to the
* desired location.  The i iteration count will
* feed the acceleration and trackdiff getting
* close to 0 will cause decleration.
:2      cmp i
        bcc :3
* trackdiff = i if trackdiff > i
        lda i
:3      cmp #$0c
        bcs :4
* If trackdiff <= 12 then 
* delayIndex = Y = trackdiff
        tay
* Turn required stepper phases on.
:4      sec
        jsr :phas1
        lda dlytbl1,y
        jsr :delay
* Turn required stepper phases off.
        lda savTrk
        clc
        jsr :phas2
        lda dlytbl2,y
        jsr :delay
* Increment iteration count and loop.
        inc i
        bne :loop
* Final delay and fall-through to turn phases
* off.
:done   jsr :delay
        clc

* Use lower 2 bits of currTrk to determine which
* phase to turn on/off before returning.
* Run with carry bit set to turn phases on.
* Run with carry bit clear to turn phases off.
:phas1  lda currTrk
:phas2  and #$03
        rol
        ora slot
        tax
        lda $c080,x
:rts    ldx slot
        rts
* Delay through looping.
:delay  ldx #$13
:5      dex
        bne :5
        sec
        sbc #$01
        bne :delay
        rts

* These tables provide shorter delays as index
* increases to provide acceleration and
* deceleration profiles in seek function.
dlytbl1 db $01,$30,$28
        db $24,$20,$1e
        db $1d,$1c,$1c
        db $1c,$1c,$1c

dlytbl2 db $70,$2c,$26
        db $22,$1f,$1e
        db $1d,$1c,$1c
        db $1c,$1c,$1c


        asc "COPYRIGHT 1985 BY ROLAND GUSTAFSSON"


*-------------------------------------------------
* Main RW18 command dispatcher.
*
* Input:
*   The command and its parameters are stored in
*   the code stream immediately after the 
*   "jsr rw18" call.  For example:
*       jsr rw18
*       db RdGrp.Inc
*       hex e0,e1,e2,e3,e4,e5,e6,e7,e8
*       hex e9,ea,eb,ec,ed,00,00,00,00
*   slot - this global should be set to indicate
*          the slot of the disk drive to be used.
*
* Output:
*   Depends on command being run.
*-------------------------------------------------
RW18
* Pull the return address off of the stack and
* place address into a 16-bit pointer used by the
* getByte routine.
        pla
        sta bytPtr1
        pla
        sta bytPtr2
* Save the zero page globals used by RW18 (e0-ef).
        jsr zpXchg
* Only need to execute init function if slot has
* changed since it was last executed.
        lda slot
iniSlot = *+1 ; Instruction address accessed.
        cmp #$00
        beq :1
        jsr init
* Extract RW18 command byte from code stream.
:1      jsr getByte
        sta cmd
* Use the lower 4 bits to look up the command
* handler in cmdTbl.  The 16-bit function pointer
* found in this table will be loaded into the
* address portion of the following jsr 
* instruction.
        and #$0f
        asl
        tax
        lda cmdTbl,x
        sta jmpAdr
        lda cmdTbl+1,x
        sta jmpAdr+1
* Call command handler.
jmpAdr  = *+1 ; Instruction address accessed.
        jsr $ffff
* Push updated return address onto stack after
* getByte has advanced bytPtr1 and bytPtr2 past
* the RW18 command parameters.
        lda bytPtr2
        pha
        lda bytPtr1
        pha
        
* Exchanges zero page bytes (e0-ef) with 16 bytes
* in a page following this code.  Calling this
* once can save the ZP bytes and calling it again
* will restore them.
zpXchg  ldx #$0f
:1      lda zpArea,x
        ldy savZP,x
        sta savZP,x
        sty zpArea,x
        dex
        bpl :1
        rts

* Table of function pointers to RW18 command
* handlers.  The RW18 routine will use the caller
* provided command byte to index into this table
* and then call the appropriate function.
cmdTbl  da CMdriveon
        da CMdriveoff
        da CMseek
        da CMreadseq
        da CMreadgroup
        da CMwriteseq
        da CMwritegroup
        da CMid
        


*-------------------------------------------------
* Turns specified drive on.
*
* Input:
*   parameter 1 - drive number (1 or 2).  PoP
*                 sets to 1.
*   parameter 2 - delay count.  If 0 then return
*                 immediately after selecting
*                 drive.
*-------------------------------------------------
* Aliases to ZP bytes for this function.
]count  equ zpArea
CMdriveon
        ldx slot
        jsr getByte
        ora slot
        tay
        lda $c089,y
        lda $c089,x
        jsr getByte
        beq :fin
        sta ]count
:delay1 ldy #$17
        ldx #$00
:delay2 jsr rts
        dex
        bne :delay2
        dey
        bne :delay2
        dec ]count
        bne :delay1
:fin   rts


*-------------------------------------------------
* Turns specified drive off.
*
* Input:
*   None
*-------------------------------------------------
CMdriveoff
        ldx slot
        lda $c088,x
        rts


*-------------------------------------------------
* Moves the head to the specified track.
*
* Input:
*   parameter 1 - flag to indicate whether code
*                 should first determine what
*                 track the head is currently
*                 positioned at.  PoP passes in 0
*                 to disable.
*   parameter 2 - track to move head to.  (0 - 34)
*-------------------------------------------------
CMseek
        jsr getByte
        beq :skpChk
* Set track to $ff so that rdTrack will fail and
* return with actual track # in A.
        lda #$ff
        sta track
        jsr rdTrack
        bcc :cont
* If rdTrack encountered an error such as would
* happen if not positioned over an actual RW18
* track, then step head in 160 times to make sure
* it is positioned at track 0.
        lda #$a0
        sta currTrk
        lda #$00
        jsr seek
        lda #$00
:cont   asl
        sta currTrk
:skpChk jsr getByte
        sta track
        jmp seek


*-------------------------------------------------
* Reads 18 pages from the current track into
* the pages beginning with the one specified in
* parameter 1.
*
* Command Modifiers:
*   Bit 7 - Set high to beep and retry on I/O
*           error.
*   Bit 6 - Set high to advance to next track
*           after successful I/O.
*
* Input:
*   parameter 1 - first page into which the track
*                 read should place its data.
*                 The other 17 pages of data will
*                 be placed in ascending page
*                 order.
*-------------------------------------------------
CMreadseq
* Only 1 page parameter specified.
        ldx #$01
* Fall through to CMreadgroup but use BIT opcode
* to skip first ldx #$12 instruction.
        hex 2c


*-------------------------------------------------
* Reads 18 pages from the current track into the
* pages specified by the 18 parameters.
*
* Command Modifiers:
*   Bit 7 - Set high to beep and retry on I/O
*           error.
*   Bit 6 - Set high to advance to next track
*           after successful I/O.
*
* Input:
*   parameter 1 - load first page from track into
*                 this page in memory. 0 means to
*                 ignore this page of data.
*   parameter 2 - load second page from track into
*                 this page in memory. 0 means to
*                 ignore this page of data.
*   parameters 3 - 18 - similar to params 1 and 2
*-------------------------------------------------
CMreadgroup
* 18 page parameters specified.
        ldx #$12
        jsr prepPgs
]read   jsr rdTrack
        bcs finRW
        beq finRW
* Get here if rdTrack determines that the head
* isn't currently placed properly for the
* desired track.
* Update currTrk to the actual track under head.
        asl
        sta currTrk
* Seek to desired track.
        lda track
        jsr seek
* Try the read again.
        jmp ]read

* Both read and write paths use this code to
* check bits in caller provided command to see if
* should move upate track to next sector and how
* to deal with errors.
finRW   bit cmd
* Branch on I/O error.
        bcs :error
* Just return if bit 7 isn't high.
        bvc :rts
* Get here on successful I/O and bit 6 of cmd is
* high.
* Increment track variable and return.
        inc track
:rts    rts
:error  bpl :rts
* Get here when I/O error is encountered and
* bit 7 in cmd is high.
* Beep the speaker and then try the I/Os again.
        ldy #$00
:1      tya
        bit $c030
:2      sec
        sbc #$01
        bne :2
        dey
        bne :1
        beq ]read


*-------------------------------------------------
* Writes 18 pages into the current track from
* the pages beginning with the one specified in
* parameter 1.
*
* Command Modifiers:
*   Bit 7 - Set high to beep and retry on I/O
*           error.
*   Bit 6 - Set high to advance to next track
*           after successful I/O.
*
* Input:
*   parameter 1 - first page into which the track
*                 write should gets its data.
*                 The other 17 pages of data will
*                 be read in ascending page
*                 order.
*-------------------------------------------------
CMwriteseq
* Only 1 page parameter specified.
        ldx #$01
* Fall through to CMwritegroup but use BIT opcode
* to skip first ldx #$12 instruction.
        hex 2c


*-------------------------------------------------
* Writes 18 pages into the current track from the
* pages specified by the 18 parameters.
*
* Command Modifiers:
*   Bit 7 - Set high to beep and retry on I/O
*           error.
*   Bit 6 - Set high to advance to next track
*           after successful I/O.
*
* Input:
*   parameter 1 - write first page to track from
*                 this page in memory. 0 means to
*                 ignore this page of data.
*   parameters 2 - 18 - similar to parameter 1.
*-------------------------------------------------
CMwritegroup
* 18 page parameters specified.
        ldx #$12
        jsr prepPgs
        jsr bldAux
        jsr wrTrack
        jmp finRW


*-------------------------------------------------
* Sets bundle id for disk side to be read.
*
* Input:
*   parameter 1 - Bundle id to use.
*                 $a9 for PoP side 1
*                 $ad for PoP side 2
*-------------------------------------------------
CMid    jsr getByte
        sta bndId
        sta bndId2
        rts

*-------------------------------------------------
* Fills in 18 element pages array based on
* command parameters.  Also moves head to correct
* track location.
*
* Input:
*   X - is the number of pages specified by
*       command.  1 for sequential read/writes
*       and 18 for group read/writes.
*   parameters - There will be 1 or 18 command
*                parameters to be copied into
*                pages array.
*
* Output:
*   pages - will be filled in with 18 page numbers
*           to be used for read/write.
*-------------------------------------------------
* Aliases to ZP area.
]count  equ zpArea
prepPgs 
        stx ]count
* Copy caller provided page numbers: 1 or 18.
        ldx #$00
:1      jsr getByte
        sta pages,x
        inx
        cpx ]count
        bcc :1
* When only 1 page parameter is specified, fill
* the other 17 elements with ascending values.
        tay
:2      iny
        cpx #$12
        beq :3
        tya
        sta pages,x
        inx
        bne :2
* Walk through the pages elements and switch any
* set to 0 with a dummy page reserved for such
* reads/writes.
:3      dex
:4      lda pages,x
        bne :5
        lda #>dumPage
        sta pages,x
:5      dex
        bpl :4
* Move head to correct location for the upcoming
* I/O operation.
        lda track
        jmp seek


*-------------------------------------------------
* Retrieves the next RW18 parameter from the
* caller's code stream.
*
* Input:
*   bytPtr1 and bytPtr2 must have been set to
*       the calls return address before the first
*       call to this routine.
*
* Output:
*   A - contains the next call parameter byte.
*-------------------------------------------------
getByte inc bytPtr1
        bne :1
        inc bytPtr2
:1
bytPtr1  = *+1 ; Instruction address accessed.
bytPtr2  = *+2 ; Instruction address accessed.
        lda $ffff
        rts


*-------------------------------------------------
* These 64 zero bytes were found in the original
* object and I want to match it for validation
* purposes.
*-------------------------------------------------
        ds 64,$00


*-------------------------------------------------
* There are variables stored in pages following
* the code.
*-------------------------------------------------
        dum *
        ds \
        
* Dummy page used for reading/writing when user
* doesn't specify a page explicitly in group
* command.
dumPage ds 256
        
* When writing to disk, a page per sector of aux
* bytes will be placed in these 6 pages.  They
* are stored in descending sector order from 5 to
* 0.
auxPgs  ds 6*256

* These LUTs are generated in the init function.
* They can take an 8-bit value from the 3 data
* pages and extract the two most significant bits
* shifted to the correct position to be ORed into
* the aux byte.
auxLUT0 ds 256
auxLUT1 ds 256
auxLUT2 ds 256
        
* The list of 18 pages to read/write for a track.
pages   ds 18

* Flags which sectors in track have been
* successfully read.
secSeen ds 6

* Saved contents of the zero page $e0-$ef bytes.
savZP   ds 16

* The upper half of this page will contain a
* sparse 8-bit to 6-bit decode table created
* from init function.
decTab  = *&$ff00
        ds \

        dend


        sav RW18525
