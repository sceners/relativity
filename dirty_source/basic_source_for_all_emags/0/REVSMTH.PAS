{$g+}

unit revsmth;

Interface

uses Crt,Dos;
procedure smoothscroll(strn:string; x,y:integer; dep:word; bar:boolean);

implementation
uses revtech,revfnt,revconst,revhsc,revhelp,revansi,revgfx,revdat,revboom,
     revmouse,revprint;

const Func1    = $bb;
      Func2    = $bc;
      homekey  = $47;
      endkey   = $4F;
      pgupkey  = $49;
      pgdnkey  = $51;
      esckey   = $01;
      upkey    = $48;
      downkey  = $50;
      ENTER    = $1c;
      P        = $99;
      bios_maxlength = 200;
      Max =$ffff;

var
  vol,x1,x2,x3,curpos1,curpos,counter,checker,
  maxline,pagespeed,scrollspeed : longint;
  key : byte;

PROCEDURE wrt; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
       and al,08h
    jz  l2
end;


Procedure ShowCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$0506
  INT   $10
end;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

Procedure Tmode;
Begin
asm
   mov ax,3h
   int 10h
end;
end;

procedure setOfs(ycharsize : byte; W : word); assembler;
  asm
          mov    ax, [W]
          mov    cx, ax

          xor    dx,dx
          xor    bx,bx
          mov    bl,[ycharsize]
          div    bx
          mov    bx, ax
          shl    ax, 6
          shl    bx, 4
          add    bx, ax

          cli
          mov    dx, 3DAh
   @11:   in     al, dx
          test   al, 01
          jnz    @11

          mov    dx, 3D4h
          mov    al, 0Ch
          mov    ah, bh
          out    dx, ax
          inc    al
          mov    ah, bl
          out    dx, ax

          mov    dx, 3d4h
          mov    al, 08h
          out    dx, al
          mov    ah, [ycharsize]
          dec    ah
          and    cl, ah
          mov    ah, cl
          out    dx, ax


          mov    dx, 3DAh
    @22:  in     al, dx
          test   al, 08
          jz     @22

          sti
  end;



procedure smoothscroll(strn:string; x,y:integer; dep:word; bar:boolean);
const
   bios_charsize =16;
   bios_ysize =24;
   a=1;

