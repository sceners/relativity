unit revinit;

interface
uses  revconst,revrad;

Procedure initcommand;
Procedure InitBright;
Procedure InitAvail;
Procedure InitMusic;
Procedure InitKey(speed:byte);
Procedure InitRadVol;
Procedure InitTag;
Procedure InitFonts;
Procedure InitCd;

implementation
uses revfnt,revtech,revdat,cdrom;

Procedure initcommand;
begin
cd:=true;
adlib:=true;
vga:=true;
end;

Procedure Initcd;
begin
cdactpos:=3;
cdsongpos:=1;
cdroms:=getNumberOfCDs(startcd);
curcddrv:=startcd;
playing:=false;
pause:=false;
locked:=false;
if cdroms=0 then
   cd:=false
else
begin
     cd:=true;
     resetCD(curcddrv);
     stopCD(curcddrv);
     playing:=false;
     getAllTrackDetails(curcddrv);
end;
{     getCDDetails(curcddrv,tad);}
end;

Procedure InitBright;
var i:integer;
begin
brgt:=1;
for i:= 0 to 15 do
GetPal(i,config^.scr[i,1],config^.scr[i,2],config^.scr[i,3]);
end;

Procedure InitFonts;
begin
config^.lastfnt:=17;
config^.curfnt:=12;
config^.font[1]:='BIGSERIF';
config^.font[2]:='BLCKSNSF';
config^.font[3]:='BLOCK';
config^.font[4]:='BROADWAY';
config^.font[5]:='COMPUTER';
config^.font[6]:='FRESNO';
config^.font[7]:='FUTURE';
config^.font[8]:='HOLLOW';
config^.font[9]:='HUGE';
config^.font[10]:='HYLAS';
config^.font[11]:='MODERN';
config^.font[12]:='SCRIBBLE';
config^.font[13]:='ROMAN';
config^.font[14]:='SANSERIF';
config^.font[15]:='SCRIPT2';
config^.font[16]:='STRETCH';
config^.font[17]:='REAL';
end;

Procedure InitTag; {also not available init}
var i,j,k:integer;
begin
     for i:= 1 to 19 do
     begin
     config^.tag[i]:=[];
     config^.notavarr[i]:=[];
     end;
     config^.notavarr[19]:=[14,15];
     config^.notavarr[1]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[2]:=[10,11,12,13,14,15,16,17];
     config^.notavarr[3]:=[14,15,16,17];
     config^.notavarr[5]:=[13,14,15,16,17];
     config^.notavarr[6]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[7]:=[10,11,12,13,14,15,16,17];
     config^.notavarr[8]:=[6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[9]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[13]:=[5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[10]:=[17];
     config^.notavarr[12]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[17]:=[5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[16]:=[2,4,9,10,11,12,16,17];
end;

Procedure InitRadVol;
begin
     config^.vol:=62;
     if adlib then
     begin
          radvolume(config^.vol);
     end
     else
     config^.vol:=52;
end;


Procedure InitKey(speed:byte);
begin
Port[$60]:=$F3;
Port[$60]:=speed;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Init Sub Files                                          *)
(****************************************************************************)

Procedure InitAvail;
begin
config^.notavhelp:=[2];
end;

Procedure InitMusic;
begin
config^.muson:=true;
config^.lastmus:=21;
config^.curmus:=musdef;
config^.music[1,1]:='RASTER';config^.music[1,2]:='RAD';config^.music[1,3]:='Reality/Void';
config^.music[2,1]:='CRYSTAL2';config^.music[2,2]:='RAD';config^.music[2,3]:='Neo SoftWare';
config^.music[3,1]:='HANGOVER';config^.music[3,2]:='RAD';config^.music[3,3]:='Reality/Void';
config^.music[4,1]:='HUBBARD';config^.music[4,2]:='RAD'; config^.music[4,3]:='Neo SoftWare';
config^.music[5,1]:='NEOINTRO';config^.music[5,2]:='RAD';config^.music[5,3]:='Neo SoftWare';
config^.music[6,1]:='ALLOYRUN';config^.music[6,2]:='RAD';config^.music[6,3]:='Reality/Void';
config^.music[7,1]:='SMJOOP';config^.music[7,2]:='RAD';config^.music[7,3]:='Neo SoftWare';
config^.music[8,1]:='TERRANIA';config^.music[8,2]:='RAD';config^.music[8,3]:='Reality/Void';
config^.music[9,1]:='DESTINY';config^.music[9,2]:='RAD';config^.music[9,3]:='Reality/Void';
config^.music[10,1]:='JAZZPOP';config^.music[10,2]:='RAD';config^.music[10,3]:='';
config^.music[11,1]:='ZM2';config^.music[11,2]:='RAD';config^.music[11,3]:='';
config^.music[12,1]:='TUNE';config^.music[12,2]:='RAD';config^.music[12,3]:='';
config^.music[13,1]:='TUNE1';config^.music[13,2]:='RAD';config^.music[13,3]:='';
config^.music[14,1]:='TUNE2';config^.music[14,2]:='RAD';config^.music[14,3]:='';
config^.music[15,1]:='TUNE4';config^.music[15,2]:='RAD';config^.music[15,3]:='';
config^.music[16,1]:='TUNE5';config^.music[16,2]:='RAD';config^.music[16,3]:='';
config^.music[17,1]:='TUNE6';config^.music[17,2]:='RAD';config^.music[17,3]:='';
config^.music[18,1]:='TUNE7';config^.music[18,2]:='RAD';config^.music[18,3]:='';
config^.music[19,1]:='TUNE8';config^.music[19,2]:='RAD';config^.music[19,3]:='';
config^.music[20,1]:='TUNE9';config^.music[20,2]:='RAD';config^.music[20,3]:='';
config^.music[21,1]:='TUNE10';config^.music[21,2]:='RAD';config^.music[21,3]:='';
end;

end.