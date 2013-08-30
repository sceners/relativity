(****************************************************************************)
(*                                                                          *)
(* REVDAT.PAS - The Relativity Emag (coded in Turbo Pascal 7.0)             *)
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
(* TP70 Coder     : xxxxx xxxxxxxxx (|MuadDib|) - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* DAT FILE UNIT USED WITH REV97.PAS AND ABOVE. CODED IN TURBO PASCAL 7.0.  *)
(****************************************************************************)


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Library Divides The Main Program Into Related Modules.  *)
(****************************************************************************)

unit RevDat;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - What Is Visible And Accessible To Any Program Or Unit.  *)
(****************************************************************************)

interface

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By This Single Unit.  *)
(****************************************************************************)
uses Crt,Dos;
const maxhead = 200;
type
  HeadRec  = record
           Name     : string[12];
           seekplace : longint;
           FileSize : Longint;
  end;

  headarray = array [ 1..maxhead ] of headrec;


Procedure ReadGlobalIndex;
procedure Encrypt_header(var header:headrec; intkey:longint);
procedure Decrypt_header(var header:headrec; intkey:longint);
{procedure AddDizPas;}
function FileExists(FileName: string) : Boolean;
Procedure ClearHeaderRecord(var headarr:headarray);
procedure MakeDatFileAll;
procedure ExtractFileFromDat(name:string);
{procedure AddFileToExistingDat(name:string);}
{procedure DelFileFromExistingDat(name:string);}
procedure DeleteDatFile(filename:string);
procedure DeleteDatFilesInDir;
procedure extractall(datnam:string; enk,diz:integer);
{procedure MakeExtractDatLabel;}
{procedure IsFileOriginalDat(name:string); {in progress}


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By This Single Unit.  *)
(****************************************************************************)

implementation
uses revconst;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Defines An Identifier That Denotes A Constant Value.    *)
(****************************************************************************)

const
  DatName     = 'REVDATA.MDB';
  EXTFILE     = 'MAKEDAT.EXE';
  Max         = 10000;
  EnkDeKCode  = 777;
  DizFileSize = 1039;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Specifies An Identifier That Denotes A Type. (values)   *)
(****************************************************************************)

TYPE
  Copy     = array[1..Max] of BYTE;


var headarr : headarray;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
 Tof        : file;
 DirInfo    : SearchRec;
 Info       : string;
 S          : string;
 S1         : string;
 Count      : Longint;
 Header     : HeadRec;
 Reg        : string;
 NumRead    : WORD;
 NumWritten : WORD;

(****************************************************************************)
(* Reserved Words - Delete Any Amount Of Files From The DAT (Extraction).   *)
(****************************************************************************)

procedure DeleteDatFile(filename:string);
var DeleteFile : Text;
begin
  Assign(DeleteFile,filename);
  Rewrite(DeleteFile);
  Close(DeleteFile);
  Erase(DeleteFile);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - rest Of dat                                              )
(****************************************************************************)

function FileExists(FileName: string) : Boolean;
var
 f: file;
begin
  {$I-}
  Assign(f, FileName);
  Reset(f);
  Close(f);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

procedure InitDatFile;
begin
  Assign(Tof,DatName);
  Rewrite(Tof,1);
end;


function AskUser(FileName : string) : Boolean;
label Again,Fin;
var
  Ask : Char;
begin
  AskUser:=False;
  Write('Include File? [Y/N]: ',filename,' ');
  Again:
  Ask:=ReadKey;
  if UpCase(Ask)='Q' then
    begin
      Close(Tof);
    end;
  if UpCase(Ask)='Y' then
    AskUser:=True;
  if UpCase(Ask)='N' then
    AskUser:=False;
  if UpCase(Ask)<>'N' then
  if UpCase(Ask)<>'Y' then
    goto Again;
    Fin:
    Writeln;
end;

procedure Encrypt_Decrypt(var Buf : Copy; Key: longint);
var
  i : Longint;
begin
  for i:=1 to sizeof(buf) do
    Buf[i]:=Buf[i] XOR Key;
