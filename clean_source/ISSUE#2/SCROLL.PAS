{$g+}
uses crt;

const Func1    = $02;
const homekey  = $47;
const endkey   = $4F;
const pgupkey  = $49;
const pgdnkey  = $51;
const esckey   = $01;
const upkey    = $48;
const downkey  = $50;

type
  w00t1 = Array[0..255,1..3] of Byte;

const
  bios_maxlength = 200;

var

  max_charsize : byte;
  max_screensize,
  max_ysize,
  max_scanlength : word;
  bios_charsize : Byte ABSOLUTE $040:$0085;  {bios stored character height.. always here}
	bios_ysize : Byte ABSOLUTE $040:$0084;
  Pall,Pall2 : w00t1;

  vol,x1,x2,x3,curpos1,curpos,counter,checker,
  maxline,pagespeed,scrollspeed : integer;

  key : byte;

{$i rzr.pas}

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

PROCEDURE sp(ColorNo : Byte; R,G,B : Byte);
BEGIN
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
END;

PROCEDURE gp(ColorNo : Byte; Var R,G,B : Byte);
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;

Procedure ShowCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$0506
  INT   $10
end;

Procedure FadeIn;
Var loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
BEGIN
  For loop1:=0 to 64 do
    begin
     For loop2:=0 to 255 do
      BEGIN
       Gp (loop2,Tmp[1],Tmp[2],Tmp[3]);
       If Tmp[1]<Pall2[loop2,1] then inc (Tmp[1]);
       If Tmp[2]<Pall2[loop2,2] then inc (Tmp[2]);
       If Tmp[3]<Pall2[loop2,3] then inc (Tmp[3]);
       sP (loop2,Tmp[1],Tmp[2],Tmp[3]);
      END;
     wrt;
   end;
  END;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

PROCEDURE FadeOut;
VAR lxpy1,lxpy2:integer;
    Tmp : Array [1..3] of byte;
BEGIN
  For lxpy1:=1 to 64 do BEGIN
     begin
      wrt;
      For lxpy2:=0 to 255 do
        BEGIN
        gp (lxpy2,Tmp[1],Tmp[2],Tmp[3]);
        If Tmp[1]>0 then dec (Tmp[1]);
        If Tmp[2]>0 then dec (Tmp[2]);
        If Tmp[3]>0 then dec (Tmp[3]);
        sp (lxpy2,Tmp[1],Tmp[2],Tmp[3]);
       END;
    end;
  END;
END;

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

procedure setpos(position : word);
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
    move(rzr[(size div max_charsize)*160+1],mem[$b800:0], max_screensize);
    setofs(max_charsize,position mod size);
    move(rzr[(size div max_charsize)*160+1+max_screensize],mem[$b800:max_screensize],max_screensize);
    end
  else if (lastpos>=size) and (position<size) then begin
    move(rzr[max_screensize+1],mem[$b800:max_screensize], max_screensize);
    setofs(max_charsize,position mod size);
    move(rzr,mem[$b800:0], max_screensize);
    end
  else
    setofs(max_charsize,position mod size);

  lastpos:=position;
end;


begin
  scrollSpeed := 4;
  hidecursor;
  clrscr;
  textcolor(11);
  move(rzr,mem[$b800:0], bios_maxlength*160);
  pageSPEED := 8;
  max_charsize := bios_charsize;
  max_ysize := bios_ysize * bios_charsize;
  max_scanlength := bios_maxlength * bios_charsize;
  max_screensize := bios_maxlength*160 div 2;
  maxline := (rzr_DEPTH-bios_ysize-1) * bios_charsize;
  curpos:=0;
  repeat
    checker := 0;
    curpos1 := curpos;
    key := port[$60];
    WHILE KEYPRESSED DO READKEY;
    if keypressed then key := port[$60];
    case key of
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
                setpos(curPos);
              end;
              end;
            If curpos < 400 then
              if curpos > 1 then
              if checker = 0 then begin
             for counter := 0 to (((curpos) div 10)) do begin
                dec(curPos, pageSpeed);
                setpos(curPos);
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
              for counter := 0 to 39 do begin
                inc(curPos, pageSpeed);
                IF CURPOS <= MAXLINE THEN
                  setpos(curPos);
              end;
            end;
           end;
       upKey :
           if curPos >= scrollspeed then
              begin
                dec(curPos, scrollSpeed);
                IF CURPOS <= MAXLINE THEN
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
  fadeout;
  tmode;
end.