Unit revhard;

interface

const
   DESQviewActive : boolean = false; { true if running under DESQview }
   DESQviewMajor  : byte    = 0;
   DESQviewMinor  : byte    = 0;

Type
  CpuType = ( cpu8088,cpu8086,cpu80286,cpu80386,
              cpu80486,cpuPentium,cpuFuture);
  CpuStrType = String[7];


Const
  CpuTypeIdentified : Boolean = False;
Var
  ConfirmedCpuType : CpuType;

Procedure HardWareInit;

Procedure ComputerModel(var comp:string);
procedure biosdate(var date:string); {Returns the bios date}
Procedure pci(var pcis:string); {Tells if there is a PCI board}
Procedure detectfpu(var co:string); {Detects a coprocessor, not 100% reliable
                             Returns true if found, false if not found}
Procedure detectgame(var joy:string); {Tells if there is a game card or joystick port
                              Returns TRUE if found}
function xms:boolean; {Tells if there is an extended memory manager
                       Returns true if found}
function emm:boolean;  {Tells if there is an expanded memory manager, EMM386
                        Returns TRUE if found (not tested with QEMM) }
procedure svga(var svg:string); {Checks for a VESA compliant card}
function cdrom:boolean;{Tells if MSCDEX is loaded (and consequently if there is
                          a CD-ROM drive. Returns TRUE if found}
procedure _4dos(var strr:string){Tells us if 4DOS.COM is loaded and its version};

Function WhichCPU : CpuType;
Function GetCpuType : CpuType;
Procedure IdentifyCpuType;
Function GetCpuTypeStr : CpuStrType;
Procedure show_ram(var b,e:word);
Function detectDESQview:boolean;
function dosemu_Detect:boolean;

implementation
uses crt,dos,revansi,revconst,revdat,revwin,detectso,revgfx;

{$L CPU.OBJ}

{$F+}
Function WhichCPU : CpuType;
  { Determines and returns the currently executing CPU type }
EXTERNAL;
{$F-}

Procedure HardWareInit;
var strr:string;
    size,b,e:word;
var regs : registers;
procedure id_version;
begin
  regs.ah := $30;
  msdos( regs);
end;

begin
extractpointerfromdat(config^.init,tempbin,size);
DisplayAnsiPointer(tempbin);
textcolor(darkgray);
textbackground(green);
gotoxy(33,2);write('6');
gotoxy(62,2);write('30/01/98');
textcolor(lightgreen);
textbackground(darkgray);
gotoxy(66,20);write('30/01/98');
gotoxy(55,21);write('6');
gotoxy(52,21);write('8');
textcolor(darkgray);
textbackground(green);
strr:='';computermodel(strr);gotoxy(26,4);write(strr);
strr:='';biosdate(strr);gotoxy(26,5);write('[',strr,']');
gotoxy(26,6);write('Rad Engine');
gotoxy(26,7);

if DetSoundBlaster then write('Sound Blaster Detected')
else write('Nothing Detected');

if voc then
begin
   gotoxy(26,8);write('Wave Output Detected');
end
else
begin
    gotoxy(26,8);write('Output Not Detected');
end;

gotoxy(26,9);write('Adlib');
strr:='';gotoxy(26,10);write(GetCpuTypeStr);strr:='';detectFpu(strr);write(', ',strr);
show_ram(b,e);gotoxy(26,11);write(b,'K');
if xms then begin
       gotoxy(26,13);write('True, ',E,'K');
       end else begin
       gotoxy(26,13);write('False');
       end;

if emm then begin
       gotoxy(26,12);write('True');
       end else begin
       gotoxy(26,12);write('False');
       end;

strr:='';gotoxy(26,14);Write(disksize(0) div 1024,' Kbytes Avail. ', DiskFree(0) div 1024, ' Kbytes free.');
strr:='';Pci(strr);gotoxy(26,15);write(strr);

if dosemu_Detect then
begin
     gotoxy(26,18);write('Dosemu Detected, Running Under Linux');
end
else
begin
    if Win3X then
    begin
         gotoxy(26,18);write('Windows, Version : ',lo(winver),'.',hi(winver));
    end
    else
    begin
         id_version;
         gotoxy(26,18);write('Dos Version : ',regs.al,'.');
         IF ( regs.ah < 10 ) THEN write( '0' );
         write( regs.ah );
    end;
end;

gotoxy(26,16);
strr:='';
svga(strr);
write(strr);
{if vga then str:='80x25 Text Mode, Vga 640x480'
else str:='80x25 Text Mode'; write(str);}

gotoxy(26,17);write(config^.font[config^.curfnt]);
gotoxy(26,19);strr:='';

detectDESQview;
_4dos(strr);write(strr);


gotoxy(26,20);
if cdrom then
   write('Detected')
else write('Not Found');

gotoxy(26,21);strr:='';
detectgame(strr);write(strr);

gotoxy(26,22);
write(config^.curmus,': ',config^.music[config^.curmus,1]);
gotoxy(26,23);

if detectDESQview then write('DesqView Detected V',DESQviewMajor,'.',DESQviewMinor)
else write('Not Detected');
hidecursor;

readkey;
end;

function dosemu_Detect:boolean; assembler;
asm
  push ds

{ check for the BIOS date }
  mov  ax,$F000
  mov  ds,ax
  mov  bx,$FFF5

  mov  ax,'20'
  cmp  word ptr [bx],'20'
  jne  @no_dosemu
  cmp  word ptr [bx+2],'2/'
  jne  @no_dosemu
  cmp  word ptr [bx+4],'/5'
  jne  @no_dosemu
  cmp  word ptr [bx+6],'39'
  jne  @no_dosemu

{ initialize interrupt $E6 to an IRET }
  xor  ax,ax
  mov  ds,ax
  mov  bx,$E6 * 4
  les  di,[bx]
  mov  bl,es:[di]
  mov  byte ptr es:[di],$CF { put an iret instruction }

{ call the installation check interrupt (int $E6 with ah = 0) }
  xor  ah,ah
  int  $E6
  mov  es:[di],bl           { restore the old instruction }
  cmp  ax,$AA55
  jne  @no_dosemu

  mov  ax,01h
  jmp  @end

@no_dosemu:
  xor  ax,ax

@end:
  pop  ds
end;


Function detectDESQview:boolean;
var regs:registers;
begin
   regs.cx := $4445;
   regs.dx := $5351; { date cx = DE, dx = SQ }
   regs.ax := $2B01; { dos set date function }
   msdos(regs);
   if (regs.al = $ff) then
      detectDESQview:= false { if dos detected an error, no DV active }
   else begin
      detectDESQview:= true;
      DESQviewMajor  := regs.bh;
      DESQviewMinor  := regs.bl;
   end;
end; {detectDESQview}


Procedure show_ram(var b,e:word);
const
  int15: longint = $f000f859;
var
  baseram,extram: word;
begin
  asm
    int   12h
    mov   baseram,ax
    mov   ah,88h
    pushf
    call  int15
    mov   extram,ax
  end;
  B:=baseram;
  e:=extram;
end;



Procedure IdentifyCpuType;
  { Handles initialization of CPU type }
Begin
  If Not CpuTypeIdentified Then
  Begin
    ConfirmedCpuType  := WhichCPU;
    CpuTypeIdentified := True;
  End;
End;   { Procedure IdentifyCpuType }

Function GetCpuType : CpuType;
  { Returns the currently executing CPU type }
Begin
  IdentifyCpuType;
  GetCpuType := ConfirmedCpuType;
End;   { Function GetCpuType }

Function GetCpuTypeStr : CpuStrType;
  { Returns the currently executing CPU type as a string }
Begin
  IdentifyCpuType;
  Case ConfirmedCpuType Of
    cpu8088    : GetCpuTypeStr := '8088';
    cpu8086    : GetCpuTypeStr := '8086';
    cpu80286   : GetCpuTypeStr := '80286';
    cpu80386   : GetCpuTypeStr := '80386';
    cpu80486   : GetCpuTypeStr := '80486';
    cpuPentium : GetCpuTypeStr := 'Pentium';
    cpuFuture  : GetCpuTypeStr := 'Future';
  End;   { Case }
End;   { Function GetCpuTypeStr }

procedure biosdate(var date:string); {Returns the bios date}
var
l:byte;
c:char;

begin
     for l:=1 to 8 do begin
     c:=chr(mem[$f000:$fff4+l]);
     date:=date+c;
     end;
end;

Procedure pci(var pcis:string); {Tells if there is a PCI board Returns TRUE if found}

          function ispci:byte;assembler;asm
                   mov ax,0b101h
                   int 01ah
                   mov al,ah
          end;

begin
     if ispci=0 then
          pcis:='PCI board found'
     else pcis:='No PCI board found';
end;


Procedure detectfpu(var co:string); {Detects a coprocessor, not 100% reliable
                             Returns true if found, false if not found}
var

val: byte;

begin
     val:= mem[$0000:$0410];

             if val and 2=2 then
             co:='Coprocessor Detected'{Check bit 2}
             else co:='Coprocessor Not Detected';{Check bit 2}

end;


Procedure detectgame(var joy:string); {Tells if there is a game card or joystick port
                              Returns TRUE if found}
var
val: byte;

begin
     val:= mem[$0000:$0411];
           if val and 6=6 then
           joy:='Joystick Detected'{Check bit 6}
           else joy:='NO Joystick';
end;



function xms:boolean; {Tells if there is an extended memory manager
                       Returns true if found}

         function checkxmm:byte;assembler;asm
                  mov ax,4300h
                  int 2fh
         end;

begin
     if checkxmm=$80 then xms:=true
     else xms:=false;
end;



function emm:boolean;  {Tells if there is an expanded memory manager, EMM386
                        Returns TRUE if found (not tested with QEMM) }
var
l: byte;
e: boolean;

const
name:string[8]='EMMXXXX0'; {We have to look in memory for this string}

         function addressemm:word;assembler;asm {It returns the segment where 
                                        the memory manager resides}
                  mov ax,3567h
                  int 21h
                  mov ax,es
         end;

begin

e:=true;

        for l:=10 to 17 do begin {This is where the string starts}
            if chr(mem[addressemm:l])<>name[l-9] then e:=false; {Compare it}
        end;

emm:=e;

end;




procedure svga(var svg:string); {Checks for a VESA compliant card}
var
infoptr: pointer; {Pointer where the cards gives us its info}
infoseg: word;
s,d: word;
i : byte;
fabric: string;  {Card's manufacturer name}

Function isvesa:byte;assembler;
asm {Checks if there's a VESA compliant card
                                   and finds where to get allits info}
         mov ax,infoseg
         mov es,ax
         xor di,di
         mov ax,4f00h
         int 10h
         xchg ah,al
end;
var sss,ss:string;
begin

     getmem(infoptr,257); {Reserve memory for card's info}
     infoseg:=seg(infoptr^);

if isvesa<>0 then
   begin
     svg:='No VESA card found';
   end
   else begin
   str(mem[infoseg:5],sss);
   str(mem[infoseg:4],ss);
   svg:='VESA Found, Ver: '+sss+'.'+ss;
        d:=memw[infoseg:6];
        s:=memw[infoseg:8];
        i:=0;

        repeat
              i:=i+1;
              fabric[i]:=chr(mem[s:d+i-1]); {The manufacturer's string is in}
        until (mem[s:d+i-1]=0);             {ASCIIZ so this ends when 0 found}

   fabric[0]:=chr(i);
   svg:=svg+', '+fabric;
   end;

   freemem(infoptr,257); {Free the info area}

end;

function cdrom:boolean;{Tells if MSCDEX is loaded (and consequently if there is
                          a CD-ROM drive. Returns TRUE if found}

          function check:byte;assembler;asm
                   mov ax,1100h
                   int 2fh
          end;
begin

     if check=255 then cdrom:=true
     else cdrom:=false;

end;

Procedure _4dos(var strr:string){Tells us if 4DOS.COM is loaded and its version};

         function _4check:word;assembler;asm {This checks that is loaded}
                  mov ax,0d44dh
                  xor bh,bh
                  int 2fh
         end;

         function major:byte;assembler;asm
                  mov ax,0d44dh
                  xor bh,bh
                  int 2fh
                  mov al,bl
         end;

         function minor:byte;assembler;asm
                  mov ax,0d44dh
                  xor bh,bh
                  int 2fh
                  mov al,bh
         end;
var ss,s:string;
begin

     if _4check=$44dd then
     begin
     str(major,s);
     str(minor,ss);
        strr:='Detected Ver:'+s+'.'+ss;
     end
     else
        strr:='4DOS not present';

end;

Procedure ComputerModel(var comp:string);
VAR
  Model : BYTE ABSOLUTE $F000:$FFFE;
BEGIN
  CASE Model OF
    $9A : Comp:=( 'COMPAQ Plus' );
    $FF : Comp:=( 'IBM PC' );
    $FE : Comp:=( 'PC XT, Portable PC' );
    $FD : Comp:=( 'PCjr' );

    $FC : Comp:=( 'Personal Computer AT, PS/2 Models 50 and 60' );
    $FB : Comp:=( 'PC XT (after 1/10/86)' );
    $FA : Comp:=( 'PS/2 Model 30' );
    $F9 : Comp:=( 'Convertible PC' );
    $F8 : Comp:=( 'PS/2 Model 80' );
  End;
end;


Procedure CPUSpeed(var mhz,khz:word);

Function WhatCPU:byte;
Const
  Cpu8086  = 1;
  Cpu80286 = 2;
  Cpu80386 = 3;
  Cpu80486 = 4;

begin
Asm  { Function WhatCPU }
  MOV     DX,Cpu8086
  PUSH    SP
  POP     AX
  CMP     SP,AX
  JNE     @OUT
  MOV     DX,Cpu80286
  PUSHF
  POP     AX
  OR      AX,4000h
  PUSH    AX
  POPF
  PUSHF
  POP     AX
  TEST    AX,4000h
  JE      @OUT
  MOV     DX,Cpu80386
  DB 66h; MOV BX,SP       { MOV EBX,ESP }
  DB 66h, 83h, 0E4h, 0FCh { AND ESP,FFFC }
  DB 66h; PUSHF           { PUSHFD }
  DB 66h; POP AX          { POP EAX }
  DB 66h; MOV CX, AX      { MOV ECX,EAX }
  DB 66h, 35h, 00h
  DB 00h, 04h, 00         { XOR EAX,00040000 }
  DB 66h; PUSH AX         { PUSH EAX }
  DB 66h; POPF            { POPFD }
  DB 66h; PUSHF           { PUSHFD }
  DB 66h; POP AX          { POP EAX }
  DB 66h, 25h,00h
  DB 00h, 04h,00h         { AND EAX,00040000 }
  DB 66h, 81h,0E1h,00h
  DB 00h, 04h,00h         { AND ECX,00040000 }
  DB 66h; CMP AX,CX       { CMP EAX,ECX }
  JE @Not486
  MOV DX, Cpu80486
 @Not486:
  DB 66h; PUSH CX         { PUSH ECX }
  DB 66h; POPF            { POPFD }
  DB 66h; MOV SP, BX      { MOV ESP,EBX }
 @Out:
  MOV AX, DX
End;
end;       { Function WhatCPU }

Const
  Processor_cycles : Array [0..4] of Byte = (165, 165, 25, 103, 42);
{
  Notice that here I have defined the 8086 as a Processor type of 0 vice
  the returned value of 1 from WhatCPU.  Since the original code did not
  distinguish between the 8086 and the 80186, I can get away with this.
}
Var
  Ticks,
  Cycles,
  CPS       : LongInt;
  Which_CPU : Word;

  Function i86_to_i286 : Word; Assembler;
  Asm  { Function i86_to_i286 }
    CLI
    MOV    CX,  1234
    XOR    DX,  DX
    XOR    AX,  AX
    MOV    AL,  $B8
    OUT    $43, AL
    IN     AL,  $61
    OR     AL,  1
    OUT    $61, AL
    XOR    AL,  AL
    OUT    $42, AL
    OUT    $42, AL
    XOR    AX,  AX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IDIV   CX
    IN     AL,  $42
    MOV    AH,  AL
    IN     AL,  $42
    XCHG   AL,  AH
    NEG    AX
    STI
  End;  { Function i86_to_i286 }

  Function i386_to_i486 : Word; Assembler;
  Asm  { Function i386_to_i486 }
    CLI
    MOV    AL,  $B8
    OUT    $43, AL
    IN     AL,  $61
    OR     AL,  1
    OUT    $61, AL
    XOR    AL,  AL
    OUT    $42, AL
    OUT    $42, AL

    DB 66H,$B8,00h,00h,00h,80h;
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    DB 66H,0FH,$BC,$C8;         { BSF  ECX, EAX }
    IN     AL,  42H
    MOV    AH,  AL
    IN     AL,  42H
    XCHG   AL,  AH
    NEG    AX
    STI
  End;  { Function i386_to_486 }

Begin  { Procedure CPUSpeed }
  Which_CPU := WhatCPU;
  If Which_cpu < 3 Then
    Ticks := i86_to_i286
  Else
    Ticks := i386_to_i486;

  Cycles := 20 * Processor_cycles[Which_CPU];
  CPS := (Cycles * 119318) Div Ticks;
  MHz := CPS Div 100000;
  KHz := (CPS Mod 100000 + 500) Div 1000
End;  { Procedure CPUSpeed }


end.