unit furyfigh;
interface

Procedure Fury_Fighter;
Procedure UpFire;
Procedure Initfire;
Procedure PutFire;

implementation

uses dos,stars,tech,variable,crt,vga,moves,firepo,sprite,intro,
     revdat,revvoc,revconst;
var a:boolean;
    i,col:byte;
    color:byte;
    limit:word;

const {fire position}
      x1 = 0;   y1 = 180;
      x2 = 329; y2 = 199;
      xpos = 0; ypos = 1;
      wx1 = 1;

var line : array[1..x2-x1] of byte;
    buf3 : array[1..x2-x1,1..y2-y1] of byte;

Procedure Initfire;
var i:integer;
begin
     for i:= 1 to x2-x1 do
     begin
{         col:=(255-64)-random(31);{green}
          col:=random(31)+(255-64);{white}
          line[i]:=col;
     end;
end;

Procedure UpFire;
var i,j:word;  points,sum,p:word;
    s : array[1..9] of byte;
    ok:boolean;

begin
     p:=random(1); {beepint backround}
     p:=1;
     for i:= wx1 to x2-x1-wx1+1 do
     begin
          for j:= 1 to y2-y1-1 do
          begin
{              sum:=sum+buf3[i-1,j];           {1}
{              sum:=sum+buf3[i,j];             {2}
{              sum:=sum+buf3[i+1,j];           {3}
               sum:=sum+buf3[i-1,j+1];         {4}
               sum:=sum+buf3[i,j+1];           {5}
               sum:=sum+buf3[i+1,j+1];         {6}
{              sum:=sum+buf3[i-1,j];           {7}
{              sum:=sum+buf3[i,j];             {8}
{              sum:=sum+buf3[i+1,j];           {9}
               sum:= sum div 4 +p;
               buf3[i,j]:= sum
          end;
     end;
     for i:= 1 to x2-x1 do
     begin
          buf3[i,j+1]:=line[i];
     end;
end;

Procedure PutFire;
var i:word;
    j:word;
begin
     for i:= 1 to x2-x1-9 do
     begin
          for j:= 4 to y2-y1 do
          begin
{         if (buf3[i,j]>=160) and (buf3[i,j]<=191) then}
          if (buf3[i,j]>=192) and (buf3[i,j]<=252) then
             buf_^[(x1+i+xpos)+((j+y1+ypos)*320)]:=buf3[i,j];
{         else buf^[(x1+i+xpos)+((j+y1+ypos)*320)]:=0;}
          end;
     end;
end;

Procedure vocassign;
begin
     vocs[4]:='AWIN.VOC';
     vocs[5]:='HWIN.VOC';
     vocs[6]:='OWIN.VOC';
     vocs[1]:='ALOSE.VOC';
     vocs[2]:='HLOSE.VOC';
     vocs[3]:='OLOSE.VOC';
     vocs[7]:='GUNMULTI.VOC';
     vocs[8]:='EXLARGE.VOC';
END;

const firemem = 7*1024;

Procedure Fury_Fighter;
var ptrmem:longint;
var aa,bb:integer;
begin
{ clrscr;
 writeln('Mem Avail : ',memavail,', Press Any Key');
{ readln;}
{ if memavail>=memneeded then
 begin
     {------- init everything -------}
{     READGLOBALINDEX;}
     invinsible:=false;
     a:=false;
     starslayer:=3;
     initvga;
     init_fire;
     Init_Stars;
     side := 6;
     vocassign;
     getmem(buf_,maxbuf);
     getmem(buf2_,firemem);
     choose_fury(color);
     loadmdaP('fury',fury_image);
     loadmdap('clock',clock);
     loadmdap('num',num);
     loadmdap('font',font);
     loadmdap('heart',heart);
     loadmdap('pop',pop);
     loadmdap('shot',fireball);
     loadmdap('boom',boom);
     loadmdap('birdi',allenemy[1]);
     loadmdap('bug',allenemy[2]);
     loadmdap('bat',allenemy[3]);
     loadmdap('birdi2',allenemy[4]);
     loadmdap('grnfish',allenemy[5]);
     loadmdap('meduza',allenemy[6]);
     loadmdap('norfish',allenemy[7]);
     loadmdap('dog',allenemy[8]);
     loadmdap('knight',allenemy[9]);
     loadmdap('browni',allenemy[10]);
     loadmdap('blacki',allenemy[11]);
     loadmdap('pumpkin',allenemy[12]);
     loadmdap('fox',allenemy[13]);
     loadpalp('fury');
{     getmem(vocp,max div 2);}
     {- introduction -}
{     Introduction;
     {- End of Introduction -}
     loadpalp('fury');
     fury_color(color);
     firetype:=0;
     life:=10;
     clockpos:=1;
     double:=1;
     cury:=90;
     curx:=1;
     image:=1;
     run:=1;
     tail:=0;
     spacepushed:=false;
     mins:=0;
     secs:=-1;
     tsecs:=0;
     tmins:=0;
     truetime:=39;
     show:=1;
     ptime:=0;
     enemies_on:=0;
     enemies_on2:=0;
     hardness:=7;
     randomize;
     patt1:=random(hardness)+1;
     patt2:=random(patt1)+1;
     {------- init everything -------}
     deadsign:=false;
     goodies[1,4]:=1;
     score:=0;
     oldscore:=0;
     firetype:=1;
     high:=100;
     fireflag:=true;
     {------ danger !!!! -------}
{     if a then
     begin
          GetIntVec(KEYBOARD_INT,Old_ISR);
          SetIntVec(KEYBOARD_INT,@New_Key_Int);
     end;}
     {------ danger !!!! -------}

     while (raw_key<>esc) and (deadsign=false) do
     begin
          raw_key := port[$60];
          Which_Move(raw_key);
          MEMW[$0000:$041C] := MEMW[$0000:$041A];

          {--- clear temp buffer ----}
          fillchar(buf_^,maxbuf,0);
          {--- clear temp buffer ----}

          {------ stars output -------}
          if side in [7,8,9] then
             Move_Stars_down;
          if side in [1,2,3] then
             Move_Stars_up;
          if side in [9,6,3] then
             Move_Stars_left;
          if side in [7,4,1] then
             Move_Stars_right;

          copy_stars(buf_);
          {------ stars output -------}
          if fireflag then
          begin
               initfire;
               upfire;
               PutFire;
          end;
          {------ image output -------}
          image_pop(buf_);
          {------ image output -------}

          if enemies_on2 = 0 then
          begin
               randomize;
               patt1:=random(hardness-1)+1;
               patt2:=random(patt1-1)+1;
          end;

          enemy_init(buf_);
          enemy_copy(buf_);
          check_colide;
          Copy_Score(buf_);
          if score>high then break;
          if (score>=oldscore+1000) then
          begin
               if firetype<4 then
                  inc(firetype);
               oldscore:=firetype*1000;
          end;
          if not invinsible then
             check_colide_fury;
          if life = 0 then deadsign:=true;

          {----- shots - firing -----}
          move_fire;
          copy_fire;
          {----- shots - firing -----}

          {----- misc things -----}
          copy_clock(buf_);
          time_check(buf_);
          life_check(buf_);
          {----- misc things -----}

          {------ screen output -------}
          WaitRetrace;

          move32fast(buf_^,mem[$a000:0],maxbuf);
          {------ screen output -------}
          {-- how fast thestars return to course --}
          inc(run);
          if run>course then
          begin
               run:=1;
               side:=6; {side right}
          end;
          image:=1;
          {-- how fast the stars return to course --}
     end;

     deloadmda(fury_image);
     deloadmda(clock);
     deloadmda(num);
     deloadmda(heart);
     deloadmda(pop);
     deloadmda(fireball);
     deloadmda(boom);
     deloadmda(dead);
     deloadmda(font);
     for i:= 1 to enemies_in_data_base do
         deloadmda(allenemy[i]);

     if score< high then
     begin
{          loadandplay_name(vocs[random(3)+1]);}
          fillchar(buf_^,maxbuf,0);
          WaitRetrace;
          move32fast(buf_^,mem[$a000:0],maxbuf);
          deadsign:=true;
          loadpalp('dead');
          extractfilefromdat('DEAD.MDA',game_file);
          loadmda('dead',dead);
          DELETEDATFILE('DEAD.MDA');
          die(color,dead);
          deloadmda(dead);
     end
     else
     begin
{          loadandplay_name(vocs[(random(3)+1)*2]);}
          fillchar(buf_^,maxbuf,0);
          WaitRetrace;
          move32fast(buf_^,mem[$a000:0],maxbuf);
          loadpalp('sleep');
          extractfilefromdat('SLEEP.MDA',game_file);
          loadmda('sleep',sleep);
          DELETEDATFILE('SLEEP.MDA');
          die(99,sleep);
          deloadmda(sleep);
     end;
{    freemem(vocp,max div 2);}
     ptrmem:=memavail;
     freemem(buf_,maxbuf);
     freemem(buf2_,firemem);
     closevga;
     textcolor(lightgray);
     textbackground(black);
     clrscr;

     {------ danger !!!! -------}
{     if a then
     begin
     SetIntVec(KEYBOARD_INT,Old_ISR);
     end;
     {------ danger !!!! -------}
 {    if a then
     asm in al,21h; and al,253; out 21h,al; end;         { enable keyboard   }
{     write('Ptr Mem Used : ',memavail-ptrmem);
 end
 else write('need atleast ',memneeded,'KB of mem');}
end;
end.