{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
unit revhelp;

interface
uses  Crt,Dos,RevDat,RevGfx,RevAnsi,
      revsmth,revconst,revmus,revfnt,revtech;

function Getstr(x,y:integer; var str:string; length1:integer):boolean;
Procedure CheckMusic(var cur:integer);
procedure write_help(b,t:integer);
Procedure help(f:string; x,y:integer; adf:boolean; buffer:bu; maxline:longint);

implementation
uses revrad,revboom,revmem;
const xpos=3;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words -  eRR...                                                 *)
(****************************************************************************)

function Getstr(x,y:integer; var str:string; length1:integer):boolean;
var i,j:integer;
    k:char;
    label finet,fin,finer,over,start;
begin
getstr:=false;
start:
textbackground(black);textcolor(darkgray);
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
              write('_');
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

Procedure CheckMusic(var cur:integer);
begin
if cur<1 then cur:=config^.lastmus;
if cur>config^.lastmus then cur:=1;
end;

procedure write_help(b,t:integer);
var
   i,a,x,y:integer;
   str:string;
begin
textcolor(black);
textbackground(lightblue);
x:=16-xpos;
y:=20;
for a := 1 to maxhelp do
  begin
    if (b=a) then
    begin
         if a in [1,2,3,4,5,6,7,8,9] then
         begin
              gotoxy(x-1,y);
              str:=config^.help_menu[a];
              textbackground(blue);
              write(' ');
              textcolor(lightblue);
              write(str[1]);
              write(str[2]);
              for i:= 3 to length(str) do
                  write(str[i]);
         end;
         if a in config^.notavhelp then
         begin
         gotoxy(x-1,y);
         str:=config^.help_menu[a];
         textbackground(blue);
         write(' ');
         textcolor(darkgray);
         write(str[1]);
         write(str[2]);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
    end
    else
    begin
         if a in [1,2,3,4,5,6,7,8,9] then
         begin
         gotoxy(x-1,y);
         str:=config^.help_menu[a];
         textbackground(black);
         write(' ');
         textcolor(blue);
         write(str[1]);
         textcolor(lightblue);
         write(str[2]);
         textcolor(lightblue);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
         if a in config^.notavhelp then
         begin
         gotoxy(x-1,y);
         str:=config^.help_menu[a];
         textbackground(black);
         write(' ');
         textcolor(darkgray);
         write(str[1]);
         write(str[2]);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
    end;
    inc(y);
  end;
end;

Procedure help(f:string; x,y:integer; adf:boolean; buffer:bu; maxline:longint);
const defstr='ş ------------ ';
var k:char;
    s,s2,i,c:integer;
    str:string;
    flag:boolean;
    label stop,damn,fin,aftercd,cdafter1,aftercd2;

procedure InitHelp;
var i:integer;
    tstr:string;
begin
{- init mus write - }
{textbackground(lightblue);textcolor(darkgray);
gotoxy(41-xpos,17);write('[');gotoxy(54-xpos,17);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42-xpos,17);write('            ');
gotoxy(42+((12-length(config^.music[config^.curmus,1]))div 2)-xpos,17);
write(config^.music[config^.curmus,1]);
textbackground(lightblue);textcolor(darkgray);
gotoxy(56-xpos,17);write('[');gotoxy(71-xpos,17);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(57-xpos,17);write('             ');
gotoxy(57+((15-length(config^.music[config^.curmus,3]))div 2)-xpos,17);
write(config^.music[config^.curmus,3]);
{- init volume -}
{textbackground(lightblue);textcolor(darkgray);
gotoxy(41-xpos,18);write('[');gotoxy(54-xpos,18);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42-xpos,18);write('____________');}
{- init brightness -}
textbackground(lightblue);textcolor(darkgray);
gotoxy(41-xpos-9,22);write('[');gotoxy(63-xpos-9,22);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42-xpos-9,22);write('                     ');
end;

Procedure InitFont(num:integer);
begin
textbackground(lightblue);textcolor(darkgray);
gotoxy(41-xpos,20);write('[');gotoxy(54-xpos,20);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42-xpos,20);write('            ');
gotoxy(42+((12-length(config^.font[config^.curfnt])) div 2)-xpos,20);
write(config^.font[config^.curfnt]);
end;

Procedure initsave(var str:string);
var tstr:string;
    i:integer;
begin
tstr:=str;
delete(tstr,length(tstr)-3,4);
tstr:=tstr+'.TXT';
textbackground(lightblue);textcolor(darkgray);
gotoxy(41-xpos,21);write('[');gotoxy(54-xpos,21);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42-xpos,21);write(tstr);
for i:= 1 to 12-length(tstr) do
    write('_');
