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
unit revconst;

interface

uses  Crt,Dos,RevDat,RevGfx,RevMem,U_Vga,U_ffGif,
      U_Kb,MIDAS,mParser,Errors,mGlobals,mMem,SDevice,MPlayer,DMA,DSM,S3M,
      MODp,MTM,mFile,mConfig,RevAnsi,revsmoot,REVCOM,REVSET,AdvHSC,revrad;

const
    DefMenuFile='DMENU.BIN';
    openinggif='EG-REV1.GIF';
    closinggif='SC-REV1.GIF';
    topics=18;
    musdef=1;
    radExt='.RAD';
    hscExt='.HSC';


    modulePlayers : array[0..(NUMMPLAYERS-1)] of PModulePlayer = (
    @mpS3M, @mpMOD, @mpMTM );

TYPE
    ScreenType = array [0..3999] of Byte;
    st12 = string[12];
    sub = array[1..topics] of st12;
    mus = array[1..19,1..2] of st12;
    fnt = array[1..10] of st12;


TYPE
   st22 = string[22];
   Subscr =  array[1..18] of st22;
   hlp = array[1..9] of string ;

const
    help_menu : hlp =
   ('þ OnLine Music ',
    'þ Volume  0-10 ',
    'þ Save As Text ',
    'þ ------------ ',
    'þ ------------ ',
    'þ ------------ ',
    'þ ------------ ',
    'þ ------------ ',
    'þ Exit Help    ');

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
  cc             : integer;
  volu           : boolean;
  vol            : byte;
  rad,hsc        : boolean;
  music          : mus;
  lastmus,curmus : integer;
  fonts          : fnt;
  subfile        : array [1..topics] of sub;
  subscreen      : array [1..topics+1] of subscr; {19 is the main menu}
  helpmenu       : hlp;
  lmem,wid,dep   : integer;
  Info1          : Gif_InfoRec;
  BgiPath,Fname1 : PathStr;
  DummyGif       : BYTE;
  ScreenAddr     : ScreenType absolute $B800:$0000;
  free1, free2   : Longint;
  error, plMusic : Integer;
  module         : PmpModule;
  SD             : PSoundDevice;
  MP             : PModulePlayer;
  key            : Char;
  meter          : WORD;
  info           : PmpInformation;
  i,isConfig     : Integer;
  stopPlay       : Boolean;
  str            : array[0..256] of Char;
  fname          : string;
  chMuted        : array[0..31] of Integer;
  chNum          : Integer;

Procedure GetSubTopics(var sub:subscr; name:string);

implementation

{mainm,relat,inter,cover,insid,gamer
jobsz,artic,Scene,games}

Procedure GetSubTopics(var sub:subscr; name:string);
var f : text;
    b : array [1..437] of byte;
    numread : integer;
    str5 : string[5];
    str24: string[24];
    k,i,j:integer;
label after;
begin
     extractfilefromdat('REVTOPIC');
     assign(f,'REVTOPIC');
     reset(f);
     while not eof(f)  do
     begin
          readln(f,str5);
          if name=str5 then
          begin
               for j:= 1 to topics do
               begin
                    readln(f,str24);
                    delete(str24,1,1);
                    delete(str24,23,1);
                    sub[j]:=str24;
               end;
               goto after;
          end;
     end;
after:
close(f);
deletedatfile('REVTOPIC');
end;
end.

const
    main_menu : subscr =
   ('þ Introduction        ',
    'þ Cover Story         ',
    'þ Articles            ',
    'þ Inside Scoop        ',
    'þ Game Reviews        ',
    'þ Fascinating Stories ',
    'þ Scene News Flash    ',
    'þ Special Highlights  ',
    'þ Scene Group NFOs    ',
    'þ Top 10''s            ',
    'þ Worms ScriptAble    ',
    'þ Secret Articles     ',
    'þ Group Requests      ',
    'þ Personal Requests   ',
    'þ Overall Survey      ',
    'þ Job Openings        ',
    'þ Relativity          ',
    'þ Conclusion          ');

    relativity: subscr =
   ('þ Contscting Us       ',
    'þ Personal Credits    ',
    'þ Relativity.Nfo      ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

    intro: subscr =
   ('þ Introduction....    ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

    cover_story : subscr =
   ('þ PSG Log Part 1      ',
    'þ PSG Log Part 2      ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

   inside_scoop : subscr =
   ('þ RaZoR 1911 Log      ',
    'þ Hybrid''s log        ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

   game_reviews : subscr =
   ('þ Alien Rampage       ',
    'þ Street Racer        ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

   job : subscr =
   ('þ Writers..           ',
    'þ Bot Masters....     ',
    'þ Ansi makers !!      ',
    'þ Chann Opz ...       ',
    'þ Trackerz ...        ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

    article: subscr =
   ('þ Our Scene,......    ',
    'þ #Warez-list!!...    ',
    'þ Sot Series .....    ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

    Scene_flash: subscr =
   ('þ WARNING !!!!!!      ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');

      game: subscr =
   ('þ Help Me Please !!!  ',
    'þ Play Me Please !!!  ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ ------------------- ',
    'þ Exit To Main        ');
