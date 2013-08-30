{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O+,R-,S-,V-,X+}
{ graph -- module om snel vga-toeren uit te halen}
unit UGraph;
interface {=================================================================}

uses dos,crt;
{
  This is a stand-alone unit :
   graph is NOT needed,
   it is even recommended that you don't use it.
}

type
    uRGB = Record
            Red,Grn,Blu : Byte;
          end;

    uPaletteRegister = Array[0..255] of uRGB;
    uVGAScreen = array[1..200,1..320] of byte;

Procedure uSetMode(mode : byte);
  { set graphics mode }
procedure uPlot(x,y : word; Color : byte);
  { Same as PuxPixel }
procedure uClearPalette(var color : uPaletteRegister);
  { clears all colors of a pallette to black }
Procedure uSetPalette(var Hue : uPaletteRegister);
  { initalizes a palette on screen }
Procedure uGetPalette(var Hue : uPaletteRegister);
procedure uInitPalette1(var color : uPaletteRegister);
  { creates a 4 color pallette red, Green, blue, grey }
procedure uCyclePalette( var Hue : uPaletteRegister);
  { cycles complete palette upward }
procedure uCyclePart(x1,x2 :byte; var Hue : uPaletteRegister);
  { cycles from x1 to x2 }
procedure uCircle(x,y,radius : word; color : byte);
  { draws a (real) circle }
procedure uInitGraphics;
  { graphics initalisation}
procedure uExitGraphics;
  { returns display to textscreen}

function VGAPresent : boolean;
Procedure WaitRetrace;

Var
   TheScreen   : uVGAScreen absolute $A000:0000;
 implementation {============================================================}


var regs : registers ;


{-------------------------------------------------------------------------}
Procedure uSetMode(mode : byte);
  begin
    with regs do
      begin
        AH :=0;
        AL := mode;
      end;
    intr($10,Regs);
  end;

const
  MaxXRes = 320;
  MaxYRes = 200;
  MaxX = (MaxXres-1);
  MaxY = (MaxYres-1);
Var
  XRes, YRes : Integer;

{-------------------------------------------------------------------------}
procedure uPlot(x,y : word; Color : byte);
 begin
   TheScreen[y,x]:=Color;
 end;

{-------------------------------------------------------------------------}
procedure uClearPalette(var color : uPaletteRegister);
Begin
 FillChar(color,768,0);
end;

{$G+}

{-------------------------------------------------------------------------}
Procedure uSetPalette(var  Hue : uPaletteRegister); (* Assembler;
asm
  mov si,offset Hue
  mov cx,256*3
  xor al,al
  mov dx,03c8h
  out dx,al
  inc dx
@lp:
  rep outsb
End;

*)
 begin
  with regs do
    begin
      AX :=$1012;
      BX :=0;
      CX :=256;
      ES := Seg(Hue);
      DX := ofs(Hue);
    end;
      Intr($10,regs);
 end;

{-------------------------------------------------------------------------}

 Procedure uGetPalette(var Hue : uPaletteRegister);
 begin
  with regs do
    begin
      AX :=$1017;
      BX :=0;
      CX :=256;
      ES := Seg(Hue);
      DX := ofs(Hue);
    end;
  Intr($10,regs);
 end;

{-------------------------------------------------------------------------}
procedure uInitPalette1(var color : uPaletteRegister);
VAR
  I : Byte;
Begin
  for i :=0 to 63 do
   with Color[i] do
    begin
      Red := i ;
      Grn := i ;
      Blu := i ;
    end;
  for i :=64  to 127 do
   with Color[i] do
    begin
      Red := i-64 ;
      Grn := 0 ;
      Blu := 0 ;
    end;
  for i :=128 to 191   do
   with Color[i] do
    begin
      Red := 0 ;
      Grn := i-128;
      Blu := 0 ;
    end;
  for i :=192 to 255   do
   with Color[i] do
    begin
      Red := 0 ;
      Grn := 0 ;
      Blu := i-192;
    end;
end;

{-------------------------------------------------------------------------}
procedure uCyclePalette( var Hue : uPaletteRegister);
var
  i   : byte;
  Tmp : uRGB;
begin
  Tmp:=Hue[0];
  move(Hue[2],Hue[1],765);
  Hue[255]:=Tmp;
  uSetPalette(Hue);
end;

{-------------------------------------------------------------------------}
procedure uCyclePart(x1,x2 :byte; var Hue : uPaletteRegister);
{ 0<= x1 < x2 <= 255  wordt aangenomen, niet gecontroleerd
  om snelheidsredenen }
var
  Tmp : uRGB;
begin
  Tmp:=Hue[x1];
  Move(Hue[x1+1],Hue[x1],3*(x2-x1));    { alles in 1 keer, lekker snel ! }
  Hue[x2]:=Tmp;
  uSetPalette(Hue);
end;

{-------------------------------------------------------------------------}
procedure uInitGraphics;
  begin
    uSetMode(19);
  end;

{-------------------------------------------------------------------------}
procedure Swap(var first,second : integer);
var
  temp : integer;
begin
  temp := first;
  first := second;
  second :=temp;
end;

{-------------------------------------------------------------------------}
procedure uCircle(x,y,radius : word; color : byte);
var
 a,af,b,bf,target,r2:integer;
begin
  Target :=0;
  a :=radius;
  b:=0;
  r2:=sqr(radius);
  while a>=b do
    begin
      b:=round(Sqrt(r2-sqr(a)));
      swap(target,b);
      while b <target do
        begin
          af :=(120*a) div 100;
          bf :=(120*b) div 100;
          uplot(x+af,y+b,color);
          uplot(x+bf,y+a,color);
          uplot(x-af,y+b,color);
          uplot(x-bf,y+a,color);
          uplot(x-af,y-b,color);
          uplot(x-bf,y-a,color);
          uplot(x+af,y-b,color);
          uplot(x+bf,y-a,color);
          inc(b);
        end;
      dec(a);
    end
end;

{-------------------------------------------------------------------------}
procedure uExitGraphics;
begin
  uSetMode(3);
end;

{------------------------------------------------------------------------}
Function VGAPresent : boolean;
var
 R : registers;
begin
 with r do
  begin
    AX := $1A00;
    Intr($10,r);
    VGaPresent := (AL = $1A);
  end;
end;

{-------------------------------------------------------------------------}
Procedure WaitRetrace; assembler;
Asm
    mov    DX,3DAh     { Input #1 status register (page 347) }
  @WaitVS1:
    in    AL,DX
    test  AL,08h       { Let him finish this retrace (if any)}
    jnz    @WaitVS1
   @WaitVS2:
    in    AL,DX
    test  AL,08h    { Is it still in display mode ? }
    jz   @WaitVS2   { then wait }  { NEW retrace has begun ! GO ! GO ! GO ! }
end;

begin
end.




