unit revinit;

interface
uses  revconst,revrad;

Procedure InitMusic;
Procedure InitSubScreen;
Procedure InitSubFiles;
Procedure InitKey(speed:byte);

implementation

Procedure InitKey(speed:byte);
begin
Port[$60]:=$F3;
Port[$60]:=speed;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Init Sub Files                                          *)
(****************************************************************************)

Procedure InitMusic;
begin
lastmus:=11;
curmus:=musdef;
music[1,1]:='RASTER';music[1,2]:='RAD';
music[2,1]:='CRYSTAL2';music[2,2]:='RAD';
music[3,1]:='HANGOVER';music[3,2]:='RAD';
music[4,1]:='HUBBARD';music[4,2]:='RAD';
music[5,1]:='NEOINTRO';music[5,2]:='RAD';
music[6,1]:='ALLOYRUN';music[6,2]:='RAD';
music[7,1]:='1';music[7,2]:='HSC';
music[8,1]:='ZM2';music[8,2]:='HSC';
music[9,1]:='SMJOOP';music[9,2]:='RAD';
music[10,1]:='TERRANIA';music[10,2]:='RAD';
music[11,1]:='INTRO';music[11,2]:='HSC';
music[12,1]:='3';music[12,2]:='HSC';
music[13,1]:='4';music[13,2]:='HSC';
music[14,1]:='5';music[14,2]:='HSC';
music[15,1]:='6';music[15,2]:='HSC';
music[16,1]:='7';music[16,2]:='HSC';
music[17,1]:='8';music[17,2]:='HSC';
music[18,1]:='9';music[18,2]:='HSC';
music[19,1]:='2';music[19,2]:='HSC';
InstallRADTimer;
end;

Procedure InitSubScreen;
begin
getsubtopics(subscreen[19],'mainm');
getsubtopics(subscreen[2],'cover');
getsubtopics(subscreen[3],'artic');
getsubtopics(subscreen[4],'insid');
getsubtopics(subscreen[5],'gamer');
getsubtopics(subscreen[7],'scene');
getsubtopics(subscreen[16],'jobsz');
getsubtopics(subscreen[17],'relat');
helpmenu:=help_menu;
end;

{Procedure InitSubScreen;
begin
subscreen[19]:=main_menu;
{subscreen[1]:=intro;}
{subscreen[2]:=cover_story;
subscreen[3]:=article;
subscreen[4]:=inside_scoop;
subscreen[5]:=game_reviews;
subscreen[7]:=scene_flash;
{subscreen[11]:=game;}
{subscreen[16]:=job;
subscreen[17]:=relativity;
helpmenu:=help_menu;
end;}

Procedure InitSubFiles;
Const Ext='BIN';
begin
subfile[1][1]:='INTRO.'+ext;
subfile[2][1]:='COVER1.'+ext;
subfile[2][2]:='COVER2.'+ext;
subfile[3][1]:='ARTIC1.'+ext;
subfile[3][2]:='ARTIC2.'+ext;
subfile[3][3]:='ARTIC3.'+ext;
subfile[4][1]:='INTER1.'+ext;
subfile[4][2]:='INTER2.'+ext;
subfile[5][1]:='GAME2.'+ext;
subfile[5][2]:='GAME1.'+ext;
subfile[7][1]:='FLASH1.'+ext;
subfile[17][1]:='CONTACT.'+ext;
subfile[17][2]:='CONTRIB.'+ext;
subfile[17][3]:='REVNFO.'+ext;
end;
end.