unit revboom;

interface

procedure f2_help;

implementation
uses revdat,revconst,revansi,dos,crt,revgfx,revmus,cdrom,revrad,revhelp,
     revmouse,revmem,revtech,cd_rom;

Procedure f2_help;
var k:char;
    tag:integer;
label overandout;

procedure check_tag(var tag:integer);
begin
     if tag<1 then tag:=maxboom;
     if tag>maxboom then tag:=1;
end;

Procedure InitBoomScreen;
begin
textcolor(darkgray);
textbackground(green);
     gotoxy(73,4);write('');
     gotoxy(71,5);write('VolUp');
     gotoxy(65,4);write('');
     gotoxy(63,5);write('VolDn');
     gotoxy(31,15);write('on/off');
     gotoxy(13,9);write('|');
     gotoxy(12,10);write('prev');
     gotoxy(21,9);write('|');
     gotoxy(20,10);write('next');
     gotoxy(30,9);write('');
     gotoxy(28,10);write('rewind');
     gotoxy(39,9);write('');
     gotoxy(38,10);write('ff');
     gotoxy(48,9);write('||');
     gotoxy(45,10);write('Rsm/Pse');
     gotoxy(57,9);write('');
     gotoxy(55,10);write('Pre');
     gotoxy(59,10);write('Drv');
     gotoxy(67,9);write('');
     gotoxy(64,10);write('Nxt');
     gotoxy(68,10);write('Drv');
     gotoxy(21,14);write('MUSIC');
     gotoxy(21,15);write('TYPE');
     gotoxy(42,14);write('');
     gotoxy(40,15);write('eject');
     gotoxy(51,14);write('||');
     gotoxy(48,15);write('Un/Lck');
     gotoxy(60,14);write('%$');
     gotoxy(58,15);write('Random');
end;

Procedure updateboomscreen;
begin
InitBoomScreen;
textcolor(lightgreen);
textbackground(green);
if tag=2 then
begin
     gotoxy(73,4);write('');
     gotoxy(71,5);write('VolUp');
end;
if tag=1 then
begin
     gotoxy(65,4);write('');
     gotoxy(63,5);write('VolDn');
end;
if tag=11 then
begin
     gotoxy(31,15);write('on/off');
end;
if tag=3 then
begin
     gotoxy(13,9);write('|');
     gotoxy(12,10);write('prev');
end;
if tag=4 then
begin
     gotoxy(21,9);write('|');
     gotoxy(20,10);write('next');
end;
if tag=5 then
begin
     gotoxy(30,9);write('');
     gotoxy(28,10);write('rewind');
end;
if tag=6 then
begin
     gotoxy(39,9);write('');
     gotoxy(38,10);write('ff');
end;
if tag=7 then
begin
     gotoxy(48,9);write('||');
     gotoxy(45,10);write('Rsm/Pse');
end;
if tag=8 then
begin
     gotoxy(57,9);write('');
     gotoxy(55,10);write('Pre');
     gotoxy(59,10);write('Drv');
end;
if tag=9 then
begin
     gotoxy(67,9);write('');
     gotoxy(64,10);write('Nxt');
     gotoxy(68,10);write('Drv');
end;
if tag=10 then
begin
     gotoxy(21,14);write('MUSIC');
     gotoxy(21,15);write('TYPE');
end;
if tag=12 then
begin
     gotoxy(42,14);write('');
     gotoxy(40,15);write('eject');
end;
if tag=13 then
begin
     gotoxy(51,14);write('||');
     gotoxy(48,15);write('Un/Lck');
end;
if tag=14 then
begin
     gotoxy(60,14);write('%$');
     gotoxy(58,15);write('Random');
end;
end;

Procedure UpDate;
label overandout;
begin
     if tag = 1 then
     begin
          tag:=9;
          goto overandout;
     end;
     if tag = 2 then
     begin
          tag:=9;
          goto overandout;
     end;
     if tag = 4 then
     begin
          tag:=10;
          goto overandout;
     end;
     if tag = 5 then
     begin
          tag:=11;
          goto overandout;
     end;
     if tag = 6 then
     begin
          tag:=12;
          goto overandout;
     end;
     if tag = 7 then
     begin
          tag:=13;
          goto overandout;
     end;
     if tag = 8 then
     begin
          tag:=14;
          goto overandout;
     end;
     if tag = 9 then
     begin
          tag:=14;
          goto overandout;
     end;
     if tag = 14 then
     begin
          tag:=1;
          goto overandout;
     end;
