{$g+}

unit revafd;
Interface

uses Crt,Dos;

const
     max=51000;

type
  a64 = array[1..max] of char;

procedure smoothscroll(str:string; x,y:integer);

implementation
uses revtech,revfnt,revconst,revhsc,revhelp,revansi,revgfx,revdat;

const Func1    = $bb;
const homekey  = $47;
const endkey   = $4F;
const pgupkey  = $49;
const pgdnkey  = $51;
const esckey   = $01;
const upkey    = $48;
const downkey  = $50;
      bios_maxlength = 200;

var
  vol,x1,x2,x3,curpos1,curpos,counter,checker,
  maxline,pagespeed,scrollspeed : longint;
  key : byte;

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



procedure smoothscroll(str:string; x,y:integer);
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
  buf:a64;
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
if adf then seek(f,4289); { 4289=header}
BlockRead(F,buf, SizeOf(buf), m);
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
    move(buf[(size div max_charsize)*160+1],mem[$b800:0], max_screensize);
    setofs(max_charsize,position mod size);
    move(buf[(size div max_charsize)*160+1+max_screensize],mem[$b800:max_screensize],max_screensize);
    end
  else if (lastpos>=size) and (position<size) then begin
    move(buf[max_screensize+1],mem[$b800:max_screensize], max_screensize);
    setofs(max_charsize,position mod size);
    move(buf,mem[$b800:0], max_screensize);
    end
  else
  begin
     setofs(max_charsize,position mod size);
  end;
  lastpos:=position;
end;

Procedure ReadhEADER;
BEGIN
  assign(f,str);
  reset(f,1);
  blockread(f,version,1);
  for count1:=0 to 63 do begin
  blockread(f,pallette[count1],3);
  end;
  blockread(f,vga_font[1],4096);
  For count1:=0 to 63 do
    GetPal(count1,old_pal[count1,1],old_pal[count1,2],old_pal[count1,3]);
  For count1:=0 to 63 do
    SetPal(count1,pallette[count1,1],pallette[count1,2],pallette[count1,3]);
  set_ice_color;
  set_character_width;
  set_vga_font;
  cursor_off;
END;

procedure ClearHeaderStatus;
begin
  For count1:=0 to 63 do
  SetPal(count1,old_pal[count1,1],old_pal[count1,2],old_pal[count1,3]);
  fillchar(mem[$b800:0],4000,7);
  set_textmode;
  fontload(font[curfnt]);
end;

Procedure GetExt(name:string; var adf:boolean);
var tmp:string;
    i,l:integer;
begin
tmp:='';
for i:= l to l-2 do
   tmp:=tmp+name[i];
if tmp='ADF' then
    adf:=true
else
    adf:=false;
end;

begin
  {-----------------------------------------------}
  getext(str,adf);
  if adf then ReadhEADER;
  getbuf(str,dep);
  {-----------------------------------------------}
  scrollSpeed := 4;
  hidecursor;
  clrscr;
  {-----------------------------------------------}
  move(buf,mem[$b800:0], bios_maxlength*160);
  pageSPEED := 10;
  max_charsize := bios_charsize;
  max_ysize := bios_ysize * bios_charsize;
  max_scanlength := bios_maxlength * bios_charsize;
  max_screensize := bios_maxlength * 160 div 2;
  maxline := ((dep div 160)-bios_ysize-1) * bios_charsize;
  {-----------------------------------------------}
  curpos:=0;
  repeat
    checker := 0;
    curpos1 := curpos;
    key := port[$60];
    WHILE KEYPRESSED DO READKEY;
    if keypressed then
        key := port[$60];
    case key of
       func1 : begin
                  notavhelp:=notavhelp-[3];
                  help(str,x,y,adf);
                  hidecursor;
                  setofs(max_charsize,curpos mod size);
                  move(buf,mem[$b800:0],max_screensize);
                  DeleteDatFile(str);
             end;
       homekey :
           begin
            for counter := 0 to curpos div 10 - 1 do
            begin
             dec(curpos, pagespeed);
             if curpos<=0 then curpos:=0;
             setpos(curpos);
            end;
           end;
       endkey :
           begin
            for counter := curpos div 10 + 1 to (maxline div 10 + 1)-1 do
            begin
                 inc(curpos, pagespeed);
                 if curpos>=maxline then
                    curpos:=maxline;
                 setpos(curpos);
            end;
           end;
       pgupkey :
           BEGIN
            If curpos > 399 then
             begin
                for counter := 0 to 39 do
                begin
                     checker := 1;
                     dec(curPos, pageSpeed);
                     IF CURPOS <=0 then
                        curpos:=0;
                     setpos(curPos);
                end;
              end;
            If curpos < 400 then
              if curpos > 1 then
                 if checker = 0 then
                 begin
                      for counter := 0 to (((curpos) div 10)) do
                      begin
                      dec(curPos, pageSpeed);
                      IF CURPOS <=0 then
                         curpos:=0;
                      setpos(curPos);
                 end;
             end;
          end;
       pgdnkey :
           BEGIN
            IF CURPOS > MAXLINE THEN CURPOS := MAXLINE;
            If CURPOS < MAXLINE then begin
              for counter := 0 to 39 do begin
                inc(curPos, pageSpeed);
                IF CURPOS >= MAXLINE THEN
                curpos:=maxline;
                  setpos(curPos);
              end;
            end;
           end;
       upKey :
           if curPos >= scrollspeed then
              begin
                dec(curPos, scrollSpeed);
                IF CURPOS <= 0 THEN
                curpos:=0;
                  setpos(curPos);
              end
           else
             begin
               curpos:=0;
               setpos(curpos);
             end;
       downKey :
            if curPos < maxline - scrollspeed  then
              begin
                inc(curPos, scrollSpeed);
                IF CURPOS <= MAXLINE THEN
                  setpos(curPos);
              end
            else
              begin
                curpos:=maxline;
                setpos(curpos);
              end;
    end;
    if curPos > maxline then curPos := maxline;
  until key = escKey;
{-----------------------------------------------}
curpos:=1;
{-----------------------------------------------}
if adf then ClearHeaderStatus;
{-----------------------------------------------}
FadedownRGBScreen;
Reset80x25VideoScreen;
DeleteDatFile(str);
{-----------------------------------------------}
end;

end.


