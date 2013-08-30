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
Procedure help(f:string; x,y:integer; adf:boolean; buffer:buf; maxline:longint);

implementation
uses revrad,revboom,revmem,revmouse,revvoc;

const helpmenx = 12;
      helpmeny = 15;
      fontloc = 15;
      smoothloc = 16;
      rodentloc = 17;
      randloc = 18;
      vocloc = 19;
      saveloc = 20;
      brightloc = 21;
      exitloc = 22;
      memloc = 17;
      xmsloc = 18;
      emsloc = 19;
      text_color = darkgray;
      tag = lightcyan;
      text_back = cyan;
      other = darkgray;
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
textbackground(black);textcolor(text_color);
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
textbackground(tag);
x:=helpmenx;
y:=helpmeny;
for a := 1 to maxhelp do
  begin
    if (b=a) then
    begin
         if a in [1,2,3,4,5,6,7,8,9] then
         begin
              gotoxy(x-1,y);
              str:=config^.help_menu[a];
              textbackground(text_back);
              write(' ');
              textcolor(tag);
              write(str[1]);
              write(str[2]);
              for i:= 3 to length(str) do
                  write(str[i]);
         end;
         if a in config^.notavhelp then
         begin
         gotoxy(x-1,y);
         str:=config^.help_menu[a];
         textbackground(text_back);
         write(' ');
         textcolor(text_color);
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
         textcolor(text_back);
         write(str[1]);
         textcolor(tag);
         write(str[2]);
         textcolor(tag);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
         if a in config^.notavhelp then
         begin
         gotoxy(x-1,y);
         str:=config^.help_menu[a];
         textbackground(black);
         write(' ');
         textcolor(text_color);
         write(str[1]);
         write(str[2]);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
    end;
    inc(y);
  end;
end;

Procedure help(f:string; x,y:integer; adf:boolean; buffer:buf; maxline:longint);
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
{- init brightness -}
textbackground(tag);textcolor(text_color);
gotoxy(41-12,brightloc);write('[');gotoxy(63-12,brightloc);write(']');
textbackground(black);textcolor(text_color);
gotoxy(42-12,brightloc);write('                     ');
end;

Procedure InitFont(num:integer);
begin

textbackground(tag);textcolor(text_color);
gotoxy(29,fontloc);write('[');gotoxy(43,fontloc);write(']');
textbackground(black);textcolor(text_color);
gotoxy(30,fontloc);;write('            ');
gotoxy(34+((12-length(config^.font[config^.curfnt])) div 2)-3,fontloc);
write(config^.font[config^.curfnt]);
end;

Procedure initsave(var str:string);
var tstr:string;
    i:integer;
begin
tstr:=str;
delete(tstr,length(tstr)-3,4);
tstr:=tstr+'.TXT';
textbackground(tag);textcolor(text_color);
gotoxy(29,saveloc);write('[');gotoxy(42,saveloc);write(']');
textbackground(black);textcolor(text_color);
gotoxy(30,saveloc);write(tstr);
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
textbackground(tag);textcolor(text_color);
textbackground(black);textcolor(other);
gotoxy(44,saveloc);write('Saved ...');
{---------------------------}
delay(1000);
{---------------------------}
textbackground(black);textcolor(black);
gotoxy(44,saveloc);write('         ');
end;

Procedure changebrightness;
var j,i:integer;
begin
  for j:= 1 to 15 do
  begin
  SetPal(j,config^.scr[j,1],config^.scr[j,2],config^.scr[j,3]);
  end;
  textbackground(black);textcolor(text_color);
  gotoxy(42-12,brightloc);write('_____________________');
  gotoxy(42-12,brightloc);
  for i:= 1 to brightness do
  write('Û');
end;

