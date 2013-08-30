{$G+ 286/287 instuctions }
Unit VGAunit;

Interface

VAR
  Address : word;
  where : word;
  poly_clip_min_x : word;
  poly_clip_max_x : word;
  poly_clip_min_y : word;
  poly_clip_max_y : word;

{ Shapes, Lines, Polys, etc. }
Procedure Box(x1, y1, x2, y2 : word; color : byte);
Procedure BoxFill (x1, y1, x2, y2 : word; c : byte);
Procedure Circle (mX, mY, mR : word; c : byte);
Procedure DrawLineH (x1, x2, y1 : word; c : byte);
Procedure DrawLineV (x1, y1, y2 : word; c : byte);
Procedure HorLine (xb, xe, y : word; c : byte);
Procedure Line (x1, y1, x2, y2 : word; c : byte);
Function  Clip(var x1, y1, x2, y2 : integer) : boolean;
Procedure Clip_Line(x1, y1, x2, y2 : integer; c : byte);
Procedure Polygon (x1, y1, x2, y2, x3, y3, x4, y4 : word; c : byte);
Procedure TriAngle(X1,Y1,X2,Y2,X3,Y3:Integer; Color:Byte); {poly}

{XOR lines/boxes - note: pretty slow, no optimization at all!}
Procedure HLine_xor (xb, xe, y : word);
Procedure VLine_xor (yb, ye, x : word);
Procedure Box_xor(x1, y1, x2, y2 : word);

{ Gets and Puts }
Procedure GetImage (x1, y1, x2, y2 : word; VAR Image : pointer);
Procedure PutImage (x1, y1 : word; VAR img);
Function  GetPixel (x, y : word) : byte;
Procedure PutPixel (x, y : word; c : byte);

{ Palette procedures }
Procedure Get_Pal(c: byte; var r, g, b : byte);
Procedure Set_Pal(c, r, g, b : byte);

{ Various file format loaders }
Procedure LoadCEL (FileName : string; ScrPtr : pointer);
Procedure LoadPAL (FileName : string);

{ Scrolling procedures }
Procedure ScrollLeft (x1, y1, x2, y2 : word);
Procedure ScrollRight (x1, y1, x2, y2 : word);
Procedure ScrollUp (x1, y1, x2, y2 : word);
Procedure ScrollDown (x1, y1, x2, y2 : word);

{ Memory related procedure }
Procedure FillChar386 (VAR buf; cnt : word; val : byte);
Procedure FillScreen (c : byte);
Procedure Move386 (VAR src, dst; cnt:word);

{ Miscellaneous }
Procedure Cls (col : byte);
Procedure Pause;
Procedure SetMode(mode : word);
Procedure SetMCGA;
Procedure TextMode;
Procedure WaitRetrace;
Procedure CLI; inline($FA); { disable interrupts }
Procedure STI; inline($FB); { enable interrupts }

Implementation

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Box(x1, y1, x2, y2 : word; color : byte);
	Var
      temp : word;
   BEGIN
      if x1>x2 then begin temp:=x1; x1:=x2; x2:=temp; end;
      if y1>y2 then begin temp:=y1; y1:=y2; y2:=temp; end;
      DrawLineH(x1,x2,y1,15);  { top line    }
		DrawLineH(x1,x2,y2,15);  { bottom line }
		DrawLineV(x1,y1,y2,15);  { left line	}
		DrawLineV(x2,y1,y2,15);  { right line	}
	END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure BoxFill(x1, y1, x2, y2 : word; c : byte);
  VAR
	 y : word;
  BEGIN
	  For Y:=Y1 to Y2 Do DrawLineH(x1, x2, y, c);
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Circle(MX, MY, MR: word; C: byte); ASSEMBLER;
  VAR d, x, y: integer;
  ASM
	 mov ax,MR;mov Y,ax;shl ax,1;mov D,3;sub D,ax;mov X,0;mov ax,where;
	 mov es,ax;mov ah,C;jmp @start;@putdot:cmp cx,0;jl @bad;cmp cx,319;jg @bad;
	 cmp dx,0;jl @bad;cmp dx,199;jg @bad;xchg dh,dl;mov di,dx;shr dx,2;
	 add di,dx;add di,cx;add di,0000h;mov es:[di],ah;@bad:ret;@start:mov cx,mx;
	 add cx,X;mov dx,my;add dx,Y;call @putdot;mov cx,mx;add cx,X;mov dx,my;
	 sub dx,Y;call @putdot;mov cx,mx;sub cx,X;mov dx,my;add dx,Y;call @putdot;
	 mov cx,mx;sub cx,X;mov dx,my;sub dx,Y;call @putdot;mov cx,mx;add cx,Y;
	 mov dx,my; add dx,X;call @putdot;mov cx,mx;add cx,Y;mov dx,my;sub dx,X;
	 call @putdot; mov cx,mx;sub cx,Y;mov dx,my;add dx,X;call @putdot;
	 mov cx,mx;sub cx,Y; mov dx,my;sub dx,X;call @putdot;cmp d,0;
	 jg @d_not_zero;mov dx,d;mov bx,x; shl bx,2;add bx,6;add dx,bx;mov d,dx;
	 jmp @Endit;@d_not_zero:mov dx,x; sub dx,y;shl dx,2;add dx,10;add dx,d;
	 mov d,dx;dec y;@Endit:inc x;mov dx,y; cmp x,dx;jl @start
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure DrawLineH(x1, x2, y1 : word; C : byte); ASSEMBLER;
  ASM
	 mov ax,where
	 mov es,ax
	 mov ax,y1
	 mov di,ax
	 shl di,1
	 shl di,1
	 add di,ax
	 mov cl,6
	 shl di,cl
	 mov bx,x1
	 mov dx,x2
	 cmp bx,dx
	 jl @1
	 xchg bx,dx
  @1:
	 inc dx
	 add di,bx
	 mov cx,dx
	 sub cx,bx
	 shr cx,1
	 mov al,c
	 mov ah,al
	 ror bx,1
	 jnb @2
	 stosb
	 ror dx,1
	 jnb @3
	 dec cx
  @3:
	 rol dx,1
  @2:
	 rep
	 stosw
	 ror dx,1
	 jnb @4
	 stosb
  @4:
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure DrawLineV(x1, y1, y2 : word; C : byte); ASSEMBLER;
  ASM
	 mov ax,x1
	 mov bx,y1
	 mov dx,y2
	 cmp bx,dx
	 jl @1
	 xchg bx,dx
  @1:
	 mov di,bx
	 shl di,1
	 shl di,1
	 add di,bx
	 mov cl,6
	 shl di,cl
	 add di,ax
	 mov cx,where
	 mov es,cx
	 mov cx,dx
	 sub cx,bx
	 inc cx
	 mov al,c
	 mov bx,$13f
  @2:
	 stosb
	 add di,bx
	 loop @2
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

