unit revint;
interface

function FileExists(filename: string) : Boolean;
procedure InitializeDetectionPhase;
procedure PrintDetectionPhase;
procedure PhazePre;

implementation
uses revgfx,dos,crt,revmus,revconst,revdat,revansi,revinit,revset,revmem,revgif,
     cdunit_p;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Preperation Phases For The Introduction & Detection.    *)
(****************************************************************************)

procedure PhazePre;
begin
  Reset80x25VideoScreen;
  TextColor(7);
  PrintDetectionPhase;
  delay(1000);
  Reset80x25VideoScreen;
  hidecursor;
  if not playing then
  begin
  if adlib then
  PlayMusic(config^.music[musdef,1],config^.music[musdef,2]);
  end
  else config^.muson:=false;
  IF (openinggif<>'') and VGA then
  begin
  ExtractFileFromDat(openinggif);
  DisplayGIF(openinggif);
  DeleteDatFile(openinggif);
  end;
  IF (openinggif2<>'') and VGA then
  begin
  ExtractFileFromDat(openinggif2);
  DisplayGIF(openinggif2);
  DeleteDatFile(openinggif2);
  end;

  Reset80x25VideoScreen;
  FadedownRGBScreen;
  Reset80x25VideoScreen;
  HideCursor;
  ExtractFileFromDat(DEFMENUFILE);
  Displayansi(DEFMENUFILE);
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

procedure PrintDetectionPhase;
begin
  HideCursor;
  Writeln;
  Writeln('CPU IDENTIFICATION ROUTINES HAVE BEEN EXCLUDED IN THIS ISSUE.');
  Writeln('--------------------------------------------------------------------------------');
  Writeln('Type Rev-03.EXE /? for Help');
  Writeln;
  InitializeDetectionPhase;
  Writeln;
  Writeln('Last Updated: May 18, 1997');
  Writeln;
  Writeln('--------------------------------------------------------------------------------');
end;

end.
