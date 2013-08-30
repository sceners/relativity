unit sprite;

interface
uses variable;

Procedure Copy_Score(var buf:buffer);
procedure choose_fury(var col:byte);
procedure copy_clock(var buf:buffer);
procedure time_check(var buf:buffer);
procedure life_check(var buf:buffer);
procedure image_pop(var buf:buffer);
Procedure Fury_color(col:byte);
Procedure DeloadMda(var sprite:sprt);
Procedure enemy_init(var buf:buffer);
Procedure enemy_copy(var buf:buffer);
Procedure check_colide;
Procedure die(col:byte);
Procedure check_colide_fury; {quick}

implementation
uses vga,crt,tech;

Procedure Copy_Score(var buf:buffer);
var ts:longint;
    numb:byte;
    xpos:integer;
begin
     ts:=score;
     xpos:=50;
     if ts>0 then
     begin
          while ts>0 do
          begin
               numb:=ts mod 10;
               ts:=(ts-numb) div 10;
               xpos:=xpos-num.images[numb+1].x-1;
               put_image(xpos,190,numb+1,buf,num,true);
          end;
     end
     else
     begin
          put_image(xpos,190,1,buf,num,true);
     end;
end;

Procedure check_colide; {quick}
var a,b,i,j,k,l,m,n,s,xsize,ysize : integer;
    fires : array [1..30,1..2] of word;
    sprites : array [1..30] of word;
    top,down,middle:longint;
    con:boolean;

begin
   if (tail>0) then
   begin
     for i:= 1 to xgrid do
     begin
       for j:= 1 to ygrid do
       begin
         if (grid[i,j].active= 1) then
         begin
          con:=false;
          top:= grid[i,j].y;
          down:=grid[i,j].y+ allenemy[grid[i,j].enemy_type].images[ grid[i,j].sprite ].y -1;
          for s:= 1 to  maxshotsallowed do {less calc help thing}
          begin
               middle:=  fire[s,3];
               if (middle>=top) and (middle<=down) and (middle>0) then
               begin
                    con:=true;
                    break;
               end;
          end;
          if con=false then
          for s:= 1 to  maxshotsallowed do {less calc help thing}
          begin
               middle:=  fire[s,3] + (fireball.images[firetype].y)-1;
               if (middle>=top) and (middle<=down) and (middle>0) then
               begin
                    con:=true;
                    break;
               end;
          end;
          if con then
           begin
             for k:= 1 to 30 do
             begin
                  fires[i,1]:=0;
                  fires[i,2]:=0;
                  sprites[i]:=0;
             end;

                xsize:= allenemy[grid[i,j].enemy_type].images[ grid[i,j].sprite ].x;
                ysize:= allenemy[grid[i,j].enemy_type].images[ grid[i,j].sprite ].y;

           for k:= 0 to ysize-1 do
           begin
                sprites[k+1] := grid[i,j].x+(320*(k+grid[i,j].y));
           end;

           for l:= 1 to  maxshotsallowed do
           begin
                if fire[l,4] = 1 then {shot exists}
                begin
                     for m:= 1 to fireball.images[firetype].y do
                     begin
                          fires[m,1]:=fire[l,2]+(320*(fire[l,3]+m-1));
                          fires[m,2]:=fire[l,2]+fireball.images[firetype].x-1+(320*(fire[l,3]+m-1));
                     end;
                     for a:= 1 to ysize do
                     begin
                          for m:= 1 to fireball.images[firetype].y do
                          begin
                          if (fires[m,1]<=sprites[a]) and (fires[m,2]>=sprites[a]) then
                          begin
                  if (fires[m,1]<>0) and (fires[m,2]<>0) and (grid[i,j].active=1) and (grid[i,j].x<=320) and (fire[l,4]=1) then
                               begin
                                    if firetype=1 then
                                       dec(grid[i,j].life,2);
                                    if firetype=2 then
                                       dec(grid[i,j].life,4);
                                    if firetype=3 then
                                       dec(grid[i,j].life,8);
                                    if firetype=4 then
                                       dec(grid[i,j].life,16);
                                    if grid[i,j].life<=0 then
                                    begin
                                       grid[i,j].active:=2;
                                       grid[i,j].sprite:=1;
                                       boomtime:=1;
                                       dec(enemies_on);
                                       score:=score+grid[i,j].score; {the step that makes the firetype go up}
                                    end;
                                    fire[l,4]:=0;
                               end;
                          end;
                          end;
                     end;
                end;
             end;
            end;
         end;
       end;
     end;
   end;
end;

