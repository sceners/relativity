program lines;
uses dos
{tell u which line is greater than x chars};
const Len = 76;
var t,t1:text;
    line,name:String;
    pos:word;
    DirInfo: SearchRec;         { For Windows, use TSearchRec }
begin                          { For Windows, use faArchive }
 assign(t1,'ouput.dir');
 rewrite(t1);
 FindFirst('*.TXT', Archive, DirInfo); { Same as DIR *.PAS }
 while DosError = 0 do
 begin
     name:=DirInfo.Name;
     assign(t,name);
     reset(t);
     writeln(t1,'FILE : ',DirInfo.Name);
     pos:=0;
     while not eof(t) do
     begin
          inc(pos);
          readln(t,line);
          if length(line)>len then
          begin
             writeln(t1,'Line #',pos);
          end;
     end;
     close(t);
     findnext(dirinfo);
 end;
 close(t1)
end.