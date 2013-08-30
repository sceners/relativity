(*  sound.pas - Digital Sound Interface Kit V1.01a unit file

    Copyright 1993,94 Carlos Hasan
*)

unit Sound;

interface

const
  (* Misc Values *)
  MAXVOICES   = 16;
  MAXTRACKS   = 16;
  MAXSAMPLES  = 100;
  MAXORDERS   = 128;
  MINPERIOD   = 28;
  MAXPERIOD   = 6848;
  MIDCPERIOD  = 428;
  MIDCFREQ    = 8363;

  (* Sound Cards *)
  ID_NONE     = 0;
  ID_SB       = 1;
  ID_SB201    = 2;
  ID_SBPRO    = 3;
  ID_SB16     = 4;
  ID_GUS      = 5;

  (* Types of RAM *)
  RAM_NONE    = 0;
  RAM_SYSTEM  = 1;
  RAM_CARD    = 2;

  (* Error Values *)
  ERR_OK      = 0;
  ERR_NORAM   = 1;
  ERR_NODRAM  = 2;
  ERR_NOFILE  = 3;
  ERR_FORMAT  = 4;
  ERR_ACCESS  = 5;

  (* Playing Status *)
  PS_STOPPED  = 0;
  PS_PLAYING  = 1;
  PS_PAUSED   = 2;

  (* Pattern Break Values *)
  PB_NONE     = 0;
  PB_BREAK    = 1;
  PB_JUMP     = 2;

  (* DSM File Block IDs *)
  ID_RIFF     = $46464952;
  ID_DSMF     = $464D5344;
  ID_SONG     = $474E4F53;
  ID_INST     = $54534E49;
  ID_PATT     = $54544150;

  (* WAV File Block IDs *)
  ID_WAVE     = $45564157;
  ID_FMT      = $20746D66;
  ID_DATA     = $61746164;

  (* Panning Values *)
  PAN_LEFT    = $00;
  PAN_RIGHT   = $80;
  PAN_DOLBY   = $A4;

  (* Inst Bit Flags *)
  INST_LOOPED = $01;
  INST_SIGNED = $02;
  INST_PACKED = $04;

type
  (* Basic Data Types *)
  dword = longint;

  (* RIFF Block Header Formats *)
  DSMHeader = record
    ID          : dword;
    Length      : dword;
    FileType    : dword;
  end;

  DSMBlock = record
    ID          : dword;
    Length      : dword;
  end;

  (* DSM File Block Formats *)
  DSMSong = record
    SongName    : array [0..27] of char;
    Version     : word;
    Flags       : word;
    Pad         : dword;
    NumOrders   : word;
    NumSamples  : word;
    NumPatterns : word;
    NumChannels : word;
    GlobalVolume: byte;
    MasterVolume: byte;
    InitTempo   : byte;
    InitBPM     : byte;
    ChanMap     : array [0..Pred(MAXTRACKS)] of byte;
    Orders      : array [0..Pred(MAXORDERS)] of byte;
  end;

  PDSMInst = ^DSMInst;
  DSMInst = record
    FileName    : array [0..12] of char;
    Flags       : word;
    Volume      : byte;
    Length      : dword;
    LoopStart   : dword;
    LoopEnd     : dword;
    Address     : pointer;
    MidCRate    : word;
    Period      : word;
    SampleName  : array [0..27] of char;
  end;

  PDSMPatt = ^DSMPatt;
  DSMPatt = record
    Length      : word;
    Data        : array [0..0] of byte;
  end;

  (* WAV File Block Formats *)
  DSMWave = record
    SampleFormat: word;
    NumChannels : word;
    PlayRate    : dword;
    BytesPerSec : dword;
    Pad         : word;
    BitsPerSmpl : word;
  end;

  (* Internal DSM format *)
  PDSM = ^DSM;
  DSM = record
    Song        : DSMSong;
    Inst        : array [0..Pred(MAXSAMPLES)] of PDSMInst;
    Patt        : array [0..Pred(MAXORDERS)] of PDSMPatt;
  end;

  (* Sound Card Configuration *)
  DSMCard = record
    CardID      : byte;
    Flags       : byte;
    IOAddr      : word;
    IRQNum      : byte;
    DRQNum      : byte;
    MixRate     : word;
  end;

  (* Internal Track structure *)
  Track = record
    NoteEvent   : word;
    VolumeEvent : byte;
    Note        : byte;
    Sample      : byte;
    Volume      : byte;
    Effect      : word;
    Period      : word;
    WantedPeriod: word;
    Rate        : word;
    VibrPos     : byte;
    VibrParm    : byte;
    TremPos     : byte;
    TremParm    : byte;
    ToneSpeed   : byte;
    EQBar       : byte;
    ArpTable    : array [0..2] of word;
  end;

  (* Internal Music structure *)
  PDSMMusicInfo = ^DSMMusicInfo;
  DSMMusicInfo = record
    ActiveTracks  : word;
    Tracks        : array [0..Pred(MAXTRACKS)] of Track;
    OrderPosition : byte;
    OrderLength   : byte;
    PatternNumber : byte;
    PatternRow    : byte;
    BreakFlag     : byte;
    Tempo         : byte;
    TempoCount    : byte;
    BPM           : byte;
    CardStatus    : word;
    PlayStatus    : word;
    SongPtr       : pointer;
    SyncMark      : byte;
  end;

