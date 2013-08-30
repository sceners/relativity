{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(*                                                                          *)
(* REVMEM.PAS - The Relativity E-Mag (coded in Turbo Pascal 7.0)            *)
(*                                                                          *)
(* "The Relativity E-Mag" was originally written by En|{rypt, |MuadDib|,    *)
(* and IllumiTIE (for assembly routines). This source may not be copied,    *)
(* distributed or modified in any shape or form. Some of the code has been  *)
(* derived from various sources and units to help us produce a better       *)
(* quality electronic magazine to let the scene know we're boss.            *)
(*                                                                          *)
(* Program Notes : This program presents "The Relativity E-Mag"             *)
(*                                                                          *)
(* ASM/TP70 Coder : xxxxx xxxxxxxxx (En|{rypt)  - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* TP70 Coder     : xxxxx xxxxxxxxx (|MuadDib|) - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(*  MEMORY UNIT USED WITH REV97.PAS AND ABOVE. CODED IN TURBO PASCAL 7.0.   *)
(****************************************************************************)


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Library Divides The Main Program Into Related Modules.  *)
(****************************************************************************)

unit RevMem;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - What Is Visible And Accessible To Any Program Or Unit.  *)
(****************************************************************************)

interface


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By This Single Unit.  *)
(****************************************************************************)

uses Dos;

function GetMainMemory : Longint;
procedure CheckMainMemory;
procedure CheckXMSMemory(var installed : boolean);
procedure CheckEMSMemory(var installed : boolean);
procedure CheckXMSEMSMemory;
procedure Extend_Heap;
procedure ShrinkHeapMemory;
procedure ExpandHeapMemory;
procedure FlushDiskCaches;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Procedures And Functions Declared In The Interface.     *)
(****************************************************************************)

implementation

const
  Max_Blocks = 4;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Specifies An Identifier That Denotes A Type. (values)   *)
(****************************************************************************)

TYPE
  PFreeRec = ^TFreeRec;
  TFreeRec = record
    Next : PFreeRec;
    Size : Pointer;
  end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
  XMS_Driver : Pointer;
  Num_Blocks : Word;
  Block_Address,
  Block_Size : Array[1..Max_Blocks+1] of Pointer;
  SaveExitProc : Pointer;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Specifies An Identifier That Denotes A Type. (values)   *)
(****************************************************************************)

TYPE
  MCBrec = record
    location   : Char;
    ProcessID  : WORD;
    allocation : WORD;
    reserved   : array[1..11] of BYTE;
  end;

  PSPrec = record
    int20h,
    EndofMem        : WORD;
    Reserved1       : BYTE;
    Dosdispatcher   : array[1..5] of BYTE;
    Int22h          : Pointer;
    Int23h          : Pointer;
    INT24h          : Pointer;
    ParentPSP       : WORD;
    HandleTable     : array[1..20] of BYTE;
    EnvSeg          : WORD;
    Reserved2       : Longint;
    HandleTableSize : WORD;
    HandleTableAddr : Pointer;
    Reserved3       : array[1..23] of BYTE;
    Int21           : WORD;
    RetFar          : BYTE;
    Reserved4       : array[1..9] of BYTE;
    DefFCB1         : array[1..36] of BYTE;
    DefFCB2         : array[1..20] of BYTE;
    Cmdlength       : BYTE;
    Cmdline         : array[1..127] of BYTE;
  end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
  pmcb            : ^MCBrec;
  emcb            : ^MCBrec;
  psp             : ^PSPrec;
  dmem            : Longint;
  HaveXms,HaveEms : Boolean;
  Reg             : Registers;
  UMB_Heap_Debug  : Boolean;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Checks If XMS Is Installed, Allocates Memory To Heap.   *)
(****************************************************************************)

procedure Pointer_Swap(var A,B : Pointer);
  var
    Temp : Pointer;
  begin
    Temp := A;
    A := B;
    B := Temp;
  end;

function XMS_Driver_Present : Boolean;
  var
    Result : Boolean;
  begin
    Result := False;
    asm
      @Begin:
        mov ax,4300h
        int 2Fh
        cmp al,80h
        jne @Fail
        mov ax,4310h
        int 2Fh
        mov word ptr XMS_Driver+2,es
        mov word ptr XMS_Driver,bx
        mov Result,1
        jmp @End
      @Fail:
        mov Result,0
      @End:
    end;
    XMS_Driver_Present := Result;
  end;

