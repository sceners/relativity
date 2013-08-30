{$M 65000,0,655360}
uses revsmth,revconst,revansi,revdat,player;
begin
extractfilefromdat(muscfgfile);
displayansi(muscfgfile);
initexpmus;
end.
  halt;
  sds_stopplay;
  sds_done;
  UseEMS:=true;
  UseUMB:=true;
  UserRoutine:=@MyFuckinRoutine;
  module:=sds_load(ParamStr(1),(card<>Silence));
  if card=GUS then writeln(#13#10,round(gus_DRAM/1024),' kb of GUS DRAM detected');
  services:=pointer(GetESBdword(44));
  textattr:=15;
{  writeln('"',ModuleName,'"');}
  textattr:=10;
  textattr:=7;
  sds_setsurround(on);
  sds_setpollmix(off);
  sds_startplay(module, 0{InitSpeed(0=auto)}, 44000{MixSpeed}, NTSC{1=Pal,0=NTSC});
  repeat
    repeat
      if getesbbyte(35) and 4 <> 0 then
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
                  ',PattOffs=',dec2hex(getesbword(40)),{}
                  ',S:',getesbbyte(34));

      temp:=getesbbyte(38);
      {do a new poll mixing}
      asm
        {wait for a vertical retrace to start}
          mov dx,3dah
      @1: in al,dx
          test al,8
          jz @1
        {music can be polled now}
          call sds_poll  {has effect only in POLL mode}
          cmp temp,170
          jbe @2
          call sds_poll  {call it twice if BPM>170 !!!}
        {wait for vertical retrace to finish}
      @2: in al,dx
          test al,8
          jnz @2
      end;
    until keypressed;
    repeat ch:=ReadKey until ch<>#0;
    case ch of
      '+' : incvolume;
      '-' : decvolume;
      '[' : decamplification;
      ']' : incamplification;
      'p' : sds_setpollmix(not(bytebool(getesbbyte(48))));
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
  if loaderror<>0 then writeln('Deallocation error.');
  end;