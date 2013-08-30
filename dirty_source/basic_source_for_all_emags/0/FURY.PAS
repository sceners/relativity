{$m 64000,0,640000}
uses furyfigh,variable,files;

begin
     if not fileexists('FURYDATA.MDB') THEN
     begin
          writeln('FURYDATA.MDB is missing..');
          halt;
     end;
     if (paramstr(1)='/V') or (paramstr(1)='/v') then voc:=false;
     if paramstr(1) = '/?' then
     begin
          writeln('Fury of The Furry Fighter Help Commands : ');
          writeln;
          writeln('þ /V disables SFX');
          writeln;
          halt;
     end;
     cheater:=false;
     fury_fighter;
end.