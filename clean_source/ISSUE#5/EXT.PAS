uses revdat,dos,crt;
var i,diz,enk:integer;
ss,s:string;
begin
     if (paramcount < 3) then
     begin
          writeln;
          write('Syntex : Extract.exe DatFile EncryptCode DizSize');
          writeln;
          halt;
     end;

     Val(ParamStr(2),enk,i );
     Val(ParamStr(3),diz, I);
{     s:='222';
     ss:='820';
     Val(s, diz,i );
     Val(ss,enk, I);}
     extractall(paramstr(1),enk,diz);
{     extractall('rev.dat',diz,enk);}
end.