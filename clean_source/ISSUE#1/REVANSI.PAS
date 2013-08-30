(****************************************************************************)
(*                                                                          *)
(* REVGFX.PAS - The Relativity Emag (coded in Turbo Pascal 7.0)             *)
(*                                                                          *)
(* "The Relativity Emag" was originally written by En|{rypt, |MuadDib|,     *)
(* and IllumiTIE (for assembly routines). This source may not be copied,    *)
(* distributed or modified in any shape or form. Some of the code has been  *)
(* derived from various sources and units to help us produce a better       *)
(* quality electronic magazine to let the scene know we're boss.            *)
(*                                                                          *)
(* Program Notes : This program presents "The Relativity Emag"              *)
(*                                                                          *)
(* ASM/TP70 Coder : xxxxx xxxxxxxxx (En|{rypt)  - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* TP70 Coder     : xxxxx xxxxxxxxx (|MuadDib|) - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* ANSI UNIT USED WITH REV97.PAS AND ABOVE. CODED IN TURBO PASCAL 7.0.      *)
(****************************************************************************)
{$M $F000,0,655360}
{$S 32768}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)

unit revansi; {My Mega Ansi Read Thingi .. !!!}
interface
uses  Crt,Dos,RevDat,revsmoot;

Procedure ReadAnsiPasAndLoadToMem(str:string; var lengthmem,width,lengt:integer);
procedure ReadAnsiBinAndLoadToMem(str:string; var lengthmem:longint);
procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
Procedure DisplayAnsi(STR:string);

{the bin file has got to stay under 64k... aka max}

implementation
const max=32768;
type st80=string[80];
     a32=array[1..max] of char;
     {Ansi Array Size Cant Be More Than max although mem max is 32k...}
     {So Break IT to half if u need....}
var f:text;
    lines:integer;
    line:st80;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Displays An 8bit 256-Color GIF Image On The Screen.     *)
(****************************************************************************)

procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
begin
  inline (
    $1E/$C5/$B6/ADDR1/$C4/$BE/ADDR2/$8B/$8E/BLKLEN/$E3/$5B/$8B/$D7/$33/$C0/
    $FC/$AC/$3C/$20/$72/$05/$AB/$E2/$F8/$EB/$4C/$3C/$10/$73/$07/$80/$E4/$F0/
    $0A/$E0/$EB/$F1/$3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/$02/$C0/$02/$C0/
    $02/$C0/$80/$E4/$8F/$0A/$E0/$EB/$DA/$81/$C2/$A0/$00/$8B/$FA/$EB/$D2/$3C/
    $1B/$72/$07/$75/$CC/$80/$F4/$80/$EB/$C7/$3C/$19/$8B/$D9/$AC/$8A/$C8/$B0/
    $20/$74/$02/$AC/$4B/$32/$ED/$41/$F3/$AB/$8B/$CB/$49/$E0/$AA/$1F);
end;

Procedure DisplayAnsi(STR:string);
var dep:longint;
begin
  ExtractFileFromDat(str);
  ReadAnsiBinAndLoadToMem(str,dep);
  DeleteDatFile(str);
end;

procedure linesinfile;
begin
reset(f);
lines:=0;
         while not eof(f) do
         begin
              readln(f,line);
              lines:=lines+1;
         end;
end;

Procedure Searchline(line1:st80; var pos1,pos2:integer; c1,c2:char);
var i:integer;
begin
     for i:= 1 to length(line) do
     begin
          if line[i]=c1 then
          pos1:=i;
          if line[i]=c2 then
          pos2:=i;
     end;
end;

Procedure Num2str(num:integer; str1:string; var char:char);
var tmp:integer;
begin
     val(str1,num,tmp);
     str(num,str1);
     char:=chr(num);
end;

{Procedure Cmp2;
var i:integer;
    notg:boolean;
begin
notg:=true;
for i:= 1 to 4000 do
if a[i]<>sub5acd[i] then
notg:=false;
end;}

procedure ReadAnsiPasAndLoadToMem(str:string; var lengthmem,width,lengt:integer);
var
    a:a32;
    ai:longint;
    pos1,pos2:integer;
    i,tmp,num:integer;
    str4:string;
    char1:char;
begin
ai:=1;
assign(f,str);
linesinfile;
reset(f);
readln(f,line);readln(f,line); {junk lines}
readln(f,line); {const}
readln(f,line);searchline(line,pos1,pos2,'=',';');delete(line,1,pos1+1);
               searchline(line,pos1,pos2,'=',';');delete(line,pos2,1); {width}
               val(line,width,pos1);
readln(f,line);searchline(line,pos1,pos2,'=',';');delete(line,1,pos1+1);
               searchline(line,pos1,pos2,'=',';');delete(line,pos2,1);  {length}
               val(line,lengt,pos1);
readln(f,line);searchline(line,pos1,pos2,'.',']');delete(line,1,pos1);
               searchline(line,pos1,pos2,'.',']');delete(line,pos2,length(line));
               val(line,lengthmem,pos1);
for i:= 1 to lines-7 do
begin
     readln(f,line);
     a[ai]:=line[6];inc(ai);
     str4:=line[10]+line[11]+line[12];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
     a[ai]:=line[15];inc(ai);
     str4:=line[19]+line[20]+line[21];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
     a[ai]:=line[24];inc(ai);
     str4:=line[28]+line[29]+line[30];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
     a[ai]:=line[33];inc(ai);
     str4:=line[37]+line[38]+line[39];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
     a[ai]:=line[42];inc(ai);
     str4:=line[46]+line[47]+line[48];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
     a[ai]:=line[51];inc(ai);
     str4:=line[55]+line[56]+line[57];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
     a[ai]:=line[60];inc(ai);
     str4:=line[64]+line[65]+line[66];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
readln(f,line);
if length(line)>=14 then
begin
     a[ai]:=line[6];inc(ai);
     str4:=line[10]+line[11]+line[12];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
if length(line)>=23 then
begin
     a[ai]:=line[15];inc(ai);
     str4:=line[19]+line[20]+line[21];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
if length(line)>=32 then
begin
     a[ai]:=line[24];inc(ai);
     str4:=line[28]+line[29]+line[30];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
if length(line)>=41 then
begin
     a[ai]:=line[33];inc(ai);
     str4:=line[37]+line[38]+line[39];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
if length(line)>=50 then
begin
     a[ai]:=line[42];inc(ai);
     str4:=line[46]+line[47]+line[48];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
if length(line)>=59 then
begin
     a[ai]:=line[51];inc(ai);
     str4:=line[55]+line[56]+line[57];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
if length(line)>=68 then
begin
     a[ai]:=line[60];inc(ai);
     str4:=line[64]+line[65]+line[66];
     num2str(num,str4,char1);
     a[ai]:=char1;inc(ai);
end;
Move(a,Mem[$B800:0],lengthmem);
close(f);
end;

procedure ReadAnsiBinAndLoadToMem(str:string; var lengthmem:longint);
var
    a:a32;
    numread:word;
    f:file;
begin
     lengthmem:=0;
     assign(f,str);
     reset(f,1);
{     repeat}
          BlockRead(F,a, SizeOf(a), NumRead);
          lengthmem:=lengthmem+numread;
{     until (NumRead = 0);}
close(f);
Move(a,Mem[$B800:0],lengthmem);
end;
end.
end.
