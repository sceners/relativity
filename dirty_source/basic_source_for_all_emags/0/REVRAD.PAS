{****************************************************************************
 RADPAS v1.3 (C) 1996 Evan Salomon.  This code is FREEWARE.  Released 2/25/95

  DESCRIPTION:
    RADPAS is an EXTREMELY easy was to incorporate Reality Adlib Tracker
    v1.x music into your Turbo Pascal 7.0 programs.  All playing code was
    written in ASM by Reality and ported to TP7 by Evan Salomon.  Dedicated
    to Reality for their awsome RAD editor, the best and easiest to use Adlib
    editor ever created!

  LICENSE AGREEMENT / DISCLAIMER:
    You may use/modify this code as much as you want.  The author is not
    responible for any damages caused by use or misuse of this code.  Use at
    your own risk.  Use of RAD music in commercial programs requires
    permission from Reality.

  REVISIONS:
    v1.3 - Fixed bug that caused slow music to play fast after playing fast
           music when using InstallRADTimer (not InstallFastRADTimer).  The
           only thing changed in this version is the jump added at line 1116.
    v1.2 - Added adlib detection code to skip playing but keep timer if no
           adlib detected
         - Added master volume control and fading (no SB, just adlib)
         - Got rid of small burst of sound when resetting adlib, by setting
           registers $43..$55 to $3F instead of 0 (to set lowest volume)
         - Added pause feature
    v1.1 - Fixed one huge bug that made the playing work randomly on only a
           select few RADs.
         - Fixed bug that was fixed in RAD v1.1a
           (effects starting one beat too late)
         - *EXTREMELY* simplified interface and directions
         - Automatically frees buffer on StopRad call when using PlayRadFile
         - Added error codes so you know what went wrong
    v1.0 - Initial release

  LIMITATIONS / BUGS: (probably due to adlib limitations)
    - Fading in doesn't work
    - Some instruments don't fade corrently
    - Clicking when using low volumes

  HOW TO WORK AROUND THE LIMITATIONS:
    - Use real SB volume control

  CONTACTS:
    If you have any questions, comments, or suggestions...
    The author can be reached by internet e-mail at: msalomon@ccnet.com

    To contact Reality, look for their address inside the RAD editor help.

    RAD, and RADPAS can be found by FTP at:
      ftp://ftp.ccnet.com/users/msalomon/rad/

*****************************************************************************
  Instructions:

  -> Pick one of the numbered selections to install the player.

  [1] If you do not use your own timer interrupt procedure:
        Call InstallRADTimer at the beginning of your program.

  [2] If you use an 18.2 times/sec interrupt procedure, and want to play
      either 18.2 or 50 times/sec music:
        (1) Install your timer and exit procedures
        (2) Call InstallRADTimer

  [3] If you use a 50 times/sec interrupt procedure, and want to play either
      18.2 or 50 times/sec music (though 18.2's might sound a tiny bit off):
        (1) Call InstallFastRADTimer
        (2) Install your timer and exit procedures
            (actually, you don't even need an exit procedure here)

  -> Choose a playing method.

     These functions return these error codes:
       RADErrorNone    - No error
       RADErrorTimer   - Timer not installed
       RADErrorInvalid - Not a RAD
       RADErrorVersion - Invalid RAD version
       RADErrorNoFile  - File not found
       RADErrorFileIO  - File I/O error or corrupt RAD
       RADErrorMemory  - Not enough memory

  [1] To play a RAD file or a RAD that is part of a file:
        PlayRADFile (RADFileName : STRING; FileOffset, RADLength : LongInt);
      Notes: You must have RADLength bytes free of heap memory.  If you
             specify a length of zero, it will load all of the rest of the
             file, up to 65528 bytes.  The point of this method is that you
             can store all your music in one file.

  [2] To start playing a RAD that is in memory:
        PlayRADPtr (RADPointer : Pointer);

  -> Cut off the music when your done (or just let it turn off by itself).

  [1] To stop playing the current RAD (if any), and reset the FM chip:
        StopRAD;

  [2] To fade the current RAD:
        FadeRAD (EndVol, Speed : Byte);
      Notes: Speed is the number of clock ticks the fade will take, with the
             fade starting at the current master volume, and ending at
             EndVol.  This procedure will run the fade on the the timer so
             you will not have to wait for it.  If your program ends before
             the fade is done, the fade will stop.  You can wait until
             RADFading turns false.

  -> You may also want ...

      To check if a RAD is currently playing:
        RADPlaying : Boolean;

      To check if a RAD is currently fading:
        RADFading : Boolean;

      To set the master volume:
        RADVolume (Volume : Byte);
      Notes: Volume is a number from 0 (silent) to 64 (loudest).  Master
             volume originates at 64.  If the volume fade is active, it will
             be stopped.

      To pause all music:
        RADPaused : Boolean;
      Notes: All music is stopped while this variable is true.  A call to a
             PlayRad procedure will not unpause music.

****************************************************************************}
UNIT revrad;
{$G+,I-}

INTERFACE

CONST
  { Error codes }
  RADErrorNone    = 0; { No error            }
  RADErrorAdlib   = 1; { Adlib not installed }
  RADErrorTimer   = 2; { Timer not installed }
  RADErrorInvalid = 3; { Not a RAD           }
  RADErrorVersion = 4; { Invalid RAD version }
  RADErrorNoFile  = 5; { File not found      }
  RADErrorFileIO  = 6; { File I/O error      }
  RADErrorMemory  = 7; { Not enough memory   }

  RADPaused : Boolean = False;

PROCEDURE InstallRADTimer;
PROCEDURE InstallFastRADTimer;
FUNCTION PlayRADPtr (RADPointer : Pointer) : Byte;
FUNCTION PlayRADFile (RADFileName : STRING;
  FileOffset, RADLength : LongInt) : Byte;
FUNCTION RadFading : Boolean;
FUNCTION RadPlaying : Boolean;
PROCEDURE StopRAD;
PROCEDURE FadeRAD (EndVol, Speed : Byte);
PROCEDURE RADVolume (Volume : Byte);
Procedure stopradandkillfile(name:string);
Procedure revPlayRADFile(name:string);
Procedure revPlayRADpointer(name:string; temp:pointer);
Procedure stopradandkillpointer;

IMPLEMENTATION

USES
  Crt,revdat,revconst;

CONST
  { Tracker commands }
  cmPortamentoUp  =  1;                  { Portamento up                    }
  cmPortamentoDwn =  2;                  { Portamento down                  }
  cmToneSlide     =  3;                  { Tone Slide: xx is speed of slide }
  cmToneVolSlide  =  5;                  { Tone slide of 00 + Vol. Slide    }
  cmVolSlide      = 10;                  { Volume Slide: <50=down, >50=up   }
  cmSetVol        = 12;                  { set volume                       }
  cmJumpToLine    = 13;                  { Jump to line in next track       }
  cmSetSpeed      = 15;                  { set speed                        }

  FreqStart = $156;                 { low end of frequency in each octave   }
  FreqEnd   = $2AE;                 { high end of frequency in each octave  }
  FreqRange = FreqEnd-FreqStart;

  AdlibPort : Word = $0388;                       { default Adlib base port }

  ChannelOffs : ARRAY [0..8] OF Byte =
    ($20,$21,$22,$28,$29,$2A,$30,$31,$32);

  NoteFreq : ARRAY [1..12] OF Word =
    ($16B,$181,$198,$1B0,$1CA,$1E5,                              { 156h = C }
     $202,$220,$241,$263,$287,$2AE);

  RADTimer : Boolean = False;
  PlayingRADFile : Boolean = False;
  RADIsPlaying : Boolean = False;

  MasterFadeAdd : Integer = 0;
  MasterVolume : Byte = 64;

VAR
  RADPlay50, RadInt50, RADAlways50 : Boolean;
  RADSegment, RADOffset : Word;
  OldInt, OldExitProc : Pointer;
  TimerCnt, TimerSteps : Word;

  { Playing a file }
  PlayingRADFilePtr : Pointer;
  PlayingRADFileLength : Word;

  InstPtrs : ARRAY [1..31] OF Word;      { offsets of instrument data       }

  Old43 : ARRAY [0..8] OF Byte;          { record of 43..   register values }
  OldA0 : ARRAY [0..8] OF Byte;          { record of A0..A8 register values }
  OldB0 : ARRAY [0..8] OF Byte;          { record of B0..B8 register values }

  ToneSlideSpeed : ARRAY [0..8] OF Byte; { speed of tone slide              }
  ToneSlideFreqL : ARRAY [0..8] OF Byte; { destination freq. of tone slide  }
  ToneSlideFreqH : ARRAY [0..8] OF Byte;
  ToneSlide : ARRAY [0..8] OF Byte;      { tone slide flag                  }
  PortSlide : ARRAY [0..8] OF Byte;      { portamento slide                 }
  VolSlide : ARRAY [0..8] OF Byte;       { volume slide                     }

  Speed : Byte;                          { speed (n/50Hz) of tune           }
  SpeedCnt : Byte;                       { counter used for deriving speed  }

  OrderSize : Word;                      { no. of entries in Order List     }
  OrderList : Word;                      { offset in module of Order List   }
  OrderPos : Word;                       { current position in Order List   }

  PatternList : Word;           { offset of pattern offset table in module  }
  PatternPos : Word;            { offset to current line in current pattern }
  Line : Byte;                  { current line being played (usually +1)    }

  MasterFadePos, MasterFadeEnd : Byte;
  AdlibPresent : Boolean;
{relativity update}

Procedure revPlayRADFile(name:string);
var size:word;
begin
extractfilefromdat(name+radext,rad_file);
playradfile(name+radext,0,0);
end;

Procedure stopradandkillfile(name:string);
begin
stoprad;
DeleteDatFile(name+radext);
end;

Procedure revPlayRADpointer(name:string; temp:pointer);
var size:word;
begin
extractpointerfromdat(name+radext,rad_file,temp,size);
PlayRADPtr (temp);
end;

Procedure stopradandkillpointer;
begin
stoprad;
end;

{relativity update}

PROCEDURE Adlib; ASSEMBLER;
  { Outputs a value to an ADLIB register }
  { IN: AH - register no.
        AL - value }

  ASM
    PUSH AX
    PUSH DX
    MOV DX,AdlibPort
    XCHG AH,AL
    OUT DX,AL
    IN AL,DX
    IN AL,DX
    IN AL,DX
    IN AL,DX
    IN AL,DX
    IN AL,DX
    INC DX
    MOV AL,AH
    OUT DX,AL
    DEC DX
    MOV AH,22
  @la:
    IN AL,DX
    DEC AH
    JNZ @la
    POP DX
    POP AX
  END;

PROCEDURE GetFreq; ASSEMBLER;
  { Returns the current absolute frequency of channel }
  {   IN: SI - channel
     OUT: AX - frequency
    USES: CX,DX }

  ASM
    MOV CL,[OFFSET OldA0+SI]
    MOV CH,[OFFSET OldB0+SI]
    AND CH,3                                   { mask to get high frequency }
    SUB CX,FreqStart
    MOV AL,[OFFSET OldB0+SI]
    SHR AL,2
    AND AX,7                                   { mask to get octave         }
    MOV DX,FreqRange
    MUL DX
    ADD AX,CX
  END;

PROCEDURE SetFreq; ASSEMBLER;
  { Sets the channel's frequency }
  {   IN: AX - absolute frequency
          SI - channel
    USES: CX, DX }

  ASM
    MOV CX,FreqRange
    XOR DX,DX
    DIV CX                          { extracts octave in AX and freq. in DX }
    ADD DX,FreqStart
    MOV AH,[OFFSET OldB0+SI]
    AND AH,$E0                      { keep old toggles                      }
    SHL AL,2                        { move octave to correct bit position   }
    OR AL,AH                        { insert octave                         }
    OR AL,DH                        { insert high frequency                 }
    MOV AH,BH
    ADD AH,$B0
    MOV [OFFSET OldB0+SI],AL
    CALL Adlib
    SUB AH,$10
    MOV AL,DL                       { low frequency                         }
    MOV [OFFSET OldA0+SI],AL
    JMP Adlib
  END;

PROCEDURE SetVolume; ASSEMBLER;
  { Outputs a value to an ADLIB register }
  { IN: CL - channel to set volume on
        CH - new volume }

  ASM
    PUSH AX
    PUSH BX
    XOR BX,BX
    MOV BL,CL

    { Apply master volume }
    MOV AL,MasterVolume
    MUL CH
    SHR AX,6 { DIV 64 }
    CMP AX,64                               { ensure volume is within range }
    JB @lb
    MOV AL,63
  @lb:

    MOV AH,[OFFSET Old43+BX]                { get old 43.. value            }
    AND AH,$C0                              { mask out volume bits          }
    XOR AL,$3F
    OR AL,AH                                { insert volume                 }
    MOV [OFFSET Old43+BX],AL                { keep new 43.. value           }
    MOV AH,[OFFSET ChannelOffs+BX]
    ADD AH,$23
    CALL Adlib                              { write new volume into Adlib   }
    POP BX
    POP AX
  END;

PROCEDURE SetOneMasterVolume; ASSEMBLER;
  { Set actual volume of channel }
  { IN: CL - channel }

  ASM
    PUSH BX
    PUSH CX
    XOR BX,BX
    MOV BL,CL
    MOV CH,[OFFSET Old43+BX]
    AND CH,$3F
    XOR CH,$3F
    CALL SetVolume
    POP CX
    POP BX
  END;

PROCEDURE SetMasterVolume; ASSEMBLER;

  ASM
    MOV CL,8
  @NextVol:
    CALL SetOneMasterVolume
    DEC CL
    JNS @NextVol
  END;

PROCEDURE UpdateNotes; ASSEMBLER;
  { Check each channel for ongoing effects to update }

  ASM
    XOR BH,BH                               { channel index                 }
    XOR SI,SI
  @la:                                      { process portamentos           }
    MOV BL,[OFFSET PortSlide+SI]
    OR BL,BL
    JZ @lb                                  { no slide for this channel     }
    CALL GetFreq
    MOV CH,BL
    SAR CX,8                                { sign extend 8bit->16bit       }
    ADD AX,CX
    CALL SetFreq                            { process volume slides         }
  @lb:
    MOV CH,[OFFSET VolSlide+SI]
    MOV CL,[OFFSET Old43+SI]                { contains current volume       }
    AND CL,$3F
    XOR CL,$3F
    OR CH,CH
    JZ @lc
    JNS @lba
    SUB CL,CH                               { slide volume up               }
    CMP CL,64
    JB @lbb
    MOV CL,63
    JMP @lbb
  @lba:                                     { slide volume down             }
    SUB CL,CH
    JNS @lbb
    XOR CL,CL
  @lbb:
    MOV CH,CL
    MOV CL,BH                               { channel to set                }
    CALL SetVolume
  @lc:                                      { process tone slides           }
    CMP BYTE PTR [OFFSET ToneSlide+SI],0
    JZ @lx                                  { no tone slide                 }
    MOV BL,[OFFSET ToneSlideSpeed+SI]       { shouldn't get wiped uc        }
    CALL GetFreq                            { get current absolute freq.    }
    MOV DH,BL                               { sign extend speed/direction   }
    SAR DX,8
    MOV CL,[OFFSET ToneSlideFreqL+SI]       { get destination frequency     }
    MOV CH,[OFFSET ToneSlideFreqH+SI]
    CMP AX,CX
    JZ @le                                  { already at destination?!      }
    JA @ld                                  { tone slide down               }
    ADD AX,DX                               { doing a tone slide up }
    CMP AX,CX
    JB @lg                                  { still under destination       }
    JMP @le                                 { reached destination           }
  @ld:                                      { doing a tone slide down       }
    SUB AX,DX
    CMP AX,CX
    JA @lg                         { still over destination                 }
  @le:                             { reached destination so stop tone slide }
    MOV AX,CX                      { clip it onto destination               }
    MOV BYTE PTR [OFFSET ToneSlide+SI],0
                                   { disables tone slide                    }
  @lg:
    CALL SetFreq                   { write new frequency back to channel    }
  @lx:
    INC BH
    INC SI
    CMP SI,9
    JB @la
  END;

PROCEDURE LoadInst; ASSEMBLER;
  { Load in instrument data into a given channel. }
  { IN: CL - channel to load instrument into (0..8)
        DL - instrument no. (1..31) }

  ASM
    PUSH AX
    PUSH BX
    PUSH SI
    MOV SI,CX
    AND SI,$FF
    XOR BX,BX
    MOV BL,DL
    DEC BX
    ADD BX,BX
    MOV BX,[OFFSET InstPtrs+BX]                    { get instrument offset  }
    OR BX,BX
    JZ @lx                                         { no instrument data ?!  }
    MOV AL,ES:[BX+2]
    MOV [OFFSET Old43+SI],AL                       { old 43.. value         }
    MOV AH,[OFFSET ChannelOffs+SI]                 { Adlib register offsets }
    MOV DL,4
  @la:
    MOV AL,ES:[BX+1]
    CALL Adlib                                     { load carrier           }
    ADD AH,3
    MOV AL,ES:[BX]
    CALL Adlib                                     { load modulator         }
    ADD BX,2
    ADD AH,$20-3
    DEC DL
    JNZ @la
    ADD AH,$40                                     { do E0 range now        }
    MOV AL,ES:[BX+2]
    CALL Adlib
    ADD AH,3
    MOV AL,ES:[BX+1]
    CALL Adlib
    MOV AH,$C0
    ADD AH,CL
    MOV AL,ES:[BX]
    CALL Adlib
  @lx:
    POP SI
    POP BX
    POP AX
  END;

PROCEDURE PlayNote; ASSEMBLER;
  { Plays a note on a channel }
  {  IN: AL - Octave (high nibble), Note (low nibble)
         AH - instrument (high nibble), command (low nibble)
         CL - channel to play note on (0..8)
         CH - parameter byte if command is non-zero
    OUT: CARRY - set if a line is to be jumped to
         AX - line to jump to if CARRY set }

  ASM
    MOV DI,CX
    AND DI,15
    MOV DH,AH
    AND DH,15                            { command                          }
    OR AL,AL
    JZ @lb                               { no note playing, process command }
    CMP DH,cmToneSlide                   { check to see if we are actually
                                           performing a tone slide          }
    JNZ @lt                              { nope, play note                  }
                                      { note/octave are used as parameters
                                        then (instrument ignored)           }
    MOV BX,AX
    AND BX,15                         { note                                }
    SHR AL,4
    AND AX,7                          { octave                              }
    DEC BX                            { we want 1..12                       }
    CMP BX,12
    JAE @lx                           { not a valid note (probably KEY-OFF) }
    PUSH DX
    MOV DX,FreqRange
    IMUL DX                           { scale octave                        }
    POP DX
    ADD BX,BX
    ADD AX,[OFFSET NoteFreq+BX]       { add frequency of this note          }
    SUB AX,FreqStart                  { so range starts from zero           }
    MOV [OFFSET ToneSlideFreqL+DI],AL { destination frequency               }
    MOV [OFFSET ToneSlideFreqH+DI],AH
    MOV BYTE PTR [OFFSET ToneSlide+DI],1        { switch tone slide on      }
    OR CH,CH
    JZ @lx { use last speed setting }
    MOV [OFFSET ToneSlideSpeed+DI],CH           { set tone slide speed      }
    JMP @lx
  @lt:                                          { KEY-OFF the previous note }
    PUSH AX
    MOV AL,[OFFSET OldB0+DI]                    { old register value        }
    AND AL,NOT $20                              { clear KEY-ON bit          }
    MOV [OFFSET OldB0+DI],AL        { so slides after KEYOFF work correctly }
    MOV AH,CL
    ADD AH,$B0
    CALL Adlib
    POP AX
    MOV DL,AH                               { load instrument (if any)      }
    ADD AL,AL
    RCR DL,1
    SHR DL,3                                { instrument no.                }
    JZ @la                                  { no instrument to load         }
    CALL LoadInst
  @la:                                      { load note into channel        }
    MOV BL,AL
    AND BX,15*2                             { note * 2                      }
    CMP BX,15*2
    JZ @lb                                  { just a KEY-OFF so we're done  }

    CALL SetOneMasterVolume

    MOV BX,[OFFSET NoteFreq-2+BX]           { frequency of note (BX-1)      }
    SHR AL,3                                { octave                        }
    AND AL,7*4
    OR AL,$20                               { KEY-ON                        }
    OR AL,BH                                { Frequency high byte           }
    MOV AH,$B0
    ADD AH,CL
    MOV [OFFSET OldB0+DI],AL                { record the register value     }
    PUSH AX
    SUB AH,$10
    MOV AL,BL                               { Frequency low byte            }
    MOV [OFFSET OldA0+DI],AL
    CALL Adlib
    POP AX
    CALL Adlib
                                            { process command (if any), DH
                                              has command, CH has parameter }
  @lb:
    XOR BX,BX
    MOV BL,DH                               { command                       }
    ADD BX,BX
    MOV AX,cs:[OFFSET @Effects+BX]
    JMP AX
  @lx:
    CLC
  @lxx:
    RET
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @PortUp:                                                  { Portamento up }
    MOV [OFFSET PortSlide+DI],CH
    JMP @lx
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @PortDown:                                              { Portamento down }
    NEG CH
    MOV [OFFSET PortSlide+DI],CH
    JMP @lx
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @ToneSlide:                       { Tone slide to note (no note supplied) }
    OR CH,CH                        { parameter has speed of tone slide     }
    JZ @lja                         { keep last tone slide speed            }
    MOV [OFFSET ToneSlideSpeed+DI],CH
  @lja:
    MOV BYTE PTR [OFFSET ToneSlide+DI],1                    { tone slide on }
    JMP @lx
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @ToneVolSlide:                       { Volume slide & Volume + Tone Slide }
  @VolSlide:
    CMP CH,50                          { <50 = slide down, >50 = slide up   }
    JB @lga
    SUB CH,50
    NEG CH
  @lga:
    MOV [OFFSET VolSlide+DI],CH
    CMP DH,cmToneVolSlide              { just plain volume slide            }
    JNZ @lx
    MOV CH,1
    MOV [OFFSET ToneSlide+DI],CH       { tone slide on                      }
    JMP @lx
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @SetVolume:                          { Set volume                         }
    CALL SetVolume                     { CH has volume, CL has channel      }
    JMP @lx
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @JumpToLine:                         { jump to line in next pattern       }
    CMP CH,64
    JAE @lx                            { ignore as it is invalid            }
    XOR AX,AX
    MOV AL,CH
    STC
    RET                                { skip rest of channels              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @SetSpeed:                                                    { Set speed }
    MOV Speed,CH
    JMP @lx
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  @Effects:
    DW @lx
    DW @PortUp
    DW @PortDown
    DW @ToneSlide
    DW @lx
    DW @ToneVolSlide
    DW @lx
    DW @lx
    DW @lx
    DW @lx
    DW @VolSlide
    DW @lx
    DW @SetVolume
    DW @JumpToLine
    DW @lx
    DW @SetSpeed
  END;

PROCEDURE NextPattern; ASSEMBLER;
  { Advances pointers to next pattern in order list }

  ASM
    MOV BX,OrderPos
    INC BX
    CMP BX,OrderSize
    JB @ld
    XOR BX,BX                             { end of tune, move back to start }
  @ld:
    MOV OrderPos,BX
    MOV SI,OrderList
    MOV BL,ES:[SI+BX]                     { no. of next pattern             }
    TEST BL,$80
    JZ @lda
    AND BL,$7F
    JMP @ld                               { bit 7 = jump to new order       }
  @lda:
    MOV SI,PatternList
    ADD BX,BX
    MOV SI,ES:[SI+BX]                     { offset of next pattern          }
    ADD SI,RADOffset   { *** Adjust pattern offset to RADPointer offset *** }
    MOV PatternPos,SI
    OR SI,SI
  END;

PROCEDURE PlayMusic; ASSEMBLER;
  { This routine does the actual playing. It MUST be called 18.2 or 50 times
    per second (whichever the music is) to maintain accurate music playback }

  ASM
    { Update master volume fade }
    MOV BX,MasterFadeAdd
    OR BX,BX
    JZ @NoFade
    MOV AL,MasterFadePos
    MOV AH,0
    JGE @FadeOut

  {@FadeIn:}
    SUB AX,BX
    MOV MasterFadePos,AL
    ADD MasterVolume,AH
    JC @FadeStop
    MOV AL,MasterVolume
    CMP AL,MasterFadeEnd
    JA @FadeStop
    JMP @FadeEnd

  @FadeOut:
    ADD AX,BX
    MOV MasterFadePos,AL
    SUB MasterVolume,AH
    JC @FadeStop
    MOV AL,MasterVolume
    CMP AL,MasterFadeEnd
    JB @FadeStop
    JMP @FadeEnd

  @FadeStop:
    MOV AL,MasterFadeEnd
    MOV MasterVolume,AL
    MOV MasterFadeAdd,0
  @FadeEnd:
    CALL SetMasterVolume
  @NoFade:

    CMP RADIsPlaying,0
    JZ @lxx
    CMP SpeedCnt,0
    JZ @la                                           { play a line of music }
    DEC SpeedCnt
    JMP @lx                  { no new line, so just update any effects      }
  @la:                       { switch off any effects that are in operation }
    MOV SI,8
    XOR AL,AL
  @laa:
    MOV [OFFSET PortSlide+SI],AL                         { reset any slides }
    MOV [OFFSET VolSlide+SI],AL                          { reset any slides }
    MOV [OFFSET ToneSlide+SI],AL                         { reset any slides }
    DEC SI
    JNS @laa
    MOV ES,RADSegment     { playing a new line, PatternPos should have been }
    MOV SI,PatternPos     { set-up already                                  }
    OR SI,SI
    JZ @lb                                  { rest of this pattern is blank }
    MOV AL,ES:[SI]                          { line indicator                }
    AND AL,$7F                              { eliminate bit 7               }
    CMP AL,Line                             { is this current line?         }
    JNZ @lb                                 { haven't reached it yet        }
    TEST BYTE PTR ES:[SI],$80               { last line?                    }
    JZ @lc                                  { no, still more to check       }
    MOV PatternPos,0                        { mark rest of pattern as blank }
  @lc:
    INC SI                                  { move to first channel         }
  @lf:                                      { play channels                 }
    MOV CL,ES:[SI]                          { channel we are processing     }
    PUSH CX
    AND CL,$7F                            { get rid of bit 7                }
    MOV AX,ES:[SI+1]                      { AL=octave/note, AH=inst/command }
    ADD SI,3
    TEST AH,15                     { if there's a cmd, there'll be a param. }
    JZ @le                         { no parameter byte                      }
    MOV CH,ES:[SI]                 { read parameter                         }
    INC SI
  @le:
    CALL PlayNote                  { play the note                          }
    POP CX
    JC @lg                         { skip rest of line, AX has new line     }
    TEST CL,$80                    { last channel to play?                  }
    JZ @lf                         { not yet                                }
    MOV PatternPos,SI              { keep position in crunched track        }
  @lb:                             { update pointers                        }
    MOV AL,Speed                   { needs to be set AFTER note playing     }
    DEC AL
    MOV SpeedCnt,AL                { for new speeds to take effect!         }
    INC Line
    CMP Line,64                    { end of pattern?                        }
    JB @lx                         { nope                                   }
    MOV Line,0                     { top of next pattern                    }
    CALL NextPattern
    JMP @lx
  @lg:                             { jump to line AX                        }
    MOV BL,Speed                   { needs to be set AFTER note playing     }
    MOV SpeedCnt,BL                { for new speeds to take effect!         }
    MOV Line,AL
    CALL NextPattern               { find start of next pattern             }
    JZ @lx                         { there isn't any data in next pattern   }
  @ll:                             { find line that is greater or equal to
                                     the current line                       }
    MOV CL,ES:[SI]                 { line id.                               }
    AND CL,$7F                     { ignore bit 7                           }
    CMP CL,AL
    JAE @lh                        { found line                             }
    TEST BYTE PTR ES:[SI],$80
    JZ @li                         { not last line                          }
    XOR SI,SI
    JMP @lh                        { ignore rest of pattern as it's last    }
  @li:                             { skip to next line definition           }
    INC SI
  @lj:
    MOV CL,ES:[SI]
    ADD SI,3
    TEST BYTE PTR ES:[SI-1],15     { is there a valid command?              }
    JZ @lk
    INC SI                         { skip parameter                         }
  @lk:
    ADD CL,CL
    JNC @lj                        { wasn't last channel spec.              }
    JMP @ll                        { check next line                        }
  @lh:
    MOV PatternPos,SI
  @lx:
    CALL UpdateNotes               { V1.1: This is the right place          }
  @lxx:
  END;

PROCEDURE GoOldInt (OldIntVector : Pointer);

  INLINE (
    $5B/                          { POP BX - Get Segment                    }
    $58/                          { POP AX - Get Offset                     }
    $89/                          { MOV SP,BP - Get secondary stack pointer }
    $EC/
    $5D/                          { POP BP                                  }
    $07/                          { POP ES                                  }
    $1F/                          { POP DS                                  }
    $5F/                          { POP DI                                  }
    $5E/                          { POP SI                                  }
    $5A/                          { POP DX                                  }
    $59/                          { POP CX                                  }
    $87/                          { XCHG SP,BP                              }
    $EC/
    $87/                          { XCHG [BP],BX                            }
    $5E/
    $00/
    $87/                          { XCHG [BP+2],AX                          }
    $46/
    $02/
    $87/                          { XCHG SP,BP                              }
    $EC/
    $CB);                         { RETF                                    }

PROCEDURE PlayerInt; INTERRUPT;

  BEGIN
    Inc (TimerCnt, TimerSteps);
    IF (RADPlay50 OR NOT RadInt50 OR (TimerCnt < TimerSteps)) AND
      NOT RadPaused
    THEN
      PlayMusic;         { If rad is 50 or if timer is 18, call every time. }
    IF NOT RadInt50 OR (TimerCnt < TimerSteps) THEN
      GoOldInt (OldInt); { If timer not 50 then call every time.            }
    ASM
      MOV AL,$20
      OUT $20,AL
    END
  END;

PROCEDURE ResetTimer; ASSEMBLER;
  { Sets the timer to the normal speed }

  ASM
    MOV AL,$36
    OUT $43,AL
    XOR AL,AL
    OUT $40,AL
    OUT $40,AL
  END;

PROCEDURE UninstallRADTimer;

  BEGIN
    IF RADTimer THEN
      BEGIN
        ASM                                          { Reset interrupt      }
          CLI
          XOR AX,AX
          MOV ES,AX
          MOV AX,WORD PTR OldInt
          MOV ES:[8*4],AX
          MOV AX,WORD PTR OldInt+2
          MOV ES:2[8*4],AX
          TEST RADInt50,1
          JZ @NoTimerFix
          CALL ResetTimer
        @NoTimerFix:
          STI
        END;
        RadTimer := False
      END
  END;

PROCEDURE NewExitProc; FAR;

  BEGIN
    ExitProc := OldExitProc;                         { Reset exit procedure }
    StopRad;
    UninstallRADTimer
  END;

PROCEDURE SetFM; ASSEMBLER;
  { Set value to Adlib register }
  { IN: AL - Adlib register
        AH - value }

  ASM
    MOV DX,AdlibPort
    OUT DX,AL    {Select register}
    MOV CX,6
  @Cycle1:
    IN AL,DX
    LOOP @Cycle1 {Wait 3.3 æs}
    MOV AL,AH
    INC DX       {DataPort}
    OUT DX,AL    {Set register with value}
    MOV CX,35
    DEC DX       {Port}
  @Cycle2:
    IN AL,DX
    LOOP @Cycle2 {Wait 23 æs}
  END;

PROCEDURE GetFMStatus; ASSEMBLER; {Get Adlib status register}

  ASM
    MOV DX,AdlibPort
    IN AL,DX
  END;

PROCEDURE ResetAdlib; ASSEMBLER;

  ASM
    MOV AX,$2000
  @la:
    CALL Adlib
    INC AH
    CMP AH,$43
    JB @la

    MOV AL,$3F { Lowest volume for $43..$55 }
  @lb:
    CALL Adlib
    INC AH
    CMP AH,$55
    JB @lb

    MOV AL,0
  @lc:
    CALL Adlib
    INC AH
    CMP AH,$F6
    JB @lc
  END;

PROCEDURE AdlibTest;

  VAR
    Stat1, Stat2 : Byte;

  BEGIN
    ASM
      MOV AX,$6004
      CALL SetFM
      MOV AX,$8004
      CALL SetFM
      CALL GetFMStatus
      MOV Stat1,AL
      MOV AX,$FF02
      CALL SetFM
      MOV AX,$2104
      CALL SetFM
    END;
    Delay (80);
    ASM
      CALL GetFMStatus
      MOV Stat2,AL
      MOV AX,$6004
      CALL SetFM
      MOV AX,$8004
      CALL SetFM
      MOV BL,Stat1
      MOV BH,Stat2
      AND BX,$E0E0
      MOV AL,0
      CMP BX,$C000
      JNZ @NoAdlib
      MOV AL,1
    @NoAdlib:
      MOV AdlibPresent,AL
    END;
    IF AdlibPresent THEN
      ResetAdlib
  END;

PROCEDURE SetTimer; ASSEMBLER;
  { Set the timer speed }
  { IN: AX - Number of clock ticks per second }

  ASM
    MOV BX,AX
    MOV AX,13432                                        { 1193180 MOD 65536 }
    MOV DX,18                                           { 1193180 DIV 65536 }
    DIV BX
    MOV BX,AX
    MOV AL,$36
    OUT $43,AL
    MOV AL,BL
    OUT $40,AL
    MOV AL,BH
    OUT $40,AL
    MOV TimerSteps,BX                      { for keeping 18.2 timer correct }
    MOV TimerCnt,0                         { counter                        }
  END;

PROCEDURE InstallRADTimer; ASSEMBLER;
  { Install interrupt }

  ASM
    CMP RadTimer,1
    JZ @End
    CALL AdlibTest
    CLI
    XOR AX,AX                                          { Get old interrupt  }
    MOV ES,AX
    MOV AX,ES:[8*4]
    MOV WORD PTR OldInt,AX
    MOV AX,ES:2[8*4]
    MOV WORD PTR OldInt+2,AX
    MOV AX,WORD PTR ExitProc                           { Set exit procedure }
    MOV WORD PTR OldExitProc,AX
    MOV AX,WORD PTR ExitProc+2
    MOV WORD PTR OldExitProc+2,AX
    MOV AX,OFFSET NewExitProc
    MOV WORD PTR ExitProc,AX
    MOV WORD PTR ExitProc+2,CS
    MOV WORD PTR ES:[8*4],OFFSET PlayerInt             { Set interrupt      }
    MOV ES:2[8*4],CS
    MOV RADTimer,1
    MOV RADAlways50,0
    MOV RADInt50,0
    STI
  @End:
  END;

PROCEDURE InstallFastRADTimer; ASSEMBLER;
  { Install interrupt }

  ASM
    CMP RadTimer,1
    JZ @End
    CALL AdlibTest
    CLI
    XOR AX,AX                                          { Get old interrupt  }
    MOV ES,AX
    MOV AX,ES:[8*4]
    MOV WORD PTR OldInt,AX
    MOV AX,ES:2[8*4]
    MOV WORD PTR OldInt+2,AX
    MOV AX,WORD PTR ExitProc                           { Set exit procedure }
    MOV WORD PTR OldExitProc,AX
    MOV AX,WORD PTR ExitProc+2
    MOV WORD PTR OldExitProc+2,AX
    MOV AX,OFFSET NewExitProc
    MOV WORD PTR ExitProc,AX
    MOV WORD PTR ExitProc+2,CS
    MOV WORD PTR ES:[8*4],OFFSET PlayerInt             { Set interrupt      }
    MOV ES:2[8*4],CS
    MOV AX,50
    CALL SetTimer
    MOV RADTimer,1
    MOV RADAlways50,1
    MOV RADInt50,1
    STI
  @End:
  END;

PROCEDURE StopRAD;
  { Stop music playback }

  BEGIN
    RADIsPlaying := False;
    IF PlayingRadFile THEN
      BEGIN
        FreeMem (PlayingRADFilePtr, PlayingRADFileLength);
        PlayingRadFile := False
      END;
    ResetAdlib
  END;

FUNCTION PlayRADPtr (RADPointer : Pointer) : Byte; ASSEMBLER;
  { Initializes the player }

  ASM
    MOV BL,RADErrorAdlib
    CMP AdlibPresent,0
    JZ @Err
    MOV BL,RADErrorTimer                                  { Error code      }
    CMP RadTimer,0
    JZ @Err                                           { Timer not installed }
    CALL StopRAD { Stop already playing music and make adlib ready for tune }
                 { initialize certain Adlib registers that aren't changed:  }
    MOV AX,$0120                                          { allow waveforms }
    CALL Adlib
    MOV AX,$0800
    CALL Adlib
    MOV AH,$bd                                            { no drums, etc.  }
    CALL Adlib
    LES SI,RADPointer
    MOV RADSegment,ES
    MOV RADOffset,SI
    MOV BL,RADErrorInvalid         { Next error code                        }
    CMP WORD PTR ES:[SI],'AR'      { check to see if it is a RAD file first }
    JNZ @Err
    CMP WORD PTR ES:[SI+2],' D'
    JNZ @Err
    MOV BL,RADErrorVersion         { Next error code                        }
    CMP BYTE PTR ES:[SI+16],$10    { correct version?                       }
    JNZ @Err
    ADD SI,17
    MOV AL,ES:[SI]                 { read initial speed                     }
    MOV AH,AL
    AND AL,$1F
    MOV Speed,AL
    INC SI
    TEST AH,$40                    { set if 18.2 times/sec instead of 50    }
    JZ @Is50
  {18.2:}
    MOV RadPlay50,0
    CMP RADAlways50,1
    JZ @SkipTimer
    CMP RADInt50,0
    JZ @SkipTimer
    CLI
    MOV RADInt50,0
    CALL ResetTimer
    STI
    JMP @SkipTimer                                { This line added in v1.3 }
  @Is50:
    MOV RadPlay50,1
    CMP RADInt50,1
    JZ @SkipTimer
    CLI
    MOV RADInt50,1
    PUSH AX
    MOV AX,50
    CALL SetTimer
    POP AX
    STI
  @SkipTimer:                        { see if there's a description to skip }
    TEST AH,$80                      { description flag                     }
    JZ @lc                           { no description                       }
    XOR AL,AL
    JMP @le
  @ld:
    INC SI
  @le:
    CMP ES:[SI],AL                   { look for null-termination            }
    JNZ @ld
    INC SI                           { move past null                       }
  @lc:                               { create table of instrument pointers  }
    XOR BX,BX
  @la:
    MOV BL,ES:[SI]                   { instrument no.                       }
    INC SI
    ADD BX,BX
    JZ @lb                           { no more instruments                  }
    MOV [OFFSET InstPtrs+BX-2],SI    { record pointer to instrument         }
    ADD SI,11
    JMP @la
  @lb:                               { record offset of order list          }
    XOR AX,AX
    MOV AL,ES:[SI]                   { no. of orders in order-list          }
    MOV OrderSize,AX
    INC SI
    MOV OrderList,SI
    XOR BX,BX
    MOV BL,ES:[SI]                   { first pattern to play                }
    ADD BX,BX
    ADD SI,AX                        { move to end of list                  }
    MOV PatternList,SI               { record table of pattern offsets      }
    MOV AX,ES:[SI+BX]                { first pattern offset                 }
    ADD AX,RADOffset   { *** Adjust pattern offset to RADPointer offset *** }
    MOV PatternPos,AX                { pointer to first pattern             }
    XOR AX,AX                        { initial pointers                     }
    MOV OrderPos,AX                  { start at position 0.                 }
    MOV SpeedCnt,AL
    MOV Line,AL                      { start at line 0                      }
    MOV AL,0
    MOV RADIsPlaying,1
    JMP @lx                          { successful initialization            }
  @err:
    MOV AL,BL
  @lx:
  END;

FUNCTION PlayRADFile (RADFileName : STRING;
  FileOffset, RADLength : LongInt) : Byte;
  { Play a RAD file }

  VAR
    RADFile : FILE;
    ErrorCode : Byte;

  BEGIN
    IF NOT RADTimer THEN
      BEGIN
        PlayRADFile := RADErrorTimer;
        Exit
      END;
    StopRAD;
    Assign (RADFile, RADFileName);
    Reset (RADFile, 1);
    IF IOResult <> 0 THEN
      BEGIN
        PlayRADFile := RADErrorNoFile;
        Exit
      END;
    IF RADLength = 0 THEN
      IF FileSize (RADFile)-FileOffset < 65528 THEN      { Find max. length }
        RADLength := FileSize (RADFile)-FileOffset
      ELSE
        RADLength := 65528;
    IF (RADLength = 0) OR (FileSize (RADFile) < (FileOffset+RADLength)) THEN
      BEGIN                                             { File too short    }
        Close (RADFile);
        PlayRADFile := RADErrorFileIO;
        Exit
      END;
    Seek (RADFile, FileOffset);
    IF IOResult <> 0 THEN
      BEGIN
        Close (RADFile);
        PlayRADFile := RADErrorFileIO;
        Exit
      END;
    IF MaxAvail < RADLength THEN                        { Not enough memory }
      BEGIN
        Close (RADFile);
        PlayRADFile := RADErrorMemory;
        Exit
      END;
    GetMem (PlayingRADFilePtr, RADLength);
    BlockRead (RADFile, PlayingRADFilePtr^, RADLength);
    IF IOResult <> 0 THEN
      BEGIN
        Close (RADFile);
        PlayRADFile := RADErrorFileIO;
        Exit
      END;
    Close (RADFile);
    IF IOResult <> 0 THEN
      BEGIN
        PlayRADFile := RADErrorFileIO;
        Exit
      END;
    ErrorCode := PlayRADPtr (PlayingRADFilePtr);        { Play this pointer }
    PlayRADFile := ErrorCode;
    IF ErrorCode = 0 THEN                               { Ok, no error      }
      BEGIN
        PlayingRADFile := True;
        PlayingRADFileLength := RADLength
      END
    ELSE
      FreeMem (PlayingRADFilePtr, RADLength) { Error, release it }
  END;

FUNCTION RadFading : Boolean;

  BEGIN
    RadFading := MasterFadeAdd <> 0
  END;

FUNCTION RadPlaying : Boolean;

  BEGIN
    RadPlaying := RadIsPlaying
  END;

PROCEDURE FadeRAD (EndVol, Speed : Byte);

  BEGIN
    IF RadIsPlaying AND (Speed <> 0) AND
      (MasterVolume <> EndVol) AND (EndVol IN [0..64])
    THEN
      BEGIN
        MasterFadePos := 0;
        MasterFadeAdd := (MasterVolume-EndVol)*256 DIV Speed;
        MasterFadeEnd := EndVol
      END
    ELSE
      StopRAD
  END;

PROCEDURE RADVolume (Volume : Byte);

  BEGIN
    IF Volume IN [0..64] THEN
      BEGIN
        MasterFadeAdd := 0;
        MasterVolume := Volume;
        SetMasterVolume
      END
  END;

END.
