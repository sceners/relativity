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

Program The_Relativity_Electronic_Magazine_issue3;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)
{$a+,b-,d+,e-,f-,g+,i+,l+,n-,o-,p-,q-,r-,s+,t-,v+,x+}
{$C MOVEABLE PRELOAD DISCARDABLE}
{$D The Relativity Emag (in Turbo Pascal 7.0)}
{$M 65000,0,655000}
{$S 65000}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

uses  Crt,Dos,REVCOM,
      revconst,revinit,revmenu,revint,revcfg,
      revhelp,{player,}revpoint,revdos;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)
{-plans for the future in the coding-
--------------------------------------
* initializing screen
* ansi coming from up do down like anemia !!
* hsc volum
* adlib detection
* sds
* compression
* f2 as cd menu only with time to end the song, left, whole left, % {round
  circle like a clock with %.. like lsl6
  cd goes ff rew, random, ends in last song begins in 1 ...
* f1 search in memory (bin)
* more command lines
* vga inroduction
* highmem (or get mem)
* 3rd submenu
* random music
* fonts onoff, bright onoff
* closing credits
* config file }

begin
  checkfordat;
  randomize;
{  start_rocking;}
  initconfigpointer;
  checkbreak:=false;
  cc:=1;
{  read_config;}
  Initcommand;
  InitSubScreen;
  RevCommand;
  InitTag;
  InitBright;
  initfonts;
  InitMusic;
  InitTag;
  initavail;
  InitradVol;
  Initcdpos;
{ InitSubFiles;}
{ adlib:=false;
  vga:=false;}
  PhazePre;
  StartMainMenuPhase;
end.
