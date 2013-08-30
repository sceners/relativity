unit revhsc;
interface
uses  Crt,Dos,RevDat,AdvHSC,revconst;

procedure StartHSCBackgroundMusic(filename:st12);
procedure StopHSCBackgroundMusic(filename:st12);
implementation

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Plays HSC Sound Files In The Background (Soundcard).    *)
(****************************************************************************)

procedure StartHSCBackgroundMusic(filename:st12);
begin
  ExtractFileFromDat(filename+HSCEXT);
  LoadSong(filename+HSCEXT);
  PlaySong;
end;

procedure StopHSCBackgroundMusic(filename:st12);
begin
  FadeSong;
  StopSong;
  ClearMem;
  DeleteDatFile(filename+HSCEXT);
end;


end.