(****************************************************************************)
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

{$A+}{$B+}{$D+}{$F+}{$G+}{$I+}{$K+}{$L+}{$N+}{$O-}{$P+}{$Q-}{$R-}{$S+}{$T+}
{$V-}{$W+}{$X+}{$Y+}
{$C MOVEABLE PRELOAD DISCARDABLE}
{$D The Relativity Emag (in Turbo Pascal 7.0)}


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

uses Crt;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Defines An Identifier That Denotes A Constant Value.    *)
(****************************************************************************)

  const pallette : array [1..768] of BYTE = (

   0,  0,  0,  0,  0,  6,  0,  0,  6,  0,  0,  7,  0,  0,  8,  0
  ,0,  8,  0,  0,  9,  0,  0, 10,  2,  0, 10,  4,  0,  9,  6,  0
  ,9,  8,  0,  8, 10,  0,  7, 12,  0,  7, 14,  0,  6, 16,  0,  5
  ,18,  0,  5, 20,  0,  4, 22,  0,  4, 24,  0,  3, 26,  0,  2, 28
  ,0,  2, 30,  0,  1, 32,  0,  0, 32,  0,  0, 33,  0,  0, 34,  0
  ,0, 35,  0,  0, 36,  0,  0, 36,  0,  0, 37,  0,  0, 38,  0,  0
  ,39,  0,  0, 40,  0,  0, 40,  0,  0, 41,  0,  0, 42,  0,  0, 43
  ,0,  0, 44,  0,  0, 45,  0,  0, 46,  1,  0, 47,  1,  0, 48,  2
  ,0, 49,  2,  0, 50,  3,  0, 51,  3,  0, 52,  4,  0, 53,  4,  0
  ,54,  5,  0, 55,  5,  0, 56,  6,  0, 57,  6,  0, 58,  7,  0, 59
  ,7,  0, 60,  8,  0, 61,  8,  0, 63,  9,  0, 63,  9,  0, 63, 10
  ,0, 63, 10,  0, 63, 11,  0, 63, 11,  0, 63, 12,  0, 63, 12,  0
  ,63, 13,  0, 63, 13,  0, 63, 14,  0, 63, 14,  0, 63, 15,  0, 63
  ,15,  0, 63, 16,  0, 63, 16,  0, 63, 17,  0, 63, 17,  0, 63, 18
  ,0, 63, 18,  0, 63, 19,  0, 63, 19,  0, 63, 20,  0, 63, 20,  0
  ,63, 21,  0, 63, 21,  0, 63, 22,  0, 63, 22,  0, 63, 23,  0, 63
  ,24,  0, 63, 24,  0, 63, 25,  0, 63, 25,  0, 63, 26,  0, 63, 26
  ,0, 63, 27,  0, 63, 27,  0, 63, 28,  0, 63, 28,  0, 63, 29,  0
  ,63, 29,  0, 63, 30,  0, 63, 30,  0, 63, 31,  0, 63, 31,  0, 63
  ,32,  0, 63, 32,  0, 63, 33,  0, 63, 33,  0, 63, 34,  0, 63, 34
  ,0, 63, 35,  0, 63, 35,  0, 63, 36,  0, 63, 36,  0, 63, 37,  0
  ,63, 38,  0, 63, 38,  0, 63, 39,  0, 63, 39,  0, 63, 40,  0, 63
  ,40,  0, 63, 41,  0, 63, 41,  0, 63, 42,  0, 63, 42,  0, 63, 43
  ,0, 63, 43,  0, 63, 44,  0, 63, 44,  0, 63, 45,  0, 63, 45,  0
  ,63, 46,  0, 63, 46,  0, 63, 47,  0, 63, 47,  0, 63, 48,  0, 63
  ,48,  0, 63, 49,  0, 63, 49,  0, 63, 50,  0, 63, 50,  0, 63, 51
  ,0, 63, 52,  0, 63, 52,  0, 63, 52,  0, 63, 52,  0, 63, 52,  0
  ,63, 53,  0, 63, 53,  0, 63, 53,  0, 63, 53,  0, 63, 54,  0, 63
  ,54,  0, 63, 54,  0, 63, 54,  0, 63, 54,  0, 63, 55,  0, 63, 55
  ,0, 63, 55,  0, 63, 55,  0, 63, 56,  0, 63, 56,  0, 63, 56,  0
  ,63, 56,  0, 63, 57,  0, 63, 57,  0, 63, 57,  0, 63, 57,  0, 63
  ,57,  0, 63, 58,  0, 63, 58,  0, 63, 58,  0, 63, 58,  0, 63, 59
  ,0, 63, 59,  0, 63, 59,  0, 63, 59,  0, 63, 60,  0, 63, 60,  0
  ,63, 60,  0, 63, 60,  0, 63, 60,  0, 63, 61,  0, 63, 61,  0, 63
  ,61,  0, 63, 61,  0, 63, 62,  0, 63, 62,  0, 63, 62,  0, 63, 62
  ,0, 63, 63,  0, 63, 63,  1, 63, 63,  2, 63, 63,  3, 63, 63,  4
  ,63, 63,  5, 63, 63,  6, 63, 63,  7, 63, 63,  8, 63, 63,  9, 63
  ,63, 10, 63, 63, 10, 63, 63, 11, 63, 63, 12, 63, 63, 13, 63, 63
  ,14, 63, 63, 15, 63, 63, 16, 63, 63, 17, 63, 63, 18, 63, 63, 19
  ,63, 63, 20, 63, 63, 21, 63, 63, 21, 63, 63, 22, 63, 63, 23, 63
  ,63, 24, 63, 63, 25, 63, 63, 26, 63, 63, 27, 63, 63, 28, 63, 63
  ,29, 63, 63, 30, 63, 63, 31, 63, 63, 31, 63, 63, 32, 63, 63, 33
  ,63, 63, 34, 63, 63, 35, 63, 63, 36, 63, 63, 37, 63, 63, 38, 63
  ,63, 39, 63, 63, 40, 63, 63, 41, 63, 63, 42, 63, 63, 42, 63, 63
  ,43, 63, 63, 44, 63, 63, 45, 63, 63, 46, 63, 63, 47, 63, 63, 48
  ,63, 63, 49, 63, 63, 50, 63, 63, 51, 63, 63, 52, 63, 63, 52, 63
  ,63, 53, 63, 63, 54, 63, 63, 55, 63, 63, 56, 63, 63, 57, 63, 63
  ,58, 63, 63, 59, 63, 63, 60, 63, 63, 61, 63, 63, 62, 63, 63, 63);

   Xsize    = 80;
   Ysize    = 112;
   Screen   = Xsize*Ysize;

