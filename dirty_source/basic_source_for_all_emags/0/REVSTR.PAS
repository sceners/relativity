unit revstr;
interface

Function Upper_(st:string):string;
Procedure Upper(var st:string);

implementation
uses crt;

Procedure Upper(var st:string);
var i:byte;
begin
     for i:= 1 to length(st) do
     st[i]:=upcase(st[i]);
end;


Function Upper_(st:string):string;
var i:byte;
begin
     for i:= 1 to length(st) do
     begin
          st[i]:=upcase(St[i]);
     end;
     upper_:=st;
end;

end.