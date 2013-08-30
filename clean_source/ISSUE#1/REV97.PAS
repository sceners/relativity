 (****************************************************************************)
(*                                                                          *)
(* REV97.PAS - The Relativity Emag (coded in Turbo Pascal 7.0)              *)
(*                                                                          *)
(* "The Relativity Emag" was originally written by En|{rypt, |MuadDib|.     *)
(* This source may not be copied, distributed or modified in any shape      *)
(* or form. Some of the code has been derived from various sources and      *)
(* units to help us produce a better quality electronic magazine to let     *)
(* the scene know that we are THE BOSS.                                     *)
(*                                                                          *)
(* Program Notes : This program presents "The Relativity Emag"              *)
(*                                                                          *)
(* ASM/TP70 Coder : xxxxx xxxxxxxxx (En|{rypt)  - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* TP70 Coder     : xxxxx xxxxxxxxx (|MuadDib|) - xxxxxx@xxxxxxxxxx.xxx     *)
(*                                                                          *)
(****************************************************************************)


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - The Heading Specifies The Program Name And Parameters.  *)
(****************************************************************************)

Program The_Relativity_Electronic_Magazine;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)

{$A+}{$B+}{$D+}{$F+}{$G+}{$I+}{$K+}{$L+}{$N+}{$O-}{$P+}{$Q-}{$R-}{$S+}{$T+}
{$V-}{$W+}{$X+}{$Y+}
{$C MOVEABLE PRELOAD DISCARDABLE}
{$D The Relativity Emag (in Turbo Pascal 7.0)}
{$M 65000,0,80000}
{$S 32768}


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

uses  AdvHSC,Crt,Dos,FastTTT5,KeyTTT5,ReadTTT5,RevDat,RevGfx,RevMem,Tgp,
      Tuc_Demo,U_Vga,U_ffGif,U_Kb;

{$I MENU.PAS}
{$I MENutd.PAS}
{$I SUB2.PAS}
{$I SUB4.PAS}
{$I SUB5.PAS}
{$I SUB2acd.PAS}
{$I SUB4acd.PAS}
{$I SUB5acd.PAS}

const
    topics=18;
    main_menu : array[1..topics] of string[24] =
   ('ş Introduction        ',
    'ş Cover Story         ',
    'ş Articles            ',
    'ş Inside Scoop        ',
    'ş Game Reviews        ',
    'ş Fascinating Stories ',
    'ş Scene News Flash    ',
    'ş Special Highlights  ',
    'ş Scene Group NFOs    ',
    'ş Top 10 Couriers     ',
    'ş Top 10 Sites        ',
    'ş Secret Articles     ',
    'ş Group Requests      ',
    'ş Personal Requests   ',
    'ş Overall Survey      ',
    'ş Job Openings        ',
    'ş Contacting Us       ',
    'ş Conclusion          ');

    cover_story : array[1..topics] of string[24] =
   ('ş PSG Log Part 1      ',
    'ş PSG Log Part 2      ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş Exit To Main        ');

   inside_scoop : array[1..topics] of string[24] =
   ('ş RaZoR 1911 Log      ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş Exit To Main        ');

   game_reviews : array[1..topics] of string[24] =
   ('ş Alien Rampage       ',
    'ş Street Racer        ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş -------------       ',
    'ş Exit To Main        ');

TYPE
    ScreenType = array [0..3999] of Byte;
var ScreenAddr : ScreenType absolute $B800:$0000;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
  Info          : Gif_InfoRec;
  BgiPath,Fname : PathStr;
  DummyGif      : BYTE;
  DeleteFile    : file;
  XX            : BYTE;
  I             : BYTE;
  J             : BYTE;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Make The PC Speaker Beep After Every Keypress.          *)
(****************************************************************************)

procedure KeyClick;
begin
  Clear80x25VideoScreen;
  KTTT.Click := True;
  with RTTT do
  begin
    RightJustify := True;
    EraseDefault := True;
    AllowNull := True;
    SuppressZero := True;
  end;
end;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Controls The Initialization Phases. (EXE And WAD Files) *)
(****************************************************************************)

