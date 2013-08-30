
Program LZSSDemo;
{ Copyright (c) 1994 by Andrew Eigus   Fidonet: 2:5100/33 }
{ Demonstrates the use of LZSSUnit (LZSSUNIT.PAS), Public Domain }

uses LZSSUnit;

var InFile, OutFile : file;

Function ToUpper(S : string) : string; assembler;
Asm
  PUSH DS
  CLD
  LDS SI,S
  LES DI,@Result
  LODSB
  STOSB
  XOR AH,AH
  XCHG AX,CX
  JCXZ @@3
@@1:
  LODSB
  CMP AL,'a'
  JB  @@2
  CMP AL,'z'
  JA  @@2
  SUB AL,20h
@@2:
  STOSB
  LOOP @@1
@@3:
  POP DS
End; { ToUpper }

Function ReadProc(var ReadBuf; var NumRead : word) : word; far;
Begin
  BlockRead(InFile, ReadBuf, LZRWBufSize, NumRead);
  Write(#13, FilePos(InFile), ' -> ')
End; { ReadProc }

Function WriteProc(var WriteBuf; Count : word; var NumWritten : word) : word;
far;Begin
  BlockWrite(OutFile, WriteBuf, Count, NumWritten);
  Write(FilePos(OutFile), #13)
End; { WriteProc }

Begin
  if not LZInit then
  begin
    WriteLn('Not enough memory');
    Halt(8)
  end;
  Assign(InFile, '0054.pas');
  Reset(InFile, 1);
  if IOResult = 0 then
  begin
    Assign(OutFile, 'AS');
    Rewrite(OutFile, 1);
    if IOResult = 0 then
    begin
      if ToUpper(ParamStr(3)) =  'UNSQUASH' then
        LZUnSquash(ReadProc, WriteProc)
      else
        LZSquash(ReadProc, WriteProc);
      Close(OutFile)
    end else WriteLn('Cannot create output file');
    Close(InFile)
  end else WriteLn('Cannot open input file');
  LZDone;
  WriteLn
End.
