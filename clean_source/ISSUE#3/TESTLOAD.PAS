{$m 32000,0,0} {don't forget to lower the heap!}
uses strings,files,alloc,sds,crt;

var p:pointer;
    lpptab:array[byte] of byte;
    ordtab:array[byte] of byte;

function hex(b:byte):string;
const hexdigit:string='0123456789ABCDEF';
begin
  hex:=hexdigit[b shr 4 + 1] + hexdigit[b and $F + 1];
end;

procedure savesam(addr:pointer; size:word; name:string);
var f:file;
begin
  openforoutput(f,name);
  if sds_writeblock(f,addr,size,0)<size then begin
    writeln('Disk full');
  end;
  closefile(f);
end;

procedure showpatt(nrpat:word; tabptr:pointer; channels:word);
var patptr:pointer; r,c,patseg:word;
    event:array[0..31] of array[0..4] of byte;
    patoffs:word;
    b:byte;
label GetOut;
begin
  textattr:=7;
  writeln('----<< pattern #',nrpat,' (',pattsize[nrpat],' bytes) >>----');
  patptr:=pointer(pointer(longint(tabptr)+nrpat*4)^);
  patseg:=seg(patptr^);
  patoffs:=0;
  fillchar(event,channels*5,0);
  for r:=0 to lpptab[nrpat]-1 do begin
    if (r=20) or (r=40) then
      if readkey in['q','Q'] then goto GetOut;
    { unpack event }
    for c:=0 to channels-1 do begin
      b:=mem[patseg:patoffs];
      if b=$FF then
        inc(patoffs)  {the same event on this channel}
      else begin
        if b=$FD then begin
          event[c][0]:=0; event[c][1]:=0;
          event[c][2]:=$41; event[c][3]:=0;
          event[c][4]:=0;
          inc(patoffs);
        end else begin
          event[c][0]:=b;
          event[c][1]:=mem[patseg:patoffs+1];
          b:=mem[patseg:patoffs+2];
          event[c][2]:=b and $7F;
          event[c][3]:=0;
          event[c][4]:=0;
          if b and $80=0 then
            inc(patoffs,3)  {no effect+para}
          else begin
            event[c][3]:=mem[patseg:patoffs+3];
            event[c][4]:=mem[patseg:patoffs+4];
            inc(patoffs,5);
          end;
        end;
      end;
    end;
    textattr:=15; write(hex(r),'³');{}
    { show event }
    for c:=0 to channels-1{} do begin
      {textattr:=11; write(hex(event[c][0]));{note}
      textattr:=3;  write(hex(event[c][1]));{sample}
      textattr:=9;  write(hex(event[c][2]));{volume}
      {textattr:=7;  write(hex(event[c][3]));{effect}
      {textattr:=8;  write(hex(event[c][4]));{para}
      textattr:=7;  write('³');{}
    end;
    textattr:=7;
    writeln(#8' ');{}
  end;
  readkey;
GetOut:
end;

procedure check(p:pointer);
var sh:sdmint_headtype; a:word;
    ss:sdmint_insttype;
    offs:word;
begin
  move(p^,sh,sizeof(sh));
  writeln('-----------------------------------------------------------------------------');
  writeln('  Patterns        = ',sh.patterns);
  writeln('  Entries         = ',sh.entries);
  writeln('  Instruments     = ',sh.samples);
  writeln('  Channels        = ',sh.channels);
  writeln('  Initial volume  = ',hex(sh.initgvolume)+'h');
  writeln('  Initial speed   = ',sh.initspeed);
  writeln('  Initial BPM     = ',hex(sh.initbpm)+'h');
  write  ('  VRI             = ');
  for a:=0 to sh.channels-1 do write(sh.vri[a],' '); writeln;
  writeln('  Master volume   = ',sh.mastervolume);
  writeln('  PattAddrTabPtr  = ',dec2hex(seg(sh.pattaddrtabptr^)),':',dec2hex(ofs(sh.pattaddrtabptr^)));
  move(pointer(longint(p)+sizeof(sh))^, lpptab, sh.patterns);
  writeln('  LinesPerPatt :');
  for a:=0 to sh.patterns-1 do write(lpptab[a],','); writeln(#8' ');
  move(pointer(longint(p)+sizeof(sh)+sh.patterns)^, ordtab, sh.entries);
  writeln('  Order:');
  for a:=0 to sh.entries-1 do write(ordtab[a],','); writeln(#8' ');
  offs:=sizeof(sh)+sh.patterns+sh.entries;
  textattr:=7;
  for a:=1 to sh.samples do begin
    writeln('-----< Instrument #',a,' >-----');
    move(pointer(longint(p)+offs)^,ss,sizeof(ss));
    offs:=offs+sizeof(ss);
    writeln('  Name         = ',sname[a]);
    writeln('  Volume       = ',hex(ss.volume),'h');
    writeln('  C2 Speed     = ',ss.c2speed);
    writeln('  Address      = ',dec2hex(ss.address),'h');
    writeln('  Size         = ',ss.size);
    writeln('  Loop Start   = ',ss.loopstart);
    writeln('  Loop End     = ',ss.loopend);
    {savesam(sample[a],ss.size,'instr'+istr(a)+'.sam');{}
    readkey;
  end;
  for a:=0 to sh.patterns-1 do begin
    showpatt(a,sh.pattaddrtabptr,sh.channels);
  end;
  writeln(' ----<< End of patterns >>---------------------------------------------------');
  writeln;
end;

begin
  UseEMS:=true; UseUMB:=true; UseGUS:=false;
  p:=sds_load(paramstr(1),true);
  if loaderror<>0 then begin
    writeln('error ',loaderror);
    halt
  end;
  check(p);
  sds_unload(p);
end.