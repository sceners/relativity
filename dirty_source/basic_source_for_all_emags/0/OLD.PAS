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
uses Crt,Dos,revconst,revtech;
const maxhead = 200;
type
  indexRec  = record
           Name     : string[12];
           seekplace : longint;
           FileSize : Longint;
  end;
  indextype= array [ 1..maxhead ] of indexrec;

const
      sigs : array[1..files] of ar19 =
      ('REV FX FILE VER.'+fx_ver+' ','REV MDB FILE VER.'+mdb_ver);
      reason : array[1..files] of ar19 =
      ('FX FILE VER.'+fx_ver+' ','MDB FILE VER.'+mdb_ver);
var
      flags :array [1..files] of boolean;

Procedure Assign_names;
procedure CheckForDat_;
Procedure ReadGlobal_Index(ix:byte);
Function ReadGlobalIndex(ix:byte):byte;
procedure Encrypt_header(var id:indexrec; intkey:longint);
procedure Decrypt_header(var id:indexrec; intkey:longint);
{procedure AddDizPas;}
Procedure ClearHeaderRecord(var id:indextype);
{procedure MakeDatFileAll(ix:byte);}
procedure MakeDatFileAll(name1:string; ix:byte);
Function ExtractPointerFromDat(name:string; ix:byte; var buf:pointer;var retsize:word):boolean;
Function ExtractFileFromDat(name:string; ix:byte):boolean;
procedure ExtractPointerFrom_Dat(name:string; ix:byte; var buf:pointer;var retsize:word);
procedure ExtractFileFrom_Dat(name:string; ix:byte);
{procedure AddFileToExistingDat(name:string);}
{procedure DelFileFromExistingDat(name:string);}
procedure DeleteDatFile(filename:string);
procedure DeleteDatFilesInDir(ix:byte);
procedure extractall(datname:string; ix:byte;  enk,diz:integer);
{procedure MakeExtractDatLabel;}
{procedure IsFileOriginalDat(name:string); {in progress}
Function fileindat(name:string; ix:byte):boolean;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By This Single Unit.  *)
(****************************************************************************)

implementation
uses revmenu,revstr;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Defines An Identifier That Denotes A Constant Value.    *)
(****************************************************************************)

const
  Dat1Name     = fx+'.MDB';
  Dat2Name     = articles+'.MDB';
  EXTFILE     = 'MAKEDAT.EXE';
  Max         = 10000;
  EnkDeKCode  = 909;
  DizFileSize = 1039;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Specifies An Identifier That Denotes A Type. (values)   *)
(****************************************************************************)

TYPE
  datbuf= array[1..Max] of BYTE;
  idx = record
      name : st12;
      max : word;
      indx : indextype;
  end;
var index_: array[1..files] of idx;

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
 Header     : indexRec;
 Reg        : string;
 NumRead    : WORD;
 NumWritten : WORD;

(****************************************************************************)
(* Reserved Words - Delete Any Amount Of Files From The DAT (Extraction).   *)
(****************************************************************************)

procedure CheckForDat_; {not used}
var
 DirInfo: SearchRec;
 i,revsize:byte;

begin
     revsize:=0;
     for i:= 1 to 2 do
     begin

{     if fileexists(index_[i].name) then}
     begin
{          findfirst(index_[i].name,Archive, DirInfo);}
          if revsize <> 0 then
          begin
               if dirinfo.size<> revsize then
               begin
                    writeln;
{                    writeln('Relativity Emag''s ',index_[i].name,' Dat File Size is Wrong');}
                    writeln('Get Full Release From Http://relativity-emag.home.ml.org');
                    writeln;
                    halt;
               end;
          end;
     end
{     else}
{     begin
          writeln;
          writeln('Relativity Emag''s ',index_[i].name,' Dat File is Missing');
          writeln('Get Full Release From Http://relativity-emag.home.ml.org');
          writeln;
          halt;
     end;}

     end;
end;


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

procedure InitDatFile(datname:String);
begin
  if pos('.',datname)=0 then datname:=datname+'.MDB';
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

procedure Encrypt_Decrypt(var Buf : datbuf; Key: longint);
var
  i : Longint;
begin
  for i:=1 to sizeof(buf) do
    Buf[i]:=Buf[i] XOR Key;
