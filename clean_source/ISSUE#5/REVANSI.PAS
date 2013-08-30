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
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)

unit revansi; {My Mega Ansi Read Thingi .. !!!}
interface
uses  Crt,Dos,RevDat,revconst;

procedure ReadAnsiBinAndLoadToMem(str:string; var lengthmem:longint);
procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
Procedure DisplayAnsi(STR:string);

{the bin file has got to stay under 64k... aka max}

implementation
const max=125;
type st80=string[80];
     a32=array[1..max] of char;
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
{  ExtractFileFromDat(str);}
  ReadAnsiBinAndLoadToMem(str,dep);
{  DeleteDatFile(str);}
end;

procedure ReadAnsiBinAndLoadToMem(str:string; var lengthmem:longint);
var
    a:a32;
    num,numread:word;
    f:file;
    i:integer;
begin
     lengthmem:=0;
     assign(f,str);
     reset(f,1);
     num:=0;
     for i:= 1 to 32 do
     begin
     BlockRead(F,a, SizeOf(a) , NumRead);
     Move(a,Mem[$B800:num],numread);
     num:=numread+num;
     end;
     close(f);
     Move(a,Mem[$B800:0],lengthmem);
end;
end.
end.
