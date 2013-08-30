uses raw;
{ this program checks my raw file for colors that are in
  the 64k buf 0-255 colors of each byte that are not in the pal
  the 0-255 pal }
{ buf (1,2,3,4,5,6,1,2,3,4,5,6,7,8,9,90)
  pal[1]:=2;
  pal[2]:=2;
  pal[3]:=2;
  pal[4]:=2;
  pal[5]:=2;
  pal[6]:=2;
  pal[7]:=1;
  pal[8]:=1;
  pal[9]:=1;
  pal[90]:=1;
  the 0 counted pal will be written on screen that way u know which
  pal colors u can erase !!}

var f:file;
    head:header;
    n:word;
    buf:buffer;
    i,sum:longint;
    pal:array[0..255] of longint;

begin
     assign(f, 'a.raw');
     reset(f, 1);
     blockread (f, head, sizeof(head),N);
     getmem(buf, sizeof(buf^));
     BlockWrite(F, Buf^,sizeof(buf^), N);

     for i:= 0 to 255 do
     pal[i]:=0;

     for i:= 1 to 64000 do
     begin
          pal[buf^[i]]:= pal[buf^[i]]+1;
     end;

     close(f);

     sum:=0;
     for i:= 0 to 255 do
     begin
          if pal[i] = 0 then
          begin
               write('Color : ',i,' is zero');
          end;
          sum:=sum+pal[i];
     end;
     freemem(buf,sizeof(buf^));
end.