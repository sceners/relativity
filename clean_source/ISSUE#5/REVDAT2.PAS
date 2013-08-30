{$m$f000,0,65000}
program block; {Dat file format-Emags / MuadDib}
uses crt,dos;
const max=50000;
      header_size=17;
      EnkDeKCode=123;
      DizFileSize=820;
type
    copy=ARRAY[1..max] OF BYTE;
    headrec = record
           name:string[12]; {this is the header}
           filesize:longint;
           end;
var  tof:file;
     DirInfo: SearchRec;
     info,s,s1:string;
     count:longint;
     header:headrec;
     reg:string;
     NumRead, NumWritten: Word;

function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

Procedure InitDatFile;
begin
assign(tof,'rev.DAT');
Rewrite(ToF,1);
end;

procedure AddDizPas;
var fromf:file;
    buf :copy;
    NumRead, NumWritten: Word;
begin
assign(fromf,'DIZ.PAS');
Reset(Fromf,1);
BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
BlockWrite(ToF, Buf, NumRead, NumWritten);
close(fromf);
end;


function askuser(filename:string):boolean;
label again,fin;
var
   ask:char;
begin
askuser:=false;
write('this file ? ',filename,' ');
again:
ask:=readkey;
if upcase(ask)='Q' then
begin
close(tof);
end;
if upcase(ask)='Y' then
askuser:=true;
if upcase(ask)='N' then
askuser:=false;
if upcase(ask)<>'N' then
   if upcase(ask)<>'Y' then
   goto again;
   fin:
writeln;
end;

Procedure Encrypt_Decrypt(Var buf:copy; Key: Byte);
var i:longint;
begin
for i:=1 to max do
     buf[i]:=buf[i] xor key;
end;

procedure Encrypt_header(var header:headrec; intkey:longint);
var i,code:integer;
begin
for i:= 1 to 12 do {enc name}
begin
     code:=ord(header.name[i]);
     code:=code+intkey;
     header.name[i]:=chr(code);
end;
header.filesize:=header.filesize+intkey;
end;

procedure Decrypt_header(var header:headrec; intkey:longint);
var i,code:integer;
begin
for i:= 1 to 12 do {enc name}
begin
     code:=ord(header.name[i]);
     code:=code-intkey;
     header.name[i]:=chr(code);
end;
header.filesize:=header.filesize-intkey;
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

procedure MakeExtractDatLabel;
var
    i:integer;
    fromf:file;
    line:string;
    NumRead, NumWritten: Word;
    buf :copy;
    ok:boolean;
    ext:text;
    label again,fin;
begin
assign(ext,'Ext.ini');
Rewrite(ext);
assign(fromf,'rev.DAT');
Reset(Fromf,1);
ok:=false;
BlockRead(FromF,buf,DizFileSize,NumRead);
again:
if not eof(fromf) then
begin
BlockRead(FromF,header,header_size, NumRead);
Decrypt_header(header,EnkDekCode);
line:='ExtractFileFromDat('''+header.name+''');';
writeln(ext,line);
while (header.filesize<>0) and (ok<>true) do {wanted full-left data}
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
close(fromf);
close(ext);
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



begin {main}
ExtractFileFromDat('GAME1.PAS');
ExtractFileFromDat('GAME2.PAS');
ExtractFileFromDat('INTER1.PAS');
ExtractFileFromDat('INTER2.PAS');
textcolor(white);
clrscr;
{DelFileFromExistingDat('DAT_HEAD.PAS');
{AddFileToExistingDat('MEMORY.TPU');}
{InitDatFile;
{AddDizPas;
MakeDatFile; {inter active}
{MakeDatFileAll;{ all the things in the directory}
{ExtractFileFromDat('ENK.PAS'); {to extract file names ...uppper case !!!!!!}
MakeExtractDatLabel; {help prepare ... for all the files the ExtractFileFromDat..}
end.                 {these commands are in ext.ini}

{to make dat file use these :>
InitDatFile;
AddDizPas;
MakeDatFile;
MakeDatFileAll;
to extract only this :>
ExtractFileFromDat('TRY.PAS');}