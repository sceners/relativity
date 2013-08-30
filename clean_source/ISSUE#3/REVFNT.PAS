
unit revfnt;
interface

Procedure FontLoad(filename:string);

implementation
uses crt,dos,revdat,revgfx,revconst;

Procedure FontLoad(filename:string);
var vga_font:array[1..8192] of byte;
    f:file;
    m:word;
    regs:registers;                     { pascal registers }

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
begin
     extractfilefromdat(filename);
     assign(f,filename);
     reset(f,1);
     BlockRead(F, vga_font, SizeOf(vga_font), m);
     Set_Vga_Font;
     close(f);
     deletedatfile(filename);
     hidecursor;
end;

Procedure ExtractFont;
var buf:array[1..8192] of byte;
    f,f1:file;
    m,u:word;
begin
     assign(f,paramstr(1));
     assign(f1,'fontraw.dat');
     reset(f,1);
     rewrite(f1,1);
     BlockRead(F, Buf, 99, m);
     BlockRead(F, Buf,sizeof(buf), m);
     BlockWrite(f1, Buf, m, u);
     close(f);
     close(f1);
end;

end.

{    asm
     mov ax,seg buf
     mov es,ax
     mov bp,offset buf
     mov ax,1110h
     mov bx,1000h
     mov cx,0100h
     mov dx,0000h
     int 10h

     mov ax, seg buf
     mov es, ax
     mov bp, offset buf
     mov cx, 128
     mov dx, 128
     mov bl, 0
     mov bh, 8
     mov al, 1
     mov ah, 11h
     int 10h
     end;
     close(f);
{    deletedatfile(filename);}