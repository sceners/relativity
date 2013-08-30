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

Program The_Relativity_Electronic_Magazine_issue_7;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
{$M 64000,000,640000}
{$S 65535}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)
{-plans for the future in the coding-
--------------------------------------
* compression
* f1 search in memory (bin)

cd player is bugged ... no disk recognize
and no drive recog

/cd    for cd player options..
/music for music options rad or mod..

- REMEMBER RAD MAX FILESIZE POINTER IS 32K AND SO IS VOC !
- dat file param and names automatically in beta mode !! reminder !
- hide cursor after 03mode doesnt work .. you can still see the _ blinking in the
  upper left corner :(..delayscreen waitretrace?}

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

uses  Crt,Dos,revcom,revcol,
      revconst,revinit,revmenu,revint,revcfgr,revvoc,
      revhelp,revpoint,detectso,revwin,revdet,
      revfnt,revrad,revtech,revgfx,revansi,revdisc,revgif,
      revdat,revsmth,revhard,revmouse,revgame,revfli{,arkanoid};

var err,i:byte;

Begin {Begins The Best Emag In The Scene}
{---------------------------------------------------------------}
  beta:=true; {for assigning auto names to the dat files.. beta mode}
  if (paramcount = 0) and (not beta) then
  begin
       writeln;
       Writeln('Relativity Emag Viewer v2.0');
       writeln('Syntax : RevXX-XX.EXE FxXX-XX.MDB EmagXX-XX.MDB /Commandline.');
       halt;
  end;

{  beta:=true; {for assigning auto names to the dat files.. beta mode}
  Assign_names; {assigning names if betamode, or taking them from paramstr}
  if not beta then
     checkbreak:=false;
  vercheck; {secret windows option :) }
  initconfigpointer;
  initbright;
  Err:=ReadGlobalIndex(1);
  if Err<>0 then kill_emag(err);
  Err:=ReadGlobalIndex(2);
  if Err<>0 then kill_emag(err);
  cc:=1; {menu option}
  voc_ok:=1; {vocals indicator}
{-------------------------------------------------------------------------}
  Det_sb;
  Det_adlib;
  Det_mouse;
{-------------------------------------------------------------------------}
        {TRUE OR FALSE INSIDE CHECKS}
  g:=true;      {change to true b4 release !}
  cd:=true;     {change to true b4 release !}
  hard:=true;   {change to true b4 release !}
  adlib:=true;  {change to true b4 release !}
  vga_:=true;  {change to true b4 release !}
  bar:=false;   {change to FALSE b4 release !}
  intro:=true; {change to true b4 release !}
  smooth:=3;    {change to 1 b4 release !}
  start:=true;  {change to true b4 release !}
  if adlib then
  begin
       rand:=true;
       radmuson:=true;
       dsmmuson:=true;
  end
  else
  begin
       rand:=false;
       dsmmuson:=false;
  end;
{-------------------------------------------------------------------------}
  if not initpointers then kill_emag(5); {taking memory, after that
                                          if not enough left for game.. disabling game}
  for i:= 1 to paramcount+1 do
  begin
       if (paramstr(i)<>'/M') and (paramstr(i)<>'/m') then
          if memavail<game_mem-(k64*1) then {*2 if fury}
             if not beta then
                kill_emag(7)          {killing ..no /m}
             else
                 add_not_avail(19,11) {diabling /m appeared}
       else
          if memavail<game_mem-(k64*1) then {k64*2 ..deinitptrart..arkanoid}
          begin
             add_not_avail(19,11); {diabling /m appeared}
             writeln('Ignored Memory Restriction, Disabling Game !!');
             Writeln('Press Any Key ...');
             waitforkey;
          end;
  end;

  randomize;
  InitTag;
  if not read_config then kill_emag(6);
  InitUpper; {makes all filenames to uppercase}
  DeleteDatFilesInDir(1);
  DeleteDatFilesInDir(2);
  initprinter;
  RevCommand;
  fontloadpointer(config^.font[config^.curfnt],fontp); {load fonts}
  initavail;
  InitradVol;
  Initcd;

if (not mouse) then {diables game if not enough mem or no mouse}
   add_not_avail(19,11);
cursor_off;
dospin;
DisplayGIF(config^.under_pic,under_file,0,0); {boy and girl}
Reset80x25VideoScreen;

disclaimercheck;
smooth:=1;
hidecursor;
if hard then
   HardWareInit;

if intro then
begin
     if config^.fli then
     if fileindat('REVFLI.FLI',FLI_FILE) THEN
     begin
          ExtractFileFromDat('REVFLI.FLI',fli_file) ;
          AAPlay('REVFLI.FLI',true);
          deletedatfile('REVFLI.FLI');
          hidecursor;
     end;
     PhazePre;
     textbackground(black);
end;

  extractpointerfromdat(config^.BMMENUFILE,article_file,boomm,size);
  extractpointerfromdat(config^.hpmenufile,article_file,helpm,size);
  extractpointerfromdat(config^.psmenufile,article_file,passM,size);
  extractpointerfromdat(config^.Secmenufile,article_file,subm,size);
  Extractpointerfromdat(config^.DEFMENUFILE,article_file,mainm,size);
  initmouse;

  StartMainMenuPhase;

end.


