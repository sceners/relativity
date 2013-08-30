{$g+}
unit revtech;
interface
uses crt,dos;


var
  version:char;                       { version of the ADF file format }
  pallette:array[0..63,1..3] of byte; { pallete (color) information }
  old_pal:array[0..63,1..3] of byte;  { save the old pallette }
  vga_font:array[1..4096] of char;    { vga font data }
{  vbuffer:array[1..4000] of char;     { video memory buffer }

{  ext:char;                           { used for reading extended keys }
 { exit_stat:integer;                  { exit the scoller? }
{  pointer:integer;                    { line number }
{  max_lines:integer;                  { number of lines }

{  f:file;                             { the file }
{  count1,count2:byte;                 { Junk counters }
  regs:registers;                     { pascal registers }

{Procedure GetPal(Color,R,G,B : Byte);}
Procedure SetPal(Color,R,G,B : Byte);
Procedure GetPal(Color:byte; var R,G,B : Byte);
Procedure Set_Ice_Color;
Procedure Remove_Ice_Color;
Procedure Set_Character_Width;
procedure Set_Vga_Font;
procedure Set_Textmode;
procedure cursor_on;
procedure cursor_off;
procedure chbrght;

implementation
uses revconst;

procedure chbrght;
var j:integer;
begin
  for j:= 1 to 15 do
  begin
  SetPal(j,config^.scr[j,1],config^.scr[j,2],config^.scr[j,3]);
  end;
end;


Procedure GetPal(Color:byte; var R,G,B : Byte);
{ this get's the RGB intensities of COLOR }
Begin
   Port[$3c7] := Color;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;

Procedure SetPal(Color,R,G,B : Byte);
{ this set's the RGB intensities of COLOR }
Begin
   Port[$3c8] := Color;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;

Procedure Set_Ice_Color;assembler;
asm
{iCE Color is a means of disabling the BLINK attribute and using the upper
8 colors (#8/Dark Grey to #15/Bright White) as background colors.  This is
the default setup for all .ADF and ANSI/2 files.}
  mov bl,0000h
  mov ax,1003h
  int 10h
end;

Procedure Remove_Ice_Color;assembler;
asm
  mov bl,0001h
  mov ax,1003h
  int 10h
end;

Procedure Set_Character_Width;assembler;
{ by default the first 32 characters have an extra vertical scanline.  This
is realy unefficient when manipulating fonts, so this procedure sets all the
characters to an even 8x16 font}
asm
  mov     dx,03c4h
  mov     ax,0100h
  out     dx,ax

  mov     dx,03c4h
  mov     ax,0301h
  out     dx,ax

  mov     dx,03c2h
  mov     al,063h
  out     dx,al

  mov     dx,03c4h
  mov     ax,0300h
  out     dx,ax

  mov     dx,03d4h
  mov     ax,4f09h
  out     dx,ax
end;

procedure Set_Vga_Font;
{font_data is a 4096 byte array that contains the entire font data to be
passed to the interrupt}
begin
  regs.bx:=(16*256);{0x1000; {16 scanline font}
  regs.es:=seg(vga_font); {segment of the font data}
  regs.bp:=ofs(vga_font); {offset of the font data}
  regs.ax:=((17*256)+16); {0x1110; {int 10h subfunction}
  regs.cx:=256; {256 characters}
  regs.dx:=0; {start with char #0}
  Intr(16, Regs); {load actual data $10}
end;

procedure Set_Textmode;assembler;
asm
  mov ax,00003h  {reset to textmode}
  int 010h
end;

procedure cursor_on;assembler;
{ turn on the cursor }
asm
  mov    cx,$0708
  mov    ah,$01
  int    $10
end;

procedure cursor_off;assembler;
{ turn off the cursor }
asm
  mov    ch,$20
  mov    ah,$01
  int    $10
end;


end.