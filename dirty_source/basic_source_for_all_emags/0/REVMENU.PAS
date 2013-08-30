unit revmenu;
interface
uses revconst;

Procedure add_not_avail(x,y:byte);
Procedure add_tag(x,y:byte);
procedure Kill_emag(err:byte);
Procedure ShowArticle(str:st12; x,y:integer; p:pointer);
procedure StartMainMenuPhase; {Main}
procedure StopMainMenuPhase;

implementation
uses revdat,revgfx,revansi,revsmth,revspec,dos,crt,revhelp,revmus,revgif,
     revfnt,revtech,revpoint,revboom,revgame,revinit,revstr,revdsm,
     revlong,cdrom,revmouse,revrad,revvoc,revdisc,revbin,arkanoid,furyfigh;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Starts The Main Menu Phase And Controls All Sub Menus.  *)
(****************************************************************************)

function Getstr(x,y:integer; var str:string; length1:integer):boolean;
var i,j:integer;
    k:char;
    label finet,fin,finer,over,start;
begin
showcursor;
getstr:=false;
start:
textbackground(black);textcolor(cyan);
gotoxy(x,y);
if str<>'' then
begin
     write(str);
end;
k:=#22;
while k <> #13 do
begin
     over:
     k:=readkey;
     if k=#0 then goto over;
     if k=#27 then goto finet;
     if k=#13 then goto finer;
     if k=#8 then
     begin
          delete(str,length(str),1);
          gotoxy(x,y);
          for j:= 1 to length1 do
              write('.');
          gotoxy(x,y);write(str);
     end
     else
     begin
          if length(str)<length1 then
          begin
               str:=str+upcase(k);
               gotoxy(x,y);write(str);
          end;
     end;
end;
finer:
getstr:=true;
fin:
if str='' then goto start;
finet:
hidecursor;
end;

Procedure ShowArticle(str:st12; x,y:integer; p:pointer);
var size:word;
begin
     if fileindat(str,article_file) then
     begin
          extractpointerfromdat(str,article_file,article,size);
          add_tag(x,y);
          FadedownRGBScreen;
          Reset80x25VideoScreen;
          if smooth = 1 then
             SmoothScroll(str,x,y,size,false);
          if smooth = 2 then
             SmoothScroll(str,x,y,size,true);
          if smooth = 3 then
             AnsiScroll(str,x,y,size);
          Displayansipointer(p);
     end;
end;

Procedure MouseOption(x,y,r,c:byte; var option:integer);
var i,j:byte;
begin
option:=0;
j:=0;
     for i:= 0 to 17 do
     begin
          if r = y+j then
          begin
             if (c>=x-1) and (c<=x+21) then
                if (i>=0) and (i<=8) then
                   option:=i+1;
             if (c>=x+22) and (c<=x+22+22) then
                if (i>=9) and (i<=17) then
                   option:=i+1;
          end;
          inc(j);
          if j>8 then j:=0;
     end;
end;

procedure StartMainMenuPhase; {Main}

procedure StartCurrentMenu(e:integer);
var option,c,b,P,code : Integer;
    k          : Char;
    str        : string;
    nav        : na;
    ch          : char;
    size:word;
    s:integer;

label stop,damn,mo,help_1,help_2,after,die;

begin
loadvoc(1);
menu:=2;
     if adlib and (mustype=1) and rand then
     begin
          randomize;
          StopMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
          config^.radcurmus:=random(config^.radlastmus)+1;
          if config^.radcurmus > 21 then  config^.radcurmus:=21;
          if config^.radcurmus < 1 then  config^.radcurmus:=1;
          PlayMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
     end;

my:=config^.y2;
mx:=config^.x2;
k:=#22;
c:=1;
nav:=config^.notavarr[e];
Displayansipointer(subm);
chbrght(palette);
write_bar_ways(random(3)+2,e,c,topics);