{ Used with polygon procedure - possible from Bas Val Gallen }
Procedure HorLine(xb, xe, y : word; c : byte); ASSEMBLER;
  ASM
	 mov bx,[xb]
	 cmp bx,0				  { if zero don't draw }
	 jz @out
	 cmp bx,320
	 ja @out
	 mov cx,[xe]
	 jcxz @out
	 cmp cx,320
	 ja @out
	 cmp bx,cx				  { see if x-end is smaller than x-begin }
	 jb @skip
	 xchg bx,cx 			  { yes: switch coords }
  @skip:
	 inc cx
	 sub cx,bx				  { length of line in cx }
	 mov es,where 		  { segment to draw in }
	 mov ax,[y] 			  { heigth of line }
	 shl ax,6
	 mov di,ax
	 shl ax,2
	 add di,ax				  { y*320 in di (offset) }
	 add di,bx				  { add x-begin }
	 mov al,[c] 			  { get color }
	 shr cx,1				  { div length by 2 }
	 jnc @skip2 			  { carry set? }
	 stosb					  { draw byte }
  @skip2:
	 mov ah,al				  { copy color in hi-byte }
	 rep stosw				  { draw (rest of) line }
  @out:
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Line(x1, y1, x2, y2 : word; c : byte); ASSEMBLER;
  ASM
	 push ds
	 { Video Segment }
	 mov ax,where;
	 mov ds,ax;
	 mov es,ax
	 { Get Vars }
	 mov al,c;
	 mov dx,y2;
	 mov cx,x2;
	 mov bx,y1;
	 mov di,x1;
	 mov si,320
	 { Calc dX }
	 sub cx,di;
	 jz @vertical;
	 ja @l1
	 add di,cx;
	 neg cx;
	 xchg dx,bx
  @l1:
	 { Calc dY }
	 sub dx,bx;
	 jz @horizontal;
	 ja @l2
	 neg dx;
	 neg si
  @l2:
	 { Calc address }
	 xchg bh,bl;
	 add di,bx;
	 shr bx,2;
	 add di,bx
	 { Determine slope }
	 cmp cx,dx;
	 je @diagonal;
	 mov ax,0;
	 mov bx,8000h;
	 jb @high_slope
  @low_slope: { |dX| > |dY| > 0 }
	 div cx;
	 xchg dx,ax;
	 mov al,c
  @ls1:
	 mov ds:[di],al;
	 add bx,dx;
	 jc @ls3
  @ls2:
	 inc di;
	 dec cx;
	 jz @last
	 mov ds:[di],al;
	 add bx,dx;
	 jnc @ls2
  @ls3:
	 adc di,si;
	 dec cx;
	 jnz @ls1;
	 jmp @last
  @high_slope: { 0 < |dX| < |dY| }
	 xchg cx,dx;
	 div cx;
	 xchg dx,ax;
	 inc cx;
	 mov al,c
	 shr cx,1;
	 jnc @hs2
  @hs1:
	 mov ds:[di],al;
	 add bx,dx;
	 adc di,si
  @hs2:
	 mov ds:[di],al;
	 add bx,dx;
	 adc di,si
	 dec cx;
	 jnz @hs1;
	 jmp @last
  @vertical: { |dX| = 0 }
	 sub dx,bx;
	 jnb @v1
	 add bx,dx;
	 neg dx
  @v1:
	 xchg bh,bl;
	 add di,bx;
	 shr bx,2;
	 add di,bx;
	 inc dx
  @v2:
	 mov ds:[di],al;
	 add di,si;
	 dec dx;
	 jnz @v2;
	 jmp @end
  @horizontal: { |dY| = 0 }
	 inc cx;
	 xchg bh,bl;
	 add di,bx;
	 shr bx,2;
	 add di,bx
	 test di,1;
	 jz @h1
	 stosb;
	 dec cx
  @h1:
	 mov ah,al;
	 shr cx,1;
	 rep stosw;
	 jnc @END;
	 jmp @last
  @diagonal: { |dX| = |dY| }
	 inc si
  @d1:
	 mov ds:[di],al;
	 add di,si;
	 dec cx;
	 jnz @d1
  @last:
	 mov ds:[di],al
  @end:
	 pop ds
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Function Clip(var x1, y1, x2, y2 : integer) : boolean;
	Label end_proc;
	Var
		point_1     : integer;
		point_2     : integer;  { tracks if each end point is visible or invisible}
		clip_always : integer;  { used for clipping override}
		xi,yi       : integer;  { point of intersection}
		right_edge  : integer;  { which edges are the endpoints beyond}
		left_edge   : integer;
		top_edge    : integer;
		bottom_edge : integer;
		dx, dy      : real;     { used to holds slope deltas}

	Begin
		point_1     := 0;
		point_2     := 0;
		clip_always := 0;
		right_edge  := 0;
		left_edge   := 0;
		top_edge    := 0;
		bottom_edge := 0;
		clip        := FALSE;

	if ( (x1>=poly_clip_min_x) AND (x1<=poly_clip_max_x) AND
		  (y1>=poly_clip_min_y) AND (y1<=poly_clip_max_y) )
		  then point_1 := 1;

	if ( (x2>=poly_clip_min_x) AND (x2<=poly_clip_max_x) AND
		  (y2>=poly_clip_min_y) AND (y2<=poly_clip_max_y) )
		  then point_2 := 1;

	if (point_1=1) AND (point_2=1)
		then clip := TRUE;

	if (point_1=0) AND (point_2=0) then begin
		if ( ((x1<poly_clip_min_x) AND (x2<poly_clip_min_x)) OR
			  ((x1>poly_clip_max_x) AND (x2>poly_clip_max_x)) OR
			  ((y1<poly_clip_min_y) AND (y2<poly_clip_min_y)) OR
			  ((y1>poly_clip_max_y) AND (y2>poly_clip_max_y)) )
			  then begin
			  clip := FALSE;
			  goto end_proc;
		end;
		clip_always := 1;
		goto end_proc;
	end;

	{Lots of tests if point_1 is visible}
	if (( point_1=1) OR (point_1=0) AND (point_2=0) ) then begin
		dx := x2 - x1;
		dy := y2 - y1;
		if (x2 > poly_clip_max_x) then begin
			right_edge := 1;
			if (dx<>0) then
				yi := trunc((0.5 + (dy/dx) * (poly_clip_max_x - x1) + y1))
			else
				yi := -1;
		end else
		  if (x2 < poly_clip_min_x) then begin
			  left_edge := 1;
			  if (dx<>0) then
				  yi := trunc((0.5 + (dy/dx) * (poly_clip_min_x - x1) + y1))
			  else
				  yi := -1;
			end;

		if (y2 > poly_clip_max_y) then begin
			bottom_edge := 1;
			if (dy<>0) then
				xi := trunc((0.5 + (dx/dy) * (poly_clip_max_y - y1) + x1))
			else
				xi := -1;
		end else
			if (y2 < poly_clip_min_y) then begin
				top_edge := 1;
				if (dy<>0) then
					xi := trunc((0.5 + (dx/dy) * (poly_clip_min_y - y1) + x1))
				else
					xi := -1;  { invalidate intersection}
			end;

		if (right_edge=1) AND (yi>=poly_clip_min_y) AND (yi<=poly_clip_max_y) then begin
			x2 := poly_clip_max_x;
			y2 := yi;
			clip := TRUE;
		end else
			if (left_edge=1) AND (yi>=poly_clip_min_y) AND (yi<=poly_clip_max_y) then begin
				x2 := poly_clip_min_x;
				y2 := yi;
				clip := TRUE;
			end;

		if (bottom_edge=1) AND (xi>=poly_clip_min_x) AND (xi<=poly_clip_max_x) then begin
			x2 := xi;
			y2 := poly_clip_max_y;
			clip := TRUE;
		end else
			if (top_edge=1) AND (xi>=poly_clip_min_x) AND (xi<=poly_clip_max_x) then begin
				x2 := xi;
				y2 := poly_clip_min_y;
				clip := TRUE;
			end;
	end; { end if point_1 is visible}

	{ reset edge flags}
	right_edge := 0;left_edge:=0; top_edge :=0; bottom_edge := 0;

	{ Lots of tests for second endpoint}
	if ( (point_2=1) OR (point_1=0) AND (point_2=0)) then begin
		dx := x1 - x2;
		dy := y1 - y2;
		if (x1 > poly_clip_max_x) then begin
			right_edge := 1;
			if (dx<>0) then
				yi := trunc((0.5 + (dy/dx) * (poly_clip_max_x - x2) + y2))
			else
				yi := -1;
		end else
			if (x1 < poly_clip_min_x) then begin
				left_edge := 1;
				if (dx<>0) then
					yi := trunc((0.5 + (dy/dx) * (poly_clip_min_x - x2) + y2))
				else
					yi := -1;
			end;

		if (y1 > poly_clip_max_y) then begin
			bottom_edge := 1;
			if (dy<>0) then
				xi := trunc((0.5 + (dx/dy) * (poly_clip_max_y - y2) + x2))
			else
				xi := -1;
		end else
			if (y1 < poly_clip_min_y) then begin
				top_edge := 1;
				if (dy<>0) then
					xi := trunc((0.5 + (dx/dy) * (poly_clip_min_y - y2) + x2))
				else
					xi := -1;
			end;

		if (right_edge=1) AND (yi>=poly_clip_min_y) AND (yi<=poly_clip_max_y) then begin
			x1 := poly_clip_max_x;
			y1 := yi;
			clip := TRUE;
		end else
			if (left_edge=1) AND (yi>=poly_clip_min_y) AND (yi<=poly_clip_max_y) then begin
				x1 := poly_clip_min_x;
				y1 := yi;
				clip := TRUE;
			end;

		if (bottom_edge=1) AND (xi>=poly_clip_min_x) AND (xi<=poly_clip_max_x) then begin
			x1 := xi;
			y1 := poly_clip_max_y;
			clip := TRUE;
		end else
			if (top_edge=1) AND (xi>=poly_clip_min_x) AND (xi<=poly_clip_max_x) then begin
				x1 := xi;
				y1 := poly_clip_min_y;
				clip := TRUE;
			end; { end if intersected top edge}
	end; { end if point_2 is visible}
end_proc:
End; { end Clip}

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)


