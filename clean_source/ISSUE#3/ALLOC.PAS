{$G+}
Unit Alloc;
{
  Memory allocation and deallocation routines (C type), without using Heap
  by Maple Leaf, 1996
  -------------------
  386 registers used.
  Last update: 2nd May 1996
}
Interface

{ --------<<< Conventional memory >>>---------- }

Const
  UseUMB : Boolean = True;  { If TRUE, the malloc routine will try to allocate
                              the memory block into the Upper Memory (if possible) }

function malloc(size:LongInt):pointer;
{ Allocates a memory block, returns a pointer to it. Offset is always 0. (paragraph alligned) }
function calloc(size:LongInt):pointer;
{ Like MALLOC, but it does initialize the block with 0 }
function halloc(size:LongInt):word;
{ Like MALLOC, returns the segment nr. of the allocated block }
function realloc(var MemPtr:Pointer; size:LongInt):LongInt;
{ Reallocates a memory block, returns the new maximal possible size (could be with up to 16 bytes greater than SIZE) }
{ Warning: if returned value is less than SIZE, then the reallocation IS NOT DONE, you must
  do it by yourself using this value as a parameter in realloc function. }

function free(var MemPtr:pointer):boolean;
{ Deallocates a memory block, returns True if successful }
function hfree(var MemSeg:word):boolean;
{ Like FREE, uses block's seg, returns True if successful }

function mavail:LongInt;
{ Returns the amount of bytes in the greatest possible block }
function umblink(LinkStatus:boolean):boolean;
{ Returns the current status of UMB linkage and set it to LinkStatus }

Implementation

function _malloc(size:LongInt):pointer;assembler;
asm
     db 66h; mov ax,word ptr Size
     test ax,0Fh
     pushf
     db 66h; shr ax,4
     popf
     jz @1
     db 66h; inc ax
@1:  db 66h; mov bx,ax   { ebx:=((size div 16) + 1) paragraphs }
     mov ah,48h
     clc
     int 21h    {Allocate memory}
     jc @Error
     xor dx,dx
     xchg ax,dx
     jmp @Exit
@Error:
     xor dx,dx
     xor ax,ax
@Exit:
end;

function _realloc(var MemPtr:Pointer;size:LongInt):LongInt;assembler;
asm
     les di,MemPtr
     les di,es:[di]
     db 66h; mov ax,word ptr Size
     test ax,0Fh
     pushf
     db 66h; shr ax,4
     popf
     jz @1
     db 66h; inc ax
@1:  db 66h; mov bx,ax  { ebx:=(NewSize div 16)+1) paragraphs }
     clc
     mov ah,4ah
     int 21h
     db 66h; rol bx,16
     xor bx,bx
     db 66h; rol bx,16+4
     mov ax,bx
     db 66h; shr bx,16
     mov dx,bx
@Exit:
end;

function _free(var MemPtr:pointer):boolean;assembler;
asm
     les di,MemPtr
     les di,es:[di]
     mov ax,es
     or ax,ax
     jz @Exit
     mov ah,49h
     clc
     int 21h
     mov ax,0
     jc @Exit
     les di,MemPtr
     mov word ptr es:[di],0
     mov word ptr es:[di+2],0
     mov ax,1
@Exit:
end;

function _mavail:LongInt;assembler;
asm
     mov ax,4800h
     mov bx,0FFFFh
     clc
     int 21h
     clc
     xor dx,dx
     mov ax,bx
     mov cx,16
     mul cx
end;

function umblink(LinkStatus:boolean):boolean;assembler;
asm
  mov ax,5802h
  int 21h
  mov ah,0
  jc @getout
  mov ah,al
  push ax
  mov ax,5803h
  xor bh,bh
  mov bl,LinkStatus
  int 21h
  pop ax
@getout:
  mov al,ah
end;

function malloc;
var SaveLink:Boolean;
begin
  if UseUMB then SaveLink:=umblink(true);
  malloc:=_malloc(size);
  if UseUMB then umblink(SaveLink);
end;

function free;
var SaveLink:Boolean;
begin
  if UseUMB then SaveLink:=umblink(true);
  free:=_free(MemPtr);
  if UseUMB then umblink(SaveLink);
end;

function realloc;
var SaveLink:Boolean;
begin
  if UseUMB then SaveLink:=umblink(true);
  realloc:=_realloc(MemPtr,Size);
  if UseUMB then umblink(SaveLink);
end;

function mavail;
var SaveLink:Boolean;
begin
  if UseUMB then SaveLink:=umblink(true);
  mavail:=_mavail;
  if UseUMB then umblink(SaveLink);
end;

function calloc;
var p:pointer;
begin
  p:=malloc(size);
  asm
      cmp word ptr p[2],0 {nil ?}
      je @getout
      db 66h; mov cx,word ptr size
      les di,p
      mov ax,1000h
  @1: mov es:[di],al
      dec ah
      jg @2
      mov ah,10h
      mov di,es
      inc di
      mov es,di
      xor di,di
  @2: db 66h; dec cx  {ecx}
      db 66h; jnz @1
  @getout:
  end;
  calloc:=p;
end;

function halloc;
var p:pointer;
begin
  p:=malloc(size);
  halloc:=word(longint(p) shr 16);
end;

function hfree;
var p:pointer;
begin
  p:=ptr(MemSeg,0);
  MemSeg:=0;
  hfree:=free(p);
end;

begin
end.