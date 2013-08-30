program dirconv;
uses dos;
var
 DirInfo: SearchRec;
 s6:string[6];

Procedure inside;
var DirInf : SearchRec;
    name : string[12];
    strnum : string;
    num : integer;
    f : file;
begin
 num:=0;
 chdir(dirinfo.name);
 FindFirst('*.bin', archive, DirInf);
 while DosError = 0 do
 begin
   str(num,strnum);
   if (num>-1) and (num<10) then
   strnum:='0'+strnum;
   name:=s6+strnum+'.bin';
   assign(f,dirinf.name);
   rename(f,name);
   FindNext(DirInf);
 end;
 chdir('..')
end;


begin
 FindFirst('*.', directory, DirInfo);
 while DosError = 0 do
 begin
    s6:=dirinfo.name;

    inside;

    FindNext(DirInfo);
 end;
end.