str:=tstr;
end;

Procedure SaveFile(out:string);
var output:text;
    j,i,lin:longint;
    numread:word;
begin
     assign(output,out);
     rewrite(output);
     for i:= 1 to (maxline div 160) do
     begin
          for j:= 1 to 159 do
              if ((j mod 2) = 1) then
                 write(output,chr(buffer^[(160*i)-(160-j)]));
           writeln(output,chr(buffer^[(160*i)-1]));
     end;
close(output);
hidecursor;
textbackground(lightblue);textcolor(darkgray);
{gotoxy(56-xpos,19);write('[');gotoxy(67-xpos,19);write(']');}
textbackground(black);textcolor(lightgreen);
gotoxy(29,21);write('Saved ...');
{---------------------------}
delay(1000);
{---------------------------}
textbackground(black);textcolor(black);
gotoxy(29,21);write('         ');
end;

Procedure changebrightness;
var j,i:integer;
begin
  for j:= 1 to 15 do
  begin
  SetPal(j,config^.scr[j,1],config^.scr[j,2],config^.scr[j,3]);
  end;
  textbackground(black);textcolor(darkgray);
  gotoxy(42-xpos-9,22);write('_____________________');
  gotoxy(42-xpos-9,22);
  for i:= 1 to brightness do
  write('Û');
end;

Procedure Mem;
var havexms,haveems:boolean;
begin
textcolor(lightblue);
gotoxy(55,20);writE('Mem : [',GetMainMemory,']');
gotoxy(55,21);write('Xms : [');
CheckXMSMemory(HaveXms);write(havexms,']');
gotoxy(55,22);write('Ems : [');
CheckEMSMemory(HaveEms);write(haveems,']');
end;

label helpstart;

begin
c:=1;
FadedownRGBScreen;
Reset80x25VideoScreen;
HideCursor;

Helpstart:

extractfilefromdat(config^.hpmenufile);
Displayansi(config^.HPmenufile);
deletedatfile(config^.hpmenufile);
k:=#22;
write_help(c,topics);
{------------------------}
inithelp;
initfont(config^.curfnt);
changebrightness;
{------------------------}
if x<>19 then
begin
     str:=config^.subfile[x][y];
     initsave(str);
