{$g+}
unit revtech;
interface
uses crt,dos,revconst;


var
  version:char;                       { version of the ADF file format }
  pallette:array[0..63,1..3] of byte; { pallete (color) information }
  old_pal:array[0..63,1..3] of byte;  { save the old pallette }
  vga_font:array[1..4096] of char;    { vga font data }
  regs:registers;                     { pascal registers }

Procedure SetPal(Color,R,G,B : Byte);
Procedure GetPal(Color:byte; var R,G,B : Byte);
Procedure Set_Ice_Color;
Procedure Remove_Ice_Color;
Procedure Set_Character_Width;
procedure Set_Vga_Font;
procedure Textmode;
procedure cursor_on;
procedure cursor_off;
procedure chbrght(palette:pal);
procedure move32fast(var Source,Dest; Count:word);
function FileExists(FileName: String): Boolean;
Procedure Waitforkey;
procedure dospin;
implementation

procedure dospin;assembler;
asm
  mov    ax,$B800
  mov    es,ax
  mov    word ptr [$0828],$000C
  mov    word ptr [$0820],$00D0
@gloop:  mov    ax,[$0820]
  mov    [$0822],ax
@eloop:  mov    word ptr [$0824],$0039
  mov    word ptr [$0826],$0001
  mov    di,$0798
  mov    ax,[$0828]
  mov    [$081E],ax
@cloop:  mov    cx,[$0824]
  dec    cx
  push   ds
  push   es
  pop    ds
  mov    si,di
  add    si,$0002
  cld
  rep movsw
  pop    ds
  mov    cx,[$0826]
  push   ds
  push   es
  pop    ds
  mov    si,di
  sub    si,$00A0
  mov    ax,$00A2
  cld
@aloop:  movsw
  sub    di,ax
  sub    si,ax
  loop   @aloop
  pop    ds
  mov    cx,[$0824]
  push   ds
  push   es
  pop    ds
  mov    si,di
  sub    si,$0002
  std
  rep movsw
  pop    ds
  mov    cx,[$0826]
  inc    cx
  push   ds
  push   es
  pop    ds
  mov    si,di
  add    si,$00A0
  mov    ax,$00A2
  std
@bloop:  movsw
  add    di,ax
  add    si,ax
  loop   @bloop
  pop    ds
  add    word ptr [$0824],$0002
  add    word ptr [$0826],$0002
  dec    word ptr [$081E]
  jne    @cloop
  dec    word ptr [$0822]
  je     @dloop
  jmp    @eloop
@dloop:  sub    word ptr [$0820],$0008
  dec    word ptr [$0828]
  je     @floop
  jmp    @gloop
@floop:
end;

Procedure Waitforkey;
var k:char;
begin
     k:=readkey; if k=#0 then k:=readkey;
end;

function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }


procedure move32fast(var Source,Dest; Count:word); assembler;
asm
   push        ds
   les        di,Dest
   lds        si,Source
   mov        cx,count
   mov        bx,cx
   shr        cx,2
   db 66h;        rep movsw
   and        bx,3
   mov        cx,bx
   rep        movsb
   pop        ds
end;

procedure chbrght(palette:pal);
var j:integer;
begin
  for j:= 1 to 15 do
  begin
  SetPal(j,palette[j,1],palette[j,2],palette[j,3]);
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

procedure textmode;assembler;
asm
  mov ax,3  {reset to textmode}
  int 10h
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