procedure Allocate_UMB_Heap;
  var
    i,j : Word;
    UMB_Strategy,
    DOS_Strategy,
    Segment,Size : Word;
    Get_Direct : Boolean;
  begin
    Num_Blocks := 0;

    for i := 1 to Max_Blocks do
      begin
        Block_Address[i] := nil;
        Block_Size[i] := nil;
      end;

    asm
      mov ax,5800h
      int 21h
      mov [DOS_Strategy],ax
      mov ax,5802h
      int 21h
      mov [UMB_Strategy],ax
      mov ax,5801h
      mov bx,0000h
      int 21h
      mov ax,5803h
      mov bx,0001h
      int 21h
    end;

    Get_Direct := True;

    for i := 1 to Max_Blocks do
      begin
        Segment := 0;
        Size := 0;

        if Get_Direct then
          begin
            asm
              @Begin:
                mov ax,01000h
                mov dx,0FFFFh
                push ds
                mov cx,ds
                mov es,cx
                call es:[XMS_Driver]
                cmp dx,100h
                jl @End
                mov ax,01000h
                call es:[XMS_Driver]
                cmp ax,1
                jne @End
                cmp bx,0A000h
                jl @End
                mov [Segment],bx
                mov [Size],dx
              @End:
                pop ds
            end;
            if ((i = 1) and (Size = 0)) then
              Get_Direct := False;
          end;

        if (not Get_Direct) then
          begin
            asm
              @Begin:
                mov ax,4800h
                mov bx,0FFFFh
                int 21h
                cmp bx,100h
                jl @End
                mov ax,4800h
                int 21h
                jc @End
                cmp ax,0A000h
                jl @End
                mov [Segment],ax
                mov [Size],bx
              @End:
            end;
          end;

        if (Segment > 0) then
          begin
            Block_Address[i] := Ptr(Segment,0);
            Inc(Num_Blocks);
          end;
        Block_Size[i] := Ptr(Size,0);
      end;
    if (Num_Blocks > 0) then
      begin
        for i := 1 to Num_Blocks-1 do
          for j := i+1 to Num_Blocks do
            if (Seg(Block_Address[i]^) > Seg(Block_Address[j]^)) then
              begin
                Pointer_Swap(Block_Address[i],Block_Address[j]);
                Pointer_Swap(Block_Size[i],Block_Size[j]);
              end;
      end;
    asm
      mov ax,5803h
      mov bx,[UMB_Strategy]
      int 21h
      mov ax,5801h
      mov bx,[DOS_Strategy]
      int 21h
    end;
  end;

procedure Release_UMB; far;
  var
    i : Word;
    Segment : Word;
  begin
    ExitProc := SaveExitProc;
    if (Num_Blocks > 0) then
      begin
        asm
          mov ax,5803h
          mov bx,0000h
          int 21h
        end;
        for i := 1 to Num_Blocks do
          begin
            Segment := Seg(Block_Address[i]^);
            if (Segment > 0) then
              asm
                mov ax,$4901
                mov bx,[Segment]
                mov es,bx
                int 21h
              end;
          end;
      end;
  end;

procedure Extend_Heap;
  var
    i : Word;
    Temp : PFreeRec;
  begin
    if XMS_Driver_Present then
      begin
        Allocate_UMB_Heap;
        if UMB_Heap_Debug then
          Release_UMB;
        if (Num_Blocks > 0) then
          begin
            for i := 1 to Num_Blocks do
              PFreeRec(Block_Address[i])^.Size := Block_Size[i];
            for i := 1 to Num_Blocks do
              PFreeRec(Block_Address[i])^.Next := Block_Address[i+1];

            PFreeRec(Block_Address[Num_Blocks])^.Next := nil;

            if (FreeList = HeapPtr) then
              with PFreeRec(FreeList)^ do
                begin
                  Next := Block_Address[1];
                  Size := Ptr(Seg(HeapEnd^)-Seg(HeapPtr^),0);
                end
            else
              with PFreeRec(HeapPtr)^ do
                begin
                  Next := Block_Address[1];
                  Size := Ptr(Seg(HeapEnd^)-Seg(HeapPtr^),0);
                end;

            HeapPtr := Block_Address[Num_Blocks];
            HeapEnd := Ptr(Seg(Block_Address[Num_Blocks]^)+Seg(Block_Size[Num_Blocks]^),0);
          end;
      end;
  end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Detects The Amount Of Main Memory Available. (640K)     *)
(****************************************************************************)

function GetMainMemory : Longint;
begin
  psp:=PTR(PrefixSeg,0);
  pmcb:=Ptr(PrefixSeg-1,0);
  emcb:=Ptr(psp^.envseg-1,0);
  GetMainMemory:=Longint(pmcb^.allocation+emcb^.allocation+1)*16;
end;

procedure CheckMainMemory;
begin
  Writeln('Memory Used: ',GetMainMemory,' bytes');
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Detects If Expanded And Extended Memory Are Available.  *)
(****************************************************************************)

procedure CheckXMSMemory(var installed : boolean);
begin
  reg.ax := $4300;
  intr($2F, reg);
  installed := reg.al = $80;
end;

procedure CheckEMSMemory(var installed : boolean);
begin
  reg.ah := $46;
  intr($67, reg);
  installed := reg.ah = $00;
end;

procedure CheckXMSEMSMemory;
begin
  CheckXMSMemory(HaveXms);
  CheckEMSMemory(HaveEms);
  writeln('XMS: ',HaveXms,'  EMS: ',HaveEms,'');
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Gives A Larger Heap Size Temporarily Until heap_expand. *)
(****************************************************************************)

procedure ShrinkHeapMemory;
begin
  reg.bx := memw[seg(heapptr) : ofs(heapptr) + 2] - prefixseg;
  reg.es := prefixseg;
  reg.ah := $4a;
  msdos(reg);
end;

procedure ExpandHeapMemory;
begin
  reg.bx := memw[seg(heapend) : ofs(heapend) + 2] - prefixseg;
  reg.es := prefixseg;
  reg.ah := $4a;
  msdos(reg);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Flushes Disk Caches SmartDrive 4.00+ and PC-Cache 8.0+. *)
(****************************************************************************)

procedure FlushDiskCaches;
begin
  Reg.AX:=$4A10;
  Reg.BX:=$0001;
  Intr($2F,Reg);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Unit Is Loaded.      *)
(****************************************************************************)

end.


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}


Attachment Converted: "c:\eudora\attach\rev.dat"
