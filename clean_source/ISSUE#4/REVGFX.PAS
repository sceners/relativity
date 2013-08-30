{****************************************************************************)
(*                                                                          *)
(* REVGFX.PAS - The Relativity Emag (coded in Turbo Pascal 7.0)             *)
(*                                                                          *)
(* "The Relativity Emag" was originally written by En|{rypt, |MuadDib|,     *)
(* and IllumiTIE (for assembly routines). This source may not be copied,    *)
(* distributed or modified in any shape or form. Some of the code has been  *)
(* derived from various sources and units to help us produce a better       *)
(* quality electronic magazine to let the scene know we're boss.            *)
(*                                                                          *)
(* Program Notes : This program presents "The Relativity Emag"              *)
(*                                                                          *)
(* ASM/TP70 Coder : xxxxx xxxxxxxxx (En|{rypt)  - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* TP70 Coder     : xxxxx xxxxxxxxx (|MuadDib|) - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* GRAPHICS UNIT USED WITH REV97.PAS AND ABOVE. CODED IN TURBO PASCAL 7.0.  *)
(****************************************************************************)

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
{$g+}

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Library Divides The Main Program Into Related Modules.  *)
(****************************************************************************)

unit RevGfx;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - What Is Visible And Accessible To Any Program Or Unit.  *)
(****************************************************************************)

interface


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By This Single Unit.  *)
(****************************************************************************)

uses Crt,revfnt,revconst;

procedure Reset80x25VideoScreen;
procedure Clear80x25VideoScreen;
{procedure DelayScreen(ms : WORD);}
{procedure WaitRetrace;}
{procedure GetPal(ColorNo : BYTE; var R,G,B : BYTE);
procedure Pal(ColorNo : BYTE; R,G,B : BYTE);}
procedure GotoXY(X,Y : WORD);
procedure FadeupRGBScreen;
procedure FadedownRGBScreen;
{procedure Putpixel (X,Y : Integer; Col : BYTE; Where:WORD);
procedure AnimateFire1;}
{procedure SetOfs(W : word);
procedure ScrollAnsiScreen;}
procedure ShowCursor;
procedure HideCursor;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Procedures And Functions Declared In The Interface.     *)
(****************************************************************************)

implementation

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Defines An Identifier That Denotes A Constant Value.    *)
(****************************************************************************)

const
   Xsize    = 80;
   Ysize    = 112;
   Screen   = Xsize*Ysize;

const
  RecANSI   : Boolean = False;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Specifies An Identifier That Denotes A Type. (values)   *)
(****************************************************************************)

TYPE
  PallArray = array[0..255,1..3] of BYTE;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
  Pall          : PallArray;
  Key           : BYTE;
  RandSeed,Count,CurPos,CurPos1,Counter,Checker,MaxLine,
  PageSpeed,ScrollSpeed : Integer;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Resets The Video Mode To 80x25 Text Mode Just In Case.  *)
(****************************************************************************)

procedure Reset80x25VideoScreen;
begin
     asm
       mov ax,3
       int $10
     end;
fontload(config^.font[config^.curfnt]);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Performs ResetVideo And Clears The Screen Using Memory. *)
(****************************************************************************)

procedure Clear80x25VideoScreen;
begin
  Reset80x25VideoScreen;
  FillChar(Mem[$B800:0], 32768, 0);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Performs An Assembly Delay Based On Its Parameters.     *)
(****************************************************************************)

procedure DelayScreen(ms : WORD); assembler;
asm
  mov ax, 400
  mul ms
  xchg dx, cx
  xchg ax, dx
  mov ah, $86
  int $15
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words -                                                         *)
(****************************************************************************)

procedure WaitRetrace; assembler;
label
  l1, l2;
asm
    mov dx,$3DA
l1:
    in al,dx
    and al,$08
    jnz l1
l2:
    in al,dx
    and al,$08
    jz  l2
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Reads The RGB Values (1 Color) And Returns Them To You. *)
(****************************************************************************)

procedure GetPal(ColorNo : BYTE; var R,G,B : BYTE);
begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Sets The RGB Values (1 Color) By Declaring The ColorNo. *)
(****************************************************************************)

procedure Pal(ColorNo : BYTE; R,G,B : BYTE);
begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Reveals The Cursor If It Has Been Hidden By HideCursor. *)
(****************************************************************************)

procedure ShowCursor; assembler;
asm
  mov   ax,$0100
  mov   cx,$0506
  int   $10
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Hides The Cursor But Can Be Revealed Using ShowCursor.  *)
(****************************************************************************)

procedure HideCursor; assembler;
asm
  mov   ax,$0100
  mov   cx,$2607
  int   $10
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Performs An Assembly GotoXY Based On Its Parameters.    *)
(****************************************************************************)