end;

procedure Encrypt_Decrypt_pointer(var Buf : pointer; Key: longint; size:word);
var
  i : Longint;
  b: byte;
begin
  for i:=0 to size-1 do
  begin
       mem[seg(Buf^):ofs(buf^)+i]:=mem[seg(Buf^):ofs(buf^)+i] xor key;
  end;
end;

Function fileindat(name:string; ix:byte):boolean;
var i:integer;
begin
     fileindat:=false;
     for i:= 1 to index_[ix].max do
     begin
          if index_[ix].indx[i].name = name then fileindat:=true;
     end;
end;

Procedure ReadGlobal_Index(ix:byte);
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : datbuf;
   i,count,headnum,size : longint;
   datname:string;
   sig :ar19;

begin
     upper(datname);
     datname:=index_[ix].name;
     if fileexists(datname) then
     begin
          assign(fromf,DatName);
          Reset(Fromf,1);
          assign(index,'index');
          rewrite(index,1);

          seek(fromf,dizfilesize);
          blockread(fromf,sig,sizeof(sigs[ix]),numread);

          if sig <> sigs[ix] then
             kill_emag(ix);

          seek(fromf,filesize(fromf)-sizeof(headnum)); {finding the num of indexes}
          BlockRead(FromF,headnum,sizeof(headnum),NumRead);

          ClearHeaderRecord(index_[ix].indx);
          seek(fromf,filesize(fromf)-sizeof(headnum)-(sizeof(index_[ix])));
          BlockRead(fromf, Buf, SizeOf(index_[ix]), NumRead);
          Encrypt_Decrypt(buf,EnkDekCode);
          BlockWrite(index, buf, sizeof(buf), NumWritten);
          reset(index,1);
          BlockRead(index,index_[ix].indx,sizeof(index_[ix].indx),NumRead);

          for i:= 1 to index_[ix].max do
          begin
               dEcrypt_Header(index_[ix].indx[i],EnkDekCode);
          end;
          close(fromf);
          rewrite(index);
          close(index);
          erase(index);

     end;
end;

Function ReadGlobalIndex(ix:byte):byte;
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : datbuf;
   i,count,headnum,size : longint;
   datname:string;
   sig :ar19;

begin
     readglobalindex:=0;
     datname:=index_[ix].name;
     upper(datname);
     if fileexists(datname) then
     begin
          assign(fromf,DatName);
          Reset(Fromf,1);
          assign(index,'index');
          rewrite(index,1);

          seek(fromf,dizfilesize);
          blockread(fromf,sig,sizeof(sigs[ix]),numread);

          if sig <> sigs[ix] then
          begin
               readglobalindex:=ix;
               exit;
          end;

          seek(fromf,filesize(fromf)-sizeof(headnum)); {finding the num of indexes}
          BlockRead(FromF,headnum,sizeof(headnum),NumRead);
          ClearHeaderRecord(index_[ix].indx);
          seek(fromf,filesize(fromf)-sizeof(headnum)-(sizeof(index_[ix])));
          BlockRead(fromf, Buf, SizeOf(index_[ix]), NumRead);
          Encrypt_Decrypt(buf,EnkDekCode);
          BlockWrite(index, buf, sizeof(buf), NumWritten);
          reset(index,1);
          BlockRead(index,index_[ix].indx,sizeof(index_[ix].indx),NumRead);

          for i:= 1 to index_[ix].max do
          begin
               dEcrypt_Header(index_[ix].indx[i],EnkDekCode);
          end;
          close(fromf);
          rewrite(index);
          close(index);
          erase(index);
          flags[ix]:=true;
     end
     else
     begin
          flags[ix]:=false;
          readglobalindex:=ix+2; {file missing}
          exit;
     end;
end;


procedure Encrypt_header(var id:indexrec; intkey:longint);
var
  i,Code : Integer;
begin
  for i:= 1 to 12 do
  begin
       Code:=Ord(id.Name[i]);
       Code:=Code+IntKey;
       id.Name[i]:=Chr(Code);
  end;
  id.FileSize:=id.FileSize+IntKey;
end;

procedure Decrypt_Header(var id:indexrec; IntKey : Longint);
var
  i,Code : Integer;