Procedure check_colide_fury;
var a,b,e,i,j,k,l,m,n,xsize,ysize : integer;
    furies : array [1..30,1..2] of word;
    sprites : array [1..30] of word;

begin
     for i:= 1 to xgrid do
     begin
       for j:= 1 to ygrid do
       begin
         if (grid[i,j].active = 1) then
         begin
            for k:= 1 to 30 do
            begin
                 furies[i,1]:=0;
                 furies[i,2]:=0;
                 sprites[i]:=0;
            end;

                xsize:= allenemy[grid[i,j].enemy_type].images[ grid[i,j].sprite ].x;
                ysize:= allenemy[grid[i,j].enemy_type].images[ grid[i,j].sprite ].y;


           for k:= 0 to ysize-1 do
           begin
                sprites[k+1] := grid[i,j].x+(320*(k+grid[i,j].y)); {x+y*320 of enemy}
           end;

           for l:= 1 to goodguys do
           begin
{               if goodies[l,4] = 1 then in future version when i have 4 furies online
                begin}
                  for m:= 1 to fury_image.images[image].y do
                  begin
                     furies[m,1]:=curx+ (320*(cury+m-1));{goodies array.x.y instead of global x y pos}
                     furies[m,2]:=curx+ fury_image.images[image].x-1+(320*(cury+m-1));
                  end;

                  for a:= 1 to ysize do
                  begin
                   for m:= 1 to fury_image.images[image].y do
                   begin
                    if (furies[m,1]<=sprites[a]) and (furies[m,2]>=sprites[a]) then
                    begin
                     if (furies[m,1]<>0) and (furies[m,2]<>0) and (grid[i,j].active=1) and (life>0) and (grid[i,j].x<=320) then
                     begin
                          dec(life);
                          grid[i,j].active:=2;
                          grid[i,j].sprite:=1;
                          boomtime:=1;
                          dec(firetype);
                          if firetype = 0 then firetype := 1;
                          cury:=90;
                          curx:=1;
                          ptime:=0;
                          dec(enemies_on);
                          for e:= 1 to maxshotsallowed do
                          fire[e,4]:=0;
                     end;
                    end;
                   end;
                  end;
   {            end;}
           end;
         end;
       end;
   end;
end;

Procedure enemy_init(var buf:buffer);
var i:byte;
    xg,yg:byte;
    xp,yp:word;
    entype,e: byte;
begin
     if enemies_on = 0 then
     begin
          randomize;
          enemies_on:=random(maxenemy)+1;
          e:=enemies_on;
          while e>0 do
          begin
             xg:=random(xgrid)+1;
             yg:=random(ygrid)+1;
             if grid[xg,yg].active = 0 then
             begin
                  dec(e);
                  grid[xg,yg].x:=321+(xg-1)*25;
                  grid[xg,yg].y:=25+(yg-1)*20;
                  grid[xg,yg].active:=1;
                  grid[xg,yg].enemy_type:=random(enemies_in_data_base)+1;
                  entype:=grid[xg,yg].enemy_type;

                  grid[xg,yg].sprite:=random(allenemy[entype].images_num)+1;
                  grid[xg,yg].score:=10*entype;
                  grid[xg,yg].life:=2*entype;
                  grid[xg,yg].active:=1;

             end;
          end;
     end;
end;

Procedure enemy_copy(var buf:buffer);
var i,j : byte;
    entype: byte;
    t,t2:integer;
begin
     inc(enemy_time);
     for i:= 1 to xgrid do
     begin
          for j:= 1 to ygrid do
          begin
               if grid[i,j].active = 1 then
               begin
                    entype:=grid[i,j].enemy_type;

                    put_image(grid[i,j].x,grid[i,j].y,grid[i,j].sprite,buf,allenemy[entype],true);
                    t:=1-allenemy[entype].images[grid[i,j].sprite].x;

                    dec(grid[i,j].x,2);
                    t2:=grid[i,j].x;
                    if (t2<t) then
                    if grid[i,j].active=1 then
                    begin
                         dec(enemies_on);
                         grid[i,j].active:=0;
                    end;
                    if enemy_time>2 then
                    begin
                       inc(grid[i,j].sprite);
                          if (grid[i,j].sprite>allenemy[entype].images_num) then
                             grid[i,j].sprite:=1;
                    end;
               end;
               if grid[i,j].active = 2 then
               begin
                    put_image(grid[i,j].x,grid[i,j].y,grid[i,j].sprite,buf,boom,true);
                    inc(boomtime);
                    if boomtime=5 then
                    begin
                    boomtime:=1;
                    inc(grid[i,j].sprite);
                    if grid[i,j].sprite>boom.images_num then
                       grid[i,j].active:=0;
                    end;
               end;
          end;
     end;
     if enemy_time>2 then enemy_time := 0;
