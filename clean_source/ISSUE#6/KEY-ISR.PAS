Program New_Int09h_ISR;

Uses VGAunit,  { used by putpixel                }
     DOS,      { used by SetIntVec and GetIntVec }
     CRT;      { used by delay()                 }

Const
  KEYBOARD_INT = $09;
  KEY_BUFFER   = $60;
  KEY_CONTROL  = $61;
  INT_CONTROL  = $20;

  MAKE_UP      = 72;
  MAKE_DOWN    = 80;
  MAKE_RIGHT   = 77;
  MAKE_LEFT    = 75;

  BREAK_UP     = 200;
  BREAK_DOWN   = 208;
  BREAK_RIGHT  = 205;
  BREAK_LEFT   = 203;

  INDEX_UP     = 0;
  INDEX_DOWN   = 1;
  INDEX_RIGHT  = 2;
  INDEX_LEFT   = 3;

Var
  Old_ISR   : Pointer;
  raw_key   : Integer;
  key_table : array[0..3] of Byte;
  Done      : Boolean;
  x         : Integer;
  y         : Integer;
  colour    : byte;

Function GetPixel(x,y: Integer) : Byte;
  Begin
    GetPixel := Mem[$A000:((y shl 8) + (y shl 6)) + x];
  End;

Procedure DrawBM;
Const
  BM : array[0..15,0..15] of byte = (
	 (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
	 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
	 (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
	 (0,0,1,1,1,1,1,2,2,1,1,1,1,1,0,0),
	 (0,1,1,1,1,1,2,2,2,2,1,1,1,1,1,0),
         (0,1,1,1,1,2,2,3,3,2,2,1,1,1,1,0),
         (1,1,1,1,2,2,3,3,3,3,2,2,1,1,1,1),
         (1,1,1,1,2,2,3,4,4,3,2,2,1,1,1,1),
         (1,1,1,1,2,2,3,3,3,3,2,2,1,1,1,1),
         (0,1,1,1,1,2,2,3,3,2,2,1,1,1,1,0),
         (0,1,1,1,1,1,2,2,2,2,1,1,1,1,1,0),
         (0,0,1,1,1,1,1,2,2,1,1,1,1,1,0,0),
         (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0),
         (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
         (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
         (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));
  Var
    j,k : Byte;
  Begin
    For j := 0 to 15 Do Begin
      For k := 0 to 15 Do Begin
		  If BM[j,k] <> 0 then PutPixel(x+k,y+j,BM[k,j] OR GetPixel(x+k,y+j) + 1);
      End;
    End;
  End;


{$F+,S-}  { It's usually wise to turn on far calls and    }
          { stack checking off when yer messin' with ISRs }

Procedure New_Key_Int; Interrupt;
  Begin
    Asm
      sti
      in al, KEY_BUFFER
      xor ah, ah
      mov raw_key, ax
      in al, KEY_CONTROL
      or al, 82h
      out KEY_CONTROL, al
      and al, 7Fh
      out KEY_CONTROL, al
      mov al, 20h
      out INT_CONTROL, al
	 End;
    Case raw_key of
      MAKE_UP     : key_table[INDEX_UP   ] := 1;
      MAKE_DOWN   : key_table[INDEX_DOWN ] := 1;
      MAKE_RIGHT  : key_table[INDEX_RIGHT] := 1;
      MAKE_LEFT   : key_table[INDEX_LEFT ] := 1;
      BREAK_UP    : key_table[INDEX_UP   ] := 0;
      BREAK_DOWN  : key_table[INDEX_DOWN ] := 0;
      BREAK_RIGHT : key_table[INDEX_RIGHT] := 0;
      BREAK_LEFT  : key_table[INDEX_LEFT ] := 0;
    Else
    End;
  End;

{$F-,S+}   { Reset far calling and stack checking }

Begin

  Done := False; x := 160; y := 100;
  FillChar(key_table,SizeOf(key_table),0);

  SetMCGA;

  LoadPal('RainBow.Pal');
  Set_Pal(0,0,0,63);

  GetIntVec(KEYBOARD_INT,Old_ISR);
  SetIntVec(KEYBOARD_INT,@New_Key_Int);

  While not Done Do Begin

    If Boolean(key_table[INDEX_RIGHT]) Then Begin
      inc(x);
      If x >= 319-15 Then x := 319-15;
		DrawBM;
	 End;

	 If Boolean(key_table[INDEX_LEFT ]) Then Begin
		dec(x);
		If x <= 1 Then x := 1;
		DrawBM;
	 End;

    If Boolean(key_table[INDEX_UP   ]) Then Begin
      dec(y);
      If y <= 1 Then y := 1;
      DrawBM;
    End;

    If Boolean(key_table[INDEX_DOWN ]) Then Begin
      inc(y);
      If y >= 199-15 Then y := 199-15;
      DrawBM;
    End;

    If raw_key = 1 Then Done := True;

	 Delay(3);  { slow it down...it's FAST! }
  End;

  SetIntVec(KEYBOARD_INT,Old_ISR);
  LoadPal('default.pal');

  asm mov ax, 03h; int 10h end;

End.
