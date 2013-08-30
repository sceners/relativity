{$g+}
unit revsmoot;
interface
uses Crt,Dos,revdat;

procedure smoothscroll(dep:longint; str:string);

implementation
uses revhsc,revhelp,revconst,revansi,revgfx;

type
  TColr = record
    r, g, b : byte;
  end;
  TRColr = record
    r, g, b : real;
  end;
  TRPal = array[0..15] of TRColr;
  ScreenType = array [0..3999] of Byte;
  w00t1 = Array[0..255,1..3] of Byte;

const
homekey  = $47;
endkey   = $4F;
pgupkey  = $49;
pgdnkey  = $51;
esckey   = $01;
upkey    = $48;
downkey  = $50;
RrGgBb_Table : array[0..15] of byte =
(0,1,1,1,1,1,20,7,56,57,58,59,60,61,62,63);

var i:integer;
    fadepal,ctl,defpal: TRPal;
    Pall,Pall2 : w00t1;
    vol,x1,x2,x3,curpos1,curpos,counter,checker,
    maxline,pagespeed,scrollspeed : integer;
    key : word;

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

procedure setOfs(W : word); assembler;
  asm
          mov    bx, [W]
          mov    cx, bx

          shr    bx, 4
          mov    ax, bx
          shl    ax, 6
          shl    bx, 4
          add    bx, ax

          cli
          mov    dx, 3DAh
   @11:   in     al, dx
          test   al, 1
          jne    @11

          mov    dx, 3D4h
          mov    al, 0Ch
          mov    ah, bh
          out    dx, ax
          inc    al
          mov    ah, bl
          out    dx, ax

          mov    al, 8
          mov    ah, cl
          and    ah, 15
          out    dx, ax

          mov    dx, 3DAh
    @22:  in     al, dx
          test   al, 08
          je     @22

          sti
  end;

procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
begin
  inline (
    $1E/$C5/$B6/ADDR1/$C4/$BE/ADDR2/$8B/$8E/BLKLEN/
    $E3/$5B/$8B/$D7/$33/$C0/$FC/$AC/$3C/$20/$72/$05/$AB/$E2/$F8/$EB/$4C/$3C/$10/
    $73/$07/$80/$E4/$F0/$0A/$E0/$EB/$F1/$3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/
    $02/$C0/$02/$C0/$02/$C0/$80/$E4/$8F/$0A/$E0/$EB/$DA/$81/$C2/$A0/$00/$8B/$FA/
    $EB/$D2/$3C/$1B/$72/$07/$75/$CC/$80/$F4/$80/$EB/$C7/$3C/$19/$8B/$D9/$AC/
    $8A/$C8/$B0/$20/$74/$02/$AC/$4B/$32/$ED/$41/$F3/$AB/$8B/$CB/$49/$E0/$AA/$1F);
end; {UNCRUNCH}

Procedure COff; Assembler;
Asm
    xor  ax, ax
    mov  es, ax
    mov  bh, Byte ptr es:[462h]  { get active page }
    mov  ah, 3
    int  10h           { get cursor Characteristics }
    or   ch, 00100000b
    mov  ah, 1
    int  10h           { set cursor Characteristics }
end;



procedure calcctl (steps : byte; var src, dest : TRPal);

var
  x : byte;

begin
  for x := 0 to 15 do
    with ctl[x] do
      begin
        r := (dest[x].r-src[x].r)/steps;
        g := (dest[x].g-src[x].g)/steps;
        b := (dest[x].b-src[x].b)/steps;
      end;
end;

procedure setcolr (idx : byte; var colr : TColr);

begin
  port[$3c8] := idx;
  port[$3c9] := colr.r;
  port[$3c9] := colr.g;
  port[$3c9] := colr.b;
end;



procedure setrcolr (idx : byte; var colr : TRColr);

var
  x : byte;
  tmp : TColr;

begin
  with tmp do
    begin
      r := round(colr.r);
      g := round(colr.g);
      b := round(colr.b);
    end;
  setcolr (idx,tmp);
end;


procedure fadetocolor;

var
  s, x : byte;

begin
  calcctl (32,fadepal,defpal);
  for s := 0 to 31 do
    begin
      for x := 0 to 15 do
        begin
          with fadepal[x] do
            begin
              r := r+ctl[x].r;
              g := g+ctl[x].g;
              b := b+ctl[x].b;
            end;
          setrcolr (RrGgBb_table[x],fadepal[x]);
        end;
      delay (25);
    end;
