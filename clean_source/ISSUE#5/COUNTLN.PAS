Program pas_Files_lines_counter;
uses crt,dos;


Procedure Countlines(name:string; var lines:longint);
var f:text;
    line:string;
begin
     assign(f,name);
     reset(f);
     lines:=0;
     while not eof(f) do
     begin
          readln(f,line);
          inc(lines);
     end;
     close(f);
end;

var
 DirInfo: SearchRec;
 lines,glolines:longint;

begin
glolines:=0;
 FindFirst('*.PAS', Archive, DirInfo);
 while DosError = 0 do
 begin
   Countlines(dirinfo.name,lines);
   glolines:=glolines+lines;
   FindNext(DirInfo);
 end;
 write(glolines);
end.



