{$X+}
unit CDPla1;
interface
{$IfDef Windows}
{$C PRELOAD}
uses {CDVars,} CD_UnitP, WinCRT, WinProcs;
{$Else}
uses strings{,CD_Vars}, CDUnit_P, CRT, Drivers;
{$EndIf}

Type
  TotPlayRec = Record
     Frames,
     Seconds,
     Minutes,
     Nada     : Byte;
  End;

Var
  GoodDisk : Boolean;
  SaveExit   : Pointer;
  OldMode    : Word;
  CurrentTrack,
  StartTrack,
  EndTrack   : Integer;
  TotPlay    : TotPlayRec;
  TrackInfo  : Array[1..30] of PAudioTrackInfo;

procedure Setup;

implementation

uses revconst;

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;


procedure DrawScreen;
Const TStr = '%03d:%02d';
      VStr = '%1d.%2d';
Var   FStr : PChar;
      NStr : String;
      Param: Array[1..2] of LongInt;
      Code : Integer;
begin
  Param[1] := MSCDEX_Version.Major;
  Param[2] := MSCDEX_Version.Minor;

{$IfDef Windows}
  wvsPrintf(FStr, VStr, Param);
{$Else}
  FormatStr(NStr, VStr, Param);
{$EndIf}

  WriteLn('MSCDEX Version ', NStr);
  Str(NumberOfCD, NStr);
  WriteLn('Number of CD ROM Drives is: '+Nstr);
  WriteLn('First CD Drive Letter is  : '+Chr(FirstCD+65));
  WriteLn('There are ' + LeadingZero(EndTrack - StartTrack + 1) + ' Tracks on this disk');
  Code := 1;
end;
{***********************************************************************}

{***********************************************************************}


procedure Setup;
Var
  LeadOut,
  StartP,
  TotalPlayTime    : LongInt;
  I     : Integer;
  A,B,C : LongInt;
  Track : Byte;
  EA    : Array[1..4] of Byte;
  SP,EP : LongInt;

Begin
  FillChar(AudioDiskInfo, SizeOf(AudioDiskInfo), #0);
  DeviceStatus;
  If Audio THEN
  Begin
    Audio_Disk_Info;
    TotalPlayTime := 0;
    LeadOut := AudioDiskInfo.LeadOutTrack;

    StartTrack := AudioDiskInfo.LowestTrack;
    EndTrack := AudioDiskInfo.HighestTrack;
    CurrentTrack := StartTrack;
    I := StartTrack-1;

    Repeat               { Checks if Audio Track or Data Track }
        Inc(I);
        Track := I;
        Audio_Track_Info(StartP, Track);
    Until (Track AND 64 = 0) OR (I = EndTrack);

    StartTrack := I;

    For I := StartTrack to EndTrack DO
      Begin
        Track := I;
        Audio_Track_Info(StartP, Track);
        New(TrackInfo[I]);
        FillChar(TrackInfo[I]^, SizeOf(TrackInfo[I]^), #0);
        TrackInfo[I]^.Track := I;
        TrackInfo[I]^.StartPoint := StartP;
        TrackInfo[I]^.TrackControl := Track;
      End;

    For I := StartTrack to EndTrack - 1 DO
        TrackInfo[I]^.EndPoint := TrackInfo[I+1]^.StartPoint;
    TrackInfo[EndTrack]^.EndPoint := LeadOut;

    For I := StartTrack to EndTrack DO
        Move(TrackInfo[I]^.EndPoint, TrackInfo[I]^.Frames, 4);

    TrackInfo[StartTrack]^.PlayMin := TrackInfo[StartTrack]^.Minutes;
    TrackInfo[StartTrack]^.PlaySec := TrackInfo[StartTrack]^.Seconds - 2;

    For I := StartTrack + 1 to EndTrack DO
      Begin
        EP := (TrackInfo[I]^.Minutes * 60) + TrackInfo[I]^.Seconds;
        SP := (TrackInfo[I-1]^.Minutes * 60) + TrackInfo[I-1]^.Seconds;
        EP := EP - SP;
        TrackInfo[I]^.PlayMin := EP DIV 60;
        TrackInfo[I]^.PlaySec := EP Mod 60;
      End;

    TotalPlayTime := AudioDiskInfo.LeadOutTrack - TrackInfo[StartTrack]^.StartPoint;
    Move(TotalPlayTime, TotPlay, 4);
  End;
  if audio then cd:=true
  else cd:=false;

end;

{***********************************************************************}

{Begin
  Setup;
  If Audio THEN
  If Playing THEN
     StopAudio
  ELSE
     Begin
       StopAudio;
{       TrackInfo[startTrack]^.StartPoint:=2000;}
{       Play_Audio(TrackInfo[startTrack]^.StartPoint,
             TrackInfo[EndTrack]^.EndPoint);
       Audio_Status_Info;
       DrawScreen;
     End
  ELSE
      WriteLn('This is not an Audio CD');
{      WriteLn('UPC Code is: ', UPC_Code);}
end.