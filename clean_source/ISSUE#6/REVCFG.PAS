program revcfg;
uses revconst,revtech,revinit,revpoint,crt;
var cfg_file: file of configure;
const
    help_menu : hlp =
   ('þ Font          ',
    'þ Smooth Scroll ',
    'þ Mr Rodent     ',
    'þ Random Music  ',
    'þ Voc Support   ',
    'þ Save As Text  ',
    'þ Brightness    ',
    'þ Exit Help     ');

var i,j : integer;
var subtemp:sub;
begin
    initconfigpointer;
    config^.y2:=12;
    config^.x2:=19;
    config^.colbacksec2:=magenta;
    config^.colformain2:=lightmagenta;
    config^.y1:=13;
    config^.x1:=18;
    config^.colbacksec1:=green;
    config^.colformain1:=lightgreen;
    config^.init:='HARDWARE.BIN'; {DONE}
    config^.introfile:='REVLONG.BIN'; {DONE}
    config^.password:='SCHOOL SUCKS'; {DONE}
    config^.disc:='DISC.BIN'; {DONE}
    config^.psMenuFile:='PASS.BIN'; {DONE}
    config^.hpMenuFile:='REVHELP.BIN';{DONE}
    config^.bmMenuFile:='REVBOOM.BIN';{DONE}
    config^.DefMenuFile:='REVMAINM.BIN';{DONE}
    config^.SecMenuFile:='REVSECM.BIN'; {DONE}
    config^.TrdMenuFile:='REVSECM.BIN'; {DONE}
    config^.EndMenuFile:='REVEND.BIN';  {DONE}
    config^.EndMenuFile2:='THANKS.BIN'; {DONE}
    config^.openinggif:='DOLBY.GIF';{} {DONE ISSUE 6}
    config^.openinggif2:='INTRO.GIF';
    config^.openinggif3:='INTRO2.GIF';
    config^.passgif:='PASS.GIF';  {}
    config^.closinggif:='END.GIF';
    config^.closinggif2:='END2.GIF';
    config^.closinggif3:='UNDER.GIF';
    config^.muscfgfile:='MUSMEN.BIN';
{    config^.MENUDISC[1]:=true;
    config^.MENUDISC[2]:=false;
    config^.MENUDISC[3]:=false;
    config^.MENUDISC[4]:=true;
    config^.MENUDISC[5]:=true;
    config^.MENUDISC[6]:=true;
    config^.MENUDISC[7]:=false;
    config^.MENUDISC[8]:=false;
    config^.MENUDISC[9]:=true;
    config^.MENUDISC[10]:=false;
    config^.MENUDISC[11]:=false;
    config^.MENUDISC[12]:=false;
    config^.MENUDISC[13]:=false;
    config^.MENUDISC[14]:=true;
    config^.MENUDISC[15]:=true;
    config^.MENUDISC[16]:=false;
    config^.MENUDISC[17]:=false;
    config^.MENUDISC[18]:=false;}
    config^.vg[1]:='INTROSEC.GIF';
    config^.vg[2]:='SCENESEC.GIF';
    config^.vg[3]:='OLDSEC.GIF';
    config^.vg[4]:='';
    config^.vg[5]:='REVSEC.GIF';
    config^.vg[6]:='';
    config^.vg[7]:='WOMANSEC.GIF';
    config^.vg[8]:='';
    config^.vg[9]:='';
    config^.vg[10]:='';
    config^.vg[11]:='';
    config^.vg[12]:='';
    config^.vg[13]:='';
    config^.vg[14]:='';
    config^.vg[15]:='';
    config^.vg[16]:='';
    config^.vg[17]:='';
    config^.vg[18]:='';
    config^.vocs[1]:='BLOW.VOC';
    config^.vocs[2]:='BLOW2.VOC';
    config^.vocs[3]:='BLOW3.VOC';
    config^.vocs[4]:='AON.VOC';
    config^.vocs[5]:='AOFF.VOC';
    config^.vocs[6]:='HON.VOC';
    config^.vocs[7]:='HOFF.VOC';
    config^.vocs[8]:='OON.VOC';
    config^.vocs[9]:='OOFF.VOC';
    config^.vocs[10]:='SCREAM1.VOC';
    config^.vocs[11]:='SCREAM2.VOC';
    config^.vocs[12]:='SCREAM3.VOC';
    config^.vocs[13]:='AWARNING.VOC';
    config^.vocs[14]:='HWARNING.VOC';
    config^.vocs[15]:='OWARNING.VOC';
    config^.vocs[16]:='OK.VOC';
    config^.vocs[17]:='OK2.VOC';
    config^.vocs[18]:='OK3.VOC';
    config^.vocs[19]:='FONT.VOC';
    config^.vocs[20]:='INTRO.VOC';
    config^.vocs[21]:='NOW.VOC';
    config^.vocs[22]:='CRUMBLE.VOC';
    config^.vocs[23]:='.VOC';
    config^.vocs[24]:='.VOC';
    config^.vocs[25]:='.VOC';
{-------}
     for i:= 1 to 19 do
     begin
     config^.tag[i]:=[];
     config^.notavarr[i]:=[];
     end;
     config^.notavarr[19]:=[];
     config^.notavarr[1]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[2]:=[9,10,11,12,13,14,15,16,17];
     config^.notavarr[3]:=[5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[4]:=[15,16,17];
     config^.notavarr[5]:=[9,10,11,12,13,14,15,16,17];
     config^.notavarr[6]:=[11,12,13,14,15,16,17];
     config^.notavarr[7]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[8]:=[6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[9]:=[3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[10]:=[12,13,14,15,16,17]; {UNKNOWNYET}
     config^.notavarr[12]:=[5,6,7,8,9,10,11,12,13,14,15,16,17]; {UNKNOWNYET}
     config^.notavarr[13]:=[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[14]:=[6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[15]:=[6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[16]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[17]:=[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];{app}
{-------}
InitBright;
InitFonts;
InitMusic;
config^.help_menu:=help_menu;

assign(cfg_file,'REV97.CFG');
rewrite(cfg_file);

for i:= 1 to 18 do
    for j:= 1 to 18 do
    begin
        config^.subfile[i][j]:='';
        config^.subscreen[i][j]:='';
    end;
{main menu}
config^.subscreen[19][1]:='þ Introductions       ';
config^.subscreen[19][2]:='þ Scene Section       ';
config^.subscreen[19][3]:='þ OLD SKOOL           ';
config^.subscreen[19][4]:='þ The Misc Section    ';
config^.subscreen[19][5]:='þ Relativity''s Sec    ';
config^.subscreen[19][6]:='þ Terror Section      ';
config^.subscreen[19][7]:='þ Women''s Section     ';
config^.subscreen[19][8]:='þ The Music Scene     ';
config^.subscreen[19][9]:='þ Coding Section      ';
config^.subscreen[19][10]:='þ The VGA Art Section ';
config^.subscreen[19][11]:='þ Arkanoid The Game   ';
config^.subscreen[19][12]:='þ RAZOR 1911          ';
config^.subscreen[19][13]:='þ Secret Articles     ';
config^.subscreen[19][14]:='þ Top 10''s            ';
config^.subscreen[19][15]:='þ Game Reviews        ';
config^.subscreen[19][16]:='þ The Stupid Section  ';
config^.subscreen[19][17]:='þ Job Openings        ';
config^.subscreen[19][18]:='þ Conclusion          ';
{hard and software .. or alone , }
{intro}
config^.subscreen[1][1]:='þ Introduction        ';config^.subfile[1][1]:='ENKRYPT.BIN';
config^.subscreen[1][2]:='þ MuadDIb Speaks      ';config^.subfile[1][2]:='MUADDIB.BIN';
config^.subscreen[1][3]:='þ Past Passwords      ';config^.subfile[1][3]:='PASSWORD.BIN';
config^.subscreen[1][4]:='þ ------------------- ';config^.subfile[1][4]:='';
config^.subscreen[1][5]:='þ ------------------- ';config^.subfile[1][5]:='';
config^.subscreen[1][6]:='þ ------------------- ';config^.subfile[1][6]:='';
config^.subscreen[1][7]:='þ ------------------- ';config^.subfile[1][7]:='';
config^.subscreen[1][8]:='þ ------------------- ';config^.subfile[1][8]:='';
config^.subscreen[1][9]:='þ ------------------- ';config^.subfile[1][9]:='';
config^.subscreen[1][10]:='þ ------------------- ';config^.subfile[1][10]:='';
config^.subscreen[1][11]:='þ ------------------- ';config^.subfile[1][11]:='';
config^.subscreen[1][12]:='þ ------------------- ';config^.subfile[1][12]:='';
config^.subscreen[1][13]:='þ ------------------- ';config^.subfile[1][13]:='';
config^.subscreen[1][14]:='þ ------------------- ';config^.subfile[1][14]:='';
config^.subscreen[1][15]:='þ ------------------- ';config^.subfile[1][15]:='';
config^.subscreen[1][16]:='þ ------------------- ';config^.subfile[1][16]:='';
config^.subscreen[1][17]:='þ ------------------- ';config^.subfile[1][17]:='';
config^.subscreen[1][18]:='þ Exit To Main        ';config^.subfile[1][18]:='';
i:=2;
config^.subscreen[i][1]:='þ "I''m Just lame.."   ';config^.subfile[i][1]:='SCENE01.BIN';
config^.subscreen[i][2]:='þ Inter W/ ^DuctMan^  ';config^.subfile[i][2]:='SCENE02.BIN';
config^.subscreen[i][3]:='þ The changing ...    ';config^.subfile[i][3]:='SCENE03.BIN';
config^.subscreen[i][4]:='þ Inter W/sextronix   ';config^.subfile[i][4]:='SCENE04.BIN';
config^.subscreen[i][5]:='þ Internet vs. BBS''s  ';config^.subfile[i][5]:='SCENE05.BIN';
config^.subscreen[i][6]:='þ Scene Friendship    ';config^.subfile[i][6]:='SCENE06.BIN';
config^.subscreen[i][7]:='þ Old Warez Dayz      ';config^.subfile[i][7]:='SCENE07.BIN';
config^.subscreen[i][8]:='þ Lame Ass Nukers     ';config^.subfile[i][8]:='SCENE08.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=3;
config^.subscreen[i][1]:='þ NEiL/FLT            ';config^.subfile[i][1]:='OLD01.BIN';
config^.subscreen[i][2]:='þ LordByron           ';config^.subfile[i][2]:='OLD02.BIN';
config^.subscreen[i][3]:='þ Theprofil           ';config^.subfile[i][3]:='OLD03.BIN';
config^.subscreen[i][4]:='þ TRISTAR & REDSECTOR ';config^.subfile[i][4]:='OLD04.BIN';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=4;
config^.subscreen[i][1]:='þ Year of the Beast   ';config^.subfile[i][1]:='MISC01.BIN';
config^.subscreen[i][2]:='þ Guide to Safe Sex   ';config^.subfile[i][2]:='MISC02.BIN';
config^.subscreen[i][3]:='þ Inet Addicts Test   ';config^.subfile[i][3]:='MISC03.BIN';
config^.subscreen[i][4]:='þ Famous Last Words   ';config^.subfile[i][4]:='MISC04.BIN';
config^.subscreen[i][5]:='þ X-mas in the Hood   ';config^.subfile[i][5]:='MISC05.BIN';
config^.subscreen[i][6]:='þ Puters Male,Female? ';config^.subfile[i][6]:='MISC06.BIN';
config^.subscreen[i][7]:='þ Rich Gates          ';config^.subfile[i][7]:='MISC07.BIN';
config^.subscreen[i][8]:='þ Fun With Barbie     ';config^.subfile[i][8]:='MISC08.BIN';
config^.subscreen[i][9]:='þ Diary of Aol User   ';config^.subfile[i][9]:='MISC09.BIN';
config^.subscreen[i][10]:='þ 30 things in a car  ';config^.subfile[i][10]:='MISC10.BIN';
config^.subscreen[i][11]:='þ Jokes               ';config^.subfile[i][11]:='MISC11.BIN';
config^.subscreen[i][12]:='þ Death               ';config^.subfile[i][12]:='MISC12.BIN';
config^.subscreen[i][13]:='þ Bad Isp ?           ';config^.subfile[i][13]:='MISC13.BIN';
config^.subscreen[i][14]:='þ Your Ghetto         ';config^.subfile[i][14]:='MISC14.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
{relativity}
i:=5;
config^.subscreen[i][1]:='þ Believe Me !!!!     ';config^.subfile[i][1]:='REV01.BIN';
config^.subscreen[i][2]:='þ Believe Me 2 !!!!!  ';config^.subfile[i][2]:='REV02.BIN';
config^.subscreen[i][3]:='þ The Fcc (whatever)  ';config^.subfile[i][3]:='REV03.BIN';
config^.subscreen[i][4]:='þ Relativity''s Faq    ';config^.subfile[i][4]:='REVFAQ.BIN';
config^.subscreen[i][5]:='þ Relativity''s NFO    ';config^.subfile[i][5]:='REVNFO.BIN';
config^.subscreen[i][6]:='þ Relativity''s App    ';config^.subfile[i][6]:='REVAPP.BIN';
config^.subscreen[i][7]:='þ Writer Instructions ';config^.subfile[i][7]:='WRITERS.BIN';
config^.subscreen[i][8]:='þ Thanks To .....      ';config^.subfile[i][8]:='THANKS.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=6;{terror}
config^.subscreen[i][1]:='þ Sodium Bomb         ';config^.subfile[i][1]:='TERROR01.BIN';
config^.subscreen[i][2]:='þ School Puters       ';config^.subfile[i][2]:='TERROR02.BIN';
config^.subscreen[i][3]:='þ Neighbour Hell 1    ';config^.subfile[i][3]:='TERROR03.BIN';
config^.subscreen[i][4]:='þ Neighbour Hell 2    ';config^.subfile[i][4]:='TERROR04.BIN';
config^.subscreen[i][5]:='þ Flame Thrower       ';config^.subfile[i][5]:='TERROR05.BIN';
config^.subscreen[i][6]:='þ Things              ';config^.subfile[i][6]:='TERROR06.BIN';
config^.subscreen[i][7]:='þ Pissing Food Outlet ';config^.subfile[i][7]:='TERROR07.BIN';
config^.subscreen[i][8]:='þ Cocktail Bomb       ';config^.subfile[i][8]:='TERROR08.BIN';
config^.subscreen[i][9]:='þ Soda Bomb           ';config^.subfile[i][9]:='TERROR09.BIN';
config^.subscreen[i][10]:='þ Ingredients         ';config^.subfile[i][10]:='TERROR10.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=7;{Woman's}
config^.subscreen[i][1]:='þ Rulez of Relations  ';config^.subfile[i][1]:='WOMAN01.BIN';
config^.subscreen[i][2]:='þ Jokes               ';config^.subfile[i][2]:='WOMAN02.BIN';
config^.subscreen[i][3]:='þ LoveMaker 3.1v      ';config^.subfile[i][3]:='WOMAN03.BIN';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='.BIN';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=8;{muisc}
config^.subscreen[i][1]:='þ Nana - Lonely       ';config^.subfile[i][1]:='MUSIC01.BIN';
config^.subscreen[i][2]:='þ Offspring''s Concert ';config^.subfile[i][2]:='MUSIC02.BIN';
config^.subscreen[i][3]:='þ The Prodigy         ';config^.subfile[i][3]:='MUSIC03.BIN';
config^.subscreen[i][4]:='þ Real Audio or Mp3 ? ';config^.subfile[i][4]:='MUSIC04.BIN';
config^.subscreen[i][5]:='þ UNDERGROUND SOUNDS  ';config^.subfile[i][5]:='MUSIC05.BIN';
config^.subscreen[i][6]:='þ -------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ -------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ -------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ -------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=9;{Coding}
config^.subscreen[i][1]:='þ Hacking Pop3        ';config^.subfile[i][1]:='CODE01.BIN';
config^.subscreen[i][2]:='þ Menu in Pascal      ';config^.subfile[i][2]:='CODE02.BIN';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='.BIN';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='.BIN';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=10;{VGA}
config^.subscreen[i][1]:='þ ENKRYPT #1          ';config^.subfile[i][1]:='ART01.GIF';
config^.subscreen[i][2]:='þ ^AcMe^ #1           ';config^.subfile[i][2]:='ART02.GIF';
config^.subscreen[i][3]:='þ Keiser Soze #1      ';config^.subfile[i][3]:='ART03.GIF';
config^.subscreen[i][4]:='þ Sir Magik #1        ';config^.subfile[i][4]:='ART04.GIF';
config^.subscreen[i][5]:='þ UnKnown #1          ';config^.subfile[i][5]:='ART05.GIF';
config^.subscreen[i][6]:='þ STAR #1000          ';config^.subfile[i][6]:='ART06.GIF';
config^.subscreen[i][7]:='þ STAR #1001          ';config^.subfile[i][7]:='ART07.GIF';
config^.subscreen[i][8]:='þ MOZ #1              ';config^.subfile[i][8]:='ART08.GIF';
config^.subscreen[i][9]:='þ PU69Y #1            ';config^.subfile[i][9]:='ART09.GIF';
config^.subscreen[i][10]:='þ STAR #1002          ';config^.subfile[i][10]:='ART10.GIF';
config^.subscreen[i][11]:='þ STAR #1003          ';config^.subfile[i][11]:='ART11.GIF';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=11; {Game}
config^.subscreen[i][1]:='þ REVIMAGE #1         ';config^.subfile[i][1]:='ART00.GIF';
config^.subscreen[i][2]:='þ REVIMAGE #2         ';config^.subfile[i][2]:='ART01.GIF';
config^.subscreen[i][3]:='þ REVIMAGE #3         ';config^.subfile[i][3]:='ART02.GIF';
config^.subscreen[i][4]:='þ REVIMAGE #4         ';config^.subfile[i][4]:='ART04.GIF';
config^.subscreen[i][5]:='þ REVIMAGE #5         ';config^.subfile[i][5]:='ART05.GIF';
config^.subscreen[i][6]:='þ REVIMAGE #6         ';config^.subfile[i][6]:='ART06.GIF';
config^.subscreen[i][7]:='þ REVIMAGE #7         ';config^.subfile[i][7]:='ART07.GIF';
config^.subscreen[i][8]:='þ REVIMAGE #8         ';config^.subfile[i][8]:='ART08.GIF';
config^.subscreen[i][9]:='þ REVIMAGE #9         ';config^.subfile[i][9]:='ART09.GIF';
config^.subscreen[i][10]:='þ REVIMAGE #10         ';config^.subfile[i][10]:='ART10.GIF';
config^.subscreen[i][11]:='þ REVIMAGE #11         ';config^.subfile[i][11]:='ART11.GIF';
config^.subscreen[i][12]:='þ REVIMAGE #12         ';config^.subfile[i][12]:='ART12.GIF';
config^.subscreen[i][13]:='þ REVIMAGE #13         ';config^.subfile[i][13]:='ART13.GIF';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=12;{RAZOR}
config^.subscreen[i][1]:='þ THE PUNISHER RESIGN ';config^.subfile[i][1]:='RAZOR01.BIN';
config^.subscreen[i][2]:='þ PITBULL REPLIES     ';config^.subfile[i][2]:='RAZOR02.BIN';
config^.subscreen[i][3]:='þ THIRD SON REPLIES   ';config^.subfile[i][3]:='RAZOR03.BIN';
config^.subscreen[i][4]:='þ TSR REPLIES         ';config^.subfile[i][4]:='RAZOR04.BIN';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=13;{SECRET}
config^.subscreen[i][1]:='þ Biskit''s            ';config^.subfile[i][1]:='SECRET01.BIN';
config^.subscreen[i][2]:='þ ------------------- ';config^.subfile[i][2]:='.BIN';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='.BIN';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='.BIN';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=14;{10}
config^.subscreen[i][1]:='þ Top 10 Sites        ';config^.subfile[i][1]:='10SITES.BIN';
config^.subscreen[i][2]:='þ Top 10 Couriers     ';config^.subfile[i][2]:='10COUR.BIN';
config^.subscreen[i][3]:='þ Top 10 ALL Groups   ';config^.subfile[i][3]:='10ALLGRP.BIN';
config^.subscreen[i][4]:='þ Top 10 Groups       ';config^.subfile[i][4]:='10GROUPS.BIN';
config^.subscreen[i][5]:='þ Top 10 of Sites     ';config^.subfile[i][5]:='SITES.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=15;{Game Reviews}
config^.subscreen[i][1]:='þ Ms - Gaming Zone    ';config^.subfile[i][1]:='REVIEW01.BIN';
config^.subscreen[i][2]:='þ Quake 2             ';config^.subfile[i][2]:='REVIEW02.BIN';
config^.subscreen[i][3]:='þ Worms 2             ';config^.subfile[i][3]:='REVIEW03.BIN';
config^.subscreen[i][4]:='þ Age of Empire       ';config^.subfile[i][4]:='REVIEW04.BIN';
config^.subscreen[i][5]:='þ Final Fantasy 7     ';config^.subfile[i][5]:='REVIEW05.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=16;{Stupid}
config^.subscreen[i][1]:='þ Dumbest Acts        ';config^.subfile[i][1]:='STUPID01.BIN';
config^.subscreen[i][2]:='þ The Theory of ReV   ';config^.subfile[i][2]:='STUPID02.BIN';
config^.subscreen[i][3]:='þ Weird Opcodes       ';config^.subfile[i][3]:='STUPID03.BIN';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='.BIN';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='.BIN';
config^.subscreen[i][6]:='þ ------------------- ';config^.subfile[i][6]:='.BIN';
config^.subscreen[i][7]:='þ ------------------- ';config^.subfile[i][7]:='.BIN';
config^.subscreen[i][8]:='þ ------------------- ';config^.subfile[i][8]:='.BIN';
config^.subscreen[i][9]:='þ ------------------- ';config^.subfile[i][9]:='.BIN';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='.BIN';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='.BIN';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='.BIN';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='.BIN';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='.BIN';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='.BIN';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='.BIN';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='.BIN';
i:=17;{jobs}
config^.subscreen[i][1]:='þ ----Relativity ---- ';
config^.subscreen[i][2]:='þ ------------------- ';
config^.subscreen[i][3]:='þ ---- Positions ---- ';
config^.subscreen[i][4]:='þ ------------------- ';
config^.subscreen[i][5]:='þ 1) Ansi Artists     ';
config^.subscreen[i][6]:='þ 2) Vga Artists      ';
config^.subscreen[i][7]:='þ 3) Bot Masters      ';
config^.subscreen[i][8]:='þ 4) Writers          ';
config^.subscreen[i][9]:='þ ------------------- ';
config^.subscreen[i][10]:='þ ------------------- ';
config^.subscreen[i][11]:='þ ------------------- ';
config^.subscreen[i][12]:='þ ------------------- ';
config^.subscreen[i][13]:='þ If you think you can';
config^.subscreen[i][14]:='þ  help us out in any ';
config^.subscreen[i][15]:='þ   way, contact us!  ';
config^.subscreen[i][16]:='þ ------------------- ';
config^.subscreen[i][17]:='þ ------------------- ';
config^.subscreen[i][18]:='þ Exit To Main        ';
write(cfg_file,config^);
close(cfg_file);
KillConfigPointer;
end.