Procedure Mem;
var havexms,haveems:boolean;
begin
if bar then
begin
     textcolor(tag);
     gotoxy(55,memloc);writE('Mem : [',GetMainMemory,']');
     gotoxy(55,xmsloc);write('Xms : [');
     CheckXMSMemory(HaveXms);write(havexms,']');
     gotoxy(55,emsloc);write('Ems : [');
     CheckEMSMemory(HaveEms);write(haveems,']');
end;
end;

Procedure RodentOnOff;
begin
textbackground(text_back);
textcolor(tag);
gotoxy(29,rodentloc);write('[On/Off]');

if mouse = true then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(30,rodentloc);write('ON');
end;
if mouse = false then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(33,rodentloc);write('OFF');
end;

end;

Procedure Smoothonoff;
begin
textbackground(text_back);
textcolor(tag);
gotoxy(29,smoothloc);write('[Smooth/+Bar/Ansi]');

if smooth= 1 then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(30,smoothloc);write('SMOOTH');
end;
if smooth= 2 then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(37,smoothloc);write('+BAR');
end;
if smooth= 3 then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(42,smoothloc);write('ANSI');
end;

end;


Procedure Randonoff;
begin
textbackground(text_back);
textcolor(tag);
gotoxy(29,randloc);write('[On/Off]');

if rand= true then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(30,randloc);write('ON');
end;

if rand= false then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(33,randloc);write('OFF');
end;

end;


Procedure voconoff;
begin
textbackground(text_back);
textcolor(tag);
gotoxy(29,vocloc);write('[On/Off]');

if voc= true then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(30,vocloc);write('ON');
end;

if voc= false then
begin
     textcolor(other);
     textbackground(text_back);
     gotoxy(33,vocloc);write('OFF');
end;

end;

var size:word;
label helpstart,after,help_2,prev,next,mo;

begin
c:=1;
loadvoc(1);
FadedownRGBScreen;
Reset80x25VideoScreen;
HideCursor;
Helpstart:
Displayansipointer(helpm);
k:=#22;
write_help(c,topics);
{------------------------}
inithelp;
initfont(config^.curfnt);
changebrightness;
RodentOnOff;
Randonoff;
Smoothonoff;
voconoff;
{------------------------}
if x<>19 then
begin
     str:=config^.subfile[x][y];
     initsave(str);
