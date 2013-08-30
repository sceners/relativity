program makedat;
uses dat,dos;
var
    h, m, s, hund : Word;
    h1, m1, s1, hund1 : Word;
begin
     GetTime(h,m,s,hund);
EXTRACTFILEFROMDAT('INTRO2.GIF');
    GetTime(h1,m1,s1,hund1);
     write('Time : ',h,':',m,':',s,':',hund);
          write('Time : ',h1,':',m1,':',s1,':',hund1);
{     InitDatFile;
     AddDizPas;
     makedatfileall;
 }

end.
