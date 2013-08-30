unit moves;
interface
uses variable;

Procedure Which_Move(key:byte);

implementation
uses stars,firepo,revvoc;

Procedure Which_Move(key:byte);
begin
case key of
     7     : if cheater then invinsible:=true;
     8     : if cheater then invinsible:=false;
     6     : fireflag:= not fireflag;
     2     : if cheater then firetype:=1;
     3     : if cheater then firetype:=2;
     4     : if cheater then firetype:=3;
     5     : if cheater then firetype:=4;
     space : begin
                  image:=2;
{                  if tail< maxshotsallowed then loadandplay_name(vocs[7]);}
                  type1;
                  spacepushed:=true; {<= should be true for continues}
             end;
     despace :
              spacepushed:=false;
     up    : begin
                  side:= 8;
                  dec(cury,2);
             end;
     down  : begin
                  side:= 2;
                  inc(cury,2);
             end;
     left  : begin
                  side:= 4;
                  dec(curx,2);
             end;
     right : begin
                  side:= 6;
                  inc(curx,2);
              end;
     pgup  : begin
                  side:= 9;
                  inc(curx,2);
                  dec(cury,2);
              end;
     pgdn  : begin
                  side:= 3;
                  inc(curx,2);
                  inc(cury,2);
               end;
     endk  :begin
                  side:= 1;
                  dec(curx,2);
                  inc(cury,2);
             end;
     home  : begin
                  side:= 7;
                  dec(curx,2);
                  dec(cury,2);
               end;
     ins   : begin
             end;
     plus : begin
                  inc(starslayer);
                  if starslayer>10 then starslayer:=10;
                  Init_Stars;
             end;
     minus : begin
                  dec(starslayer);
                  if starslayer<3 then starslayer:=3;
                  Init_Stars;
             end;
end;

    if spacepushed then
    begin
         image:=2;
         type1;
    end;

    if cury<15 then cury:=15;
    if (curx+fury_image^.images[image].x>200) then curx:=200-fury_image^.images[image].x;
    if curx<1 then curx:=1;
    if (fury_image^.images[image].y+cury>180) then cury:=180-fury_image^.images[image].y;

end;

end.