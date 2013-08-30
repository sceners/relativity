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
var size:word;
begin
Extractpointerfromdat(config^.longfile,article_file,article,size);
long(config^.longfile,1,size);
end;

procedure PhazePre;
var i:byte;
begin
  Reset80x25VideoScreen;
  if adlib then
  PlayMusic(config^.music[config^.radmusdef,1],config^.music[config^.radmusdef,2]);
  if config^.long then longbin;
  DisplayGIF(config^.dolby_pic,dolby_file,0,0);
  for i:= 1 to intropics do
      DisplayGIF(config^.intro[i],gif_file,0,0);
  Reset80x25VideoScreen;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Checks For Configuration File, Dosen't Work In TP IDE!! *)
(****************************************************************************)

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

end.