end;

Procedure ReadGlobalIndex;
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : copy;
   i,count,headnum,size : longint;

begin
     if fileexists(datname) then
     begin
          assign(fromf,DatName);
          Reset(Fromf,1);
          assign(index,'index');
          rewrite(index,1);

          seek(fromf,filesize(fromf)-sizeof(headnum)); {finding the num of indexes}
          BlockRead(FromF,headnum,sizeof(headnum),NumRead);

          ClearHeaderRecord(headarr);
          seek(fromf,filesize(fromf)-sizeof(headnum)-(headnum*sizeof(headarr)));
          BlockRead(fromf, Buf, SizeOf(headarr), NumRead);
          Encrypt_Decrypt(buf,EnkDekCode);
          BlockWrite(index, buf, sizeof(buf), NumWritten);
          reset(index,1);
          BlockRead(index,headarr,sizeof(headarr),NumRead);

{          for i:= 1 to headnum do
{          begin
          {need to make a room in highmem and ... take the index there}
{                BlockRead(FromF,headarr,sizeof(headarr),NumRead);
          end;}
          for i:= 1 to maxhead do
          begin
               dEcrypt_Header(headarr[i],EnkDekCode);
          end;
          close(fromf);
          rewrite(index);
          close(index);
          erase(index);
     end;
end;


procedure Encrypt_header(var header:headrec; intkey:longint);
var
  i,Code : Integer;
begin
  for i:= 1 to 12 do
begin
  Code:=Ord(Header.Name[i]);
  Code:=Code+IntKey;
  Header.Name[i]:=Chr(Code);
end;
  Header.FileSize:=Header.FileSize+IntKey;
end;

procedure Decrypt_Header(var Header : HeadRec; IntKey : Longint);
var
  i,Code : Integer;
begin
for i:= 1 to 12 do
begin
  Code:=Ord(Header.Name[i]);
  Code:=Code-IntKey;
  Header.Name[i]:=Chr(Code);
end;
  Header.FileSize:=Header.FileSize-IntKey;
end;


Procedure ClearHeaderRecord(var headarr:headarray);
var i:longint;
begin
     for i:= 1 to maxhead do
     begin
          headarr[i].name:='';
          headarr[i].filesize:=0;
          headarr[i].seekplace:=0;
     end;
end;

procedure MakeDatFileAll; {for lazy ppl}
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : copy;
   count, headnum, i : longint;

procedure AddDizPas;
var
  fromf: file;
  Buf        : Copy;
  NumRead    : WORD;
  NumWritten : WORD;
begin
  Assign(fromf,'DIZ.PAS');
  Reset(fromf,1);
  BlockRead(fromf, Buf, SizeOf(Buf), NumRead);
  BlockWrite(tof, Buf, NumRead, NumWritten);
  Close(Fromf);
end;

begin
{ i can kill the index file.. if i use himem i dont need it}
     Assign(tof,DatName);
     Rewrite(tof,1);

     AddDizPas;

     ClearHeaderRecord(headarr);
     assign(index,'index');
     rewrite(index,1);

     count:=0;
     headnum:=0;
     i:=0;
     FindFirst('*.*', Archive, DirInfo);
     while DosError = 0 do
     begin
          if (dirinfo.name<>DatName) and (dirinfo.name<>EXTFILE) then
          begin
               inc(i);
               headarr[i].name:=dirinfo.name;
               headarr[i].filesize:=dirinfo.size;
               headarr[i].seekplace:=count;

{               if i = maxhead then
               begin
                  BlockWrite(index, headarr,sizeof(headarr), NumWritten);
                  i:=1;
                  inc(headnum);
                  ClearHeaderRecord(headarr);
               end;                          }

               inc(count,dirinfo.size);

               Assign(FromF,dirinfo.name);
               Reset(FromF,1);
               repeat
                     BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
                     Encrypt_Decrypt(buf,EnkDekCode);
                     BlockWrite(ToF, Buf, NumRead, NumWritten);
               until (NumRead = 0) or (NumWritten <> NumRead);
               Close(FromF);

          end;
          FindNext(DirInfo);
     end;

     for i:= 1 to maxhead do
        Encrypt_Header(headarr[i],EnkDekCode);

     BlockWrite(index, headarr, sizeof(headarr), NumWritten);
     reset(index,1);
     BlockRead(index, Buf, SizeOf(Buf), NumRead);
     Encrypt_Decrypt(buf,EnkDekCode);
     BlockWrite(ToF, Buf, NumRead, NumWritten);

{     reset(index,1);
     repeat
           BlockRead(index, headarr, SizeOf(headarr), NumRead);

     until (NumRead = 0) or (NumWritten <> NumRead);}

     headnum:=1;
     BlockWrite(ToF, headnum, sizeof(headnum), NumWritten);

close(tof);
rewrite(index);
close(index);
erase(index);
writeln('DatFile was made with arj/zip/rar/muaddib like headers');
end;


procedure ExtractFileFromDat(name:string);
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : copy;
   i,count,headnum,size : longint;

begin
{need to read the globalindex first !!
}
     assign(fromf,DatName);
     Reset(Fromf,1);

   for i:=1 to maxhead do
   begin
        if headarr[i].name='' then
        break;
        if headarr[i].name=name then
        begin
             assign(tof,name);
             Rewrite(tof,1);

             seek(fromf,headarr[i].seekplace+dizfilesize);
             size:=headarr[i].filesize;
             while (size<>0) do
             begin
                  if size<max then
                  begin
                       BlockRead(FromF, Buf,size, NumRead);
                       Encrypt_Decrypt(buf,EnkDekCode);
                       BlockWrite(ToF, Buf, NumRead, NumWritten);
                       dec(size,numread);
                  end
                  else
                  begin
                       BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
                       Encrypt_Decrypt(buf,EnkDekCode);
                       BlockWrite(ToF, Buf, NumRead, NumWritten);
                       dec(size,numread);
                  end;
             end;
             close(tof);
             close(fromf);
             break;
        end;
   end;

end;

procedure extractall(datnam:string; enk,diz:integer);
var
    i:integer;
    index,fromf:file;
    NumRead, NumWritten: Word;
    headnum:longint;
    buf :copy;

begin

     assign(fromf,DatName);
     Reset(Fromf,1);

     seek(fromf,filesize(fromf)-sizeof(headnum)); {finding the num of indexes}
     BlockRead(FromF,headnum,sizeof(headnum),NumRead);

     assign(index,'index');
     Rewrite(index,1);
     seek(fromf,filesize(fromf)-sizeof(headnum)-(headnum*sizeof(headarr)));

     for i:= 1 to headnum do
     begin
          {need to make a room in highmem and ... take the index there}
          BlockRead(FromF,headarr,sizeof(headarr),NumRead);
     end;

     for i:= 1 to maxhead do
     begin
          if headarr[i].name='' then
          break;
          if headarr[i].name<>'' then
          begin
             assign(tof,headarr[i].name);
             Rewrite(tof,1);

             seek(fromf,headarr[i].seekplace);
             while (header.filesize<>0) do
             begin
                  if header.filesize<max then
                  begin
                       BlockRead(FromF, Buf,header.filesize, NumRead);
                       Encrypt_Decrypt(buf,EnkDekCode);
                       BlockWrite(ToF, Buf, NumRead, NumWritten);
                  end
                  else
                  begin
                       BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
                       Encrypt_Decrypt(buf,EnkDekCode);
                       BlockWrite(ToF, Buf, NumRead, NumWritten);
                       dec(header.filesize,SizeOf(Buf));
                  end;
             end;
             close(tof);
          end;
     end;


end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Unit Is Loaded.      *)
(****************************************************************************)


Procedure DeleteDatFilesInDir;
var i,j:byte;
begin
     for i:= 1 to maxhead do
     begin
          if fileexists(headarr[i].name) then
               deletedatfile(headarr[i].name);
     end;
end;
end.


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}