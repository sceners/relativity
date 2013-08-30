{$G+}
Unit FCache;

{
   Cache work with files. (for better speed on accesing disk)
   by Maple Leaf, 1996
}

Interface

Const
  MaxCache              = 4*1024;   { 4K }
  CacheError  : byte    = 0;
  CacheEOF    : Boolean = False;

(*
  'CacheError' values:

     0  = No error
     1  = Write error/Disk full
     2  = Is End-Of-File
*)

Var
  OutBuffIndex,InBuffIndex : Word;
  MaxCacheRead             : Word;
  OBuff, IBuff             : Array [1..MaxCache] of byte;

{ Write cache }
Procedure FlushBuffer(var f:file);
Function  WriteByte(var f:file; b:byte):Boolean;
{ Read cache }
Procedure ResetBuffer;
Function  ReadByte(var f:file) : Byte;

Implementation

Procedure FlushBuffer(var f:file);
var k:word;
begin {$i-}
  CacheError:=0;
  CacheEOF:=False;
  if (OutBuffIndex>0) and (OutBuffIndex<=MaxCache) then begin
    BlockWrite(f,OBuff,OutBuffIndex,k);
    if k<>OutBuffIndex then CacheError:=1;
  end;
  OutBuffIndex:=0;
end;

Function WriteByte(var f:file; b:byte):Boolean;
begin {$i-}
  CacheError:=0;
  CacheEOF:=False;
  Inc(OutBuffIndex);
  if OutBuffIndex>MaxCache then begin
    dec(OutBuffIndex);
    FlushBuffer(f);
    OutBuffIndex:=1;
  end;
  OBuff[OutBuffIndex]:=b;
  WriteByte:=CacheError=0;
end;

Procedure ResetBuffer;
begin
  InBuffIndex:=MaxCache+1;
  MaxCacheRead:=0;
end;

Function ReadByte(var f:file):Byte;
begin {$i-}
  CacheEOF:=False;
  CacheError:=0;
  Inc(InBuffIndex);
  if InBuffIndex>MaxCacheRead then begin
    InBuffIndex:=1;
    BlockRead(f,IBuff,MaxCache,MaxCacheRead);
    if MaxCacheRead=0 then begin
      CacheEOF:=True;
      CacheError:=2;
      InBuffIndex:=0;
    end;
  end;
  ReadByte:=IBuff [ InBuffIndex ] ;
end;

begin
end.
