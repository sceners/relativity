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

Program The_Relativity_Electronic_Magazine_issue4;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
{$M 65320,000,653600}
{$S 65535}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)
{-plans for the future in the coding-
--------------------------------------
* initializing screen
* compression
* f1 search in memory (bin)
* more command lines
* vga inroduction
* fonts onoff, bright onoff
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

{ i used the rev-non pointer dat.. .. i wonder.. pointers or not ???}



uses  Crt,Dos,REVCOM,
      revconst,revinit,revmenu,revint,revcfgr,
      revhelp,revpoint,revdos,detectso,revwin,
      revfnt,revrad,revtech,revgfx,revansi,
      revdat,revsmth;

Begin {Begin The Best Emag In The Scene}
{---------------------------}
  checkbreak:=false;
  vercheck;
  checkfordat;
  cc:=1; {menu option}
{---------------------------}
  if DetSoundBlaster then
     adlib:=true
  else
      adlib:=false;
  if not adlib then
     mustype:=2
  else
      mustype:=1;
  if adlib then
     InstallRADTimer;
{---------------------------}
  randomize;
  initconfigpointer;
  read_config;
  Initcommand;
  fontload(config^.font[config^.curfnt]);
  RevCommand;
  InitTag;
{ InitBright;
  initfonts;
  InitMusic;
  InitTag;}
  initavail;
  InitradVol;
  Initcd;
{-----------------}
{adlib:=false;}
{vga:=false;
{  cd:=false;}
{-----------------}
  PhazePre;
  hidecursor;
  chbrght;
  ExtractFileFromDat('MUADDIB.BIN');
  smoothscroll('MUADDIB.BIN',0,0);
  if keypressed then
  readkey;
  FadedownRGBScreen;
  Reset80x25VideoScreen;
  HideCursor;
  ExtractFileFromDat(config^.DEFMENUFILE);
  Displayansi(config^.DEFMENUFILE);
  StartMainMenuPhase;
end.


