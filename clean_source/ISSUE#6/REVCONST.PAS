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
unit revconst;

interface
uses cdrom,revmouse;
var
   curcddrv:word;
   startcd,cdroms:word;
   playing,locked,pause:boolean;
   mustype:byte;


const
    saveastag=6;
    changetag = 2;
    MaxBoom=14;
    Max = $ffff;
    topics=18;
    musdef=1;
    fntdef=13;
    radExt='.RAD';
    hscExt='.HSC';
    musimplemented=21;
    maxhelp=8;
    vocfiles=25;

TYPE
    ScreenType = array [0..3999] of Byte;
    st12 = string[12];
    sub = array[1..topics] of st12;
    mus = array[1..musimplemented,1..3] of st12;
    fnt = array[1..20] of st12;

TYPE
   st22   = string[22];
   Subscr =  array[1..18] of st22;
   hlp    = array[1..maxhelp] of string;
   na     = set of 1..18;
   pal    = array [0..15,1..3] of byte;
   naa    = array [1..19] of na; {19 is the main}
   subf   = array [1..topics] of sub;
   subs   = array [1..topics+1] of subscr;
   buffer = array[1..max] of byte;
   buf     = ^buffer;

var slutbuf:buf;
    slut:longint;
    voc_Start,intro,rand,bar,hard,g,help1,boom1:boolean;
    music,article,PassM,TempBin,MainM,SubM,HelpM,BoomM,FontP,VocP:pointer;
    vsize:word;
    menu:byte;
var OK:byte; {vocals ok}

type
    configure = record
     x1,y1,x2,y2:integer;
     init:st12;
     IntroFile:st12;
     password:string;
     disc:st12;
     psMenuFile:st12;
     hpMenuFile:st12;
     bmMenuFile:st12;
     DefMenuFile:st12;
     SecMenuFile:st12;
     TrdMenuFile:st12;
     EndMenuFile:st12;
     EndMenuFile2:st12;
     openinggif:st12;
     openinggif2:st12;
     openinggif3:st12;
     passgif:st12;
     closinggif:st12;
     closinggif2:st12;
     closinggif3:st12;
     muscfgfile:st12;
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
     winon          : boolean;
     vg             : array[1..18] of st12;
     vocs           : array[1..vocfiles] of st12;
{     menudisc       : array[1..18] of boolean;}
     colbacksec1    : byte;
     colformain1    : byte;
     colbacksec2    : byte;
     colformain2    : byte;
{--------------------------------------------------------------------}
end;

     cfg = ^configure;

var config:cfg;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Associates And Stores An Identifier And Type In Memory. *)
(****************************************************************************)
var
  start          : boolean;
  smooth         : byte;
  m              : tmouserec;
  mx,my          : integer; {menu xy}
{--------------------------------------------------------------------}
{command line controllers}
  voc,printer,mouse,cd,vga_,adlib : boolean;
{--------------------------------------------------------------------}
  cdsongpos      : integer;
  brightness     : integer;
  cdactpos       : integer;
  cdpos          : integer;
  brgt           : integer;
  cc             : integer;
  dep            : integer;
  ScreenAddr     : ScreenType absolute $B800:$0000;
  key            : Char;
  fname          : string;



implementation
end.

