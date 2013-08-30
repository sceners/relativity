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

{uses
      REVDAT;}

const
    Max = $ffff;
    password='SANDRA BULLOCK';
    mainchar='Û';
    psMenuFile='PASS.BIN';
    hpMenuFile='REVHELP.BIN';
    DefMenuFile='REVMAINM.BIN';
    SecMenuFile='REVSECM.BIN';
    EndMenuFile='REVEND.BIN';
    EndMenuFile2='GREETS.BIN';
    openinggif='SB-REV01.GIF';
    openinggif2='DEC-REV1.GIF';
    midgif='ACID-BIG.GIF';
    passgif='SANDRA.GIF';
    closinggif='REV-DEC2.GIF';
    closinggif2='SD-REV1.GIF';
    muscfgfile='MUSMEN.BIN';
    topics=18;
    musdef=6;
    fntdef=13;
    radExt='.RAD';
    hscExt='.HSC';
    musimplemented=9;



TYPE
    ScreenType = array [0..3999] of Byte;
    st12 = string[12];
    sub = array[1..topics] of st12;
    mus = array[1..musimplemented,1..3] of st12;
    fnt = array[1..20] of st12;

const maxhelp=7;

TYPE
   st22   = string[22];
   Subscr =  array[1..18] of st22;
   hlp    = array[1..maxhelp] of string;
   na     = set of 1..18;
   pal    = array [0..15,1..3] of byte;
   naa    = array [1..19] of na; {19 is the main}
   subf   = array [1..topics] of sub;
   subs   = array [1..topics+1] of subscr;
{   infos  = array[1..max] of st22;}

type configure = record
     help_menu      : hlp ;
     scr            : pal ;
     Tag            : naa ;
     NotAvArr       : naa ;
     NotAvHelp      : na;
     subfile        : subf;
     subscreen      : subs;
{--------------------------------------------------------------------}
     music          : mus;
     muson          : boolean;
     lastmus,curmus : integer;
     vol            : byte;
{--------------------------------------------------------------------}
     font           : fnt;
     curfnt         : integer;
     lastfnt        : integer;
{     cdactpos       : integer;}
{--------------------------------------------------------------------}
     end;
     cfg = ^configure;

var config:cfg;

const
    help_menu : hlp =
   ('ş OnLine Music ',
    'ş Volume  0-12 ',
    'ş Save As Text ',
    'ş Font         ',
    'ş Brightness   ',
    'ş CD Control   ',
    'ş Exit Help    ');

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)

var
  mx,my          : integer; {menu xy}
{--------------------------------------------------------------------}
{command line controllers}
  cd,vga,adlib   : boolean;
{--------------------------------------------------------------------}
  cdsongpos      : integer;
  pause          : boolean;
  brightness     : integer;
  cdactpos       : integer;
  cdpos          : integer;
  brgt           : integer;
  cc             : integer;
  volu           : boolean;
  rad,hsc        : boolean;
{  helpmenu       : hlp;}
  lmem,wid,dep   : integer;
  ScreenAddr     : ScreenType absolute $B800:$0000;
  free1, free2   : Longint;
  key            : Char;
  i,isConfig     : Integer;
  fname          : string;



implementation
end.

