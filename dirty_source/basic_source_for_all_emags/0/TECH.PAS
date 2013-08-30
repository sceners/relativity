{$g+}
unit tech;
interface
uses variable;


procedure initvga;  { initialize vga card mode 13h }
procedure closevga; { close vga mode and set text }
procedure move32fast(var Source,Dest; Count:word);
Function Sigok(sig2:ar17):boolean;
Procedure WaitRetrace;
Function KeyPressed : {output} Boolean;
Procedure New_Key_Int; Interrupt;
implementation

Function KeyPressed : {output} Boolean; Assembler;
Asm
  mov ah, 01h
  int 16h
  mov ax, 00h
  jz @1
  inc ax
  @1:
end; { KeyPressed. }

{$F+,S-}  { It's usually wise to turn on far calls and    }
          { stack checking off when yer messin' with ISRs }

Procedure New_Key_Int;
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
{    Which_Move(raw_key);}
end;

{$F-,S+}   { Reset far calling and stack checking }


{Procedure WaitRetrace; assembler;
Asm
   mov  dx,3DAh
@l2:
   in   al,dx
   and  al,08h
   jz   @l2
End;}

Procedure WaitRetrace; assembler;
Asm
    mov    DX,3DAh     { Input #1 status register (page 347) }
  @WaitVS1:
    in    AL,DX
    test  AL,08h       { Let him finish this retrace (if any)}
    jnz    @WaitVS1
   @WaitVS2:
    in    AL,DX
    test  AL,08h    { Is it still in display mode ? }
    jz   @WaitVS2   { then wait }  { NEW retrace has begun ! GO ! GO ! GO ! }
end;


procedure move32fast(var Source,Dest; Count:word); assembler;
asm
   push        ds
   les        di,Dest
   lds        si,Source
   mov        cx,count
   mov        bx,cx
   shr        cx,2
   db 66h;        rep movsw
   and        bx,3
   mov        cx,bx
   rep        movsb
   pop        ds
end;

Function Sigok(sig2:ar17):boolean;
var i:integer;
    b:boolean;
begin
     b:=true;
     i:= 1;
     repeat
          if sig2[i] <> sig[i] then
          b:=false;
          inc(i);
     until (b=false) or (i=sizeof(sig)+1);
     sigok:=b;
end;


procedure initvga; assembler; { initialize vga card mode 13h }
asm
 mov ax,0013h
 int 10h
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�}
procedure closevga; assembler; { close vga mode and set text }
asm
 mov ax,0003h
 int 10h
end;

end.