unit stars;

interface
uses variable;

Procedure Init_Stars;
Procedure Copy_Stars(var buf:buffer);
Procedure Move_Stars_Up;
Procedure Move_Stars_Down;
Procedure Move_Stars_Right;
Procedure Move_Stars_Left;

implementation

uses crt;

Procedure Init_Stars;
var i:word;
begin
     randomize;
     for i:= 1 to maxstars do
     begin
          stars_vec[i]  := random(320) + random(200) * 320; {not x+y*320}
          stars_speed[i] := random(starslayer)+1;
     end;
end;

Procedure Move_Stars_Right;
var i:word;
begin
     for i:= 1 to maxstars do
     begin
          if ((stars_vec[i]+1) mod 320) = 0 then
             stars_vec[i] := stars_vec[i]-320;
          stars_vec[i] := stars_vec[i]+stars_speed[i];
     end;
end;


Procedure Move_Stars_Up;
var i:word;
    sum : word ;
begin
     for i:= 1 to maxstars do
     begin
           if ((stars_vec[i]>=1) and (stars_vec[i]<=320)) then
             stars_vec[i] := 64000-(320-stars_vec[i]);
          stars_vec[i] := stars_vec[i]-(stars_speed[i]*320);
     end;
end;


Procedure Move_Stars_Down;
var i:word;
    sum : word ;
begin
     for i:= 1 to maxstars do
     begin
           if ((stars_vec[i]>=63680) and (stars_vec[i]<=64000)) then
             stars_vec[i] := 64000-stars_vec[i];
          stars_vec[i] := stars_vec[i]+(stars_speed[i]*320);
     end;
end;

Procedure Move_Stars_Left;
var i:word;
begin
     for i:= 1 to maxstars do
     begin
          if (stars_vec[i] mod 320) = 0 then
             stars_vec[i] := stars_vec[i]+320;
          stars_vec[i] := stars_vec[i]-stars_speed[i];
     end;
end;

Procedure Copy_Stars(var buf:buffer);
var i:word;
    c:byte;
begin
     for i:= 1 to maxstars do
     begin
          if stars_speed[i]=1 then c:=layer1color;
          if stars_speed[i]=2 then c:=layer2color;
          if stars_speed[i]=3 then c:=layer3color;
          buf^[stars_vec[i]]:=c;
     end;
end;

end.