(* Sound System API Routines *)
function DSMInit(var Card:DSMCard):boolean;
procedure DSMDone;
procedure DSMPoll;
procedure DSMSetupVoices(MaxVoices:word; MasterVolume:word);
procedure DSMStopVoices;
function DSMTypeOfRAM:word;
function DSMAllocSampleData(Inst:PDSMInst):boolean;
procedure DSMFreeSampleData(Inst:PDSMInst);
procedure DSMPlaySample(Voice:word; Inst:PDSMInst);
procedure DSMStopSample(Voice:word);
procedure DSMSetPeriod(Voice:word; Period:word);
procedure DSMSetVolume(Voice:word; Volume:word);
procedure DSMSetBalance(Voice:word; Balance:word);
procedure DSMSetMusicVolume(Volume:word);
procedure DSMSetSoundVolume(Volume:word);
procedure DSMPlayMusic(Module:PDSM);
procedure DSMStopMusic;
function DSMGetMusicStatus:word;
function DSMGetMusicInfo:PDSMMusicInfo;

implementation

{$L SB.OBJ}
{$L GUS.OBJ}
{$L NULL.OBJ}
{$L AUDIO.OBJ}
{$L PLAYER.OBJ}

(* Sound Devices Internal Interfaces *)
procedure SBAudioDevice; external;
procedure GUSAudioDevice; external;
procedure NULLAudioDevice; external;

function DSMInit(var Card:DSMCard):boolean; external;
procedure DSMDone; external;
procedure DSMPoll; external;
procedure DSMSetupVoices(MaxVoices:word; MasterVolume:word); external;
procedure DSMStopVoices; external;
function DSMTypeOfRAM:word; external;
function DSMAllocSampleData(Inst:PDSMInst):boolean; external;
procedure DSMFreeSampleData(Inst:PDSMInst); external;
procedure DSMPlaySample(Voice:word; Inst:PDSMInst); external;
procedure DSMStopSample(Voice:word); external;
procedure DSMSetPeriod(Voice:word; Period:word); external;
procedure DSMSetVolume(Voice:word; Volume:word); external;
procedure DSMSetBalance(Voice:word; Balance:word); external;
procedure DSMSetMusicVolume(Volume:word); external;
procedure DSMSetSoundVolume(Volume:word); external;
procedure DSMPlayMusic(Module:PDSM); external;
procedure DSMStopMusic; external;
function DSMGetMusicStatus:word; external;
function DSMGetMusicInfo:PDSMMusicInfo; external;

end.
