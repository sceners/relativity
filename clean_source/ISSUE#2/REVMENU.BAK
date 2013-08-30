unit revmenu;
interface
uses revconst;

Procedure DoExtractFileFromDat(str:string);
Procedure phaze_two(str,str2:st12; x,y:integer);
Procedure ShowArticle(str,str2:st12; x,y:integer);
Function EmptySub(sub:subscr):boolean;
procedure StartMainMenuPhase; {Main}
procedure StopMainMenuPhase;

implementation
uses revdat,revgfx,revansi,revsmth,revspec,dos,crt,revhelp,revnfo,revmus,revgif,
     arkanoid;
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
               str:=str+k;
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



Procedure DoExtractFileFromDat(str:string);
begin
ExtractFileFromDat(str);
end;

Procedure phaze_two(str,str2:st12; x,y:integer);
var dep:integer;
    f:file;
    numread:integer;
begin
     FadedownRGBScreen;
     Reset80x25VideoScreen;
     SmoothScroll(str,x,y);
     DisplayaNsi(str2);
     hidecursor;
end;

Procedure ShowArticle(str,str2:st12; x,y:integer);
begin
     DoExtractFileFromDat(str);
     phaze_two(str,str2,x,y);
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

procedure StartMainMenuPhase; {Main}

procedure StartCurrentMenu(e:integer);
var c,b,P,code : Integer;
    k          : Char;
    str        : string;

label stop,damn;
begin
k:=#22;
c:=1;
{randomize;}
write_bar_ways(random(3)+2,e,c,topics);
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
               notavhelp:=notavhelp+[3];
               help(subfile[e][c],e,c);
               hidecursor;
               Displayansi(defmenufile);
               write_bar(e,c,topics);
          end;
    #72 : begin dec(c); end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=c+9;
          end;
    #80 : begin inc(c); end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          end;
    #27,'q' : begin write_bar(e,0,topics); StartMainMenuPhase; end;
    #13 : Begin
        if c in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17] then
        begin
          if subfile[e][c]<>'' then
          begin
               tag[e]:=tag[e]+[c];
               ShowArticle(subfile[e][c],DEFMENUFILE,e,c);
               write_bar(e,c,topics);
               k:=readkey;
          end;
        end;
        if c=18 then
        begin
           write_bar(e,0,topics);
           StartMainMenuPhase;
        end;
        end;
  end;
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(e,c,topics);
  until true=false; {never....hehe}
end;


var c,b,P,code : Integer;
score:longint;
    k          : Char;
    str        : string;
    nav        : na;
    pass       : string;
label stop,damn;
begin
c:=cc;
k:=#22;
write_bar_way2(topics+1,c,topics);
nav:=notavarr[topics+1];
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
               notavhelp:=notavhelp+[3];
               cc:=c;
               help(subfile[1][c],topics+1,c);
               hidecursor;
               Displayansi(defmenufile);
               write_bar(topics+1,c,topics);
          end;
    #72 : begin
                dec(c);
          while c in nav do
             begin
                  c:=c-1;
             end;
          end;                            {up}
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
    #27,'q' : begin FadedownRGBScreen; StopMainMenuPhase; end;
    #13 : Begin
          if c=12 then
          begin
          pass:='';
          Reset80x25VideoScreen;
          hidecursor;
          extractfilefromdat(psmenufile);
          Displayansi(psmenufile);
          showcursor;
          getstr(49,13,pass,17);
          hidecursor;
          deletedatfile(psmenufile);
          if pass=password then
          begin
                    extractfilefromdat(midgif);
                    displaygif(midgif);
                    deletedatfile(midgif);
                    Reset80x25VideoScreen;
                    hidecursor;
                    Displayansi(defmenufile);
                    cc:=c;
                    write_bar(topics+1,0,topics);
                    tag[19]:=tag[19]+[c];
                    StartCurrentMenu(c);

          end
          else
          begin
          Displayansi(defmenufile);
          end;
          end;
          if c=11 then
          begin
               Extractfilefromdat('PATTERN0.BTM');
               Extractfilefromdat('PATTERN1.BTM');
               Extractfilefromdat('PATTERN2.BTM');
               Extractfilefromdat('PATTERN3.BTM');
               Extractfilefromdat('PATTERN4.BTM');
               Extractfilefromdat('PLAYGR.BTM');
{               Extractfilefromdat('PRESENT.BTM');}
               Extractfilefromdat('EXPLODE.BTM');
               Extractfilefromdat('NEWVAUS.BTM');
               Extractfilefromdat('SOUNDFX.BTM');
               Extractfilefromdat('SHINEWAL.BTM');
               Extractfilefromdat('MINIVAUS.BTM');
               Extractfilefromdat('LEVELSEL.BTM');
               Extractfilefromdat('DROPS.BTM');
               Extractfilefromdat('VAUS.BTM');
               Extractfilefromdat('LASERS.BTM');
               Extractfilefromdat('ENLARGED.BTM');
               Extractfilefromdat('FIRE.BTM');
               Extractfilefromdat('SCRFLUX.BTM');
               Extractfilefromdat('WHWALLS.DTA');
               startgame(score);
          end;
          if c=9 then
          begin
               InfoMenu;
          end;
          if c in [1,2,3,4,5,6,7,8,{9,}10,11{,12},13,14,15,16,17] then
          begin
          if not emptysub(subscreen[c]) then
          begin
               cc:=c;
               write_bar(topics+1,0,topics);
               tag[19]:=tag[19]+[c];
               StartCurrentMenu(c);
          end;
             k:=#22;
          end;
          if c= 18 then
             StopMainMenuPhase;
          end;
  end;
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(topics+1,c,topics);
  until true=false; {never....hehe}
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Stops The Menu Phase And Begins The Ending Phase. (FIN) *)
(****************************************************************************)

procedure StopMainMenuPhase;
var k:char;
begin
  deletedatfile(DEFMENUFILE);
  if curmus<>musdef then
  begin
       StopMusic(music[curmus,1],music[curmus,2]);
       PlayMusic(music[musdef,1],music[musdef,2]);
  end;
  Reset80x25VideoScreen;
  ExtractFileFromDat(closinggif);
  DisplayGIF(closinggif);
  DeleteDatFile(closinggif);
  Reset80x25VideoScreen;
  TextColor(7);
  TextBackground(black);
  hidecursor;
  extractfilefromdat(endmenufile);
  Displayansi(endmenufile);
  k:=readkey;
  deletedatfile(endmenufile);
  clrscr;
  PrintEndingPhase;
  showcursor;
  Reset80x25VideoScreen;
  StopMusic(music[musdef,1],music[musdef,2]);
  Halt;
end;

end.