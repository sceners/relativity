
UNIT wormnit;
interface
uses extra;

PROCEDURE SwitchTo25;
PROCEDURE SwitchTo43_50;
Procedure WriteInfo;
Procedure WriteLevel;
Procedure InitLevel;
procedure ShowCursor;
Procedure HideCursor;
Procedure InitDirections;
procedure quit;
Procedure MoveWorm(var worm:wrm);
Procedure WriteWorm(worm:wrm);
Function OutOfBorder(worm:wrm):boolean;
Procedure quit_mistake;
Procedure PlaceFood(food:fd; f:integer);
Function Onfood(worm:wrm; food:fd; f:integer):boolean;
Procedure AdvanceFood(var food:fd; var f:integer);
Procedure placescore(score:integer);
Procedure placeLives(Lives:integer);
procedure checkwhoislast(var last:integer; worm:wrm);
Procedure AddTail(var worm:wrm; length:integer);
Function OnTail(worm:wrm):boolean;
Function FileExists(FileName: String): Boolean;
Procedure StrToNum(str:string; var num:integer);
Procedure InitWorm(var worm:wrm);
Procedure InitFood(var food:fd);
Procedure Initsecret(var secret:sh);
Procedure ClearSecret(var secret:sh);
Procedure Play(var lives,score,level:integer; f,orgspeed:integer; var worm:wrm; var food:fd; var levellimit:levmit);
Procedure LoadNewLevel(var levfile:text; var levellimit:levmit; var worm:wrm; var food:fd; var secret:sh);
Procedure NewLevel;
Procedure Duplicate(x,y:integer);
Procedure clrlastworm(worm:wrm);
Procedure DeleteOldFood(food:fd; f:integer);

implementation

uses crt;
var  x,y:integer;

PROCEDURE SwitchTo43_50; ASSEMBLER;
ASM
   MOV AX,$1112
   INT $10
END;

PROCEDURE SwitchTo25; ASSEMBLER;
ASM
   MOV AX,$1114
   INT $10
END;

Procedure Play(var lives,score,level:integer; f,orgspeed:integer; var worm:wrm; var food:fd; var levellimit:levmit);
var
     key:char;
     last,i,code:integer;
     tmp,line:string;
label notliggle,again;
label after;
begin
hidecursor;
again:
f:=1;
writelevel;
speed:=orgspeed;
initDirections;
initworm(worm);
initfood(food);
writeworm(worm);
placefood(food,f);
while key<>#27  do
begin
     if keypressed then
     begin
     key:=readkey;
     if key=#0 then key:=readkey;
     case key of
          '+': begin
               speed:=speed-10;
               if speed<10 then speed:=10;
               end;
          '-': begin
               speed:=speed+10;
               if speed<600 then speed:=600;
               end;
          'l': begin
               level:=level+1;
               newlevel;
               goto after;
               end;
          's': begin
               score:=score+100;
               placescore(score);
               end;
{          'f': begin
               deleteoldfood(food,f);
               advancefood(food,f);
               placefood(food,f);
               if level>lastlevel then goto after;
               end;}
       ']': begin
               lives:=lives+1;
               placelives(lives);
               end;
       '[': begin
               lives:=lives-1;
               placelives(lives);
               end;
          'w': begin
               if left or right then
               duplicate(0,-1);
               end;
          'x': begin
               if left or right then
               duplicate(0,1);
               end;
          'a': begin
               if up or down then
               duplicate(-1,0);
               end;
          'd': begin
               if up or down then
               duplicate(1,0);
               end;
          #27: quit;
{down}    #80: begin
                     if up=true then goto notliggle;
                     left:=false;right:=false;
                     if down=true then goto notliggle;
                     down:=true;
               end;
{up}      #72: begin
                    if down=true then goto notliggle;
                    left:=false;right:=false;
                    if up=true then goto notliggle;
                    up:=true;
               end;
{left}    #75: begin
                     if right=true then goto notliggle;
                     up:=false;down:=false;
                     if left=true then goto notliggle;
                     left:=true;
               end;
{right}   #77: begin
                     if left=true then goto notliggle;
                     up:=false;down:=false;
                     if right=true then goto notliggle;
                     right:=true;
               end;
     end;{case}
     writeworm(worm);
     end
     else
     begin
          if lives<=0 then goto after;
          delay(speed);
          lastworm:=worm;
          moveworm(worm);
          writeworm(worm);
          if onfood(Worm,food,f) then
          begin
               advancefood(food,f);
               placefood(food,f);
               placescore(score);
              { AddTail(worm,3);}
               speed:=speed-10;
          end;
          if ontail(worm) then
          begin
               dec(lives);
               if lives= 0 then
                  quit_mistake;
               placelives(lives);
               goto again;
          end;
          if outofborder(worm) then
          begin
               dec(lives);
               if lives= 0 then
                  quit_mistake;
               placelives(lives);
               goto again;
          end;
     end;
     notliggle:
