{$g+}
unit revlong;

Interface

uses Crt,Dos,revconst;

procedure long(str:st12; n:byte);

implementation
uses revtech,revfnt,revhsc,revhelp,revansi,revgfx,revdat,revboom;

const bios_maxlength = 200;
      Max =$ffff;

var
  vol,x1,x2,x3,curpos1,curpos,counter,checker,
  maxline,pagespeed,scrollspeed : longint;
  buffer:bu;
  line:longint;

PROCEDURE wrt; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
       and al,08h
    jz  l2
end;


Procedure ShowCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$0506
  INT   $10
end;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

Procedure Tmode;
Begin
asm
   mov ax,3h
   int 10h
end;
end;

procedure setOfs(ycharsize : byte; W : word); assembler;
  asm
          mov    ax, [W]
          mov    cx, ax

          xor    dx,dx
          xor    bx,bx
          mov    bl,[ycharsize]
          div    bx
          mov    bx, ax
          shl    ax, 6
          shl    bx, 4
          add    bx, ax

          cli
          mov    dx, 3DAh
   @11:   in     al, dx
          test   al, 01
          jnz    @11

          mov    dx, 3D4h
          mov    al, 0Ch
          mov    ah, bh
          out    dx, ax
          inc    al
          mov    ah, bl
          out    dx, ax

          mov    dx, 3d4h
          mov    al, 08h
          out    dx, al
          mov    ah, [ycharsize]
          dec    ah
          and    cl, ah
          mov    ah, cl
          out    dx, ax


          mov    dx, 3DAh
    @22:  in     al, dx
          test   al, 08
          jz     @22

          sti
  end;



procedure long(str:st12; n:byte);
const
   bios_charsize =16;
   bios_ysize =24;
   a=1;

var
  max_charsize : longint;
  max_screensize,max_ysize,max_scanlength : longint;
{ bios_charsize : Byte ABSOLUTE $040:$0085;  {bios stored character height.. always here}
{ bios_ysize : Byte ABSOLUTE $040:$0084;}
  dep:longint;
  position,lastpos,size : longint;
  adf:boolean;
  label start;

Procedure getbuf(str:string; var numread:longint);
var
    m:word;
    f:file;
begin
assign(f,str);
reset(f,1);
BlockRead(F,buffer^, max, m);
numread:=m;
close(f);
end;

procedure setpos(position:longint);
const
  lastpos : longint= 0;
var
  size : longint;
begin
  size := max_scanlength-max_ysize;
  asm
          cli
          mov    dx, 3DAh
   @11:   in     al, dx
          test   al, 08
          jnz    @11
  end;
  if (lastpos<=size) and (position>size) then begin
    move(buffer^[(size div max_charsize)*160+1],mem[$b800:0], max);
    setofs(max_charsize,position mod size);
    move(buffer^[(size div max_charsize)*160+1+max_screensize],mem[$b800:max_screensize],max);
    end
  else if (lastpos>=size) and (position<size) then begin
    move(buffer^[max_screensize+1],mem[$b800:max_screensize], max);
    setofs(max_charsize,position mod size);
    move(buffer^,mem[$b800:0], max);
    end
  else
  begin
     setofs(max_charsize,position mod size);
  end;
  lastpos:=position;
end;

Procedure Nextlines;
var i:integer;
    lin:longint;
begin
lin:=0;
    while lin<=maxline do
    begin
          inc(lin,4);
          if lin<=maxline then
          setpos(lin);
{          setofs(lin,position mod size);}
     end;
end;

Procedure Next2;
var i:integer;
    lin:longint;
    label two,one,over;
begin
lin:=0;
          one:
          while lin<=maxline do
          begin
               if keypressed then goto over;
          inc(lin,4);
          if lin<=maxline then
          setpos(lin)
          else goto two;
          end;
          two:
          while lin>=0 do
          begin
               if keypressed then goto over;
          dec(lin,4);
          if lin>=0 then
          setpos(lin)
          else goto one;
          end;
{          setofs(lin,position mod size);}
     over:
end;


begin
  getmem(buffer,max);
  {-----------------------------------------------}
{  chbrght;}
  getbuf(str,dep);
  deletedatfile(str);
  {-----------------------------------------------}
  scrollSpeed := 4;
  hidecursor;
  clrscr;
  {-----------------------------------------------}
  move(buffer^,mem[$b800:0], max);
  pageSPEED := 10;
  max_charsize := bios_charsize;
  max_ysize := bios_ysize * bios_charsize;
  max_scanlength := bios_maxlength * bios_charsize;
  max_screensize := bios_maxlength * 160 div 2;
  maxline := ((dep div 160)-bios_ysize-1) * bios_charsize;
{-----------------------------------------------}
if n= 1 then
  Nextlines;
if n= 2 then
   next2;
{-----------------------------------------------}
 freemem(buffer,max);
 FadedownRGBScreen;
{-----------------------------------------------}
 Reset80x25VideoScreen;
{DeleteDatFile(str);}
{-----------------------------------------------}
end;

end.


