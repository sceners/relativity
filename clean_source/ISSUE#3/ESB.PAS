Unit ESB;

{
   Sound Deluxe System 5
   a Music Interface Kit by Maple Leaf, 1996-97
   -----------------------------------------------------
   ESB (External Syncronization Block) managing routines
   See the documentation (ESB.DOC) before using this unit.
}

interface

Function  GetESBByte(offs:word):byte;
Function  GetESBWord(offs:word):word;
Function  GetESBDWord(offs:word):longint;
Procedure SetESBByte(offs:word; value:byte);
Procedure SetESBWord(offs:word; value:word);

implementation

Function  GetESBByte(offs:word):byte;assembler;
asm
  push es
  xor ax,ax
  mov es,ax
  les di,dword ptr es:[4FCh]
  add di,offs
  mov al,es:[di]
  pop es
end;

Function  GetESBWord(offs:word):word;assembler;
asm
  push es
  xor ax,ax
  mov es,ax
  les di,dword ptr es:[4FCh]
  add di,offs
  mov ax,es:[di]
  pop es
end;

Function  GetESBDWord(offs:word):longint;assembler;
asm
  push es
  xor ax,ax
  mov es,ax
  les di,dword ptr es:[4FCh]
  add di,offs
  mov ax,es:[di]
  mov dx,es:[di+2]
  pop es
end;

Procedure SetESBByte(offs:word; value:byte);assembler;
asm
  push es
  xor ax,ax
  mov es,ax
  les di,dword ptr es:[4FCh]
  add di,offs
  mov al,value
  mov es:[di],al
  pop es
end;

Procedure SetESBWord(offs:word; value:word);assembler;
asm
  push es
  xor ax,ax
  mov es,ax
  les di,dword ptr es:[4FCh]
  add di,offs
  mov ax,value
  mov es:[di],ax
  pop es
end;

begin
end.