end;
after:
end;

Procedure Duplicate(x,y:integer);
var i:integer;
begin
{startworm:=worm;}
clrlastworm(lastworm);
     for i:= 1 to 80 do
     begin
          if (worm[i,1]<>0) and (worm[i,2]<>0) then
          begin
               worm[i,1]:=worm[i,1]+x;
               worm[i,2]:=worm[i,2]+y;
          end;
     end;
WriteWorm(worm);
end;

Procedure ClearLimit(var levellimit:levmit);
var i,go:integer;
begin
     for i:= 1 to 2000 do
     begin
         levellimit[i,1]:=0;
         levellimit[i,2]:=0;
     end;
end;

Procedure InitWorm(var worm:wrm);
begin
worm:=startworm;
end;

Procedure Initsecret(var secret:sh);
begin
secret:=startsecret;
end;

Procedure InitFood(var food:fd);
begin
food:=startfood;
end;

Procedure ClearWorm(var worm:wrm);
var i:integer;
begin
for i:= 1 to 80 do
begin
    worm[i,1]:=0;
    worm[i,2]:=0;
end;
end;

Procedure ClearSecret(var secret:sh);
var i:integer;
begin
for i:= 1 to 206 do
begin
    secret[i,1]:=0;
    secret[i,2]:=0;
end;
end;

Procedure LoadNewLevel(var levfile:text; var levellimit:levmit; var worm:wrm; var food:fd; var secret:sh);
var levline:string[80];
    s,w,i,j,go:integer;
begin
clearlimit(levellimit);
clearWorm(Worm);
clearsecret(secret);
{readln(levfile,levline);
who:='levline';}
x:=1;
w:=1;
s:=1;
for i:= 1 to 24 do
begin
    readln(levfile,levline);
     for j:= 1 to 80 do
     begin
          if levline[j]='L' then
          begin
               levellimit[x,1]:=j;
               levellimit[x,2]:=i;
               x:=x+1;
          end;
          if levline[j]='S' then
          begin
               Secret[s,1]:=j;
               Secret[s,2]:=i;
               s:=s+1;
          end;
          if levline[j]='H' then
          begin
               worm[1,1]:=j;
               worm[1,2]:=i;
          end;
          if levline[j]='A' then
          begin
               worm[2,1]:=j;
               worm[2,2]:=i;
          end;
          if levline[j]='B' then
          begin
               worm[3,1]:=j;
               worm[3,2]:=i;
          end;
          if levline[j]='C' then
          begin
               worm[4,1]:=j;
               worm[4,2]:=i;
          end;
          if levline[j]='D' then
          begin
               worm[5,1]:=j;
               worm[5,2]:=i;
          end;
          if levline[j]='E' then
          begin
               worm[6,1]:=j;
               worm[6,2]:=i;
          end;
          if levline[j]='T' then
          begin
               worm[7,1]:=j;
               worm[7,2]:=i;
          end;
          if levline[j]='1' then
          begin
                food[1,1]:=j;
                food[1,2]:=i;
          end;
          if levline[j]='2' then
          begin
               food[2,1]:=j;
               food[2,2]:=i;
          end;
          if levline[j]='3' then
          begin
          food[3,1]:=j;
          food[3,2]:=i;
          end;
          if levline[j]='4' then
          begin
          food[4,1]:=j;
          food[4,2]:=i;
          end;
          if levline[j]='5' then
          begin
          food[5,1]:=j;
          food[5,2]:=i;
          end;
          if levline[j]='6' then
          begin
          food[6,1]:=j;
          food[6,2]:=i;
          end;
          if levline[j]='7' then
          begin
          food[7,1]:=j;
          food[7,2]:=i;
          end;
          if levline[j]='8' then
          begin
          food[8,1]:=j;
          food[8,2]:=i;
          end;
          if levline[j]='9' then
          begin
          food[9,1]:=j;
          food[9,2]:=i;
          end;
     end;
