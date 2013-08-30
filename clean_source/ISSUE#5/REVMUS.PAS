unit revmus;
interface
Procedure StopMusic(Name,Name2:string);
procedure PlayMusic(Name,Name2:string);
implementation
uses revhsc,revrad,revconst{,advhsc};

procedure StopMusic(Name,Name2:string);
begin
{ClearMem;}
if name2='RAD' then
   stopradandkill(name);
if name2='HSC' then
   StopHSCBackgroundMusic(name);
end;

Procedure PlayMusic(Name,Name2:string);
begin
if name2='RAD' then
   RevPlayRADFile (name);
if name2='HSC' then
   StartHSCBackgroundMusic(name);
end;

end.