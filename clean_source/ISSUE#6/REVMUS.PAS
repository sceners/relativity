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
   stopradandkillpointer;
if name2='HSC' then
   StopHSCBackgroundMusic(name);
end;

Procedure PlayMusic(Name,Name2:string);
begin
if name2='RAD' then
   revPlayRADpointer(name,music);
if name2='HSC' then
   StartHSCBackgroundMusic(name);
end;

end.