uses dos,crt;
var key:byte;
begin
while key<>$01 do
if keypressed then
    begin
        key := port[$60];
        writeln(keY);
        readkey;
    end;
end.