end;

Procedure DeloadMda(var sprite:sprt);
var i:integer;
begin
     for i:= 1 to max_sprites do
     begin
          if sprite.images[i].active=1 then
          begin
               freemem(sprite.images[i].p,sprite.images[i].x*sprite.images[i].y);
               sprite.images[i].x:=0;
               sprite.images[i].y:=0;
               sprite.images[i].active:=0;
          end;
     end;
end;

Procedure choose_screen(place:byte);
begin
     fillchar(buf^,maxbuf,0);
     put_image(55,20,1,buf,tiny,false);
     if place = 1 then
        put_image(150,1,2,buf,arrow,false);
     if place = 2 then
        put_image(30,90,3,buf,arrow,false);
     if place = 3 then
        put_image(160,180,1,buf,arrow,false);
     if place = 4 then
        put_image(270,90,4,buf,arrow,false);

     WaitRetrace;
     move32fast(buf^,mem[$a000:00],maxbuf);
end;

procedure choose_fury(var col:byte);
var key:char;
    place:byte;
begin
     col:=0;
     loadmda('bigpic',tiny);
     loadmda('arrow',arrow);
     loadpal('intro');
     place:=1;
     choose_screen(place);
     key:=#33;
     while col=0 do
     begin
          key:=readkey;
          if key=#0 then key:=readkey;
          case key of
               #72   : begin
                            place:=1;
                       end;
               #80   : begin
                            place:=3;
                       end;
               #75   : begin
                            place:=2;
{                           dec(place);
                            if place=0 then place:=4;}
                       end;
               #77   : begin
                            place:=4;
{                           inc(place);
                            if place>4 then place:=1;}
                       end;
               #13   : begin
                            col:=place;
                       end;
          end;
          choose_screen(place);
     end;
     fillchar(buf^,maxbuf,0);
     move32fast(buf^,mem[$a000:00],maxbuf);
     DeloadMda(arrow);
     DeloadMda(tiny);
end;

Procedure Fury_color(col:byte);
begin
     if col=4 then {red}
     begin
          palette[11,1]:=60; {rest of face}
          palette[11,2]:=0; {rest of face}
          palette[11,3]:=0; {rest of face}
          palette[141,1]:=60; {pop}
          palette[141,2]:=0; {pop}
          palette[141,3]:=0; {pop}
          palette[2,1]:=60; {heart}
          palette[2,2]:=0; {heart}
          palette[2,3]:=0; {heart}
          palette[25,1]:=48; {head and chin}
          palette[25,2]:=0; {head and chin}
          palette[25,3]:=0; {head and chin}
          palette[18,1]:=60; {fire}
          palette[18,2]:=0; {fire}
          palette[18,3]:=0; {fire}
          palette[14,1]:=30; {fire outer}
          palette[14,2]:=0; {fire outer}
          palette[14,3]:=0; {fire outer}
          {14 in fireis outer brown thing}
     end;
     if col=2 then {green}
     begin
          palette[11,1]:=0; {rest of face}
          palette[11,2]:=60; {rest of face}
          palette[11,3]:=0; {rest of face}
          palette[141,1]:=0;
          palette[141,2]:=60;
          palette[141,3]:=0;
          palette[2,1]:=0;
          palette[2,2]:=60;
          palette[2,3]:=0;
          palette[25,1]:=0; {head and chin}
          palette[25,2]:=48; {head and chin}
          palette[25,3]:=0; {head and chin}
          palette[18,1]:=0; {fire}
          palette[18,2]:=60; {fire}
          palette[18,3]:=0; {fire}
          palette[14,1]:=0; {fire outer}
          palette[14,2]:=30; {fire outer}
          palette[14,3]:=0; {fire outer}
     end;
     if col=1 then {blue}
     begin
          palette[11,1]:=0;
          palette[11,2]:=0;
          palette[11,3]:=60;
          palette[141,1]:=0;
          palette[141,2]:=0;
          palette[141,3]:=60;
          palette[2,1]:=0;
          palette[2,2]:=0;
          palette[2,3]:=60;
          palette[25,1]:=0;
          palette[25,2]:=0;
          palette[25,3]:=48;
          palette[18,1]:=0; {fire}
          palette[18,2]:=0; {fire}
          palette[18,3]:=60; {fire}
          palette[14,1]:=0; {fire outer}
          palette[14,2]:=0; {fire outer}
          palette[14,3]:=30; {fire outer}
     end;
     if col=3 then {yellow}
     begin
          palette[11,1]:=63;
          palette[11,2]:=59;
          palette[11,3]:=0;
          palette[141,1]:=63;
          palette[141,2]:=59;
          palette[141,3]:=0;
          palette[2,1]:=63;
          palette[2,2]:=59;
          palette[2,3]:=0;
          palette[25,1]:=63;
          palette[25,2]:=53;
          palette[25,3]:=0;
          palette[18,1]:=63; {fire}
          palette[18,2]:=53; {fire}
          palette[18,3]:=0; {fire}
          palette[14,1]:=33; {fire outer}
          palette[14,2]:=23; {fire outer}
          palette[14,3]:=0; {fire outer}
     end;
     Set_Palette;
