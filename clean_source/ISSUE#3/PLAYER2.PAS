{$M 20000,0,0} {don't forget to reduce the heap!}
unit player2;

interface

procedure start_rocking;

implementation

uses sds, sds_det, crt, alloc, esb{, sdsetup}, string_s,revconst;

var module  : pointer; fff:file;
    cevent  : array [0..31] of array [0..4] of byte;
    a,b,c,d : word;
    sh:sdmint_headtype;
    dlpp, dentry, dpatt, dspd, dbpm, drow:word;
    card:word;
    services : pointer;
    ch:char;
    k:word;
    stat:longint;

    rate, gain : word;
    palmode:byte;
    surmode:boolean;

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
   vol:=getesbbyte(31); if vol+$F<256 then inc(vol,$F) else vol:=$FF;
   asm
     mov ah,2
     mov al,vol
     call dword ptr services
   end
end;

procedure decmastervol;near;
var vol:byte;
begin
   vol:=getesbbyte(31); if vol-$F>=0 then dec(vol,$F) else vol:=0;
   asm
     mov ah,2
     mov al,vol
     call dword ptr services
   end
end;

procedure MyFuckinRoutine;far;
begin
  asm mov ax,seg @DATA; mov ds,ax end;
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
  clreol;
end;

procedure start_rocking;
var s:string;
begin
{ sds_setup(card,irq,dma,base,rate,gain,palmode,surmode,UseEMS,UseUMB);}
  {default values}
  card:=Silence; UseEMS:=true; UseUMB:=true; surmode:=on; palmode:=NTSC;
  card:=DetectSoundCard(Base,Irq,Dma);
  if card=8 then
     cd:=false
  else
  begin
       sds_init(card{Card ID},Base{BasePort},Irq{IRQ},DMA{DMA#});
       frq
  end;
  UserRoutine:=@MyFuckinRoutine;
  module:=sds_load('psb.s3m',card<>Silence);

{  if loaderror<>0 then begin
    writeln('Error loading module (errorcode=',loaderror,')');
    sds_done; {close SDS before exit!!!}
 {   halt
  end;}

  services:=pointer(GetESBdword(44));

{  writeln;
  writeln('Name        : ',modulename);
  writeln('Channels    : ',channels);
  writeln('Patterns    : ',patterns);
  writeln('Entries     : ',entries); }

  sds_setsurround(surmode);
  sds_setpollmix(off);
  sds_setamplification(gain);

{  writeln('Starting module ...');}
  sds_startplay(module, 0{InitSpeed(0=auto)}, rate{MixSpeed}, palmode{1=Pal,0=NTSC});

{  writeln('Playing. Press ESC to stop.'#13#10);}

  repeat
    repeat

      if getesbbyte(35) and 4 <> 0 then

{        write(#13'PAUSED. Press "u" to resume.')}
      else
      ;
{        write(#13,getesbword(20):2,'(',
{                  getesbword(22):2,'):',
{                  getesbword(26):2,'/',
{                  getesbword(24)-1:2,
{                  ',Spd=',getesbword(36),
{                  ',BPM=',dec2hex(getesbword(38)),
{                  ',UC=',dec2hex(getesbdword(53)),
{                  ',V=',dec2hex(getesbbyte(30)),
{                  ',MV=',dec2hex(getesbbyte(31)),
 {                 ',A=',getesbword(32),
                  {',Dst=',dec2hex(getesbword(58)),{}
{                  ',PattOffs=',dec2hex(getesbword(40)),
                  ',S:',getesbbyte(34));          }

      clreol;

      {for a:=0 to 3 do write(getesbbyte(140+a):2,',');{}

      {do a new poll mixing}
      asm
        {wait for a vertical retrace to start}
          mov dx,3dah
      @1: in al,dx
          test al,8
          jz @1
        {music can be polled now}
          call sds_poll  {has effect only in POLL mode}
        {wait for vertical retrace to finish}
      @2: in al,dx
          test al,8
          jnz @2
      end;
    until keypressed;
    ch:=readkey; if ch=#0 then ch:=readkey;
    case ch of
      '+' : incvolume;
      '-' : decvolume;
      '[' : decamplification;
      ']' : incamplification;
      'p' : begin  {poll/timer}
              k:=getesbbyte(48);
              k:=word(not wordbool(k));
              asm
                mov ax,k
                mov ah,05h
                call dword ptr services
              end
            end;
      '{' : decmastervol;
      '}' : incmastervol;
      's' : begin  {surround/normal}
              k:=getesbbyte(34);
              k:=word(not wordbool(k));
              asm
                mov ax,k
                mov ah,04h
                call dword ptr services
              end
            end;
      '>' : begin {skip pattern}
              asm
                mov ah,17
                call dword ptr services
              end
            end;
      '1'..'9' : begin { on/off channel - Dxx command still has problems w/ it ! }
              stat:=getesbdword(49);
              k:=byte(ch)-byte('1');
              if (stat and (1 shl k) = 0) then
                asm
                  mov ax,k
                  mov ah,9
                  call dword ptr services
                end
              else
                asm
                  mov ax,k
                  mov ah,10
                  call dword ptr services
                end
            end;
      'u' : begin {pause/restart}
              k:=getesbbyte(35); {flags byte}
              if (k and 2 = 2) and (k and 4 = 0) then
                asm {sds is playing, must be paused}
                  mov ah,20
                  call dword ptr services
                end
              else
                asm {sds is paused, must be restarted}
                  mov ah,21
                  call dword ptr services
                end;
            end;
    end;
  until ch=#27;

  sds_stopplay;
  sds_done;
  sds_unload(module);

{  if loaderror<>0 then writeln('Deallocation error.');}
end;
end.