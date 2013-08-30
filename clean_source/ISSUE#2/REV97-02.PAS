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

Program The_Relativity_Electronic_Magazine_issue2;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)

{$A+}{$B+}{$D+}{$F+}{$G+}{$I+}{$K+}{$L+}{$N+}{$O-}{$P+}{$Q-}{$R-}{$S+}{$T+}
{$V-}{$W+}{$X+}{$Y+}
{$C MOVEABLE PRELOAD DISCARDABLE}
{$D The Relativity Emag (in Turbo Pascal 7.0)}
{$M 65000,0,655360}
{$S 602768}

{$IFNDEF __BPREAL__}
{$DEFINE NOEMS}
{$ENDIF}

{$DEFINE MSDOS}
{$DEFINE VER70}

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Each Identifier Names A Unit Used By The Program.       *)
(****************************************************************************)

uses  Crt,Dos,RevDat,RevGfx,RevMem,RevAnsi,revsmth,REVCOM,
      REVSET,AdvHSC,revhelp,revconst,revhsc,revrad,revmus,
      revinit,revmid,revspec,gifutil9,revnfo,revgif,revmenu,revint;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Statements To Be Executed When The Program Runs.        *)
(****************************************************************************)

begin
  checkbreak:=false;
  cc:=1;
  InitSubScreen;
  RevCommand;
  InitTag;
  initavail;
  InitradVol;
  InitMusic;
  {InitSubFiles;}
 {CheckCFG;}
  PhazePre;
  StartMainMenuPhase;
end.