end;
end;

function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

Procedure StrToNum(str:string; var num:integer);
var code:integer;
begin
Val(str,num, Code);
end;

Function OnTail(worm:wrm):boolean;
var j,i,last:integer;
label after;
begin
ontail:=false;
checkwhoislast(last,worm);
for i:= 1 to last do
begin
     for j:= 1 to last do
     begin
          if i<>j then
          begin
          if (worm[i,1]=worm[j,1]) and (worm[i,2]=worm[j,2]) then
          begin
          ontail:=true;
          goto after;
          end;
          end;
     end;
end;
after:
end;

Procedure AddTail(var worm:wrm; length:integer);
var i,last:integer;
begin
checkwhoislast(last,worm);
for i:= 1 to length do
begin
     worm[last+i,1]:=worm[last+i-1,1]+1;
     worm[last+i,2]:=worm[last+i-1,2];
end;
end;

Procedure endgame;
begin
end;

procedure deleteoldfood(food:fd; f:integer);
begin
gotoxy(food[f,1],food[f,2]);
textcolor(lightgreen);
write(' ');
end;

Procedure PlaceFood(food:fd; f:integer);
begin
gotoxy(food[f,1],food[f,2]);
textcolor(lightgreen);
write(f);
end;

Function Onfood(worm:wrm; food:fd; f:integer):boolean;
begin
onfood:=false;
if (worm[1,1]=food[f,1]) and (worm[1,2]=food[f,2]) then
begin
score:=score+100;
onfood:=true;
end;
end;

Procedure NewLevel;
label after;
begin
if level> lastlevel then
begin
endgame;
goto after;
end;
LoadNewLevel(levfile,levellimit,worm,food,secret);
writelevel;
startsecret:=secret;
startworm:=worm;
startfood:=food;
f:=1;
Play(lives,score,level,f,150,worm,food,levellimit);
after:
end;

Procedure AdvanceFood(var food:fd; var f:integer);
begin
if level<= lastlevel then
f:=f+1;
if f>9 then
begin
     level:=level+1;
     if level> lastlevel then
     endgame;
     newlevel;
end;
if level> lastlevel then
endgame;
end;

Procedure checkwhoislast(var last:integer; worm:wrm);
var x,y:integer;
label after;
begin
for x := 1 to 80 do
begin
     if (worm[x,1]=0) and (worm[x,2]=0) then
     begin
          last:=x-1;
          goto after;
     end;
end;
after:
end;

Procedure MoveWormBack(var worm:wrm; last:integer);
var x,y:integer;
begin
for x := last downto 2 do
begin
worm[x,1]:=worm[x-1,1];
worm[x,2]:=worm[x-1,2];
end;
end;

Procedure MoveWorm(var worm:wrm);
var last,go:integer;
begin
go:=24;
checkwhoislast(last,worm);
MoveWormBack(worm,last);
if up=true then
begin
     Worm[1,1]:=worm[2,1];
     Worm[1,2]:=worm[2,2]-1;
     if worm[1,2]= 0 then
        worm[1,2]:=go;
