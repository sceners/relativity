unit revnfo;
interface

Procedure InfoMenu;
procedure PrintEndingPhase;

implementation
uses revconst,crt,revdat,revspec,revmenu,revgfx,revansi,revsmth,revhelp;

Procedure ClearMenuArea;
var x,y:integer;
begin
x:=25;
y:=15;
textbackground(black);
for i:= 1 to 9 do
begin
     Gotoxy(x,y);
     write('                                              ');
     y:=y+1;
end;
end;

Procedure InfoMenu;
const max=60;
      lines=7;
var
    f          : text;
    str22      : st22;
    str        : string[14];
    c,p,l,d,ll   : integer;
    k          : char;

Procedure WriteMenu;
var i:integer;
    x,y:integer;
begin
ClearMenuArea;
x:=25;
y:=16;
textcolor(darkgray);
ll:=l;
if ll>lines then ll:=lines;
     for i:= 1 to ll do
     begin
          if p = i then
             textbackground(blue)
          else
              textbackground(black);
{          gotoxy(48-(length(info[c+i-1]) div 2),y);write(info[c+i-1]);}
          y:=y+1
     end;
end;

Procedure InitInfonames;
begin
ExtractFileFromDat('REVINFO');
assign(f,'REVINFO');
reset(f);
i:=1;
     while not eof(f)  do
     begin
          read(f,str22);readln(f,str);
{          Info[i]:=str22;}
          delete(str,1,1);
{          files[i]:=str;}
          i:=i+1;
     end;
{     info[i]:='Exit Info Section';}
l:=i-1;
close(f);
deletedatfile('REVINFO');
end;

var adf:boolean;

begin
{---------------------------------------}
{decided that group nfoes are not adf   }
adf:=false;
{---------------------------------------}
c:=1;p:=1;
InitInfonames;
ClearMenuArea;
WriteMenu;
k:=#22;
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
               config^.notavhelp:=config^.notavhelp+[3];
               help('none',19,0,false);
               hidecursor;
               Displayansi(defmenufile);
               WriteMenu;
          end;
    #75 : begin
                dec(p);
                if p<1 then
                begin
                     dec(c);
                     p:=1;
                end;
                if c<1 then c:=1;
          end;
    #72 : begin
                dec(p);
                if p<1 then
                begin
                     dec(c);
                     p:=1;
                end;
                if c<1 then c:=1;
          end;
    #77 : begin
                inc(p);
                if p>lines then
                begin
                     inc(c);
                     p:=lines;
                end;
                if c>=(l-lines)+1 then c:=(l-lines)+1;
                if p>l then p:=l;
          end;
    #80 : begin
                inc(p);
                if p>lines then
                begin
                     inc(c);
                     p:=lines;
                end;
                if c>=(l-lines)+1 then c:=(l-lines)+1;
                if p>l then p:=l;
          end;
    #71 : begin
              c:=1;
              p:=1;
          end;
    #79 : begin
              p:=lines;
              c:=l-lines+1;
          end;
    #27,'q' : begin StartMainMenuPhase; end;
    #13 : Begin
          if c = 1 then
          d:=p;
          if c>1 then
          d:=c+p-1;
          if c<l-lines+1 then
          begin
{               extractfilefromdat(config.files[d]);}
{               SmoothScroll(files[d],19,0);}
               DisplayaNsi(defmenufile);
               hidecursor;
               WriteMenu;
               k:=readkey;
          end;
          if c=l-lines+1  then
               StartMainMenuPhase;
          end;
  end;
WriteMenu;
  until true=false; {never....hehe}
end;

procedure PrintEndingPhase;
var k:char;
begin
end;


end.