procedure InitializeDetectionPhase;
begin
  GetMainMemory;
  CheckMainMemory;
  FlushDiskCaches;
  CheckXMSEMSMemory;
  Debugmode:=True;
  Writeln;
  Writeln('Sound Card Detected: ',Tgp.BestCard);
  Tgp.Device:=Tgp.Info.BestCard.Device;
  Tgp.MusPort:=Tgp.Info.BestCard.Port;
  Tgp.Irq:=Tgp.Info.BestCard.Irq;
  Tgp.Dma:=Tgp.Info.BestCard.Dma;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Error Handler For All Errors Which Can Be Generated.    *)
(****************************************************************************)

procedure ErrorHandler(ErrorNumber : Integer);
begin
  case ErrorNumber of
    2 :  Writeln('File not found...');
    3 :  Writeln('Path not found...');
    5 :  Writeln('Access denied...');
    6 :  Writeln('Invalid handle...');
    8 :  Writeln('Not enough memory...');
    10:  Writeln('Invalid environment...');
    11:  Writeln('Invalid format...');
    18:  Writeln('No more files...');
  end;
end;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Delete Any Amount Of Files From The DAT (Extraction).   *)
(****************************************************************************)

procedure DeleteDatFile(filename:string);
var DeleteFile : Text;
begin
  Assign(DeleteFile,filename);
  Rewrite(DeleteFile);
  Close(DeleteFile);
  Erase(DeleteFile);
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Runs Exe                                                *)
(****************************************************************************)
function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;

Procedure Run(filename:string);
begin
if fileexists(filename) then
begin
  SwapVectors;
  Exec(filename, '');
  SwapVectors;
end;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Starting And Ending Initialization Phases (Detection).  *)
(****************************************************************************)

procedure PrintDetectionPhase;
begin
{ SwapVectors;
  Exec('CPUID.EXE', '');
  SwapVectors;
  if DosError <> 0 then
    Writeln('Dos error #', DosError);
  ErrorHandler(DosError); }
  HideCursor;
{ Writeln; }
  Writeln('CPU IDENTIFICATION ROUTINES HAVE BEEN EXCLUDED IN THIS ISSUE.');
  Writeln('--------------------------------------------------------------------------------');
  Writeln('Type -------- for Help');
  Writeln;
  InitializeDetectionPhase;
  Writeln;
  Writeln('Last Updated: December 10th, 1996');
  Writeln;
  Writeln('--------------------------------------------------------------------------------');
end;

procedure PrintEndingPhase;
begin
  Reset80x25VideoScreen;
  HideCursor;
  Writeln('                          Relativity Emag Issue #1!');
  Writeln('                          Coded by En|{rypt/MuadDib');
  Writeln('                        Relativity Productions(c)1997');
  Writeln;
  Writeln('                      Credits to all REV 97 members for');
  Writeln('                      sticking through all the 5 months');
  Writeln('                      of pain & agony, but its worthit!');
  Writeln;
  Writeln('                      Special thanks to Edge!! who made');
  Writeln('                      the first GIF (issue #1!) and who');
  Writeln('                      has been one of my friends in the');
  Writeln('                      scene for a long time. - En|{rypt');
  Writeln;
  Writeln('                         press any key to continue');
  Readln;
end;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Plays MOD Sound Files In The Background (Soundcard).    *)
(****************************************************************************)

procedure StartMODBackgroundMusic(filename:string);
begin
  Tgp.FastInit(filename,Tgp.Device,Tgp.Irq,Tgp.Dma,Tgp.MusPort,Freq(CurFreq));
  Tgp.Volume(255);
  Tgp.StartMus;
end;

procedure StopMODBackgroundMusic;
begin
  Tgp.StopMus;
  Tgp.UnloadMus;
  UnInit_DemoUnit;
  Tgp.UnloadMus;
end;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Plays HSC Sound Files In The Background (Soundcard).    *)
(****************************************************************************)

procedure StartHSCBackgroundMusic(filename:string);
begin
  LoadSong(filename);
  PlaySong;
end;

procedure StopHSCBackgroundMusic;
begin
  FadeSong;
  StopSong;
  ClearMem;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Displays An 8bit 256-Color GIF Image On The Screen.     *)
(****************************************************************************)

procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
begin
  inline (
    $1E/$C5/$B6/ADDR1/$C4/$BE/ADDR2/$8B/$8E/BLKLEN/$E3/$5B/$8B/$D7/$33/$C0/
    $FC/$AC/$3C/$20/$72/$05/$AB/$E2/$F8/$EB/$4C/$3C/$10/$73/$07/$80/$E4/$F0/
    $0A/$E0/$EB/$F1/$3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/$02/$C0/$02/$C0/
    $02/$C0/$80/$E4/$8F/$0A/$E0/$EB/$DA/$81/$C2/$A0/$00/$8B/$FA/$EB/$D2/$3C/
    $1B/$72/$07/$75/$CC/$80/$F4/$80/$EB/$C7/$3C/$19/$8B/$D9/$AC/$8A/$C8/$B0/
    $20/$74/$02/$AC/$4B/$32/$ED/$41/$F3/$AB/$8B/$CB/$49/$E0/$AA/$1F);
end;

Procedure DisplayAnsi(name:string);     {acid}
begin
  move(name,mem[$b800:160], 4000);
end;

procedure DisplayGIF(GIFname:string);
begin
  BgiPath := '';
  Fname := GIFname;
  if Gif_Info(Fname,Info)<>Gif_Ok then begin
    Writeln('Error: ',Gif_ErrStr); Halt; end;
  with Info do
  DummyGif := Gif_Display(Fname,BgiPath,-1);
  ClearKeyBuf; WaitKey(0);
  FadedownRGBScreen;
  SetVideo(U_Lm);
end;

procedure StopMainMenuPhase;
begin
  Reset80x25VideoScreen;
  ExtractFileFromDat('SVGA256.BGI');
  ExtractFileFromDat('EX-REV1.GIF');
  DisplayGIF('EX-REV1.GIF');
  DeleteDatFile('EX-REV1.GIF');
  DeleteDatFile('SVGA256.BGI');
  Reset80x25VideoScreen;
  ExtractFileFromDat('VISUAL1.EXE');
  run('VISUAL1.EXE');
{  if DosError <> 0 then
    Writeln('Dos error #', DosError);}
{ ErrorHandler(DosError); }
  Delay(1000);
  DeleteDatFile('VISUAL1.EXE');
  Reset80x25VideoScreen;
  StopMODBackgroundMusic;
{ StopHSCBackgroundMusic; }
  DeleteDatFile('DUNEINTR.MOD');
  TextColor(7);
  TextBackground(black);
  PrintEndingPhase;
  Reset80x25VideoScreen;
  ShrinkHeapMemory;
  Halt;
end;

procedure write_bar(b,t:integer);
var
i,a,x,y:integer;
str:string;
begin
textcolor(black);
textbackground(lightgray);
x:=25;
y:=15;
for a := 1 to 18 do
  begin
    if b=a then
    begin
    gotoxy(x-1,y);
    str:=main_menu[a];
    textbackground(red);
    write(' ');
    textcolor(darkgray);
    write(str[1]);
    write(str[2]);
    for i:= 3 to length(str) do
    write(str[i]);
    end
    else
    begin
    gotoxy(x-1,y);
    str:=main_menu[a];
    textbackground(darkgray);
    write(' ');
    textcolor(red);
    write(str[1]);
    textcolor(lightred);
    write(str[2]);
    textcolor(darkgray);
    for i:= 3 to length(str) do
    write(str[i]);
    end;
    inc(y);
    if a=9 then
    begin
     y:=15;
     x:=51;
     end;
  end;
end;

procedure write_bar2(b,t:integer);
var
i,a,x,y:integer;
str:string;
begin
textcolor(black);
textbackground(lightgray);
x:=25;
y:=15;
for a := 1 to 18 do
  begin
    if b=a then
    begin
    gotoxy(x-1,y);
    str:=cover_story[a];
    textbackground(red);
    write(' ');
    textcolor(darkgray);
    write(str[1]);
    write(str[2]);
    for i:= 3 to length(str) do
    write(str[i]);
    end
    else
    begin
    gotoxy(x-1,y);
    str:=cover_story[a];
    textbackground(darkgray);
    write(' ');
    textcolor(red);
    write(str[1]);
    textcolor(lightred);
    write(str[2]);
    textcolor(darkgray);
    for i:= 3 to length(str) do
    write(str[i]);
    end;
    inc(y);
    if a=9 then
    begin
     y:=15;
     x:=51;
     end;
  end;
end;

