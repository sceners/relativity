unit revstr;
interface

Function Upstr(line:string):string;

implementation
uses crt;

Function Upstr(line:string):string;
var i:byte;
begin
     for i:= 1 to length(line) do
     begin
          line[i]:=upcase(line[i]);
     end;
     upstr:=line;
end;
end.