procedure GotoXY(X,Y : WORD);
begin
  asm
    mov    ax,y
    mov    dh,al
    dec    dh
    mov    ax,x
    mov    dl,al
    dec    dl
    mov    ah,2
    xor    bh,bh
    int    10h
  end
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Slowly Fades Up The Screen Using The RGB Color Palette. *)
(****************************************************************************)

procedure FadeupRGBScreen;
var loop1,loop2:Integer;
    Tmp : array [1..3] of BYTE;
begin
  for loop1:=1 to 64 do begin
    WaitRetrace;
    for loop2:=0 to 255 do begin
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      if Tmp[1]<Pall[loop2,1] then Inc (Tmp[1]);
      if Tmp[2]<Pall[loop2,2] then Inc (Tmp[2]);
      if Tmp[3]<Pall[loop2,3] then Inc (Tmp[3]);
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
    end;
  end;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Slowly Fades Down The Screen Using The Tmp RGB Array.   *)
(****************************************************************************)

procedure FadedownRGBScreen;
var loop1,loop2:Integer;
    Tmp : array [1..3] of BYTE;
begin
  for loop1:=1 to 64 do begin
    WaitRetrace;
    for loop2:=0 to 255 do begin
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      if Tmp[1]>0 then Dec (Tmp[1]);
      if Tmp[2]>0 then Dec (Tmp[2]);
      if Tmp[3]>0 then Dec (Tmp[3]);
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
    end;
  end;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Puts A Pixel On The Screen By Writing Direct To Memory. *)
(****************************************************************************)

procedure Putpixel (X,Y : Integer; Col : BYTE; Where:WORD);
begin
 asm
   push    ds
   push    es
   mov     ax,[where]
   mov     es,ax
   mov     bx,[X]
   mov     dx,[Y]
   push    bx
   mov     bx, dx
   mov     dh, dl
   xor     dl, dl
   shl     bx, 6
   add     dx, bx
   pop     bx
   add     bx, dx
   mov     di, bx
   xor     al,al
   mov     ah, [Col]
   mov     es:[di],ah
   pop     es
   pop     ds
 end;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Puts Fire1 On The Screen And Randomizes The Pattern.    *)
(****************************************************************************)

procedure Random2; assembler;
asm
  mov     ax,[RandSeed]
  mov     dx,$8405
  mul     dx
  inc     ax
  mov     [RandSeed],ax
  ret
end;

{procedure SetupScreen; assembler;
label _SetUpScreen;
asm
_SetUpScreen:
    mov     ax,$0013
    int     $10

    mov     ax,$0A000
    mov     es,ax
    xor     di,di

    cli
    cld
    mov     dx,$3C4
    mov     ax,$604
    out     dx,ax
    mov     ax,$0F02
    out     dx,ax
    xor     ax,ax
    mov     cx,32767
    rep     stosw
    mov     dx,$3D4
    mov     ax,$14
    out     dx,ax
    mov     ax,$0E317
    out     dx,ax
    out     dx,ax
    mov     ax,$00409
    out     dx,ax

    mov     si, offset [pallette]
    mov     dx, $3C8
    mov     al, 0
    out     dx, al
    inc     dx
    mov     cx, 768

@PalLoop :
    outsb
    dec     cx
    jnz     @PalLoop
    ret
end;

procedure AnimateFire1;
label _l1, _l2, _l3;
begin
  asm
    call    SetupScreen

    mov     randseed,$1234
    mov     si,offset [screen]
    mov     cx,xsize * ysize
    xor     ax,ax
    rep     stosb

@MainLoop :
    mov     si,offset [screen]
    add     si,xsize * ysize
    sub     si,xsize
    mov     cx,xsize
    xor     dx,dx

@Newline :
    call    random2
    mov     ds:[si],dl
    inc     si
    dec     cx
    jnz     @Newline
    mov     cx,xsize * ysize
    sub     cx,xsize
    mov     si,offset [screen]
    add     si,xsize

@FileLoop :
    xor     ax,ax
    mov     al,ds:[si]
    add     al,ds:[si+1]
    adc     ah,0
    add     al,ds:[si-1]
    adc     ah,0
    add     al,ds:[si+xsize]
    adc     ah,0
    shr     ax,2
    jz      @zero
    dec     ax

@Zero :
    mov     ds:[si-xsize],al
    inc     si
    dec     cx
    jnz     @FileLoop
    mov     dx, $3DA

_l1:
    in      al, dx
    and     al, $8
    jnz     _l1

_l2:
    in      al, dx
    and     al, $8
    jz      _l2

    mov     cx,xsize * ysize
    shr     cx,1
    mov     si,offset [screen]
    xor     di,di
    rep     movsw

    mov     ah,01
    int     $16
    jz      @MainLoop

    xor     ah,ah
    int     $16
  end;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Unit Is Loaded.      *)
(****************************************************************************)

end.


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
