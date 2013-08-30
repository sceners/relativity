{ -----------------------------------   CUT HERE --------------------   }

Unit CD_Vars;

Interface
Type
  ListBuf    = Record
    UnitCode : Byte;
    UnitSeg,
    UnitOfs  : Word;
  end;
  VTOCArray  = Array[1..2048] of Byte;
  DriveByteArray = Array[1..128] of Byte;

  Req_Hdr    = Record
     Len     : Byte;
     SubUnit : Byte;
     Command : Byte;
     Status  : Word;
     Reserved: Array[1..8] of Byte;
  End;

Const
  Init       = 0;
  IoCtlInput = 3;
  InputFlush = 7;
  IOCtlOutput= 12;
  DevOpen    = 13;
  DevClose   = 14;
  ReadLong   = 128;
  ReadLongP  = 130;
  SeekCmd    = 131;
  PlayCD     = 132;
  StopPlay   = 133;
  ResumePlay = 136;

Type

  Audio_Play = Record
    APReq    : Req_Hdr;
    AddrMode : Byte;
    Start    : LongInt;
    NumSecs  : LongInt;
  end;

  IOControlBlock = Record
    IOReq_Hdr : Req_Hdr;
    MediaDesc : Byte;
    TransAddr : Pointer;
    NumBytes  : Word;
    StartSec  : Word;
    ReqVol    : Pointer;
    TransBlock: Array[1..130] OF Byte;
  End;

  ReadControl = Record
    IOReq_Hdr : Req_Hdr;
    AddrMode  : Byte;
    TransAddr : Pointer;
    NumSecs   : Word;
    StartSec  : LongInt;
    ReadMode  : Byte;
    IL_Size,
    IL_Skip   : Byte;
  End;

  AudioDiskInfoRec = Record
    LowestTrack    : Byte;
    HighestTrack   : Byte;
    LeadOutTrack   : LongInt;
  End;

  PAudioTrackInfo   = ^AudioTrackInfoRec;
  AudioTrackInfoRec = Record
    Track           : Integer;
    StartPoint      : LongInt;
    EndPoint        : LongInt;
    Frames,
    Seconds,
    Minutes,
    PlayMin,
    PlaySec,
    TrackControl    : Byte;
  end;

  MSCDEX_Ver_Rec = Record
    Major,
    Minor       : Integer;
  End;

  DirBufRec    = Record
     XAR_Len   : Byte;
     FileStart : LongInt;
     BlockSize : Integer;
     FileLen   : LongInt;
     DT        : Byte;
     Flags     : Byte;
     InterSize : Byte;
     InterSkip : Byte;
     VSSN      : Integer;
     NameLen   : Byte;
     NameArray : Array[1..38] of Char;
     FileVer   : Integer;
     SysUseLen : Byte;
     SysUseData: Array[1..220] of Byte;
     FileName  : String[38];
  end;

  Q_Channel_Rec = Record
    Control     : Byte;
    Track       : Byte;
    Index       : Byte;
    Minutes     : Byte;
    Seconds     : Byte;
    Frame       : Byte;
    Zero        : Byte;
    AMinutes    : Byte;
    ASeconds    : Byte;
    AFrame      : Byte;
  End;

Var
  AudioChannel   : Array[1..9] of Byte;
  RedBook,
  Audio,
  DoorOpen,
  DoorLocked,
  AudioManip,
  DiscInDrive    : Boolean;
  AudioDiskInfo  : AudioDiskInfoRec;
  DriverList     : Array[1..26] of ListBuf;
  NumberOfCD     : Integer;
  FirstCD        : Integer;
  UnitList       : Array[1..26] of Byte;
  MSCDEX_Version : MSCDEX_Ver_Rec;
  QChannelInfo   : Q_Channel_Rec;
  Busy,
  Playing,
  Paused         : Boolean;
  Last_Start,
  Last_End       : LongInt;
  DirBuf         : DirBufRec;

Implementation

Begin
  FillChar(DriverList, SizeOf(DriverList), #0);
  FillChar(UnitList, SizeOf(UnitList), #0);
  NumberOfCD  := 0;
  FirstCD  := 0;
  MSCDEX_Version.Major := 0;
  MSCDEX_Version.Minor := 0;
end.
end.