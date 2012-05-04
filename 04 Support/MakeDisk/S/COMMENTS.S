* comments
*-------------------------------
*
* M  O  V  E  R
*
*-------------------------------
*
* Routines to keep track of moving objects are contained
* in the file MOVER.
*
* There are 2 types of moving objects: Transitional objects
* (TROBs) and mobile objects (MOBs).
*
* TROBs (e.g. gate, spikes, pressplate, torch) can have moving
* parts & change appearance, but remain in a fixed location.
*
* MOBs (falling floor) can move all over the place, including
* between screens.
*
*-------------------------------
*
* TROBs are kept track of in a data structure called
* the "trans list" as follows:
*
* numtrans = # of active TROBs
*
* For x = 1 to numtrans:
*
*  trloc,x = block location (0-29)
*  trscrn,x = screen # (1-24)
*  trdirec,x = direction of motion (means something different
*   for different kinds of objects)
*
* When an object stops moving, we set its trdirec = -1, then
* remove the object from trans list on the next cycle.
*
*-------------------------------
*
* MOBs are kept track of in a similar data structure called
* the "MOB list":
*
* nummob = # of active MOBs
*
* For x = 1 to nummob:
*
*  mobx,x = byte (0-39)
*  moby,x = y-coord
*  mobscrn,x = screen #
*  mobvel,x = velocity
*  mobtype,x = type
*    0: falling floor
*    (No other MOB types defined at present)
*  moblevel,x = level (0-2)
*
*-------------------------------
*
*  The basic routine in MOVER is ANIMTRANS.  This
*  routine, which is called once per cycle, advances
*  all active TROBs to their next phase (this includes
*  deleting TROBs that become inactive) and marks the
*  appropriate redraw buffers for each TROB.
*
*  Other routines such as TRIGSPIKES, PUSHPP, BREAKLOOSE,
*  etc. are called to add new TROBs to the trans list (when,
*  for example, a character jumps over spikes or steps on
*  a pressure plate or loose floor).
*
*  The routine ANIMMOBS performs the same function for
*  the MOB list that ANIMTRANS does for the trans list.
*  It advances all active MOBs to the position they will
*  occupy in the next frame.
*
*  Example: When a character steps on a loose floor, the
*  control routine senses this & puts in a call to
*  BREAKLOOSE (which adds the loose floor to the trans
*  list).  For the next 10 frames or so, the loose floor
*  wiggles (under the control of ANIMTRANS) until ANIMTRANS
*  decides it's time for it to fall.  At that point, the
*  loose floor is deleted from the trans list, the block
*  is replaced by "empty space", and a new MOB is
*  created to take its place.  Under the control of
*  ANIMMOBS, the MOB then falls until it hits the ground,
*  at which point ANIMMOBS deletes the falling floor from
*  the MOB list and changes the objid of the block it landed
*  on to "rubble."
*
*-------------------------------
*
*  F  R  A  M  E  A  D  V
*
*-------------------------------
*
*  IMAGE LISTS
*
*  FRAMEADV never calls hires routines directly.  Instead,
*  parameters of images to be drawn are stored in "image lists."
*
*  There are 6 separate image lists:
*
*  bg:   Images in background plane (drawn first)
*        X, Y, IMG, OP
*
*  wipe: Solid-color wipes (drawn with b.g. plane)
*        X, Y, H, W, COL
*
*  fg:   Images in foreground plane (drawn last)
*        X, Y, IMG, OP
*
*  mid:  Images between b.g. and f.g. planes
*        X, OFF, Y, IMG, OP, TYP, CU, CD, CL, CR
*
*  msg:  Images in message plane (drawn last of all)
*        X, OFF, Y, IMG, OP
*
*  gen:  General instructions (e.g. clear screen)
*
*
*  Explanation of parameters:
*
*  X    = X-coord (in bytes)
*  OFF  = X-offset (0-6)
*  Y    = Y-coord
*  IMG  = image # in table (1-n)
*  OP   = opacity
*  TYP  = image type (for mid only)
*  CU   = top cutoff
*  CD   = bottom cutoff
*  CL   = left cutoff
*  CR   = right cutoff
*  H    = height
*  W    = width (in bytes)
*  COL  = color (for wipe only)
*
*  NOTE--bg, fg, and wipe calls assume offset=0
*
*
*  There is also an "object list" with params similar to
*  mid list:
*
*        X, OFF, Y, IMG, FACE, TYP, CU, CD, CL, CR
*
*  Note that obj list has 2 additional params:
*
*  objFACE = left/right
*  objTYP  = object type (Not to be confused with midTYP)
*
*  The object list has one entry for each object to be
*  drawn (e.g., "kid," "falling floor").  FRAMEADV uses
*  the object list to build the actual mid list
*  of images to be drawn.  E.g., the single object "falling
*  floor" might translate into 3 separate images:
*  A-section, B-section, and D-section.
*
*-------------------------------
*
*  REDRAW BUFFERS
*
*  Each redraw buffer contains 30 counters, one for each
*  block on screen: 0 = skip, non-0 = redraw and decrement.
*
*  REDBUF:
*  The most general-purpose buffer.  Marking REDBUF for a
*  block will cause all sections of the block to be redrawn.
*
*  WIPEBUF:
*  Wipe square (usually to black).  WHITEBUF contains
*  wipe height, in lines.
*
*  Marking both REDBUF and WIPEBUF for a block will cause
*  the entire block to be erased & redrawn.  This is the
*  safest way to redraw a block.
*
*  MOVEBUF:
*  Refers only to movable portion of object (e.g. lowering
*  gate).  Superseded by REDBUF.
*
*  FREDBUF:
*  Refers only to foreground plane.  Marked when character
*  goes behind a post or other object with a frontpiece.
*  Superseded by REDBUF.
*
*  FLOORBUF:
*  Refers to floorpieces.  Marked to the right of a
*  falling or hanging character.  FLOORBUF causes floorpiece
*  to be drawn in the mid plane (where it will cover up
*  character if appropriate).
*
*  HALFBUF:
*  Like FLOORBUF, but redraws a triangular section of
*  the floorpiece instead of the whole thing.  Used when
*  a character climbs up on the left side of a floorpiece
*  and we want to mask out his lower body while letting his
*  upper body show.  (Superseded by FLOORBUF.)
*
*  OBJBUF:
*  Marked whenever objects need to be drawn in a given block.
*  (Objects are always the last mid elements drawn in
*  a block.  Objects are assigned to blocks based on
*  their lower left x-y coords.  Characters are considered
*  objects.  There can be multiple objects in a given block.)
*
*  TOPBUF:
*  10-byte buffer for row of D-sections across top of screen
*  (from screen above).
*
*  Note that TOPBUF is a 10-byte buffer while the others are
*  all 30 bytes.
*
*-------------------------------
*
*  The specific routines called by SURE (in FRAMEADV) for
*  each of these buffers are:
*
*  REDBUF: redblock (drawc, drawb, drawmb, drawd, drawmd,
*     drawa, drawma, drawfrnt)
*
*  WIPEBUF: wipesq
*
*  MOVEBUF: drawc, drawmc, drawmb, drawma
*
*  FREDBUF: drawfrnt
*
*  FLOORBUF: drawfloor
*
*  HALFBUF: drawhalf
*
*  OBJBUF: drawobjs
*
*  TOPBUF: drawc, drawb, redrawd, drawmd, drawfrnt
*
*-------------------------------
*
*  B  L  U  E  P  R  I  N  T
*
*-------------------------------
*
*  LEVEL BLUEPRINT ($900 bytes)
*
*               Start      Length
*               -----      ------
*  BlueType     B700       720
*  BlueSpec     B9D0       720
*  LinkLoc      BCA0       256
*  LinkMap      BDA0       256
*  Map          BEA0       96
*  Info         BF00       256
*
*  TOTAL: 2304 bytes
*
*-------------------------------
*
* BLUETYPE
*
* Bytes 0-29 describe screen #1
* Bytes 30-59   "     screen #2
* etc.
* 24 screens total.
*
* Each BLUETYPE byte corresponds to one block.
* (30 blocks per screen.)  Blocks are mapped
* into BLUETYPE left-right, top-bottom.
*
* AND with #$1F to get the "objid," or object
* identification number (0-31), of each block.
*
*-------------------------------
*
* BLUESPEC
*
* (Screen blocks mapped the same way as in BLUETYPE.)
*
* Taken together, each pair of corresponding bytes in
* BLUETYPE and BLUESPEC contains all the information
* about an object.  The BLUETYPE byte always contains
* the object id.  The BLUESPEC byte functions differently
* depending on what the object is.
*
* For movable objects (gates, spikes, torches, etc.)
* BLUESPEC specifies the object's "state" (e.g. is it
* open, closed, somewhere in between?)
*
* For static objects (floor, space, solid block, etc.)
* BLUESPEC specifies the object's "pattern" (e.g. which
* design appears on the wall behind it?)
*
* For pressure plates, the BLUESPEC byte tells which
* gates the pressure plate controls.  Specifically, the
* BLUESPEC byte is a pointer (0-255) to the first entry
* in the link list for this pressure plate.
*
*-------------------------------
*
* Link list (LINKLOC/LINKMAP)
*
* Contains a list of the gates controlled by each pressure
* plate.  Each pair of bytes specifies one plate-to-gate
* linkage.  There can be up to 256 such linkages in a level.
*
* LINKLOC:
*  Bits 0-4: gate screen posn (0-29)
*  Bits 5-6: low 2 bits of gate screen # (1-24)
*  Bit 7: 1 = this is last entry, 0 = more gates to come
*
* LINKMAP:
*  Bits 0-4: pressplate timer (0-31)
*  Bits 5-7: high 3 bits of gate screen #
*
* If a pressplate controls nothing, LINKLOC = FF; LINKMAP
* still functions as pressplate timer.
*
*-------------------------------
*
* MAP
*
* Specifies how the 24 screens of the level are connected.
*
* Each screen gets 4 bytes corresponding to the screen #s
* of the 4 adjacent screens.
*
* Bytes 0-3 = screen #1
* Bytes 4-7 = screen #2
* etc.
*
* For each screen:
* Byte #1 = screen to left
* Byte #2 = screen to right
* Byte #3 = screen above
* Byte #4 = screen below
*
*-------------------------------
*
*  INFO
*
*  Bytes 0-63: reserved for editor
*
*  Bytes 64-255: Information about starting positions
*  of player & other characters on this level.
*  (See GAMEEQ for details.)
*
*-------------------------------
*
*  S  E  Q  T  A  B  L  E
*
*-------------------------------
*
*  Frame def list:
*
*  1200 bytes allocated -- 240 frames, 5 bytes each
*  (241-255 reserved as commands)
*
*  Frame definition consists of:
*
*  (1) Fimage
*
*     Bit 7 = chtable # (0-7), bit 2
*
*     Bits 0-6 = image # (0-127)
*
*     SUMMARY:
*       $00 + x: chtable 1,2,3,4
*       $80 + x: chtable 5,6,7,8
*
*  (2) Fsword
*
*     Bits 6-7 = chtable # (0-7), bits 0-1
*
*     Bits 0-5 = pointer to SWORDTAB frame (0-63)
*
*     SUMMARY:
*       $00 + x: chtable 1,5
*       $40 + x: chtable 2,6
*       $80 + x: chtable 3,7
*       $c0 + x: chtable 4,8
*
*  (3) Fdx
*
*     X-shift in pixels (+ = fwd, - = bkwd)
*     (NOTE -- horizontal resolution is 140 pixels)
*
*  (4) Fdy
*
*     Y-shift in pixels (+ = down, - = up)
*     (Frame #15 is defined as unshifted)
*
*  (5) Fcheck
*
*     Bit 7 = odd/even pixel
*
*     Bit 6 = 1 if floor check is required (i.e., if weight
*       is on floor)
*
*     Bit 5 = 1 to "thin" this frame for collision detection
*
*     Bits 0-4 = number of pixels (0-31) from left edge of
*       image block to base x-coord
*       (usually center of foot bearing character's weight)
*
*     SUMMARY:
*       $c0 + x: check, odd
*       $40 + x: check, even
*       $80 + x: no check, odd
*       $00 + x: no check, even
*
*     + $20 to set bit 5
*
*-------------------------------
*
*  SEQPOINT is 2-byte pointer to character's current
*  position in sequence table.
*
*  Seq pointer is incremented by 1 with each frame-advance.
*
*  CTRL can jump seq pointer around at will (e.g., in response
*  to joystick command)
*
*  POSITIVE seq table values represent frame numbers.
*  NEGATIVE values are instruction codes.
*
*  Sequence table instructions:
*
*   goto NN    jump seq pointer to NN (low byte first)
*   aboutface  change KIDFACE direction
*   up         up one floor
*   down       down one floor
*   chx N      KIDX := KIDX + N (BEFORE we draw next frame)
*   chy N      KIDY := KIDY + N (ditto)
*   act N      change action code to N
*   setfall X,Y  set initial x,y velocity for freefall
*
*  Action codes:
*
*  -1 = dead
*   0 = standing still
*   1 = running, jumping, other actions
*       that require a floor beneath your feet
*   2 = hanging, climbing, and all other actions that
*       require holding onto a ledge
*   3 = in midair (briefly)
*   4 = in freefall
*   5 = being bumped
*   6 = hanging straight
*   7 = turning
*
*  Screen resolution is 140 x 192.
*
*-------------------------------
*
*  NOTE: Frame table offsets are TEMPORARY; sequence table
*  offsets are PERMANENT.
*
*  CTRL draws each frame at [KIDX + Fdx, KIDY + Fdy],
*  but leaves KIDX & KIDY unchanged for the next frame.
*  "Chx" and "Chy" instructions in sequence table, however,
*  change KIDX & KIDY permanently.
*
*  For JUMPHANG, CLIMBUP, etc., the idea is for KIDX, KIDY &
*  KIDLEVEL to keep the kid where he started -- at the end
*  of the block behind & below the one he's hanging from --
*  and use only the frame list x & y offsets, until he's back
*  on the ground.  This way, we can branch into either HANGDROP
*  or CLIMBUP from any point in HANG.
*
*  The first 4 frames of STARTRUN also use only the frame list
*  offsets.  This lets us switch easily to, say, FULLSTEP
*  or STANDJUMP.
*
*-------------------------------
*
*  M  I  S  C
*
*-------------------------------
*
* Potion IDs
*
* 0  Empty
* 1  Regular healing
* 2  Boost strength
* 3  Weightless
* 4  Upside down
* 5  Poison
*
*-------------------------------
*
* Character IDs
*
* 0  Kid
* 1  Shadow
* 2  Guard
* 3  Vizier (in game)
* 4  Skeleton
* 5  Princess (in princess cuts)
* 6  Vizier (in princess cuts)
*
*-------------------------------
 lst off
