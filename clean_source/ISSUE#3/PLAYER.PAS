{$M 20000,0,0}
unit player;
interface

procedure initexpmus;

implementation

uses sds, sds_det, crt, alloc, esb, string_s, revgfx;

var module   : pointer;
    services : pointer;
    ch       : char;
    k        : word;
    stat     : longint;

procedure music_menu(var c:integer);
var b,P,code : Integer;
    k          : Char;
    str        : string;

const choices : array [1..8] of string =(
  ' 1.Sound Blaster 1 or 2 ',
  ' 2.Sound Blaster Pro    ',
  ' 3.Sound Blaster 16/32  ',
  ' 4.Gravis UltraSound    ',
  ' 5.Pro Audio Spectrum16 ',
  ' 6.Crystal/Analog CODEC ',
  ' 7.Aria                 ',
  ' 8.UltraSilence!(tm)    ');

procedure write_music;
var i,a,x,y:byte;
    str:string;
begin
textcolor(darkgray);
textbackground(black);
x:=49;
y:=8;
for a := 1 to 8 do
  begin
    if c=a then
    begin
        gotoxy(x-1,y);
        str:=choices[a];
        textbackground(cyan);
        textcolor(darkgray);
        for i:= 1 to length(str) do
            write(str[i]);
    end
    else
    begin
         gotoxy(x-1,y);
         str:=choices[a];
         textbackground(black);
         textcolor(darkgray);
         for i:= 1 to length(str) do
             write(str[i]);
    end;
    inc(y);
    end;
end;

begin
k:=#22;
c:=1;
hidecursor;
write_music;
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #72 : begin dec(c); end;
    #80 : begin inc(c); end;
  end;
  if c = 8+1 then
     c := 1;
  if c = 0 then
     c := 8;
  write_music;
  until k=#13; {never....hehe}
end;

function choosecard:word;
var c:char; crd:word;
    cc:integer;
begin
  cc:=1;
  music_menu(cc);
  repeat
    c:='Y';
    case cc of
      1: if not DetectSB(Base, Irq, Dma) then c:='N';
      2: if not DetectSBPro(Base, Irq, Dma) then c:='N';
      3: if not DetectSB16(Base, Irq, Dma) then c:='N';
      4: if not DetectGUS(Base, Irq, Dma) then c:='N';
      5: if not DetectPAS(Base, Irq, Dma) then c:='N';
      6: if not DetectWSS(Base, Irq, Dma) then c:='N';
      7: if not DetectARIA(Base, Irq, Dma) then c:='N';
    end;
  until c='Y';
  choosecard:=cc;
end;

procedure incvolume;near;assembler;
asm
  mov ah,6
  call dword ptr services
end;

procedure decvolume;near;assembler;
asm
  mov ah,7
  call dword ptr services
end;

procedure incAmplification;near;
var amp:integer;
begin
   amp:=getESBword(32) + 5;
   asm
     mov ah,3
     mov bx,amp
     call dword ptr services
   end
end;

procedure decAmplification;near;
var amp:integer;
begin
   amp:=getESBword(32) - 5;
   if amp<25 then amp:=25;
   asm
     mov ah,3
     mov bx,amp
     call dword ptr services
   end
end;

procedure incmastervol;near;
var vol:byte;
begin
   vol:=getesbbyte(31);
   if vol+$8<256 then inc(vol,$8) else vol:=$FF;
   asm
     mov ah,2
     mov al,vol
     call dword ptr services
   end
end;

procedure decmastervol;near;
var vol:byte;
begin
   vol:=getesbbyte(31);
   if vol-$8>=0 then dec(vol,$8) else vol:=0;
   asm
     mov ah,2
     mov al,vol
     call dword ptr services
   end
end;

procedure MyFuckinRoutine;far;
begin
{ asm mov ax,seg @DATA; mov ds,ax end;
  write(#13,'Loading ');
  case Action of
    1 : write ('header');
    2 : write ('pattern ',actionPARA);
    3 : write ('sample ',actionPARA);
    4 : write ('channel ',actionPARA);
    5 : write ('text');
    6 : write ('descriptor #',actionPARA);
    else write('something (unknown)');
  end;
  write(', Available mem: ',sds_mavail div 1024,' kb');
  clreol; }
end;


procedure initexpmus;
var temp:byte;

begin
  card:=choosecard;
  if card<>8 then
  begin
  sds_init(Card{Card#},Base{BasePort},Irq{IRQ},DMA{DMA#});
  end;
end;
end.