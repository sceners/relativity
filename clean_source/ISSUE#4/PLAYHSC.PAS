UNIT PLAYHSC;

(*
                           HSC Player Unit V1.0
                           --------------------

  Written in 1994 by GLAMOROUS RAY^RADiCAL RHYTHMS
  Original code and .OBJ by CHiCKEN and ZWERG ZWACK^ELECTRONiC RATS

  This code is FREE WARE. This means that you can copy and distribute it
  as you like, but you may not charge any money for its distribution. If
  you intend to use this code in a commercial product than you have to
  get written permission from NEO Software Produktions GmbH Austria.


  Introduction:
  -------------

  What is PLAYHSC? This unit is intended for use with the HSC tracker
  written by Zwerg Zwack and Chicken on low level support from NEO
  Software <g>.

  This unit supports an easy and fast to use way to play sound, so
  not all general functions of the player are included. It is not
  possible to do the polling - this is done by the player automatically,
  it links into the timer interrupt.


  General overview:
  -----------------

  Below follows a description how to play sound files from your program,
  calling this unit. There are two ways:

  1st: Play a sound file, loading from disk
  2nd: Play a sound file, directly from included data.

  The first method is very easy and simple, the second one more
  cool ;).

  The player is build up as an object, so it is initialized on your heap
  when starting and deinstalled when finishing. Please note that the
  player does _no_ check for memory. So it's up to you to check if there's
  enough memory (heap) free to load the music - the player won't just do
  anything in that case.

  To get the object to work, you have to declare it as a variable. This
  is normally done this way:

  VAR
    Music : HSC_obj;

  Now the object is declared and has to be used and called by _you_.
  An object's variables and procedures a called like a record so you
  can do the following:

  Music.Init(0);
  Music.Done;


  Software implementation:
  ------------------------

  CONSTRUCTOR HSC_obj.Init (AdlibAddress : WORD);
  -> Init the player and the object. You must supply a base address for
     the adlib card. If you want to use the player's autodetection
     routines, simply use 0 as the base.

  PROCEDURE HSC_Obj.Start;
  -> Start music file, located at HSC_Obj.Address. The address is
     set by either HSC_Obj.LoadMem or HSC_Obj.LoadFile;

  FUNCTION HSC_Obj.LoadFile (FileName):BOOLEAN;
  -> Load a file from disk into memory. If the file you tend to load
     is invalid or simply not there, the player won't play a single
     voice. The function returns if it has loaded the music or not. If
     not, there maybe was not enough memory or the file could not be
     loaded (due to non-existence etc.).

  PROCEDURE HSC_Obj.LoadMem (Music_Address : Pointer);
  -> "Load" music from disk. This has to be done to tell the player
     that the music is _not_ loaded from disk so the memory is not freed
     up when playing the next file.

  PROCEDURE HSC_Obj.Stop;
  -> Stop music (if playing). This has to be done if you want to stop
     the music. If you want to unload the music, simplay call HSC_Obj.Done
     as this (of course) stops the music, too!

  PROCEDURE HSC_Obj.Fade;
  -> Fade out music. This takes up to 4 seconds, so be sure to wait
     in you program for fade-out, otherwise you will "kill" the sound
     when calling HSC_Obj.Done (this will do a very nasty "pop").

  DESTRUCTOR HSC_Obj.Done;
  -> Deinit object <g>. This frees up all memory allocated and stops
     the music.


  Hints & Tips section:
  ---------------------

  Make sure your program does not exit without calling the destructor
  or at least stopping the music. If you don't stop the music, your
  system will hang on loading a new program (This is because of the
  memory usage - the player still plays while the memory is already
  freed up and used by another program - "Zack!"). It is a wise idea
  to put the command into the @Exitproc.

  If you want to play more than one music file - okay - do it! ;)


  Examples:
  ---------

  Please see the enclosed file TSTHSC.PAS for more information.


  Including music into .EXE files:
  --------------------------------

  All you need for doing this, is your sound file (*.HSC) and the
  program BINOBJ.EXE which came with your pascal package. Run the
  program like this:

  BINOBJ.EXE MUSIC.HSC MUSIC.OBJ MUSIC_DATA

  This converts the file MUSIC.HSC into MUSIC.OBJ with the public name
  set to MUSIC_DATA. Now all you have to do is to declare this object
  file within you program. This has to be done like this:

  {$F+}
  {$L MUSIC.OBJ}
  PROCEDURE MUSIC_DATA; EXTERNAL;
  {$F-}

  To play this file, try:

  HSC_Obj.LoadMem (@MUSIC_DATA);

  That's it!


  Last words:
  -----------

  First, I'd like to comment on my code. I hope, you're able to under-
  stand this mess <g>. Second, don't bother me for the way it was
  written. I just know: it works. And it will work on other machines
  because it is written _cleanly_. If you think, you can do better:
  please do! (And send me a copy! :)) )

  Greetings go to all RADiCAL RHYTHMS members for being an amazing posse.
  Last, but not least, thanks to Chicken and Zwerg Zwack for their rellay
  neat program.

  If you find any bugs, or have ideas for add-ons, please contact me:

  via modem : The UnderCover BBS - +49 2323 450 850
             (9600+, 8N1)

  via fido  : Christian Bartsch@2:2445/321.49 (classic)

  via phone : +49 2323 460 525



  May, 23rd 1994 - GLAMOROUS RAY! C U in cyberspace...

