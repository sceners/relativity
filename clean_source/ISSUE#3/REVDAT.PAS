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



procedure InitDatFile;
procedure AddDizPas;
procedure MakeDatFileAll;
procedure MakeDatFile;
procedure ExtractFileFromDat(name:string);
procedure AddFileToExistingDat(name:string);
procedure DelFileFromExistingDat(name:string);
procedure DeleteDatFile(filename:string);

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By This Single Unit.  *)
(****************************************************************************)

implementation

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Defines An Identifier That Denotes A Constant Value.    *)
(****************************************************************************)

const
  Max         = 30000;
  Header_Size = 17;
  EnkDeKCode  = 222;
  DizFileSize = 820;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Specifies An Identifier That Denotes A Type. (values)   *)
(****************************************************************************)

TYPE
  Copy     = array[1..Max] of BYTE;
  HeadRec  = record
  Name     : string[12];
  FileSize : Longint;
end;


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
  FileMode := 0;
  Reset(f);
  Close(f);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

procedure InitDatFile;
begin
  Assign(Tof,'rev.DAT');
  Rewrite(Tof,1);
end;

procedure AddDizPas;
var
  Fromf      : file;
  Buf        : Copy;
  NumRead    : WORD;
  NumWritten : WORD;
begin
  Assign(Fromf,'DIZ.PAS');
  Reset(Fromf,1);
  BlockRead(Fromf, Buf, SizeOf(Buf), NumRead);
  BlockWrite(Tof, Buf, NumRead, NumWritten);
  Close(Fromf);
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

procedure Encrypt_Decrypt(var Buf : Copy; Key: BYTE);
var
  i : Longint;
begin
  for i:=1 to Max do
    Buf[i]:=Buf[i] XOR Key;
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

procedure MakeDatFileAll; {for lazy ppl}
var
   fromf:file;
   NumRead, NumWritten: Word;
   buf :copy;
