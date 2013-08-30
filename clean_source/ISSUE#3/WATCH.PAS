uses esb, crt;

var magic:longint;
    dopoll:pointer;
    services:pointer;

procedure noSDS;
begin
  writeln('SDS is not playing !  Run a SDS background session first !');
  halt;
end;

procedure SayName;
var s:string; p:pointer; k:byte; c:char;
begin
  writeln;
  p:=pointer(getESBdword(60));
  s:='';
  k:=0; c:=' ';
  while (c<>#0) and (k<128) do begin {asciiz}
    inc(k);
    s[0]:=char(k);
    s[k]:=char(mem[seg(p^):ofs(p^)+k-1]);
    c:=char(mem[seg(p^):ofs(p^)+k]);
  end;
  write('ID STRING FOUND: ');
  textattr:=10; writeln(s);
  s[0]:=#4;
  move(magic,s[1],4);
  textattr:=7; write('MAGIC ID FOUND: ');
  textattr:=11; writeln(s);
end;

procedure SayPara;
var over:boolean;
    k:word;
begin
  services:=pointer(getesbdword(44));
  dopoll:=pointer(getesbdword(0));
  textattr:=7; writeln(#13#10'SDS is now playing :');
  over:=false;
  repeat
    write(#13, 'Ord ',getesbword(20),',',
              'Pat ',getesbword(22),',',
              'Row ',getesbword(26),',',
              'Vol ',getesbbyte(30),',',
              'MVol ',getesbbyte(31),',',
              'Amp ',getesbword(32),'%,',
              'Spd ',getesbword(36),',',
              'BPM ',getesbword(38),',',
              'Dst ',getesbword(58){}
              {'UC=',getesbdword(53){}
    );
    clreol;
    if keypressed then
      case UpCase(readkey) of
        'P' : begin
                k:=word(not bytebool(getesbbyte(48)));
                asm
                  mov ax,k
                  mov ah,5
                  call dword ptr services
                end;
              end;
        #27 : over:=true;
      end;
    asm
        mov dx,3dah
    @1: in al,dx
        test al,8
        jnz @1
        call dword ptr DoPoll
        call dword ptr DoPoll {do not call it twice but only when BPM > 170 !!!}
    @2: in al,dx
        test al,8
        jz @2
    end;
  until over;
  write(#13); clreol;
  readkey;
end;

begin
  if memw[0:$4fe]=0 {seg} then noSDS;
  magic:=getEsbDword(64);
  if (magic and $FFFFFF) <> $534453 then noSDS;
  writeln('I''ve found a SDS background session.');
  SayName;
  SayPara;
end.