procedure write_bar4(b,t:integer);
var
i,a,x,y:integer;
str:string;
begin
textcolor(black);
textbackground(lightgray);
x:=25;
y:=15;
for a := 1 to 18 do
  begin
    if b=a then
    begin
    gotoxy(x-1,y);
    str:=inside_scoop[a];
    textbackground(red);
    write(' ');
    textcolor(darkgray);
    write(str[1]);
    write(str[2]);
    for i:= 3 to length(str) do
    write(str[i]);
    end
    else
    begin
    gotoxy(x-1,y);
    str:=inside_scoop[a];
    textbackground(darkgray);
    write(' ');
    textcolor(red);
    write(str[1]);
    textcolor(lightred);
    write(str[2]);
    textcolor(darkgray);
    for i:= 3 to length(str) do
    write(str[i]);
    end;
    inc(y);
    if a=9 then
    begin
     y:=15;
     x:=51;
     end;
  end;
end;

procedure write_bar5(b,t:integer);
var
i,a,x,y:integer;
str:string;
begin
textcolor(black);
textbackground(lightgray);
x:=25;
y:=15;
for a := 1 to 18 do
  begin
    if b=a then
    begin
    gotoxy(x-1,y);
    str:=game_reviews[a];
    textbackground(red);
    write(' ');
    textcolor(darkgray);
    write(str[1]);
    write(str[2]);
    for i:= 3 to length(str) do
    write(str[i]);
    end
    else
    begin
    gotoxy(x-1,y);
    str:=game_reviews[a];
    textbackground(darkgray);
    write(' ');
    textcolor(red);
    write(str[1]);
    textcolor(lightred);
    write(str[2]);
    textcolor(darkgray);
    for i:= 3 to length(str) do
    write(str[i]);
    end;
    inc(y);
    if a=9 then
    begin
     y:=15;
     x:=51;
     end;
  end;
end;

procedure StartMainMenuPhase;

procedure StartCoverMenuPhase;
var c,b,P,code : Integer;
    k          : Char;
    str        : string;
label stop,damn;
begin
Reset80x25VideoScreen;
HideCursor;
UNCRUNCH (sub2,ScreenAddr[ (1*2) + (1*160) -162],sub2_length);
k:=#22;
c:=1;
write_bar2(c,topics);
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : ; {this is f1 -- 60 61 62....}
    #72 : begin dec(c); end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=c+9;
          end;
    #80 : begin inc(c); end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          end;
    #27,'q' : begin gotoxy(39,25); StartMainMenuPhase; end;
    #13 : Begin
        case c of
        1:begin
          gotoxy(39,25);
          ExtractFileFromDat('COVERPT1.EXE');
          Reset80x25VideoScreen;
          run('COVERPT1.EXE');
          UNCRUNCH (sub2,ScreenAddr[ (1*2) + (1*160) -162],sub2_length);
 {         StartCoverMenuPhase;}
          end;
        2:begin
          gotoxy(39,25);
          ExtractFileFromDat('COVERPT2.EXE');
          Reset80x25VideoScreen;
          run('COVERPT2.EXE');
          UNCRUNCH (sub2,ScreenAddr[ (1*2) + (1*160) -162],sub2_length);
{          StartCoverMenuPhase;}
          end;
        3:begin gotoxy(39,25); write('N/A'); end;
        4:begin gotoxy(39,25); write('N/A'); end;
        5:begin gotoxy(39,25); write('N/A'); end;
        6:begin gotoxy(39,25); write('N/A'); end;
        7:begin gotoxy(39,25); write('N/A'); end;
        8:begin gotoxy(39,25); write('N/A'); end;
        9:begin gotoxy(39,25); write('N/A'); end;
       10:begin gotoxy(39,25); write('N/A'); end;
       11:begin gotoxy(39,25); write('N/A'); end;
       12:begin gotoxy(39,25); write('N/A'); end;
       13:begin gotoxy(39,25); write('N/A'); end;
       14:begin gotoxy(39,25); write('N/A'); end;
       15:begin gotoxy(39,25); write('N/A'); end;
       16:begin gotoxy(39,25); write('N/A'); end;
       17:begin gotoxy(39,25); write('N/A'); end;
       18:begin gotoxy(39,25); StartMainMenuPhase; end;
       end; {c}
     end;    {13}
  end;  {k}
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar2(c,topics);
  until true=false; {never....hehe}