repeat
      if mouse then
      begin
           GetMouseInfo(M);
           if (M.ButtonClicked = leftButton) then
           begin
                while not buttonreleased do
                begin
                end;
                if ((m.row = 1) and (m.column = 1)) or ((m.row = 25) and (m.column = 1)) then
                goto help_1;
                if ((m.row = 1) and (m.column = 80)) or ((m.row = 25) and (m.column = 80))  then
                goto help_2;
                MouseOption(mx,my,M.row,M.column,c);
                if c<> 0 then
                begin
                     write_bar(e,c,topics);
                     delay(100);
                     goto mo;
                end;
           end;
           if (M.ButtonClicked = rightButton) then
           begin
                 while not buttonreleased do
                 begin
                 end;
                 goto die;
           end;
      end;
  IF KEYPRESSED THEN
  BEGIN
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
          help_1:
               help1:=true;
               help(config^.subfile[e][c],e,0,false,slutbuf,slut);
               DisplayansiPointer(subm);
               help1:=false;
               loadvoc(1);
          end;
    #60 : begin
          help_2:
               boom1:=true;
               f2_help(e);
               hidecursor;
               chbrght(palette);
               DisplayansiPointer(subm);
               boom1:=false;
               loadvoc(1);
          end;
    #71 : c:=1;
    #79 : c:=18;
    #72 : begin
                dec(c);
          while c in nav do
             begin
                  c:=c-1;
             end;
          end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then              {pageup}
             c:=c+9;
          while c in nav do
             begin
                  c:=c+1;
             end;
          end;
    #80 : begin
               inc(c);
          while c in nav do
             begin
                  c:=c+1;
             end;
          end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          while c in nav  do
             begin
                  c:=c+1;
             end;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          while c in nav  do
             begin
                  c:=c-1;
             end;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          while c in nav  do
             begin
                  c:=c-1;
             end;
          end;
    #27 : begin
          Playkey(k);
          if adlib and (mustype=1) and rand  then
            begin
                 StopMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
                 config^.radcurmus:=config^.radmusdef;
                 PlayMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
            end;

              write_bar(e,0,topics);
              StartMainMenuPhase;
              end;
    #13 : Begin
        mo:
        inc(voc_ok);if voc_ok>3 then voc_ok:=1;
        loadandplay(voc_ok+15);

        if (pos('.GIF',upper_(config^.subfile[e][c]))>0) and (c<>18) then
        begin
             DisplayGIF(config^.subfile[e][c],gif_file,e,c);
             Reset80x25VideoScreen;
             Displayansipointer(subm);
        end
        else
            if (pos('.BIN',upper_(config^.subfile[e][c]))>0) and (c<>18) then
            begin
                 ShowArticle(config^.subfile[e][c],e,c,subm);
                 if keypressed then
                    readkey;
            end;

        if c=18 then
        begin
         die:
            if adlib and (mustype=1) and rand then
            begin
                 StopMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
                 config^.radcurmus:=config^.radmusdef;
                 PlayMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
            end;

           write_bar(e,0,topics);
           StartMainMenuPhase;
        end;

        loadvoc(1);
      end;
  end;
  after:
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(e,c,topics);
  playkey(k);
  if mouse then showmouse;
  end;
  until true=false; {never....hehe}
end;


var c,b,P,code : Integer;
score:longint;
    k          : Char;
    str        : string;
    nav        : na;
    pass       : string;
    option     : byte;
    size:word;
label stop,damn,mo,help_1,help_2,die;

Begin
menu:=1;
my:=config^.y1;
mx:=config^.x1;
c:=cc;
k:=#22;
Displayansipointer(mainm);
write_bar_way2(topics+1,c,topics);
nav:=config^.notavarr[topics+1];
chbrght(palette);
if start then
begin
     if voc then
     begin
          radvolume(40);
          loadandplay(20);
          delay(1000);
          loadandplay(21);
          delay(800);
          start:=false;
          radvolume(config^.radvol);
     end;