end;
if down=true then
begin
     Worm[1,1]:=worm[2,1];
     Worm[1,2]:=worm[2,2]+1;
     if worm[1,2]=go+1 then
        worm[1,2]:=1;
end;
if right=true then
begin
     Worm[1,1]:=worm[2,1]+1;
     Worm[1,2]:=worm[2,2];
     if worm[1,1]= 81 then
        worm[1,1]:=1;
end;
if left=true then
begin
     Worm[1,1]:=worm[2,1]-1;
     Worm[1,2]:=worm[2,2];
     if worm[1,1]= 0 then
        worm[1,1]:=80;
end;
end;

Procedure InitLevel;
begin
level:=1;
end;

Procedure WriteSecret;
var i:integer;
begin
textcolor(blue);
for i:= 1 to 206 do
begin
     if (Secret[i,1]<>0) and (Secret[i,2]<>0) then
     begin
          gotoxy(Secret[i,1],Secret[i,2]);write('±');
     end;
end;
end;

Procedure WriteLevel;
var i:integer;
begin
clrscr;
textcolor(blue);
for i:= 1 to 2000 do
begin
     if (levellimit[i,1]<>0) and (levellimit[i,2]<>0) then
     begin
          gotoxy(levellimit[i,1],levellimit[i,2]);write('±');
     end;
end;
writesecret;
PlaceScore(score);
PlaceLives(lives);
writeInfo;
end;

Procedure WriteInfo;
begin
textcolor(lightgreen);
gotoxy(44,25);write('Worms ScriptAble Made By MuadDIB v.1');
end;

Procedure placescore(score:integer);
begin
gotoxy(25,25);textcolor(red);write('S');
textcolor(lightred);write('co');
textcolor(white);write('re :> ');
textcolor(lightgray);write(Score);
end;

Procedure placeLives(Lives:integer);
begin
gotoxy(1,25);textcolor(red);write('L');
textcolor(lightred);write('iv');
textcolor(white);write('es :> ');
textcolor(lightgray);write(Lives);
end;

Procedure clrlastworm(worm:wrm);
var i,last:integer;
begin
checkwhoislast(last,worm);
for i:= 1 to last do
begin
     gotoxy(worm[i,1],worm[i,2]);write(' ');
end;
end;

Procedure WriteWorm(worm:wrm);
var x:integer;
begin
clrlastworm(lastworm);
     for x:= 1 to 80 do
     begin
         textcolor(Red);
         if (worm[x,1]<>0) and (worm[x,2]<>0) then
         begin
         gotoxy(worm[x,1],worm[x,2]);
         if (up=true) and (x=1) then
         write('');
         if (down=true) and (x=1) then
         write('');
         if (right=true) and (x=1) then
         write('');
         if (left=true) and (x=1) then
         write('');
{         if (x<>1) and ((up=true) or (down=true)) then
         write('º');
         if (x<>1) and ((left=true) or (right=true)) then
         write('Í');}
         if x<>1 then
         write('#');
         end;
     end;
writesecret;
end;

Procedure InitDirections;
begin
up:=false;
down:=false;
left:=false;
right:=true;
end;

Function OutOfBorder(worm:wrm):boolean;
var headx,heady,x,y,i,last:integer;
begin
outofborder:=false;
headx:=worm[1,1];
heady:=worm[1,2];
for i:= 1 to 2000 do
begin
     if (headx=levellimit[i,1]) and (heady=levellimit[i,2]) then
     begin
        OutOfBorder:=true;
        textcolor(blue);
        gotoxy(headx,heady);write('±');
     end;
end;
end;

procedure quit_mistake;
begin
end;


procedure quit;
begin
end;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

procedure ShowCursor;
begin
asm MOV ax,$0100
    MOV cx,$0506
    INT $10 end;
end;
end.