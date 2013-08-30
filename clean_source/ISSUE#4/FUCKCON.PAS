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

const
    MaxBoom=14;
    Max = $ffff;
    password='SANDRA BULLOCK';
    psMenuFile='PASS.BIN';
    hpMenuFile='REVHELP.BIN';
    bmMenuFile='REVBOOM.BIN';
    DefMenuFile='REVMAINM.BIN';
    SecMenuFile='REVSECM.BIN';
    TrdMenuFile='REVSECM.BIN';
    EndMenuFile='REVEND.BIN';
    EndMenuFile2='GREETS.BIN';
    openinggif='REV4.GIF';
    openinggif2='REV97.GIF';
    midgif='ACID-BIG.GIF';
    passgif='SANDRA.GIF';
    closinggif='REV-DEC1.GIF';
    closinggif2='';
{    closinggif2='SD-REV1.GIF';}
    muscfgfile='MUSMEN.BIN';
    topics=18;
    musdef=6;
    fntdef=13;
    radExt='.RAD';
    hscExt='.HSC';
    musimplemented=22;
    maxhelp=4;

type
     buff = array [1..max] of char;
     bu=^buff;

var
   slutbuf:bu;
   slut:longint; {just a fucking thing not used at all !}

TYPE
    st12    = string[12];
    st22    = string[22];
{    Subb    = array[1..topics] of sub;}
{    Subfil  = array[1..topics] of subfi;}
{    Tag     = set of 1..topics;}
{ 0 is not avail, 1 taged, 2 is taged and not avail}
    Tag     = array [1..topics] of byte;
{ 0 is not avail, 1 taged, 2 is taged and not avail}
    Tagg    = array [1..topics] of tag;
{    Taggg   = array[1..topics] of tagg;}

    ScreenType = array [0..3999] of Byte;
    mus = array[1..musimplemented,1..3] of st12;
    fnt = array[1..20] of st12;

TYPE
   hlp    = array[1..maxhelp] of string;
   na     = set of 1..18;
   pal    = array [0..15,1..3] of byte;
   naa    = array [1..19] of na; {19 is the main}

TYPE
     subfile = array[1..topics] of st12;
     Subfi   = array[1..topics] of subfile;
     {------------------------}
     Subscr  = array[1..topics] of st22;
     sub     = array [1..topics] of subscr;
     {------------------------}
{--------------------------------------------------------------------}
Configure = record
{--------------------------------------------------------------------}
     mFirst         : Subscr;
     fFirst         : subfile;
     ftag           : tag;
{--------------------------------------------------------------------}
     mSec           : sub;
     fsec           : subfi;
     stag           : tagg;
{--------------------------------------------------------------------}
{     mthird         : array [1..topics] of ^sub;
     fthird         : array [1..topics] of ^subfi;
     ttag           : array [1..topics] of tagg;  }
{--------------------------------------------------------------------}
     help_menu      : hlp ;
     scr            : pal ;
     NotAvHelp      : na  ;
{--------------------------------------------------------------------}
     music          : mus ;
     muson          : boolean;
     lastmus,curmus : integer;
     vol            : byte;
{--------------------------------------------------------------------}
     font           : fnt;
     curfnt         : integer;
     lastfnt        : integer;
     winon          : boolean
{--------------------------------------------------------------------}
end;

     cfg = ^configure;

var config:cfg;

const
    help_menu : hlp =
   ('ş Font         ',
    'ş Save As Text ',
    'ş Brightness   ',
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
  rad,hsc        : boolean;
  lmem,wid,dep   : integer;
  ScreenAddr     : ScreenType absolute $B800:$0000;
  free1, free2   : Longint;
  key            : Char;
  i,isConfig     : Integer;
  fname          : string;



implementation
end.

{    M = record
      mthird : ^Subb;                       {18*18 blocks ..}
{      ttag   : ^Taggg;                      {who was taged}
{      Tna    : ^Taggg;                      {who is Not Available}
{      fthird : ^Subfil;                     {18*18*18 files files ..}
{      mSec   : ^sub;                        {18 sub blocks}
{      Stag   : ^Tagg;
{      Sna    : ^Tagg;
{      fsec   : ^subfi;                      {18 blocks of 18 files ..}
{      mFirst : ^Subscr;                     {main block}
{      FTag   : ^Tag;
{      Fna    : ^Tag;
{      fFirst : ^subfile;                    {18 files}
{    end;}

