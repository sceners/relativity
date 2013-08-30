unit revcfg;
interface
procedure write_config;
procedure read_config;
implementation
uses revconst,revtech,revinit;

var cfg_file: file of configure;

procedure write_config;
var i : integer;
var subtemp:sub;
begin
{------------------------------------------------------------}
for i:= 0 to 15 do
GetPal(i,config^.scr[i,1],config^.scr[i,2],config^.scr[i,3]);
{------------------------------------------------------------}
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
{------------------------------------------------------------}
config^.vol:=62;
config^.notavhelp:=[3,6];
config^.notavarr[19]:=[7,8,10,13,14,15];
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
{------------------------------------------------------------}
config^.muson:=true;
config^.lastmus:=11;
config^.curmus:=musdef;
config^.music[1,1]:='RASTER';config^.music[1,2]:='RAD';config^.music[1,3]:='Reality/Void';
config^.music[2,1]:='CRYSTAL2';config^.music[2,2]:='RAD';config^.music[2,3]:='Neo SoftWare';
config^.music[3,1]:='HANGOVER';config^.music[3,2]:='RAD';config^.music[3,3]:='Reality/Void';
config^.music[4,1]:='HUBBARD';config^.music[4,2]:='RAD'; config^.music[4,3]:='Neo SoftWare';
config^.music[5,1]:='NEOINTRO';config^.music[5,2]:='RAD';config^.music[5,3]:='Neo SoftWare';
config^.music[6,1]:='ALLOYRUN';config^.music[6,2]:='RAD';config^.music[6,3]:='Reality/Void';
config^.music[7,1]:='1';config^.music[7,2]:='HSC';config^.music[7,3]:='Neo SoftWare';
config^.music[8,1]:='ZM2';config^.music[8,2]:='HSC';config^.music[8,3]:='DeadKrew';
{config.music[9,1]:='SMJOOP';config.music[9,2]:='RAD';config.music[9,3]:='Neo SoftWare';
config.music[10,1]:='TERRANIA';config.music[10,2]:='RAD';config.music[10,3]:='Reality/Void';
config.music[11,1]:='INTRO';config.music[11,2]:='HSC';config.music[11,3]:='Reality/Void';
config.music[12,1]:='3';config.music[12,2]:='HSC';config.music[12,3]:='Neo SoftWare';
config.music[13,1]:='4';config.music[13,2]:='HSC';config.music[13,3]:='Neo SoftWare';
config.music[14,1]:='5';config.music[14,2]:='HSC';config.music[14,3]:='Neo SoftWare';
config.music[15,1]:='6';config.music[15,2]:='HSC';config.music[15,3]:='Neo SoftWare';
config.music[16,1]:='7';config.music[16,2]:='HSC';config.music[16,3]:='Neo SoftWare';
config.music[17,1]:='8';config.music[17,2]:='HSC';config.music[17,3]:='Neo SoftWare';
config.music[18,1]:='9';config.music[18,2]:='HSC';config.music[18,3]:='Neo SoftWare';
config.music[19,1]:='2';config.music[19,2]:='HSC';config.music[19,3]:='Neo SoftWare';
{------------------------------------------------------------}
getsubtopics(config^.subscreen[19],subtemp,'mainm');
getsubtopics(config^.subscreen[1],config^.subfile[1],'intro');
getsubtopics(config^.subscreen[2],config^.subfile[2],'insid');
getsubtopics(config^.subscreen[3],config^.subfile[3],'artic');
getsubtopics(config^.subscreen[4],config^.subfile[4],'misc');
getsubtopics(config^.subscreen[5],config^.subfile[5],'revie');
getsubtopics(config^.subscreen[6],config^.subfile[6],'inter');
getsubtopics(config^.subscreen[7],config^.subfile[7],'scene');
getsubtopics(config^.subscreen[8],config^.subfile[8],'highs');
{getsubtopics(config.subscreen[9],config.subfile[9],'9'); 9 is group nfos}
getsubtopics(config^.subscreen[10],config^.subfile[10],'top10');
{getsubtopics(config.subscreen[11],config.subfile[11],'11'); 11 is game }
getsubtopics(config^.subscreen[12],config^.subfile[12],'secre');
{getsubtopics(config.subscreen[13],config.subfile[13],'gques');
getsubtopics(config.subscreen[14],config.subfile[14],'pques');}
{getsubtopics(config.subscreen[15],config.subfile[16],'16'); 16 is survay }
getsubtopics(config^.subscreen[16],config^.subfile[16],'jobsz');
getsubtopics(config^.subscreen[17],config^.subfile[17],'relat');
config^.help_menu:=help_menu;
{------------------------------------------------------------}
assign(cfg_file,'REV97.CFG');
rewrite(cfg_file);
config^.help_menu := help_menu;
{config.scr := scr;
config.Tag:=Tag;
config.NotAvArr:=NotAvArr;
config.NotAvHelp:=NotAvHelp;
config.subfile:=subfile;
config.subscreen:=subscreen;
config.music:=music;
config.muson:=muson;
config.lastmus:=lastmus;
config.curmus:=curmus;
config.vol:=vol;
config.font:=font;
config.curfnt:=curfnt;
config.lastfnt:=lastfnt;}
write(cfg_file,config^);
close(cfg_file);
end;

procedure read_config;
begin
assign(cfg_file,'REV97.CFG');
reset(cfg_file);
read(cfg_file,config^);
close(cfg_file);
end;
end.