end;
mem;
{------------------------}
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #60 : begin
          if not boom1 then
          f2_help;
          goto helpstart;
          end;
    #72 : begin
          dec(c);
          while c in config^.notavhelp do
             begin
                  c:=c-1;
             end;
          if c<1 then c:=maxhelp;
          end;                            {up}
    #80 : begin
               inc(c);
          while c in config^.notavhelp do
             begin
                  c:=c+1;
             end;
             if c>maxhelp then c:=1;
          end;
    #27,'q' : begin goto fin; end;
    #77 : Begin
          if c = 1 then
          begin
          inc(config^.curfnt);
          if config^.curfnt>config^.lastfnt then
             config^.curfnt:=1;
          textbackground(lightblue);textcolor(darkgray);
          gotoxy(41-xpos,20);write('[');gotoxy(54-xpos,20);write(']');
          textbackground(black);textcolor(darkgray);
          gotoxy(42-xpos,20);write('            ');
          gotoxy(42+((12-length(config^.font[config^.curfnt])) div 2)-xpos,20);
          write(config^.font[config^.curfnt]);
          fontload(config^.font[config^.curfnt]);
          end;
          if c = 3 then
          begin
          flag:=false;
          for s:= 0 to 15 do
          begin
               if (config^.scr[s,1]=63) and (config^.scr[s,2]=63) and (config^.scr[s,3]=63) then
                  flag :=true;
          end;
          if flag=false then
          begin
               for s:= 0 to 15 do
               begin
                    inc(config^.scr[s,1],1);
                    inc(config^.scr[s,2],1);
                    inc(config^.scr[s,3],1);
               end;
               inc(brightness);
          end;
          changebrightness;
          end;
      end;
    #75 : begin
          if c = 1 then
          begin
          dec(config^.curfnt);
          if config^.curfnt<1 then
             config^.curfnt:=config^.lastfnt;
          textbackground(lightblue);textcolor(darkgray);
          gotoxy(41-xpos,20);write('[');gotoxy(54-xpos,20);write(']');
          textbackground(black);textcolor(darkgray);
          gotoxy(42-xpos,20);write('            ');
          gotoxy(42+((12-length(config^.font[config^.curfnt])) div 2)-xpos,20);write(config^.font[config^.curfnt]);
          fontload(config^.font[config^.curfnt]);
          end;
          if c = 3 then
          begin
          flag:=false;
          for s:= 0 to 15 do
          begin
          if (config^.scr[s,1]=0) or (config^.scr[s,2]=0) or (config^.scr[s,3]=0) then
          flag:=true;
          end;
          if flag=false then
          begin
          for s:= 0 to 15 do
          begin
               dec(config^.scr[s,1],1);
               dec(config^.scr[s,2],1);
               dec(config^.scr[s,3],1);
          end;
               dec(brightness);
          end;
          changebrightness;
          end;
{          if c = 4 then
          begin
               dec(cdactpos,1);
               if cdactpos<1 then cdactpos:=8;
               if cdactpos=2 then cdactpos:=1;
               if cdactpos=7 then cdactpos:=6;
               InitCdRom;
          end;}
          end;
    #13 : begin
{               if (c=1) then
               begin
               if adlib then
               begin
                    if config^.muson=true then
                    begin
                       config^.muson:=false;
                       stoprad;
                    end
                    else
                    begin
                        config^.muson:=true;
                        PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                    end;
                    InitOnoffMusic;
                    if playing then
                    begin
                    stopaudio;
                    playing:=false;
                    end;
               end;
               end;  }
               if (c=2) then
               begin
{------------------------}
{                    if x<>19 then
                       begin
                            str:=config^.subfile[x][y];
                            initsave(str);
                       end;
{------------------------}
               showcursor;
               if Getstr(42-xpos,21,str,12) then
               savefile(str);
               hidecursor;
               end;
{               if c=4 then
               begin
               if cd then
               begin
                setup;
                    if cdactpos = 1 then
                    begin
                         if pause then
                         begin
                              stopaudio;
                              pause:=false;
                         end;
                         dec(cdsongpos);
                         if cdsongpos<1 then cdsongpos:=endtrack;
                         if playing then
                         begin
                         stopaudio;
                         Play_Audio(TrackInfo[cdsongpos]^.StartPoint,
                         TrackInfo[cdsongpos]^.EndPoint);
                         end;
                         cd:=true;
                    end;
                    if cdactpos = 3 then
                    begin
                         if config^.muson=true then
                         begin
                              stoprad;
                              config^.muson:=false;
                              InitOnoffMusic;
                         end;
                         if not playing and not pause then
                         begin
                              Play_Audio(TrackInfo[cdsongpos]^.StartPoint,
                              TrackInfo[cdsongpos]^.EndPoint);
                              goto cdafter1;
                         end;
                         if pause then
                         begin
                              resume_play;
                              pause:=false;
                              goto cdafter1;
                         end;
                         if playing then
                         begin
                              Play_Audio(TrackInfo[cdsongpos]^.StartPoint,
                              TrackInfo[cdsongpos]^.EndPoint);
                         end;
                         cdafter1:
                    end;
                    if cdactpos = 4 then
                    begin
                         if playing then stopaudio;
                         if pause then pause:=false;
                         if dooropen then
                            closetray;
                         if not dooropen then
                            eject;
                    end;
                    if cdactpos = 5 then
                    begin
                         if playing then
                         begin
                              Pause_Audio;
                              pause:=true;
                              goto aftercd;
                         end;
                         if pause then
                         begin
                              resume_play;
                              pause:=false;
                         end;
                         aftercd:
                    end;
                    if cdactpos = 6 then
                    begin
                         if playing then StopAudio;
                         if pause then resume_play;
                         playing:=false;
                         cd:=true;
                    end;
                    if cdactpos = 8 then
                    begin
                         if pause then
                         begin
                              stopaudio;
                              pause:=false;
                         end;
                         inc(cdsongpos);
                         if cdsongpos>endtrack then cdsongpos:=1;
                         if playing then
                         begin
                         stopaudio;
                         Play_Audio(TrackInfo[cdsongpos]^.StartPoint,
                         TrackInfo[cdsongpos]^.EndPoint);
                         end;
                         cd:=true;
                    end;
               cd:=true;
               initcdrom;
               end;
               end;}
               if c=4 then
               begin
                    goto fin;
               end;
           end;
      end;
  if c = 8 then
     c := 1;
  if c = 0 then
     c := 7;
  write_help(c,topics);
  until true=false; {never....hehe}
fin:
FadedownRGBScreen;
Reset80x25VideoScreen;
end;

end.