Procedure Clip_Line(x1, y1, x2, y2 : integer; c : byte);
  Begin
  if Clip(x1, y1, x2, y2) then begin
  ASM
	 push ds
	 { Video Segment }
	 mov ax,where;
	 mov ds,ax;
	 mov es,ax
	 { Get Vars }
	 mov al,c;
	 mov dx,y2;
	 mov cx,x2;
	 mov bx,y1;
	 mov di,x1;
	 mov si,320
	 { Calc dX }
	 sub cx,di;
	 jz @vertical;
	 ja @l1
	 add di,cx;
	 neg cx;
	 xchg dx,bx
  @l1:
	 { Calc dY }
	 sub dx,bx;
	 jz @horizontal;
	 ja @l2
	 neg dx;
	 neg si
  @l2:
	 { Calc address }
	 xchg bh,bl;
	 add di,bx;
	 shr bx,2;
	 add di,bx
	 { Determine slope }
	 cmp cx,dx;
	 je @diagonal;
	 mov ax,0;
	 mov bx,8000h;
	 jb @high_slope
  @low_slope: { |dX| > |dY| > 0 }
	 div cx;
	 xchg dx,ax;
	 mov al,c
  @ls1:
	 mov ds:[di],al;
	 add bx,dx;
	 jc @ls3
  @ls2:
	 inc di;
	 dec cx;
	 jz @last
	 mov ds:[di],al;
	 add bx,dx;
	 jnc @ls2
  @ls3:
	 adc di,si;
	 dec cx;
	 jnz @ls1;
	 jmp @last
  @high_slope: { 0 < |dX| < |dY| }
	 xchg cx,dx;
	 div cx;
	 xchg dx,ax;
	 inc cx;
	 mov al,c
	 shr cx,1;
	 jnc @hs2
  @hs1:
	 mov ds:[di],al;
	 add bx,dx;
	 adc di,si
  @hs2:
	 mov ds:[di],al;
	 add bx,dx;
	 adc di,si
	 dec cx;
	 jnz @hs1;
	 jmp @last
  @vertical: { |dX| = 0 }
	 sub dx,bx;
	 jnb @v1
	 add bx,dx;
	 neg dx
  @v1:
	 xchg bh,bl;
	 add di,bx;
	 shr bx,2;
	 add di,bx;
	 inc dx
  @v2:
	 mov ds:[di],al;
	 add di,si;
	 dec dx;
	 jnz @v2;
	 jmp @end
  @horizontal: { |dY| = 0 }
	 inc cx;
	 xchg bh,bl;
	 add di,bx;
	 shr bx,2;
	 add di,bx
	 test di,1;
	 jz @h1
	 stosb;
	 dec cx
  @h1:
	 mov ah,al;
	 shr cx,1;
	 rep stosw;
	 jnc @END;
	 jmp @last
  @diagonal: { |dX| = |dY| }
	 inc si
  @d1:
	 mov ds:[di],al;
	 add di,si;
	 dec cx;
	 jnz @d1
  @last:
	 mov ds:[di],al
  @end:
	 pop ds
  END;
  end;
