unit firepo;
interface

Procedure Init_Fire;
Procedure Move_Fire;
Procedure Copy_Fire;
Procedure Type1;

implementation
uses variable,vga;

Procedure Type1;
var tempx:integer;
begin
if firetype > 0 then
begin
     tempx:=curx+fury_image^.images[image].x+2;
     if (tail<maxshotsallowed) and ((tail = 0) or (tempx+fireball^.images[firetype].x<=fire[tail,2])) then
     begin
          inc(tail);
          fire[tail,1]:= (curx+fury_image^.images[image].x+2);
          fire[tail,2]:= (curx+fury_image^.images[image].x+2);
          if firetype=4 then
             fire[tail,3]:= (cury+7)
          else
             fire[tail,3]:= (cury+8);
          fire[tail,4]:=1;
     end;
end;
end;


Procedure Init_Fire;
var i :word;
begin
     for i:= 1 to maxshots do
     begin
          fire[i,1]:=0;
          fire[i,2]:=0;
          fire[i,3]:=0;
          fire[i,4]:=0;
     end;
end;

Procedure Move_Fire;
var i,j:word;
begin
 if tail>0 then
     for i:= 1 to tail do
     begin
          if ((shotspeed+(fire[i,2]+fire[i,3]*320) > ((fire[i,3]+1)*320)-fireball^.images[firetype].x)) or (fire[i,4]=0) then
          {overlining the limit line}
          begin
             fire[i,1]:=0; {kill shot}
             fire[i,2]:=0; {kill shot}
             fire[i,3]:=0; {kill shot}
             fire[i,4]:=0; {kill shot}
{ decided to decrease shots only after i shrink tor
 to save afficiancy in the next for so i dont have to go over maxshots
 only tail :)                                                          }
          end
          else
              if (fire[i,1] <> 0) and (fire[i,2] <> 0) and (fire[i,3] <> 0) and (fire[i,4]=1) then
              if (shotspeed+(fire[i,2]+fire[i,3]*320) <= ((fire[i,3]+1)*320)-fireball^.images[firetype].x) then
                 inc(fire[i,2],shotspeed);
     end;
     for i:= 1 to tail do
     begin
          if ((fire[i,1] = 0) and (fire[i,2] = 0) and (fire[i,3] = 0)) or (fire[i,4]=0) then
          begin
               for j:= i to tail-1 do
               begin
                    fire[j,1]:=fire[j+1,1];
                    fire[j,2]:=fire[j+1,2];
                    fire[j,3]:=fire[j+1,3];
                    fire[j,4]:=fire[j+1,4];
               end;
               dec(tail);
          end;
     end;

end;

Procedure Copy_Fire;
var i:word;
begin
    if tail>0 then
     for i:= 1 to tail do
     begin
          if (fire[i,1]>0) and (fire[i,4]=1) then
          begin
             put_image(fire[i,2],fire[i,3],firetype,buf_,fireball,true);
          end
          else fire[i,4]:=0;
     end;
end;


end.