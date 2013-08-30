{$G+}
unit SDS;
{
    Sound Deluxe System 5
    a Maple Leaf production, 1996-1997
    (Maple Leaf is a.k.a. Gruian Radu Bogdan)
    ---------------------------------------------------------------------
    SDS kernel interface
    ---------------------------------------------------------------------
    This program is part of the Sound Deluxe System 5, and it cannot
    be modified or sold without the written permission of the author. The
    author does not assume any responsability for the incidental loss or
    hardware/software damages produced while using this program or any other
    part of the Sound Deluxe System. The author also does not assume any
    responsability for the damages produced by using modified parts of this
    package.  Blah, blah...
    ---------------------------------------------------------------------
}

interface

uses alloc, ems, fcache, files, string_s, sds_k, math;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ            Constants and 'keywords' used everywhere in SDS             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Const

{±±± Version definitions ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

       TrackerVer         : word    = $0503;        { 5.03 }
       HeaderSign         : Longint = $35534453;    { 'SDS5' }
       SDS_Version                  = '5.03б';      { like TrackerVer, but string }
       TrackerName        : string  = 'Sound Deluxe System '+SDS_Version;  { <=32 bytes! }

{±±± Soundcards ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

       SB                 = 1;  { Plain Sound Blaster (DSP 1.0)              }
       SB2                = 1;  { Sound Blaster 2.0 (DSP 2.x)                }
       SBPro              = 2;  { Sound Blaster Pro (DSP 3.x)                }
       SB16ASP            = 3;  { Sound Blaster 16 ASP (DSP 4.0)             }
       SBAWE32            = 3;  { Sound Blaster AWE 32 (DSP 5.0)             }
       GUS                = 4;  { Gravis UltraSound                          }
       PAS                = 5;  { Pro Audio Spectrum                         }
       PASPlus            = 5;  { Pro Audio Spectrum Plus                    }
       PAS16              = 5;  { Pro Audio Spectrum 16                      }
       WSS                = 6;  { WSS/AudioTrix Pro/GUS MAX CODEC            }
       Aria               = 7;  { Aria soundcard (Sierra SC180xxx DSP chip)  }
       Silence            = 8;  { No Sound (UltraSilence(tm)Pro++/16!)       }


{±±± Memory manager vars ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

       GUSbase            : word    = $200;         { MUST be set when loading into GUS }
       UseGUS             : boolean = False;        { MUST be set when loading into GUS }
       UseEMS             : boolean = False;        { True if samples must be loaded into EMS }
       gus_DRAM           : longint = 0;


{±±± General purpose vars ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

       Amplif_NoSound               = 0;            { Amplification percents.    }
       Amplif_Normal                = 100;          { Of course, any value might }
       Amplif_NormalAndHalf         = 150;          { be used, not only these    }
       Amplif_Double                = 200;          { predefined ones ...        }
       Amplif_DoubleAndHalf         = 250;
       Amplif_Triple                = 300;
       Amplif_Quadruple             = 400;

       On                           = True;         { ON/OFF flags }
       Off                          = False;

       PAL                          = 1;            { PAL/NTSC mode consts }
       NTSC                         = 0;

{±±± Load/Save vars ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

       LoadError          : Byte    = 0;            { Load-error codes. See docs. }
       SaveError          : Byte    = 0;            { Save-error codes. See docs. }

       UserRoutine        : Pointer = nil;          { Called by SDS_Load_... while loading. If it is NIL, no call is performed}
       Action             : Byte    = 0;            { Actions. See docs. }
       ActionPARA         : Byte    = 0;            { Action idx. See docs. }

       TextPtr            : Pointer = nil;          { pointer to a data area where a text is stored }
       TextSize           : Word    = 0;            { nr. of bytes in that text area }

       EOC                : byte    = $EC;
       MINF                         = $464E494D;    { 'MINF' }
       SDES                         = $53454453;    { 'SDES' }
       SNAM                         = $4D414E53;    { 'SNAM' }
       PATT                         = $54544150;    { 'PATT' }
       MTXT                         = $54584554;    { 'TEXT' }
       SDAT                         = $54414453;    { 'SDAT' }
       STYP                         = $50595453;    { 'STYP' }


{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ                          New SDS data types                            ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Type

{±±± SDM format definitions ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

       SDMInt_HeadType    = record     {internal format}
                              Patterns, Entries, Samples : word;
                              Channels, InitGVolume, InitSpeed, InitBPM : byte;
                              VRI : array [0..31] of byte;
                              MasterVolume : byte;
                              PattAddrTabPtr : pointer;
                              ChannelStatus :  longint;
                            end;
       SDMInt_InstType    = record
                              Volume : byte;
                              C2Speed : word;
                              Address : longint;
                              Size, LoopStart, LoopEnd : word;
                            end;


{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ                             SDS variables                              ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Var

     ModuleName   : String;                         { Module's name }
     Author       : String;                         { Author, if available }

     Entries      : byte;                           { Orders }
     Patterns     : byte;                           { Patterns }
     Samples      : byte;                           { Samples }
     Channels     : byte;                           { Channels }

     Order        : array [byte] of byte;           { Order list }
     Sample       : array [byte] of pointer;        { Samples addresses }
     SamSize      : array [byte] of word;           { Sizes }
     SName        : array [byte] of string[35];     { Names }
     SamType      : array [byte] of byte;           { Type: bit 0 = 8bit(0), 16bit(1)
                                                                6 = delta packed(1), normal(0)
                                                                7 = unsigned(1),signed(0) }
     Pattern      : array [byte] of pointer;        { Patterns addresses }
     PattSize     : array [byte] of word;           { Sizes }

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ                  SDS interface functions declaration                   ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

{±±± Memory manager functions ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

function SDS_alloc (size:longint) : pointer;        { Alloc a block in GUS DRAM, EMS or conv. }
function SDS_free (var p:pointer) : boolean;        { Deallocates the specified block }
function SDS_mavail : longint;                      { If UseGUS=True : returns free DRAM available }
                                                    {    UseEMS=True : returns EMS amount available }
                                                    {    Otherwise   : returns conventional memory available }

{±±± Load/Save functions ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

procedure SDS_UnLoad(var module:pointer);
function  SDS_Load(name:string; LoadSamples:boolean):Pointer;

function  SDS_Read_669(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_FAR(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_MOD(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_MTM(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_S3M(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_PTM(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_STM(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_ULT(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Read_SDM(var f:file; LoadSamples:boolean):Pointer;
function  SDS_Load_669(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_FAR(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_MOD(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_MTM(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_S3M(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_PTM(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_STM(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_ULT(name:string; LoadSamples:boolean):Pointer;
function  SDS_Load_SDM(name:string; LoadSamples:boolean):Pointer;

function  SDS_Save_SDM(module:pointer; name:string):boolean;

{±±± SDS kernel routines ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

procedure SDS_Init(Card, Base, Irq, Dma:word);far;
procedure SDS_Done;far;
procedure SDS_StartPlay(module:pointer; InitSpd, MixSpeed, Pal:word);far;
procedure SDS_StopPlay;far;
procedure SDS_SetSurround(surroundmod:boolean);far;
procedure SDS_SetAmplification(percent:word);far;
procedure SDS_SetPollMix(pollmode:boolean);far;
procedure SDS_Poll;far;
procedure SDS_Services;far;

{±±± I/O routines ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

function SDS_ReadBlock (var f:file; p:pointer; size:word; xorval:byte) : word;
function SDS_WriteBlock(var f:file; p:pointer; size:word; xorval:byte) : word;

{ For both routines, if XorVal=01h then the sample must be loaded/saved as
  a 16-bit sample. For conversion:
     Smp8_unsigned  = 255 * ( Smp16_unsigned / 65535 )
     Smp8_signed    = Smp8_unsigned xor 80h  (GUPE uses 7Fh !!!)
     Smp16_unsigned = 65535 * ( Smp8_unsigned / 255 )
     Smp16_signed   = Smp16_unsigned-32768
}


{±±± Other useful routines ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}

procedure CallUserRoutine;
function  FineTune2Speed(ft:byte):word;
function  AsciiZ2String(var v; maxlen:byte):string;
function  CompressPattern(     source:pointer;
                               chnls, lines:word;
                           var dest:pointer;
                           var CompressedSize:word ):boolean;
{ 'Samples' MUST be set in order to call 'CompressPattern()' function !!! }

implementation

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   SDS memory manager functions                                         ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}


type  gus_chunk_type = ^gct;
      gct            = record
                         addr, size : longint;
                         next : gus_chunk_type;
                       end;  { sort of a single chained list }
const gus_MCB : gus_chunk_type = nil;


procedure gusDelay;near;assembler;
asm
  mov dx,300h
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  in al,dx
end;

procedure gusPoke(addr:longint; b:byte);near;
var AddrLo:word; AddrHi:byte;
begin
  AddrLo:=word(addr and $FFFF);
  AddrHi:=byte(longint(addr and $FF0000) shr 16);
  port [gusBase+$103]:=$43; { set DRAM I/O address LOW }
  portw[gusBase+$104]:=AddrLo;
  port [gusBase+$103]:=$44; { set DRAM I/O address HIGH }
  port [gusBase+$105]:=AddrHi;
  port [gusBase+$107]:=b;   { write byte }
end;

function gusPeek(addr:longint):byte;near;
var AddrHi,b:byte; AddrLo:word;
begin
  AddrLo:=word(addr and $FFFF);
  AddrHi:=byte(longint(addr and $FF0000) shr 16);
  port [gusBase+$103]:=$43; { set DRAM I/O address LOW }
  portw[gusBase+$104]:=AddrLo;
  port [gusBase+$103]:=$44; { set DRAM I/O address HIGH }
  port [gusBase+$105]:=AddrHi;
  b:=port[gusBase+$107];
  gusPeek:=b;
end;

procedure gusHowMuchDRAM; { determines how much DRAM has the card (max 1 Mb detected) }
const MaxDetected = 1024*1024; { 1 Mb - std. GUS supports only bits 0-19 of the linear address }
var addr : longint;
begin
  addr:=256*1024; { 256 kb = default }
  gus_DRAM:=0;
  repeat
    gusPoke(addr,$AA);
    gusDelay;
    gusDelay;
    if (gusPeek(addr)<>$AA) then gus_DRAM:=addr-1;
    addr:=addr+256*1024; {next bank}
  until (gus_DRAM>0) or (addr>=MaxDetected);
  if (addr>=MaxDetected) and (gus_DRAM=0) then gus_DRAM:=MaxDetected-1;
end;

function galloc (size:longint) : pointer;
var p,ap,q:gus_chunk_type; stop:boolean;
begin
  if gus_MCB=nil { first allocation ? } then begin
    gus_MCB:=malloc(sizeof(gct));
    gus_MCB^.next:=nil;
    gus_MCB^.addr:=1; { Start with address 1, not with 0 !!! }
    gus_MCB^.size:=size;
    galloc:=pointer(1);  { 1 instead of zero, to avoid NIL }
  end else begin
    { search the lowest address that out block can start from }
    p:=gus_MCB; stop:=false; q:=nil;
    while (p^.next<>nil) and (not stop) do begin
      ap:=p^.next;
      if ap=nil then stop:=true else begin
        if size <= ap^.addr - (p^.addr+longint(p^.size)) then begin
          { block fits here! first create a descriptor for it }
          q:=malloc(sizeof(gct));
          q^.addr:=p^.addr+longint(p^.size);
          q^.size:=size;
          { link descriptor to chain }
          q^.next:=ap;
          p^.next:=q;
          stop:=true;
        end else p:=p^.next; { does not fit, test the next locations }
      end;
    end;
    if (q=nil) and (stop or (p^.next=nil)) then begin { last element }
      if p^.addr+longint(p^.size)+longint(size) <= gus_DRAM then begin { check if enough DRAM }
        { allocate a new block at the end of the chain }
        q:=malloc(sizeof(gct));
        q^.addr:=p^.addr+longint(p^.size);
        q^.size:=size;
        { link descriptor to the chain }
        q^.next:=nil;
        p^.next:=q;
      end else q:=nil;
    end;
    if q=nil then galloc:=nil else galloc:=pointer(q^.addr);
  end;
end;

function gus_free (var p:pointer) : boolean;
var q,bq:gus_chunk_type; x:pointer;
begin
  if p=nil then begin
    gus_free:=true;
    exit
  end;
  q:=gus_MCB; { head of the chained list of descriptors }
  bq:=nil;    { "before q" }
  while (q<>nil) and (q^.addr<>longint(p)) do begin
    if q=gus_MCB then bq:=q else bq:=bq^.next;
    q:=q^.next;
  end;
  if q=nil then gus_free:=false { deallocation has failed, cannot find the given DRAM address }
  else begin
    { we have to deallocate q from the descriptors chain }
    if q=gus_MCB { first element ? } then begin
      gus_MCB:=q^.next;
      x:=q; gus_free:=free(x); q:=x;  { deallocate memo }
    end else begin
      bq^.next:=q^.next; { erase linkage }
      x:=q; gus_free:=free(x); q:=x;  { deallocate memo }
    end;
    p:=nil;
  end;
end;

function gus_alloc (size:longint) : pointer;
var p,aux:pointer;
    s_addr, e_addr : longint;
    fill_sz:longint;
begin
{ the first DRAM alloc ? If yes, init GUS and read how much memory onboard }
  if gus_MCB=nil then gusHowMuchDRAM;
{ allocate block }
  p:=galloc(size);
  if p<>nil then begin
  { check 256k page crossing }
    s_addr:=longint(p);          { start DRAM address }
    e_addr:=longint(p)+size-1;   { end DRAM address }
    if (s_addr and $C0000)<>(e_addr and $C0000) then begin { a 256k page has been crossed }
      fill_sz:=(e_addr and $FFFC0000)-s_addr;  { fill-up buffer (temp) }
      gus_free(p);                  { deallocate block }
      aux:=galloc(fill_sz);         { fill-up the rest of the page }
      p:=gus_alloc(size);           { recursive alloc }
      gus_free(aux);                { deallocate fill-up buf }
    end;
  end;
  gus_alloc:=p;  { return allocated block }
end;

function gus_avail : longint; { returns the TOTAL memory available, not the greatest block ! }
var p:gus_chunk_type; avail:longint;
begin
  p:=gus_MCB; avail:=gus_DRAM;
  while p<>nil do begin
    avail:=avail-p^.size;
    p:=p^.next
  end;
  gus_avail:=avail;
end;

function ems_alloc (size:longint) : pointer;
var handle:word;
begin
  handle:=emsAlloc(((size-1) div 16384) + 1); { size in 16k pages }
  if handle=0 then
    ems_alloc:=nil
  else
    ems_alloc:=ptr($F000 or handle,0);   { Fxxx:0, where xxx is the EMS handle }
end;

function ems_free (var p:pointer) : boolean;
var handle:word;
begin
  handle:=seg(p^) and $0FFF;
  ems_free:=emsFree(handle);
  if handle=0 then p:=nil;
end;

function ems_avail : longint;
begin
  ems_avail:=longint(emsFreePages)*16384;
end;

var auxalloc : pointer;

{ Allocates a block in GUS's DRAM, EMS or conventional memory. When UseGUS
  is True, it also takes care about not crossing 256k page boundary. }
function sds_alloc (size:longint) : pointer;
begin
{ if a GUS is present, then alloc a chunk into its DRAM : }
  if UseGUS then
    sds_alloc:=gus_alloc(size)
  else
{ if EMS is present and user wants, allocate a block into it : }
    if UseEMS then begin
      auxAlloc:=ems_alloc(size);
      if auxAlloc=nil then sds_alloc:=malloc(size) else sds_alloc:=auxAlloc;
    end else
{ else, do a normal allocation in the fuckin conventional memory : }
      sds_alloc:=malloc(size);
end;

function sds_free (var p:pointer) : boolean;
begin
{ if sample was loaded into GUS DRAM, then free it from there : }
  if UseGUS then
    sds_free:=gus_free(p)
  else begin
{ if sample was loaded into EMS, deallocate it from there : }
    if (seg(p^) and $F000 = $F000) { in EMS } then
      sds_free:=ems_free(p)
    else
{ else, do a normal deallocation : }
      sds_free:=free(p);
  end;
end;

function sds_mavail : longint;
begin
  if UseGUS then sds_mavail:=gus_avail else
  if UseEMS then sds_mavail:=ems_avail + mavail else
                 sds_mavail:=mavail;
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   Other useful routines                                                ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Procedure CallUserRoutine;assembler;
asm
  cmp    word ptr UserRoutine[2],0   {is segment=0 (NIL) ?}
  je     @NoFuckinCall
  push   ds
  push   bp
  call   dword ptr UserRoutine
  pop    bp
  pop    ds
@NoFuckinCall:
end;

Function FineTune2Speed(ft:byte):word;
const
  FTune : Array [0..15] of Word =
  ( 8363,8413,8463,8529,8581,8651,8723,8757,7895,7941,7985,8046,8107,8169,8232,8280 );
begin
  FineTune2Speed:=FTune[FT];
end;

Function AsciiZ2String(var v; maxlen:byte):string;
var s:string; k:byte; c:char;
begin
  s:=''; k:=0;
  if maxlen>0 then begin
    repeat
      c:=char(mem[seg(v):ofs(v)+k]); inc(k);
      if c<>#0 then s:=s+c;
    until (k>=maxlen) or (c=#0);
  end;
  AsciiZ2String:=s;
end;

function CompressPattern(source:pointer; chnls, lines:word; var dest:pointer; var CompressedSize:word ):boolean;
{ this function assumes that 'Samples' variable is already set to the right
  value, otherwise a wrong compression will be made !!! }
var l,c,pattoffs:word; b:byte;
    cevent, event : array [0..31] of
                    array [0..4]  of byte; { SDS events ! }
begin
  {shrinks source into dest}
  pattoffs:=0;
  fillchar(cevent,32*5,$FF);
  fillchar(event,32*5,$AB);
  for l:=0 to lines-1 do begin
    move(mem[seg(source^):l*chnls*5],event,chnls*5);
    for c:=0 to chnls-1 do begin
      if (event[c][0]=cevent[c][0]) and (event[c][1]=cevent[c][1]) and
         (event[c][2]=cevent[c][2]) and (event[c][3]=cevent[c][3]) and
         (event[c][4]=cevent[c][4]) then begin
         mem[seg(Dest^):pattoffs]:=$FF; {the same event}
         inc(pattoffs)
      end else begin
         if ((event[c][0] or event[c][1] or event[c][3] or event[c][4]) = 0)
            and (event[c][2] and $41 = $41) then begin
            mem[seg(Dest^):pattoffs]:=$FD; {null event}
            inc(pattoffs);
         end else begin
            mem[seg(Dest^):pattoffs]:=event[c][0];
            inc(pattoffs);
            {}if event[c][1]>Samples then event[c][1]:=0;{!!!!!!!!!}
            mem[seg(Dest^):pattoffs]:=event[c][1];
            inc(pattoffs);
            b:=event[c][2];
            if (event[c][3]<>0) then begin
               mem[seg(Dest^):pattoffs]:=b or $80;
               mem[seg(Dest^):pattoffs+1]:=event[c][3];
               mem[seg(Dest^):pattoffs+2]:=event[c][4];
               inc(pattoffs,3);
            end else begin
               mem[seg(Dest^):pattoffs]:=b and $7F;
               inc(pattoffs);
            end;
         end;
      end;
    end;
    move(event,cevent,32*5);
  end;
  {reallocate this pattern}
  CompressedSize:=pattoffs;
  CompressPattern:=(realloc(Dest,CompressedSize)>=CompressedSize)
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   I/O routines                                                         ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

var RemindSome : array [0..7] of byte; { used to "extend" the sample in GUS DRAM
                                         in order to prevent the ugly UltraClicks(tm) }

function gus_UpLoad(var f:file; addr:longint; size:word; xorval:byte) : word;
{ this routine is very slow, but what the fuck... }
var k:longint; r:word; c:byte; poz:longint; w:integer;
    delta,xv:byte;
label _fuck;
begin {$i-}
  if size=0 then begin
    gus_UpLoad:=0;
    exit;
  end;
  poz:=filepos(f);
  ResetBuffer;
  r:=0; CacheEOF:=false;
  delta:=0; xv:=xorval and $80;
  for k:=addr to addr+longint(size)-1 do begin
    if CacheEOF then goto _fuck;
    c:=ReadByte(f);
    if xorval and 1 = 0 then c:=c xor xv
    else begin
          inc(r);
          if xorval and $41 = $41 then begin
            c:=c+delta;
            delta:=c;
          end;
          w:=c;
          c:=ReadByte(f);
          if xorval and $41 = $41 then begin
            c:=c+delta;
            delta:=c;
          end;
          w:=w+(integer(c) shl 8);  { 16-bit signed - that's all SDS knows... }
          w:=w xor $8000;
          c:=byte(w shr 8) xor $80; { 8-bit signed }
    end;
    if xorval and $41 = $40 {delta format} then begin
      c:=c+delta;
      delta:=c;
    end;
    gusPoke(k,c); inc(r);
    if (addr+longint(size)-1-k)<=7 then
      RemindSome[addr+longint(size)-1-k]:=c; { store this byte ! }
  end;
_fuck:
  { extend the sample by adding a few extra bytes (8) at the end of it -
    this is done in order to prevent the UltraClicks(TM)!  The bytes are
    already stored into RemindSome[] }
  for k:=addr+longint(size) to addr+longint(size)+7 do
    gusPoke(k,RemindSome[k-(addr+longint(size))]);
  { now restore status and exit }
  seek(f,poz+longint(r));
  gus_UpLoad:=r;
end;

function ems_UpLoad(var f:file; p:pointer; size:word; xorval:byte) : word;
var Handle,pages,i,j,fval,r:word; poz:longint; c:byte; w:integer;
    xv,delta:byte;
label _fuck;
begin {$i-}
  if size=0 then begin
    ems_UpLoad:=0;
    exit;
  end;
  handle:=seg(p^) and $FFF;
  pages:=((size-1) div 16384)+1;
  poz:=FilePos(f);
  xv:=xorval and $80; delta:=0;
  ResetBuffer;
  r:=0; CacheEOF:=false;
  for i:=0 to pages-1 do begin
    emsMap(handle,i,0);
    if i=pages-1 then fval:=(size-1) mod 16384 else fval:=16383;
    for j:=0 to fval do begin
      if CacheEOF then goto _fuck else begin
        c:=ReadByte(f);
        if XorVal and 1 = 0 then c:=c xor xv
        else begin { it's a 16-bit-signed sample ... }
          inc(r);
          if xorval and $41 = $41 then begin
            c:=c+delta;
            delta:=c;
          end;
          w:=c;
          c:=ReadByte(f);
          if xorval and $41 = $41 then begin
            c:=c+delta;
            delta:=c;
          end;
          w:=w+(integer(c) shl 8);  { 16-bit signed - that's all SDS knows... }
          w:=w xor $8000;
          c:=byte(w shr 8) xor $80; { 8-bit signed }
        end;
        if xorval and $41 = $40 then begin
          c:=c + delta;
          delta:=c;
        end;
        mem[emsPageFrameAddr:j]:=c;  { write byte into EMS page }
        inc(r);
      end;
    end;
  end;
_fuck:
  seek(f,poz+longint(r));
  ems_UpLoad:=r;
end;

function cnv_UpLoad(var f:file; p:pointer; size:word; xorval:byte) : word;
var r:word; poz,k:longint; c:byte; w:integer;
    xv,delta:byte;
begin {$i-}
  if size=0 then begin
    cnv_UpLoad:=0;
    exit;
  end;
  if xorval=0 then
    blockread(f,p^,size,r) { no xor is necessarry, load it directly }
  else begin
    poz:=filepos(f);
    xv:=xorval and $80; delta:=0;
    ResetBuffer;
    r:=0; CacheEOF:=false;
    for k:=0 to size-1 do begin
      if CacheEOF then k:=size-1 else begin
        c:=ReadByte(f);
        if XorVal and 1 = 0 then c:=c xor xv
        else begin { it's a 16-bit-signed sample ... }
          inc(r);
          if xorval and $41 = $41 then begin
            c:=c+delta;
            delta:=c;
          end;
          w:=c;
          c:=ReadByte(f);
          if xorval and $41 = $41 then begin
            c:=c+delta;
            delta:=c;
          end;
          w:=w+(integer(c) shl 8);  { 16-bit signed - that's all SDS knows... }
          w:=w xor $8000;
          c:=byte(w shr 8) xor $80; { 8-bit signed }
        end;
        if xorval and $41 = $40 then begin
          c:=c+delta;
          delta:=c;
        end;
        mem[seg(p^):ofs(p^)+k]:=c;
        inc(r);
      end;
    end;
    seek(f,poz+longint(r));
  end;
  cnv_UpLoad:=r;
end;

function gus_DownLoad(var f:file; addr:longint; size:word; xorval:byte) : word;
var r:word; k,poz:longint; c:byte; w:integer;
label _fuck;
begin
  if size=0 then begin
    gus_DownLoad:=0;
    exit;
  end;
  r:=0; poz:=filepos(f);
  OutBuffIndex:=0;
  for k:=addr to addr+longint(size)-1 do begin
    c:=GusPeek(addr);
    if XorVal<>1 then c:=c xor xorval
    else begin { it's a 16-bit-signed sample ... }
      w:=((c xor $80) shl 8) - 32768;
      if not WriteByte(f,w and $FF) then goto _fuck;
      c:=(w shr 8) and $FF;
    end;
    if not WriteByte(f,c) then goto _fuck;
    inc(r);
  end;
_fuck:
  FlushBuffer(f);
  seek(f,poz+r);
  gus_DownLoad:=r;
end;

function ems_DownLoad(var f:file; p:pointer; size:word; xorval:byte) : word;
var r:word; k,poz:longint; c:byte;
    handle, pages,i, j, fv : word;
    w:integer;
label _fuck;
begin
  if size=0 then begin
    ems_DownLoad:=0;
    exit;
  end;
  handle:=seg(p^) and $FFF;
  pages:=((size-1) div 16384)+1;
  r:=0; poz:=filepos(f);
  OutBuffIndex:=0;
  for i:=0 to pages-1 do begin
    emsMap(handle,i,0);
    if i=pages-1 then fv:=(size-1) mod 16384 else fv:=16383;
    for j:=0 to fv do begin
      c:=mem[emsPageFrameAddr:j];
      if XorVal and 1 = 0 then c:=c xor (xorval and $80)
      else begin { it's a 16-bit-signed sample ... }
        w:=((c xor $80) shl 8) - 32768;
        if not WriteByte(f,w and $FF) then goto _fuck;
        c:=(w shr 8) and $FF;
      end;
      if not WriteByte(f,c) then goto _fuck;
      inc(r);
    end;
  end;
_fuck:
  FlushBuffer(f);
  seek(f,poz+r);
  ems_DownLoad:=r;
end;

function cnv_DownLoad(var f:file; p:pointer; size:word; xorval:byte) : word;
var r:word; k,poz:longint; c:byte; w:integer;
label _fuck;
begin
  if size=0 then begin
    cnv_DownLoad:=0;
    exit;
  end;
  poz:=filepos(f);
  if xorval=0 then
    BlockWrite(f,p^,size,r)
  else begin
    r:=0; OutBuffIndex:=0;
    for k:=0 to size-1 do begin
      c:=mem[seg(p^):ofs(p^)+k];
      if XorVal<>1 then c:=c xor xorval
      else begin { it's a 16-bit-signed sample ... }
        w:=((c xor $80) shl 8) - 32768;
        if not WriteByte(f,w and $FF) then goto _fuck;
        c:=(w shr 8) and $FF;
      end;
      if not WriteByte(f,c) then goto _fuck;
      inc(r);
    end;
_fuck:
    FlushBuffer(f);
  end;
  seek(f,poz+r);
  cnv_DownLoad:=r;
end;


function sds_ReadBlock (var f:file; p:pointer; size:word; xorval:byte) : word;
begin
  if UseGUS then
    sds_ReadBlock:=gus_UpLoad(f,longint(p),size,xorval)
  else begin
    if (seg(p^) and $F000 = $F000) then {from EMS}
      sds_ReadBlock:=ems_UpLoad(f,p,size,xorval)
    else
      sds_ReadBlock:=cnv_UpLoad(f,p,size,xorval); {from conv. memory}
  end;
end;

function sds_WriteBlock(var f:file; p:pointer; size:word; xorval:byte) : word;
begin
  if UseGUS then
    sds_WriteBlock:=gus_DownLoad(f,longint(p),size,xorval)
  else begin
    if (seg(p^) and $F000 = $F000) then {into EMS}
      sds_WriteBlock:=ems_DownLoad(f,p,size,xorval)
    else
      sds_WriteBlock:=cnv_DownLoad(f,p,size,xorval); {into conv. memory}
  end;
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   669 loader, revision 1.1                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function SDS_Read_669(var f:file; LoadSamples:boolean):Pointer;
var m,pattaux:pointer; {module}
    r,a,k,pattoffs:word;
    b,c,l:word;
    OldPosition : longint;
    ifh : record
            Magic    : word;
            Title    : array [0..107] of char;
            Samples,
            Patterns,
            Unused   : byte;
            Order    : array [0..127] of byte;
            PattSpd  : array [0..127] of byte;
            LastRow  : array [0..127] of byte;
          end;
    ifs : record
            Name     : array [0..12] of char;
            Size, LoopStart, LoopEnd : longint;
          end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    XorValue:byte;
    sgn : string;
    cevent, event : array [0..31] of array [0..4] of byte; { SDS events ! }
    iev : array [0..7] of array [0..2] of byte;
Function ifCommand2Internal(b,p:byte):Byte;
begin
  ifCommand2Internal:=0;   {FIXME!}
end;
Function ifPara2Internal(b,p:byte):Byte;
begin
  ifPara2Internal:=0;      {FIXME!}
end;
begin {$i-}

  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_669:=nil;

  OldPosition:=FilePos(f);

  loaderror:=0;

  action:=1; CallUserRoutine;
  blockread(f,ifh,sizeof(ifh),r);
  if r<sizeof(ifh) then begin
    loaderror:=2; { incorrect format }
    exit
  end;

  sgn:=AsciiZ2String(ifh.Magic,2);
  if sgn<>'if' then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  Patterns:=ifh.Patterns;
  Samples:=ifh.samples;
  {compute nr. of entries}
  Entries:=0;
  for k:=0 to 127 do if ifh.Order[k]<$FF then inc(Entries);
  {module name}
  move(ifh.Title[0],ModuleName[1],35);
  ModuleName:=AsciiZ2String(ModuleName[1],35);
  { unknown autor - 669 does not have such info }
  Author:='';
  {others}
  sh.patterns:=Patterns;
  sh.entries:=Entries;
  sh.samples:=Samples;
  {channels}
  sh.channels:=8;       {always!}
  Channels:=8;
  sh.InitGVolume:=$40;  {this seems to be the 669 default gvolume}
  sh.InitSpeed:=6;      {is this the default initial speed ?}
  sh.InitBPM:=80;       {669's default tempo}
  sh.MasterVolume:=$88;
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF; { all channels are initially ON }
  {VRI (pan positions)}
  for k:=0 to 7 do
    if (byte(k and 3) in [1,2]) then sh.VRI[k]:=$F else sh.VRI[k]:=0;
  {allocate memory for module}
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; exit
  end;
  move(sh,m^,sizeof(sh));
  {lines/pattern}
  fillchar(LPerPatt,patterns,64);  {default=64 lines/patt}
  {read instruments descriptors}
  fillchar(SamType,256,0);  { 8bit samples (default) }
  fillchar(Sample,256*4,0);
  for a:=1 to Samples do begin
    action:=3; actionpara:=a; CallUserRoutine;
    blockread(f,ifs,sizeof(ifs),r);
    if r<>sizeof(ifs) then begin
      sds_unload(m); loaderror:=2; exit
    end;
    SName[a]:=AsciiZ2String(ifs.Name,13);
    if (ifs.Size>1) then begin
      SamType[a]:=0;  {0=8bit, 1=16bit}
      SamSize[a]:=(ifs.Size div (1+SamType[a])) and $FFFF;
      if LoadSamples then begin
        Sample[a]:=sds_alloc(SamSize[a]+8); { 8 extra bytes to prevent UltraClicks(tm)... }
        if (Sample[a]=nil) then begin
          sds_unload(m); loaderror:=3; exit
        end;
      end;
      with ss do begin
        Volume:=$40;
        C2Speed:=8363;
        if UseGUS then Address:=longint(Sample[a]) else Address:=seg(Sample[a]^);
        Size:=ifs.Size and $FFFF;
        LoopStart:=ifs.LoopStart and $FFFF;
        LoopEnd:=ifs.LoopEnd and $FFFF;
        if (LoopEnd<=2) then loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
    end else begin
      with ss do begin
        Volume:=0;
        C2Speed:=8363;
        Address:=0;
        Size:=0;
        loopstart:=0;
        loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SamSize[a]:=0;
      Sample[a]:=nil;
      SamType[a]:=0;
    end;
  end;
  {fill order}
  move(ifh.Order,Order,128);
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);
  {read and uncompress patterns}
  for a:=1 to patterns do begin
    action:=2; actionPARA:=a-1; CallUserRoutine;
    { read nr. of Rows/pattern }
    lperpatt[a-1]:=ifh.LastRow[a-1]+1;
    { alloc aux pattern having that many rows }
    pattaux:=malloc(5*8*word(lperpatt[a-1])+16);
    {alloc pattern at max size, it will be reallocated later}
    pattern[a-1]:=malloc(5*8*word(lperpatt[a-1])+16);
    if (pattern[a-1]=nil) or (pattaux=nil) then begin
     sds_unload(m); loaderror:=3; exit { not enough memory }
    end;
    {init pattaux -> null pattern}
    fillchar(event[0],5,0); event[0][2]:=$C1;
    for k:=0 to 8*LPerPatt[a-1]-1 do begin
      move(event[0],mem[seg(pattaux^):k*5],5);
    end;
    {read line by line the whole pattern}
    for l:=0 to 63 do begin
      {read event}
      blockread(f,iev[0],3*8,r);
      if l<LPerPatt[a-1] then begin
        {scan channel by channel the whole event}
        fillchar(event[0],8*5,0);
        for c:=0 to 7 do begin
          { note }
          event[c][0]:=(iev[c][0] shr 2) + 1;
          if event[c][0]>60 then event[c][0]:=0;
          { instr }
          event[c][1]:=(iev[c][1] shr 4) + ((iev[c][0] and 3) shl 4) + 1;
          if event[c][1]>Samples then event[c][1]:=0;
          { volume }
          event[c][2]:=trunc($40*(iev[c][1] and $F)/$F);   {!?}
          if event[c][2]=$40 then event[c][2]:=$C1;
          { eff+para -> FIXME! }
          event[c][3]:=ifCommand2Internal(iev[c][2] shr 4, iev[c][2] and $F);{}
          event[c][4]:=ifPara2Internal(iev[c][2] shr 4, iev[c][2] and $F);{}
          if (l=0) and (c=0) then begin
            event[c][3]:=1; {set speed}
            event[c][4]:=ifh.PattSpd[a-1]; {??????????????????????}
          end;
        end;
        {transfer full event (8 chn) into pattaux}
        move(event[0],mem[seg(pattaux^):5*word(l)*8],5*8);
      end;
    end;
    if not CompressPattern(pattaux,Channels,LPerPatt[a-1],Pattern[a-1],PattSize[a-1]) then begin
      SDS_UnLoad(m); loaderror:=5; exit
    end;
    {free the auxiliary pattern}
    if not free(pattaux) then begin
      SDS_UnLoad(m); loaderror:=8; exit;
    end;
  end;
  {now write the nr. of rows/pattern}
  move(lperpatt,mem[seg(m^):sizeof(sh)],patterns);
  {read samples if necessarry}
  if LoadSamples then begin
    for a:=1 to Samples do begin
      if SamSize[a]>0 then begin  {skip unused samples}
        action:=3; actionPARA:=a; CallUserRoutine;
        XorValue:=$80;  {always 8 bit unsigned data !}
        r:=sds_ReadBlock(f,Sample[a],SamSize[a],XorValue);
        if r<SamSize[a]*(1+SamType[a]) then begin
          sds_unload(m); loaderror:=2; exit;
        end;
      end;
    end;
  end;
  SDS_Read_669:=m;
  seek(f,OldPosition);
end;

Function SDS_Load_669(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  sds_load_669:=nil;
  if not openforinput(f,name) then begin
    LoadError:=1; { file not found }
    exit
  end;
  sds_load_669:=sds_read_669(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   FAR loader, revision 1.3, 31 Jan 1997                                ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

function SDS_Read_FAR(var f:file; LoadSamples:boolean):Pointer;
var m:pointer;
    sign:string[5];
    farh1 : record
              magic : longint; { FARю }
              name : array [0..39] of char;
              cr_lf_eof : array [0..2] of byte;
              rest_size : word;
              version : byte;
              channelmap : array [0..15] of byte; { on/off }
              shit1 : array [0..8] of byte;
              def_tempo : byte;
              panning : array [0..15] of byte; { 0-15 for each channel }
              shit2 : longint;
              text_size : word;
            end;
    farh2 : record
              order : array [byte] of byte;
              patterns : byte;
              entries : byte; { really "ENTRIES" ? }
              loopTo : byte;
              PattSize : array [byte] of word;  { PattRows = (PattSize-2)/(16*4) }
            end;
    fsh : record
            name : array [0..31] of char;
            size : longint;
            finetune : byte;
            volume : byte;
            loopstart, loopend : longint;
            stype : byte;
            loopmode : byte;
          end;
    r,a,b,c,d:word;
    lpp : array[byte] of byte;
    fev : array [0..15] of array [0..3] of byte; { a FAR row }
    ev  : array [0..31] of array [0..4] of byte; { a SDS row }
    smap : array [0..7] of byte;
    sh : sdmint_headtype;
    ih : array [byte] of sdmint_insttype;
    mask:longint;
    OldPos:longint;
    pattaux:pointer;
    _tempo : byte;
    _finetempo:shortint;
function ReadData(var Dat; size:word):boolean;
begin
  blockread(f,Dat,size,r);
  readdata:=r=size;
end;
function farcommand2internal(b:byte):byte;
begin
  farcommand2internal:=0;
  case b shr 4 of
    3: {port to note} farcommand2internal:=7;
    4: {retrigger} farcommand2internal:=17;
    7: {vol sld up} farcommand2internal:=4{13};  (**)
    8: {vol sld dn} farcommand2internal:=4{13};  (**)
    $C: {note offset?} farcommand2internal:=19;  (**)
    $F: {tempo} farcommand2internal:=20;
    $E: {finetempo up} farcommand2internal:=20;
    $D: {finetempo up} farcommand2internal:=20;
  end;
end;
function farpara2internal(b:byte):byte;
begin
  farpara2internal:=0;
  case b shr 4 of
    3: {port to note} farpara2internal:=b and $F; {far from okay...}
    4: {retrigger} if b and $F<>0 then farpara2internal:=16 div (b and $F) + 1; {far from okay...}
    7: {vol sld up} farpara2internal:=(b and $F) shl 4;
    8: {vol sld dn} farpara2internal:=(b and $F);
    $C: {note offset?} farpara2internal:=(b and $F) or $D0;
    $F: {tempo} begin
                  if b and $F > 0 then begin
                    farpara2internal:=trunc((32/(b and $F)*4+_finetempo)*5/2);
                    _tempo:=b and $F;
                  end;
                end;
    $E: {finetempo} begin
                      if _tempo>0 then begin
                        farpara2internal:=trunc((32/_tempo*4+(b and $F))*5/2);
                        _finetempo:=b and $F;
                      end;
                    end;
    $D: {finetempo} begin
                      if _tempo>0 then begin
                        farpara2internal:=trunc((32/_tempo*4-(b and $F))*5/2);
                        _finetempo:=-(b and $F);
                      end;
                    end;
  end;
end;
function sinit(n:byte):boolean;
begin
  sinit:=( smap[(n-1) div 8] and (1 shl ((n-1) mod 8)) ) <> 0;
end;
var OldPosition : longint;
begin {$I-}
  if UseEMS and (not emsDetect) then UseEMS:=false;

  sds_read_far:=nil;

  OldPosition:=filePos(f);

  loaderror:=0;

  action:=1; calluserroutine;
  if not ReadData(farh1, sizeof(farh1)) or (farh1.magic<>$FE524146{FARю}) then begin
    loaderror:=2; exit;
  end;

  if farh1.text_size>0 then begin { there is a text stored here }
    action:=5; calluserroutine;
    if TextPtr<>nil then free(TextPtr);
    TextPtr:=malloc(farh1.text_size+16);
    TextSize:=farh1.text_size;
    readdata(TextPtr^,TextSize);
  end;

  action:=1; calluserroutine;
  if not readdata(farh2,sizeof(farh2)) then begin
    loaderror:=2;
    if TextPtr<>nil then begin free(TextPtr); TextSize:=0 end;
    exit
  end;

  Channels:=16;
  patterns:=farh2.patterns;  {!!!!!!!!!!!!!??????????? no way, sometimes there are more patterns !!! }
  entries:=farh2.entries;
  move(farh2.order,order,256);
  modulename:=asciiz2string(farh1.name,35); {truncate!}
  Author:='';

  seek(f,OldPosition+longint(farh1.rest_size));
  fillchar(ih,256*sizeof(sdmint_insttype),0);

  {tempo and fine tempo}
  _tempo:=farh1.def_tempo;
  _finetempo:=0;

  { correction of FAR's documentation... :-( }
  patterns:=0;
  for a:=0 to 255 do if farh2.pattsize[a]>0 then inc(patterns);

  {store old position}
  OldPos:=filepos(f);

  {seek the sample map}
  for a:=0 to patterns-1 do seek(f,filepos(f)+farh2.pattsize[a]);

  { Read Sample Map }
  if not readdata(smap,8) then begin
    loaderror:=2; sds_unload(m); exit
  end;
  samples:=0;
  for a:=1 to 64 do if sinit(a) then inc(samples);  { a shitty method }

  {back to patterns}
  seek(f,OldPos);

  { Read and compress patterns }
  for a:=0 to patterns-1 do begin
    action:=2; actionpara:=a; calluserroutine;

    { Break Location and Tempo for this pattern - unused data }
    readdata(b,2);

    { compute the number of Rows/Pattern }
    if farh2.pattsize[a]>=16322 then
      lpp[a]:=255
    else
      lpp[a]:=(farh2.pattsize[a]-2) div (16*4);

    { alloc pattern at max size, it will be reallocated }
    pattern[a]:=malloc(word(lpp[a])*16*5);
    if pattern[a]=nil then begin
      loaderror:=3; sds_unload(m); exit
    end;

    {create an aux pattern}
    pattaux:=malloc(16*5*word(lpp[a]));  {max size!}
    if pattaux=nil then begin
      loaderror:=9; sds_unload(m); exit
    end;

    { init pattaux - quite useless... }
    fillchar(ev[0],5,0); ev[0][2]:=$C1;
    for b:=0 to word(lpp[a])*16-1 do
      move(ev[0],mem[seg(pattaux^):word(b)*5],5);

    if lpp[a]>0 then
      for b:=0 to lpp[a]-1 do begin
        if not readdata(fev,16*4) then begin
          loaderror:=2; sds_unload(m); exit
        end;
        for c:=0 to 15 do begin { each column ... }
          { note }
          ev[c][0]:=fev[c][0];
          if ev[c][0]>0 then inc(ev[c][0],12); { FAR's octave #0 = SDS's octave #1 }
          { sample/inst }
          ev[c][1]:=fev[c][1];
          if ev[c][0]>0 then inc(ev[c][1]);
          { volume }
          if fev[c][2]=0 then ev[c][2]:=$C1 else begin
            if (fev[c][2] and $F=0) and (fev[c][2] and $F0<>0) then
              ev[c][2]:=$40
            else begin
              ev[c][2]:=((fev[c][2] shr 4) and $F) + ((fev[c][2] shl 4) and $F0);
              ev[c][2]:=trunc(64*(ev[c][2]-$10)/$EF);
            end;
           end;
          { eff+para - very few of them supported }
          ev[c][3]:=farcommand2internal(fev[c][3]);  {eff}
          ev[c][4]:=farpara2internal(fev[c][3]);     {par}
          if ev[c][3]=20{BPM} then
            for d:=0 to c do
              if ev[d][3]=20 then ev[d][4]:=ev[c][4];
        end; {for c}
        move(ev,mem[seg(pattaux^):b*5*Channels],5*Channels);
      end; {for b}

    if not CompressPattern(pattaux,16,lpp[a],Pattern[a],PattSize[a]) then begin
      loaderror:=5; sds_unload(m); exit
    end;
    {kill pattaux}
    free(pattaux);
  end; {for a}

  { skip 8 bytes (smap) }
  seek(f,filepos(f)+8);

  fillchar(SamType,256,0);
  { Read samples }
  for a:=1 to samples do begin
    if sinit(a) then begin
      action:=3; actionpara:=a; calluserroutine;
      if not readdata(fsh,sizeof(fsh)) then begin
        loaderror:=2; sds_unload(m); exit
      end;
      Sample[a]:=nil;
      if LoadSamples then begin
        sample[a]:=sds_alloc(fsh.size+8);
        if sample[a]=nil then begin
          loaderror:=3; sds_unload(m); exit
        end;
        r:=sds_ReadBlock(f, sample[a], fsh.size, 0); { always 8-bit signed ? }
        if r<fsh.size then begin
          loaderror:=2; sds_unload(m); exit;
        end;
      end else seek(f,filepos(f)+fsh.size);
      SamSize[a]:=fsh.size;
      SName[a]:=asciiz2string(fsh.name,32);
      { fill up the descriptor's fields }
      with ih[a] do begin
        volume:=$40;   { fsh.volume is not supported by FAR 1.0 }
        c2speed:=8363; { fsh.finetune is not supported by FAR 1.0 }
        if UseGUS then
          address:=longint(Sample[a])
        else
          address:=seg(sample[a]^);
        size:=fsh.size;
        loopstart:=fsh.loopstart;
        if fsh.loopmode and $8 <> 0 then
          loopend:=fsh.loopend
        else
          loopend:=$FFFF;
      end;
    end else begin
      { fill up the descriptor's fields }
      with ih[a] do begin
        volume:=0;
        c2speed:=8363;
        address:=0;
        size:=0;
        loopstart:=0;
        loopend:=0;
      end;
      Sample[a]:=nil;
      SamSize[a]:=0;
      SName[a]:='';
    end;
  end;

  { Allocate and fill up module's MINF chunk }
  m:=malloc(sizeof(sh)+patterns+entries+samples*sizeof(sdmint_insttype));
  if m=nil then begin
    loaderror:=3; sds_unload(m); exit
  end;

  sh.patterns:=patterns;
  sh.entries:=entries;
  sh.samples:=samples;
  sh.channels:=16;

  sh.InitGVolume:=$40;
  sh.InitSpeed:=4;
  sh.InitBPM:=trunc((32/farh1.def_tempo*4)*5/2);
  move(farh1.panning,sh.vri,16);
  sh.mastervolume:=$88;
  sh.PattAddrTabPtr:=@Pattern;
  mask:=1; sh.channelstatus:=0;
  for a:=0 to 15 do begin
    if farh1.channelmap[a]<>0 then
      sh.channelstatus:=sh.channelstatus or mask;
    mask:=mask shl 1;
  end;
  move(sh,m^,sizeof(sh));
  move(lpp,mem[seg(m^):sizeof(sh)],patterns);
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);
  move(ih[1],mem[seg(m^):sizeof(sh)+patterns+entries],samples*sizeof(sdmint_insttype));
  sds_read_far:=m;
  seek(f,OldPosition);
  loaderror:=0;
end;

function SDS_Load_FAR(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  if not openforinput(f,name) then begin
    loaderror:=1; exit
  end;
  sds_load_far:=sds_read_far(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   MOD loader, revision 1.3                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function MOD_Effect2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0: if p=0 then c:=0 else c:=10; { Arpeggio }
    1: { Portamento up } c:=6;
    2: { Portamento down } c:=5;
    3: { ToNote/Slide to pitch } c:=7;
    4: { Vibrato } c:=8;
    5: { Tone portamento + vol slide } c:=12;
    6: { Vibrato + vol slide } c:=11;
    7: { Tremolo } c:=18;
    8: { Amiga 8xy, unused } c:=24;
    9: { Set sample offset } c:=15;
    10: { Slide volume } c:=4;
    11: { Jump } c:=2;
    {12 = set voice volume, replaced}
    13: { Cancel } c:=3;
    15: { Set tempo/set BPM } if p<$20 then c:=1 {speed} else c:=20; {bpm}
    14: begin { Extended }
      case (p shr 4) of
        0 : { Set filter } c:=19;
        1 : { FineSlide up } c:=6;
        2 : { FineSlide down } c:=5;
        3 : { Glissando control } c:=19;
        4 : { Set vibrato waveform } c:=19;
        5 : { Set finetune } c:=19;
        6 : { Set/Jump to loop } c:=19;
        7 : { Set tremolo waveform } c:=19;
        8 : { Set panning } c:=19;
        9 : { Retrig note } c:=17;
        10: { Fine volumeslide up } c:=13;
        11: { Fine volumeslide down } c:=13;
        12: { Note cut } c:=19;
        13: { Note delay } c:=19;
        14: { Pattern delay } c:=19;
        15: { Invert loop } c:=0; {not used}
      end;
    end;
    else c:=0;
  end;
  MOD_Effect2Internal:=c;
end;

Function MOD_Para2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0..9,11,13: c:=p; {all eff}
    10: if p and $F0 <> 0 then c:=p and $F0 else c:=p and $F;
    14: begin { Extended }
      case (p shr 4) of
        0 : { Set filter            } c:=p and $f;
        1 : { FineSlide up          } c:=$F0 or (p and $f);
        2 : { FineSlide down        } c:=$F0 or (p and $f);
        3 : { Glissando control     } c:=$10 or (p and $f);
        4 : { Set vibrato waveform  } c:=$30 or (p and $f);
        5 : { Set finetune          } c:=$20 or (p and $f);
        6 : { Set/Jump to loop      } c:=$B0 or (p and $f);
        7 : { Set tremolo waveform  } c:=$40 or (p and $f);
        8 : { Set panning           } c:=$80 or (p and $F);
        9 : { Retrig note           } c:=p and $f;
        10: { Fine volumeslide up   } c:=(p and $f) shl 4;
        11: { Fine volumeslide down } c:=(p and $f);
        12: { Note cut              } c:=$C0 or (p and $f);
        13: { Note delay            } c:=$D0 or (p and $f);
        14: { Pattern delay         } c:=$E0 or (p and $f);
        15: { Invert loop           } c:=0; {not used}
      end;
    end;
    15: { Set tempo } c:=p; {spd/BPM}
    else c:=0;
  end;
  MOD_Para2Internal:=c;
end;

Function TTSgn(S:string):boolean; { Checks whether S is a TakeTracker/FastTracker signature or not }
begin TTSgn:=UCase(copy(S,3,2))='CH' end;

Function Value(c:char):byte;
begin
  if c in ['0'..'9'] then Value:=byte(c)-byte('0') else Value:=0;
end;

Function TTChn(s:string):word;
begin TTChn:=Value(s[1])*10+Value(s[2]); end;

function Pitch2Byte(w:word):byte; {converts a pitch into a note index (0..60)}
const
  Pitch : Array [0..71] of word =
( 1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960,912,
  856, 808, 762, 720, 678, 640, 604, 570, 538, 508, 480,453,
  428, 404, 381, 360, 339, 320, 302, 285, 269, 254, 240,226,
  214, 202, 190, 180, 170, 160, 151, 143, 135, 127, 120,113,
  107, 101, 95,  90,  85,  80,  75,  71,  67,  63,  60,  56,
  53,  50,  47,  45,  42,  40,  37,  35,  33,  31,  30,  28 );
var
  k:byte;
begin
  k:=0;
  while (Pitch[k]<>w) and (k<71) do inc(k);
  if Pitch[k]<>w then Pitch2Byte:=0 else Pitch2Byte:=k+1;
end;

Function SDS_Read_MOD(var f:file; LoadSamples:boolean):Pointer;
var m:pointer; {pointer to a module}
    a,b,c,instr,chn,r:word;
    sign:string[5];
    ms : record  { MOD sample }
           Name : array [0..21] of char;
           SizeDiv2 : Word;
           FineTune, Volume : Byte;
           LoopStartDiv2, LoopEndDiv2 : Word;
         end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    event : array [0..31] of array [0..3] of byte; {MOD events!}
    sev : array [0..31] of array [0..4] of byte;   {SDS events!}
    pattaux:pointer;
    OldPosition : longint;
begin {$i-}
  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_mod:=nil;
  OldPosition:=FilePos(f);
  action:=1; CallUserRoutine;
  seek(f,OldPosition+$438);
  sign[0]:=#4;
  blockread(f,sign[1],4,r);
  if r<4 then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  chn:=4; instr:=15;
  if sign='1CHN' then begin
    chn:=1; instr:=31;
  end;
  if sign='2CHN' then begin
    chn:=2; instr:=31;
  end;
  if sign='3CHN' then begin
    chn:=3; instr:=31;
  end;
  if sign='M.K.' then begin
    chn:=4; instr:=31;
  end;
  if sign='M!K!' then begin
    chn:=4; instr:=31;
  end;
  if (sign='FLT4') or (sign='4CHN') then begin
    chn:=4; instr:=31;
  end;
  if sign='5CHN' then begin
    chn:=5; instr:=31;
  end;
  if sign='6CHN' then begin
    chn:=6; instr:=31;
  end;
  if sign='7CHN' then begin
    chn:=7; instr:=31;
  end;
  if (sign='8CHN') or (sign='FLT8') or (sign='CD81') then begin
    chn:=8; instr:=31;
  end;
  if sign='9CHN' then begin
    chn:=9; instr:=31;
  end;
  if TTsgn(sign) then begin
    chn:=TTchn(sign); instr:=31;
  end;
  seek(f,OldPosition);
  BlockRead(f,ModuleName[1],20);
  ModuleName:=AsciiZ2String(ModuleName[1],20);
  Author:='';
  seek(f,OldPosition+20+instr*30);
  BlockRead(f,Entries,1,r);
  Patterns:=0;
  seek(f,OldPosition+20+instr*30+2);
  BlockRead(f,Order,128,r);
  for r:=0 to 127 do if Patterns<Order[r] then Patterns:=Order[r];
  inc(Patterns);
  samples:=instr;
  { allocate memory for module }
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; { not enough memory }
    exit
  end;
  { read instr. descriptors }
  seek(f,OldPosition+20);
  for a:=1 to instr do begin
     blockread(f,ms,30,r);
     if r<30 then begin
       SDS_UnLoad(m);
       loaderror:=2;
       exit
     end;

     sample[a]:=nil;
     if longint(Swap(ms.SizeDiv2))*2>2 then begin
       if LoadSamples then begin
         sample[a]:=sds_alloc(longint(swap(ms.SizeDiv2))*2 + 8);
         if sample[a]=nil then begin
           loaderror:=3; sds_unload(m); exit
         end;
       end;
     end;

     with ss do begin
       Volume:=ms.volume;
       C2Speed:=FineTune2Speed(ms.FineTune and $F);
       if UseGUS then Address:=longint(sample[a]) else Address:=seg(Sample[a]^);
       Size:=longint(swap(ms.sizediv2))*2;
       if Size<=2 then Size:=0;
       loopstart:=swap(ms.loopstartdiv2)*2;
       loopend:=swap(ms.loopenddiv2)*2;
       if loopend<=2 then
         loopend:=$FFFF
       else
         loopend:=loopstart+loopend{-1}; {???!!!}
     end;
     SamSize[a]:=ss.Size;
     SName[a]:=AsciiZ2String(ms.Name,22);
     move(ss,mem[seg(m^):ofs(m^)+sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
  end;
  sh.patterns:=patterns;
  sh.entries:=entries;
  sh.samples:=instr;
  sh.channels:=chn;
  Channels:=chn;
  sh.initgvolume:=$40;
  sh.initspeed:=6;
  sh.initbpm:=$7d; {125 BPM}
  sh.mastervolume:=$88;  { jumate' ... }
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF;
  for a:=0 to 31 do
    if (a mod 4 = 0) or (a mod 4 = 3) then sh.vri[a]:=0 {left} else sh.vri[a]:=$F; {right}
  move(sh,m^,sizeof(sh));
  for a:=0 to 255 do lperpatt[a]:=64; {default}
  move(lperpatt,mem[seg(m^):ofs(m^)+sizeof(sh)],patterns);
  move(order,mem[seg(m^):ofs(m^)+sizeof(sh)+patterns],entries);

  { allocate an aux pattern }
  pattaux:=malloc(5*Channels*64);

  { load patterns }
  seek(f,OldPosition+20+instr*30+130+((instr shr 4) shl 2));
  for a:=0 to patterns-1 do begin
    action:=2; actionPARA:=a; CallUserRoutine;
    pattern[a]:=malloc(5*chn*lperpatt[a]);  {alloc at max size, it will be reallocated}
    if pattern[a]=nil then begin
      sds_unload(m); loaderror:=3; exit
    end;
    pattsize[a]:=0;
    for b:=1 to lperpatt[a] do begin
      blockread(f,event,chn*4,r);
      if r<chn*4 then begin
        SDS_UnLoad(m);
        loaderror:=2; { bad mod/incorrect format }
        exit
      end;
      fillchar(sev,32*5,0);
      for c:=0 to chn-1 do begin
        {note}
        sev[c][0]:=Pitch2Byte(event[c][1]+((event[c][0] and $F) shl 8));
        {instrument}
        sev[c][1]:=(event[c][0] and $F0)+(event[c][2] shr 4);
        if sev[c][1]>instr then sev[c][1]:=0;
        {volume}
        if event[c][2] and $F = $C then begin
          sev[c][2]:=event[c][3];
          if sev[c][2]>$40 then sev[c][2]:=$40;
        end else sev[c][2]:=$C1;
        {effect+para}
        sev[c][3]:=MOD_Effect2Internal(event[c][2] and $F,event[c][3]);
        sev[c][4]:=MOD_Para2Internal(event[c][2] and $F,event[c][3]);
      end;
      move(sev,mem[seg(pattaux^):(word(b)-1)*Channels*5],channels*5);
    end;
    if not CompressPattern(pattaux,Channels,64,Pattern[a],PattSize[a]) then begin
      SDS_UnLoad(m); loaderror:=5; exit
    end;
  end;
  { kill pattaux }
  free(pattaux);

  { load samples }
  for a:=1 to instr do begin
    if SamSize[a]>2 then begin  {is a true sample data ?}
      action:=3; actionPARA:=a; CallUserRoutine;
      if LoadSamples then begin
        if Sample[a]<>nil then begin {skip unused instruments}
          r:=sds_ReadBlock(f, Sample[a], SamSize[a], 0);
          if r<SamSize[a] then begin
            SDS_UnLoad(m);
            loaderror:=2; {bad mod}
            exit
          end;
        end;
      end;
    end;
  end;

  fillchar(samtype,256,0); { MOD supports only 8-bit samples }
  SDS_Read_MOD:=m;
  loaderror:=0;
  seek(f,OldPosition);
end;

Function SDS_Load_MOD(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  if not openforinput(f,name) then begin
    loaderror:=1; {file not found}
    exit
  end;
  sds_load_mod:=sds_read_mod(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   MTM loader, revision 1.2                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function SDS_Read_MTM(var f:file; LoadSamples:boolean):Pointer;
var m,pattaux:pointer; {module}
    r,a,k,cpatternsize,pattoffs:word;
    b,ch,c,l:word;
    OldPosition, TracksPosition, ThisPosition, SmPos:longint;
    mth : record
            Magic    : array [0..2] of char; {MTM}
            Version  : byte;
            Name     : array [0..19] of char; {ASCIIZ}
            Tracks   : word;
            PatternsMinus1,
            EntriesMinus1 : Byte;
            TextSize : word;
            Samples  : byte;
            Attr     : byte;
            RowsPerPattern,
            Channels : byte;
            Panning  : array [0..31] of byte;  {0-15}
          end;
    mts : record
            Name     : array [0..21] of char;
            Size, LoopStart, LoopEnd : longint;
            FineTune, Volume : byte;
            Attr     : byte;
          end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    XorValue:byte;
    sgn : string;
    PSD : array [0..31] of word;  { Pattern Sequencing Data }
    cevent, event : array [0..31] of array [0..4] of byte; { SDS events ! }
    Track : array [0..$FF] of array [0..2] of byte;
    ssz : array [byte] of longint;
begin {$i-}
  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_mtm:=nil;

  OldPosition:=FilePos(f);

  action:=1; CallUserRoutine;
  blockread(f,mth,sizeof(mth),r);
  if r<sizeof(mth) then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  sgn:=AsciiZ2String(mth.Magic,3);
  if sgn<>'MTM' then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  Entries:=mth.EntriesMinus1 + 1;
  Patterns:=mth.PatternsMinus1 + 1;
  Samples:=mth.samples;
  {module name}
  move(mth.name[0],ModuleName[1],20);
  ModuleName:=AsciiZ2String(ModuleName[1],20);
  { unknown autor - MTM does not have such info }
  Author:='';
  {others}
  sh.patterns:=Patterns;
  sh.entries:=Entries;
  sh.samples:=Samples;
  {channels}
  sh.channels:=mth.Channels;
  Channels:=mth.Channels;
  sh.InitGVolume:=$40;  {this seems to be the MTM default gvolume}
  sh.InitSpeed:=6;      {is this the default initial speed ?}
  sh.InitBPM:=$7D;      { = 125 BPM = 50 ticks/sec  -> is this the default? }
  sh.MasterVolume:=$88;
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF; { all channels are initially ON }
  {VRI (pan positions)}
  move(mth.Panning,sh.VRI,32);
  {allocate pattaux}
  pattaux:=malloc(5*sh.channels*mth.RowsPerPattern);
  if pattaux=nil then begin
    loaderror:=9; exit
  end;
  {allocate memory for module}
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; exit
  end;
  move(sh,m^,sizeof(sh));
  {lines/pattern}
  fillchar(LPerPatt,patterns,mth.RowsPerPattern);  {default=64 lines/patt}
  move(lperpatt,mem[seg(m^):sizeof(sh)],patterns);
  {read instruments descriptors}
  fillchar(SamType,256,0);  { 8bit samples (default) }
  fillchar(Sample,256*4,0);
  for a:=1 to Samples do begin
    action:=3; actionpara:=a; CallUserRoutine;
    blockread(f,mts,sizeof(mts),r);
    if r<>sizeof(mts) then begin
      sds_unload(m); loaderror:=2; exit
    end;
    SName[a]:=AsciiZ2String(mts.Name,22);
    if (mts.Size<>0) then begin
      SamType[a]:=mts.Attr and 1;  {0=8bit, 1=16bit}
      ssz[a]:=mts.size;
      if longint(mts.size) div longint((1+SamType[a])) > longint($FFFF) then
        SamSize[a]:=$FFFE
      else
        SamSize[a]:=longint(mts.Size div (1+SamType[a])) and $FFFF;
      if LoadSamples then begin
        Sample[a]:=sds_alloc(SamSize[a]+8); { 8 extra bytes to prevent UltraClicks(tm)... }
        if (Sample[a]=nil) then begin
          sds_unload(m); loaderror:=3; exit
        end;
      end;
      with ss do begin
        Volume:=mts.volume;
        C2Speed:=Finetune2Speed(mts.finetune);
        if UseGUS then Address:=longint(Sample[a]) else Address:=seg(Sample[a]^);
        Size:=SamSize[a];
        LoopStart:=min(mts.LoopStart div (1+SamType[a]),$FFFE);
        LoopEnd:=min(mts.LoopEnd div (1+SamType[a]),$FFFE);
        if LoopEnd<=2 {!!!F@#$%^*!} then loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
    end else begin
      with ss do begin
        Volume:=0;
        C2Speed:=8363;
        Address:=0;
        Size:=0;
        loopstart:=0;
        loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      ssz[a]:=0;
      SamSize[a]:=0;
      Sample[a]:=nil;
      SamType[a]:=0;
    end;
  end;
  {read order}
  fillchar(order,256,$FF);
  blockread(f,order,128,r);
  for a:=Entries to 255 do order[a]:=$FF;
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);
  {next are the tracks (channel descriptors), but they will be skipped at
   this moment, since they'll be read and loaded during patterns reading}
  TracksPosition:=OldPosition+194+longint(mth.Samples)*37; {FilePos(f)}
  seek(f,TracksPosition+longint(mth.Tracks)*3*longint(mth.RowsPerPattern));
  {read and uncompress patterns}
  for a:=1 to patterns do begin
    action:=2; actionPARA:=a-1; CallUserRoutine;
    { read the track sequencing data for this pattern (32 words) }
    blockread(f,PSD,32*2,r);
    if r<32*2 then begin
      sds_unload(m); loaderror:=2; exit
    end;
    {alloc pattern at max size, it will be reallocated later}
    pattern[a-1]:=malloc(5*sh.channels*lperpatt[a-1]);
    if pattern[a-1]=nil then begin
     sds_unload(m); loaderror:=3; exit { not enough memory }
    end;
    {store this position, because we'll return here}
    ThisPosition:=FilePos(f);
    {init pattaux -> null pattern}
    fillchar(event[0],5,0); event[0][2]:=$C1;
    for k:=0 to sh.channels*LPerPatt[a-1]-1 do begin
      move(event[0],mem[seg(pattaux^):k*5],5);
    end;
    {load the tracks into this aux pattern}
    for k:=0 to mth.Channels-1 do begin
      if PSD[k]>0 {skip if empty track (0)} then begin
        {first, seek the track}
        seek(f,TracksPosition+longint(PSD[k]-1)*3*longint(LPerPatt[a-1]));
        {read it}
        blockread(f,Track,3*longint(LPerPatt[a-1]),r);
        {expand it into our aux pattern (with all necessarry conversions)}
        for l:=0 to LPerPatt[a-1]-1 do begin
          fillchar(event[0],5,0);
          {note (0=none, 1=C-0, 60=B-4)}
          event[0][0]:=Track[l][0] shr 2;
          {instrument number (0=none, 1=first,...)}
          event[0][1]:=((Track[l][0] and 3) shl 4) + (Track[l][1] shr 4);
          {volume}
          event[0][2]:=$C1;  {yet...}
          if Track[l][1] and $F = 12 {set volume} then begin
            event[0][2]:=Track[l][2];
            event[0][3]:=0;
            event[0][4]:=0;  {no effect, no para}
          end else begin
            {effect}
            event[0][3]:=MOD_Effect2Internal(Track[l][1] and $F, Track[l][2]);
            {parameter}
            event[0][4]:=MOD_Para2Internal(Track[l][1] and $F, Track[l][2]);
          end;
          { Now transfer the info into pattaux ... }
          move(event[0][0],mem[seg(pattaux^):l*sh.Channels*5+word(k)*5],5);
        end;
      end;
    end;
    if not CompressPattern(pattaux,Channels,LPerPatt[a-1],pattern[a-1],pattsize[a-1]) then begin
      SDS_UnLoad(m); loaderror:=5; exit
    end;
    {get back to the stored position}
    seek(f,ThisPosition);
  end;
  if not free(pattaux) then begin
    sds_unload(m); loaderror:=8; exit;
  end;
  {read text data (if exists)}
  if mth.TextSize>0 then begin
    if TextPtr<>nil then free(TextPtr);
    TextSize:=mth.TextSize;
    TextPtr:=malloc(TextSize+16);
    if TextPtr<>nil then begin  {load only if enough memory}
      action:=5; actionPARA:=0; CallUserRoutine;
      BlockRead(f,TextPtr^,TextSize,r);
      if r<>TextSize then begin
        sds_unload(m); loaderror:=2; exit;
      end;
    end;
  end;
  {read samples if necessarry}
  if LoadSamples then begin
    for a:=1 to Samples do begin
      if ssz[a]>0 then begin  {skip unused samples}
        action:=3; actionPARA:=a; CallUserRoutine;
        if SamType[a]=0 {8bit} then
          XorValue:=$80  {8 bit unsigned data}
        else
          XorValue:=1;   {(?) 16 bit signed data (?)}
        SmPos:=filepos(f);
        r:=sds_ReadBlock(f,Sample[a],SamSize[a],XorValue);
        if r<SamSize[a]*(1+SamType[a]) then begin
          sds_unload(m); loaderror:=2; exit;
        end;
        seek(f,SmPos+ssz[a]);
      end;
    end;
  end;
  fillchar(samtype,256,0);
  SDS_Read_MTM:=m;
  loaderror:=0;
  seek(f,OldPosition)
end;

Function SDS_Load_MTM(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  sds_load_mtm:=nil;
  if not openforinput(f,name) then begin
    LoadError:=1; { file not found }
    exit
  end;
  sds_load_mtm:=sds_read_mtm(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   S3M loader, revision 2.1                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function S3MNote(b:byte):Byte;
begin
  if (b=$FF) or (b=0) then
    S3MNote:=0 {empty note}
  else
    if b = 254 then
       S3MNote:=254 {note off}
    else
      if (b shr 4 in [2..7]) then
        S3MNote:=(((b shr 4)-2)*12) + (b and $f)+1
      else
        if (b shr 4 < 2) then
          S3MNote:=1  {unused octave}
        else
          S3MNote:=72; {the last high note}
end;

Function SDS_Read_S3M(var f:file; LoadSamples:boolean):Pointer;
var m,pattaux:pointer; {module}
    r,a,k,cpatternsize,pattoffs:word;
    b,ch,c,l:word;
    OldPosition:longint;
    s3h:record
          name:array[0..27] of char;
          EOFSign, SongType, Bug1, Bug2 : Byte;
          Orders, Samples, Patterns, Flags : Word;
          Version, SamplesType : Word;
          Sign : Array [1..4] of Char; {"SCRM"}
          GlobalVolume, InitialSpeed, InitialTempo, MasterVolume : Byte;
          Bug3:array[1..10] of char; { "xxxxxxxxxx" }
          Special : Word;
          ChannelSetting : Array [0..31] of byte;
        end;
    s3s:record
          InstrType : Byte;
          DosName : array[1..12] of char;
          MemSegEMS:Byte; MemSeg:word;
          DLen,DLoopStart,DLoopEnd : longint;
          Volume,Bug1,CompressionType,Flag : Byte;
          SpeedForMiddleC : longint;
          Bug2 : longint;
          GUSoffset, SBFlags : Word;
          LastUsed : longint;
          Name : Array[0..27] of Char;
          Sign : Array[1..4] of Char; {"SCRS"}
        end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    SOffset,POffset:array[byte] of word; {parapointers to samples/patterns}
    XorValue:byte;
    event,cevent:array[0..31] of array[0..4] of byte;
    sgn:string[10];
    lastcommand:array[0..31] of byte;
Function S3MCommand2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0..3,5..26:c:=b;
    4: if p=0 then begin
         c:=lastcommand[ch];
       end else begin
         if ((p and $F=$F) and (p shr 4<>0)) or
            ((p and $F0=$F0) and (p and $F<>0)) then c:=13 {fine sld...} else c:=4;
         lastcommand[ch]:=c;
       end;
  end;
  S3MCommand2Internal:=c;
end;
Function S3MPara2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0..3,5..26:c:=p;
    4: if ((p and $F=$F) and (p shr 4<>0)) then c:=p and $F0 else
       if ((p and $F0=$F0) and (p and $F<>0)) then c:=p and $F else c:=p;
  end;
  S3MPara2Internal:=c;
end;
Function RealChannel(b:byte):byte;
var c,rc:byte;
begin
  c:=0; rc:=0;
  while c<b do begin inc(c); if s3h.ChannelSetting[c]<>$ff then inc(rc); end;
  RealChannel:=rc;
end;
begin {$i-}
  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_s3m:=nil;
  fillchar(lastcommand,32,4);
  action:=1; CallUserRoutine;
  OldPosition:=FilePos(f);
  blockread(f,s3h,sizeof(s3h),r);
  if r<sizeof(s3h) then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  sgn:=AsciiZ2String(s3h.Sign,4);
  if sgn<>'SCRM' then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  Entries:=s3h.orders;
  Patterns:=s3h.patterns;
  Samples:=s3h.samples;
  {module name}
  move(s3h.name[0],ModuleName[1],28);
  ModuleName:=AsciiZ2String(ModuleName[1],28);
  { unknown autor - S3M does not have such info }
  Author:='';
  {others}
  sh.patterns:=s3h.patterns;
  sh.entries:=s3h.orders;
  sh.samples:=s3h.samples;
  {channels}
  sh.channels:=0;
  for a:=0 to 31 do if s3h.channelsetting[a]<>$FF then inc(sh.channels);
  Channels:=sh.Channels;
  sh.InitGVolume:=s3h.GlobalVolume;
  sh.InitSpeed:=s3h.InitialSpeed;
  sh.InitBPM:=s3h.InitialTempo;
  sh.MasterVolume:=$88;{Trunc(255*(s3h.MasterVolume and $7F)/127);}
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF; { should be fixed, S3M has ON/OFF status... }
  {VRI}
  for a:=0 to sh.channels-1 do if (a mod 2=0) then sh.vri[a]:=0 else sh.vri[a]:=$F;
  {allocate pattaux}
  pattaux:=malloc(5*sh.channels*64);{}
  if pattaux=nil then begin
    loaderror:=9; exit
  end;
  {allocate memory for module}
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; exit
  end;
  move(sh,m^,sizeof(sh));
  {lines/pattern}
  fillchar(LPerPatt,patterns,64);  {default=64 lines}
  move(lperpatt,mem[seg(m^):sizeof(sh)],patterns);
  {read order}
  blockread(f,order,s3h.orders,r);
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);
  {read parapointers to samples and patterns}
  for a:=1 to Samples do blockread(f,SOffset[a],2,r);
  for a:=0 to Patterns-1 do blockread(f,POffset[a],2,r);
  {read instruments descriptors}
  fillchar(SamType,256,0); { 8bit samples - S3M does not handle 16-bit samples }
  fillchar(sample,256*4,0);
  for a:=1 to Samples do begin
    action:=3; actionpara:=a; CallUserRoutine;
    seek(f,OldPosition+longint(SOffset[a])*16);
    blockread(f,s3s,sizeof(s3s),r);
    if r<>sizeof(s3s) then begin
      sds_unload(m); loaderror:=2; exit
    end;
    if s3s.InstrType = 2 then begin
      sds_unload(m); loaderror:=6; exit
    end;
    SName[a]:=AsciiZ2String(s3s.Name,28);
    if (s3s.dlen<>0) and (s3s.InstrType=1) then begin
      if (s3s.sign[4]<>'S') then begin
        sds_unload(m); loaderror:=6; exit
      end;
      samsize[a]:=(s3s.dlen div (1+SamType[a])) and $FFFF;
      if LoadSamples then begin
        Sample[a]:=sds_alloc(samsize[a]+8); { 8 extra bytes to prevent UltraClicks(tm)... }
        if (Sample[a]=nil) then begin
          sds_unload(m); loaderror:=3; exit
        end;
      end;
      with ss do begin
        Volume:=s3s.volume;
        C2Speed:=s3s.speedformiddlec;
        if UseGUS then Address:=longint(Sample[a]) else Address:=seg(Sample[a]^);
        Size:=s3s.dlen div (1+SamType[a]);
        loopstart:=s3s.dloopstart div (1+SamType[a]);
        loopend:=s3s.dloopend div (1+SamType[a]);
        if s3s.Flag and 1 = 0 then
          loopend:=$FFFF
        else
          if loopend=0 then
            loopend:=$FFFF
          else
            {dec(loopend)};
      end;
      if s3s.CompressionType<>0 then begin
        sds_unload(m); loaderror:=7; exit
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SOffset[a]:=s3s.MemSeg;
      seek(f,OldPosition+longint(s3s.MemSeg)*16);
      if s3h.SamplesType and 2 = 2 then
        XorValue:=$80
      else
        XorValue:=0;
      if LoadSamples then begin
        r:=sds_ReadBlock(f,Sample[a],SamSize[a],XorValue);
        if r<SamSize[a]*(1+SamType[a]) then begin
          sds_unload(m); loaderror:=2; exit;
        end;
      end;
    end else begin
      with ss do begin
        Volume:=0;
        C2Speed:=8363;
        Address:=0;
        Size:=0;
        loopstart:=0;
        loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SamSize[a]:=0;
      Sample[a]:=nil;
    end;
  end;
  {read and uncompress patterns}
  for a:=1 to patterns do begin
    action:=2; actionPARA:=a-1; CallUserRoutine;
    pattern[a-1]:=malloc(5*sh.channels*64);  {alloc at max size, it will be reallocated}
    if pattern[a-1]=nil then begin
     sds_unload(m); loaderror:=3; exit
    end;
    seek(f,OldPosition+longint(POffset[a-1])*16);
    blockread(f,CPatternSize,2,r);
    {init pattaux}
    fillchar(event[0],5,0); event[0][2]:=$C1;
    for k:=0 to sh.channels*64-1 do begin
      move(event[0],mem[seg(pattaux^):k*5],5);
    end;
    if (CPatternSize>2{64?}) and (CPatternSize<=5*32*64+2) then begin
      {this condition is not documented, ST 3.21 sets the CPatternSize's
       value to 26948 istead of 0 when the pattern is in fact empty! - maybe
       a bug in ST3 ?}
      {decompress ST3 pattern into pattaux}
      ResetBuffer;
      l:=0;
      repeat
        b:=ReadByte(f);
        if b=0 then { end of row }
          inc(l)
        else begin
          ch:=RealChannel(b and $1f);
          fillchar(event[0],5,0); event[0][2]:=$C1;
          if b and 32 = 32 then begin { Note and instrument ... }
            event[0][0]:=S3MNote(ReadByte(f));
            event[0][1]:=ReadByte(f);
          end;
          if b and 64 = 64 then begin { Volume ... }
            event[0][2]:=ReadByte(f) or $80;
          end; { ... else is the default: 41h/0C1h }
          if b and 128 = 128 then begin { Command and info ... }
            cevent[0][3]:=ReadByte(f);
            cevent[0][4]:=ReadByte(f);
            event[0][3]:=S3MCommand2Internal(cevent[0][3],cevent[0][4]);
            event[0][4]:=S3MPara2Internal(cevent[0][3],cevent[0][4]);
          end;
          { Now transfer the info into pattaux ... }
          move(event[0][0],mem[seg(pattaux^):l*sh.Channels*5+word(ch)*5],5);
        end;
      until l>=64;
    end;
    if not CompressPattern(pattaux,Channels,64,pattern[a-1],pattsize[a-1]) then begin
      SDS_UnLoad(m); loaderror:=5; exit
    end;
  end;
  if not free(pattaux) then begin
    sds_unload(m); loaderror:=8; exit;
  end;
  SDS_Read_S3M:=m;
  loaderror:=0;
  seek(f,OldPosition);
end;

Function SDS_Load_S3M(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  sds_load_s3m:=nil;
  if not openforinput(f,name) then begin
    LoadError:=1; { file not found }
    exit
  end;
  sds_load_s3m:=sds_read_s3m(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   PTM loader, revision 1.1                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function PTMNote(b:byte):Byte;
const sds_octave = 25;  {octave start in sds}
begin
  if (b=$FF) or (b=0) then
    PTMNote:=0 {empty note}
  else
    if b = 254 then
       PTMNote:=254 {note off}
    else
      if (b in [sds_octave..(sds_octave+12*6 - 1)]) then
        PTMNote:=b - sds_octave + 1
      else
        if (b < sds_octave) then
          PTMNote:=1  {unused octave}
        else
          PTMNote:=72; {the last high note}
end;

Function SDS_Read_PTM(var f:file; LoadSamples:boolean):Pointer;
var m,pattaux:pointer; {module}
    r,a,k,cpatternsize,pattoffs:word;
    b,ch,c,l:word;
    OldPosition, ThisPos:longint;
    pth:record
          name:array[0..27] of char;
          EOFSign : Byte;
          FileVersion : word;
          reserved1 : byte;
          Orders, Samples, Patterns, Channels, Flags : Word;
          reserved2 : word;
          Sign : Array [1..4] of Char; {"PTMF"}
          reserved3 : array [0..15] of byte;
          vri : Array [0..31] of byte;
        end;
    pts:record
          InstrType : Byte;
          DosName : array[1..12] of char;
          Volume : byte;
          SpeedForMiddleC : word;
          MemSeg:word;
          SampleOffset : longint;
          DLen,DLoopStart,DLoopEnd : longint;
          gus_shit : array[0..2] of longint;
          gusloop,reserved : byte;
          Name : Array[0..27] of Char;
          Sign : Array[1..4] of Char; {"PTMS"}
        end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    POffset:array[byte] of word; {parapointers to patterns}
    SOffset:array[byte] of longint; {parapointers to samples}
    XorValue:byte;
    event,cevent:array[0..31] of array[0..4] of byte;
    sgn:string[10];
    lastcommand:array[0..31] of byte;
Function PTMCommand2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0: if p=0 then c:=0 else c:=10; { Arpeggio }
    1: { Portamento up } c:=6;
    2: { Portamento down } c:=5;
    3: { ToNote/Slide to pitch } c:=7;
    4: { Vibrato } c:=8;
    5: { Tone portamento + vol slide } c:=12;
    6: { Vibrato + vol slide } c:=11;
    7: { Tremolo } c:=18;
    8: { Amiga 8xy, unused } c:=24;
    9: { Set sample offset } c:=15;
    10: { Slide volume } c:=4;
    11: { Jump } c:=2;
    12: { set voice volume, replaced} c:=0;
    13: { Cancel } c:=3;
    15: { Set tempo/set BPM } if p<$20 then c:=1 {speed} else c:=20; {bpm}
    14: begin { Extended }
      case (p shr 4) of
        0 : { Set filter } c:=19;
        1 : { FineSlide up } c:=6;
        2 : { FineSlide down } c:=5;
        3 : { Glissando control } c:=19;
        4 : { Set vibrato waveform } c:=19;
        5 : { Set finetune } c:=19;
        6 : { Set/Jump to loop } c:=19;
        7 : { Set tremolo waveform } c:=19;
        8 : { Set panning } c:=19;
        9 : { Retrig note } c:=17;
        10: { Fine volumeslide up } c:=13;
        11: { Fine volumeslide down } c:=13;
        12: { Note cut } c:=19;
        13: { Note delay } c:=19;
        14: { Pattern delay } c:=19;
        15: { Invert loop } c:=0; {not used}
      end;
    end;
    16: {set global volume} c:=22;
    17: {multiretrig} c:=17;
    18: {fine vibrato} c:=21;
    else c:=0; {the rest are unsupported}
  end;
  PTMCommand2Internal:=c;
end;
Function PTMPara2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0..9,11,13,15..18: c:=p; {all eff}
    10: if p and $F0 <> 0 then c:=p and $F0 else c:=p and $F;
    14: begin { Extended }
      case (p shr 4) of
        0 : { Set filter            } c:=p and $f;
        1 : { FineSlide up          } c:=$F0 or (p and $f);
        2 : { FineSlide down        } c:=$F0 or (p and $f);
        3 : { Glissando control     } c:=$10 or (p and $f);
        4 : { Set vibrato waveform  } c:=$30 or (p and $f);
        5 : { Set finetune          } c:=$20 or (p and $f);
        6 : { Set/Jump to loop      } c:=$B0 or (p and $f);
        7 : { Set tremolo waveform  } c:=$40 or (p and $f);
        8 : { Set panning           } c:=$80 or (p and $F);
        9 : { Retrig note           } c:=p and $f;
        10: { Fine volumeslide up   } c:=(p and $f) shl 4;
        11: { Fine volumeslide down } c:=(p and $f);
        12: { Note cut              } c:=$C0 or (p and $f);
        13: { Note delay            } c:=$D0 or (p and $f);
        14: { Pattern delay         } c:=$E0 or (p and $f);
        15: { Invert loop           } c:=0; {not used}
      end;
    end;
    else c:=0;
  end;
  PTMPara2Internal:=c;
end;
begin {$i-}

  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_ptm:=nil;
  fillchar(lastcommand,32,4);
  action:=1; CallUserRoutine;

  OldPosition:=FilePos(f);

  {read header}
  blockread(f,pth,sizeof(pth),r);
  if r<sizeof(pth) then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  sgn:=AsciiZ2String(pth.Sign,4);
  if sgn<>'PTMF' then begin
    loaderror:=2; { incorrect format }
    exit
  end;

  Entries:=pth.orders;
  Patterns:=pth.patterns;
  Samples:=pth.samples;
  Channels:=pth.Channels;

  {module name}
  move(pth.name[0],ModuleName[1],28);
  ModuleName:=AsciiZ2String(ModuleName[1],28);
  { unknown autor - PTM does not have such info }
  Author:='';

  {others}
  sh.patterns:=pth.patterns;
  sh.entries:=pth.orders;
  sh.samples:=pth.samples;
  sh.channels:=pth.Channels;
  sh.InitGVolume:=$40;           {ptm's default}
  sh.InitSpeed:=6;               {ptm's default}
  sh.InitBPM:=$7d;               {ptm's default}
  sh.MasterVolume:=$88;          {ptm's default}
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF;
  move(pth.vri,sh.vri,32);       {Voice Repartition Info}

  {allocate pattaux}
  pattaux:=malloc(5*sh.channels*64);{}
  if pattaux=nil then begin
    loaderror:=9; exit
  end;

  {allocate memory for module}
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; exit
  end;
  move(sh,m^,sizeof(sh));

  {lines/pattern}
  fillchar(LPerPatt,patterns,64);  {default=64 lines}
  move(lperpatt,mem[seg(m^):sizeof(sh)],patterns);

  {read order}
  blockread(f,order,256,r);
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);

  {read parapointers to patterns}
  blockread(f,POffset,128*2,r);

  {read instruments descriptors}
  fillchar(SamType,256,0);
  fillchar(sample,256*4,0);
  for a:=1 to Samples do begin
    action:=3; actionpara:=a; CallUserRoutine;
    blockread(f,pts,sizeof(pts),r);
    if r<>sizeof(pts) then begin
      sds_unload(m); loaderror:=2; exit
    end;
    if pts.InstrType and $10 = $10 {16bit} then SamType[a]:=1;
    SName[a]:=AsciiZ2String(pts.Name,28);
    if (pts.dlen<>0) and (pts.InstrType and 3 = 1) then begin
      {if (pts.sign[4]<>'S') then begin
        sds_unload(m); loaderror:=6; exit
      end; {not all ptm versions have this signature!}
      samsize[a]:=min($FFFF,pts.dlen div (1+SamType[a]));
      if LoadSamples then begin
        Sample[a]:=sds_alloc(samsize[a]+8); { 8 extra bytes to prevent UltraClicks(tm)... }
        if (Sample[a]=nil) then begin
          sds_unload(m); loaderror:=3; exit
        end;
      end;
      with ss do begin
        Volume:=pts.volume;
        C2Speed:=pts.speedformiddlec;
        if C2Speed=0 then C2Speed:=8363;
        if UseGUS then
          Address:=longint(Sample[a])
        else
          Address:=seg(Sample[a]^);
        Size:=SamSize[a];
        loopstart:=min(pts.dloopstart div (1+SamType[a]),$FFFE);
        loopend:=min(pts.dloopend div (1+SamType[a]),$FFFE);
        if pts.InstrType and 4 = 0 then
          loopend:=$FFFF
        else
          if loopend=0 then loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SOffset[a]:=pts.SampleOffset;
      if LoadSamples then begin
        XorValue:=SamType[a] or $40; {bit 6="signed delta format"!}
        ThisPos:=filepos(f);
        seek(f,OldPosition+SOffset[a]);
        r:=sds_ReadBlock(f,Sample[a],SamSize[a],XorValue);
        if r<>SamSize[a]*(1+SamType[a]) then begin
          sds_unload(m); loaderror:=2; exit;
        end;
        seek(f,ThisPos);
      end;
    end else begin
      with ss do begin
        Volume:=0;
        C2Speed:=8363;
        Address:=0;
        Size:=0;
        loopstart:=0;
        loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SamSize[a]:=0;
      Sample[a]:=nil;
    end;
  end;

  {read and uncompress patterns}
  for a:=1 to patterns do begin
    action:=2; actionPARA:=a-1; CallUserRoutine;

    pattern[a-1]:=malloc(5*sh.channels*64);  {alloc at max size, it will be reallocated}
    if pattern[a-1]=nil then begin
     sds_unload(m); loaderror:=3; exit
    end;

    seek(f,OldPosition+longint(POffset[a-1])*16);

    {init pattaux}
    fillchar(event[0],5,0); event[0][2]:=$C1;
    for k:=0 to sh.channels*64-1 do begin
      move(event[0],mem[seg(pattaux^):k*5],5);
    end;

    if a<patterns then
      CPatternSize:=longint(POffset[a]-POffset[a-1]) * 16
    else
      CPatternSize:=SOffset[0]-longint(POffset[a-1])*16;

    if (CPatternSize>0{64?}) and (CPatternSize<=5*32*64+2) then begin
      {decompress PTM pattern into pattaux}
      ResetBuffer;
      l:=0;
      repeat
        b:=ReadByte(f);
        if b=0 then { end of row }
          inc(l)
        else begin
          ch:=b and $1f;  {channel #}
          fillchar(event[0],5,0); event[0][2]:=$C1;
          if b and $20 = $20 then begin { Note and instrument ... }
            event[0][0]:=PTMNote(ReadByte(f));  {note}
            event[0][1]:=ReadByte(f);           {instr}
          end;
          if b and $40 = $40 then begin { Command and info ... }
            cevent[0][3]:=ReadByte(f);
            cevent[0][4]:=ReadByte(f);
            if cevent[0][3] = 12 then event[0][2]:=cevent[0][4] or $80;
            event[0][3]:=PTMCommand2Internal(cevent[0][3],cevent[0][4]);
            event[0][4]:=PTMPara2Internal(cevent[0][3],cevent[0][4]);
          end;
          if b and $80 = $80 then begin { Volume ... }
            event[0][2]:=ReadByte(f);
            event[0][2]:=event[0][2] or $80;
          end; { ... else is the default: 41h/0C1h }
          { Now transfer the info into pattaux ... }
          move(event[0][0],mem[seg(pattaux^):l*sh.Channels*5+word(ch)*5],5);
        end;
      until l>=64;
    end;
    if not CompressPattern(pattaux,Channels,64,pattern[a-1],pattsize[a-1]) then begin
      SDS_UnLoad(m); loaderror:=5; exit
    end;
  end;
  if not free(pattaux) then begin
    sds_unload(m); loaderror:=8; exit;
  end;
  SDS_Read_PTM:=m;
  loaderror:=0;
  fillchar(SamType,256,0);
  seek(f,OldPosition);
end;

Function SDS_Load_PTM(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  sds_load_ptm:=nil;
  if not openforinput(f,name) then begin
    LoadError:=1; { file not found }
    exit
  end;
  sds_load_ptm:=sds_read_ptm(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   STM loader, revision 1.1                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function SDS_Read_STM(var f:file; LoadSamples:boolean):Pointer;
var m,pattaux:pointer; {module}
    r,a,k,cpatternsize,pattoffs:word;
    b,ch,c,d,l:word;
    OldPosition, CPosition:longint;
    sth : record
            Name     : array [0..19] of char;
            TrkName  : array [0..7] of char;
            EOF_id   : byte;
            FileType : byte;  {1=song, 2=module}
            Version  : word;
            Tempo,
            Patterns,
            GVolume  : byte;
            Reserv1  : array [0..12] of byte;
          end;
    sts : record
            Name     : array [0..11] of char;
            Unused1,
            Unused2  : byte;
            Unused3  : word;
            Size, LoopStart, LoopEnd : word;
            Volume,
            Unused4  : byte;
            C2Speed  : word;
            Unused5  : longint;
            Size16   : word;
          end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    XorValue:byte;
    sgn : string;
    cevent, event : array [0..31] of array [0..4] of byte; { SDS events ! }
    sev : array [0..3] of byte;
Function STMCommand2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    1: { "tempo"=speed } c:=1;
    2: { jump to pattern } c:=2;
    3: { cancel } c:=3;
    4: { slide volume } c:=4;
    5: { portamento down } c:=5;
    6: { portamento up } c:=6;
    7: { tone portamento } c:=7;
    8: { vibrato } c:=8;
    9: { Tremor? } c:=9;
    10: { arpeggio } c:=10;
    11: { vibrato+volSlide? } c:=11;
    12: { tonePorta+volSlide? } c:=12;
    13: { fineslide vol } c:=13;
    14: {N/A}
    else c:=0;
  end;
  STMCommand2Internal:=c;
end;
Function STMPara2Internal(b,p:byte):Byte;
var c:byte;
begin
  case b of
    0: c:=0;
    6: { Portamento up } begin
      if p shr 4=$f then c:=p and $f { fineslide up } else
        if p shr 4 = $e then c:=p and $f { extrafine slide up } else
          c:=p;  { simple slide up }
    end;
    5: { Portamento down } begin
      if p shr 4=$f then c:=p and $f { fineslide down } else
        if p shr 4 = $e then c:=p and $f { extrafine slide down } else
          c:=p;  { simple slide down }
    end;
    7: { ToNote/Slide to pitch }c:=p;
    8: { Vibrato } c:=p;
    4: { Slide volume } begin
      if p shr 4 = $f then
        c:=p and $f { fine slide vol down }
      else
        if p and $f = $f then
          c:=p shr 4 { fine slide vol up }
        else
          if p and $f <> 0 then c:=p and $f else c:=p shr 4; { slide vol down/up }
    end;
    2: { Jump } c:=p;
    3: { Cancel } c:=p;
    1: { Set speed/tempo } c:=p shr 4;
    12: { Tone portamento + vol slide } c:=p;
    11: { Vibrato + vol slide } c:=p;
    9: { Tremor } c:=p;
    15: { Set sample offset } c:=p;
    10: { arpeggio } c:=p;
    13: { fineslide vol } c:=p;
    else c:=0;
  end;
  STMPara2Internal:=c;
end;
begin {$i-}
  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_stm:=nil;

  OldPosition:=FilePos(f);

  action:=1; CallUserRoutine;
  blockread(f,sth,sizeof(sth),r);
  if r<sizeof(sth) then begin
    loaderror:=2; { incorrect format }
    exit
  end;

  sgn:=AsciiZ2String(sth.Reserv1[3],4);
  if (sgn<>'XXXX') or (sth.FileType<>2) then begin
    loaderror:=2; { incorrect format }
    exit
  end;
  Patterns:=sth.Patterns;
  Samples:=31;  {!?always?!}
  {module name}
  move(sth.name[0],ModuleName[1],20);
  ModuleName:=AsciiZ2String(ModuleName[1],20);
  { unknown autor - the original STM does not have such info }
  Author:='';
  {others}
  sh.patterns:=Patterns;
  sh.samples:=Samples;
  sh.channels:=4;
  Channels:=4;
  sh.InitGVolume:=sth.gvolume;
  sh.InitSpeed:=sth.Tempo shr 4;
  sh.InitBPM:=$7D;
  sh.MasterVolume:=$88;
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF;    { all channels are initially ON }
  {VRI (pan positions)}
  sh.VRI[0]:=0;    {left}
  sh.VRI[1]:=$F;   {right}
  sh.VRI[2]:=$F;   {right}
  sh.VRI[3]:=0;    {left}
  {allocate pattaux}
  pattaux:=malloc(5*4*64+16);  {1280 bytes + something}
  if pattaux=nil then begin
    loaderror:=9; exit
  end;
  {keep the actual position in mind}
  CPosition:=filepos(f);
  {seek order and load it}
  seek(f,CPosition+31*sizeof(sts));
  fillchar(order,256,$FF);
  blockread(f,order,128,r);
  entries:=0;
  for a:=0 to 127 do if order[a]<99 then inc(entries) else order[a]:=$FF;
  sh.entries:=entries;
  {get back}
  seek(f,CPosition);
  {allocate memory for module}
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; exit
  end;
  move(sh,m^,sizeof(sh));
  {move lines/pattern}
  fillchar(LPerPatt,256,64);  {default=64 lines/patt}
  move(lperpatt,mem[seg(m^):sizeof(sh)],patterns);
  {move order}
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);
  {read instruments descriptors}
  fillchar(SamType,256,0);  { 8bit samples (default) }
  fillchar(Sample,256*4,0);
  for a:=1 to Samples do begin
    action:=3; actionpara:=a; CallUserRoutine;
    blockread(f,sts,sizeof(sts),r);
    if r<>sizeof(sts) then begin
      sds_unload(m); loaderror:=2; exit
    end;
    SName[a]:=AsciiZ2String(sts.Name,12);
    if (sts.Size<>0) then begin
      SamType[a]:=0;  {0=8bit, 1=16bit}
      SamSize[a]:=sts.Size;
      if LoadSamples then begin
        Sample[a]:=sds_alloc(SamSize[a]+8); { 8 extra bytes to prevent UltraClicks(tm)... }
        if (Sample[a]=nil) then begin
          sds_unload(m); loaderror:=3; exit
        end;
      end;
      with ss do begin
        Volume:=sts.volume;
        C2Speed:=sts.C2Speed;
        if UseGUS then Address:=longint(Sample[a]) else Address:=seg(Sample[a]^);
        Size:=sts.Size;
        LoopStart:=sts.LoopStart;
        LoopEnd:=sts.LoopEnd;
        if (LoopEnd<=2) or (LoopStart=$FFFF) {?} then loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
    end else begin
      with ss do begin
        Volume:=0;
        C2Speed:=8363;
        Address:=0;
        Size:=0;
        loopstart:=0;
        loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SamSize[a]:=0;
      Sample[a]:=nil;
      SamType[a]:=0;
    end;
  end;
  {skip order}
  seek(f,filepos(f)+128);
  {read and uncompress patterns}
  for a:=1 to patterns do begin
    action:=2; actionPARA:=a-1; CallUserRoutine;
    {alloc pattern at max size, it will be reallocated later}
    pattern[a-1]:=malloc(5*4*64);
    if pattern[a-1]=nil then begin
      sds_unload(m); loaderror:=3; exit { not enough memory }
    end;
    {init pattaux -> null pattern}
    fillchar(event[0],5,0); event[0][2]:=$C1;
    for k:=0 to 4*LPerPatt[a-1]-1 do begin
      move(event[0],mem[seg(pattaux^):k*5],5);
    end;
    for k:=0 to 4*64-1 do begin
      {compute line (row) and channel}
      l:=k div 4; c:=k and 3;
      {default event}
      fillchar(event[0][0],5,0);
      event[0][2]:=$C1;
      {read event}
      blockread(f,sev,4,r);
      if r<4 then begin
        sds_unload(m); loaderror:=2; exit
      end;
      {unpack data into event[0]}
      if sev[0]=251 then begin  {all 0}
        event[0][2]:=$80;
        seek(f,filepos(f)-3);
      end;
      if sev[0]=252 then begin  {noteoff?}
        event[0][0]:=$FE;
        seek(f,filepos(f)-3);
      end;
      if sev[0]=253 then begin  {empty event}
        event[0][2]:=$C1;
        seek(f,filepos(f)-3);
      end;
      if not (sev[0] in [251,252,253]) then begin
        {note/octave}
        b:=sev[0] and $F; {note}
        d:=sev[0] shr 4;  {octave}
        if (b=$F) or (d=$F) then
          event[0][0]:=0
        else
          event[0][0]:=1 + d*12+b;
        {instrument}
        event[0][1]:=(sev[1] shr 3);
        {volume}
        event[0][2]:=(sev[1] and 7) or ((sev[2] and $F0) shr 1);
        if event[0][2]=65 then event[c][2]:=$C1;
        {eff+para}
        event[0][3]:=STMCommand2Internal (sev[2] and $F, sev[3]);
        event[0][4]:=STMPara2Internal    (sev[2] and $F, sev[3]);
      end;
      {write event into pattaux}
      move(event[0],mem[seg(pattaux^):5*k],5);
    end;
    if not CompressPattern(pattaux,Channels,64,pattern[a-1],pattsize[a-1]) then begin
      SDS_UnLoad(m); loaderror:=5; exit
    end;
  end;
  if not free(pattaux) then begin
    sds_unload(m); loaderror:=8; exit;
  end;
  {read samples if necessarry}
  if LoadSamples then begin
    for a:=1 to Samples do begin
      if SamSize[a]>0 then begin  {skip unused samples}
        action:=3; actionPARA:=a; CallUserRoutine;
        r:=sds_ReadBlock(f,Sample[a],SamSize[a],0);
        if r<SamSize[a]*(1+SamType[a]) then begin
          sds_unload(m); loaderror:=2; exit;
        end;
      end;
    end;
  end;
  SDS_Read_STM:=m;
  loaderror:=0;
  seek(f,OldPosition);
end;

Function SDS_Load_STM(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  sds_load_stm:=nil;
  if not openforinput(f,name) then begin
    LoadError:=1; { file not found }
    exit
  end;
  sds_load_stm:=sds_read_stm(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   ULT loader, revision 1.4                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

const
    ExpVol : array [byte] of byte = (
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,
                $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$1,
                $1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$2,
                $2,$2,$2,$2,$2,$2,$2,$2,$3,$3,$3,$3,$3,$3,$3,$4,
                $4,$4,$4,$4,$5,$5,$5,$5,$6,$6,$6,$6,$7,$7,$7,$8,
                $8,$8,$9,$9,$A,$A,$B,$B,$C,$C,$D,$D,$E,$E,$F,$10,
                $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,
                $1C,$1D,$1E,$20,$21,$23,$25,$27,$29,$2B,$2D,$2F,
                $31,$33,$35,$37,$39,$3B,$3D,$3E,$3E,$3E,$3E,$3E,
                $3E,$3E,$3E,$3E,$3F,$3F,$3F,$3F,$3F,$40,$40,$40 );

Function SDS_Read_ULT(var f:file; LoadSamples:boolean):Pointer;
var m,pattaux:pointer; {module}
    r,a,k,row,pattoffs:word;
    b,c,l,p:word;
    OldPosition, ThisPosition:longint;
    uh : record
            Magic    : array [0..14] of char; {'MAS_UTrack_V00x'}
            Name     : array [0..31] of char; {ASCIIZ}
            JumpVal  : byte;
         end;
    us : record
            Name     : array [0..31] of char;
            DosName  : array [0..11] of char;
            LoopStart, LoopEnd : longint;
            SizeStart, SizeEnd : longint;
            Volume, BidiLoop : byte;
            FineTune : word;
         end;
    ss:SDMInt_InstType;
    sh:SDMInt_HeadType;
    lperpatt : array [byte] of byte;
    XorValue:byte;
    sgn : string;
    cevent, event : array [0..31] of array [0..4] of byte; { SDS events ! }
    Ver, Chn : byte;
    c2s:word;
    sz, ls, le : longint;
    uRLE : record
             RepFlag,
             RepCount : byte
           end;
    uev  : array [0..4] of byte;
Function ULTCmd(b,p1,p2:byte):Byte;
var c,e,p:byte;
begin
  c:=0;
  case b of
    $a4: {vibrato+volSlide} c:=11;
    $4a: {volSlide+vibrato} c:=11;
    $3a: {tonePrt+volSlide} c:=12;
    $a3: {volSlide+tonePrt} c:=12;
    $99: {fine smpoffset} c:=15;
    else {priorities...}
      if b and $F  = $D  then c:=3 else
      if b and $F  = $F  then if p2<$30 then c:=1 else c:=20 else
      if b and $F0 = $D0 then c:=3 else
      if b and $F0 = $F0 then if p1<$30 then c:=1 else c:=20 else begin
        e:=0; p:=0;
        if (b and $F0=0) and (p1<>0) then begin
          e:=0; {arpeggio} p:=p1;
        end else
        if (b and $F=0) and (p2<>0) then begin
          e:=0; {arpeggio} p:=p2;
        end else
        if (b and $F0<>0) and (b and $F=0) then begin
          e:=b shr 4; p:=p1;
        end else
        if (b and $F<>0) and (b shr 4=0) then begin
          e:=b and $F; p:=p2;
        end else
        begin
          e:=b shr 4; p:=p1; {sorry, only first parameter if two non-zero...}
        end;
        case e of
          0: {arpeggio} if p<>0 then c:=10;
          1: {porta up} c:=6;
          2: {porta dn} c:=5;
          3: {toneport} c:=7;
          4: {vibrato} c:=8;
          5: {UT special, not supported} c:=0;
          7: {tremolo} c:=18;
          9: {smpOffset} c:=15;  {fine smpOffset not supported}
          $a: {sldVolume} c:=4;
          $b: {panning} c:=19;
          $c: {change volume, can't be} c:=0;
          $d: {breakPatt} c:=3;
          $e: {extended}
          case (p shr 4) of
            0: {UT vibratoValue, not supported} c:=0;
            1: {fineSldUp} c:=6;
            2: {fineSldDn} c:=5;
            8: {trackDelay} c:=19;
            9: {retrig} c:=17;
            $a: {fineVolSldUp} c:=13;
            $b: {fineVolSldDn} c:=13;
            $c: {cutNote} c:=19;
            $d: {delayNote} c:=19;
            else c:=0;
          end;
          $f: if p<=$2f then c:=1 {speed} else c:=20; {bpm}
          else c:=0;
        end; {case e}
      end; {if b}
  end; {case b}
  ULTCmd:=c;
end;
Function ULTPara(b,p1,p2:byte):Byte;
var c,e,p:byte;
begin
  c:=0;
  case b of
    $a4: {vibrato+volSlide} c:=p1;
    $4a: {volSlide+vibrato} c:=p2;
    $3a: {tonePrt+volSlide} c:=p2;
    $a3: {volSlide+tonePrt} c:=p1;
    $99: {fine smpoffset} c:=byte((word(p1)*256+word(p2)) shr 6);
    else {priorities...}
      if b and $F  = $D  then c:=p2 else
      if b and $F  = $F  then c:=p2 else
      if b and $F0 = $D0 then c:=p1 else
      if b and $F0 = $F0 then c:=p1 else begin
        e:=0; p:=0;
        if (b and $F0=0) and (p1<>0) then begin
          e:=0; {arpeggio} p:=p1;
        end else
        if (b and $F=0) and (p2<>0) then begin
          e:=0; {arpeggio} p:=p2;
        end else
        if (b and $F0<>0) and (b and $F=0) then begin
          e:=b shr 4; p:=p1;
        end else
        if (b and $F<>0) and (b shr 4=0) then begin
          e:=b and $F; p:=p2;
        end else
        begin
          e:=b shr 4; p:=p1; {sorry, only first parameter...}
        end;
        case e of
          0: {arpeggio} c:=p;
          1: {porta up} c:=p;
          2: {porta dn} c:=p;
          3: {toneport} c:=p;
          4: {vibrato} c:=p;
          5: {UT special, not supported} c:=0;
          7: {tremolo} c:=p;
          9: {smpOffset} c:=p shl 2;  {fine smpOffset not supported}
          $a: {sldVolume} if p and $F0 <> 0 then c:=p and $F0 else c:=p and $F;
          $b: {panning} c:=$80 or (p and $F);
          $c: {change volume, can't be} c:=0;
          $d: {breakPatt} c:=p;
          $e: {extended}
          case (p shr 4) of
            0: {UT vibratoValue, not supported} c:=0;
            1: {fineSldUp} c:=$F0 or (p and $f);
            2: {fineSldDn} c:=$F0 or (p and $f);
            8: {trackDelay} c:=$E0 or (p and $f);
            9: {retrig} c:=p and $F;
            $a: {fineVolSldUp} c:=(p and $f) shl 4;
            $b: {fineVolSldDn} c:=(p and $f);
            $c: {cutNote} c:=$C0 or (p and $f);
            $d: {delayNote} c:=$D0 or (p and $f);
            else c:=0;
          end;
          $f: c:=p;
          else c:=0;
        end; {case e}
      end; {if b}
  end; {case b}
  ULTPara:=c;
end;
function UTReserved:boolean;
begin
  UTReserved:=(uev[2] in [$11,$22,$33,$44,$66,$77,$88,$AA,$BB,$CC,$DD]) or
              ((uev[2] and $F) in [6,8]) or
              ((uev[2] shr 4) in [6,8]);
end;
Procedure ConvertEvent;
begin
  { init first }
  fillchar(event,5,0);
  { note }
  event[0][0]:=uev[0];
  if event[0][0]>72 then event[0][0]:=72; {for Ver >= 1.5 }
  { sample }
  event[0][1]:=uev[1];
  { volume }
  event[0][2]:=$C1;
  if (uev[2] and $F0=$C0) then begin
    event[0][2]:=trunc($40*uev[4]/$FF);   {linear!}
    uev[2]:=uev[2] and $F; {get rid of voleffect}
    uev[4]:=0;
  end;
  if (uev[2] and $F=$C) then begin
    event[0][2]:=trunc($40*uev[3]/$FF);     {linear!}
    uev[2]:=uev[2] and $F0; {get rid of voleffect}
    uev[3]:=0;
  end;
  { effect+para }
  if not UTReserved then begin
    event[0][3]:=ULTCmd(uev[2],uev[4],uev[3]);
    event[0][4]:=ULTPara(uev[2],uev[4],uev[3]);
  end;
end;
begin {$i-}

  if UseEMS and (not emsDetect) then UseEMS:=false;
  sds_read_ult:=nil;

  OldPosition:=FilePos(f);

  action:=1; CallUserRoutine;
  blockread(f,uh,sizeof(uh),r);
  if r<sizeof(uh) then begin
    loaderror:=2; { incorrect format }
    exit
  end;

  sgn:=AsciiZ2String(uh.Magic,15);
  if pos('MAS_UTrack_V',sgn)=0 then begin
    loaderror:=2; { incorrect format }
    exit
  end;

  {read version}
  Ver:=$F0;  {default, a virtual version 15.0...}
  if sgn='MAS_UTrack_V001' then Ver:=10;   {1.0-1.3}
  if sgn='MAS_UTrack_V002' then Ver:=14;   {1.4}
  if sgn='MAS_UTrack_V003' then Ver:=15;   {1.5}
  if sgn='MAS_UTrack_V004' then Ver:=16;   {1.6}

  { read text if case }
  if Ver>=14 then begin
    action:=5; CallUserRoutine;
    if TextPtr<>nil then free(TextPtr);
    TextSize:=Longint(uh.JumpVal)*32;
    if TextSize>0 then begin
      TextPtr:=malloc(TextSize+16);
      BlockRead(f,TextPtr^,TextSize,r);
    end;
  end;

  {read nr. of samples}
  BlockRead(f,Samples,1,r);

  { keep this position in mind }
  ThisPosition:=filepos(f);

  { skip descriptors in order to read the other shits }
  if Ver>=16 then
    seek(f,filepos(f)+word(Samples)*(sizeof(us)+2))
  else
    seek(f,filepos(f)+word(Samples)*sizeof(us));

  {read order}
  blockread(f,Order,256,r);

  {read nr. of channels and patterns}
  blockread(f,Chn,1,r);
  inc(Chn); if Chn>32 then Chn:=32;
  blockread(f,Patterns,1,r);
  inc(Patterns);

  {read pan positions if version at least 1.5}
  if Ver>=15 then blockread(f,sh.VRI,Chn,r);

  {if Ver<15 then{}  {in comments 'cause I hate UT's pannings like: 7-7-7-7-7...  :-) }
    for k:=0 to Chn-1 do
      sh.VRI[k]:=$F*byte((k and 3) in [1,2]);  {default: L-R-R-L-L-R-R-L...}

  {compute nr. of entries in Order list}
  Entries:=0;
  while (Order[entries]<>$FF) and (Entries<255) do inc(Entries);

  {module name}
  move(uh.name[0],ModuleName[1],32);
  ModuleName:=AsciiZ2String(ModuleName[1],32);

  { unknown autor - ULT does not have such info }
  Author:='';

  {others}
  sh.patterns:=Patterns;
  sh.entries:=Entries;
  sh.samples:=Samples;
  sh.channels:=Chn;
  Channels:=Chn;
  sh.InitGVolume:=$40;  {default gvolume}
  sh.InitSpeed:=6;      {default}
  sh.InitBPM:=$7D;      {default}
  sh.MasterVolume:=$88; {default}
  sh.PattAddrTabPtr:=@Pattern;
  sh.ChannelStatus:=$FFFFFFFF; { all channels are initially ON }

  {allocate memory for module and fill the fields}
  m:=malloc(sizeof(sh)+Patterns+Entries+Samples*(sizeof(ss)));
  if m=nil then begin
    loaderror:=3; exit
  end;
  {main header}
  move(sh,m^,sizeof(sh));
  {lines/pattern list}
  fillchar(LPerPatt,patterns,64);  {default=64 lines/patt}
  move(lperpatt,mem[seg(m^):sizeof(sh)],patterns);
  {order list}
  move(order,mem[seg(m^):sizeof(sh)+patterns],entries);

  { return to the stored position to read smp descriptors }
  seek(f,ThisPosition);

  {read sample descriptors}
  fillchar(SamType,256,0);  { 8bit samples (default) }
  fillchar(Sample,256*4,0);
  for a:=1 to Samples do begin
    action:=3; actionpara:=a; CallUserRoutine;
    blockread(f,us,sizeof(us),r);
    if r<sizeof(us) then begin
      sds_unload(m); loaderror:=2; exit
    end;
    if Ver>=16 then
      c2s:=us.FineTune
    else
      c2s:=Finetune2Speed(us.FineTune and $F);
    { *doc correction* :
      indeed, versions above 1.6 have an additional word here, but IT IS NOT
      the C2-Speed as the original doc claims !!! }
    if Ver>=16 then blockread(f,k,2,r);  {some shit, seems to be always zero}
    SName[a]:=AsciiZ2String(us.Name,32);
    {sample resolution (8/16 bit)}
    if us.BidiLoop in [4,12,28] then
      SamType[a]:=1  {16 bit signed}
    else
      SamType[a]:=0; {8 bit}
    {compute real size, loopstart and loopend}
    sz:=us.SizeEnd-us.SizeStart;
    ls:=us.LoopStart;
    le:=us.LoopEnd;
    if SamType[a]=1 then sz:=sz * 2;
    {alloc}
    if (sz<>0) then begin
      SamSize[a]:=word(sz);
      if LoadSamples then begin
        Sample[a]:=sds_alloc(SamSize[a]+8); { 8 extra bytes to prevent UltraClicks(tm)... }
        if (Sample[a]=nil) then begin
          sds_unload(m); loaderror:=3; exit
        end;
      end;
      with ss do begin
        {volume}
        if Ver>=14 then
          Volume:=trunc($40*us.volume/$FF)  {linear volume}
        else
          Volume:=ExpVol[us.volume];    {logarithmic volume}  ;
        {C2speed}
        C2Speed:=c2s;  {set before}
        {address}
        if UseGUS then Address:=longint(Sample[a]) else Address:=seg(Sample[a]^);
        {size,loopstart,loopend}
        Size:=word(sz);
        LoopStart:=word(ls);
        LoopEnd:=word(le);
        if ((ls=0) and (le=0)) or (us.BidiLoop in [0,4]) then loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
    end else begin
      with ss do begin
        Volume:=0;
        C2Speed:=8363;
        Address:=0;
        Size:=0;
        loopstart:=0;
        loopend:=$FFFF;
      end;
      move(ss,mem[seg(m^):sizeof(sh)+patterns+entries+(a-1)*sizeof(ss)],sizeof(ss));
      SamSize[a]:=0;
      Sample[a]:=nil;
      SamType[a]:=0;
    end;
  end;

  { now skip all info until the patterndata }
  if Ver>=15 then
    seek(f,filepos(f)+258+Chn)
  else
    seek(f,filepos(f)+258);

  {allocate pattaux}
  pattaux:=malloc(5*Chn*64 + 16);
  if pattaux=nil then begin
    loaderror:=9; exit
  end;

  {read patterndata (as mega-channels)}
  for c:=0 to Chn-1 do begin
    action:=4; ActionPara:=c; CallUserRoutine;
    a:=0; { absolute row (0=(row0,pattern0), 64=(row0,pattern1),...) }
    repeat
      fillchar(uev,5,0); fillchar(uRLE,2,0);
      l:=a and $3F;  {a mod 64 = relative row within pattern}
      p:=a div 64;   {a div 64 = pattern number}
      if (c=0) and (l=0) then begin  { 1st line, 1st chn of a pattern }
        { allocate pattern }
        pattern[p]:=malloc(5*Chn*64); {max size, it will be shrunk later}
        if pattern[p]=nil then begin
          sds_unload(m); loaderror:=3; exit { not enough memory }
        end;
        { fill pattern with empty events }
        fillchar(event[0],5,0); event[0][2]:=$C1;
        for k:=0 to Chn*64-1 do
          move(event[0],mem[seg(Pattern[p]^):k*5],5);
      end;
      {read RLE flag/Note+Number}
      blockread(f,uRLE,2,r);
      if r<2 then begin
        sds_unload(m); loaderror:=2; exit
      end;
      if uRLE.RepFlag<>$FC then begin { Note + Instrument }
        uev[0]:=uRLE.RepFlag;
        uev[1]:=uRLE.RepCount;
        blockread(f,uev[2],3,r);      { read the rest of event }
        ConvertEvent;                 { UltraTracker->SDM event }
        move(event[0],mem[seg(Pattern[p]^):Chn*5*l+c*5],5);
        inc(a);                       { next absolute row }
        l:=a and $3F;                 { relative row (used below) }
      end else begin                  { RepFlag + RepCount, a full event follows }
        blockread(f,uev,5,r);         { read the event }
        ConvertEvent;                 { UltraTracker->SDM event }
        for k:=1 to uRLE.RepCount do  { run the counter ... }
        begin
          move(event[0],mem[seg(Pattern[p]^):Chn*5*l+c*5],5);
          inc(a);
          l:=a and $3F;               { a mod 64 = relative row within pattern }
        end;
      end;
      { compress pattern if last channel/row has been written }
      if (l=0{overflow!}) and (c=Chn-1) then begin  { last row/channel }
        { initialize pattaux }
        move(Pattern[p]^,pattaux^,5*Chn*64);
        { default size }
        pattsize[p]:=5*Chn*64;
        { compress pattern[] using pattaux }
        if not CompressPattern(pattaux,Chn,64,Pattern[p],PattSize[p]) then begin
          SDS_UnLoad(m); loaderror:=5; exit
        end;
      end;
    until a>=word(64)*word(Patterns);
  end;

  { dealloc pattaux }
  if not free(pattaux) then begin
    sds_unload(m); loaderror:=8; exit;
  end;

  { the operations above (patterns loading) will leave big holes in the
    conventional memory, and thus, it's almost useless to try to load
    an ULT file in the <640k memory... However, small ULTs (has anyone
    heard of small ULTs?) are still loadable.
    What the heck, MAS's coding method (using mega-channels instead of
    patterns in order) is at least weird, so don't blame me. }

  {read samples if necessarry}
  if LoadSamples then begin
    for a:=1 to Samples do begin
      if SamSize[a]>0 then begin  {skip unused samples}
        action:=3; actionPARA:=a; CallUserRoutine;
        if SamType[a]=0 {8bit} then
          XorValue:=0    {8 bit signed data}
        else
          XorValue:=1;   {16 bit signed data}
        r:=sds_ReadBlock(f,Sample[a],SamSize[a],XorValue);
        if r<SamSize[a]*(1+SamType[a]) then begin
          sds_unload(m); loaderror:=2; exit;
        end;
      end;
    end;
  end;
  SDS_Read_ULT:=m;
  fillchar(samtype,256,0);
  loaderror:=0;
  seek(f,OldPosition);
end;

Function SDS_Load_ULT(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  sds_load_ult:=nil;
  if not openforinput(f,name) then begin
    LoadError:=1; { file not found }
    exit
  end;
  sds_load_ult:=sds_read_ult(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   SDM loader, revision 1.3                                             ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Function SDS_Read_SDM(var f:file; LoadSamples:boolean):Pointer;
type chunktype = record name:longint; size:longint end;
var module:pointer;
    a,b,r:word;
    chunk : chunktype;
    _EOC:byte;
    header : record
               Sign   : LongInt;
               Name   : Array [0..63] of byte; {ASCIIZ}
               Author : Array [0..63] of byte; {ASCIIZ}
               Chunks : Word;  { # of chunks in song, except this header }
               TrkName : array [0..31] of byte; { SDS/tracker name }
               TrkVer : Word;  { SDS/tracker version }
               PCompr : Byte;  { Patterns' compression type (0=none) }
             end;
    mi:sdmint_headtype;
    si:sdmint_insttype;
    sdes_c, sdat_c, patt_c, snam_c : word;
    known : boolean;
    OldPosition:longint;
function ReadData(var Dat; size:word):boolean;
begin
  blockread(f,Dat,size,r);
  readdata:=r=size;
end;
procedure readchunk;
begin
  blockread(f,chunk,8,r);
end;
function testEOC:boolean;
begin
  blockread(f,_EOC,1,r);
  testEOC:=(r=1)and(_EOC=EOC);
end;
procedure IgnoreChunk;
begin
  seek(f,filepos(f)+chunk.size);
end;
begin

  if UseEMS and (not emsDetect) then UseEMS:=false;

  sds_read_sdm:=nil;

  OldPosition:=FilePos(f);

  { read general info header }
  ReadData(header,sizeof(header));
  if (r<>sizeof(header)) or (header.Sign<>headerSign) then begin
    loaderror:=2; exit
  end;
  ModuleName:=AsciiZ2String(header.name,64);
  Author:=AsciiZ2String(header.author,64);
  if header.PCompr>1 then begin
    loaderror:=7; exit
  end;

  { read MINF chunk }
  readchunk;
  if chunk.name<>MINF then begin
    loaderror:=11; exit
  end;
  if not readdata(mi,sizeof(mi)) then begin
    loaderror:=11; exit
  end;
  module:=malloc(sizeof(mi)+mi.patterns+mi.entries+word(mi.samples)*sizeof(si));
  if module=nil then begin
    loaderror:=3; exit;
  end;
  mi.PattAddrTabPtr:=@pattern;
  mi.ChannelStatus:=$FFFFFFFF; {all channels ON}
  entries:=mi.entries;
  patterns:=mi.patterns;
  samples:=mi.samples;
  channels:=mi.channels;
  move(mi,module^,sizeof(mi));
  readdata(ptr(seg(module^),sizeof(mi))^,mi.patterns);
  readdata(order,mi.entries);
  move(order,ptr(seg(module^),sizeof(mi)+patterns)^,mi.entries);
  if not testEOC then begin
    loaderror:=10; sds_unload(module); exit
  end;

  { read the other chunks }
  sdes_c:=0; sdat_c:=0; patt_c:=0; snam_c:=0;
  FillChar(SamType,256,0); { default = 8-bit samples }

  for a:=1 to header.chunks-1 {w/out MINF} do begin

    known:=false;
    readchunk; {read chunk's id}

    if r<8 {chunk has not been readed} then begin
      loaderror:=13; sds_unload(module); exit
    end;

    if chunk.name = MTXT {TEXT chunk} then begin
      known:=true;
      action:=5; calluserroutine;
      { create a TEXT area }
      if TextPtr<>nil then free(TextPtr);
      TextPtr:=malloc(chunk.size); TextSize:=chunk.size;
      readdata(TextPtr^,TextSize);
    end;

    if chunk.name = STYP {STYP chunk} then begin
      known:=true;
      readdata(SamType[1],chunk.size); { Read flags }
    end;

    if chunk.name = PATT {PATT chunk} then begin
      known:=true;
      if patt_c>patterns-1 then known:=false {just ignore it}
      else begin
        action:=2; actionPara:=patt_c; calluserroutine;
        pattsize[patt_c]:=chunk.size; {interesting method, isn't it ? :) }
        pattern[patt_c]:=malloc(pattsize[patt_c]);
        if pattern[patt_c]=nil then begin
          loaderror:=3; sds_unload(module); exit
        end;
        if not readdata(pattern[patt_c]^,pattsize[patt_c]) {read pattern} then begin
          loaderror:=2; sds_unload(module); exit
        end;
      end;
      inc(patt_c);
    end;

    if chunk.name = SNAM {SNAM chunk} then begin
      known:=true;
      inc(snam_c);
      if (snam_c>samples) or (chunk.size<>35) then known:=false else begin
        readdata(sname[snam_c][1],chunk.size);
        sname[snam_c]:=Asciiz2String(sname[snam_c][1],35);
      end;
    end;

    if chunk.name = SDES {SDES chunk} then begin
      known:=true;
      inc(sdes_c);
      if sdes_c>samples then known:=false else begin
        action:=6; actionPara:=sdes_c; calluserroutine;
        readdata(si,sizeof(si));
        SamSize[sdes_c]:=si.size div (1+SamType[sdat_c]);
        if (SamSize[sdes_c]>0) and LoadSamples then begin { only if sample exists and must be loaded }
          Sample[sdes_c]:=sds_alloc(SamSize[sdes_c]+8);
          if Sample[sdes_c]=nil { error ? } then begin
            loaderror:=3; sds_unload(module); exit
          end;
        end else Sample[sdes_c]:=nil;
        si.LoopStart:=si.LoopStart div (1+SamType[sdes_c]);
        si.LoopEnd:=si.LoopEnd div (1+SamType[sdes_c]);
        si.Size:=si.Size div (1+SamType[sdes_c]);
        if UseGUS then si.Address:=longint(Sample[sdes_c]) else si.Address:=seg(Sample[sdes_c]^);
        move(si,ptr(seg(module^),sizeof(mi)+patterns+entries+(sdes_c-1)*sizeof(si))^,sizeof(si));
      end;
    end;

    if chunk.name = SDAT {SDAT chunk} then begin
      known:=true;
      if sdat_c>=sdes_c {trying to read sample data before its descriptor ?} then begin
        loaderror:=12; sds_unload(module); exit
      end;
      inc(sdat_c);
      if (sdat_c>samples) or (Sample[sdat_c]=nil) then known:=false else begin
        action:=3; actionPara:=sdat_c; calluserroutine;
        if LoadSamples then begin
          r:=sds_readblock(f,Sample[sdat_c],SamSize[sdat_c],SamType[sdat_c]);
          if (r<SamSize[sdat_c]*(1+SamType[sdat_c])) then begin
            loaderror:=2; sds_unload(module); exit;
          end;
        end;
      end;
    end;

    if not known then IgnoreChunk; { ignore all the unknown chunks }

    if not testEOC then begin {end of chunk?}
      loaderror:=10; sds_unload(module); exit
    end;

  end;

  loaderror:=0;
  sds_read_sdm:=module;
end;

Function SDS_Load_SDM(name:string; LoadSamples:boolean):Pointer;
var f:file;
begin
  if not openforinput(f,name) then begin
    loaderror:=1; {file not found}
    exit
  end;
  sds_load_sdm:=sds_read_sdm(f,LoadSamples);
  closefile(f);
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   SDM saver, revision 1.2                                              ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

function SDS_Save_SDM(module:pointer; name:string):boolean;
type
  ChunkType = record
                Name : LongInt;
                Size : LongInt;
              end;
var
  chunk : chunktype;
  f:file;
  a,r:word;
  header : record
             Sign    : LongInt;
             Name    : Array [0..63] of byte; {ASCIIZ}
             Author  : Array [0..63] of byte; {ASCIIZ}
             Chunks  : Word;  { # of chunks in song, except this header }
             TrkName : Array [0..31] of byte; { SDS/tracker name }
             TrkVer  : Word;  { SDS/tracker version }
             PCompr  : Byte;  { Patterns' compression type (0=none) }
           end;
  mi : sdmint_headtype;
  si : sdmint_insttype;

procedure WriteEOC;
begin
  blockwrite(f,EOC,1,r);
end;
procedure WriteData(var Dat; Size:Word);
begin
  blockwrite(f,Dat,Size,r);
end;
procedure WriteChunk(var chunk:ChunkType);
begin
  writedata(chunk,8);
end;
begin {$i-}
  sds_save_sdm:=false;
  if not openforoutput(f,name) then begin
    saveerror:=1;
    exit;
  end;

  { write global info header }
  fillchar(header,sizeof(header),0);
  header.Sign := HeaderSign;
  if length(ModuleName)<=64 then
    move(ModuleName[1],header.Name,length(modulename))
  else
    move(ModuleName[1],header.Name,64);
  if length(Author)<=64 then
    move(Author[1],header.author,length(author))
  else
    move(author[1],header.author,64);
  header.Chunks:=2+word(Samples)*3+word(patterns);
  if TextSize>0 then inc(header.Chunks);
  move(TrackerName[1],header.TrkName,length(TrackerName));
  header.TrkVer:=TrackerVer;
  header.PCompr:=1; { actually 1 compression type }
  writedata(header,sizeof(header));
  if r<sizeof(header) then begin
    saveerror:=2; exit
  end;

  { write MINF chunk }
  chunk.name:=MINF;
  chunk.size:=sizeof(mi)+patterns+entries;
  writechunk(chunk);
  move(module^,mi,sizeof(mi));
  mi.PattAddrTabPtr:=nil; {field used only in memory}
  writedata(mi,sizeof(mi));
  writedata(ptr(seg(module^),sizeof(mi))^,word(patterns));
  writedata(order,entries);
  if r<entries then begin
    saveerror:=2; exit
  end;
  writeEOC; {end of chunk}

  { write STYP chunk }
  chunk.name:=STYP;
  chunk.size:=samples; { 1byte per sample - flag which shows whether it's an 8bit or 16bit sample }
  writechunk(chunk);

  {all samples were previously converted to 8bit unsigned, non-delta, so...}
  {fillchar(samtype,256,0); {}

  writedata(SamType[1],samples);  { bit 0 : 8bit(0), 16bit(1)
                                        6 : delta packed(1), normal (0)
                                        7 : unsigned (1), signed(0) }
  if r<samples then begin
    saveerror:=2; exit
  end;
  writeEOC; {end of chunk}

  { write SDES chunks }
  for a:=1 to samples do begin
    chunk.name:=SDES;
    chunk.size:=sizeof(si);
    writechunk(chunk);
    move(ptr(seg(module^),sizeof(mi)+entries+patterns+(a-1)*sizeof(si))^,si,sizeof(si));
    with si do Address:=0; {used only while in memory}
    si.Size:=si.Size*(1+SamType[a]);
    si.LoopStart:=si.LoopStart*(1+SamType[a]);
    si.LoopEnd:=si.LoopEnd*(1+SamType[a]);
    writedata(si,sizeof(si));
    if r<sizeof(si) then begin
      saveerror:=2; exit
    end;
    writeEOC; {end of chunk}
  end;

  { write SNAM chunks - names of samples }
  for a:=1 to samples do begin
    chunk.name:=SNAM;
    chunk.size:={****}35{****}; {?!}
    writechunk(chunk);
    writedata(SName[a][1],35);
    if r<35 then begin
      saveerror:=2; exit
    end;
    writeEOC; {end of chunk}
  end;

  { write patterns }
  for a:=0 to patterns-1 do begin
    chunk.name:=PATT;
    chunk.size:=PattSize[a];
    writechunk(chunk);
    writedata(pattern[a]^,PattSize[a]);
    if r<pattsize[a] then begin
      saveerror:=2; exit
    end;
    writeEOC; {end of chunk}
  end;

  { write TEXT chunk (if case) }
  if TextSize>0 then begin
    chunk.name:=MTXT;
    chunk.size:=TextSize;
    writechunk(chunk);
    writedata(TextPtr^,TextSize);
    if r<TextSize then begin
      saveerror:=3; exit
    end;
    writeEOC; {end of chunk}
  end;

  { write SDAT chunks - sample data }
  for a:=1 to samples do begin
    chunk.name:=SDAT;
    chunk.size:=SamSize[a]*(1+SamType[a]);
    writechunk(chunk);
    r:=sds_WriteBlock(f,Sample[a],SamSize[a]*(1+SamType[a]),SamType[a]);
    if r<SamSize[a]*(1+SamType[a]) then begin
      saveerror:=2; exit
    end;
    writeEOC; {end of chunk}
  end;

  saveerror:=0;
  closefile(f);
  sds_save_sdm:=true;
end;


{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   SDS kernel routines                                                  ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

(*
  Note:
  All the routines below use a small trick to call the kernel's routines.
  In this manner, the stack is left untouched and does not grow up
  excessively. The returning points from the real kernel' routines is not
  the end of THESE routines but the instructions immediately following
  the caller.  This idea is based on the fact that, at the far routine's
  entrance, Pascal creates a stack frame which is disabled using the LEAVE
  instruction below. This is true for all the routines containing parameters
  in their declaration, and NOT TRUE for simple far routines. This version
  of SDS has been cooked and compiled under Turbo Pascal 7.0 and the routines
  below worked perfectly. I really don't know the behaviour under other
  compilers.
  (Or else: the routines below pass all the responsability, including
  parameters and stack cleaning, to the kernel's routines (defined in the
  SDS.ASM file)).
*)

procedure sds_init(Card, Base, Irq, Dma:word);assembler;
asm
  mov UseGUS,False
  mov ax,Card
  cmp ax,4
  jne @1
  mov UseGUS,True     { UseGUS and GUSbase are used by the memory manager }
  mov ax,Base         { and I/O manager, and thus they have to be set up  }
  mov GUSbase,ax      { correctly                                         }
@1:
  leave
  jmp far ptr sds_k.sds_init
end;

procedure sds_done;assembler;
asm
  jmp far ptr sds_k.sds_done
end;

procedure sds_startplay(module:pointer; InitSpd, MixSpeed, Pal:word);assembler;
asm
  leave
  jmp far ptr sds_k.sds_startplay
end;

procedure sds_stopplay;assembler;
asm
  jmp far ptr sds_k.sds_stopplay
end;

procedure sds_setsurround(surroundmod:boolean);assembler;
asm
  leave
  jmp far ptr sds_k.sds_setsurround
end;

procedure sds_setamplification(percent:word);assembler;
asm
  leave
  jmp far ptr sds_k.sds_setamplification
end;

procedure sds_setpollmix(pollmode:boolean);assembler;
asm
  leave
  jmp far ptr sds_k.sds_setpollmix
end;

procedure sds_poll;assembler;
asm
  jmp far ptr sds_k.sds_poll
end;

procedure sds_services;assembler;
asm
  jmp far ptr sds_k.sds_services
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ   Load/Unload general functions                                        ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

procedure SDS_UnLoad;
var a:word;
begin
  for a:=0 to 255 do begin
    if Sample[a]<>nil then sds_free(Sample[a]);
    if Pattern[a]<>nil then free(Pattern[a]);
    Pattern[a]:=nil;
    Sample[a]:=nil;
    SName[a]:='';
    SamSize[a]:=0;
  end;
  if module<>nil then free(module);
  if (TextSize>0) and (TextPtr<>nil) then free(TextPtr);
end;

function SDS_Load(name:string; LoadSamples:boolean):Pointer;
begin
  name:=ucase(name); LoadError:=0;
  if pos('.SDM',name)>0 then SDS_Load:=sds_load_sdm(name,LoadSamples) else
  if pos('.S3M',name)>0 then SDS_Load:=sds_load_s3m(name,LoadSamples) else
  if pos('.MTM',name)>0 then SDS_Load:=sds_load_mtm(name,LoadSamples) else
  if pos('.MOD',name)>0 then SDS_Load:=sds_load_mod(name,LoadSamples) else
  if pos('.STM',name)>0 then SDS_Load:=sds_load_stm(name,LoadSamples) else
  if pos('.669',name)>0 then SDS_Load:=sds_load_669(name,LoadSamples) else
  if pos('.ULT',name)>0 then SDS_Load:=sds_load_ult(name,LoadSamples) else
  if pos('.FAR',name)>0 then SDS_Load:=sds_load_far(name,LoadSamples) else
  if (pos('.PTM',name)>0) or
     (pos('.ћM',name)>0) then SDS_Load:=sds_load_ptm(name,LoadSamples) else
    begin
      SDS_Load:=nil;
      LoadError:=4
    end;
end;

var k:word;
begin
  for k:=0 to 255 do begin
    Sample[k]:=nil;
    Pattern[k]:=nil;
    SName[k]:='';
  end;
end.
