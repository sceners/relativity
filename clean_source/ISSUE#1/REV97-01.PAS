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


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - The Heading Specifies The Program Name And Parameters.  *)
(****************************************************************************)

Program The_Relativity_Electronic_Magazine;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)

{$A+}{$B+}{$D+}{$F+}{$G+}{$I+}{$K+}{$L+}{$N+}{$O-}{$P+}{$Q-}{$R-}{$S+}{$T+}
{$V-}{$W+}{$X+}{$Y+}
{$C MOVEABLE PRELOAD DISCARDABLE}
{$D The Relativity Emag (in Turbo Pascal 7.0)}
{$M 65000,0,655360}
{$S 32768}

{$IFNDEF __BPREAL__}
{$DEFINE NOEMS}
{$ENDIF}

{$DEFINE MSDOS}
{$DEFINE VER70}

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

uses  Crt,Dos,RevDat,RevGfx,RevMem,U_Vga,U_ffGif,
      U_Kb,RevAnsi,revsmoot,REVCOM,REVSET,AdvHSC,revhelp,
      revconst,revhsc,revrad,revmus,revinit,revmid,worms;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Extended FileExists Function From The RevDat.pas.       *)
(****************************************************************************)

function FileExists(filename: string) : Boolean;
var
 f: file;
begin
  {$I-}
  Assign(f, FileName);
  FileMode := 0;
  Reset(f);
  Close(f);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Controls The Initialization Phases. (EXE And WAD Files) *)
(****************************************************************************)

procedure InitializeDetectionPhase;
begin
  GetMainMemory;
  CheckMainMemory;
  FlushDiskCaches;
  CheckXMSEMSMemory;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Starting And Ending Initialization Phases (Detection).  *)
(****************************************************************************)

procedure PrintDetectionPhase;
begin
  HideCursor;
  Writeln;
  Writeln('CPU IDENTIFICATION ROUTINES HAVE BEEN EXCLUDED IN THIS ISSUE.');
  Writeln('--------------------------------------------------------------------------------');
  Writeln('Type Rev-01.EXE /? for Help');
  Writeln;
  InitializeDetectionPhase;
  Writeln;
  Writeln('Last Updated: December 10th, 1996');
  Writeln;
  Writeln('--------------------------------------------------------------------------------');
end;

procedure PrintEndingPhase;
var k:char;
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
  Writeln('             For Future Issues Goto Http://www.geocities.com/soho/6477 ');
  Writeln;
  Writeln('                         press any key to continue');
  k:=readkey;
end;


procedure DisplayGIF(GIFname:string);
begin
  BgiPath := '';
  Fname1 := GIFname;
  if Gif_Info(Fname1,Info1)<>Gif_Ok then begin
    Writeln('Error: ',Gif_ErrStr); Halt; end;
  with Info1 do
  DummyGif := Gif_Display(Fname1,BgiPath,-1);
  ClearKeyBuf; WaitKey(0);
  FadedownRGBScreen;
  SetVideo(U_Lm);
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Stops The Menu Phase And Begins The Ending Phase. (FIN) *)
(****************************************************************************)
procedure StopMainMenuPhase;
begin
  if curmus<>musdef then
  begin
       StopMusic(music[curmus,1],music[curmus,2]);
       PlayMusic(music[musdef,1],music[musdef,2]);
  end;
  Reset80x25VideoScreen;
  ExtractFileFromDat('SVGA256.BGI');
  ExtractFileFromDat(closinggif);
  DisplayGIF(closinggif);
  DeleteDatFile(closinggif);
  DeleteDatFile('SVGA256.BGI');
  Reset80x25VideoScreen;
  TextColor(7);
  TextBackground(black);
  PrintEndingPhase;
  Reset80x25VideoScreen;
  StopMusic(music[musdef,1],music[musdef,2]);
  Halt;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Procedures Related To Ansi & The Menu Highlight Bars.   *)
(****************************************************************************)

procedure write_bar(e,b,t:integer);
var
i,a,x,y:integer;
str:st22;
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
    str:=subscreen[e][a];
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
    str:=subscreen[e][a];
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
     x:=48;
     end;
  end;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Starts The Main Menu Phase And Controls All Sub Menus.  *)
(****************************************************************************)

Procedure ShowArticle(str,str2:st12);
var dep:longint;
begin
     ExtractFileFromDat(str);
     FadedownRGBScreen;
     Reset80x25VideoScreen;
     ReadAnsiBinAndLoadToMem(str,dep);
     DeleteDatFile(str);
     SmoothScroll(dep,str);
     DisplayaNsi(str2);
     hidecursor;
end;