overandout:
end;

Procedure DownDate;
label overandout;
begin
     if tag = 1 then
     begin
          tag:=14;
          goto overandout;
     end;
     if tag = 9 then
     begin
          tag:=1;
          goto overandout;
     end;
     if tag = 10 then
     begin
          tag:=4;
          goto overandout;
     end;
     if tag = 11 then
     begin
          tag:=5;
          goto overandout;
     end;
     if tag = 12 then
     begin
          tag:=6;
          goto overandout;
     end;
     if tag = 13 then
     begin
          tag:=7;
          goto overandout;
     end;
     if tag = 14 then
     begin
          tag:=8;
          goto overandout;
     end;
overandout:
end;

Procedure CheckMusic(var cur:integer);
begin
if cur<1 then cur:=config^.lastmus;
if cur>config^.lastmus then cur:=1;
end;

Procedure PlayHscRad;
begin
if config^.muson=true then
   PlayMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
end;

Procedure CheckTrack(var cur:integer);
begin
if cur<1 then cur:=lasttrack;
if cur>lasttrack then cur:=1;
end;

Procedure StopHscRad;
begin
if config^.muson=true then
   StopMusic(config^.music[config^.curmus,1],config^.music[config^.curmus,2]);
end;

Procedure PlayButtonTwo;
begin
if (mustype=1) and adlib then {1=adlib}
begin
     StopHscRad;
     config^.curmus:=config^.curmus+1;
     checkmusic(config^.curmus);
     PlayHscRad;
end;
if cd and (mustype=2) then
begin
     inc(cdsongpos);
     checktrack(cdsongpos);
     if playing then
     begin
     stopcd(curcddrv);
     playTrack(curcddrv,cdsongpos);
     end;
end;
end;

Procedure PlayButtonOne;
begin
if (mustype=1) and adlib then {1=adlib}
begin
     StopHscRad;
     config^.curmus:=config^.curmus-1;
     checkmusic(config^.curmus);
     PlayHscRad;
     {writevol(52);}
end;
if cd and (mustype=2) then
begin
     dec(cdsongpos);
     checktrack(cdsongpos);
     if playing then
     begin
     stopcd(curcddrv);
     playTrack(curcddrv,cdsongpos);
     end;
end;
end;

Procedure CdHscRadInfo(What:string);
begin
textcolor(darkgray);
textbackground(black);
gotoxy(22,5);write('                  ');
gotoxy(26+((9-length(what))div 2),5);
write(what);
end;

Procedure WriteVol(vol:byte);
var i:integer;
begin
     textbackground(black);textcolor(white);
     for i:= 1 to 12 do
     begin
     gotoxy(45+i-1,4);write(' ');
     gotoxy(45+i-1,5);write(' ');
     end;
     for i:= 1 to (12-(64-vol)) do
     begin
     gotoxy(45+i-1,4);write('Ü');
     gotoxy(45+i-1,5);write('ß');
     end;
end;

Procedure Rand;
begin
if (mustype=1) and adlib then {1=adlib}
begin
     StopHscRad;
     config^.curmus:=random(musimplemented)+1;
{     checktrack(musimplemented);}
     PlayHscRad;
end;
if cd and (mustype=2) then
begin
     if playing then
     stopcd(curcddrv);
     cdsongpos:=random(lasttrack)+1;
     checktrack(cdsongpos);
     if playing then
     playTrack(curcddrv,cdsongpos);
end;
end;

Procedure Onoff;
begin
if (mustype=1) and adlib then {1=adlib}
begin
     if config^.muson=true then
     begin
          StopHscRad;
          config^.muson:=false;
     end
     else
     begin
          config^.muson:=true;
          PlayHscRad;
     end;
end;
if cd and (mustype=2) then
begin
     if playing then
     begin
     stopcd(curcddrv);
     playing:=false;
     end
     else
     begin
     playTrack(curcddrv,cdsongpos);
     playing:=true;
     end;
end;
end;

Procedure VolDn;
begin
if (mustype=1) and adlib then {1=adlib}
begin
     if (config^.vol<>52) then
     begin
          config^.vol:=config^.vol-1;
          radvolume(config^.vol);
          writevol(config^.vol);
     end
end
else
    writevol(52)
end;

Procedure VolUp;
begin
if (mustype=1) and adlib then {1=adlib}
begin
     if (config^.vol<>64) then
     begin
          config^.vol:=config^.vol+1;
          radvolume(config^.vol);
          writevol(config^.vol);
     end;
