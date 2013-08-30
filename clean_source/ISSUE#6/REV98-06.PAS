(****************************************************************************)
(*                                                                          *)
(* REV97.PAS - The Relativity Emag (coded in Borland Pascal 7.0)            *)
(*                                                                          *)
(* "The Relativity Emag" was originally written by En|{rypt, |MuadDib|.     *)
(* This source may not be copied, distributed or modified in any shape      *)
(* or form. Some of the code has been derived from various sources and      *)
(* units to help us produce a better quality electronic magazine to let     *)
(* the scene know that we are THE BOSS.                                     *)
(*                                                                          *)
(* Program Notes : This program presents "The Relativity Emag"              *)
(*                                                                          *)
(* ASM/BP70 Coder     : xxxxx xxxxxxxxx (MuadDib) - xxxxxx@xxxxxxxxxx.xxx   *)
(* ------------------------------------------------------------------------ *)
(* Older Coder : xxxxx xxxxxxxxx (En|{rypt)  - xxxxxx@xxxxxxxxxx.xxx :)))   *)
(*                                                                          *)
(****************************************************************************)
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - The Heading Specifies The Program Name And Parameters.  *)
(****************************************************************************)

Program The_Relativity_Electronic_Magazine_issue_6;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
{$M 60320,000,603600}
{$S 65535}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)
{-plans for the future in the coding-
--------------------------------------
* compression
* f1 search in memory (bin)
* more command lines
* vga inroduction

cd player is bugged ... no disk recognize
and no drive recog

/cd    for cd player options..
/music for music options rad or mod..

REMOVE ALL HIDECURSOR !!!!!!!!!!!!!!! NO NEED !!!!!11
REMEMBER DISABLED F1 AND F2 IN SMOOTH.. FIX IT
REMEMBER RAD MAX FILESIZE POINTER IS 32K AND SO IS VOC !!!!!!!!
REMOVED 3RD ENDING PIC
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

uses  Crt,Dos,revcom,revcol,
      revconst,revinit,revmenu,revint,revcfgr,revvoc,
      revhelp,revpoint,revdos,detectso,revwin,
      revfnt,revrad,revtech,revgfx,revansi,revdisc,revgif,
      revdat,revsmth,revhard,revmouse,revgame,arkanoid,revfli;

var beta:boolean;
    score:longint;
    size:word;


Begin {Begins The Best Emag In The Scene}
{---------------------------}
  if memavail<350000 then
  begin
       writeln(memavail,' Free Mem,');
       writeln('Relativity Emag Needs More : ',350000-memavail,', free mem !');

       if (paramstr(1)<>'/M') and (paramstr(1)<>'/m') then
       halt
       else
       begin
            writeln('Ignored Memory Warning.. the emag could get suck.. so dont balme me !!');
            delay(1000);
       end;
  end;
  beta:=false;
  if not beta then
  checkbreak:=false;
  vercheck;
  checkfordat;
  ReadGlobalIndex;
  cc:=1; {menu option}
  ok:=1;{vocals indicator}
{-------------------------------------}
  if InstallMouse then mouse:=true
     else mouse:=false;
{-------------------------------------}
  if DetSoundBlaster then
     begin
          adlib:=true;
{          voc:=true;}
     end
     else
     begin
          adlib:=false;
          voc:=false;
          voc_start:=false;
     end;
  if not adlib then mustype:=2
     else mustype:=1;
  if adlib then InstallRADTimer;
{-------------------------------------}
  Initcommand;
  g:=true;
  hard:=true;
  adlib:=true;
{  voc:=true;
  voc_Start:=true;}
  vga_:=true;
  bar:=false;
  intro:=true;
  smooth:=1;
  beta:=false;
  start:=true;
  cd:=true;

  if adlib then rand:=true
  else rand:=false;
{-------------------------------------}
  randomize;
  initconfigpointer;
  InitTag;
  read_config;
  DeleteDatFilesInDir;
  initprinter;
  RevCommand;
  initpointers;
  fontloadpointer(config^.font[config^.curfnt],fontp);
  initavail;
  InitradVol;
  Initcd;

if not mouse then
   config^.notavarr[19]:=config^.notavarr[19]+[11];

if vga_ then
begin
     ExtractFileFromDat(config^.closinggif3);
     DisplayGIF(config^.closinggif3);
     DeleteDatFile(config^.closinggif3);
     Reset80x25VideoScreen;
     textbackground(black);
     TextColor(7);
end;
hidecursor;
disclaimercheck;
smooth:=1;

if hard then
   HardWareInit;

if not beta then
begin
  if intro then
  begin
       ExtractFileFromDat('REVFLI.FLI');
       AAPlay('REVFLI.FLI',true);
       deletedatfile('REVFLI.FLI');
  end;
  hidecursor;
  PhazePre;
  hidecursor;
  textbackground(black);
  chbrght;
end;

  extractpointerfromdat(config^.BMMENUFILE,boomm,size);
  extractpointerfromdat(config^.hpmenufile,helpm,size);
  extractpointerfromdat(config^.psmenufile,passM,size);
  extractpointerfromdat(config^.Secmenufile,subm,size);
  Extractpointerfromdat(config^.DEFMENUFILE,mainm,size);
  initmouse;
{ changecol(lightgreen,lightblue);}
  StartMainMenuPhase;

end.


