{$m 64000,0,640000}
program makedat;
uses revdat,dos,revconst;
var
    h, m, s, hund : Word;
    h1, m1, s1, hund1 : Word;
begin
     makedatfileall('FX98-02.MDB',1);
end.
