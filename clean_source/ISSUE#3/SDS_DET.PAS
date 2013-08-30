Unit SDS_Det;
{
    Sound Deluxe System 5
    a Maple Leaf production, 1996-1997
    (Maple Leaf is a.k.a. Gruian Radu Bogdan)
    ---------------------------------------------------------------------
    Souncards detection and initialization routines
    ---------------------------------------------------------------------
    This program is part of the Sound Deluxe System 5, and it cannot
    be modified or sold without the written permission of the author. The
    author does not assume any responsability for the incidental loss or
    hardware/software damages produced while using this program or any other
    part of the Sound Deluxe System. The author also does not assume any
    responsability for the damages produced by using modified parts of this
    package.  Blah, blah...
    ---------------------------------------------------------------------
    Detection order:
    GUS-SB16-WSS-PAS-Aria-SBPro-SB2/SB
}

Interface

var
  Base, Irq, Dma : WORD;   { Set up by the routines below }
  Card           : WORD;   { Same for this shit }

function DetectSoundCard(var Base:WORD; var Irq:WORD; var Dma:WORD):word;far;
function InitSoundCard(Card, Base, Irq, Dma:WORD):boolean;

function InitSB(Base, Irq, Dma:WORD):Boolean;far;
function DetectSB(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

function InitSBPro(Base, Irq, Dma:WORD):Boolean;far;
function DetectSBPro(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

function InitSB16(Base, Irq, Dma:WORD):Boolean;far;
function DetectSB16(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

function InitGUS(Base, Irq, Dma:WORD):Boolean;far;
function DetectGUS(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

function InitPAS(Base, Irq, Dma:WORD):Boolean;far;
function DetectPAS(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

function InitWSS(Base, Irq, Dma:WORD):Boolean;far;
function DetectWSS(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

function InitARIA(Base, Irq, Dma:WORD):Boolean;far;
function DetectARIA(var Base:WORD; var Irq:WORD; var Dma:WORD):Boolean;far;

Implementation

{$L sds_det.obj}
function InitSB;external;
function DetectSB;external;

function InitSBPro;external;
function DetectSBPro;external;

function InitSB16;external;
function DetectSB16;external;

function InitGUS;external;
function DetectGUS;external;

function InitPAS;external;
function DetectPAS;external;

function InitWSS;external;
function DetectWSS;external;

function InitARIA;external;
function DetectARIA;external;

function DetectSoundCard(var Base:WORD; var Irq:WORD; var Dma:WORD):word;
begin
  if DetectGUS   (Base,Irq,Dma) then card:=4 else
  if DetectSB16  (Base,Irq,Dma) then card:=3 else
  if DetectWSS   (Base,Irq,Dma) then card:=6 else
  if DetectPAS   (Base,Irq,Dma) then card:=5 else
  if DetectARIA  (Base,Irq,Dma) then card:=7 else
  if DetectSBPro (Base,Irq,Dma) then card:=2 else
  if DetectSB    (Base,Irq,Dma) then card:=1 else
  begin
    card:=8; base:=$378; dma:=0; Irq:=0; {not used}
  end;
  DetectSoundCard:=card; {useless, just for compatibility with a previous SDS version}
end;

function InitSoundCard(Card, Base, Irq, Dma:WORD):boolean;
var yes:boolean;
begin
  case Card of
    1: yes:=InitSB(Base,Irq,Dma);
    2: yes:=InitSBPro(Base,Irq,Dma);
    3: yes:=InitSB16(Base,Irq,Dma);
    4: yes:=InitGUS(Base,Irq,Dma);
    5: yes:=InitPAS(Base,Irq,Dma);
    6: yes:=InitWSS(Base,Irq,Dma);
    7: yes:=InitAria(Base,Irq,Dma);
    8: yes:=true;
    else yes:=false;
  end;
  InitSoundCard:=yes;
end;

begin
end.