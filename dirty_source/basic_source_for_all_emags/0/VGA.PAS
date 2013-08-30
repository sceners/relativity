unit vga;
interface
uses variable;

procedure loadpal(name: string);
procedure loadmda(name: string; var sprite:sprt);
procedure Set_Palette;
procedure setcolor(nr,r,g,b: byte);
procedure putpix_(x,y : integer; c: byte; var buf_:buffer_);
Procedure Put_image(x,y,image:word; var buf_:buffer_; spr_image:sprt; trans:boolean);
procedure loadpalP(name: string); { load .pal file and set palette }
procedure loadmdaP(name: string; var sprite:sprt);

implementation
uses files,tech,sprite,revdat,revconst;

procedure putpix_(x,y : integer; c: byte; var buf_:buffer_);
begin
     buf_^[x+320*y]:=c;
end;

Procedure Put_image(x,y,image:word; var buf_:buffer_; spr_image:sprt; trans:boolean);
var i,j,exist,xcord,ycord,c:word;
begin
 exist:=spr_image^.images[image].active;
 if exist=1 then
 begin
      xcord:=spr_image^.images[image].x;
      ycord:=spr_image^.images[image].y;
      for i:= 1 to ycord do
      begin
          for j:= 1 to xcord do
          begin
           if (x+j-1<=320) and (y+i-1<=200) and (x+j-1>=1) and (y+i-1>=1) then
           begin
               c:=mem[seg(spr_image^.images[image].p^):ofs(spr_image^.images[image].p^)+(i-1)*xcord+j-1];
               if trans then
                  if c>0 then
                  begin
                       putpix_(x+j-1,y+i-1,0,buf_); {clear pix}
                       putpix_(x+j-1,y+i-1,c,buf_); {invisible}
                  end;
               if not trans then
               begin
                    putpix_(x+j-1,y+i-1,0,buf_); {clear pix}
                    putpix_(x+j-1,y+i-1,c,buf_); {invisible}
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
procedure loadpalP(name: string); { load .pal file and set palette }
var i:integer;
    f:file;
    size:word;
begin
     name:=name+'.PAL';
      for i:= 1 to length(name) do
      name[i]:=upcase(name[i]);
     getmem(pali,768);
     ExtractPointerFromDat(name,game_file,pali,size);
     move32fast(mem[seg(pali^):ofs(pali^)],palette,768);
     SET_PALETTE;
     freemem(pali,768)
end;

procedure loadmdaP(name: string; var sprite:sprt);
var f,ff: file;
    i: byte;
    ch:word;
    n:word;
    tmp: ar17;
    p,size:word;
    x,y:byte;
    sum_:word;

begin
      name:=name+'.MDA';
      for i:= 1 to length(name) do
      name[i]:=upcase(name[i]);
      sum_:=0;
      DeloadMda(sprite);
      getmem(pali,$ffff);
      ExtractPointerFromDat(name,game_file,pali,size);
      move32fast(mem[seg(pali^):ofs(pali^)],tmp,sizeof(sig));
      sum_:=sum_+sizeof(sig);
      if sigok(tmp) then
      begin
           ch:=0;
           if sprite=nil then
              getmem(sprite,sizeof(sprite^));
           for i:= 1 to max_sprites do
           sprite^.images[i].active:=0;
           while sum_<size do
           begin
                 move32fast(mem[seg(pali^):ofs(pali^)+sum_],ch,1);
                 sum_:=sum_+1;
                 move32fast(mem[seg(pali^):ofs(pali^)+sum_],x,1);
                 sprite^.images[ch].x:=x;
                 sum_:=sum_+1;
                 move32fast(mem[seg(pali^):ofs(pali^)+sum_],y,1);
                 sprite^.images[ch].y:=y;
                 sum_:=sum_+1;
                 sprite^.images[ch].active:=1;
                 if memavail > sprite^.images[ch].x*sprite^.images[ch].y then
                 begin
{                   if sprite^.images[ch].p = nil then
                    begin} {.p automaticaly gets seg:ofs .. so u cant check for nil}
                    getmem(sprite^.images[ch].p,sprite^.images[ch].x*sprite^.images[ch].y);
{                   end;}
                 end;
{                 else
                 begin
                      asm mov ax,03
                      int 10h
                      end;
                      writeln('not enough mem');
                      halt;
                 end;}
                 move32fast(mem[seg(pali^):ofs(pali^)+sum_],sprite^.images[ch].p^,sprite^.images[ch].y*sprite^.images[ch].x);
                 sum_:=sum_+(y*x);
{                 inc(sum,sprite^.images[ch].y*sprite^.images[ch].x);}
            end;
            sprite^.images_num:=ch;
      end;
{      ELSE
      BEGIN
           asm mov ax,03
                int 10h end;
           writeln('Error in furydata.mdb');
           halt;
      end;}
      freemem(pali,$ffff);
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�}
procedure loadmda(name: string; var sprite:sprt);
var f,ff: file;
    i: integer;
    ch:byte;
    n:word;
    tmp: ar17;

begin
if fileexists(name+'.mda') then
begin
      DeloadMda(sprite);
      assign(f,name+'.mda');
      reset(f,1);
      blockread(f,tmp,sizeof(sig));
      if sigok(tmp) then
      begin
           ch:=0;
           if sprite=nil then
              getmem(sprite,sizeof(sprite^));
           for i:= 1 to max_sprites do
               sprite^.images[i].active:=0;
           while not eof(f) do
           begin
                 blockread(f,ch,1);
                 blockread(f,sprite^.images[ch].x,1);
                 blockread(f,sprite^.images[ch].y,1);
                 sprite^.images[ch].active:=1;
                 if memavail > sprite^.images[ch].x*sprite^.images[ch].y then
                    getmem(sprite^.images[ch].p,sprite^.images[ch].x*sprite^.images[ch].y);
          {       else
                 begin
                      writeln('not enough mem');
                      halt;
                 end;}
                 blockread(f,sprite^.images[ch].p^,sprite^.images[ch].x*sprite^.images[ch].y,n);
            end;
            close(f);
            sprite^.images_num:=ch;
      end;
end;
end;

procedure Set_Palette;
var i:integer;
begin
     for i:=0 to 255 do setcolor(i,palette[i,1],palette[i,2],palette[i,3]);
end;

end.