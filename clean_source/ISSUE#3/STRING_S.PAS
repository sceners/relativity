{$G+}
Unit String_s;
{
  Strings library v1.1
  by Maple Leaf, 1996
  -------------------------------------------------------------------------
  no comments ...
}

interface

Function IStr (n : LongInt)  : String;   { int->string }
Function RStr (n : Real)     : String;   { real->string }
Function IVal (s : String)   : LongInt;  { string->int }
Function RVal (s : String)   : Real;     { string->real }
{ Fast conversions }

Function Dec2Hex (n:longint) : String;   { int->hex(string) }
Function Hex2Dec (s:string)  : LongInt;  { hex(string)->int }
Function Dec2Bin (n:longint) : String;   { int->bin(string) }
Function Bin2Dec (s:string)  : LongInt;  { bin(string)->int }
{ basis conversions }

function  UCase (txt : string) : string;
{ Returns the same text processing letters between 'a' and 'z' to 'A'..'Z' }

function  DCase (txt : string) : string;
{ Complementary function of UCASE.Transform letters between 'A'-'Z' to 'a'-'z' }

function  LTrim(s : String) : string;
function  RTrim(s : String) : string;
function  AllTrim(s : String) : string;
{ Functions which provide initial/final/intermediar Space-characters deletion }

function DCaseButFirst (txt : string) : string;
{ Like DCASE, except the first letter which is gonna be a big one }

function  RightPos (str1,str2 : string) : byte;
{ Returns position of string STR1 in the string STR2, searching from the
   right to the left position of the string }

function  PosOfStr (str1,str2 : string; initpos:byte) : byte;
{ Returns the position of STR1 into STR2, starting search with INITPOS position }

function  Space (n : byte) : string;
{ Returns a string of #32 , with length = n }

function  Strng (n:byte; c:byte): string;
{ Returns a string which contains n characters with ASCII code C }

implementation

const HexDigit : string = '0123456789ABCDEF';
      BinDigit : string = '01';

Function Dec2Hex (n:longint) : String;   { int->hex(string) }
var s:string; nr:byte;
begin
  s:=''; nr:=0;
  repeat
    s:=HexDigit[1+(n and $F)] + s;
    n:=n shr 4; inc(nr);
  until (n=0) or (n=$FFFFFFFF) or (nr>=8);
  Dec2Hex:=s;
end;

Function Hex2Dec (s:string)  : LongInt;  { hex(string)->int }
var n:longint; nr:byte;
begin
  if s='' then begin
    Hex2Dec:=0;
    exit
  end;
  while (s[1]='0') and (s[0]>#1) do delete(s,1,1);
  s:=UCase(s);
  n:=0; nr:=0;
  repeat
    inc(nr);
    n:=(n shl 4) + longint((pos(s[nr],HexDigit) - 1));
  until (nr>=8) or (nr>=length(s));
  Hex2Dec:=n;
end;

Function Dec2Bin (n:longint) : String;   { int->bin(string) }
var s:string; nr:byte;
begin
  s:=''; nr:=0;
  repeat
    s:=BinDigit[1+(n and 1)] + s;
    n:=n shr 1; inc(nr);
  until (n=0) or (n=$FFFFFFFF) or (nr>=32);
  Dec2Bin:=s;
end;

Function Bin2Dec (s:string)  : LongInt;  { bin(string)->int }
var n:longint; nr:byte;
begin
  if s='' then begin
    Bin2Dec:=0;
    exit
  end;
  while (s[1]='0') and (s[0]>#1) do delete(s,1,1);
  n:=0; nr:=0;
  repeat
    inc(nr);
    n:=(n shl 1) + (pos(s[nr],BinDigit) - 1);
  until (nr>=32) or (nr>=length(s));
  Bin2Dec:=n;
end;

Function IStr(n:LongInt) : String;
var qs:string[20];
begin
  str(n,qs); istr:=qs;
end;

Function IVal(s:String) : LongInt;
var n:longint; c:integer;
begin
  val(s,n,c); if c<>0 then n:=0;
  ival:=n;
end;

Function RStr(n:real) : String;
var qs:string[20];
begin
  str(n:10:4,qs); rstr:=qs;
end;

Function RVal(s:String) : real;
var n:longint; c:integer;
begin
  val(s,n,c); if c<>0 then n:=0;
  rval:=n;
end;

function  LTrim(s : String) : string;
begin
  while (s[1]=' ') and (length(s)>0) do delete(s,1,1);
  LTrim:=s;
end;

function  RTrim(s : String) : string;
begin
  while (s[Length(s)]=' ') and (length(s)>0) do delete(s,Length(s),1);
  RTrim:=s;
end;

function  AllTrim(s : String) : string;
var k:byte;
begin
  k:=1;
  while k<=length(s) do begin
    if s[k]=#32 then delete(s,k,1) else inc(k);
  end;
  AllTrim:=s;
end;

function ucase;
var n:byte;
begin
  if txt<>'' then for n:=1 to length(txt) do txt[n]:=upcase(txt[n]);
  ucase:=txt;
end;

function dcase;
var n:byte;
begin
  if txt<>'' then
    for n:=1 to length(txt) do
      if txt[n] in ['A'..'Z'] then txt[n]:=chr(ord(txt[n])+32);
  dcase:=txt;
end;

function dcasebutfirst;
var n:byte;
begin
  if txt<>'' then
    for n:=1 to length(txt) do
      if txt[n] in ['A'..'Z'] then txt[n]:=chr(ord(txt[n])+32);
  n:=1;
  while not(txt[n] in ['a'..'z']) and (n<=length(txt)) do inc(n);
  txt[n]:=upcase(txt[n]);
  dcasebutfirst:=txt;
end;


function rightpos;
var n,p:byte;
label _1;
begin
  p:=0;
  for n:=length(str2) downto 1 do
    if pos(str1,copy(str2,n,length(str2)-n+1))<>0 then begin
      p:=n-1+pos(str1,copy(str2,n,length(str2)-n+1));
      goto _1;
    end;
_1:
  rightpos:=p;
end;

function PosOfStr;
var p:byte;
begin
  p:=initpos-1+pos(str1,copy(str2,initpos,length(str2)-initpos+1));
  if p=initpos-1 then p:=0;
  PosOfStr:=p;
end;

function space;
var s:string;
begin
  s:='';
  while length(s)<n do s:=s+' ';
  space:=s;
end;

function strng;
var s:string;
begin
  s:='';
  while length(s)<n do s:=s+chr(c);
  strng:=s;
end;

begin
end.