Function EmptySub(sub:subscr):boolean;
var i:integer;
begin
     EmptySub:=True;
     for i:= 1 to topics do
     begin
          if sub[i]<>'' then
           EmptySub:=false;
     end;
end;

procedure StartMainMenuPhase;

procedure StartCurrentMenu(e:integer);
var c,b,P,code : Integer;
    k          : Char;
    str        : string;
label stop,damn;
begin
FadedownRGBScreen;
Reset80x25VideoScreen;
HideCursor;
Displayansi(defmenufile);
k:=#22;
c:=1;
write_bar(e,c,topics);
{k:=readkey;}
k:=#22;
repeat
  if (k<>#13) and (k<>#27)then
     k:=readkey;
  if k=#0 then
     k:=readkey;
  case k of
    #59 : begin
               help(false,subfile[e][c]);
               hidecursor;
               Displayansi(defmenufile);
               write_bar(e,c,topics);
          end;
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
    #27,'q' : begin StartMainMenuPhase; end;
    #13 : Begin
        if c in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17] then
        begin
          if subfile[e][c]<>'' then
               ShowArticle(subfile[e][c],DEFMENUFILE)
          else
              nope;
              k:=#22;
        end;
        if c=18 then
           StartMainMenuPhase;
        end;
  end;
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(e,c,topics);
  k:=readkey;
  until true=false; {never....hehe}
end;

var c,b,P,code : Integer;
    k          : Char;
    str        : string;
label stop,damn;
begin
c:=cc;
FadedownRGBScreen;
Reset80x25VideoScreen;
HideCursor;
Displayansi(DEFMENUFILE);
k:=#22;
write_bar(topics+1,c,topics);
k:=readkey;
repeat
  if (k<>#13) and (k<>#27) then
  k:=readkey;
  if k=#0 then
  k:=readkey;
  case k of
    #59 : begin
               cc:=c;
               help(false,subfile[1][c]);
               hidecursor;
               Displayansi(defmenufile);
               write_bar(topics+1,c,topics);
          end;
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
    #27,'q' : begin FadedownRGBScreen; StopMainMenuPhase; end;
    #13 : Begin
          if c= 1 then
          begin
               cc:=c;
               ShowArticle(subfile[1][1],DEFMENUFILE);
          end;
          if c= 11 then
          begin
          cc:=c;
          FadedownRGBScreen;
          Reset80x25VideoScreen;
          if not fileexists('WORMS.LVL') THEN
          extractfilefromdat('WORMS.LVL');
          startgame;
          FadedownRGBScreen;
          Reset80x25VideoScreen;
          HideCursor;
          Displayansi(DEFMENUFILE);
          write_bar(topics+1,c,topics);
          K:=#22;
          end;
          if c in [{1,}2,3,4,5,6,7,8,9,10,{11,}12,13,14,15,16,17] then
          begin
          if not emptysub(subscreen[c]) then
          begin
             cc:=c;
             StartCurrentMenu(c);
             end
          else
              nope;
          end;
          if c= 18 then
             StopMainMenuPhase;
          end;
  end;
  if c = topics+1 then
     c := 1;
  if c = 0 then
     c := topics;
  write_bar(topics+1,c,topics);
  k:=readkey;
  until true=false; {never....hehe}
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Preperation Phases For The Introduction & Detection.    *)
(****************************************************************************)

procedure PhazePre;
begin
  Reset80x25VideoScreen;
  TextColor(7);
  PrintDetectionPhase;
  DelayScreen(1000);
  Reset80x25VideoScreen;
  hidecursor;
  PlayMusic(music[musdef,1],music[musdef,2]);
{ ExtractFileFromDat('DUNEINTR.MOD');
  StartBackgroundMusic('DUNEINTR.MOD');}
  ExtractFileFromDat('SVGA256.BGI');
  ExtractFileFromDat(openinggif);
  DisplayGIF(openinggif);
  DeleteDatFile(openinggif);
  Reset80x25VideoScreen;
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Checks For Configuration File, Dosen't Work In TP IDE!! *)
(****************************************************************************)

procedure CheckCFG;
var k:char;
begin
  if not FileExists(ConfigFile) then
  begin
    SetMidasCfg;
    Writeln;
    Writeln('Press any key to continue...');
    k:=readkey;
  end;
end;

Procedure InitRadVol;
begin
     vol:=62;
     radvolume(vol);
     volu:=true;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)

begin
CHECKBREAK:=FALSE;
  cc:=1;
{  initkey(10);}
  InitradVol;
  InitMusic;
  InitSubFiles;
  InitSubScreen;
  RevCommand;
{ CheckCFG;}
  PhazePre;
  StartMainMenuPhase;
{  initkey(10);}
end.