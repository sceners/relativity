 {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
 {                    Bells, Whistles, and Sound Boards                     }
 {       Copyright (c) 1993-95, Edward Schlunder. All Rights Reserved.      }
 {ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}
 { MSE_TP.PAS - Turbo Pascal <-> MSE Interface Unit file.                   }
 {              Requires TPX_MSE.OBJ to compile.                            }
 {              Written by Alex Chalfin (1994-95)                           }
 {                                                                          }
 {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Unit MSE_TP1;
{$G+}  { Enable 286 Instructions }

Interface

Type

  GDMHeader = Record
    IDString     : Longint;              { 'GDMş' = $FE4D4447        }
    SongTitle    : Array[0..31] of Char; { Title of the Song         }
    SongMusician : Array[0..31] of Char; { generally not used        }
    EOF          : Array[0..2] of Char;  { DOS EOF marker, 13,10,26  }
    IDString2    : Longint;              { 'GMFS' = $53464D47        }
    FormatMajor  : Byte;                 { Format major version num  }
    FormatMinor  : Byte;                 { Format minor version num  }
    TrackerID    : Word;                 { Tracker's ID              }
    TrackerMajor : Byte;                 { Tracker's major ver num   }
    TrackerMinor : Byte;                 { Tracker's minor ver num   }
    PanMap       : Array[0..31] of Byte; { Default panning locations }
    InitVol      : Byte;                 { Default music volume      }
    InitTempo    : Byte;                 { Default music tempo       }
    InitBPM      : Byte;                 { Default music BPM         }
    FormOrigin   : Word;                 { Format origin             }
    OrderOffset  : Longint;
    NumOrders    : Byte;
    PatternOffset: Longint;
    NumPatterns  : Byte;
    OffsetSamHead: Longint;
    OffsetSamData: Longint;
    NumSamples   : Byte;
    OffsetMessage: Longint;
    MessageLen   : Longint;
    OffsetScrolly: Longint;
    ScrollyLen   : Word;
    OffsetGraph  : Longint;
    GraphLen     : Word;
  End;

  SamHeader = Record
    SamName      : Array[0..31] of Byte;   { Instrument name         }
    FileName     : Array[0..11] of Byte;   { Sample Filename         }
    EmsHandle    : Byte;                   { Ems Handle used         }
    Length       : Longint;                { Length of sample        }
    LoopBegin    : Longint;                { Offset of Loop Start    }
    LoopEnd      : Longint;                { Offset of Loop End      }
    Flags        : Byte;                   { Sample Flags            }
    C4Hertz      : Word;                   { Middle C Playback Hertz }
    Volume       : Byte;                   { Sample's Default Volume }
    Pan          : Byte;                   { this is not really used }
    Segment      : Word;                   { Segment of sample mem   }
  End;

  ChannelType = Record
    MixFlags       : Byte;             { Mixing Flags                }
    MixLBeg        : Word;             { Offset of loop beginning    }
    MixLEnd        : Word;             { Offset of loop ending       }
    MixFinetune    : Word;             { Finetune (C-4 Hertz)        }
    MixRate        : Longint;          { Sample rate/period of sound }
    MixSeg         : Word;             { Segment of sound            }
    MixOff         : Word;             { Offset of next byte to mix  }
    MixVolume      : Byte;             { Volume of channel           }
    MixInc         : Word;             { Incrementation for each sample. MSB.LSB }
    MixIncRemain   : Byte;             { Remainder from last increment }
    MusSample      : Byte;             { Currently played sample number }
    MusNote        : Byte;             { Currently played note       }
    MusOctave      : Byte;             { Currently played octave     }
    MusEffect1     : Byte;             { Music Effect Number (1)**   }
    MusEffDat1     : Word;             { Music Effect Data   (1)**   }
    MusEffect2     : Byte;             { Music Effect Number (2)*    }
    MusEffDat2     : Word;             { Music Effect Data   (2)*    }
    MusEffect3     : Byte;             { Music Effect Number (3)     }
    MusEffDat3     : Word;             { Music Effect Data   (3)     }
    MusEffect4     : Byte;             { Music Effect Number (4)     }
    MusEffDat4     : Word;             { Music Effect Data   (4)     }
    VUMeter        : Byte;             { Volume Meter value          }
    MusVolRate     : Word;             { Old Vol Slide Speed         }
    MusPortaRate   : Word;             { Old Porta to Note Speed     }
    MusVibWave     : Byte;             { Vibrato Waveform Select     }
    MusVibPosition : Byte;             { Vibrato Table Position      }
    MusVibSpeed    : Byte;             { Vibrato Speed (x0h)         }
    MusVibDepth    : Byte;             { Vibrato Depth (0yh)         }
    MusTrmWave     : Byte;             { Tremolo Waveform Select     }
    MusTrmPosition : Byte;             { Tremolo Table Position      }
    MusTrmSpeed    : Byte;             { Tremolo Speed               }
    MusTrmDepth    : Byte;             { Tremolo Depth               }
    MusRetrigSpeed : Byte;             { Retrigger speed             }
    MusRetrigSlide : Byte;             { Retrigger volume slide      }
    MusGlissFunk   : Byte;             { Funk It (Invert Loop) Speed }
    MusFunkOffset  : Byte;             { Funk It position            }
    MusWaveStart   : Word;             { Funk It funk pointer (offset into sample) }
    MixPanning     : Byte;             { Pan position                }
    MixHandle      : Byte;             { EMS Handle this sample resides on }
    MixMonoVol     : Byte;             { Mono volume value           }
    MixLftVol      : Byte;             { Left speaker mixing volume  }
    MixRgtVol      : Byte;             { Right speaker mixing volume }
    GUSAddress     : Longint;          { Address of start position in GUS memory }
    MusArpeggio    : Byte;             { Old Arpeggio speed          }
    MusPortaUD     : Byte;             { Old Porta Up/Down speed     }
    Reserved       : Array[0..63] of Char;    { For future expansion }
  End;                                                               

Function LoadMSE(Var FileName : String; FileOfs : Longint; Ovr,
                 BufferSize : Word; Var BaseIO : Word; Var IRQ, DMA : Byte) : Word;
Function DeviceName : String;
Function StartOutput(Channels, Amp : ShortInt) : Word;
Function MixStatus : Word;
Function MusicStatus : Word;
Function MusicBPM(BPM : Byte) : Byte;
Function MusicTempo(Tempo : Byte) : Byte;
Function MusicOrder(Order : Byte) : Byte;
Function MusicPattern(Pat : Byte) : Byte;
Function MusicRow : Byte;
Function MusicLoop(LoopStatus : Byte) : Byte;
Function MusicVolume(Vol : Byte) : Byte;
Function ChannelPan(Chan, Pan : Byte) : Byte;
Function ChannelVU(Chan, Vu : Byte) : Byte;
Function ChannelVol(Channel, NewVol : Byte) : Word;
Function ChannelPos(Channel, NewPos : Word) : Word;
Function LoadGDM(Var Handle : File; FileOfs : Longint; Var Flags : Word; Var GHead) : Word;
Function EmsExist : Boolean;
Procedure GetChannelTable(Chan : Byte; TSeg, TOff : Word);
Procedure FreeMSE;
Procedure StopOutput;
Procedure MixForground;
Procedure SetAutoMix(Mix : Byte);
Procedure StartMusic;
Procedure StopMusic;
Procedure GetSampleTable(Samp : Byte; TSeg, TOff : Word);
Procedure GetMainScope(Var Left, Right : Word);
Procedure UnloadModule;
Procedure PlaySample(Channel, Sample : Byte; Rate : Word; Volume, Pan : Byte);
Procedure PlayNote(Channel, Sample, Octave, Note : Byte);
Procedure AmigaHertz(Hertz : Longint);

Function AllocSample(SamNum : Byte; Var SamHead) : Word;
Function FreeSample(SamNum : Byte) : Word;

Implementation

Const
  EmmIdCode : Array[0..7] of Char = ('E','M','M','X','X','X','X','0');

{$F+}
{$L TPX_MSE.OBJ}
Function LoadMSE(Var FileName : String; FileOfs : Longint; Ovr,
                 BufferSize : Word; Var BaseIO : Word; Var IRQ, DMA : Byte) : Word; External;
Procedure FreeMSE; External;
Function DeviceName : String; External;

Function StartOutput(Channels, Amp : ShortInt) : Word; External;
Procedure StopOutput; External;

Function MixStatus : Word; External;
Procedure MixForground; External;
Procedure SetAutoMix(Mix : Byte); External;

Procedure StartMusic; External;
Procedure StopMusic; External;
Function MusicStatus : Word; External;

Function MusicBPM(BPM : Byte) : Byte; External;
Function MusicTempo(Tempo : Byte) : Byte; External;
Function MusicOrder(Order : Byte) : Byte; External;
Function MusicPattern(Pat : Byte) : Byte; External;
Function MusicRow : Byte; External;
Function MusicLoop(LoopStatus : Byte) : Byte; External;
Function MusicVolume(Vol : Byte) : Byte; External;

Function ChannelPan(Chan, Pan : Byte) : Byte; External;
Function ChannelVU(Chan, Vu : Byte) : Byte; External;
Function ChannelVol(Channel, NewVol : Byte) : Word; External;
Function ChannelPos(Channel, NewPos : Word) : Word; External;

Function LoadGDM(Var Handle : File; FileOfs : Longint; Var Flags : Word; Var GHead) : Word; External;
Procedure UnloadModule; External;

Procedure GetChannelTable(Chan : Byte; TSeg, TOff : Word); External;
Procedure GetSampleTable(Samp : Byte; TSeg, TOff : Word); External;
Procedure GetMainScope(Var Left, Right : Word); External;

Procedure AmigaHertz(Hertz : Longint); External;
Procedure PlaySample(Channel, Sample : Byte; Rate : Word; Volume, Pan : Byte); External;
Procedure PlayNote(Channel, Sample, Octave, Note : Byte); External;

Function AllocSample(SamNum : Byte; Var SamHead) : Word; External;
Function FreeSample(SamNum : Byte) : Word; External;

{$F-}

Function EmsExist : Boolean; Assembler;
{ Checks to see if EMS memory exists }
{ Returns TRUE/FALSE                 }

Asm
  Xor     ax, ax
  Mov     es, ax
  Mov     bx, 19Eh
  Mov     ax, es:[bx]
  Mov     es, ax
  Mov     cl, 8
  Mov     si, 10
  Xor     bx, bx
 @CmpLoop:
  Mov     al, es:[si]
  Cmp     al, Byte Ptr ds:[EmmIdCode+bx]
  Jne     @EmsNoExist
  Inc     si
  Inc     bx
  Dec     cl
  Jnz     @CmpLoop
 @EmsYesExist:
  Mov     ax, 0FFFFh
  Ret
 @EmsNoExist:
  Xor     ax, ax
End;

End.

