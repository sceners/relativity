{$G+}
Unit Files;
{
  Files library v1.0
  by Maple Leaf, 13 Nov 1996
  -------------------------------------------------------------------------
  no comments necessary...
}

interface

uses String_s, Dos;

Const
  OwnDirectory : String   = '';
  OwnFileName  : String   = '';
  OwnPath      : String   = '';

function  OnlyFileName (path : string) : string;
{ Extract file name from a full path ('????????.???') }

function  OnlyName (path : string) : string;
{ Extract only the name from a full path ('????????') }

function  OnlyExt (path : string) : string;
{ Extract extension from the name contained in the full path ('.???') }

function  OnlyDir (path : string) : string;
{ Extract directory from the full path then add '\' at the end of string (if needs) }

function  FMatch(file1,file2 : string) : Boolean;
{ Check if files format match (ex. *.EXE match with RARA.EXE) }

function OpenForInput(var f:file; filename:string) : Boolean;
{ Open file for input . Displays ERRMSG and stops the program if any error
   is found }

function OpenForOutput(var f:file; filename:string) : Boolean;
{ Open file for output . Displays ERRMSG and stops the program if any error
   is found }

function OpenForAppend(var f:file; filename:string) : Boolean;
{ Open file for append . Displays ERRMSG and stops the program if any error
   is found }

function CloseFile(var f:file) : Boolean;
{ Close specified file. If any error is appeared, display ERRORMSG onto
   the screen and stops the program }

function EraseFile(var f:file) : Boolean;
{ Erase specified file. If any error is appeared, display ERRORMSG onto
   the screen and stops the program }

function ExistFile(path:string) : Boolean;
{ Checks whether the filename is (or is not) the name of an existing file }

procedure MakePath(path:String);
{ Create a full path }

implementation

procedure MakePath(path:String);
var s:string; k:word;
begin {$i-}
  if path[length(path)]='\' then path:=copy(path,1,length(path)-1);
  if (pos('\',path)=0) or (path[length(path)]=':') then
    MkDir(Path)
  else
    MakePath(onlydir(Path));
  MkDir(path); k:=IoResult; InOutRes:=0;
end;

function  FMatch(file1,file2 : string) : Boolean;
function  EExpand(s:string):string;
var r:string; k:byte;
begin
  r:=''; k:=0; delete(s,1,1);
  repeat
    inc(k);
    if length(s)>=k then begin
      if s[k]='*' then begin
        r:=r+Strng(3-length(r),63);
        k:=3;
      end else r:=r+s[k];
    end else begin
      r:=r+' ';
    end;
  until k=3;
  EExpand:='.'+UCase(r);
end;
function  EMatch(file1,file2 : string) : Boolean;
var q:boolean; k:byte;
begin
  file1:=EExpand(OnlyExt(file1)); file2:=EExpand(OnlyExt(file2));
  q:=true; k:=0;
  repeat
    inc(k);
    if not((file1[k]=file2[k]) or (file1[k]='?') or (file2[k]='?')) then q:=false;
  until not q or (k=4);
  EMatch:=q;
end;
function  Expand(s:string):string;
var r:string; k:byte;
begin
  r:=''; k:=0;
  repeat
    inc(k);
    if length(s)>=k then begin
      if s[k]='*' then begin
        r:=r+Strng(8-length(r),63);
        k:=8;
      end else r:=r+s[k];
    end else begin
      r:=r+' ';
    end;
  until k=8;
  Expand:=UCase(r);
end;
function  NMatch(file1,file2 : string) : Boolean;
var q:boolean; k:byte;
begin
  file1:=Expand(OnlyName(file1)); file2:=Expand(OnlyName(file2));
  q:=true; k:=0;
  repeat
    inc(k);
    if not((file1[k]=file2[k]) or (file1[k]='?') or (file2[k]='?')) then q:=false;
  until not q or (k=8);
  NMatch:=q;
end;
begin
  file1:=OnlyFileName(file1);
  file2:=OnlyFileName(file2);
  FMatch:=NMatch(file1,file2) and EMatch(file1,file2);
end;

function onlyname;
var
  d:dirstr;
  e:extstr;
  n:namestr;
begin
  fsplit(path,d,n,e);
  onlyname:=n;
end;

function onlydir;
var
  d:dirstr;
  e:extstr;
  n:namestr;
begin
  fsplit(path,d,n,e);
  if d<>'' then
    if d[length(d)]<>'\' then d:=d+'\';
  onlydir:=d;
end;

function onlyext;
var
  d:dirstr;
  e:extstr;
  n:namestr;
begin
  fsplit(path,d,n,e);
  onlyext:=e;
end;

function onlyfilename;
begin
  onlyfilename:=onlyname(path)+onlyext(path);
end;

function OpenForInput;
begin {$i-}
  if ioresult=0 then;
  inoutres:=0;
  assign(f,filename);
  filemode:=0;
  reset(f,1);
  OpenForInput:=(IOResult=0);
end;

function OpenForOutput;
begin {$i-}
  if ioresult=0 then;
  inoutres:=0;
  assign(f,filename);
  filemode:=2;
  rewrite(f,1);
  OpenForOutput:=(IOResult=0);
end;

function OpenForAppend;
begin {$i-}
  if ioresult=0 then;
  inoutres:=0;
  assign(f,filename);
  filemode:=2;
  reset(f,1);
  OpenForAppend:=(IOResult=0);
end;

function CloseFile;
begin {$i-}
  if ioresult=0 then;
  inoutres:=0;
  close(f);
  CloseFile:=(IOResult=0);
end;

function EraseFile;
begin {$i-}
  if ioresult=0 then;
  inoutres:=0;
  erase(f);
  EraseFile:=(IOResult=0);
end;

function ExistFile;
var r:SearchRec;
begin
  findfirst(path,$3F,r);
  ExistFile:=DosError=0;
end;

begin
  OwnPath:=UCase(ParamStr(0));
  OwnDirectory:=OnlyDir(OwnPath);
  OwnFileName:=OnlyFileName(OwnPath);
end.