*)

INTERFACE

TYPE
  HSC_obj = OBJECT

    (* The following variables are _internal_ variables and should not be
       changed from outside!                                             *)

    Address    : Pointer;
    Music_Load : BOOLEAN;
    Music_Size : LONGINT;
    Music_Run  : BOOLEAN;
    Music_Fade : BOOLEAN;

    (* The following procedures/cuntions are for your use. Please read
       the information above on how to use them!                        *)

    CONSTRUCTOR Init (AdlibAddress : WORD);
    PROCEDURE Start;
    PROCEDURE Stop;
    PROCEDURE Fade;
    PROCEDURE LoadMem (Music_Address : Pointer);
    FUNCTION LoadFile (FileName : STRING):BOOLEAN;
    DESTRUCTOR Done;

  END;

IMPLEMENTATION

USES CRT;



(*-------------------------------------------------------------------------*)
(*                SECTION: Sub-routines used for by HSC_obj                *)
(*-------------------------------------------------------------------------*)



{$F+}                               (* Include                         *)
{$L HSCOBJ.OBJ}                     (*        external                 *)
PROCEDURE _HscPlayer; EXTERNAL;     (*                  player         *)
{$F-}                               (*                          object *)

FUNCTION  DetectAdlib (SuggestedPort : WORD) : WORD; ASSEMBLER;
  ASM
    MOV  AH,4
    MOV  BX,SuggestedPort
    CALL _HscPlayer
    JNC  @GoOn
    MOV  AX,0FFh
  @GoOn:
  END;

PROCEDURE GetPlayerState (VAR Destination); ASSEMBLER;
  ASM
    MOV  AH,7
    LES  SI,DWORD PTR Destination
    CALL _HscPlayer
  END;

PROCEDURE StartMusic (Song : POINTER; Polling, OldIRQ : BOOLEAN); ASSEMBLER;
  ASM
    MOV  AH,0
    MOV  BL,Polling
    MOV  BH,OldIRQ
    CMP  BH,1
    JE   @Invert
    MOV  BH,1
    JMP  @GoOn
  @Invert:
    XOR  BH,BH
  @GoOn:
    LES  SI,DWORD PTR Song
    CALL _HscPlayer
  END;

PROCEDURE StopMusic; ASSEMBLER;
  ASM
    MOV  AH,2
    CALL _HscPlayer
  END;



(*-------------------------------------------------------------------------*)
(*                      SECTION: HSC_obj implementation                    *)
(*-------------------------------------------------------------------------*)



CONSTRUCTOR HSC_obj.Init (AdlibAddress : WORD);
VAR
  Dummy : WORD;
BEGIN
  Music_Load := FALSE;
  Music_Run  := FALSE;
  Music_Fade := FALSE;
  Address    := NIL;

  Dummy := DetectAdlib (0);
  Delay (30);
END;

PROCEDURE HSC_obj.Start;
BEGIN
  IF NOT Music_Run THEN BEGIN
    IF Address <> NIL THEN BEGIN
      StartMusic (Address,FALSE,TRUE);
      Music_Run := TRUE;
    END;
  END;
END;

PROCEDURE HSC_obj.Stop;
BEGIN
  IF Music_Run THEN BEGIN
    StopMusic;
    Music_Run := FALSE;
  END;
END;

PROCEDURE HSC_obj.Fade;
BEGIN
  IF Music_Run THEN BEGIN
    ASM
      MOV  AH,3
      CALL _HscPlayer
    END;
    Music_Fade := TRUE;
    Music_Run  := FALSE;
  END;
END;

PROCEDURE HSC_Obj.LoadMem (Music_Address : Pointer);
BEGIN
  IF Music_Fade or Music_Run THEN BEGIN
    StopMusic;
    Music_Run  := FALSE;
    Music_Fade := FALSE;
    IF Music_Load THEN FreeMem (Address,Music_Size);
  END;
  Music_Load := FALSE;
  Address    := Music_Address;
END;

FUNCTION HSC_Obj.LoadFile (Filename : STRING):BOOLEAN;
VAR
  f : FILE;
BEGIN
  IF FileName <> '' THEN BEGIN
    Assign (F,FileName);
    {$I-} RESET (F,1); {$I+}
  END;

  IF (IORESULT <> 0) OR (FileName = '') THEN BEGIN
    Music_Load := FALSE;
    LoadFile   := FALSE;
  END ELSE BEGIN
    IF Music_Fade or Music_Run THEN BEGIN
      StopMusic;
      Music_Run  := FALSE;
      Music_Fade := FALSE;
      IF Music_Load THEN FreeMem (Address,Music_Size);
    END;
    Music_Size := FileSize (F);
    IF MaxAvail < Music_Size THEN BEGIN
      LoadFile   := FALSE;
      Music_Load := FALSE;
    END ELSE BEGIN
      GetMem (Address,Music_Size);
      BlockRead (f,Address^,Music_Size);
      LoadFile   := TRUE;
      Music_Load := TRUE;
    END;
  Close (f);
  END;
END;

DESTRUCTOR HSC_obj.Done;
BEGIN
  IF Music_Run OR Music_Fade THEN StopMusic;
  IF Music_Load THEN FREEMEM (Address,Music_Size);
END;

END.

(*-------------------------------------------------------------------------*)
(*                         SECTION: END OF FILE ;)                         *)
(*-------------------------------------------------------------------------*)
