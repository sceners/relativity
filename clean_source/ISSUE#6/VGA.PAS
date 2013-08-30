unit vga;
interface
uses variable;

procedure loadpal(name: string);
procedure loadmda(name: string; var sprite:sprt);
procedure Set_Palette;
procedure setcolor(nr,r,g,b: byte);
procedure putpix(x,y : integer; c: byte; var buf:buffer);
Procedure Put_image(x,y,image:word; var buf:buffer; spr_image:sprt; trans:boolean);


implementation
uses files,tech,sprite;

procedure putpix(x,y : integer; c: byte; var buf:buffer);
begin
     buf^[x+320*y]:=c;
end;

Procedure Put_image(x,y,image:word; var buf:buffer; spr_image:sprt; trans:boolean);
var i,j,exist,xcord,ycord,c:word;
begin
 exist:=spr_image.images[image].active;
 if exist=1 then
 begin
      xcord:=spr_image.images[image].x;
      ycord:=spr_image.images[image].y;
      for i:= 1 to ycord do
      begin
          for j:= 1 to xcord do
          begin
           if (x+j-1<=320) and (y+i-1<=200) and (x+j-1>=1) and (y+i-1>=1) then
           begin
               c:=mem[seg(spr_image.images[image].p^):ofs(spr_image.images[image].p^)+(i-1)*xcord+j-1];
               if trans then
                  if c>0 then
                  begin
                       putpix(x+j-1,y+i-1,0,buf); {clear pix}
                       putpix(x+j-1,y+i-1,c,buf); {invisible}
                  end;
               if not trans then
               begin
                    putpix(x+j-1,y+i-1,0,buf); {clear pix}
                    putpix(x+j-1,y+i-1,c,buf); {invisible}
               end;
           end;
          end;
      end;
 end;
end;

procedure setcolor(nr,r,g,b: byte); assembler; { set rgb val to color nr }
asm
 mov dx,3c8h
 mov al,nr
 out dx,al
 inc dx
 mov al,r
 out dx,al
 mov al,g
 out dx,al
 mov al,b
 out dx,al
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�}
procedure loadpal(name: string); { load .pal file and set palette }
var i:integer;
    f:file;
begin
if fileexists(name+'.pal') then
begin
 assign(f,name+'.pal');
 reset(f,1);
 blockread(f,palette,768);
 palette[0,1]:=0;
 palette[0,2]:=0;
 palette[0,3]:=0;
 close(f);
 SET_PALETTE;
end;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�}
procedure loadmda(name: string; var sprite:sprt);
var f,ff: file;
    ch,i: integer;
    n:word;
    tmp: ar17;
    sum:longint;

begin
sum:=0;
if fileexists(name+'.mda') then
begin
      DeloadMda(sprite);
      assign(f,name+'.mda');
      reset(f,1);
      blockread(f,tmp,sizeof(sig));
      sum:=sum+sizeof(sig);
      if sigok(tmp) then
      begin
          ch:=0;
           while not eof(f) do
           begin
                 blockread(f,ch,1);
                 sum:=sum+sizeof(ch);
                 blockread(f,sprite.images[ch].x,1);
                 blockread(f,sprite.images[ch].y,1);
                 sum:=sum+sizeof(sprite.images[ch].y);
                 sum:=sum+sizeof(sprite.images[ch].x);
                 sprite.images[ch].active:=1;
                 if memavail > sprite.images[ch].x*sprite.images[ch].y then
                    getmem(sprite.images[ch].p,sprite.images[ch].x*sprite.images[ch].y)
                 else
                 begin
                      writeln('not enough mem');
                      halt;
                 end;
                 sum:=sum+sprite.images[ch].y*sprite.images[ch].x;
                 blockread(f,sprite.images[ch].p^,sprite.images[ch].x*sprite.images[ch].y,n);
            end;
            close(f);
            sprite.images_num:=ch;
      end;
end;
end;

procedure Set_Palette;
var i:integer;
begin
     for i:=0 to 255 do setcolor(i,palette[i,1],palette[i,2],palette[i,3]);
end;

end.