var
  max_charsize : longint;
  max_screensize,max_ysize,max_scanlength : longint;
{ bios_charsize : Byte ABSOLUTE $040:$0085;  {bios stored character height.. always here}
{ bios_ysize : Byte ABSOLUTE $040:$0084;}
  position,lastpos,size : longint;
  adf:boolean;
  lastline:array[1..2,1..80] of char;
  label start;

Procedure getbuf(str:string; var numread:longint);
var
    m:word;
    f:file;
begin
assign(f,str);
reset(f,1);
if adf then seek(f,4289); { 4289=header}
BlockRead(F,article_main^, max, m);
{BlockRead(F,b, sizeof(b), m);}
numread:=m;
close(f);
end;

procedure display(segment,o: word; s: string; color:byte);    { Write string at segment   }
var
     j,i: word;
begin
{    i:=0;
    while i < 160 do begin
        mem[segment:i] := 32; inc(i,2); end;}
    for j := 1 to length(s) do begin
        mem[segment:o] := ord(s[j]);
        mem[segment:o+1] := color;
        inc(o,2); end;
end;

procedure ModFont; assembler;
asm
    mov dx,03C4h; mov ax,0402h; out dx,ax; mov ax,0704h; out dx,ax
    mov dl,0CEh; mov ax,0204h; out dx,ax; mov ax,0005h; out dx,ax
    inc ax; out dx,ax
end;
procedure SetFont; assembler;
asm
    mov dx,03C4h; mov ax,0302h; out dx,ax; mov ax,0304h; out dx,ax
    mov dl,0CEh; mov ax,0004h; out dx,ax; mov ax,1005h; out dx,ax
    mov ax,0E06h; out dx,ax
end;

procedure ShowPercent;
var
    j, k: integer;
    whole, remainder: word;
    s: string[7];
    mask: byte;
    DisplayString, Attribs: array [0..15] of byte;
    lala:integer;

begin
    dec(curpos,32);
    dec(maxline,64);
    fillchar(DisplayString, 16, ' ');
    fillchar(attribs, 16, $1F); {color of the red back}
    whole := (curpos*128 div maxline) shr 3;
    remainder := (curpos*128 div maxline) and 7;
    fillchar(DisplayString, whole, #219);
    lala:=curpos*100 div maxline;
    if lala > 100 then
    lala:=100;
    str(lala, s);
    inc(curpos,32);
    inc(maxline,64);
    s := s+'%';
    k := 7 - length(s) shr 1; {place of %}
    for j := 1 to length(s) do begin
        DisplayString[k+j] := ord(s[j]);
        if k+j < whole then
            attribs[k+j] := $F1; {color}
    end;
    if remainder <> 0 then begin
        ModFont;
        move32fast(mem[$A000:DisplayString[whole] shl 5], mem[$A000:864], 16);
        mask := not ($FF shr remainder);
        for j := 0 to 15 do
           mem[$A000:864+j] := mem[$A000:864+j] xor mask;
        SetFont;
        DisplayString[whole] := 27;
    end;
    for j := 0 to 15 do begin
        mem[$B800:j*2+284] := DisplayString[j]; {place and % bar}
        mem[$B800:j*2+285] := attribs[j];
    end;
end;

procedure setpos(position:longint);
const
     lastpos : longint= 0;
var
   size : longint;

begin
  size := max_scanlength-max_ysize;
  asm
          cli
          mov    dx, 3DAh
   @11:   in     al, dx
          test   al, 08
          jnz    @11
  end;
  if (lastpos<=size) and (position>size) then
  begin
       if bar then
          move32fast(article_main^[(size div max_charsize)*160+1],mem[$b814:0], max)
       else
          move32fast(article_main^[(size div max_charsize)*160+1],mem[$b800:0], max);
       setofs(max_charsize,position mod size);
       if bar then
          move32fast(article_main^[(size div max_charsize)*160+1+max_screensize],mem[$b814:max_screensize],max)
       else
          move32fast(article_main^[(size div max_charsize)*160+1+max_screensize],mem[$b800:max_screensize],max);
  end
  else
      if (lastpos>=size) and (position<size) then
      begin
           if bar then
              move32fast(article_main^[max_screensize+1],mem[$b814:max_screensize], max)
           else
               move32fast(article_main^[max_screensize+1],mem[$b800:max_screensize], max);
           setofs(max_charsize,position mod size);
           if bar then
              move32fast(article_main^,mem[$b814:0], max)
           else
              move32fast(article_main^,mem[$b800:0], max)
      end
  else
  begin
       setofs(max_charsize,position mod size);
  end;
  lastpos:=position;

if bar then
begin
  if (x<>0) and (y<>0) then
  begin
       display($B80A,0, ' <F1> Help, <F2> BoomBox, <P> Print, <Enter> Save,  Progress :',9);
       display($B80A,$0004,'F1',10);
       display($B80A,$001a,'F2',10);
       display($B80A,$00036,'P',10);
       display($B80A,$0004c,'Enter',10);
  end
  else
  begin
       display($B80A,0, '                          <P> Print, <Enter> Save,  Progress :',9);
       display($B80A,$00036,'P',10);
       display($B80A,$0004c,'Enter',10);
  end;

  ShowPercent;
end;
end;

Procedure BarPre;
var j:byte;
begin

{ long waited bar at the bottom !!!!!!!!!!!!!!!!!!!!!!!!!! }

  asm mov dx,03DAh; in al,dx; mov dl,0c0h;
      mov al,30h; out dx,al; mov al,36;
      out dx,al; end;

  asm mov dx,03D4h; mov ax,7018h; out dx,ax;
      mov ax,1F07h; out dx,ax; mov ax,0F09h;
      out dx,ax;mov ax,0A00Dh; out dx,ax;end;

  asm mov ax,0100h; mov cx,2000h; int 10h; end;

  if (x<>0) and (y<>0) then
  begin
       display($B80A,0, ' <F1> Help, <F2> BoomBox, <P> Print, <Enter> Save,  Progress :',9);
       display($B80A,$0004,'F1',10);
       display($B80A,$001a,'F2',10);
       display($B80A,$00036,'P',10);
       display($B80A,$0004c,'Enter',10);
  end
  else
  begin
       display($B80A,0, '                          <P> Print, <Enter> Save,  Progress :',9);
       display($B80A,$00036,'P',10);
       display($B80A,$0004c,'Enter',10);
  end;
    for j := 0 to 79 do
    begin
        mem[$B800:j*2] := 196;  {straight line}
        mem[$B800:j*2-1] := lightblue;  {straight line}
    end;
        mem[$B800:j*2+1] := lightblue;  {straight line}
  ShowPercent;

{long waited bar at the bottom !!!!!!!!!!!!!!!!!!!!!!!!!!}

end;


Procedure SaveFile(out:string);
var output:text;
    j,i,lin:longint;
    numread:word;
begin
     assign(output,out);
     rewrite(output);
     for i:= 1 to (dep div 160) do
     begin
          for j:= 1 to 159 do
              if ((j mod 2) = 1) then
                 write(output,chr(article_main^[(160*i)-(160-j)]));
           writeln(output,chr(article_main^[(160*i)-1]));
     end;
close(output);
hidecursor;
END;

Procedure ReadhEADER;
var f:file;
    count1:integer;
BEGIN
  assign(f,strn);
  reset(f,1);
  blockread(f,version,1);
  for count1:=0 to 63 do begin
  blockread(f,pallette[count1],3);
  end;
  blockread(f,vga_font[1],4096);
  For count1:=0 to 63 do
    GetPal(count1,old_pal[count1,1],old_pal[count1,2],old_pal[count1,3]);
  For count1:=0 to 63 do
    SetPal(count1,pallette[count1,1],pallette[count1,2],pallette[count1,3]);
  set_ice_color;
  set_character_width;
  set_vga_font;
  cursor_off;
END;

procedure chpal;
var count1:integer;
begin
  For count1:=0 to 63 do
    GetPal(count1,old_pal[count1,1],old_pal[count1,2],old_pal[count1,3]);
  For count1:=0 to 63 do
    SetPal(count1,pallette[count1,1],pallette[count1,2],pallette[count1,3]);
  set_ice_color;
  set_character_width;
  set_vga_font;
  cursor_off;
end;

procedure ClearHeaderStatus;
var count1:integer;
begin
  For count1:=0 to 63 do
  SetPal(count1,old_pal[count1,1],old_pal[count1,2],old_pal[count1,3]);
end;

Procedure GetExt(name:string; var adf:boolean);
var tmp:string;
    i,l:integer;
begin
tmp:='';
l:=length(name);
for i:= l downto l-2 do
   tmp:=name[i]+tmp;
if tmp='ADF' then
    adf:=true
else
    adf:=false;
end;

Procedure MoveTomem(position:longint);
var size:longint;
begin
  size := max_scanlength-max_ysize;
  asm
          cli
          mov    dx, 3DAh
   @11:   in     al, dx
          test   al, 08
          jnz    @11
  end;
  if (lastpos<=size) and (position>size) then
  begin
       if bar then
          move(article_main^[(size div max_charsize)*160+1],mem[$b814:0], max)
       else
          move(article_main^[(size div max_charsize)*160+1],mem[$b800:0], max);
       setofs(max_charsize,position mod size);
       if bar then
          move(article_main^[(size div max_charsize)*160+1+max_screensize],mem[$b814:max_screensize],max)
       else
          move(article_main^[(size div max_charsize)*160+1+max_screensize],mem[$b800:max_screensize],max);
  end
  else
      if (lastpos>=size) and (position<size) then
      begin
           if bar then
              move(article_main^[max_screensize+1],mem[$b814:max_screensize], max)
           else
               move(article_main^[max_screensize+1],mem[$b800:max_screensize], max);
           setofs(max_charsize,position mod size);
           if bar then
              move(article_main^,mem[$b814:0], max)
           else
              move(article_main^,mem[$b800:0], max)
      end
  else
  begin
{  if (lastpos<=size) and (position>size) then
  begin
       if bar then
          move(buffer^[(size div max_charsize)*160+1],mem[$b814:0], max)
       else
          move(buffer^[(size div max_charsize)*160+1],mem[$b800:0], max);
  end;
  if (lastpos>=size) and (position<size) then
  begin
       if bar then
          move(buffer^[max_screensize+1],mem[$b814:max_screensize], max)
       else
           move(buffer^[max_screensize+1],mem[$b800:max_screensize], max);
  end;}
  setofs(max_charsize,position mod size);
  end;
  lastpos:=position;
end;


var r:byte;
    filename:st12;
    uppos,dnpos:longint;

label up,down;

begin
  move32fast(article^,article_main^,$ffff);
  chbrght(palette);
  {-----------------------------------------------}
  scrollSpeed := 4;
  hidecursor;
  clrscr;
  if bar then
  curpos:=32
  else curpos:=0;
  {-----------------------------------------------}
  pageSPEED := 10;
  max_charsize := bios_charsize;
  max_ysize := bios_ysize * bios_charsize;
  max_scanlength := bios_maxlength * bios_charsize;
  max_screensize := bios_maxlength * 160 div 2;
  maxline := ((dep div 160)-bios_ysize-1) * bios_charsize;
  clrscr;
{-------------}
if bar then
begin
  inc(maxline,64); {after the bar the 4 last lines were lost :( 4*16 }
  BarPre;
{-------------}
  for r := 1 to 160 do
  begin
       if r mod 2 <> 0 then
          article_main^[dep+r]:=ord(' ');
       if r mod 2 = 0 then
          article_main^[dep+r]:=0;
  end;
  move32fast(article_main^,mem[$b814:0], max);
end
else move32fast(article_main^,mem[$b800:0], max);

{  display($B80A,$0009e,' ',10);}
  {-----------------------------------------------};
  repeat
    checker := 0;
    curpos1 := curpos;
    key := port[$60];
    WHILE KEYPRESSED DO READKEY;
    if keypressed then
{    begin}
        key := port[$60];
    case key of
       func1 : begin {blocked by intention.. doesnt work .. fix it !}
{               if strn<>config^.EndMenuFile2 then
               begin
                  if (x=0) and (y=0) then
                  else
                  begin
                       help1:=true;
                       config^.notavhelp:=config^.notavhelp+[changetag];
                       config^.notavhelp:=config^.notavhelp-[saveastag];
                       help(strn,x,y,adf,buffer,dep);
                       config^.notavhelp:=config^.notavhelp-[changetag];
                       hidecursor;
                       chbrght;
                       if bar then BarPre;
                        MoveTomem(curpos);
                       help1:=false;
                  end;
               end;}
             end;
       func2 : begin
{               if strn<>config^.EndMenuFile2 then
               begin
                  if (x=0) and (y=0) then
                  else
                  begin
                       boom1:=true;
                       F2_HELP;
                       hidecursor;
                       chbrght;
                       if bar then BarPre;
                        MoveTomem(curpos);
                       boom1:=false;
                  end;
               end;}
             end;
       enter:
             begin
                  filename:=strn;
                  delete(filename,length(filename)-2,3);
                  filename:=filename+'TXT';
                  savefile(filename);
             end;
           P:
             begin
                  if printer then
                  begin
                       filename:='PRN';
                       savefile(filename);
                  end;
             end;
       homekey :
           begin
                if bar then uppos:=32
                else uppos:=0;
            for counter := 0 to curpos div 10 - 1 do
            begin
             dec(curpos, pagespeed);
             if curpos<=uppos then curpos:=uppos;
             setpos(curpos);
            end;
           end;
       endkey :
           begin
            for counter := curpos div 10 + 1 to (maxline div 10 + 1)-1 do
            begin
                 inc(curpos, pagespeed);
                 if curpos>=maxline then
                    curpos:=maxline;
                 setpos(curpos);
            end;
           end;
       pgupkey :
           BEGIN
                if bar then uppos:=32
                else uppos:=0;
            If curpos > 399 then
             begin
                for counter := 0 to 39 do
                begin
                     checker := 1;
                     dec(curPos, pageSpeed);
                     IF CURPOS <=uppos then
                        curpos:=uppos;
                     setpos(curPos);
                end;
              end;
            If curpos < 400 then
              if curpos > 1 then
                 if checker = 0 then
                 begin
                      for counter := 0 to (((curpos) div 10)) do
                      begin
                      dec(curPos, pageSpeed);
                      IF CURPOS <=uppos then
                         curpos:=uppos;
                      setpos(curPos);
                 end;
             end;
          end;
       pgdnkey :
           BEGIN
            IF CURPOS > MAXLINE THEN CURPOS := MAXLINE;
            If CURPOS < MAXLINE then begin
              for counter := 0 to 39 do begin
                inc(curPos, pageSpeed);
                IF CURPOS >= MAXLINE THEN
                curpos:=maxline;
                  setpos(curPos);
              end;
            end;
           end;
       upKey :
              up:
              begin
                   if bar then uppos:=32
                   else uppos:=0;
           if curPos >= scrollspeed then
              begin
                dec(curPos, scrollSpeed);
                IF CURPOS <= uppos THEN
                curpos:=uppos;
                  setpos(curPos);
              end
           else
             begin
               curpos:=uppos;
               setpos(curpos);
             end;
             end;
       downKey : begin
               down:
            if curPos < maxline - scrollspeed  then
              begin
                inc(curPos, scrollSpeed);
                IF CURPOS <= MAXLINE THEN
                  setpos(curPos);
                  if curpos=maxline then
                  setpos(maxline-1);
              end
            else
              begin
                curpos:=maxline;
                setpos(curpos);
              end;
              end;
    end;
    if curPos > maxline then curPos := maxline;
  until key = escKey;
{-----------------------------------------------}
curpos:=1;
FadedownRGBScreen;
Reset80x25VideoScreen;
{-----------------------------------------------}
end;

end.


