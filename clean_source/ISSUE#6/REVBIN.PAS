unit revbin;
interface
uses Crt,Dos;

procedure ansiscroll(strn:string; x,y:integer; dep:word);

implementation
uses revtech,revfnt,revconst,revhsc,revhelp,revansi,revgfx,revdat,revboom,
     revmouse,revprint;

const Func1    = #59;
      Func2    = #60;
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
  key : char;
  buffer:buf;

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

procedure ansiscroll(strn:string; x,y:integer; dep:word);
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
BlockRead(F,buffer^, max, m);
{BlockRead(F,b, sizeof(b), m);}
numread:=m;
close(f);
end;

{       display($B80A,0, ' <F1> Help, <F2> BoomBox, <P> Print, <Enter> Save,  Progress :',9);}

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
                 write(output,chr(buffer^[(160*i)-(160-j)]));
           writeln(output,chr(buffer^[(160*i)-1]));
     end;
close(output);
hidecursor;
END;

var r:byte;
    filename:st12;
    uppos,dnpos:longint;
    line:integer;

Procedure Bar;
var i:byte;
begin
     for i:= 0 to 79 do
     begin
          textcolor(blue);
          gotoxy(1+i,24);write('Ä');
     end;
     textcolor(blue);
     textbackground(black);
     gotoxy(1,25);write(' <F1> Help, <F2> BoomBox, <P> Print, <Enter> Save,  Progress :                ');
     gotoxy(70,25);write((line) * 100 div (maxline-23),'%');
     textcolor(lightblue);
     gotoxy(3,25);write('F1');
     gotoxy(14,25);write('F2');
     gotoxy(28,25);write('P');
     gotoxy(39,25);write('ENTER');
     gotoxy(53,25);write('Progress');
end;


label up,down;

begin
  getmem(buffer,$ffff);
  move32fast(article^,buffer^,$ffff);
  {-----------------------------------------------}
  scrollSpeed := 4;
  hidecursor;
  clrscr;
  {-----------------------------------------------}
  maxline := dep div 160;
  key:=#33;
  line:=0;
  while key<>#27 do
  begin
       move32fast(buffer^[line*160+1],mem[$b800:00],3680);
       bar;
       key :=readkey;
       case key of
           'P','p':
             begin
                  if printer then
                  begin
                       filename:='PRN';
                       savefile(filename);
                  end;
             end;
       #13:
             begin
                  filename:=strn;
                  delete(filename,length(filename)-2,3);
                  filename:=filename+'TXT';
                  savefile(filename);
             end;
             end;
       if key = #0 then
       begin
       key:=readkey;
       case key of
       func1 : begin
               if strn<>config^.EndMenuFile2 then
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
                       move32fast(buffer^[line*160+1],mem[$b800:00],3680);
                       bar;
                       help1:=false;
                  end;
               end;
             end;
       func2 : begin
               if strn<>config^.EndMenuFile2 then
               begin
                  if (x=0) and (y=0) then
                  else
                  begin
                       boom1:=true;
                       F2_HELP;
                       hidecursor;
                       move32fast(buffer^[line*160+1],mem[$b800:00],3680);
                       bar;
                       boom1:=false;
                  end;
               end;
             end;
       #71 :
           begin
             line:=0;
           end;
       #72 :
             begin
                line:=line-1;
                if line<0 then line:=0;
             end;
       #73:
           BEGIN
                line:=line-23;
                if line<0 then line:=0;
           end;
       #79 :
           begin
                line:=maxline-23;
           end;
       #80:
             begin
                  line:=line+1;
                  if line>maxline-23 then line:=maxline-23;
             end;
       #81:
           BEGIN
                line:=line+23;
                if line>maxline-23 then line:=maxline-23;
           end;
           end;
    end;
  end;
{-----------------------------------------------}
FadedownRGBScreen;
Reset80x25VideoScreen;
freemem(buffer,$ffff);
{-----------------------------------------------}
end;

end.