end
else
    writevol(52)
end;

Procedure Change;
label overandout;
begin
     if (mustype=1) and cd then
     begin
          StopHscRad;
          writevol(52);
          mustype:=2;
          if playing then
             playTrack(curcddrv,cdsongpos);
          goto overandout;
     end;
     if adlib and (mustype=2) then
     begin
          stopcd(curcddrv);
          writevol(config^.vol);
          if config^.muson=true then
             PlayHscRad;
          mustype:=1;
     end;
overandout:
end;

Procedure Door;
begin
if cd and (mustype=2) then
begin
if not dooropen(curcddrv) then
begin
   ejectCD(curcddrv);
   playing:=false;
end
else
    closecd(curcddrv);
end;
end;

Procedure Lock;
begin
if cd and (mustype=2) then
begin
if locked then
begin
   unlockCD(curcddrv);
   locked:=false;
end
else
begin
    lockCD(curcddrv);
    locked:=true;
end;
end;
end;

Procedure WriteType;
begin
     gotoxy(22,3);
     textcolor(lightgreen);
     textbackground(black);
     write(' ADLIB  SB  CDROM');
     textcolor(darkgray);
     if mustype=1 then
     begin
          gotoxy(23,3);write('ADLIB');
     end;
     if mustype=2 then
     begin
          gotoxy(34,3);write('CDROM');
     end;
     if mustype=3 then
     begin
          gotoxy(30,3);write('SB');
     end;
end;

Procedure WriteDrive;
var s:string[1];
begin
     textcolor(darkgray);
     textbackground(black);
     gotoxy(22,4);write(chr(curcddrv+65));
end;

Function MouseBorder(x,y,x1,y1,py,px:byte):boolean;
{px and y are backward}
begin
MouseBorder:=false;
     if (px>=x) and (px<=x1) then
        if (py>=y) and (py<=y1) then
        MouseBorder:=true;
end;


Var T:string;
    a:st12;

