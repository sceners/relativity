{$M 20000,0,0}
uses sds, crt, alloc, esb, dos, sds_det, strings, math;

{ Speed tester for poll routine }
{ This program might not work on some systems! }

var module,api,poll  : pointer;
    a,b,c,d : word;
    freq:word;

function choosecard:word;
var c:char; crd:word;
begin
  writeln('Choose soundcard :');
  writeln(' 1.Sound Blaster 1.0 or 2.0');
  writeln(' 2.Sound Blaster Pro (DSP 3.x)');
  writeln(' 3.Sound Blaster 16 ASP or AWE 32 (DSP 4.0)');
  writeln(' 4.Gravis UltraSound');
  writeln(' 5.Pro Audio Spectrum Plus/16');
  writeln(' 6.Crystal/Analog CODEC (WSS/AudioTrix Pro/GUS MAX CODEC)');
  writeln(' 7.Aria');
  writeln(' 8.UltraSilence!(tm) (no sound)');
  repeat
    repeat c:=readkey until c in ['1'..'8'];
    crd:=byte(c)-byte('0');
    c:='Y';
    case crd of
      1: if not DetectSB(Base, Irq, Dma) then c:='N';
      2: if not DetectSBPro(Base, Irq, Dma) then c:='N';
      3: if not DetectSB16(Base, Irq, Dma) then c:='N';
      4: if not DetectGUS(Base, Irq, Dma) then c:='N';
      5: if not DetectPAS(Base, Irq, Dma) then c:='N';
      6: if not DetectWSS(Base, Irq, Dma) then c:='N';
      7: if not DetectAria(Base, Irq, Dma) then c:='N';
    end;
    if c<>'Y' then begin
      write(#13'Card not found, try again');
      sound(1000); delay(20); nosound
    end;
  until c='Y';
  write(#13); clreol;
  choosecard:=crd;
end;

function choosefreq:word;
var c:char; frq:word;
begin
  writeln('Choose mixing frequency :');
  writeln(' 1. 8000 Hz');
  writeln(' 2. 11025 Hz');
  writeln(' 3. 15000 Hz');
  writeln(' 4. 22050 Hz');
  writeln(' 5. 33000 Hz');
  writeln(' 6. 44100 Hz');
  writeln(' 7. 48000 Hz');
  repeat
    repeat c:=readkey until c in ['1'..'7'];
    frq:=byte(c)-byte('0');
    c:='Y';
    if (frq=7) and (card<>wss) then c:='N';
    if c<>'Y' then begin
      write(#13'Too high for the selected soundcard, try again');
      sound(1000); delay(20); nosound
    end;
  until c='Y';
  write(#13); clreol;
  case frq of
    1: frq:=8000;
    2: frq:=11025;
    3: frq:=15000;
    4: frq:=22050;
    5: frq:=33000;
    6: frq:=44100;
    7: frq:=48000;
  end;
  choosefreq:=frq;
end;

procedure DeskTop;
begin
  ClrScr;
  asm
    mov ax,1003h
    mov bl,0
    int 10h
  end;
  textattr:=$1E;
  write(space(79),#13,' Sound Deluxe System 5, ');
  textattr:=$1F;
  write('a Maple Leaf production, 1997                           ');
  textattr:=$71;
  write(space(79),#13,' Speed tester v1.0                                                              ');
  textattr:=$8F;
  write(' '); clreol; writeln;
  textattr:=$1F;
  write(' '); clreol; writeln;
  write(' '); clreol; writeln;
  write(' '); clreol; writeln;
  write(' '); clreol; writeln;
  textattr:=$8F;
  write(' '); clreol; writeln;
  textattr:=$1A;
  write(' '); clreol; writeln;
  write('  ',ModuleName); clreol; writeln;
  textattr:=$1B;
  write('  ',channels,' channels, ',samples,' samples, ',patterns,' patterns, ', entries,' orders'); clreol; writeln;
  write(' '); clreol; writeln;
  textattr:=3;
  write(' '); clreol; writeln;
  write(' '); clreol; writeln;
  writeln('This program measures the relative speed of the mixing routine in SDS. The');
  writeln('result is given in two manners: the upper bar (and its info in the left)');
  writeln('shows how many ticks are elapsed during one single mixing, where 1 tick is');
  writeln('the 1/65536th part of a second. The full bar means one full second and the');
  writeln('filled part is the time wasted by sds_poll (intuitively).');
  writeln('The percent means the part of a second wasted, and its bar shows a how big part');
  writeln('of the 1/10th of a second is wasted this way.');
end;

var cnt:word;

procedure polling;near;assembler;
asm
  {read timer's init value and store it}
  in al,42h
  mov ah,al
  in al,42h
  xchg al,ah
  mov bx,ax
  {polling music}
  call dword ptr poll
  {now read the counter}
  in al,42h
  mov ah,al
  in al,42h
  xchg al,ah
  {compute how many ticks, and store the value}
  sub bx,ax
  jge @1
  add bx,0ffffh
@1:
  mov cnt,bx
end;

procedure retrace;near;assembler;
asm
    mov dx,3dah
@1: in al,dx
    test al,8
    jnz @1
@2: in al,dx
    test al,8
    jz @2
end;

procedure starttimer;near;assembler;
asm
  {start dma timer, channel #2}
  mov al,0b2h
  out 43h,al
  mov al,0ffh
  out 42h,al
  out 42h,al
end;

procedure display;
var perc:real;
const error = 0.05;
begin
  gotoxy(1,5);
  textattr:=$1A; write(cnt:8);
  textattr:=$1F; write(' ³ ');
  textattr:=$1E; write(strng(trunc(64*longint(cnt)/longint($FFFF)),219));
  textattr:=$17; write(strng(trunc(64-64*longint(cnt)/longint($FFFF)),176));
  clreol;
  perc:=100*longint(cnt)/longint($FFFF);
  if perc>error then begin
    gotoxy(1,6);
    textattr:=$1B; write(perc:7:2,'%');
    textattr:=$1F; write(' ³ ');
    textattr:=$1A; write(strng(min(64,trunc(640*longint(cnt)/longint($ffff))),219));
    textattr:=$17; write(strng(max(0,trunc(64-640*longint(cnt)/longint($ffff))),178));
    write(' ');
  end;
end;

procedure testspeed;
var bpm:word;
begin
  cnt:=0;
  directvideo:=true;
  starttimer;
  repeat
    display;
    bpm:=getesbword(38);
    polling; if bpm>170 then polling;
    retrace;
  until port[$60]=1;
end;

begin
  writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('³  Sound Deluxe System 5, a Maple Leaf production, 1996-1997      ³');
  writeln('³  Speed tester v1.0 (example program)                            ³');
  writeln('³  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ³');
  writeln('³  For problems/questions concerning this program or any other    ³');
  writeln('³  part of Sound Deluxe System, please contact me:                ³');
  writeln('³  ş Maple Leaf (a.k.a. Gruian Radu)                              ³');
  writeln('³  ş str.Lunii, nr.22, ap.4, Cluj Napoca, 3400, Romƒnia           ³');
  writeln('³  ş Phone: 040 64 124260                                         ³');
  writeln('³  ş e-Mail: maple_leaf_@hotmail.com                              ³');
  writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  writeln;

  if paramcount=0 then begin
    writeln(#13#10'Usage: TESTSPD module_name');
    writeln('Example: TESTSPD MY_SONG.MOD');
    halt;
  end;

  card:=choosecard;
  freq:=choosefreq;
  sds_init(card,base{BasePort},irq{IRQ},dma{DMA#});

  useEMS:=true;
  UseUMB:=true;
  module:=sds_load(paramstr(1),Card<>Silence);

  if loaderror<>0 then begin
    writeln('Error loading module (errorcode=',loaderror,')');
    sds_done; {don't forget to close SDS before ending!}
    halt
  end;

  sds_setsurround(true);
  sds_setpollmix(true);
  sds_setamplification(100);

  sds_startplay(module, 0{InitSpeed(0=auto)}, freq{MixSpeed}, 0{1=Pal,0=NTSC});

  api:=pointer(getesbdword(44));
  poll:=pointer(getesbdword(0));

  desktop;
  testspeed;

  sds_stopplay;
  sds_done;  {don't forget to close SDS before ending!}
  sds_unload(module);

  textattr:=7;
  clrscr;
end.
