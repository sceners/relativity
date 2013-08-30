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
    config^.defsavefile:='REV98-07.REV';
    config^.fntdef:=12;
    config^.radmusdef:=1;
    config^.dsmmusdef:=22;
    config^.pass_section:=13;
    config^.game_section:=11;
    config^.colbacksec1:=green;
    config^.colformain1:=lightgreen;
    config^.cfg_file:=cfg_name; {DONE}
    config^.init:='HARDWARE.BIN'; {DONE}
    config^.longfile:='REVLONG.BIN'; {DONE}
    config^.long:=TRUE; {DONE}
    config^.fli:=TRUE; {DONE}
    config^.password:='GARGOYLES'; {DONE}
    config^.disc:='DISC.BIN'; {DONE}
    config^.psMenuFile:='PASS.BIN'; {DONE}
    config^.hpMenuFile:='REVHELP.BIN';{DONE}
    config^.bmMenuFile:='REVBOOM.BIN';{DONE}
    config^.DefMenuFile:='REVMAINM.BIN';{DONE}
    config^.SecMenuFile:='REVSECM.BIN'; {DONE}
    config^.TrdMenuFile:='REVSECM.BIN'; {DONE}
    config^.EndMenuFile:='REVEND.BIN';  {DONE}
    config^.EndMenuFlag:=TRUE;  {DONE}
    config^.EndMenuFile2:='THANKS.BIN'; {DONE}
    config^.dolby_pic:='DOLBY.GIF';{} {DONE ISSUE 6}
    config^.intro[1]:='INTRO.GIF';
    config^.intro[2]:='INTRO2.GIF';
    config^.under_pic:='UNDER.GIF';
    config^.passgif:='PASS.GIF';  {}
    config^.outro[1]:='OUTRO.GIF';
    config^.outro[2]:='OUTRO2.GIF';
    config^.muscfgfile:='MUSMEN.BIN';
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
     config^.notavarr[19]:=[10,12,15,16];
     config^.notavarr[1]:=[5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[2]:=[5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[3]:=[10,11,12,13,14,15,16,17];
     config^.notavarr[4]:=[16,17];
     config^.notavarr[5]:=[7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[6]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[7]:=[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[8]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[9]:=[10,11,12,13,14,15,16,17];
     config^.notavarr[10]:=[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]; {UNKNOWNYET}
     config^.notavarr[12]:=[5,6,7,8,9,10,11,12,13,14,15,16,17]; {UNKNOWNYET}
     config^.notavarr[13]:=[3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[14]:=[7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[15]:=[8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[16]:=[4,5,6,7,8,9,10,11,12,13,14,15,16,17];
     config^.notavarr[17]:=[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];{app}
{-------}
InitBright;
InitFonts;
InitMusic;
config^.help_menu:=help_menu;

assign(cfg_file,CONFIG^.CFG_FILE);
rewrite(cfg_file);

for i:= 1 to 18 do
    for j:= 1 to 18 do
    begin
        config^.subfile[i][j]:='';
        config^.subscreen[i][j]:='';
    end;

{main menu}
config^.subscreen[19][1]:='þ Introductions       ';config^.subfile[19][1]:='';
config^.subscreen[19][2]:='þ Scene NEWS Section  ';config^.subfile[19][2]:='';
config^.subscreen[19][3]:='þ Articles .....      ';config^.subfile[19][3]:='';
config^.subscreen[19][4]:='þ The Misc Section    ';config^.subfile[19][4]:='';
config^.subscreen[19][5]:='þ Relativity''s Sec    ';config^.subfile[19][5]:='';
config^.subscreen[19][6]:='þ Anti - Racism Sec   ';config^.subfile[19][6]:='';
config^.subscreen[19][7]:='þ Software Section    ';config^.subfile[19][7]:='';
config^.subscreen[19][8]:='þ The Ansi Section    ';config^.subfile[19][8]:='';
config^.subscreen[19][9]:='þ The VGA Art Section ';config^.subfile[19][9]:='';
config^.subscreen[19][10]:='þ The Coding Scene    ';config^.subfile[19][10]:='';
config^.subscreen[19][11]:='þ Arkanoid The Game   ';config^.subfile[19][11]:='';
config^.subscreen[19][12]:='þ Music Scene         ';config^.subfile[19][12]:='';
config^.subscreen[19][13]:='þ Secret Articles     ';config^.subfile[19][13]:='SECRET.GIF';
config^.subscreen[19][14]:='þ Top 10''s            ';config^.subfile[19][14]:='';
config^.subscreen[19][15]:='þ Game Reviews        ';config^.subfile[19][15]:='';
config^.subscreen[19][16]:='þ The Stupid Section  ';config^.subfile[19][16]:='';
config^.subscreen[19][17]:='þ Job Openings        ';config^.subfile[19][17]:='';
config^.subscreen[19][18]:='þ Conclusion          ';config^.subfile[19][18]:='';
{hard and software .. or alone , }
{intro}
config^.subscreen[1][1]:='þ Introduction        ';config^.subfile[1][1]:='ENKRYPT.BIN';
config^.subscreen[1][2]:='þ MuadDIb Speaks      ';config^.subfile[1][2]:='MUADDIB.BIN';
config^.subscreen[1][3]:='þ Past Passwords      ';config^.subfile[1][3]:='PASSWORD.BIN';
config^.subscreen[1][4]:='þ Universal Engine    ';config^.subfile[1][4]:='UNI.BIN';
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
config^.subscreen[i][1]:='þ Dead Grps,Save them?';config^.subfile[i][1]:='sCENE01.BIN';
config^.subscreen[i][2]:='þ Inter W/Biomatrix   ';config^.subfile[i][2]:='SCENE02.BIN';
config^.subscreen[i][3]:='þ Inter W/Hoson       ';config^.subfile[i][3]:='SCENE03.BIN';
config^.subscreen[i][4]:='þ Rebel Rumers        ';config^.subfile[i][4]:='SCENE04.BIN';
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
i:=3;
config^.subscreen[i][1]:='þ Pc nerds?are They ? ';config^.subfile[i][1]:='ARTIC01.BIN';
config^.subscreen[i][2]:='þ USA Controls all ?  ';config^.subfile[i][2]:='ARTIC02.BIN';
config^.subscreen[i][3]:='þ The Scene..         ';config^.subfile[i][3]:='ARTIC03.BIN';
config^.subscreen[i][4]:='þ Today''s Scene       ';config^.subfile[i][4]:='ARTIC04.BIN';
config^.subscreen[i][5]:='þ Un-Nudes            ';config^.subfile[i][5]:='ARTIC05.BIN';
config^.subscreen[i][6]:='þ IBM Sucks           ';config^.subfile[i][6]:='ARTIC06.BIN';
config^.subscreen[i][7]:='þ Bill Gets Creamed   ';config^.subfile[i][7]:='ARTIC07.BIN';
config^.subscreen[i][8]:='þ Bill''s Picture      ';config^.subfile[i][8]:='BILL.GIF';
config^.subscreen[i][9]:='þ The Creamer          ';config^.subfile[i][9]:='SHOOTER.GIF';
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
config^.subscreen[i][1]:='þ Coke Addict         ';config^.subfile[i][1]:='MISC01.BIN';
config^.subscreen[i][2]:='þ Make Your Wife Come ';config^.subfile[i][2]:='MISC02.BIN';
config^.subscreen[i][3]:='þ Cool Things To Say  ';config^.subfile[i][3]:='MISC03.BIN';
config^.subscreen[i][4]:='þ Some Good Jokes ..  ';config^.subfile[i][4]:='MISC04.BIN';
config^.subscreen[i][5]:='þ Seinfeld            ';config^.subfile[i][5]:='MISC05.BIN';
config^.subscreen[i][6]:='þ Hacking,The Meaning ';config^.subfile[i][6]:='MISC06.BIN';
config^.subscreen[i][7]:='þ Are You A Good Girl ';config^.subfile[i][7]:='MISC07.BIN';
config^.subscreen[i][8]:='þ Bedroom Golf        ';config^.subfile[i][8]:='MISC08.BIN';
config^.subscreen[i][9]:='þ Jack Schitt         ';config^.subfile[i][9]:='MISC09.BIN';
config^.subscreen[i][10]:='þ I Love You''s        ';config^.subfile[i][10]:='MISC10.BIN';
config^.subscreen[i][11]:='þ 28 Types of Men     ';config^.subfile[i][11]:='MISC11.BIN';
config^.subscreen[i][12]:='þ New Tax ...         ';config^.subfile[i][12]:='MISC12.BIN';
config^.subscreen[i][13]:='þ Potatoe Head        ';config^.subfile[i][13]:='MISC13.BIN';
config^.subscreen[i][14]:='þ Medical Terms       ';config^.subfile[i][14]:='MISC14.BIN';
config^.subscreen[i][15]:='þ Valentines Day      ';config^.subfile[i][15]:='MISC15.BIN';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
{relativity}
i:=5;
config^.subscreen[i][1]:='þ Relativity''s Faq    ';config^.subfile[i][1]:='REVFAQ.BIN';
config^.subscreen[i][2]:='þ Relativity''s NFO    ';config^.subfile[i][2]:='REVNFO.BIN';
config^.subscreen[i][3]:='þ Relativity''s App    ';config^.subfile[i][3]:='REVAPP.BIN';
config^.subscreen[i][4]:='þ Writer Instructions ';config^.subfile[i][4]:='WRITERS.BIN';
config^.subscreen[i][5]:='þ Thanks To .....     ';config^.subfile[i][5]:='THANKS.BIN';
config^.subscreen[i][6]:='þ Advertisements      ';config^.subfile[i][6]:='REVXX.BIN';
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
i:=6;{anti}
config^.subscreen[i][1]:='þ Rednecks in school  ';config^.subfile[i][1]:='ANTI01.BIN';
config^.subscreen[i][2]:='þ Racism on the Scene ';config^.subfile[i][2]:='ANTI02.BIN';
config^.subscreen[i][3]:='þ Racism on Iparty    ';config^.subfile[i][3]:='ANTI03.BIN';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=7;{Soft}
config^.subscreen[i][1]:='þ Promotion Seminar   ';config^.subfile[i][1]:='SOFT01.BIN';
config^.subscreen[i][2]:='þ ------------------- ';config^.subfile[i][2]:='';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=8;{muisc}
config^.subscreen[i][1]:='þ Desert Fox #1       ';config^.subfile[i][1]:='ANSI01.BIN';
config^.subscreen[i][2]:='þ Desert Fox #2       ';config^.subfile[i][2]:='ANSI02.BIN';
config^.subscreen[i][3]:='þ UnKnown             ';config^.subfile[i][3]:='ANSI03.BIN';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
config^.subscreen[i][5]:='þ ------------------- ';config^.subfile[i][5]:='';
config^.subscreen[i][6]:='þ -------------------- ';config^.subfile[i][6]:='';
config^.subscreen[i][7]:='þ -------------------- ';config^.subfile[i][7]:='';
config^.subscreen[i][8]:='þ -------------------- ';config^.subfile[i][8]:='';
config^.subscreen[i][9]:='þ -------------------- ';config^.subfile[i][9]:='';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=9;{Coding}
config^.subscreen[i][1]:='þ STAR #1             ';config^.subfile[i][1]:='1.GIF';
config^.subscreen[i][2]:='þ STAR #2             ';config^.subfile[i][2]:='2.GIF';
config^.subscreen[i][3]:='þ STAR #3             ';config^.subfile[i][3]:='3.GIF';
config^.subscreen[i][4]:='þ STAR #4             ';config^.subfile[i][4]:='4.GIF';
config^.subscreen[i][5]:='þ STAR #5             ';config^.subfile[i][5]:='5.GIF';
config^.subscreen[i][6]:='þ STAR #6             ';config^.subfile[i][6]:='6.GIF';
config^.subscreen[i][7]:='þ KEISER SOZE #1      ';config^.subfile[i][7]:='7.GIF';
config^.subscreen[i][8]:='þ PU69Y #1            ';config^.subfile[i][8]:='8.GIF';
config^.subscreen[i][9]:='þ PU69Y #2            ';config^.subfile[i][9]:='9.GIF';
config^.subscreen[i][10]:='þ ------------------- ';config^.subfile[i][10]:='';
config^.subscreen[i][11]:='þ ------------------- ';config^.subfile[i][11]:='';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=10;{VGA}
config^.subscreen[i][1]:='þ ENKRYPT #1          ';config^.subfile[i][1]:='';
config^.subscreen[i][2]:='þ ^AcMe^ #1           ';config^.subfile[i][2]:='';
config^.subscreen[i][3]:='þ Keiser Soze #1      ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ Sir Magik #1        ';config^.subfile[i][4]:='';
config^.subscreen[i][5]:='þ UnKnown #1          ';config^.subfile[i][5]:='';
config^.subscreen[i][6]:='þ STAR #1000          ';config^.subfile[i][6]:='';
config^.subscreen[i][7]:='þ STAR #1001          ';config^.subfile[i][7]:='';
config^.subscreen[i][8]:='þ MOZ #1              ';config^.subfile[i][8]:='';
config^.subscreen[i][9]:='þ PU69Y #1            ';config^.subfile[i][9]:='';
config^.subscreen[i][10]:='þ STAR #1002          ';config^.subfile[i][10]:='';
config^.subscreen[i][11]:='þ STAR #1003          ';config^.subfile[i][11]:='';
config^.subscreen[i][12]:='þ ------------------- ';config^.subfile[i][12]:='';
config^.subscreen[i][13]:='þ ------------------- ';config^.subfile[i][13]:='';
config^.subscreen[i][14]:='þ ------------------- ';config^.subfile[i][14]:='';
config^.subscreen[i][15]:='þ ------------------- ';config^.subfile[i][15]:='';
config^.subscreen[i][16]:='þ ------------------- ';config^.subfile[i][16]:='';
config^.subscreen[i][17]:='þ ------------------- ';config^.subfile[i][17]:='';
config^.subscreen[i][18]:='þ Exit To Main        ';config^.subfile[i][18]:='';
i:=11; {Game}
config^.subscreen[i][1]:='þ ------------------- ';config^.subfile[i][1]:='';
config^.subscreen[i][2]:='þ ------------------- ';config^.subfile[i][2]:='';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=12;{RAZOR}
config^.subscreen[i][1]:='þ THE PUNISHER RESIGN ';config^.subfile[i][1]:='';
config^.subscreen[i][2]:='þ ------------------- ';config^.subfile[i][2]:='';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=13;{SECRET}
config^.subscreen[i][1]:='þ Biskit''s           ';config^.subfile[i][1]:='SECRET01.BIN';
config^.subscreen[i][2]:='þ Stupid Lamers !@#   ';config^.subfile[i][2]:='SECRET02.BIN';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=14;{10}
config^.subscreen[i][1]:='þ Introduction        ';config^.subfile[i][1]:='CWS.BIN';
config^.subscreen[i][2]:='þ Scene Wide Couriers ';config^.subfile[i][2]:='REVCWS1.BIN';
config^.subscreen[i][3]:='þ Worlds Top Couriers ';config^.subfile[i][3]:='REVCWS2.BIN';
config^.subscreen[i][4]:='þ Top Courier Groups  ';config^.subfile[i][4]:='REVCWS3.BIN';
config^.subscreen[i][5]:='þ World''s Top Sites   ';config^.subfile[i][5]:='REVCWS4.BIN';
config^.subscreen[i][6]:='þ CWS SCENE NEWS      ';config^.subfile[i][6]:='NEWS.BIN';
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
i:=15;{Game Reviews}
config^.subscreen[i][1]:='þ ------------------- ';config^.subfile[i][1]:='';
config^.subscreen[i][2]:='þ ------------------- ';config^.subfile[i][2]:='';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=16;{Stupid}
config^.subscreen[i][1]:='þ ------------------- ';config^.subfile[i][1]:='';
config^.subscreen[i][2]:='þ ------------------- ';config^.subfile[i][2]:='';
config^.subscreen[i][3]:='þ ------------------- ';config^.subfile[i][3]:='';
config^.subscreen[i][4]:='þ ------------------- ';config^.subfile[i][4]:='';
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
i:=17;{jobs}
config^.subscreen[i][1]:='þ ----Relativity ---- ';
config^.subscreen[i][2]:='þ ------------------- ';
config^.subscreen[i][3]:='þ ---- Positions ---- ';
config^.subscreen[i][4]:='þ ------------------- ';
config^.subscreen[i][5]:='þ 1) Ansi Artists     ';
config^.subscreen[i][6]:='þ 2) Vga Artists      ';
config^.subscreen[i][7]:='þ 3) Bot Masters      ';
config^.subscreen[i][8]:='þ 4) Writers          ';
config^.subscreen[i][9]:='þ 5) More Writers     ';
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