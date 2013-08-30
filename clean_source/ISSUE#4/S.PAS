unit revspec;
interface
uses revconst;

procedure write_bar_ways(num,b,t:integer; tag:tag; menu:subscr);
procedure write_bar(b,t:integer; tag:tag; menu:subscr);

implementation
uses crt,revgfx;
const backmain=black;
      backsec=blue;
      formain=lightblue;
      forsec=darkgray;
      fortrd=lightgray;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Procedures Related To Ansi & The Menu Highlight Bars.   *)
(****************************************************************************)
procedure write_bar_ways(num,b,t:integer; tag:tag; menu:subscr);


procedure write_bar_way5(b,t:integer);
var
   i,a,x,y:integer;
   str2,str:st22;
   i1,i2,j,k,l:integer;
begin
{write_bar(topics+1,0,topics);}
     textbackground(black);
     textcolor(backmain);
     textcolor(formain);
     x:=mx+22;
     y:=my;
          for j:= 1 to 22 do
          begin
               i1:=1;
               i2:=10;
               for l:= 1 to 9 do
               begin
                    str2:=menu[i1];
                    str:=menu[i2];
                    t:=1;
                    for k:= j downto 1 do
                    begin
                         if (str[t]='þ') and ((tag[i2]=0) or (tag[i2]=2)) then
                              textcolor(forsec)
                         else
                              textcolor(backsec);
                         if (str[t]<>'þ') then
                              textcolor(forsec);
                         gotoxy(x+(22-k+1),y+l-1);
                         if t=1 then
                            write(str[1])
                         else
                         begin
                         {-------------------------}
                         if (tag[i2]=1) or (tag[i2]=2) then
                         textcolor(lightgray);
                         {-------------------------}
                         write(str[t]);
                         end;
                         {-----------------------------------}
                         if (str[22-t+1]='þ') and ((tag[i1]=0) or (tag[i1]=2)) then
                              textcolor(forsec)
                         else
                             textcolor(backsec);
                         if (str[22-t+1]<>'þ') then
                              textcolor(forsec);
                         gotoxy(x-(22-k+1),y+l-1);
                         if 22-t+1=1 then
                            write(str2[1])
                         else
                         begin
                         {-------------------------}
                         if (tag[i1]=1) or (tag[i1]=2) then
                         textcolor(lightgray);
                         {-------------------------}
                         write(str2[22-t+1]);
                         end;
                         t:=t+1;
                    end;
                    inc(i1);inc(i2);
               end;
          delay(50);
          end;
write_bar(b,topics,tag,menu);
end;



procedure write_bar_way4(b,t:integer);
var
   nav:na;
   i,a,x,y:integer;
   str2,str:st22;
   i1,i2,j,k,l:integer;
begin
{write_bar(topics+1,0,topics);}
{nav:=config^.notavarr[e];}
     textbackground(black);
     textcolor(backmain);
     textcolor(formain);
     x:=mx+22;
     y:=my;
          for j:= 1 to 22 do
          begin
               i1:=1;
               i2:=10;
               for l:= 1 to 9 do
               begin
{                    str2:=config^.subscreen[e][i1];
                    str:=config^.subscreen[e][i2];  }
                    t:=1;
                    for k:= j downto 1 do
                    begin
                         if (str[22-t+1]='þ') and (i2 in nav) then
                              textcolor(forsec)
                         else
                              textcolor(backsec);
                         if (str[22-t+1]<>'þ') then
                              textcolor(forsec);
                         gotoxy(x+k,y+l-1);
                         if 22-t+1=1 then
                            write(str[1])
                            else
                         begin
{                         if i2 in config^.tag[e] then}
                            textcolor(lightgray);
                            write(str[22-t+1]);
                         end;
                         {-------------------------}
                         if (str[t]='þ') and (i1 in nav) then
                              textcolor(forsec)
                         else
                             textcolor(backsec);
                         if (str[22-t+1]<>'þ') then
                              textcolor(forsec);
                         gotoxy(x-(22-k+1),y+l-1);
                         if t=1 then
                            write(str2[1]);
                         {-------------------------}
{                         if i1 in config^.tag[e] then}
                         textcolor(lightgray);
                         {-------------------------}
                         write(str2[22-t+1]);
                         t:=t+1;
                    end;
                    inc(i1);inc(i2);
               end;
          delay(50);
          end;
