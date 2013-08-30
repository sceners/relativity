{$M 16384,0,65560}
uses cdrom,crt;
var cdroms,curcddrv:word;
    tad:TAudiodiskRec;
    s:string;

begin
clrscr;
     curcddrv:=3;
     gotoxy(22,4);
     write(chr(curcddrv+64));
end.