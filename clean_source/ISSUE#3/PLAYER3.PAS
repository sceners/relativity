{$M 20000,0,0} {don't forget to reduce the heap!}
uses sds, sds_det, crt, alloc, esb, string_s, dos, files;

{ 
  Sound Deluxe System 5, a Maple Leaf production, 1996-1997
  Multi-module player (kinda musicdisk player)
}


var module   : pointer;
    services : pointer;
    ch       : char;
    k        : word;
    stat     : longint;
    filespec : string;
    rec      : searchrec;

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

procedure Load_And_Play_Module (name:string);
var finished:boolean;
label outta_here;  { ... I know, I know... }
begin
  write('Loading module ',onlyfilename(name),'...');
  UseEMS:=true;
  UseUMB:=true;

  UserRoutine:=nil;{@MyFuckinRoutine;{}
  module:=sds_load(name,(card<>Silence){load samples only if card is NOT UltraSilence});

  if loaderror<>0 then begin
    writeln(#13'Error loading module (errorcode=',loaderror,')');
    sds_done; {dont forget to close SDS before exit!}
    halt
  end;

  services:=pointer(GetESBdword(44));

  textattr:=15;
  write(#13,'"',ModuleName,'"'); clreol;
  textattr:=10;
  writeln(#13#10,channels,' channels, ',patterns,' patterns, ',entries,' orders, ',Samples,' samples');

  textattr:=7;

  sds_setsurround(on);
  sds_setpollmix(off);
  sds_startplay(module, 0{InitSpeed(0=auto)}, 44100{MixSpeed}, NTSC{1=Pal,0=NTSC});

  finished:=false;

  repeat

    repeat

      if getesbbyte(35) and 4 <> 0 then
        write(#13'PAUSED. Press "u" to resume.')
      else
        write(#13,getesbword(20):2,'(',
                  getesbword(22):2,'):',
                  getesbword(26):2,'/',
                  getesbword(24)-1:2,
                  ',Spd=',getesbword(36),
                  ',BPM=',dec2hex(getesbword(38)),
                  ',UC=',dec2hex(getesbdword(53)),
                  ',V=',dec2hex(getesbbyte(30)),
                  ',MV=',dec2hex(getesbbyte(31)),
                  ',A=',getesbword(32),
                  {',Dst=',dec2hex(getesbword(58)),{}
                  ',PattOffs=',dec2hex(getesbword(40)),
                  ',S:',getesbbyte(34));


      clreol;

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
      finished:=(getesbbyte(35) and 1 = 1);
    until keypressed or finished;

    if finished then goto outta_here;
    repeat ch:=ReadKey until ch<>#0;

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
  until ch in [#27,' '];

outta_here:
  writeln;
  sds_stopplay;
  sds_unload(module);
  if loaderror<>0 then writeln('Deallocation error.');
  if not finished and (ch=#27) then halt;
end;

begin
  writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('³  Sound Deluxe System 5, a Maple Leaf production, 1996-1997      ³');
  writeln('³  General player version 2.0 (example program)                   ³');
  writeln('³  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ³');
  writeln('³  For problems/questions concerning this program or any other    ³');
  writeln('³  part of Sound Deluxe System, please contact me:                ³');
  writeln('³  ş Maple Leaf (a.k.a. Gruian Radu)                              ³');
  writeln('³  ş str.Lunii, nr.22, ap.4, Cluj Napoca, 3400, Romƒnia           ³');
  writeln('³  ş Phone: 040 64 124260                                         ³');
  writeln('³  ş e-Mail: maple_leaf_@hotmail.com, or                          ³');
  writeln('³            lsmm@hercule.utcluj.ro (w/ mention "pt. Maple Leaf") ³');
  writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  writeln;

  if paramcount=0 then begin
    writeln(#13#10'Syntax: PLAYER3 filespec');
    writeln('Example: PLAYER3 *.S3M');
    halt;
  end;

  filespec:=paramstr(1);

  card:=DetectSoundCard(Base,Irq,Dma);

  writeln('Init sound system (',dec2Hex(base),',IRQ',irq,',DMA #',Dma,') ...');
  sds_init(Card{Card#},Base{BasePort},Irq{IRQ},DMA{DMA#});

  findfirst(filespec,$3f,rec);
  while doserror=0 do begin
    if (rec.name[1]<>'.') and (rec.attr and $18=0) then begin
      Load_And_Play_Module (onlydir(filespec)+rec.name);
    end;
    findnext(rec);
  end;

  writeln('Shuting down SDS ...');
  sds_done;
end.