const
  RecANSI   : Boolean = False;
  Func1     = $02;
  HomeKey   = $47;
  EndKey    = $4F;
  PgupKey   = $49;
  PgdnKey   = $51;
  EscKey    = $01;
  UpKey     = $48;
  DownKey   = $50;

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

procedure Reset80x25VideoScreen;
procedure Clear80x25VideoScreen;
procedure DelayScreen(ms : WORD);
procedure WaitRetrace;
procedure GetPal(ColorNo : BYTE; var R,G,B : BYTE);
procedure Pal(ColorNo : BYTE; R,G,B : BYTE);
procedure GotoXY(X,Y : WORD);
procedure FadeupRGBScreen;
procedure FadedownRGBScreen;
procedure Putpixel (X,Y : Integer; Col : BYTE; Where:WORD);
procedure AnimateFire1;
procedure SetOfs(W : word);
procedure ScrollAnsiScreen;
procedure ShowCursor;
procedure HideCursor;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Procedures And Functions Declared In The Interface.     *)
(****************************************************************************)

implementation

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Resets The Video Mode To 80x25 Text Mode Just In Case.  *)
(****************************************************************************)

procedure Reset80x25VideoScreen; assembler;
asm
  mov ax,3
  int $10
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

procedure SetupScreen; assembler;
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
(* Reserved Words - Needed To Smootly Scroll An ANSi Image From Arrays.     *)
(****************************************************************************)

procedure SetOfs(W : word); assembler;
  asm
       mov     bx,[W]
       mov     cx,bx

       shr     bx,4
       mov     ax,bx
       shl     ax,6
       shl     bx,4
       add     bx,ax

       cli
       mov     dx,3DAh
@11:   in      al,dx
       test    al,1
       jne     @11

       mov     dx,3D4h
       mov     al,0Ch
       mov     ah,bh
       out     dx,ax
       inc     al
       mov     ah,bl
       out     dx,ax

       mov     al,8
       mov     ah,cl
       and     ah,15
       out     dx,ax

       mov     dx,3DAh
@22:   in      al,dx
       test    al,08
       je      @22
       sti
  end;

procedure ScrollAnsiScreen;
label 2;
begin
  ScrollSpeed := 4;
  PageSpeed := 10;
  MaxLine := 2800;
  repeat
    Checker := 0;
    CurPos1 := CurPos;
    Key := Port[$60];
    while KeyPressed do ReadKey;
    if KeyPressed then Key := Port[$60];
    case Key of
       HomeKey :
           begin
            for Counter := 0 to CurPos div 10 - 1 do begin
             Dec(CurPos,PageSpeed);
             SetOfs(CurPos);
            end;
           end;
       EndKey :
           begin
            for Counter := CurPos div 10 + 1 to (MaxLine div 10 + 1)-1 do begin
             Inc(CurPos,PageSpeed);
             SetOfs(CurPos);
            end;
           end;
       PgupKey :
           begin
            if CurPos > 399 then begin
              for Counter := 0 to 39 do begin
                Checker := 1;
                Dec(CurPos, PageSpeed);
                SetOfs(CurPos);
              end;
              end;
            if CurPos < 400 then
              if CurPos > 1 then
              if Checker = 0 then begin
             for Counter := 0 to (((CurPos) div 10)) do begin
                Dec(CurPos, PageSpeed);
                SetOfs(CurPos);
              if CurPos < 0 then begin
              CurPos := 0;
              SetOfs(CurPos);
              end;
             end;
             end;
          end;
       PgdnKey :
           begin
            if CurPos > MaxLine then CurPos := MaxLine;
            if CurPos < MaxLine then begin
              for Counter := 0 to 39 do begin
                Inc(CurPos, PageSpeed);
                IF CurPos > MaxLine then goto 2;
                SetOfs(CurPos);
              end;
            end;
           end;
       UpKey :
           if CurPos > 1 then
              begin
                Dec(CurPos, ScrollSpeed);
                IF CurPos > MaxLine then goto 2;
                SetOfs(CurPos);
              end;
       DownKey :
            if CurPos < MaxLine + 10 then
              begin
                Inc(CurPos, ScrollSpeed);
                if CurPos > MaxLine then goto 2;
                SetOfs(CurPos);
               2:
              end;
    end;
    if CurPos > MaxLine then CurPos := MaxLine;
  until Key = EscKey;
  FadedownRGBScreen;
  Reset80x25VideoScreen;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Unit Is Loaded.      *)
(****************************************************************************)

end.


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