label start,help_1,fin,enter;
begin
     if keypressed then readkey;
     k:=#99;
     tag:=1;
     start:
     FadedownRGBScreen;
     Reset80x25VideoScreen;
     chbrght;
     HideCursor;
     extractfilefromdat(config^.BMMENUFILE);
     displayansi(config^.BMMENUFILE);
     deletedatfile(config^.BMMENUFILE);
     updateboomscreen;
     WriteType;
     WriteDrive;
     cdHscRadInfo(config^.music[config^.curmus,1]);
     if adlib then
        writevol(config^.vol);
     if mouse then showmouse;
     while k<>#27 do
     begin
      if mouse then
      begin
           GetMouseInfo(M);
           if (M.ButtonClicked = leftButton) then
           begin
                while not buttonreleased do
                begin
                end;
                if ((m.row = 1) and (m.column = 1)) or ((m.row = 25) and (m.column = 1))  then
                goto help_1;
                if MouseBorder(44,4,50,5,m.row,m.column) then
                begin
                tag:=1;
                     goto enter;
                end;
                if MouseBorder(62,4,68,6,m.row,m.column) then
                begin
                tag:=1;
                     goto enter;
                end;
                if MouseBorder(51,4,57,5,m.row,m.column) then
                begin
                tag:=2;
                     goto enter;
                end;
                if MouseBorder(70,4,76,6,m.row,m.column) then
                begin
                tag:=2;
                     goto enter;
                end;
                if MouseBorder(10,8,17,11,m.row,m.column) then
                begin
                tag:=3;
                     goto enter;
                end;
                if MouseBorder(19,8,25,11,m.row,m.column) then
                begin
                tag:=4;
                     goto enter;
                end;
                if MouseBorder(27,8,34,11,m.row,m.column) then
                begin
                tag:=5;
                     goto enter;
                end;
                if MouseBorder(36,8,42,11,m.row,m.column) then
                begin
                tag:=6;
                     goto enter;
                end;
                if MouseBorder(44,8,52,11,m.row,m.column) then
                begin
                tag:=7;
                     goto enter;
                end;
                if MouseBorder(54,8,62,11,m.row,m.column) then
                begin
                tag:=8;
                     goto enter;
                end;
                if MouseBorder(63,8,71,11,m.row,m.column) then
                begin
                tag:=9;
                     goto enter;
                end;
                if MouseBorder(18,13,27,16,m.row,m.column) then
                begin
                tag:=10;
                     goto enter;
                end;
                if MouseBorder(23,3,27,3,m.row,m.column) then
                begin
                tag:=10;
                     goto enter;
                end;
                if MouseBorder(34,3,38,3,m.row,m.column) then
                begin
                tag:=10;
                     goto enter;
                end;
                if MouseBorder(29,13,37,16,m.row,m.column) then
                begin
                tag:=11;
                     goto enter;
                end;
                if MouseBorder(39,13,45,16,m.row,m.column) then
                begin
                tag:=12;
                     goto enter;
                end;
                if MouseBorder(47,13,54,16,m.row,m.column) then
                begin
                tag:=13;
                     goto enter;
                end;
                if MouseBorder(57,13,64,16,m.row,m.column) then
                begin
                     tag:=14;
                     goto enter;
                end;
                updateboomscreen;
           end;
           if (M.ButtonClicked = rightButton) then
           begin
                 while not buttonreleased do
                 begin
                 end;
                    goto fin;
           end;
      end;
        IF KEYPRESSED THEN
          BEGIN
          k:=readkey;
          if k=#0 then
             k:=readkey;
          case k of
              #59 : begin
              help_1:
              if not help1 then
              begin
               config^.notavhelp:=config^.notavhelp+[2];
               help(a,0,0,false,slutbuf,slut);
               hidecursor;
               goto start;
              end;
                    end;
              #80 : begin {down}
                          update;
                          goto overandout;
                    end;
              #77 : begin {right}
                          inc(tag);
                          check_tag(tag);
                    end;
              #72 : begin
                          downdate;
                          goto overandout;
                    end;
              #75 : begin {left}
                          dec(tag);
                          check_tag(tag);
                    end;
              '+' : VolUp;
              '-' : VolDn;
              #27,'q' : begin
                        end;
              #13 : Begin
                  enter:
                         if tag=1 then
                         begin
                              VolDn;
                         end;
                         if tag=2 then
                         begin
                              VolUp
                         end;
                         if tag= 3 then
                         begin
                              PlayButtonOne;
                         end;
                         if tag= 4 then
                         begin
                              PlayButtonTwo;
                         end;
                         if tag= 7 then
                         begin
                              if pause then
                              begin
                                 resumeplay(curcddrv);
                                 pause:=false;
                              end
                              else
                              begin
                                   pause:=true;
                                   stopcd(curcddrv);
                              end;
                         end;
                         if tag= 8 then
                         begin
                              dec(curcddrv);
                              if curcddrv<startcd then
                                 curcddrv:=startcd+cdroms-1
                              else
                              begin
                              if  dooropen(curcddrv) then
                                  closecd(curcddrv);
                                   resetCD(curcddrv);
                                   stopCD(curcddrv);
                                   getAllTrackDetails(curcddrv);
                                   cdsongpos:=1;
                                   pause:=false;
                                   if playing then
                                   playTrack(curcddrv,cdsongpos);
                              end;
                         end;
                         if tag= 9 then
                         begin
                              inc(curcddrv);
                              if curcddrv-2>cdroms then
                                 curcddrv:=startcd
                              else
                              begin
                              if  dooropen(curcddrv) then
                                  closecd(curcddrv);
                                   resetCD(curcddrv);
                                   stopCD(curcddrv);
                                   getAllTrackDetails(curcddrv);
                                   cdsongpos:=1;
                                   pause:=false;
                                   if playing then
                                   playTrack(curcddrv,cdsongpos);
                              end;
                         end;
                         if tag= 10 then
                         begin
                              change;
                         end;
                         if tag= 11 then
                         begin
                              OnOff;
                         end;
                         if tag= 12 then
                         begin
                              door;
                         end;
                         if tag= 13 then
                         begin
                              Lock;
                         end;
                         if tag= 14 then
                         begin
                              Rand;
                         end;
                         if (tag in [3,4,10,11,14]) and (mustype=1) then
                         begin
                              CdHscRadInfo(config^.music[config^.curmus,1]);
                              WriteType;
                         end;
                         if (tag in [3,4,10,11,14]) and (mustype=2) then
                         begin
                              str(cdsongpos,t);
                              CdHscRadInfo('Track #'+t);
                              WriteType;
                              WriteDrive;
                         end;
                         if (tag in [8,9]) and (mustype=2) then
                         begin
                              WriteDrive;
                         end;
              end;
          end;
          overandout:
          updateboomscreen;
     end;
     end;
     fin:
     FadedownRGBScreen;
     Reset80x25VideoScreen;
     HideCursor;
end;

end.