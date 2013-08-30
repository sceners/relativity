unit revwin;
interface
Procedure VerCheck;
Procedure Change_VMM_Title(Title:String); { Max String Length = 29+Nul }
Procedure Change_APP_Title(Title:String); { Max String Length = 79+Nul }
Function Win3X : Boolean;
Function WinVer :Word;
implementation

USES DOS,CRT,revconst;
Var
  Regs : Registers;    { to hold register info }
  Title_ : String;

Function Win3X : Boolean;
{ Routine to determine if Windows is currently running }
begin
  Regs.AX := $4680;    { Win 3.x Standard check }
  Intr($2F, Regs);     { Call Int 2F }
  if Regs.AX <> 0 then { if AX = 0 Win in Real mode }
  begin                { else check For enhanced mode }
    Regs.AX := $1600;  { Win 3.x Enhanced check }
    Intr($2F, Regs);   { Call Int 2F }
    if Regs.AL in [$00,$80,$01,$FF] then { Check returned value }
      Win3X := False   { Nope not installed }
    else
      Win3X := True;   { Ya it is }
  end
  else
    Win3X := True;     { Return True }
end;


Function WinVer :Word;
{  Returns a Word containing the version of Win Running }
{  Should only be used after checking For Win installed }
{  Or value returned will be meaningless                }
begin
  Regs.AX := $1600;    {  Enhanced mode check }
  Intr($2F, Regs);     {  Call Int 2F         }
  WinVer := Regs.AX;   {  Return proper value }
end;

Procedure Change_APP_Title(Title:String); { Max String Length = 79+Nul }
 begin
  Title_:=Title;
  Asm
   Mov Ax,168Eh
   Mov Dx,0000h
   Mov Di,OffSet Title_+1
   int 2fh
  End;
 end;

Procedure Change_VMM_Title(Title:String); { Max String Length = 29+Nul }
 begin
  Title_:=Title;
  Asm
   Mov Ax,168Eh
   Mov Dx,0001h
   Mov Di,OffSet Title_+1
   Int 2fh
  End;
end;

Procedure VerCheck;
begin
  if Win3X then
  begin
       if lo(winver) = 4 then
       begin
            winon:=true;
            Change_VMM_Title('Relativity Emag');
            Change_APP_Title('Thanks to : MuadDib, Enkrypt And All The Hard Working Members (/j #relativity)');
       end;
{    Writeln('Version Running is : ', Lo(WinVer), '.', Hi(WinVer));}
  end
  else
  begin
       winon:=false;
  end;
end;



end.