End;
(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Polygon(x1, y1, x2, y2, x3, y3, x4, y4 : word; c : byte);
{I'm pretty sure this is from Bas Van Gallen (not optimized at all)}
  VAR
	 xpos 			 : array[0..199, 0..1] of integer;
	 mny, mxy, y	 : integer;
	 i 				 : word;
	 s1, s2, s3, s4 : shortint;
	 pos				 : byte;
  BEGIN
	 mny := y1;
	 if y2 < mny then mny := y2;
	 if y3 < mny then mny := y3;
	 if y4 < mny then mny := y4;

	 mxy := y1;
	 if y2 > mxy then mxy := y2;
	 if y3 > mxy then mxy := y3;
	 if y4 > mxy then mxy := y4;

	 s1 := byte(y1 < y2) * 2 - 1;
	 s2 := byte(y2 < y3) * 2 - 1;
	 s3 := byte(y3 < y4) * 2 - 1;
	 s4 := byte(y4 < y1) * 2 - 1;

	 y := y1;
	 pos := byte(y1 < y2);
	 If y1 <> y2 then
		repeat
		  xpos[y,pos] := integer(x2 - x1) * (y - y1) div (y2 - y1) + x1;
		  inc(y,s1);
		until y = y2 + s1
	 else
		xpos[y, pos] := x1;

	 y := y2;
	 pos := byte(y2 < y3);
	 if y2 <> y3 then
		repeat
		  xpos[y,pos] := integer(x3 - x2) * (y - y2) div (y3 - y2) + x2;
		  inc(y,s2);
		until y = y3 + s2
	 else
		xpos[y,pos] := x2;

	 y := y3;
	 pos := byte(y3 < y4);
	 if y3 <> y4 then
		repeat
		  xpos[y,pos] := integer(x4 - x3) * (y - y3) div (y4 - y3) + x3;
		  inc(y,s3);
		until y = y4 + s3
		  else xpos[y,pos] := x3;

	 y := y4;
	 pos := byte(y4 < y1);
	 if y4 <> y1 then
		repeat
		  xpos[y,pos] := integer(x1 - x4) * (y - y4) div (y1 - y4) + x4;
		  inc(y,s4);
		until y = y1 + s4
	 else xpos[y,pos] := x4;

	 For y:=mny to mxy do
		horline(xpos[y,0], xpos[y,1], y, c);

  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure TriAngle(X1,Y1,X2,Y2,X3,Y3:Integer; Color:Byte); Assembler;
{Very fast triangle poly filler, but not totally accurate.  I don't think
there's even one DIV in there (not even for the slope calculation)!!!}
	Var
		RV1,RV2,IF1,IF2,DeX1,DeX2,DeY1,DeY2 : Integer;
	Asm
		CLI
		{Sort by Y-value}
		Mov  CX,2
	 @@SortLoop:
		Mov  AX,[Y2]; Cmp  AX,[Y3]; JBE	@@Skip1
		Xor  AX,[Y3]; Xor  [Y3],AX; Xor	AX,[Y3]; Mov  [Y2],AX
		Mov  AX,[X2]; Xor  AX,[X3]; Xor	[X3],AX; Xor  AX,[X3]; Mov  [X2],AX
	 @@Skip1:
		Mov  AX,[Y1]; Cmp  AX,[Y2]; JBE	@@Skip2
		Xor  AX,[Y2]; Xor  [Y2],AX; Xor	AX,[Y2]; Mov  [Y1],AX
		Mov  AX,[X1]; Xor  AX,[X2]; Xor	[X2],AX; Xor  AX,[X2]; Mov  [X1],AX
	 @@Skip2:
		Mov  AX,[Y1]; Cmp  AX,[Y3]; JBE	@@Skip3
		Xor  AX,[Y3]; Xor  [Y3],AX; Xor	AX,[Y3]; Mov  [Y1],AX
		Mov  AX,[X1]; Xor  AX,[X3]; Xor	[X3],AX; Xor  AX,[X3]; Mov  [X1],AX
	 @@Skip3:
		Loop @@SortLoop
		{Calculate start-offsets}
		Mov  DX,[Y1]; Shl  DX,6; Mov	BX,DX; Shl	DX,2; Add  DX,BX
		Add  DX,[X1]; Mov  SI,DX
		{Claculate DY, and fill DeY en RefVar with it}
		{Just sorted by Y-value, so no checking for <0 is needed}
		Mov  AX,[Y3]; Sub  AX,[Y1]; Inc	AX; Mov	[DeY1],AX
		Mov  [RV1],AX; Mov  AX,[Y2]; Sub  AX,[Y1]; Inc	AX
		Mov  [DeY2],AX; Mov	[RV2],AX
		{Same for DX. Possible to get a <0 value, so check for that}
		Mov  [IF1],1; Mov  AX,[X3]; Sub	AX,[X1]; JNC  @@SkipDXNeg1
		Neg  AX; Neg  [IF1]
	 @@SkipDXNeg1:
		Inc  AX; Mov  [DeX1],AX; Mov	[IF2],1; Mov  AX,[X2]
		Sub  AX,[X1]; JNC  @@SkipDXNeg2; Neg  AX; Neg  [IF2]
	 @@SkipDXNeg2:
		Inc  AX; Mov  [DeX2],AX
		{Video segment in ES}
		Mov  AX,where; Mov  ES,AX
		Mov  AL,[Color]; Mov  AH,AL; Mov  CX,[DeY2]
	 @@DrawLoop1:
		Push CX
		{Draw a horizontal line}
		Mov  DI,DX
		Mov  CX,SI
		Cmp  CX,DI
		JA   @@DontSwap1
		Xchg CX,DI
	 @@DontSwap1:
		Sub  CX,DI
		Inc  CX
		Test CX,1
		JZ   @@Even1
		StosB
	 @@Even1:
		Shr  CX,1
		Rep  StosW
		{Adapt: RV1, Ofs1}
		Mov  BX,[RV1]
		Sub  BX,[DeX1]
		Cmp  BX,0
		JG   @@DoNothing1
	 @@DoSomething1:
		Add  BX,[DeY1]
		Add  DX,[IF1]
		Cmp  BX,0
		JLE  @@DoSomething1
	 @@DoNothing1:
		Add  DX,320
		Mov  [RV1],BX
		{Adapt: RV2, Ofs2}
		Mov  BX,[RV2]
		Sub  BX,[DeX2]
		Cmp  BX,0
		JG   @@DoNothing2
	 @@DoSomething2:
		Add  BX,[DeY2]
		Add  SI,[IF2]
		Cmp  BX,0
		JLE  @@DoSomething2
	 @@DoNothing2:
		Add  SI,320
		Mov  [RV2],BX
		Pop  CX
		Loop @@DrawLoop1
		{Adapt: DeY2, DeX2, RV2, IF2}
		Push DX
		Mov  DX,[Y3]
		Sub  DX,[Y2]
		Inc  DX
		Mov  [DeY2],DX
		Mov  [RV2],DX
		Mov  [IF2],1
		Mov  DX,[X3]
		Sub  DX,[X2]
		JNC  @@DX2Pos
		Neg  DX
		Neg  [IF2]
	 @@DX2Pos:
		Inc  DX
		Mov  [DeX2],DX
		Pop  DX
		{Draw second half of poly}
		Mov  CX,[DeY2]
	 @@DrawLoop2:
		Push CX
		{Draw a horizontal line}
		Mov  DI,DX
		Mov  CX,SI
		Cmp  CX,DI
		JA   @@DontSwap2
		Xchg CX,DI
	 @@DontSwap2:
		Sub  CX,DI
		Inc  CX
		Test CX,1
		JZ   @@Even2
		StosB
	 @@Even2:
		Shr  CX,1
		Rep  StosW
		{Adapt: RV1, Ofs1}
		Mov  BX,[RV1]
		Sub  BX,[DeX1]
		Cmp  BX,0
		JG   @@DoNothing3
	 @@DoSomething3:
		Add  BX,[DeY1]
		Add  DX,[IF1]
		Cmp  BX,0
		JLE  @@DoSomething3
	 @@DoNothing3:
		Add  DX,320
		Mov  [RV1],BX
		{Adapt: RV2, Ofs2}
		Mov  BX,[RV2]
		Sub  BX,[DeX2]
		Cmp  BX,0
		JG   @@DoNothing4
	 @@DoSomething4:
		Add  BX,[DeY2]
		Add  SI,[IF2]
		Cmp  BX,0
		JLE  @@DoSomething4
	 @@DoNothing4:
		Add  SI,320
		Mov  [RV2],BX
		Pop  CX
		Loop @@DrawLoop2
	 @@Exit:
		STI
End;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure HLine_xor (xb, xe, y : word);
	Var
		x:     word;
		color: byte;
	Begin
		for x := xb to xe do begin
			color := getpixel(x, y);
			putpixel(x, y, color xor 15); { harded coded xor color! }
		end;
	End;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure VLine_xor (yb, ye, x : word);
	Var
		y:     word;
		color: byte;
	Begin
		for y := yb to ye do begin
			color := getpixel(x, y);
			putpixel(x, y, color xor 15); { harded coded xor color! }
		end;
	End;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Box_xor(x1, y1, x2, y2 : word);
	Var
		temp : word;
	BEGIN
		if x1>x2 then begin temp:=x1; x1:=x2; x2:=temp; end;
		if y1>y2 then begin temp:=y1; y1:=y2; y2:=temp; end;
		HLine_xor(x1,x2,y1);  { top line 	}
		HLine_xor(x1,x2,y2);  { bottom line }
		VLine_xor(x1,y1,y2);  { left line	}
		VLine_xor(x2,y1,y2);  { right line	}
	END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure GetImage(X1,Y1,X2,Y2:word;VAR Image:Pointer);
  VAR
	 Screen : Array[1..200,1..320] of byte absolute $A000:0;
	 I,Width,Height,IOF,ISG:word;
  BEGIN
	 IOF := Ofs(Image^);
	 ISG := Seg(Image^);
	 Width := X2-X1;
	 Height := Y2-Y1;
	 MEMW[ISG:IOF]   := Width;
	 MEMW[ISG:IOF+2] := Y2-Y1;
	 Inc(IOF,4);
	 For I := 0 to Height do
		MOVE386(Screen[Y1+I,X1],MEM[ISG:IOF+(I*Width)],Width+1);
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure PutImage(X1,Y1:word; VAR IMG); ASSEMBLER;
  {	Do not pass a Pointer for IMG; Use a Buffer!   }
  VAR
	 CX1, CX2 : word;   { Holders for precalculations	 }
  ASM
	 { Instructions:	Clocks: Comments: 					 }
	 PUSH DS;			  { 11: DS Must be preserved! 	 }

	 LDS SI, IMG;		  { 16: DS:SI = Image Buffer		 }
	 MOV AX, 0A000h;	  { 04: A000:00 = Video Buffer	 }
	 MOV ES, AX;		  { 02: Can't "MOV ES, Immediate" }

	 LODSW;				  { 12: Get Width in AX 			 }

	 MOV CX, AX;		  { 10: Set Counter to IMG width  }
	 AND CX, 3; 		  { 04: Num of BYTEs to MOVE (0-3)}
	 MOV CX1, CX;			{ 09: Store in CX1 for LOOP	  }

	 MOV CX, AX;		  { 10: Set Counter to IMG width  }
	 SHR CX, 2; 		  { 09: Number of DOUBLEs to MOVE }
	 MOV CX2, CX;		  { 09: Store in CX2 for LOOP 	 }

	 MOV DX, 320;		  { 04: Width of full screen ..	 }
	 SUB DX, AX;		  { 03: .. SUB width of IMG in DX }

	 LODSW;				  { 12: Get Height in AX			 }
	 MOV BX, AX;		  { 10: Get Height from IMG		 }

	 MOV AX, Y1;		  { 04: MOV Y1 into AX for SHLing }
	 MOV CX, AX;		  { 03: Store a second copy in BX }
	 SHL AX, 6; 		  { 04: ** AX := (Y1*320)+X1	 ** }
	 SHL CX, 8; 		  { 04: ** without using MUL	 ** }
	 ADD AX, CX;		  { 03: ** by using shifts 	 ** }
	 ADD AX, X1;		  { 09: ** and adding.			 ** }

	 MOV DI, AX;		  { 02: DI to start position		 }

  @LOOP: 				  { --: Loop here after each line }
	 MOV CX, CX1;		  { 08: Number of BYTEs restored  }
	 REP MOVSB; 		  { --: Store leftover BYTEs. 	 }
	 MOV CX, CX2;		  { 08: Number of DOUBLEs restored}
	 DB 66h; REP MOVSW; { --: Extended 32-bit REP MOVSD.}
	 ADD DI, DX;		  { 03: Set DI to next position	 }
	 DEC BX; 			  { 03: Decrement height counter  }
	 JNZ @LOOP;

	 POP DS; 			  { 08: DS Must be preserved! 	 }
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Function GetPixel(X, Y : word) : byte; ASSEMBLER;
  ASM
	 mov es,where
	 mov ax,y
	 mov bx,x
	 add bh,al
	 shl ax,6
	 add bx,ax
	 mov al, es:[bx]
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Putpixel(x, y : word; c : byte); ASSEMBLER;
  ASM
	 mov es,where
	 mov ax,y
	 mov bx,x
	 add bh,al
	 shl ax,6
	 add bx,ax
	 mov al,c
	 mov es:[bx],al
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Get_Pal(c: byte; var r, g, b : byte);
	Begin
		Port[$3C7] := c;
		R := Port[$3C9];
		G := Port[$3C9];
		B := Port[$3C9];
	End;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Set_Pal(c, r, g, b : byte); ASSEMBLER;
  ASM
	 mov dx,3c8h;
	 mov al,[c];
	 out dx,al;
	 inc dx;            {-$3c9h-}
	 mov al,[r]
	 out dx,al;
	 mov al,[g];
	 out dx,al;
	 mov al,[b];
	 out dx,al;
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure LoadCEL (FileName :  string; ScrPtr : pointer);
  { This loads the cel 'filename' into the pointer scrptr }
  VAR
	 Fil : file;
	 Buf : array [1..1024] of byte;
	 BlocksRead, Count : word;
  BEGIN
	 {$I-}
	 assign (Fil, FileName);
	 reset (Fil, 1);
	 {$I+}
	 if ioresult=0 then begin
		 BlockRead (Fil, Buf, 800);	 { Read and ignore the 800 byte header }
		 Count := 0;
		 BlocksRead := $FFFF;
		 while (not eof (Fil)) and (BlocksRead <> 0) do begin
			BlockRead (Fil, mem [seg (ScrPtr^): ofs (ScrPtr^) + Count], 1024, BlocksRead);
			inc(Count,1024);
		 end;
		 close (Fil);
	 end else begin
		 asm mov ax, 03h; int 10h; end;
		 Writeln('Palette not found');
		 halt(1);
	 end;
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure LoadPAL(FileName : String);
	TYPE rgb = Record r,g,b : byte; END;
	VAR
		col : Array[0..255] of rgb;
		i   : Integer;
		f   : File;
	BEGIN
		{$I-}
		assign(f,fileName);
		reset(f,1);
		{$I+}
		if ioresult=0 then begin
			blockread(f, col, sizeof(col));
			close(F);
			for i := 0 to 255 do begin
				with col[i] do begin
					set_Pal(i,r,g,b)
				end
			end
		end else begin
			asm mov ax, 03h; int 10h; end;
			Writeln('Palette not found');
			halt(1);
		end;
	END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)
{very slow screen scoller, even has a mul and rep stodb!}
Procedure ScrollLeft(X1,Y1,X2,Y2:word); ASSEMBLER;
  ASM
	 push ds
	 mov ax,where
	 mov es,ax
	 mov ds,ax
	 mov si,[bp+offset y1]
	 mov cx,[bp+offset y2]
	 sub cx,si
	 inc cx

	 mov ax,320
	 shl ax, 6
	 mov si, ax
	 shl ax, 8
	 add si, ax
	 {mul si}

	 mov bx,[bp+offset x1]
	 add ax,bx
	 mov dx,[bp+offset x2]
	 sub dx,bx
	 inc dx
	 cld
  @1:
	 mov bx,cx
	 mov di,ax
	 dec di
	 mov si,ax
	 mov cx,dx
	 shr cx, 1
	 inc cx
	 rep movsw
	 mov cx,bx
	 add ax,320
	 loop @1
	 pop ds
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)
{very slow screen scoller}
Procedure ScrollRight(X1,Y1,X2,Y2:word); ASSEMBLER;
  ASM
	 push ds
	 mov ax,where
	 mov es,ax
	 mov ds,ax
	 mov si,[bp+offset y1]
	 mov cx,[bp+offset y2]
	 sub cx,si
	 inc cx

	 mov ax, 320
	 shl ax, 6
	 mov si, ax
	 shl ax, 8
	 add si, ax

	 mov bx,[bp+offset x1]
	 mov dx,[bp+offset x2]
	 add ax,dx
	 sub dx,bx
	 inc dx
	 std
  @1:
	 mov bx,cx
	 mov di,ax
	 mov si,ax
	 dec si
	 mov cx,dx

	 shr cx, 1
	 inc cx
	 rep movsw

	 mov cx,bx
	 add ax,320
	 loop @1
	 cld
	 pop ds
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)
{very slow screen scoller}
Procedure ScrollUp(X1,Y1,X2,Y2:word); ASSEMBLER;
  ASM
	 push ds
	 mov ax,where
	 mov es,ax
	 mov ds,ax
	 mov si,[bp+offset y1]
	 mov cx,[bp+offset y2]
	 sub cx,si
	 inc cx
	 mov ax,320
	 mul si
	 mov bx,[bp+offset x1]
	 add ax,bx
	 mov dx,[bp+offset x2]
	 sub dx,bx
	 inc dx
	 cld
  @1:
	 mov bx,cx
	 mov di,ax
	 sub di,320
	 mov si,ax
	 mov cx,dx
	 rep movsb
	 mov cx,bx
	 add ax,320
	 loop @1
	 pop ds
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)
{very slow screen scoller}
Procedure ScrollDown(X1,Y1,X2,Y2:word); ASSEMBLER;
  ASM
	 push ds
	 mov ax,where
	 mov es,ax
	 mov ds,ax
	 mov si,[bp+offset y1]
	 mov cx,[bp+offset y2]
	 mov ax,320
	 mul cx
	 sub cx,si
	 inc cx
	 mov bx,[bp+offset x1]
	 mov dx,[bp+offset x2]
	 add ax,bx
	 sub dx,bx
	 inc dx
	 cld
  @1:
	 mov bx,cx
	 mov di,ax
	 mov si,ax
	 sub si,320
	 mov cx,dx
	 rep movsb
	 mov cx,bx
	 sub ax,320
	 loop @1
	 pop ds
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure FillChar386(VAR BUF;CNT:word;VAL:byte); ASSEMBLER;
  ASM
	 { Instructions:	Clocks: Comments: 					 }
	 LES DI, BUF;		  { 16: Load Buffer. 				 }
	 MOV AL, [VAL];	  { 08: Load value to fill with.  }
	 MOV AH, AL;		  { 02: Set Double Bits 5-8		 }
	 DB 66h; XOR CX,CX; { ??: Clear ECX.					 }
	 MOV CX, AX;		  { 02: AX+CX; 						 }
	 DB 66h; SHL AX,16; { ??: SHL EAX, 16; 				 }
	 DB 66h; ADD AX,CX; { ??: ADD EAX, ECX;				 }
	 MOV CX, [CNT];	  { 08: Store length in CX.		 }
	 MOV DX, CX;		  { 02: Store a copy of CNT in DX }
	 SHR CX, 2; 		  { 09: Number of MOVSDs.			 }
	 DB 66h; REP STOSW; { --: REP STOSD  (32-Bit MOVS)  }
	 MOV CX, DX;		  { 08: Get CNT again via DX. 	 }
	 AND CX, 3; 		  { 04: # of leftover BYTEs (0-3).}
	 REP STOSB; 		  { --: Store leftover BYTEs. 	 }
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure FillScreen(C:byte); ASSEMBLER;
  ASM
	 mov ax,where
	 mov es,ax
	 mov al,c
	 mov ah,al
	 cld
	 xor di,di
	 mov cx,32000
	 rep stosw
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Move386(VAR SRC,DST;CNT:word); ASSEMBLER;
  { Instructions:  Clocks: Comments:					  }
  ASM
	 MOV AX, DS;		  { 08: Save DS in AX.				 }
	 LDS SI, SRC;		  { 16: Load Source Buffer.		 }
	 LES DI, DST;		  { 16: Load Destination Buffer.  }
	 MOV CX, CNT;		  { 08: Store length in CX.		 }
	 MOV BX, CX;		  { 02: Store a copy in BX.		 }
	 SHR CX, 2; 		  { 09: Number of DWORDs to MOVS. }
	 DB 66h; REP MOVSW; { --: Extended 32-bit REP MOVSD.}
	 MOV CX, BX;		  { 02: Get Length again.			 }
	 AND CX, 3; 		  { 04: # of leftover BYTEs (0-3).}
	 REP MOVSB; 		  { --: Store leftover BYTEs. 	 }
	 MOV DS, AX;		  { 08: Restore DS from AX.		 }
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Cls (Col : byte); ASSEMBLER;
  ASM
	 mov		es,[where]
	 mov		al,[col]
	 mov		ah,al
	 mov		cx, 32000;
	 xor		di,di
	 rep		stosw
	 pop		es
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure Pause; ASSEMBLER; {same as Readkey, but doesn't return anything}
  ASM
	 xor ax, ax;
	 int 16h;
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure SetMCGA; ASSEMBLER;
{ for older programs...or if I'm too lazy to put in the mode }
	ASM
		mov ax, 0013h
		int 10h
	END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure SetMode(mode : word); ASSEMBLER;
  ASM
	 mov ax, mode	 { (usually $13) }
	 int 10h
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure TextMode; ASSEMBLER; {for backward compatibility}
  ASM
	 mov ax, 0003h
	 int 10h
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure SetTEXT; ASSEMBLER; {new Textmode so it doesn't confict with CRT}
  ASM
	 mov ax, 0003h
	 int 10h
  END;

(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

Procedure WaitRetrace; ASSEMBLER;
  ASM
	 mov dx,$3da
  @1:
	 in al,dx
	 test al,8
	 jz @1
  @2:
	 in al,dx
	 test al,8
	 jnz @2
  END;
(*xìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxìxì*)

BEGIN
	where := $0a000;
	poly_clip_min_x := 0;
	poly_clip_max_x := 319;
	poly_clip_min_y := 0;
	poly_clip_max_y := 199;

END.