begin
 count:=0;
 FindFirst('*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
 if (dirinfo.name<>'REV.DAT') and (dirinfo.name<>'REV.INI') then {big safety !!}
 begin
      {file header}
        header.name:=dirinfo.name;
        header.filesize:=dirinfo.size;
        Encrypt_Header(header,EnkDekCode);
        BlockWrite(ToF, header,header_size, NumWritten); {if one uses diff header..}
        Assign(FromF,dirinfo.name);
        Reset(FromF,1);
          repeat
             BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
          until (NumRead = 0) or (NumWritten <> NumRead);
        {end of updates}
        Close(FromF);
        count:=count+dirinfo.size;
   end;
   FindNext(DirInfo);
 end;
close(tof);
writeln('rev.dat was made with arj/zip/rar/muaddib like headers');
end;

procedure MakeDatFile;
var
   fromf:file;
   NumRead, NumWritten: Word;
   buf :copy;
begin
count:=0;
 FindFirst('*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
 if (dirinfo.name<>'REV.DAT') and (dirinfo.name<>'REV.INI') then {big safety !!}
 begin
   if (askuser(dirinfo.name)) and (doserror=0) then
      begin
      {file header}
        header.name:=dirinfo.name;
        header.filesize:=dirinfo.size;
        Encrypt_Header(header,EnkDekCode);
        BlockWrite(ToF, header,header_size, NumWritten); {if one uses diff header..}
        Assign(FromF,dirinfo.name);
        Reset(FromF,1);
          repeat
             BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
          until (NumRead = 0) or (NumWritten <> NumRead);
        {end of updates}
        Close(FromF);
        count:=count+dirinfo.size;
      end;
   end;
   FindNext(DirInfo);
 end;
close(tof);
writeln('rev.dat was made with arj/zip/rar/muaddib like headers');
end;

procedure ExtractFileFromDat(name:string);
var
    i:integer;
    fromf:file;
    NumRead, NumWritten: Word;
    buf :copy;
    ok:boolean;
    label again,fin;
begin
assign(fromf,'rev.DAT');
Reset(Fromf,1);
ok:=false;
BlockRead(FromF,buf,DizFileSize,NumRead);
again:
BlockRead(FromF,header,header_size, NumRead);
Decrypt_Header(header,EnkDekCode);
   if header.name=name then
   begin
        assign(tof,name);
        Rewrite(tof,1);
{ the good data ------------------------------------------------}
        while (header.filesize<>0) and (ok<>true) do {wanted full-left data}
        begin
             if header.filesize<max then
             begin
             BlockRead(FromF, Buf,header.filesize, NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             ok:=true;
             end
             else
             begin
             BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             header.filesize:=header.filesize-SizeOf(Buf);
             end;
        end;
        close(tof);
        close(fromf);
        goto fin;
   end
   else
   begin
{ the waste data ----------------------------------------------}
        while (header.filesize<>0) and (ok<>true) do {lose unwanted data}
        begin
             if header.filesize<max then
             begin
             BlockRead(FromF, Buf,header.filesize, NumRead);
             ok:=true;
             end
             else
             begin
             BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
             header.filesize:=header.filesize-SizeOf(Buf);
             end;
        end;
        ok:=false;
        goto again;
   end;
fin:
end;

Procedure AddFileToExistingDat(name:string);{also replaces older existing file in dat}
var
    fromf,f:file;
    buf :copy;
    written,ok:boolean;
    fsize:longint;
    label again,fin;
begin
written:=false;
if fileExists(name) then
begin
assign(tof,'rev.$$$');
rewrite(tof,1);
assign(fromf,'rev.dat');
reset(fromf,1);
BlockRead(FromF,buf,DizFileSize,NumRead);
BlockWrite(toF,buf,numread,numwritten);
again:
if not eof(fromf) then
begin
BlockRead(FromF,header,header_size, NumRead); {header}
Decrypt_Header(header,EnkDekCode);
   if header.name=name then
   begin
   {ask to replace ??}
        written:=true;
        FindFirst(name, Archive, DirInfo);
        header.name:=dirinfo.name;
        header.filesize:=dirinfo.size;
        fsize:=dirinfo.size;
        Encrypt_Header(header,EnkDekCode);
        BlockWrite(ToF, header,header_size, NumWritten); {if one uses diff header..}
        assign(f,name);
        Reset(f,1);
        while (fsize<>0) and (ok<>true) do {wanted full-left data}
        begin
             if fsize<max then
             begin
             BlockRead(Fromf, Buf,fsize, NumRead); {waste data}
             BlockRead(F, Buf,fsize, NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             ok:=true;
             end
             else
             begin
             BlockRead(Fromf, Buf,fsize, NumRead); {waste data}
             BlockRead(F, Buf,SizeOf(Buf), NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             fsize:=fsize-SizeOf(Buf);
             end;
        end;
        close(f);
        OK:=False;
        goto again;
   end
   else
   begin
        fsize:=header.filesize;
        Encrypt_Header(header,EnkDekCode);
        BlockWrite(ToF, header,header_size, NumWritten);
        while (fsize<>0) and (ok<>true) do {lose unwanted data}
        begin
             if fsize<max then
             begin
             BlockRead(FromF, Buf,fsize, NumRead);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             ok:=true;
             end
             else
             begin
             BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             fsize:=fsize-SizeOf(Buf);
             end;
        end;
        ok:=false;
        goto again;
   end;
fin:
end;
end
else writeln('file not exists');

if written=false then {new file}
begin
        FindFirst(name, Archive, DirInfo);
        header.name:=dirinfo.name;
        header.filesize:=dirinfo.size;
        fsize:=dirinfo.size;
        Encrypt_Header(header,EnkDekCode);
        BlockWrite(ToF, header,header_size, NumWritten); {if one uses diff header..}
        assign(f,name);
        ReSET(f,1);
        while (fsize<>0) and (ok<>true) do {wanted full-left data}
        begin
             if fsize<max then
             begin
             BlockRead(FromF, Buf,fsize, NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             ok:=true;
             end
             else
             begin
             BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
             Encrypt_Decrypt(buf,EnkDekCode);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             fsize:=fsize-SizeOf(Buf);
             end;
        end;
        close(f);
end;
close(fromf);
close(tof);
erase(fromf);
rename(tof,'rev.dat');
end;

Procedure DelFileFromExistingDat(name:string);
var
    fromf,f:file;
    buf :copy;
    deleted,ok:boolean;
    fsize:longint;
    label again,fin;
begin
deleted:=false;
assign(tof,'rev.$$$');
rewrite(tof,1);
assign(fromf,'rev.dat');
reset(fromf,1);
BlockRead(FromF,buf,DizFileSize,NumRead);
BlockWrite(toF,buf,numread,numwritten);
again:
if not eof(fromf) then
begin
BlockRead(FromF,header,header_size, NumRead); {header}
Decrypt_Header(header,EnkDekCode);
   if header.name=name then
   begin
        deleted:=true;
        while (fsize<>0) and (ok<>true) do
        begin
             fsize:=header.filesize;
             if fsize<max then
             begin
             BlockRead(Fromf, Buf,fsize, NumRead); {waste data}
             ok:=true;
             end
             else
             begin
             BlockRead(Fromf, Buf,fsize, NumRead); {waste data}
             fsize:=fsize-SizeOf(Buf);
             end;
        end;
        OK:=False;
        goto again;
   end
   else
   begin
        fsize:=header.filesize;
        Encrypt_Header(header,EnkDekCode);
        BlockWrite(ToF, header,header_size, NumWritten);
        while (fsize<>0) and (ok<>true) do {lose unwanted data}
        begin
             if fsize<max then
             begin
             BlockRead(FromF, Buf,fsize, NumRead);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             ok:=true;
             end
             else
             begin
             BlockRead(FromF, Buf,SizeOf(Buf), NumRead);
             BlockWrite(ToF, Buf, NumRead, NumWritten);
             fsize:=fsize-SizeOf(Buf);
             end;
        end;
        ok:=false;
        goto again;
   end;
fin:
end;
if deleted=false then write('file was not in dat');
close(fromf);
close(tof);
erase(fromf);
rename(tof,'rev.dat');
end;

procedure IsFileOriginalDat(name:string); {in progress}
var
    fromf,f:file;
    buf :copy;
begin
assign(fromf,'rev.dat');
reset(fromf,1);
BlockRead(FromF,buf,DizFileSize,NumRead);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Unit Is Loaded.      *)
(****************************************************************************)

end.


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}