write_bar(b,topics,tag,menu);
end;


procedure write_bar_way2(b,t:integer);
var
   i,a,x,y:integer;
   str2,str:st22;
   i1,i2,j,k,l:integer;
begin
{nav:=config^.notavarr[e];}
     textbackground(black);
     textcolor(backmain);
     textcolor(formain);
     x:=mx+22;
     y:=my;
          for j:= 1 to 22 do
          begin
               i1:=1;
               i2:=10;
               for l:= 1 to 9 do
               begin
                    str2:=menu[i1];
                    str:=menu[i2];
                    t:=1;
                    for k:= j downto 1 do
                    begin
                         if (str[22-t+1]='þ') and ((tag[i2]=0) or (tag[i2]=2)) then
                              textcolor(forsec)
                         else
                              textcolor(backsec);
                         if (str[22-t+1]<>'þ') then
                              textcolor(forsec);
                         gotoxy(x+k,y+l-1);
                         if 22-t+1=1 then
                            write(str[1])
                         else
                         begin
                         if (tag[i2]=1) or (tag[i2]=2) then
                         textcolor(lightgray);
                         write(str[22-t+1]);
                         end;
                         if (str[t]='þ') and ((tag[i1]=0) or (tag[i1]=2)) then
                              textcolor(forsec)
                         else
                             textcolor(backsec);
                         if (str[t]<>'þ') then
                              textcolor(forsec);
                         gotoxy(x-k,y+l-1);
                         if t=1 then
                         write(str2[1])
                         else
                         begin
                         if (tag[i1]=1) or (tag[i1]=2) then
                         textcolor(lightgray);
                         write(str2[t]);
                         end;
                         t:=t+1;
                    end;
                    inc(i1);inc(i2);
               end;
          delay(50);
          end;
write_bar(b,topics,tag,menu);
end;

begin
if num=2 then
write_bar_way2(b,t);
if num=3 then
write_bar_way5(b,t);
if num=4 then
write_bar_way5(b,t);
end;


procedure write_bar(b,t:integer; tag:Tag; menu:subscr);
var
   i,a,x,y:integer;
   str:st22;
begin
textcolor(backmain);
textbackground(forsec);
x:=MX;
y:=my;
for a := 1 to 18 do
  begin
    if b=a then
    begin
        gotoxy(x-1,y);
        str:=menu[a];
        textbackground(backsec);
        write(' ');
        textcolor(forsec);
        write(str[1]);
        {-------------------------}
        if (tag[a] = 1) or (tag[a] = 2) then
           textcolor(lightgray);
        {-------------------------}
        for i:= 2 to length(str) do
            write(str[i]);
    end
    else
    begin
         gotoxy(x-1,y);
        str:=menu[a];
         textbackground(forsec);
         write(' ');
        if (tag[a] = 1) or (tag[a] = 2) then
            textcolor(forsec)
         else
             textcolor(backsec);
         write(str[1]);
         textcolor(formain);
        {-------------------------}
        if (tag[a] = 1) or (tag[a] = 2) then
           textcolor(lightgray);
        {-------------------------}
         textcolor(forsec);
        {-------------------------}
        if (tag[a] = 1) or (tag[a] = 2) then
           textcolor(lightgray);
        {-------------------------}
         for i:= 2 to length(str) do
             write(str[i]);
    end;
    inc(y);
    if a=9 then
    begin
     x:=mx+23;
     y:=my;
    end;
  end;
end;




end.