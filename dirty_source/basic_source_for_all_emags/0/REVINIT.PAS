unit revinit;

interface
uses  revconst,revrad;

Function InitPointers:boolean;
Procedure KillPointers;
procedure InitMouse;
procedure initPrinter;
Procedure InitBright;
Procedure InitAvail;
Procedure InitMusic;
Procedure InitKey(speed:byte);
Procedure InitRadVol;
Procedure InitTag;
Procedure InitFonts;
Procedure InitCd;
Procedure InitUpper;

Procedure InitPtrArt;
Procedure DeInitPtrArt;

Procedure InitPtrArtArk;
Procedure DeInitPtrArtArk;
implementation
uses revfnt,revtech,revdat,cdrom,revmouse,dos,revprint,crt,revstr;

Procedure InitUpper;
var i,j:byte;
begin
     for i:=1 to 19 do
         for j:=1 to 18 do
         begin
              if config^.subfile[i][j]<>'' then
                 config^.subfile[i][j]:=upper_(config^.subfile[i][j]);
         end;
end;

Procedure InitPtrArt;
begin
     getmem(article_main,k64);
     getmem(article,k64);
     if voc then getmem(vocp,k32);
end;

Procedure DeInitPtrArt;
begin
     freemem(article_main,k64);
     freemem(article,k64);
     if voc then freemem(vocp,k32);
end;

Procedure InitPtrArtArk;
begin
     getmem(article_main,k64);
end;

Procedure DeInitPtrArtArk;
begin
     freemem(article_main,k64);
end;


Function InitPointers:boolean;
begin
     initpointers:=true;
     if memavail>used_size then
     begin
          getmem(PassM,k4);
          getmem(mainm,k4);
          getmem(subm,k4);
          getmem(helpm,k4);
          getmem(tempbin,k4);
          getmem(boomm,k4);
          getmem(fontp,k8);
          getmem(cfg_ptr,cfg_size);
          if voc then getmem(vocp,k32);
          if adlib then getmem(music,k32);
          getmem(article,k64);
          getmem(article_main,k64);
          mem_being_used:=true;
     end
     else
     begin
          initpointers:=false;
          mem_being_used:=false;
     end;
end;

Procedure KillPointers;
begin
     if mem_being_used then
     begin
          freemem(PassM,k4);
          freemem(mainm,k4);
          freemem(subm,k4);
          freemem(helpm,k4);
          freemem(boomm,k4);
          freemem(tempbin,k4);
          freemem(fontp,k8);
          freemem(cfg_ptr,cfg_size);
          if voc then freemem(vocp,k32);
          if adlib then freemem(music,k32);
          freemem(article,k64);
          freemem(article_main,k64);
     end;
end;


Procedure InitPointer(p:pointer);
begin
     if memavail>max then
        getmem(p,max);
end;

Procedure KillPointer(p:pointer);
begin
     if memavail>max  then freemem(p,max);
end;


procedure initPrinter;
begin
     if printeronline then
        printer:=true
     else
        printer:=false;
end;

procedure InitMouse;
begin
     if mouse then
     begin
          SetMouseCursor(True);
          showmouse;
       end;
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
begin
    GetPal(i,palette[i,1],palette[i,2],palette[i,3]);
    GetPal(i,old_palette[i,1],old_palette[i,2],old_palette[i,3]);
end;
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
end;

Procedure InitRadVol;
begin
     config^.radvol:=62;
     if adlib then
     begin
          radvolume(config^.radvol);
     end
     else
         config^.radvol:=52;
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
config^.notavhelp:=[saveastag];
end;

Procedure InitMusic;
var i:byte;
begin
dsmmuson:=true;
radmuson:=false;
config^.RADlastmus:=21;
config^.RADcurmus:=config^.radmusdef;
config^.DSMlastmus:=38;
config^.DSMcurmus:=config^.dsmmusdef;
i:=1;
config^.music[i,1]:='RASTER';config^.music[i,2]:='RAD';config^.music[i,3]:='Reality/Void';inc(i);
config^.music[i,1]:='CRYSTAL2';config^.music[i,2]:='RAD';config^.music[i,3]:='Neo SoftWare';inc(i);
config^.music[i,1]:='HANGOVER';config^.music[i,2]:='RAD';config^.music[i,3]:='Reality/Void';inc(i);
config^.music[i,1]:='HUBBARD';config^.music[i,2]:='RAD'; config^.music[i,3]:='Neo SoftWare';inc(i);
config^.music[i,1]:='NEOINTRO';config^.music[i,2]:='RAD';config^.music[i,3]:='Neo SoftWare';inc(i);
config^.music[i,1]:='ALLOYRUN';config^.music[i,2]:='RAD';config^.music[i,3]:='Reality/Void';inc(i);
config^.music[i,1]:='SMJOOP';config^.music[i,2]:='RAD';config^.music[i,3]:='Neo SoftWare';inc(i);
config^.music[i,1]:='TERRANIA';config^.music[i,2]:='RAD';config^.music[i,3]:='Reality/Void';inc(i);
config^.music[i,1]:='DESTINY';config^.music[i,2]:='RAD';config^.music[i,3]:='Reality/Void';inc(i);
config^.music[i,1]:='JAZZPOP';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='ZM2';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE1';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE2';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE4';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE5';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE6';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE7';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE8';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE9';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='TUNE10';config^.music[i,2]:='RAD';config^.music[i,3]:='';inc(i);
config^.music[i,1]:='SPN_CH01';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #1';inc(i);
config^.music[i,1]:='SPN_CH02';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #2';inc(i);
config^.music[i,1]:='SPN_CH03';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #3';inc(i);
config^.music[i,1]:='SPN_CH04';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #4';inc(i);
config^.music[i,1]:='SPN_CH05';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #5';inc(i);
config^.music[i,1]:='SPN_CH06';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #6';inc(i);
config^.music[i,1]:='SPN_CH07';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #7';inc(i);
config^.music[i,1]:='SPN_CH08';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #8';inc(i);
config^.music[i,1]:='SPN_CH09';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #9';inc(i);
config^.music[i,1]:='SPN_CH10';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #10';inc(i);
config^.music[i,1]:='SPN_CH11';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #11';inc(i);
config^.music[i,1]:='SPN_CH12';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #12';inc(i);
config^.music[i,1]:='SPN_CH13';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #13';inc(i);
config^.music[i,1]:='SPN_CH14';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #14';inc(i);
config^.music[i,1]:='SPN_CH15';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #15';inc(i);
config^.music[i,1]:='SPN_CH16';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #16';inc(i);
config^.music[i,1]:='SPN_CH17';config^.music[i,2]:='DSM';config^.music[i,3]:='SPOON #17';inc(i);
end;

end.