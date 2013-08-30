{$g+}

unit revsmth;

{$A+}{$B+}{$D+}{$F+}{$G+}{$I+}{$K+}{$L+}{$N+}{$O-}{$P+}{$Q-}{$R-}{$S+}{$T+}
{$V-}{$W+}{$X+}{$Y+}
{$C MOVEABLE PRELOAD DISCARDABLE}
{$D The Relativity Emag (in Turbo Pascal 7.0)}
{$M 65000,0,655360}
{$S 655360}

Interface

uses Crt,Dos,revdat;

const
     max=62000;

type
  a64 = array[1..max] of char;

procedure smoothscroll(str:string);

implementation
uses revhsc,revhelp,revansi,revgfx;

const Func1    = $02;
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
  maxline,pagespeed,scrollspeed : word;
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

Procedure getbuf(var buf:a64; str:string; var numread:integer);
var
    f:file;
begin
assign(f,str);
reset(f,1);
BlockRead(F,buf, SizeOf(buf), NumRead);
close(f);
end;

procedure smoothscroll(str:string);
const
   bios_charsize =80;
   bios_ysize =24;
a=1;
var
  max_charsize : longint;
  max_screensize,max_ysize,max_scanlength : longint;
{  bios_charsize : Byte ABSOLUTE $040:$0085;  {bios stored character height.. always here}
{  bios_ysize : Byte ABSOLUTE $040:$0084;}
  dep:integer;
  buf:a64;
  position,lastpos,size : longint;
  label start;

procedure setpos(position:word);
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
    setofs(max_charsize,position mod size);
  lastpos:=position;

end;

begin
  getbuf(buf,str,dep);
  scrollSpeed := 4;
  hidecursor;
  clrscr;
  move(buf,mem[$b800:0], bios_maxlength*160);
  pageSPEED := 10;
  max_charsize := bios_charsize;
  max_ysize := bios_ysize * bios_charsize;
  max_scanlength := bios_maxlength * bios_charsize;
  max_screensize := bios_maxlength*160 div 2;
  maxline := ((dep div 160)-bios_ysize-1) * bios_charsize;
  curpos:=0;
  repeat
    checker := 0;
    curpos1 := curpos;
    key := port[$60];
    WHILE KEYPRESSED DO READKEY;
    if keypressed then key := port[$60];
    case key of
       func1 : begin
                  help(true,str);
                  hidecursor;
                  ExtractFileFromDat(str);
{                   goto setpos;}
{                  ReadAnsiBinAndLoadToMem(str,dep);}
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
{------------------------------------------------------------------------------}
{  lastpos:=0;
  position:=curpos;
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
    setofs(max_charsize,position mod size);
  lastpos:=position;
{------------------------------------------------------------------------------}
    if curPos > maxline then curPos := maxline;
  until key = escKey;
{  fadeout;
  tmode;}
curpos:=1;
FadedownRGBScreen;
Reset80x25VideoScreen;
end;
end.


procedure setpos(position : word; buf:a64; var max_screensize,max_ysize,max_scanlength : word; var max_charsize : byte);
const
  lastpos : word = 0;
var
  size : word;
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
    setofs(max_charsize,position mod size);
  lastpos:=position;

end;
       homekey :
           begin
            for counter := 0 to curpos div 10 - 1 do begin
             dec(curpos, pagespeed);
             setpos(curpos);
            end;
           end;
       endkey :
           begin
            for counter := curpos div 10 + 1 to (maxline div 10 + 1)-1 do begin
             inc(curpos, pagespeed);
             setpos(curpos);
            end;
           end;
       pgupkey :
           BEGIN
            If curpos > 399 then begin
              for counter := 0 to 39 do begin
                checker := 1;
                dec(curPos, pageSpeed);
             setpos(curpos);
              end;
              end;
            If curpos < 400 then
              if curpos > 1 then
              if checker = 0 then begin
             for counter := 0 to (((curpos) div 10)) do begin
                dec(curPos, pageSpeed);
             setpos(curpos);
              IF curpos < 0 then begin
              curpos := 0;
             setpos(curpos);
              end;
             end;
             end;
          end;
       pgdnkey :
           BEGIN
            IF CURPOS > MAXLINE THEN CURPOS := MAXLINE;
            If CURPOS < MAXLINE then begin
              for counter := 0 to 39 do
               begin
                inc(curPos, pageSpeed);
                IF CURPOS >= MAXLINE THEN
                curpos:=maxline;
             setpos(curpos);
              end;
            end;
           end;
       upKey :
           if curPos >= scrollspeed then
              begin
                dec(curPos, scrollSpeed);
                IF CURPOS <=0  THEN
                curpos:=0;
             setpos(curpos);
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
                IF CURPOS >= MAXLINE THEN
                curpos:=maxline;
             setpos(curpos);
              end
            else
              begin
                curpos:=maxline;
             setpos(curpos);
              end;