end;

procedure StartInsideMenuPhase;
var c,b,P,code : Integer;
    k          : Char;
    str        : string;
label stop,damn;
begin
Reset80x25VideoScreen;
HideCursor;
UNCRUNCH (sub4,ScreenAddr[ (1*2) + (1*160) -162],sub4_length);
k:=#22;
c:=1;
write_bar4(c,topics);
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : ; {this is f1 -- 60 61 62....}
    #72 : begin dec(c); end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=c+9;
          end;
    #80 : begin inc(c); end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          end;
    #27,'q' : begin gotoxy(39,25); StartMainMenuPhase; end;
    #13 : Begin
        case c of
        1:begin
               gotoxy(39,25);
               ExtractFileFromDat('INTER1.EXE');
               Reset80x25VideoScreen;
               run('INTER1.EXE');
               UNCRUNCH (sub4,ScreenAddr[ (1*2) + (1*160) -162],sub4_length);
               hidecursor;
               k:=#22;
          end;
        2:begin gotoxy(39,25); write('N/A'); end;
        3:begin gotoxy(39,25); write('N/A'); end;
        4:begin gotoxy(39,25); write('N/A'); end;
        5:begin gotoxy(39,25); write('N/A'); end;
        6:begin gotoxy(39,25); write('N/A'); end;
        7:begin gotoxy(39,25); write('N/A'); end;
        8:begin gotoxy(39,25); write('N/A'); end;
        9:begin gotoxy(39,25); write('N/A'); end;
       10:begin gotoxy(39,25); write('N/A'); end;
       11:begin gotoxy(39,25); write('N/A'); end;
       12:begin gotoxy(39,25); write('N/A'); end;
       13:begin gotoxy(39,25); write('N/A'); end;
       14:begin gotoxy(39,25); write('N/A'); end;
       15:begin gotoxy(39,25); write('N/A'); end;
       16:begin gotoxy(39,25); write('N/A'); end;
       17:begin gotoxy(39,25); write('N/A'); end;
       18:begin gotoxy(39,25); StartMainMenuPhase; end;
       end; {c}
     end;    {13}
  end;  {k}
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar4(c,topics);
  until true=false; {never....hehe}
end;

procedure StartGameMenuPhase;
var c,b,P,code : Integer;
    k          : Char;
    str        : string;
label stop,damn;
begin
Reset80x25VideoScreen;
HideCursor;
UNCRUNCH (sub5,ScreenAddr[ (1*2) + (1*160) -162],sub5_length);
k:=#22;
c:=1;
write_bar5(c,topics);
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : ; {this is f1 -- 60 61 62....}
    #72 : begin dec(c); end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=c+9;
          end;
    #80 : begin inc(c); end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          end;
    #27,'q' : begin gotoxy(39,25); StartMainMenuPhase; end;
    #13 : Begin
        case c of
        1:begin gotoxy(39,25); ExtractFileFromDat('GAME2.EXE');
          Reset80x25VideoScreen;
          run('GAME2.EXE');
          UNCRUNCH (sub5,ScreenAddr[ (1*2) + (1*160) -162],sub5_length);
          hidecursor;
          k:=#22;
          end;
        2:begin gotoxy(39,25); ExtractFileFromDat('GAME1.EXE');
          Reset80x25VideoScreen;
          run('GAME1.EXE');
          UNCRUNCH (sub5,ScreenAddr[ (1*2) + (1*160) -162],sub5_length);
          hidecursor;
          k:=#22;
          end;
        3:begin gotoxy(39,25); write('N/A'); end;
        4:begin gotoxy(39,25); write('N/A'); end;
        5:begin gotoxy(39,25); write('N/A'); end;
        6:begin gotoxy(39,25); write('N/A'); end;
        7:begin gotoxy(39,25); write('N/A'); end;
        8:begin gotoxy(39,25); write('N/A'); end;
        9:begin gotoxy(39,25); write('N/A'); end;
       10:begin gotoxy(39,25); write('N/A'); end;
       11:begin gotoxy(39,25); write('N/A'); end;
       12:begin gotoxy(39,25); write('N/A'); end;
       13:begin gotoxy(39,25); write('N/A'); end;
       14:begin gotoxy(39,25); write('N/A'); end;
       15:begin gotoxy(39,25); write('N/A'); end;
       16:begin gotoxy(39,25); write('N/A'); end;
       17:begin gotoxy(39,25); write('N/A'); end;
       18:begin gotoxy(39,25); StartMainMenuPhase; end;
       end; {c}
     end;    {13}
  end;  {k}
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar5(c,topics);
  until true=false; {never....hehe}
