unit revhsc;
interface
uses  Crt,Dos,RevDat,revconst{,playhsc}
     {advhsc};

procedure StartHSCBackgroundMusic(filename:st12);
procedure StopHSCBackgroundMusic(filename:st12);
implementation
{var  Music : HSC_obj;}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Plays HSC Sound Files In The Background (Soundcard).    *)
(****************************************************************************)

procedure StartHSCBackgroundMusic(filename:st12);
begin
{  Music.Fade;
  Music.Done;}
{  ExtractFileFromDat(filename+HSCEXT);
    LoadSong(filename+HSCEXT);
  PlaySong;
 { IF Music.LoadFile (filename+HSCEXT) THEN
    Music.Start;}
end;

procedure StopHSCBackgroundMusic(filename:st12);
begin
{  FadeSong;
  StopSong;
  ClearMem;
{  Music.Fade;
  Music.Done;}
  DeleteDatFile(filename+HSCEXT);
end;


end.