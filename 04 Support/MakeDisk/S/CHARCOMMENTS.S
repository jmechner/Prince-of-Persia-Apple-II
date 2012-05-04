*-------------------------------
*
* Character animation comments
*
*-------------------------------
*
* For each character, we maintain a 16-byte block of data
* (referred to as "character data" or "character vars")
* that describes the character's current position & what
* he is doing.  The 16 bytes are allocated as follows:
*
* CharPosn
*
*   Frame # of the character's current position.  E.g.,
*   CharPosn = 15 refers to frame #15 of the frame list, or
*   "standing still."
*
* CharX
* CharY
*
*   Character X & Y coords, based on a 140 x 192 screen.
*   (Upper left corner is X = 58, Y = 0)
*
* CharFace
*
*   Direction character is facing: 0 = right, -1 = left
*
* CharBlockX
* CharBlockY
*
*   Coords of character's current block (X = 0-9, Y = 0-2).
*   (0,0) is upper left block.
*
* CharAction
*
*   Code containing information about character's current
*   action.  E.g., CharAction = 4 means "falling."  This
*   variable is used in a variety of different ways in
*   different situations
*
* CharXVel
* CharYVel
*
*   X & Y components of character's velocity (during
*   freefall).  Every frame, CharXVel is added to CharX and
*   CharYVel is added to CharY.
*
* CharSeq (2 bytes)
*
*   Pointer to current address in the sequence table.
*
* CharScrn
*
*   Screen # of character's current screen.  (0 for null
*   screen.)
*
* CharRepeat
*
*   When character stands at the edge of a chasm & takes a
*   cautious step forward, the first time he tries it he only
*   "tests" with his foot.  This causes CharRepeat (usually
*   a non-0 value) to be set to 0.  The next time he tries a
*   cautious step, he will step right off the edge.
*
* CharID
*
*   Identifies character:
*   0 = kid
*   1 = shadow man
*   2 = guards, vizier
*   4 = skeleton
*   5 = princess (in princess scenes)
*   6 = vizier (in princess scenes)
*   24 = mouse
*
* CharSword
*
*   2: sword drawn
*   0: sword sheathed
*
* CharLife
*
*   -1: alive
*   0-127: dead
*
*-------------------------------
*
*  Two permanent sets of CharData are maintained: KidData
*  (for the kid) and ShadData (for his opponent).  Note
*  that the opponent data is always referred to by the
*  prefix "Shad" although the character may be the shadow
*  man, skeleton, Vizier, etc.
*
*  CharData itself is used as temporary storage for whichever
*  character we want to deal with.  Typically, we will call
*  LoadKid to "load" the kid as our current character (i.e.,
*  load the 16 bytes of KidData into the CharData space),
*  then call the control routines that change CharData, then
*  when we're done call SaveKid to "save" the modified
*  CharData back into KidVars.  This way we can use the
*  same control routines for both the kid & his opponent.
*
*  There is a second data set used for temporary storage
*  OppData.  OppData always contains the "other" character
*  than CharData -- e.g., when we call LoadKid, we load
*  KidData into CharData and ShadData into OppData.
*
*-------------------------------
