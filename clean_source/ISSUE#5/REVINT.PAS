unit revint;
interface

function FileExists(filename: string) : Boolean;
{procedure InitializeDetectionPhase;
procedure PrintDetectionPhase;}
procedure PhazePre;

implementation
uses revgfx,dos,crt,revmus,revconst,revdat,revansi,revinit,revset,revmem,revgif,revlong;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Preperation Phases For The Introduction & Detection.    *)
(****************************************************************************)
Procedure Longbin;
begin
ExtractFileFromDat(config^.introfile);
long(config^.introfile,1);
end;

procedure PhazePre;
begin
  Reset80x25VideoScreen;
  textbackground(black);
  TextColor(7);
{  PrintDetectionPhase;}
  delay(1000);
  Reset80x25VideoScreen;
  hidecursor;
  if adlib then
  PlayMusic(config^.music[musdef,1],config^.music[musdef,2]);
  longbin;
  hidecursor;
  IF (config^.openinggif<>'') and VGA then
  begin
  ExtractFileFromDat(config^.openinggif);
  DisplayGIF(config^.openinggif);
  DeleteDatFile(config^.openinggif);
  end;
  IF (config^.openinggif2<>'') and VGA then
  begin
  ExtractFileFromDat(config^.openinggif2);
  DisplayGIF(config^.openinggif2);
  DeleteDatFile(config^.openinggif2);
  end;
  IF (config^.openinggif3<>'') and VGA then
  begin
  ExtractFileFromDat(config^.openinggif3);
  DisplayGIF(config^.openinggif3);
  DeleteDatFile(config^.openinggif3);
  end;
  Reset80x25VideoScreen;
  FadedownRGBScreen;
  Reset80x25VideoScreen;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Checks For Configuration File, Dosen't Work In TP IDE!! *)
(****************************************************************************)

procedure CheckCFG;
var k:char;
begin
  if not FileExists(ConfigFile) then
  begin
    SetMidasCfg;
    Writeln;
    Writeln('Press any key to continue...');
    k:=readkey;
  end;
end;


function FileExists(filename: string) : Boolean;
var
 f: file;
begin
  {$I-}
    Assign(f, FileName);
    FileMode := 0;
    Reset(f);
    Close(f);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Controls The Initialization Phases. (EXE And WAD Files) *)
(****************************************************************************)

procedure InitializeDetectionPhase;
begin
  GetMainMemory;
  CheckMainMemory;
  FlushDiskCaches;
  CheckXMSEMSMemory;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Starting And Ending Initialization Phases (Detection).  *)
(****************************************************************************)

{procedure PrintDetectionPhase;
begin
  HideCursor;
  Writeln;
  Writeln('CPU IDENTIFICATION ROUTINES HAVE BEEN EXCLUDED IN THIS ISSUE.');
  Writeln('--------------------------------------------------------------------------------');
  Writeln('Type Rev97-04.EXE /? for Help');
  Writeln;
  InitializeDetectionPhase;
  Writeln;
  Writeln('Last Updated: July 7, 1997');
  Writeln;
  Writeln('--------------------------------------------------------------------------------');
end;      }

end.
