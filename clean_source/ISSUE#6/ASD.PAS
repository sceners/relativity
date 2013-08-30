{$m 64000,0,640000}
uses revdisc,revdat,revconst,dos;
begin
     bar:=true;
     ReadGlobalIndex;
     getmem(article,$ffff);
     if disclaimer2('DISC.BIN') then write('yes');
end.