end;
loadvoc(3);
repeat
      if mouse then
      begin
           GetMouseInfo(M);
           if (M.ButtonClicked = leftButton) then
           begin
                while not buttonreleased do
                begin
                end;
                if ((m.row = 1) and (m.column = 1)) or ((m.row = 25) and (m.column = 1)) then
                goto help_1;
                if ((m.row = 1) and (m.column = 80)) or ((m.row = 25) and (m.column = 80))  then
                goto help_2;
                MouseOption(mx,my,M.row,M.column,c);
                if c<> 0 then
                begin
                     write_bar(topics+1,c,topics);
                     delay(100);
                     goto mo;
                end;
           end;
           if (M.ButtonClicked = rightButton) then
           begin
                 while not buttonreleased do
                 begin
                 end;
                 goto die;
           end;
      end;
  IF KEYPRESSED THEN
  BEGIN
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
        help_1:
               help1:=true;
               config^.notavhelp:=config^.notavhelp+[saveastag];
               cc:=c;
               help(config^.subfile[1][c],topics+1,c,false,slutbuf,slut);
               hidecursor;
               chbrght(palette);
               Displayansipointer(mainm);
               write_bar(topics+1,c,topics);
               help1:=false;
               loadvoc(3)
          end;
    #60 : begin
        help_2:
               boom1:=true;
               f2_help(19);
               Displayansipointer(mainm);
               write_bar(topics+1,c,topics);
               boom1:=false;
               loadvoc(3)
    end;
    #71: c:=1;
    #79: c:=18;
    #72 : begin
                dec(c);
          while c in nav do
             begin
                  c:=c-1;
             end;
          end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then              {pageup}
             c:=c+9;
          while c in nav do
             begin
                  c:=c+1;
             end;
          end;
    #80 : begin
               inc(c);
          while c in nav do
             begin
                  c:=c+1;
             end;
          end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          while c in nav  do
             begin
                  c:=c+1;
             end;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          while c in nav  do
             begin
                  c:=c-1;
             end;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          while c in nav  do
             begin
                  c:=c-1;
             end;
          end;
    #27 : begin die: playkey(k);FadedownRGBScreen; StopMainMenuPhase; end;
    #13 : Begin
               inc(voc_ok);if voc_ok>3 then voc_ok:=1;
               loadandplay(voc_ok+15);
          mo:
             if c=config^.pass_section then
             begin
                  pass:='';
                  Reset80x25VideoScreen;
                  Displayansipointer(passm);
                  getstr(48,12,pass,20);
                  if pass=config^.password then
                  begin
                       displaygif(config^.subfile[19][c],gif_file,19,c);
                       Reset80x25VideoScreen;
                       cc:=c;
                       add_tag(19,c);
                       StartCurrentMenu(c);
                  end
                  else
                  begin
                       Displayansipointer(mainm);
                  end;
          end;

          if c=config^.game_section then
          begin
               DisplayGIF('NEWGAME.GIF',gif_file,0,0);
               if mouse then
               begin
                  cc:=c;
                  add_tag(19,c);
{                 deinitptrart;
                  Fury_Fighter;
                  initptrart;
                  {when using arkanoid on revinit .. remove free and get mem
                   of article !}
                  extractgamefiles;
                  startgame(score);
               end;
          end;

          if (pos('.GIF',upper_(config^.subfile[19][c]))>0) and (c<>18) then
          begin
               DisplayGIF(config^.subfile[19][c],gif_file,19,c);
               Reset80x25VideoScreen;
               Displayansipointer(mainm);
          end
          else
              if (pos('.BIN',upper_(config^.subfile[19][c]))>0) and (c<>18) then
              begin
                   ShowArticle(config^.subfile[19][c],19,c,mainm);
                   if keypressed then
                      readkey;
              end
              else
                  if (c<>config^.pass_section) and (c<>config^.game_section) and (c<>18) then
                  begin
                       cc:=c;
                       add_tag(19,c);
                       StartCurrentMenu(c);
                  end;

          if c= 18 then
          begin
               FadedownRGBScreen;
               StopMainMenuPhase;
          end;

          loadvoc(3);
        end;
  end;
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(topics+1,c,topics);
  playkey(k);
  if mouse then showmouse;
  end;
  until true=false; {never....hehe}
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Stops The Menu Phase And Begins The Ending Phase. (FIN) *)
(****************************************************************************)

