unit revhelp;

interface
uses  Crt,Dos,RevDat,RevGfx,
      RevAnsi,revsmoot,
      revconst,revmus;

function Getstr(x,y:integer; var str:string; length1:integer):boolean;
Procedure CheckMusic(var cur:integer);
Procedure Nope;
procedure write_help(b,t:integer; fwrite,volu:boolean);
procedure InitHelp;
Procedure help(fwrite:boolean; f:string);
Procedure SaveFile(iner,out:string);

implementation
uses revrad;
const max=60000;
type buf= array[1..max] of char;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words -  eRR...                                                 *)
(****************************************************************************)
Procedure SaveFile(iner,out:string);
var b:buf;
    f1:file;
    f2:text;
    i,lin:longint;
    numread:word;
begin
     lin:=0;
     assign(f1,iner);
     reset(f1,1);
     BlockRead(F1,b, SizeOf(b), NumRead);
     assign(f2,out);
     rewrite(f2);
     for i:= 1 to NUMREAD do
     begin
          if (i mod 2) <> 0 then
          begin
               if lin=79 then
               begin
                    lin:=0;
                    writeln(f2,b[i]);
               end
               else
               begin
                    lin:=lin+1;
                    write(f2,b[i]);
               end;
          end;
     end;
     close(f1);
     close(f2);
end;

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
if cur=0 then cur:=lastmus;
if cur=lastmus+1 then cur:=1;
end;

Procedure Nope;
const str='Not Available Yet In This Issue';
begin
gotoxy(((80-length(str)) div 2),25); write(str);
end;


procedure write_help(b,t:integer; fwrite,volu:boolean);
var
i,a,x,y:integer;
str:string;
begin
textcolor(black);
textbackground(lightblue);
x:=25;
y:=15;
for a := 1 to 9 do
  begin
    if b=a then
    begin
         if a in [1,2,3,4,5,6,7,8,9] then
         begin
              gotoxy(x-1,y);
              str:=helpmenu[a];
              textbackground(blue);
              write(' ');
              textcolor(lightblue);
              write(str[1]);
              write(str[2]);
              for i:= 3 to length(str) do
                  write(str[i]);
         end;
         if (a = 3) and (fwrite=false) then
         begin
         gotoxy(x-1,y);
         str:=helpmenu[a];
         textbackground(blue);
         write(' ');
         textcolor(darkgray);
         write(str[1]);
         write(str[2]);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
         if (a = 2) and (volu=false) then
         begin
              gotoxy(x-1,y);
              str:=helpmenu[a];
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
         str:=helpmenu[a];
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
         if (a = 3) and (fwrite=false) then
         begin
         gotoxy(x-1,y);
         str:=helpmenu[a];
         textbackground(black);
         write(' ');
         textcolor(darkgray);
         write(str[1]);
         write(str[2]);
         for i:= 3 to length(str) do
             write(str[i]);
         end;
         if (a = 2) and (volu=false) then
         begin
              gotoxy(x-1,y);
              str:=helpmenu[a];
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

procedure InitHelp;
var i:integer;
begin
{- init mus write - }
textbackground(lightblue);textcolor(darkgray);
gotoxy(41,15);write('[');gotoxy(54,15);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42,15);write('            ');
gotoxy(42+((12-length(music[curmus,1]))div 2),15);
write(music[curmus,1]);
{- init volume -}
textbackground(lightblue);textcolor(darkgray);
gotoxy(41,16);write('[');gotoxy(54,16);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42,16);write('____________');
{- init save -}
textbackground(lightblue);textcolor(darkgray);
gotoxy(41,17);write('[');gotoxy(54,17);write(']');
textbackground(black);textcolor(darkgray);
gotoxy(42,17);write('____________');
end;

Procedure WriteVol(vol:byte);
var i:integer;
begin
     gotoxy(42,16);
     textbackground(black);textcolor(darkgray);
     for i:= 1 to (12-(64-vol)) do
     write('Û');
     for i:= 1 to (64-vol) do
     write('_');
end;

Procedure help(fwrite:boolean; f:string);
var k:char;
    i,c:integer;
    str:string;
const defstr='ş ------------ ' ;
label stop,damn,fin;
begin
FadedownRGBScreen;
Reset80x25VideoScreen;
HideCursor;
c:=1;
Displayansi(defmenufile);
k:=#22;
write_help(c,topics,fwrite,volu);
inithelp;
writevol(vol);
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
               textbackground(black);textcolor(darkgray);
               gotoxy(22,25); write(' You Are So Stupid There Is No More Help');
               delay(1000);
               gotoxy(22,25); write('                                        ');
          end;
    #72 : begin dec(c); end;
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
    #27,'q' : begin goto fin; end;
    #77 : Begin
          if c= 1 then
          begin
               StopMusic(music[curmus,1],music[curmus,2]);
               curmus:=curmus+1;
               checkmusic(curmus);
               PlayMusic(music[curmus,1],music[curmus,2]);
               if music[curmus,2]='RAD' then
               begin
               volu:=true;
               writevol(vol);
               end
               else
               begin
               volu:=false;
               writevol(52);
               end;
               textbackground(black);textcolor(darkgray);
               gotoxy(42,15);write('           ');
               gotoxy(42+((12-length(music[curmus,1]))div 2),15);
               write(music[curmus,1]);
          end;
          if (c = 2)  then
          begin
              if (vol<>64) then
              begin
              if volu=true then
              begin
                   vol:=vol+1;
                   radvolume(vol);
                   writevol(vol);
              end;
              end;
              if volu=false then
                  writevol(52)
          end;
      end;
    #75 : begin
          if c= 1 then
          begin
               StopMusic(music[curmus,1],music[curmus,2]);
               curmus:=curmus-1;
               checkmusic(curmus);
               PlayMusic(music[curmus,1],music[curmus,2]);
               if music[curmus,2]='RAD' then
               begin
               volu:=true;
               writevol(vol);
               end
               else
               begin
               volu:=false;
               writevol(52);
               end;
               textbackground(black);textcolor(darkgray);
               gotoxy(42,15);write('           ');
               gotoxy(42+((12-length(music[curmus,1]))div 2),15);
               write(music[curmus,1]);
          end;
          if (c = 2)  then
          begin
              if (vol<>52) then
              begin
              if volu=true then
              begin
              vol:=vol-1;
              radvolume(vol);
              writevol(vol);
              end;
              end;
              if volu=false then
              writevol(52)
          end;
          end;
    #13 : begin
               if (c = 3) and (fwrite=true) then
               begin
               str:='';
               textbackground(black);textcolor(darkgray);
               gotoxy(42,17);write('____________');
               showcursor;
               if Getstr(42,17,str,12) then
               begin
               ExtractFileFromDat(f);
               savefile(f,str);
               end;
               hidecursor;
               end;
               if c=9 then
                  goto fin;
           end;
      end;
  if c = (topics DIV 2)+1 then
     c := 1;
  if c = 0 then
     c := (topics DIV 2);
  write_help(c,topics,fwrite,volu);
  until true=false; {never....hehe}
fin:
FadedownRGBScreen;
Reset80x25VideoScreen;
end;





end.