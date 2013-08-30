unit revmenu;
interface
uses revconst;

Procedure ShowArticle(str,str2:st12; x,y:integer);
Function EmptySub(sub:subscr):boolean;
procedure StartMainMenuPhase; {Main}
procedure StopMainMenuPhase;

implementation
uses revdat,revgfx,revansi,revsmth,revspec,dos,crt,revhelp,revmus,revgif,
     revfnt,revtech,revpoint,revboom,revgame,revinit,arkanoid,
     revlong,cdrom,revmouse,revrad,revvoc,revdisc,furyfigh,revbin;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Starts The Main Menu Phase And Controls All Sub Menus.  *)
(****************************************************************************)

function Getstr(x,y:integer; var str:string; length1:integer):boolean;
var i,j:integer;
    k:char;
    label finet,fin,finer,over,start;
begin
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
end;

Procedure ShowArticle(str,str2:st12; x,y:integer);
var size:word;
begin
     extractpointerfromdat(str,article,size);
     FadedownRGBScreen;
     Reset80x25VideoScreen;
     if smooth = 1 then
     SmoothScroll(str,x,y,size,false);
     if smooth = 2 then
     SmoothScroll(str,x,y,size,true);
     if smooth = 3 then
     AnsiScroll(str,x,y,size);
     chbrght;
     Displayansipointer(subm);
     hidecursor;
end;

Function EmptySub(sub:subscr):boolean;
var i:integer;
begin
     EmptySub:=True;
     for i:= 1 to topics do
     begin
          if sub[i]<>'' then
           EmptySub:=false;
     end;
end;

Procedure Upstr(var str:string);
var i:integer;
begin
     For i:= 1 to length(str) do
          str[i]:=upcase(str[i]);
end;

Function Gif(Sec:st22):boolean;
var str:string;
begin
     gif:=false;
     str:=sec[length(sec)-2]+sec[length(sec)-1]+sec[length(sec)-1];
     upstr(str);
     if str='GIF' then
        gif:=true;
end;

Function Bin(Sec:st22):boolean;
var str:string;
begin
     bin:=false;
     str:=sec[length(sec)-2]+sec[length(sec)-1]+sec[length(sec)-1];
     upstr(str);
     if str='BIN' then
        bin:=true;
end;

Function Sub(Sec:st22):boolean;
var str:string;
begin
     sub:=false;
     str:=sec[length(sec)-2]+sec[length(sec)-1]+sec[length(sec)-1];
     upstr(str);
     if str='' then
        sub:=true;
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
          StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
          config^.curmus:=random(config^.lastmus)+1;
          if config^.curmus > 21 then  config^.curmus:=21;
          if config^.curmus < 1 then  config^.curmus:=1;
          PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
     end;

{     if config^.menudisc[e] = true then
     begin
          if (smooth = 2)  then
          begin
             if (not disclaimer(config^.disc)) then
                StartMainMenuPhase;
          end;
          if (smooth = 3) or (smooth=1) then
          begin
               if not disclaimer2(config^.disc) then
                  StartMainMenuPhase;
          end;
     end;

                                       }
{        IF E = 12 THEN
        BEGIN
             extractpointerfromdat('I5.BIN',tempbin,size);
             Reset80x25VideoScreen;
             hidecursor;
             Displayansipointer(tempbin);
             deletedatfile('I5.BIN');
             ch:=readkey;
             Reset80x25VideoScreen;
             hidecursor;
        END;            }

my:=config^.y2;
mx:=config^.x2;
k:=#22;
c:=1;
nav:=config^.notavarr[e];
Displayansipointer(subm);
chbrght;
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
               config^.notavhelp:=config^.notavhelp+[saveastag];
               help(config^.subfile[e][c],e,c,false,slutbuf,slut);
               hidecursor;
               chbrght;
               DisplayansiPointer(subm);
               write_bar(e,c,topics);
               help1:=false;
          end;
    #60 : begin
          help_2:
               boom1:=true;
               f2_help;
               hidecursor;
               chbrght;
               DisplayansiPointer(subm);
               boom1:=false;
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
                 StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                 config^.curmus:=musdef;
                 PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
            end;

              write_bar(e,0,topics);

{        IF E = 12 THEN
        BEGIN
             extractpointerfromdat('I52.BIN',tempbin,size);
             Reset80x25VideoScreen;
             hidecursor;
             Displayansipointer(tempbin);
             deletedatfile('I52.BIN');
             ch:=readkey;
             Reset80x25VideoScreen;
             hidecursor;
        END;           }
              StartMainMenuPhase;
              end;
    #13 : Begin
        mo:
        inc(ok);if ok>3 then ok:=1;
        loadandplay(ok+15);
        if (e=10) and (c in [1,2,3,4,5,6,7,8,9,10,11,12,13]) and vga_ then
        begin{arts gif}
             extractfilefromdat(config^.subfile[e][c]);
             config^.tag[e]:=config^.tag[e]+[c];
             Reset80x25VideoScreen;
             hidecursor;
             DisplayGIF(config^.subfile[e][c]);
             DeleteDatFile(config^.subfile[e][c]);
             Reset80x25VideoScreen;
             hidecursor;
             Displayansipointer(subm);
             loadvoc(1);
        GOTO AFTER;
        end;
       if (c in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]) and (e<>10) then
        begin
          if config^.subfile[e][c]<>'' then
          begin
               config^.tag[e]:=config^.tag[e]+[c];
               ShowArticle(config^.subfile[e][c],config^.SecMENUFILE,e,c);
               write_bar(e,c,topics);
               if keypressed then
               readkey;
          end;
        end;
        if c=18 then
        begin
         die:
            if adlib and (mustype=1) and rand then
            begin
                 StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                 config^.curmus:=musdef;
                 PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
            end;

           write_bar(e,0,topics);