Procedure add_not_avail(x,y:byte);
begin
   config^.notavarr[x]:=config^.notavarr[x]+[y];
end;

Procedure add_tag(x,y:byte);
begin
   config^.tag[x]:=config^.tag[x]+[y];
end;

procedure StopMainMenuPhase;
var k:char;
    size:word;
    i:word;
begin
  Reset80x25VideoScreen;
  if mouse then
  begin
       UninstallMouse;
       SetMouseCursor(false);
  end;
  if playing then
     stopcd(curcddrv);
  if (config^.radcurmus<>config^.radmusdef) and adlib and (radmuson = true) then
  begin
       StopMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
       PlayMusic(config^.music[config^.radmusdef,1],config^.music[config^.radmusdef,2]);
  end;
  if (config^.dsmcurmus<>config^.dsmmusdef) and adlib and (dsmmuson = true) then
  begin
       StopMusic(config^.music[config^.dsmcurmus,1],config^.music[config^.dsmcurmus,2]);
       PlayMusic(config^.music[config^.dsmmusdef,1],config^.music[config^.dsmmusdef,2]);
  end;
  for i:= 1 to outropics do
      DisplayGIF(config^.outro[i],gif_file,0,0);
  Reset80x25VideoScreen; {must after vga mode ..long is up next}
  if config^.endmenuflag then
  begin
     extractpointerfromdat(config^.endmenufile2,article_file,article,size);
     long(config^.endmenufile2,2,size);
  end;
  extractpointerfromdat(config^.endmenufile,article_file,tempbin,size);
  Displayansipointer(tempbin);
  textbackground(black);
  textcolor(lightgray);
  if keypressed then readkey;
  k:=readkey;
  chbrght(old_palette);
  if k=#0 then k:=readkey;
  if adlib and (radmuson = true) then
     StopMusic(config^.music[config^.radmusdef,1],config^.music[config^.radmusdef,2]);
  if adlib and (dsmmuson = true) then
     StopMusic(config^.music[config^.dsmmusdef,1],config^.music[config^.dsmmusdef,2]);
  fontloadpointer(config^.font[17],fontp);
  gotoxy(1,25);
  writeln;
  showcursor;
  DeleteDatFilesInDir(1);
  DeleteDatFilesInDir(2);
  killconfigpointer;
  KillPointers;
  Halt;
end;

procedure Kill_emag(err:byte);
var k:char;
    size:word;
begin
  TextColor(7);
  TextBackground(black);
  Reset80x25VideoScreen;
  gotoxy(1,25);
  if mem_err=err then {only for memory error, game mem}
  begin
       writeln(memavail,' Free Mem,');
       writeln('Emag Needs More : ',game_mem-memavail,', free mem !');
  end;
  Write('Error #',err,': ',error[err]);
  showcursor;
  if mouse then
  begin
       UninstallMouse;
       SetMouseCursor(false);
  end;
  if playing then
  stopcd(curcddrv);
  if adlib and (radmuson = true) then
  begin
       StopMusic(config^.music[config^.radcurmus,1],config^.music[config^.radcurmus,2]);
  end;
  if adlib and (dsmmuson = true) then
  begin
       StopMusic(config^.music[config^.dsmcurmus,1],config^.music[config^.dsmcurmus,2]);
  end;
  killdsm;
  killconfigpointer;
  Halt;
end;

end.