end;

procedure image_pop(var buf:buffer);
begin
   if ptime<7 then
   begin
     inc(show);
     if show>2 then
     begin
          show:=0;
          inc(ptime);
          if ptime=7 then
          begin
               inc(curx,8);
               inc(cury,6);
          end
     end;
     put_image(curx,cury,ptime,buf,pop,true)
   end
   else
       put_image(curx,cury,image,buf,fury_image,true);
end;

procedure life_check(var buf:buffer);
var i:byte;
begin
     for i:= 0 to life-1 do
     begin
     put_image(306-(i*15),1,1,buf,heart,true);
     end;
     {ask brian if 9xheart or heart heart.... is better}
end;

procedure time_check(var buf:buffer); {9:60 limit !! }
begin
   inc(truetime);
   if truetime = 40 then
   begin
     truetime:=0;
     inc(secs);
     if secs>9 then
     begin
          secs:=0;
          inc(tsecs);
          if tsecs>5 then
          begin
               tsecs:=0;
               inc(mins);
               if (mins>9) then
               begin
                  mins:=0;
                  inc(tmins);
                  if tmins>5 then tmins:=0;
               end;
          end;
     end;
   end;
     put_image(277,190,tmins+1,buf,num,true);
     put_image(284,190,mins+1,buf,num,true);
     put_image(291,190,11,buf,num,true); {':'}
     put_image(298,190,tsecs+1,buf,num,true);
     put_image(305,190,secs+1,buf,num,true);
end;

procedure copy_clock(var buf:buffer);
begin
     put_image(254,185,clockpos,buf,clock,true);
     inc(double);
     if double=6 then
     begin
          inc(clockpos);
          if clockpos>8 then clockpos:=1;
          double:=1;
     end;
end;

Procedure die(col:byte);
var i,p1,p2:byte;
begin
     {none = black}
     {1 = red}
     {2 = green}
     {3 = blue}
     {1 and 2 = yellow }
     {1 ans 3 = purple }
     {2 and 3 = lightblue = tchelet}
     {1 & 2 & 3 = gray}

     if col in [0,1,2] then
     begin
          case col of
          0 :begin
                 p1:=1;
                 p2:=3;
             end;
          1 :begin
                  p1:=3;
                  p2:=1;
             end;
          2 :begin
                  p1:=2;
                  p2:=1;
             end;
          end;
          for i:= 3 to 33 do
          begin
               palette[i,p1]:= palette[i,p2];
               palette[i,p2]:= 0;
          end;
          set_palette;
     end;

     if col in [3,5] then
     begin
          case col of
          3 :begin
                  p1:=2;
                  p2:=1;
             end;
          5 :begin
                  p1:=3;
                  p2:=1;
             end;
          end;
          for i:= 3 to 33 do
              palette[i,p1]:= palette[i,p2];
          set_palette;
     end;

     if col = 6 then
     begin
          p1:=2;
          p2:=3;
          for i:= 3 to 33 do
          begin
              palette[i,p1]:= palette[i,1];
              palette[i,p2]:= palette[i,1];
              palette[i,1]:= 0;
          end;
          set_palette;
     end;

     if col = 7 then
     begin
          for i:= 3 to 33 do
          begin
              palette[i,2]:= palette[i,1];
              palette[i,3]:= palette[i,1];
          end;
          set_palette;
     end;
     {--- clear temp buffer ----}
     {--- clear temp buffer ----}
     for i:= 1 to 12 do
     begin
          fillchar(buf^,maxbuf,0);
          put_image(100,70,i,buf,dead,false);
          WaitRetrace;
          move32fast(buf^,mem[$a000:0],maxbuf);
          delay(100);
     end;
end;

end.
