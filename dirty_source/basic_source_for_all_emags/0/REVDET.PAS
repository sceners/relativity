unit revdet;
interface

Procedure det_adlib;
procedure det_mouse;
Procedure det_sb;

implementation
uses revmouse,revconst,detectso,revrad;
procedure det_mouse;
begin
     if InstallMouse then
        mouse:=true
     else
         mouse:=false;
end;

Procedure det_sb;
begin
  if DetSoundBlaster then
     begin
          adlib:=true;
     end
     else
     begin
          adlib:=false;
          voc:=false;
          voc_start:=false;
     end;
end;

Procedure det_adlib;
begin
     if not adlib then
        mustype:=2
     else
         mustype:=1;
     if adlib then
        InstallRADTimer;
end;

end.