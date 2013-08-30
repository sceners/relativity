{$m 64000,0,640000}
Program SNOW;
uses dos,tech,variable,crt,vga,cmpics;
var a:boolean;
    i,col:byte;

const
      x1 = 0;   y1 = 99;
      x2 = 119; y2 = 199;
      xpos = 30; ypos = -20;
      wx1 = 2;

var line : array[1..x2-x1] of byte;
    buf2 : array[1..x2-x1,1..y2-y1] of byte;

Procedure Initfire;
var i:integer;
begin
     for i:= 1 to x2-x1 do
     begin
          col:=random(256);
          line[i]:=col;
     end;
end;

Procedure UpFire;
var i,j:word;  points,sum,p:word;
    s : array[1..9] of byte;
    ok:boolean;

begin
               p:=random(1); {beepint backround}
     for i:= wx1 to x2-x1-wx1 do
     begin
          for j:= 1 to y2-y1-1 do
          begin
{              sum:=sum+buf2[i-1,j];           {1}
{              sum:=sum+buf2[i,j];             {2}
{              sum:=sum+buf2[i+1,j];           {3}
               sum:=sum+buf2[i-1,j+1];         {4}
               sum:=sum+buf2[i,j+1];           {5}
               sum:=sum+buf2[i+1,j+1];         {6}
{              sum:=sum+buf2[i-1,j];           {7}
{              sum:=sum+buf2[i,j];             {8}
{              sum:=sum+buf2[i+1,j];           {9}
               sum:= sum div 4 +p;
               buf2[i,j]:= sum;
          end;
     end;
     for i:= 1 to x2-x1 do
     begin
          buf2[i,j+1]:=line[i];
     end;
end;

Procedure PutFire;
var i:word;
    j:word;
begin
     for i:= 1 to x2-x1 do
     begin
          for j:= 4 to y2-y1-2 do
          begin
               buf^[(x1+i+xpos)+((j+y1+ypos)*320)]:=buf2[i,j];
          end;
     end;
end;

begin
     {------- init everything -------}
     getmem(buf,maxbuf);
     fillchar(buf^,maxbuf,0);
     initvga;
     loadpalette; {loads the fire palette}
     while (raw_key<>esc)  do
     begin

          raw_key := port[$60];
          MEMW[$0000:$041C] := MEMW[$0000:$041A];

          {--- clear temp buffer ----}

          {--- clear temp buffer ----}

          randomize;
          initfire;
          upfire;
          PutFire;

          {------ screen output -------}
          WaitRetrace;
          move32fast(buf^,mem[$a000:0],maxbuf);
          {------ screen output -------}
     end;

     freemem(buf,maxbuf);
     closevga;
     clrscr;

end.


{               sum:=0;
               for i := 1 to points do
               begin
                    case s[i] of
                    1 : sum:=sum+buf2[i-1,j];
                    2 : sum:=sum+buf2[i,j];
                    3 : sum:=sum+buf2[i+1,j];
                    4 : sum:=sum+buf2[i-1,j+1];
                    5 : sum:=sum+buf2[i,j+1];
                    6 : sum:=sum+buf2[i+1,j+1];
                    7 : sum:=sum+buf2[i-1,j+2];
                    8 : sum:=sum+buf2[i,j+2];
                    9 : sum:=sum+buf2[i+1,j+2];
                    end;
               end;
               sum:=sum div (points);}


{     points := random (8)+1;
     i:=1;
     while i<=points do
     begin
          p:= random(8)+1;
          ok:=true;
          for j:= 1 to i-1 do
          begin
               if s[i] = p then ok:=false;
          end;
          if ok then
          begin
               s[i]:=p;
               inc(i);
          end;
     end;}