end;
mem;
{------------------------}
if mouse then showmouse;
repeat
      if mouse then
      begin
           GetMouseInfo(M);
           if (M.ButtonClicked = leftButton) then
           begin
                while not buttonreleased do
                begin
                end;
                if ((m.row = 1) and (m.column = 80)) or ((m.row = 25) and (m.column = 80))  then
                goto help_2;
{-----------------------------------------------------------------------------}
               if m.row = fontloc then
               begin
                     c:=1;
                     write_help(c,topics);
                     delay(100);
                     if (m.column>=12) and (m.column<=20) then
                        goto prev;
                     if (m.column>20) and (m.column<28) then
                        goto next;
                     if (m.column>=29) and (m.column<=36) then
                        goto prev;
                     if (m.column>36) and (m.column<44) then
                        goto next;
               end;
               if m.row = rodentloc  then
               begin
                     c:=2;
                     write_help(c,topics);
                     delay(100);
                     if (m.column>=12) and (m.column<=28) then
                     goto mo;
                     if (m.column>=33) and (m.column<=36) then
                     goto mo;
               end;
               if m.row = saveloc  then
                  if (m.column>=12) and (m.column<=28) then
                  begin
                     c:=4;
                  end;
               if m.row = brightloc  then
                  begin
                     c:=5;
                     write_help(c,topics);
                     delay(100);
                     if (m.column>=12) and (m.column<=20) then
                        goto prev;
                     if (m.column>20) and (m.column<28) then
                        goto next;
                     if (m.column>=29) and (m.column<=41) then
                        goto prev;
                     if (m.column>41) and (m.column<52) then
                        goto next;
                  end;
               if m.row = exitloc  then
                  begin
                     c:=6;
                     write_help(c,topics);
                     delay(100);
                     goto fin;
                  end;
{-----------------------------------------------------------------------------}
           end;
           if (M.ButtonClicked = rightButton) then
           begin
                 while not buttonreleased do
                 begin
                 end;
                    goto fin;
           end;
      end;
  IF KEYPRESSED THEN
  BEGIN
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #60 : begin
            help_2:
          if not boom1 then
          f2_help;
          goto helpstart;
          end;
    #71 : c:=1;
    #73 : c:=1;
    #79: c:=maxhelp;
    #81: c:=maxhelp;
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
          next:
      if c=2 then
               begin
                    if smooth=1 then
                    begin
                         smooth:=2;
                         LoadAndPlay(11);
                         smoothonoff;
                         goto after;
                    end;
                    if smooth=2 then
                    begin
                         smooth:=3;
                         LoadAndPlay(12);
                         smoothonoff;
                         goto after;
                    end;
                    if smooth=3 then
                    begin
                         smooth:=1;
                         LoadAndPlay(10);
                         smoothonoff;
                         goto after;
                    end;
               end;
          if c = 1 then
          begin
          loadandplay(19);
          inc(config^.curfnt);
          if config^.curfnt>config^.lastfnt then
             config^.curfnt:=1;
          initfont(config^.curfnt);
          fontloadpointer(config^.font[config^.curfnt],fontP);
          end;
      if c=3 then
               begin
                    if mouse=false then
                    begin
                         mouse:=true;
                         LoadAndPlay(4);
                         installMouse;
                         SetMouseCursor(true);
                         RodentOnOff;
                         goto after;
                    end;
                    if mouse=true then
                    begin
                         mouse:=false;
                         LoadAndPlay(5);
                         UninstallMouse;
                         SetMouseCursor(false);
                         RodentOnOff;
                         goto after;
                    end;
               end;
               if (c=4) and adlib and (mustype = 1) then
               begin
                    if rand=false then
                    begin
                         rand:=true;
                         LoadAndPlay(6);
                         RandOnOff;
                         randomize;
                         StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         config^.curmus:=random(config^.lastmus)+1;
                         if config^.curmus > 21 then  config^.curmus:=21;
                         if config^.curmus < 1 then  config^.curmus:=1;
                         PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         goto after;
                    end;
                    if rand=true then
                    begin
                         rand:=false;
                         LoadAndPlay(7);
                         StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         config^.curmus:=musdef;
                         PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         RandOnOff;
                         goto after;
                    end;
               end;
               if (c=5) and voc_Start then
               begin
                    if voc=true then
                    begin
                         voc:=false;
                         LoadAndPlay(8);
                         voconoff;
                         goto after;
                    end;
                    if voc=false then
                    begin
                         LoadAndPlay(9);
                         voc:=true;
                         voconoff;
                         goto after;
                    end;
               end;
          if c = 7 then
          begin
          loadandplay(22);
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
          prev:
      if c=2 then
               begin
                    if smooth=2 then
                    begin
                         smooth:=1;
                         LoadAndPlay(10);
                         smoothonoff;
                         goto after;
                    end;
                    if smooth=3 then
                    begin
                         smooth:=2;
                         LoadAndPlay(11);
                         smoothonoff;
                         goto after;
                    end;
                    if smooth=1 then
                    begin
                         smooth:=3;
                         LoadAndPlay(12);
                         smoothonoff;
                         goto after;
                    end;
               end;
          if c = 1 then
          begin
          loadandplay(19);
          dec(config^.curfnt);
          if config^.curfnt<1 then
             config^.curfnt:=config^.lastfnt;
          initfont(config^.curfnt);
          fontloadpointer(config^.font[config^.curfnt],fontP);
          end;
      if c=3 then
               begin
                    if mouse=false then
                    begin
                         mouse:=true;
                         LoadAndPlay(4);
                         installMouse;
                         SetMouseCursor(true);
                         RodentOnOff;
                         goto after;
                    end;
                    if mouse=true then
                    begin
                         mouse:=false;
                         LoadAndPlay(5);
                         UninstallMouse;
                         SetMouseCursor(false);
                         RodentOnOff;
                         goto after;
                    end;
               end;
               if (c=4) and adlib and (mustype = 1) then
               begin
                    if rand=false then
                    begin
                         rand:=true;
                         LoadAndPlay(6);
                         RandOnOff;
                         randomize;
                         StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         config^.curmus:=random(config^.lastmus)+1;
                         if config^.curmus > 21 then  config^.curmus:=21;
                         if config^.curmus < 1 then  config^.curmus:=1;
                         PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         goto after;
                    end;
                    if rand=true then
                    begin
                         rand:=false;
                         LoadAndPlay(7);
                         StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         config^.curmus:=musdef;
                         PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         RandOnOff;
                         goto after;
                    end;
               end;
               if (c=5) and voc_Start then
               begin
                    if voc=false then
                    begin
                         voc:=true;
                         LoadAndPlay(8);
                         voconoff;
                         goto after;
                    end;
                    if voc=true then
                    begin
                         LoadAndPlay(9);
                         voc:=false;
                         voconoff;
                         goto after;
                    end;
               end;
          if c = 7 then
          begin
          loadandplay(22);
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
          end;
    #13 : begin
               mo:
      if c=2 then
               begin
                    if smooth=1 then
                    begin
                         smooth:=2;
                         LoadAndPlay(11);
                         smoothonoff;
                         goto after;
                    end;
                    if smooth=2 then
                    begin
                         smooth:=3;
                         LoadAndPlay(12);
                         smoothonoff;
                         goto after;
                    end;
                    if smooth=3 then
                    begin
                         smooth:=1;
                         LoadAndPlay(10);
                         smoothonoff;
                         goto after;
                    end;
               end;
               if c=3 then
               begin
                    if mouse=false then
                    begin
                         mouse:=true;
                         LoadAndPlay(4);
                         installMouse;
                         SetMouseCursor(true);
                         RodentOnOff;
                         goto after;
                    end;
                    if mouse=true then
                    begin
                         mouse:=false;
                         LoadAndPlay(5);
                         UninstallMouse;
                         SetMouseCursor(false);
                         RodentOnOff;
                         goto after;
                    end;
               end;
               if (c=4) and adlib and (mustype = 1) then
               begin
                    if rand=false then
                    begin
                         rand:=true;
                         LoadAndPlay(6);
                         RandOnOff;
                         randomize;
                         StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         config^.curmus:=random(config^.lastmus)+1;
                         if config^.curmus > 21 then  config^.curmus:=21;
                         if config^.curmus < 1 then  config^.curmus:=1;
                         PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         goto after;
                    end;
                    if rand=true then
                    begin
                         rand:=false;
                         LoadAndPlay(7);
                         StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         config^.curmus:=musdef;
                         PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
                         RandOnOff;
                         goto after;
                    end;
               end;
               if (c=5) and voc_Start then
               begin
                    if voc=false then
                    begin
                         voc:=true;
                         LoadAndPlay(8);
                         voconoff;
                         goto after;
                    end;
                    if voc=true then
                    begin
                         LoadAndPlay(9);
                         voc:=false;
                         voconoff;
                         goto after;
                    end;
               end;
               if (c=6) then
               begin
                    showcursor;
                    if Getstr(30,21,str,12) then
                       savefile(str);
                    hidecursor;
               end;
               if c=maxhelp then
               begin
                    goto fin;
               end;
           end;
      end;
  if c = maxhelp+1 then
     c := 1;
  if c = 0 then
     c := maxhelp;
  after:
  if voc and (k in [#75,#77,#13]) then loadvoc(1)
  else
      playkey(k);
  write_help(c,topics);
  if mouse then showmouse;
  end;
  until true=false; {never....hehe}
fin:
playkey(k);
FadedownRGBScreen;
Reset80x25VideoScreen;
end;

end.