end;

var c,b,P,code : Integer;
    k          : Char;
    str        : string;
label stop,damn;
begin
Reset80x25VideoScreen;
HideCursor;
UNCRUNCH (menutd,ScreenAddr[ (1*2) + (1*160) -162],menutd_length);
k:=#22;
c:=1;
write_bar(c,topics);
repeat
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : ; {this is f1 -- 60 61 62....}
    #72 : begin dec(c); end;
    #77 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=c+9;
          end;
    #80 : begin inc(c); end;
    #81 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=18;
          if c=9 then c:=10;
          if c in [1,2,3,4,5,6,7,8] then c:=9;
          end;
    #73 : begin
          if c in [1,2,3,4,5,6,7,8,9] then c:=1;
          if c=10 then c:=9;
          if c in [10,11,12,13,14,15,16,17,18] then c:=10;
          end;
    #75 : begin
          if c in [10,11,12,13,14,15,16,17,18] then c:=c-9;
          end;
    #27,'q' : begin gotoxy(39,25); StopMainMenuPhase; end;
    #13 : Begin
        case c of
        1:begin gotoxy(39,25); write('N/A'); end;
        2:begin gotoxy(39,25); StartCoverMenuPhase; end;
        3:begin gotoxy(39,25); write('N/A'); end;
        4:begin gotoxy(39,25); StartInsideMenuPhase; end;
        5:begin gotoxy(39,25); StartGameMenuPhase; end;
        6:begin gotoxy(39,25); write('N/A'); end;
        7:begin gotoxy(39,25); write('N/A'); end;
        8:begin gotoxy(39,25); write('N/A'); end;
        9:begin gotoxy(39,25); write('N/A'); end;
       10:begin gotoxy(39,25); write('N/A'); end;
       11:begin gotoxy(39,25); write('N/A'); end;
       12:begin gotoxy(39,25); write('N/A'); end;
       13:begin gotoxy(39,25); write('N/A'); end;
       14:begin gotoxy(39,25); write('N/A'); end;
       15:begin gotoxy(39,25); write('N/A'); end;
       16:begin gotoxy(39,25); write('N/A'); end;
       17:begin gotoxy(39,25); write('N/A'); end;
       18:begin gotoxy(39,25); StopMainMenuPhase; end;
       end; {c}
     end;    {13}
  end;  {k}
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(c,topics);
  until true=false; {never....hehe}
end;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Displays An ANSi On The Screen Allowing Scrolling.      *)
(****************************************************************************)

procedure SetScreenStart(ScanLine : WORD);
var
StartAddress: WORD;
begin
  StartAddress := (ScanLine DIV 16)*80;
  Portw[$3D4] := Hi(StartAddress) SHL 8 + $0C;
  Portw[$3D4] := Lo(StartAddress) SHL 8 + $0D;
  repeat until Port[$3DA] AND 8<>0;
  Portw[$3D4] := (ScanLine MOD 16) SHL 8 + 8;
  repeat until Port[$3DA] AND 8=0;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Phaze 1.                                                                 *)
(****************************************************************************)
procedure PhazePre;
begin
  ExpandHeapMemory;
  KeyClick;
  Reset80x25VideoScreen;
  TextColor(7);
  PrintDetectionPhase;
  DelayScreen(5000);
  FadedownRGBScreen;
  Reset80x25VideoScreen;
  ExtractFileFromDat('DUNEINTR.MOD');
  StartMODBackgroundMusic('DUNEINTR.MOD');
  StartHSCBackgroundMusic('');
  ExtractFileFromDat('SVGA256.BGI');
  ExtractFileFromDat('EG-REV1.GIF');
  DisplayGIF('EG-REV1.GIF');
  DeleteDatFile('Eg-REV1.GIF');
  Reset80x25VideoScreen;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)

begin
     Phazepre;
     StartMainMenuPhase;
end.


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}