program lines;
{tell u which line is greater than x chars}
const Len = 76;
var t,t1:text;
    line,name:String;
    pos:word;

begin
     if paramcount <1 then
     begin
          writeln('syntax : lines file.txt');
          halt;
     end;
     name:=paramstr(1);
{     name:='racism.txt';}
     assign(t,name);
     assign(t1,'ouput.txt');
     reset(t);
     rewrite(t1);
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
     close(t1);
end.