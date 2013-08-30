{4m 64000,0,640000}
uses crt, play;

var voc  : pointer;
    name : string;

begin
 getmem(voc, 65535);

 if paramcount = 1 then
  name := paramstr(1)
 else
  begin
   write('Play voc file (size < 65535!): ');
   readln(name);
  end;

 play_voc(name, voc);

 freemem(voc, 65535);
end.
