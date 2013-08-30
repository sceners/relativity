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
uses cdrom,revmouse,Sound,Load,TS;

var
  Card   : DSMCard;
  Module : PDSM;
  Volume : Integer;

const
      cfg_size                       = 16438;
      intropics                      = 2;
      outropics                      = 2;
      mem_err                        =  7;
      issue_now                      = '7';
      year_now                       = '8';
      cfg_name       ='REV.CFG';
      topics         = 18;
      musimplemented = 38;
      maxhelp        = 8;
      Max            = $ffff;
      vocfiles       = 25;
      k4=4000;
      k8=8*1024;
      k64=$ffff;
      k32=32*1024;
      k17=17*1024;
      used_size =((k4*6)+(2*k32)+(2*k64)+(k8)+(k17));
      game_mem  = 95000;{- arkanoid
{       game_mem = 220000;}
type
    ar19   = array[1..19] of char;
    st12   = string[12];
    ScreenType = array [0..3999] of Byte;
    sub    = array[1..topics] of st12;
    mus    = array[1..musimplemented,1..3] of st12;
    fnt    = array[1..20] of st12;
    st22   = string[22];
    st80   = string[79];
    Subscr =  array[1..18] of st22;
    hlp    = array[1..maxhelp] of string;
    na     = set of 1..18;
    pal    = array [0..15,1..3] of byte;
    naa    = array [1..19] of na; {19 is the main}
    subf   = array [1..topics+1] of sub;
    subs   = array [1..topics+1] of subscr;
    buffer = array[1..max] of byte;
    buf    = ^buffer;
    configure = record
              x1,y1,x2,y2    : integer;
              radmusdef,dsmmusdef : byte;
              fntdef         : byte;
              defsavefile    : st12;
              init           : st12;
              cfg_file       : st12;
              LongFile       : st12;
              Long           : boolean;
              fli            : boolean;
              password       : string;
              disc           : st12;
              psMenuFile     : st12;
              hpMenuFile     : st12;
              bmMenuFile     : st12;
              DefMenuFile    : st12;
              SecMenuFile    : st12;
              TrdMenuFile    : st12;
              EndMenuFile    : st12;
              endmenuflag    : boolean;
              EndMenuFile2   : st12;
              intro          : array[1..intropics] of st12;
              outro          : array[1..outropics] of st12;
              dolby_pic      : st12;
              under_pic      : st12;
              passgif        : st12;
              muscfgfile     : st12;
              help_menu      : hlp ;
              Tag            : naa ;
              NotAvArr       : naa ;
              NotAvHelp      : na;
              subfile        : subf;
              subscreen      : subs;
              music          : mus;
              radlastmus,radcurmus : byte;
              dsmlastmus,dsmcurmus : byte;
              radvol,dsmvol  : byte;
              font           : fnt;
              curfnt         : integer;
              lastfnt        : integer;
              vocs           : array[1..vocfiles] of st12;
              colbacksec1    : byte;
              colformain1    : byte;
              colbacksec2    : byte;
              colformain2    : byte;
              pass_section   : byte;
              game_section   : byte;
    end;
    cfg = ^configure;


const
      fx_ver                         = '#2';
      mdb_ver                        = '#2';
      max_errors                     =    7;
      error                          : array [1..max_errors] of string =
      ('þ Version of FX File Isn''t : Ver.'+fx_ver+' !',
       'þ Version of Emag File Isn''t : Ver.'+mdb_ver+' !',
       'þ FX File is Missing !',
       'þ Emag File is Missing !',
       'þ Not Enough Memory To Run Emag !',
       'þ CONFIG File Corrupted or Missing !',
       'þ Not Enough Memory To Run Emag !');
      files                          = 2;
      sigs : array[1..files] of ar19 =
      ('REV FX FILE VER.'+fx_ver+' ','REV MDB FILE VER.'+mdb_ver);
      under_file                     = 1;
      dolby_file                     = 1;
      fury_file                      = 1;
      dsm_file                       = 1;
      rad_file                       = 1;
      font_file                      = 1;
      voc_file                       = 1;
      walls_file                     = 2;
      disclaimer_file                = 2;
      game_file                      = 1;
      article_file                   = 2;
      gif_file                       = 2;
      hard_file                      = 2;
      config_file                    = 2;
      fli_file                       = 1;
      compile_date                   = '02/02/9'+ year_now;
      DiskSizeNeeded                 = '2';
{      articles                       = 'REV98-08';}
      articles                       = 'CWS98-09';
      fx                             = 'FX98-02';
      saveastag                      = 6;
      changetag                      = 2;
      MaxBoom                        = 14;
      radExt                         = '.RAD';
      hscExt                         = '.HSC';

var
   pali:pointer;
   palette,old_palette          : pal;
   curcddrv                     : word;
   startcd,cdroms               : word;
   playing,locked,pause         : boolean;
   mustype                      : byte;
   names                        : array[1..files] of st12;
   slutbuf                      : buf;
   slut                         : longint;
   voc_Start,intro,rand         : boolean;
   bar,hard,g,help1,boom1       : boolean;
   music,article,PassM,TempBin  : pointer;
   MainM,SubM,HelpM,BoomM,FontP : pointer;
   VocP,cfg_ptr                 : pointer;
   article_main                 : buf;
   vsize                        : word;
   menu                         : byte;
   voc_ok                       : byte; {vocals ok}
   beta                         : boolean;
   score                        : longint;
   size                         : word;
   config                       : cfg;
   radmuson                        : boolean;
   dsmmuson                        : boolean;
   winon                        : boolean;
   start                        : boolean;
   smooth                       : byte;
   m                            : tmouserec;
   mx,my                        : integer; {menu xy}
   {command line controllers}
   voc,printer,mouse,cd,vga_    : boolean;
   mem_being_used               : boolean;
   adlib                        : boolean;
   cdsongpos                    : integer;
   brightness                   : integer;
   cdactpos                     : integer;
   cdpos                        : integer;
   brgt                         : integer;
   cc                           : integer;
   dep                          : integer;
   ScreenAddr                   : ScreenType absolute $B800:$0000;
   key                          : Char;
   fname                        : string;

implementation
end.

