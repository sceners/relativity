{$M 20000,0,0}  {don't forget to reduce the heap!}
uses sds, crt, alloc, esb, dos, sds_det;

{
  Sound Deluxe System 5, a Maple Leaf production, 1996-1997
  Background (shell) player
  * not intended for demos/intros! See POLL.PAS for such an example! *
}

var module  : pointer;
    cevent  : array [0..31] of array [0..4] of byte;
    a,b,c,d : word;
    sh:sdmint_headtype;
    dlpp, dentry, dpatt, dspd, dbpm, drow:word;
    card:word;

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
  writeln(' 7.Aria (Sierra SC18025/SC18026 DSP)');
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
      7: if not DetectARIA(Base, Irq, Dma) then c:='N';
    end;
    if c<>'Y' then begin
      write(#13'Card not found, try again');
      sound(1000); delay(20); nosound
    end;
  until c='Y';
  write(#13); clreol;
  choosecard:=crd;
end;

var parac, paras : string;

begin
  writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('³  Sound Deluxe System 5, a Maple Leaf production, 1996-1997      ³');
  writeln('³  Background player v1.0 (example program)                       ³');
  writeln('³  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ³');
  writeln('³  For problems/questions concerning this program or any other    ³');
  writeln('³  part of Sound Deluxe System, please contact me:                ³');
  writeln('³  þ Maple Leaf (a.k.a. Gruian Radu)                              ³');
  writeln('³  þ str.Lunii, nr.22, ap.4, Cluj Napoca, 3400, Romƒnia           ³');
  writeln('³  þ Phone: 040 64 124260                                         ³');
  writeln('³  þ e-Mail: maple_leaf_@hotmail.com, or                          ³');
  writeln('³            lsmm@hercule.utcluj.ro (w/ mention "pt. Maple Leaf") ³');
  writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  writeln;

  if paramcount=0 then begin
    writeln(#13#10'Usage: BGPLAYER module_name [executable_file [para1][para2]...[parax]]');
    writeln('Where module_name is the name of the module to play, and executable_file is the');
    writeln('filename of an executable file (EXE/COM/BAT) to be run while playing music.');
    writeln('The rest of the parameters are transmitted to the executable as its params.');
    writeln('If executable_file is ommited, then COMSPEC string is assumed (...\COMMAND.COM)');
    writeln('Example: BGPLAYER MY_SONG.MOD INTRO.EXE /nosetup /fast /lalala');
    halt;
  end;

  if paramcount>1 then
    parac:=paramstr(2)
  else
    parac:=getenv('COMSPEC');

  paras:='';
  if paramcount>2 then
    for a:=3 to paramcount do paras:=paras+paramstr(a)+' ';


  writeln('Free memory = ',mavail,' bytes');
  card:=choosecard;
  writeln('Init sound system ...');
  sds_init(card,base{BasePort},irq{IRQ},dma{DMA#});

  write('Loading module ...');
  UseEMS:=true;
  UseUMB:=true;
  module:=sds_load(paramstr(1),card<>Silence);

  if loaderror<>0 then begin
    writeln('Error loading module (errorcode=',loaderror,')');
    sds_done;  {dont forget to close SDS before exit!}
    halt
  end;

  writeln;
  textattr:=15;
  writeln('"',ModuleName,'"');
  textattr:=10;
  writeln(channels,' channels, ',patterns,' patterns, ',entries,' orders, ',Samples,' samples');
  textattr:=7;

  writeln('Turning off surround sounds ...');
  sds_setsurround(false);

  writeln('Turning off poll-mixing ...');
  sds_setpollmix(false);

  writeln('Setting 10% gain ...');
  sds_setamplification(110);

  writeln('Starting module at 44.1 kHz ...');
  sds_startplay(module, 0{InitSpeed(0=auto)}, 44100{MixSpeed}, 0{1=Pal,0=NTSC});

  textattr:=14;
  write('Type EXIT to stop playing and return to parent process');
  textattr:=7;
  writeln('.'#13#10);

  swapvectors;
  exec(parac,paras);
  swapvectors;

  case doserror of
    2,3 : writeln('Error: file not found (',parac,')'#13#10);
    8 : writeln('Error: not enough memory to load executable file'#13#10);
  end;

  writeln('Stopping sound...'); sds_stopplay;
  writeln('Shuting down SDS ...'); sds_done;
  writeln('Unloading module ...'); sds_unload(module);

  if loaderror<>0 then writeln('Deallocation error.');
end.