begin
for i:= 1 to 12 do
begin
  Code:=Ord(id.Name[i]);
  Code:=Code-IntKey;
  id.Name[i]:=Chr(Code);
end;
  id.FileSize:= id.FileSize-IntKey;
end;


Procedure ClearHeaderRecord(var id:indextype);
var i:longint;
begin
     for i:= 1 to maxhead do
     begin
          id[i].name:='';
          id[i].filesize:=0;
          id[i].seekplace:=0;
     end;
end;

procedure MakeDatFileAll(name1:string; ix:byte);
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : datbuf;
   count, headnum, i : longint;
   datname:string;

procedure AddDizPas(ix:byte);
var
  fromf: file;
  Buf        : datbuf;
  NumRead    : WORD;
  NumWritten : WORD;
  sig: ar19;
begin
  Assign(fromf,'DIZ.PAS');
  Reset(fromf,1);
  BlockRead(fromf, Buf, SizeOf(Buf), NumRead);
  BlockWrite(tof, Buf, NumRead, NumWritten);
  fillchar(sig,0,19);
  sig := sigs[ix];
  BlockWrite(tof, sig, sizeof(sig), NumWritten);
  Close(Fromf);
end;

begin
{     datname:=index_[ix].name;}
      datname:=name1;
     Assign(tof,DatName);
     Rewrite(tof,1);

     AddDizPas(ix);

     ClearHeaderRecord(index_[ix].indx);
     assign(index,'index');
     rewrite(index,1);

     count:=0;
     headnum:=0;
     index_[ix].max:=0;
     i:=0;
     FindFirst('*.*', Archive, DirInfo);
     while DosError = 0 do
     begin
          if (dirinfo.name<>DatName) and (dirinfo.name<>EXTFILE) then
          begin
               inc(i);
               inc(index_[ix].max);
               index_[ix].indx[i].name:=dirinfo.name;
               index_[ix].indx[i].filesize:=dirinfo.size;
               index_[ix].indx[i].seekplace:=count;
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
        Encrypt_Header(index_[ix].indx[i],EnkDekCode);

     BlockWrite(index, index_[ix], sizeof(index_[ix]), NumWritten);
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


Function ExtractFileFromDat(name:string; ix:byte):boolean;
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : datbuf;
   i,count,headnum,size : longint;
   datname:string;

begin
{need to read the globalindex first !!}
 if fileindat(name,ix) then
 begin
   if not flags[ix] then
   begin
        extractfilefromdat:=false;
        exit;
   end;
   upper(name);
   extractfilefromdat:=false;
   datname:=index_[ix].name;
   assign(fromf,DatName);
   Reset(Fromf,1);

   for i:=1 to index_[ix].max do
   begin
        if index_[ix].indx[i].name=name then
        begin
             extractfilefromdat:=true;
             assign(tof,name);
             Rewrite(tof,1);
             seek(fromf,index_[ix].indx[i].seekplace+dizfilesize+sizeof(sigs[ix]));
             size:=index_[ix].indx[i].filesize;
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
             break;
        end;
   end;
   close(fromf);
 end;
end;


Procedure ExtractFileFrom_Dat(name:string; ix:byte);
var
   index,fromf : file;
   NumRead, NumWritten : Word;
   buf : datbuf;
   i,count,headnum,size : longint;
   datname:string;

begin
{need to read the globalindex first !!}
 if fileindat(name,ix) then
 begin
   upper(name);
   datname:=index_[ix].name;
   assign(fromf,DatName);
   Reset(Fromf,1);

   for i:=1 to   index_[ix].max do
   begin
        if index_[ix].indx[i].name=name then
        begin
             assign(tof,name);
             Rewrite(tof,1);

             seek(fromf,index_[ix].indx[i].seekplace+dizfilesize+sizeof(sigs[ix]));
             size:=index_[ix].indx[i].filesize;
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
             break;
        end;
   end;
   close(fromf);
 end;
end;


Function ExtractPointerFromDat(name:string; ix:byte; var buf:pointer;var retsize:word):boolean;
var fromf:file;
    i:integer;
    buff: array[1..8192] of byte;
    datname:string;

