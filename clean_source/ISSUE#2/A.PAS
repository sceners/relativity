PROGRAM A;
uses revgif;
begin
if paramcount=1 then
displaygif(paramstr(1))
else
write('gif.exe gifname.gif');
end.
