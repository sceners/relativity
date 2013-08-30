{$G+}
unit EMS;
{
  Expanded Memory Specifications (EMS) handling routines
  by Maple Leaf, 1996
  ------------------------------------------------------------------------
  No rights reserved.
}
interface

const emsPageFrameAddr : word = $0000;
      emsVersion : byte       = 0;
      emsError : byte         = 0;

      emsDevName = 'EMMXXXX0';


function  emsDetect:boolean;   { checks if EMS is present, detects emsPageFrameAddr }
function  emsFreePages:word;   { returns the nr. of available pages }
function  emsTotalPages:word;  { returns the total nr. pages }
function  emsAlloc(pages:word):word;        { allocates pages }
function  emsFree(var handle:word):boolean; { deallocates pages }
procedure emsMap(Handle,LogicalPage:word; PhysicalPage:byte);  { maps page }
procedure emsSaveMapping(handle:word);     { save mapping }
procedure emsRestoreMapping(handle:word);  { restore mapping }

implementation

function  emsDetect:boolean;   { checks if EMS is present, detects emsPageFrameAddr }
var emsid:string; p:longint; ok:boolean;
begin
  emsDetect:=false;
  p:=meml[0:$19C]; if p=0 then exit; { no EMM386 }
  p:=(p and $FFFF0000) or $A; { 'EMMXXXX0' str. address }
  emsid[0]:=#8; move(pointer(p)^,emsid[1],8);
  if emsid<>emsDevName then exit; { no EMM386 }
  asm
    mov ok,1
    mov ah,40h
    int 67h
    or ah,ah
    jz @ok
    mov ok,0
  @ok:
  end;
  if not ok then exit; { Exp. memory manager is not working correctly }
  asm
    mov ah,41h
    int 67h   { get page frame address }
    mov emsPageFrameAddr,bx
    mov ah,46h
    int 67h   { get version }
    mov emsVersion,al
  end;
  emsDetect:=true;
end;

function emsFreePages:word;assembler;
asm
  push bx
  push dx
  mov ah,42h
  int 67h
  mov emsError,ah
  mov ax,bx
  pop dx
  pop bx
end;

function emsTotalPages:word;assembler;
asm
  push bx
  push dx
  mov ah,42h
  int 67h
  mov emsError,ah
  mov ax,dx
  pop dx
  pop bx
end;

function emsAlloc(pages:word):word;assembler;
asm
  push bx
  push dx
  mov ah,43h
  mov bx,pages
  int 67h
  mov emsError,ah
  or ah,ah
  jnz @error
  mov ax,dx
  jmp @outta
@error:
  mov ax,0   { return 0 if error, since Handle 0 cannot be allocated }
@outta:
  pop dx
  pop bx
end;

function emsFree(var handle:word):boolean;assembler;
asm
  push dx
  mov ah,45h
  les di,handle
  mov dx,es:[di]
  int 67h
  mov emsError,ah
  or ah,ah
  jnz @error
  mov word ptr es:[di],0
  mov ax,1
  jmp @outta
@error:
  mov ax,0
@outta:
  pop dx
end;

procedure emsMap(Handle,LogicalPage:word; PhysicalPage:byte);assembler;
asm
  mov ah,44h
  mov al,PhysicalPage
  mov bx,LogicalPage
  mov dx,Handle
  int 67h
  mov emsError,ah
end;

procedure emsSaveMapping(handle:word);assembler;
asm
  mov ah,47h
  mov dx,handle
  int 67h
  mov emsError,ah
end;

procedure emsRestoreMapping(handle:word);assembler;
asm
  mov ah,48h
  mov dx,handle
  int 67h
  mov emsError,ah
end;

begin
  emsDetect;
end.
