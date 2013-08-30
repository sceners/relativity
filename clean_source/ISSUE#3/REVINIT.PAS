unit revinit;

interface
uses  revconst,revrad;

Procedure GetSubTopics(var sub:subscr; var subf:sub; name:string);
Procedure initcommand;
Procedure InitBright;
Procedure InitAvail;
Procedure InitMusic;
Procedure InitSubScreen;
Procedure InitKey(speed:byte);
Procedure InitRadVol;
Procedure InitTag;
Procedure InitFonts;
Procedure Initcdpos;

implementation
uses revfnt,revtech,revdat{,cd_vars},cdunit_p,cdpla1;

Procedure initcommand;
begin
cd:=true;
adlib:=true;
vga:=true;
end;

Procedure Initcdpos;
begin
cdactpos:=1;
cdsongpos:=1;
setup;
pause:=false;
end;

Procedure InitBright;
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
fontload(config^.font[config^.curfnt]);
end;

Procedure InitTag;
var i:integer;
begin
     for i:= 1 to 19 do
     begin
          config^.tag[i]:=[];
     end;
end;

Procedure InitRadVol;
begin
     config^.vol:=62;
     if adlib then
     begin
          radvolume(config^.vol);
          volu:=true;
     end;
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
config^.notavhelp:=[3];
config^.notavarr[19]:=[10,12,14,15];
config^.notavarr[1]:=[];
config^.notavarr[2]:=[];
config^.notavarr[3]:=[];
config^.notavarr[4]:=[];
config^.notavarr[5]:=[];
config^.notavarr[6]:=[];
config^.notavarr[7]:=[];
config^.notavarr[8]:=[];
config^.notavarr[9]:=[];
config^.notavarr[10]:=[];
config^.notavarr[11]:=[];
config^.notavarr[12]:=[];
config^.notavarr[13]:=[];
config^.notavarr[14]:=[];
config^.notavarr[15]:=[];
config^.notavarr[16]:=[];
config^.notavarr[17]:=[];
config^.notavarr[18]:=[];
end;

Procedure InitMusic;
begin
config^.muson:=true;
config^.lastmus:=9;
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
{config^.music[9,1]:='INTRO';config.music[9,2]:='HSC';config.music[9,3]:='Reality/Void';
config^.music[10,1]:='1';config.music[10,2]:='HSC';config.music[10,3]:='Neo SoftWare';
config^.music[11,1]:='ZM2';config.music[11,2]:='HSC';config.music[11,3]:='Neo SoftWare';
config^.music[12,1]:='5';config.music[12,2]:='HSC';config.music[12,3]:='Neo SoftWare';
config^.music[13,1]:='6';config.music[13,2]:='HSC';config.music[13,3]:='Neo SoftWare';
config^.music[14,1]:='7';config.music[14,2]:='HSC';config.music[14,3]:='Neo SoftWare';
config^.music[15,1]:='8';config.music[15,2]:='HSC';config.music[15,3]:='Neo SoftWare';
config^.music[16,1]:='9';config.music[16,2]:='HSC';config.music[16,3]:='Neo SoftWare';
config^.music[17,1]:='2';config.music[17,2]:='HSC';config.music[17,3]:='Neo SoftWare';
config^.music[18,1]:='3';config.music[18,2]:='HSC';config.music[18,3]:='Neo SoftWare';
config^.music[19,1]:='4';config.music[19,2]:='HSC';config.music[19,3]:='DeadKrew';}
if adlib then
InstallRADTimer;
end;

Procedure InitSubScreen;
var subtemp:sub;
begin
getsubtopics(config^.subscreen[19],subtemp,'mainm');
getsubtopics(config^.subscreen[1],config^.subfile[1],'intro');
getsubtopics(config^.subscreen[2],config^.subfile[2],'inter');
getsubtopics(config^.subscreen[3],config^.subfile[3],'scene');
getsubtopics(config^.subscreen[4],config^.subfile[4],'revie');
getsubtopics(config^.subscreen[5],config^.subfile[5],'misc');
getsubtopics(config^.subscreen[6],config^.subfile[6],'hacke');
getsubtopics(config^.subscreen[7],config^.subfile[7],'music');
getsubtopics(config^.subscreen[8],config^.subfile[8],'coder');
getsubtopics(config^.subscreen[9],config^.subfile[9],'books');
{getsubtopics(config.subscreen[10],config.subfile[10],'top10');
{getsubtopics(config.subscreen[11],config.subfile[11],'11'); 11 is game }
getsubtopics(config^.subscreen[12],config^.subfile[12],'crack');
getsubtopics(config^.subscreen[13],config^.subfile[13],'secre');
{getsubtopics(config.subscreen[14],config.subfile[14],'litle');}
{getsubtopics(config.subscreen[15],config.subfile[15],'15'); 16 is app }
getsubtopics(config^.subscreen[16],config^.subfile[16],'jobsz');
getsubtopics(config^.subscreen[17],config^.subfile[17],'relat');
config^.help_menu:=help_menu;
end;



Procedure GetSubTopics(var sub:subscr; var subf:sub; name:string);
var f : text;
    b : array [1..437] of byte;
    numread : integer;
    str5 : string[5];
    str24: string[24];
    str12: string[13];
    k,i,j:integer;
label after;
begin
     extractfilefromdat('REVTOPIC');
     assign(f,'REVTOPIC');
     reset(f);
     while not eof(f)  do
     begin
          readln(f,str5);
          if name=str5 then
          begin
               for j:= 1 to topics do
               begin
                    read(f,str24);
                    delete(str24,1,1);
                    delete(str24,23,1);
                    readln(f,str12);
                    delete(str12,1,1);
                    subf[j]:=str12;
                    sub[j]:=str24;
               end;
               goto after;
          end;
     end;
after:
close(f);
deletedatfile('REVTOPIC');
end;


end.