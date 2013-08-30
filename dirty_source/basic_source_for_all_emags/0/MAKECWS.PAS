{$m 64000,0,640000}
program makedat;
uses revdat,dos;
var
    h, m, s, hund : Word;
    h1, m1, s1, hund1 : Word;
begin
     makedatfileall('CWS98-02.MDB',2);
end.