end;

procedure getcolr (idx : byte; var colr : TColr);

begin
  port[$3c7] := idx;
  colr.r := port[$3c9];
  colr.g := port[$3c9];
  colr.b := port[$3c9];
end;


procedure getrcolr (idx : byte; var entry : TRColr);

var
  tmp : TColr;

begin
  getcolr (idx,tmp);
  with entry do
    begin
      r := tmp.r;
      g := tmp.g;
      b := tmp.b;
    end;
end;

procedure savepalette (var pal : TRPal);

var
  x : byte;

begin
  for x := 0 to 15 do
    getrcolr (RrGgBb_Table[x],pal[x]);
end;

procedure whitescreen;

var
  x : byte;

begin
  for x := 0 to 15 do
    with fadepal[x] do
      begin
        r := 63.0;
        g := 63.0;
        b := 63.0;
      end;
end;

const
Func1    = $bb;

procedure smoothscroll(dep:longint; str:string);
label 2;
begin
curpos:=1;
coff;
checkbreak:=false;
textcolor(lightgray);
textbackground(black);
scrollSpeed :=4;
hidecursor;
textcolor(11);
pageSPEED := 8;
maxline :=((dep div 160)-24)*16;
repeat
    checker := 0;
    curpos1 := curpos;
    key := port[$60];
    WHILE KEYPRESSED DO READKEY;
    if keypressed then
       key := port[$60];
    case key of
       func1 : begin
                  help(true,str);
                  hidecursor;
                  ExtractFileFromDat(str);
                  setofs(curpos);
                  ReadAnsiBinAndLoadToMem(str,dep);
                  DeleteDatFile(str);
             end;
       homekey :
           begin
            for counter := 0 to curpos div 10 - 1 do begin
             dec(curpos, pagespeed);
             setofs(curpos);
            end;
           end;
       endkey :
           begin
            for counter := curpos div 10 + 1 to (maxline div 10 + 1)-1 do begin
             inc(curpos, pagespeed);
             setofs(curpos);
            end;
           end;
       pgupkey :
           BEGIN
            If curpos > 399 then begin
              for counter := 0 to 39 do begin
                checker := 1;
                dec(curPos, pageSpeed);
                setOfs(curPos);
              end;
              end;
            If curpos < 400 then
              if curpos > 1 then
              if checker = 0 then begin
             for counter := 0 to (((curpos) div 10)) do begin
                dec(curPos, pageSpeed);
                setOfs(curPos);
              IF curpos < 0 then begin
              curpos := 0;
              setofs(curpos);
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
                IF CURPOS > MAXLINE THEN GOTO 2;
                setOfs(curPos);
              end;
            end;
           end;
       upKey :
           if curPos > 1 then
              begin
                dec(curPos, scrollSpeed);
                IF CURPOS > MAXLINE THEN GOTO 2;
                setOfs(curPos);
              end;
       downKey :
            if curPos < maxline + 10 then
              begin
                inc(curPos, scrollSpeed);
                IF CURPOS > MAXLINE THEN GOTO 2;
                setOfs(curPos);
               2:
              end;
    end;
    if curPos > maxline then curPos := maxline;
  until key = escKey;
{fadeout;}
curpos:=1;
FadedownRGBScreen;
Reset80x25VideoScreen;
end;


{procedure AnsiWriteScreen;
var
  cxsize     : Integer;
begin
  { caculates size of CX based on size of ansi array in .pas ansi file }
  { calculation is ansi array size divided by 2 minus 10 }
  { the last number is to fine tune the size in case some text was cut }
{  cxsize := 31520 DIV 2 - 10;
  asm
    push    ds
    push    es
    pusha

    mov     ax,0B800h
    mov     es,ax

    mov     si,offset coverpt1
    xor     di,di
    mov     cx,cxsize
    cld
    rep     movsw

    popa
    pop     es
    pop     ds
   end;
end;}

{begin
  { caculates scroll size based on size of ansi array in .pas ansi file }
  { calculation is ansi array size divided by real number rounded to make }
  { it a clean integer compatible with maxline in revgfx.pas }
 { scrollsize := round (31520 / 11.42028985507);
  Reset80x25VideoScreen;
  HideCursor;
  AnsiWriteScreen;
  ScrollAnsiScreen(scrollsize);
  Reset80x25VideoScreen;
end.}

end.