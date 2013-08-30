unit worms;
interface
procedure startgame;
implementation
uses crt,dos,wormnit,extra;
procedure startgame;
var
     key:char;
     orgspeed,last,i,code:integer;
     tmp,line:string;

begin
lives:=9;
orgspeed:=150;
level:=1;
if paramcount=1 then
begin
     if paramstr(1)='/50' then
     fif:=true
     else fif:=false;
end;
if fileexists('worms.lvl') then
begin
     assign(levfile,'worms.lvl');
     reset(levfile);
     readln(LevFile,Line);
     delete(line,1,10);
     strtonum(line,lastlevel);
     LoadNewLevel(levfile,levellimit,worm,food,secret);
     startsecret:=secret;
     startworm:=worm;
     startfood:=food;
end
else begin
     write('No .. worms.lvl... go get original filez...');
     halt;
{     extractlevelsfile;}
      end;
if level>1 then
begin
     for i:=1 to level-1 do
     begin
     LoadNewLevel(levfile,levellimit,worm,food,secret);
     startworm:=worm;
     startfood:=food;
     end;
end;
f:=1;
{fif:=true;}
{if fif=true then
SwitchTo43_50;}
Play(lives,score,level,f,orgspeed,worm,food,levellimit);
{SwitchTo25;}
end;
END.