begin
if fileindat(name,ix) then
begin
   if not flags[ix] then
   begin
        extractpointerfromdat:=false;
        exit;
   end;
   upper(name);
   extractpointerfromdat:=false;
   datname:=index_[ix].name;
   assign(fromf,DatName);
   Reset(Fromf,1);
   for i:=1 to index_[ix].max do
   begin
        if index_[ix].indx[i].name=name then
        begin
             extractpointerfromdat:=true;
             retsize:=index_[ix].indx[i].filesize;
             seek(fromf,index_[ix].indx[i].seekplace+dizfilesize+sizeof(sigs[ix]));
             BlockRead(FromF, buf^,retsize, NumRead);
{             move32fast(buff,mem[seg(buf^):ofs(buf^)],retsize);}
             Encrypt_Decrypt_pointer(buf,EnkDekCode,retsize);
             break;
        end;
   end;
close(fromf);
end;
end;

Procedure ExtractPointerFrom_Dat(name:string; ix:byte; var buf:pointer;var retsize:word);
var fromf:file;
    i:integer;
    buff: array[1..8192] of byte;
    datname:string;

begin
if fileindat(name,ix) then
begin
   datname:=index_[ix].name;
   upper(name);
   assign(fromf,DatName);
   Reset(Fromf,1);
   for i:=1 to index_[ix].max do
   begin
        if index_[ix].indx[i].name=name then
        begin
             retsize:=index_[ix].indx[i].filesize;
             seek(fromf,index_[ix].indx[i].seekplace+dizfilesize+sizeof(sigs[ix]));
             BlockRead(FromF, buf^,retsize, NumRead);
{             move32fast(buff,mem[seg(buf^):ofs(buf^)],retsize);}
             Encrypt_Decrypt_pointer(buf,EnkDekCode,retsize);
             break;
        end;
   end;
close(fromf);
end;
end;



procedure extractall(datname:string; ix:byte; enk,diz:integer);
var
    i:integer;
    index,fromf:file;
    NumRead, NumWritten: Word;
    headnum:longint;
    buf :datbuf;

begin
     if pos('.',datname)=0 then datname:=datname+'.MDB';
     assign(fromf,DatName);
     Reset(Fromf,1);

     seek(fromf,filesize(fromf)-sizeof(headnum)); {finding the num of indexes}
     BlockRead(FromF,headnum,sizeof(headnum),NumRead);

     assign(index,'index');
     Rewrite(index,1);
     seek(fromf,filesize(fromf)-sizeof(headnum)-(headnum*sizeof(index_[ix].indx)));

     for i:= 1 to headnum do
     begin
          {need to make a room in highmem and ... take the index there}
          BlockRead(FromF,index_[ix].indx,sizeof(index_[ix].indx),NumRead);
     end;

     for i:= 1 to index_[ix].max do
     begin
          if index_[ix].indx[i].name='' then
          break;
          if index_[ix].indx[i].name<>'' then
          begin
             assign(tof,index_[ix].indx[i].name);
             Rewrite(tof,1);

             seek(fromf,index_[ix].indx[i].seekplace+dizfilesize+sizeof(sigs[ix]));
             while (header.filesize<>0) do
             begin
                  if header.filesize<=max then
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


Procedure DeleteDatFilesInDir(ix:byte);
var i,j:byte;
begin
     for i:= 1 to  index_[ix].max do
     begin
          if fileexists(index_[ix].indx[i].name) then
             deletedatfile(index_[ix].indx[i].name);
     end;
end;

Procedure Assign_names;
var i,j:byte;
begin
{  names[1]:=dat1name;
  names[2]:=dat2name;
  index_[1].name:=dat1name;
  index_[2].name:=dat2name;}
  if not beta then
  begin
     j:=1;
     for i:= 1 to paramcount do
     begin
          if pos('.MDB',upper_(paramstr(i)))>0 then
          begin
               if j<= files then
               begin
                    index_[j].name:=upper_(paramstr(i));
                    names[j]:=index_[j].name;
                    inc(j);
               end;
          end;
     end;
{     writeln('!1',names[1],'!',index_[1].name);
     writeln('!2',names[2],'!',index_[2].name);
     delay(3000);                              }
  end
  else
  begin
     index_[1].name:=dat1name;
     index_[2].name:=dat2name;
     names[1]:=index_[1].name;
     names[2]:=index_[2].name;
  end;
  flags[1]:=false;
  flags[2]:=false;
end;

begin
end.


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}