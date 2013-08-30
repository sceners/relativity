uses dos,crt;
var key:byte;
begin
          key := port[$60];
          while  key<> $13 do
          begin
             key := port[$60];
             if keypressed then
             begin
             readkey;
             key := port[$60];
             end;
             writeln(key);
          end;
end.