var
t,t1:text;
line,l:string[80];
i,j:byte;
begin
     assign(t,'™.pro');
     assign(t1,'a');
     reset(t);
     rewrite(t1);

     while not eof(t) do
     begin
          readln(t,line);
          for i:= length(line) downto 1 do
          begin
               l:=l+line[i];
          end;
          writeln(t1,l);
          line:='';
          l:='';
     end;

     close(t);
     close(t1);
end.