{        IF E = 12 THEN
        BEGIN
             extractpointerfromdat('I52.BIN',tempbin,size);
             Reset80x25VideoScreen;
             hidecursor;
             Displayansipointer(tempbin);
             deletedatfile('I52.BIN');
             ch:=readkey;
             Reset80x25VideoScreen;
             hidecursor;
        END;            }

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
chbrght;
if start then begin if voc then begin loadandplay(20);delay(1000);loadandplay(21);delay(800); start:=false; end; end;
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
               chbrght;
               Displayansipointer(mainm);
               write_bar(topics+1,c,topics);
               help1:=false;
               loadvoc(3)
          end;
    #60 : begin
        help_2:
               boom1:=true;
               f2_help;
               hidecursor;
               chbrght;
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
               inc(ok);if ok>3 then ok:=1;
               loadandplay(ok+15);
          mo:
{          if c = 16 then
          begin
               Reset80x25VideoScreen;
               hidecursor;
               chbrght;
               extractfilefromdat('APP.BIN');
               ShowArticle('APP.BIN',config^.defMENUFILE,c,1);
               DELETEDATFILE ('APP.BIN');
               config^.tag[19]:=config^.tag[19]+[c];
               write_bar(topics+1,c,topics);
          end;}
          if c=13 then
          begin
          pass:='';
          Reset80x25VideoScreen;
          hidecursor;
          chbrght;
          Displayansipointer(passm);
          showcursor;
          getstr(48,12,pass,20);
          hidecursor;
          if pass=config^.password then
          begin
               if vga_ and (config^.vg[c]<>'' )then
               begin
                    extractfilefromdat(config^.vg[c]);
                    displaygif(config^.vg[c]);
                    deletedatfile(config^.vg[c]);
               end;

                    Reset80x25VideoScreen;
                    hidecursor;
                    chbrght;
{                    Displayansi(secmenufile);}
                    cc:=c;
{                    write_bar(topics+1,0,topics);}
                    config^.tag[19]:=config^.tag[19]+[c];
                    StartCurrentMenu(c);
          end
          else
          begin
               Displayansipointer(mainm);
          end;
          end;
          if c=11 then
          begin
               if vga_ then
               begin
                    ExtractFileFromDat('NEWGAME.GIF');
                    DisplayGIF('NEWGAME.GIF');
                    DeleteDatFile('NEWGAME.GIF');
               end;
               if mouse then
               begin
                  config^.tag[19]:=config^.tag[19]+[c];
                  extractgamefiles;
                  startgame(score);
               end;
          end;
          if not emptysub(config^.subscreen[c]) and (c<>13) then
          begin
          IF (config^.vg[c]<>'') and vga_ then
               begin
                  Reset80x25VideoScreen;
                  hidecursor;
                  ExtractFileFromDat(config^.vg[c]);
                  DisplayGIF(config^.vg[c]);
                  DeleteDatFile(config^.vg[c]);
                  Reset80x25VideoScreen;
                  hidecursor;
               end;
               cc:=c;
               config^.tag[19]:=config^.tag[19]+[c];
               StartCurrentMenu(c);
          end;

          if keypressed then
            readkey;
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

procedure StopMainMenuPhase;
var k:char;
    size:word;
begin
  Reset80x25VideoScreen;
  hidecursor;
  if mouse then
  begin
       UninstallMouse;
       SetMouseCursor(false);
  end;
  if playing then
  stopcd(curcddrv);
  if (config^.curmus<>musdef) and adlib then
  begin
       StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
       PlayMusic(config^.music[musdef,1],config^.music[musdef,2]);
  end;
  if (config^.closinggif<>'') and vga_ then
  begin
       ExtractFileFromDat(config^.closinggif);
       DisplayGIF(config^.closinggif);
       DeleteDatFile(config^.closinggif);
  end;
  if (config^.closinggif2<>'') and vga_ then
  begin
       ExtractFileFromDat(config^.closinggif2);
       DisplayGIF(config^.closinggif2);
       DeleteDatFile(config^.closinggif2);
  end;
{  if (config^.closinggif3<>'') and vga_ then
  begin
       ExtractFileFromDat(config^.closinggif3);
       DisplayGIF(config^.closinggif3);
       DeleteDatFile(config^.closinggif3);
  end;                                    }
  Reset80x25VideoScreen;
  TextColor(7);
  TextBackground(black);
  hidecursor;
  extractpointerfromdat(config^.endmenufile2,article,size);
  long(config^.endmenufile2,2,size);
  extractpointerfromdat(config^.endmenufile,tempbin,size);
  Displayansipointer(tempbin);
  readkey;
  k:=readkey;
{  PrintEndingPhase;}
{  Reset80x25VideoScreen;}
  if adlib then
     StopMusic(config^.music[musdef,1],config^.music[musdef,2]);
  fontloadpointer(config^.font[17],fontp);
  gotoxy(1,25);
  writeln;
  showcursor;
  killconfigpointer;
  KillPointers;
  Halt;
end;

end.