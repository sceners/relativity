

uses crt, play;
const max =57;
type str8= string[8];
     sub = record
         name : str8;
         del : integer;
     end;
var voc  : pointer;
    name : string;
    a: array[1..max] of sub;
    i:byte;

Procedure InitVoc;
begin
     i:=1;
     a[i].name:='planet';a[i].del:=2000;inc(i);
     a[i].name:='known';a[i].del:=3000;inc(i);
     a[i].name:='sandland';a[i].del:=2000;inc(i);
     a[i].name:='home';a[i].del:=1200;inc(i);
     a[i].name:='spice';a[i].del:=3000;inc(i);
     a[i].name:='melange';a[i].del:=2000;inc(i);
     a[i].name:='spice2';a[i].del:=2000;inc(i);
     a[i].name:='controls';a[i].del:=2000;inc(i);
     a[i].name:='empire';a[i].del:=2000;inc(i);
     a[i].name:='whoever';a[i].del:=2000;inc(i);
     a[i].name:='control2';a[i].del:=2000;inc(i);
     a[i].name:='control3';a[i].del:=2000;inc(i);
     a[i].name:='proposed';a[i].del:=2000;inc(i);
     a[i].name:='ehouse';a[i].del:=2000;inc(i);
     a[i].name:='eproduce';a[i].del:=2000;inc(i);
     a[i].name:='emost';a[i].del:=2000;inc(i);
     a[i].name:='econtrol';a[i].del:=2000;inc(i);
     a[i].name:='enoset';a[i].del:=2000;inc(i);
     a[i].name:='eterrit';a[i].del:=2000;inc(i);
     a[i].name:='eandno';a[i].del:=2000;inc(i);
     a[i].name:='erules';a[i].del:=2000;inc(i);
     a[i].name:='vast';a[i].del:=2000;inc(i);
     a[i].name:='arrived';a[i].del:=2000;inc(i);
     a[i].name:='andnow';a[i].del:=2000;inc(i);
     a[i].name:='3houses';a[i].del:=2000;inc(i);
     a[i].name:='control4';a[i].del:=2000;inc(i);
     a[i].name:='ofdune';a[i].del:=2000;inc(i);
     a[i].name:='noble';a[i].del:=2000;inc(i);
     a[i].name:='insid';a[i].del:=2000;inc(i);
     a[i].name:='ord';a[i].del:=2000;inc(i);
     a[i].name:='evil';a[i].del:=2000;inc(i);
     a[i].name:='hark';a[i].del:=2000;inc(i);
     a[i].name:='house2';a[i].del:=2000;inc(i);
     a[i].name:='prevail';a[i].del:=2000;inc(i);
     a[i].name:='your';a[i].del:=2000;inc(i);
     a[i].name:='battle';a[i].del:=2000;inc(i);
     a[i].name:='begins';a[i].del:=2000;inc(i);
     a[i].name:='now';a[i].del:=2000;inc(i);
end;

begin
 getmem(voc, 65535);
{ name:='ehouse';
 play_voc(name+'.voc', voc);
 halt;}
 initvoc;
 for i:= 3 to 6 do
 begin
 name:=a[i].name;
 if name<>'' then
 begin
  play_voc(name+'.voc', voc);
  delay(a[i].del);
 end;
 end;

 freemem(voc, 65535);
end.
