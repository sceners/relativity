{$G+}
unit SDSetup1;

{
    Sound Deluxe System 5
    a Maple Leaf production, 1996-1997
    (Maple Leaf is a.k.a. Gruian Radu Bogdan)
    ---------------------------------------------------------------------
    Setup program v1.6, Feb 1997
    new features:
        ю two more IRQ's can be used now (up to IRQ12)
        ю one more soundcard (Aria)
        ю more compact
        ю VESA mode if user wants
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

interface

uses crt, string_s, sds_det, ems, alloc;

const sdsetup_txt  : string = ' Sound Deluxe System v5.03б,'+
                              ' Setup program v1.6 (Feb 1997)'+
                              '                 SDS5';

      sdsetup_txt2 : string = ' (c)1996,97 by Maple Leaf'+
                              ' (a.k.a. Gruian Radu)';



const scNames : array [1..8] of string = (
  ' Sound Blaster/Sound Blaster 2.0 (DSP 1.x/2.x)      Yes',
  ' Sound Blaster Pro (DSP 3.x)                        Yes',
  ' Sound Blaster 16 ASP (DSP 4.x/5.x)                 Yes',
  ' Gravis Ultrasound                                  Yes',
  ' Pro Audio Spectrum                                 No ',
  ' Windows Sound System (Crystal/Analog CODEC)        No ',
  ' Aria (SC18025/SC18026 DSP)                         No ',
  ' Grave UltraSilence!(tm) (no sound)                 Yes');

procedure SDS_Setup(var card_,irq_,dma_,base_,rate_,gain_:word; var pal:byte; var surround,ems_,umb_:boolean);

implementation

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ                     Very simple windows routines                       ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

Const ScrWidth  : word = 80;  {try 132 for vesa}
      ScrHeight : word = 25;  {try 43 for vesa}

Type
  WinType  = ^WT;
  WT       = Record
               x,y,xx,yy,attr:byte;
               Shadow:Boolean;
               CWindow:Byte;
               DirtyArea:Pointer;
               Next : WinType;
             end;

Const
  Border : Array [0..5,0..7] of byte = ( (32,32,32,32,32,32,32,32),
                                         ($da,$c4,$bf,$b3,$d9,$c4,$c0,$b3),
                                         ($c9,$cd,$bb,$ba,$bc,$cd,$c8,$ba),
                                         ($d5,$cd,$b8,$b3,$be,$cd,$d4,$b3),
                                         ($d6,$c4,$b7,$ba,$bd,$c4,$d3,$ba),
                                         ($db,$df,$db,$db,$db,$dc,$db,$db));
Var
  LastWin : WinType;
  CBorder : Byte;

{±±± Windows routines: ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}
(*
Procedure SetBorderType(n:byte);     { Set the character used for border }
Procedure MWindow(x,y,xx,yy,Attr:Byte; Shadow:Boolean);  { draw a window }
Procedure RWindow;                                  { remove last window }
Procedure RAllWindows;                      { remove all defined windows }
Procedure TWindow(Title:String; TitleType:Byte);    { set window's title }
Procedure NoTitle;                                   { remove all titles }
Procedure NoTopTitle;                                { remove top titles }
Procedure NoBottomTitle;                          { remove bottom titles }
Procedure WColor(attr:byte);     { set the default color for last window }
Procedure Exclusive;                 { all I/O redirected to last window }
Procedure NonExclusive;                      { I/O global, not to window }
Procedure WText(x,y:byte; txt:String; attr:byte);         { write a text }
Procedure WCText(y:byte; txt:String; attr:byte); { write a centered text }
Procedure GWText(x,y:byte; txt:String; attr:byte); { write a text into the
                                                           global window }
*)

Procedure SetBorderType(n:byte);
begin
  CBorder:=n;
end;

Procedure MWindow(x,y,xx,yy,Attr:Byte; Shadow:Boolean);
var
  p:WinType;
  l,c:byte;
  at:byte;
begin
  p:=malloc(sizeof(WT));
  p^.Next:=LastWin;
  p^.x:=x; p^.y:=y; p^.xx:=xx; p^.yy:=yy; p^.attr:=attr;
  p^.shadow:=shadow;
  p^.DirtyArea:=malloc((yy+Byte(Shadow))*(xx+Byte(Shadow))*2);
  { Rape screen area }
  for l:=0 to yy-1+Byte(Shadow) do
    move(mem[$b800:((y+l)*ScrWidth+x)*2],Pointer(LongInt(p^.DirtyArea)+2*l*(xx+Byte(Shadow)))^,(xx+Byte(Shadow))*2);
  { Fill that area with blanks }
  for l:=0 to yy-1 do
    for c:=0 to xx-1 do
      memw[$b800:((y+l)*ScrWidth+(x+c))*2]:=(Attr shl 8)+32;
  { Draw border }
  for c:=0 to xx-1 do begin
    mem[$b800:(y*ScrWidth+(x+c))*2]:=Border[CBorder,1];
    mem[$b800:((y+yy-1)*ScrWidth+(x+c))*2]:=Border[CBorder,5];
  end;
  for l:=0 to yy-1 do begin
    mem[$b800:((y+l)*ScrWidth+x)*2]:=Border[CBorder,7];
    mem[$b800:((y+l)*ScrWidth+(x+xx-1))*2]:=Border[CBorder,3];
  end;
  mem[$b800:(y*ScrWidth+x)*2]:=Border[CBorder,0];
  mem[$b800:((y+yy-1)*ScrWidth+x)*2]:=Border[CBorder,6];
  mem[$b800:((y+yy-1)*ScrWidth+(x+xx-1))*2]:=Border[CBorder,4];
  mem[$b800:(y*ScrWidth+(x+xx-1))*2]:=Border[CBorder,2];
  { Make shadow }
  if Shadow then begin
    for l:=1 to yy do begin
      at:=mem[$b800:((y+l)*ScrWidth+(x+xx))*2+1];
      if at shr 4 >= 8 then
        at:=(((at shr 4)-8) shl 4) + (at and $F)
      else
        at:=(at and $F);
      if at and $F >=8 then
        at:=(at and $F0) + ((at and $F)-8)
      else
        at:=(at and $F0) + (at and $F);
      mem[$b800:((y+l)*ScrWidth+(x+xx))*2+1]:=at;
    end;
    for c:=1 to xx-1 do begin
      at:=mem[$b800:((y+yy)*ScrWidth+(x+c))*2+1];
      if at shr 4 >= 8 then
        at:=(((at shr 4)-8) shl 4) + (at and $F)
      else
        at:=(at and $F);
      if at and $F >=8 then
        at:=(at and $F0) + ((at and $F)-8)
      else
        at:=(at and $F0) + (at and $F);
      mem[$b800:((y+yy)*ScrWidth+(x+c))*2+1]:=at;
    end;
  end;
  LastWin:=p;
end;

Procedure RWindow;
var l,c:byte;
    p:WinType; ll:pointer;
begin
  if LastWin=nil then exit;
  with LastWin^ do begin
    for l:=0 to yy-1+Byte(Shadow) do
      move(pointer(longint(DirtyArea)+2*l*(xx+Byte(Shadow)))^,mem[$b800:((y+l)*ScrWidth+x)*2],(xx+Byte(Shadow))*2);
    Free(DirtyArea);
  end;
  p:=LastWin^.Next;
  ll:=pointer(LastWin);
  free(ll);
  LastWin:=p;
end;

Procedure WCText(y:byte; txt:String; attr:byte);
var o,k,x:word;
begin
  x:=LastWin^.x+(LastWin^.xx div 2)-(Length(txt) div 2); y:=y+LastWin^.y;
  o:=(y*ScrWidth+x)*2;
  for k:=1 to length(txt) do memw[$b800:o+(k-1) shl 1]:=(attr shl 8)+Byte(txt[k]);
end;

Procedure GWText(x,y:byte; txt:String; attr:byte);
var o,k:word;
begin
  o:=(y*ScrWidth+x)*2;
  for k:=1 to length(txt) do memw[$b800:o+(k-1) shl 1]:=(attr shl 8)+Byte(txt[k]);
end;

Procedure TWindow(Title:String; TitleType:Byte);
begin
  with LastWin^ do begin
    case TitleType of
      0 : {MiddleTop}   GWText(x+(xx div 2)-(length(Title) div 2),y,Title,Attr);
      1 : {LeftTop}     GWText(x+2,y,Title,Attr);
      2 : {RightTop}    GWText(x+xx-2-Length(Title),y,Title,Attr);
      3 : {MiddleBott}  GWText(x+(xx div 2)-(length(Title) div 2),y+yy-1,Title,Attr);
      4 : {LeftBottom}  GWText(x+2,y+yy-1,Title,Attr);
      5 : {RightBottom} GWText(x+xx-2-Length(Title),y+yy-1,Title,Attr);
    end;
  end;
end;

Procedure Exclusive;
begin
  with LastWin^ do
    Window(x+2,y+2,x+xx-2,y+yy-1);
end;

Procedure NonExclusive;
begin
  Window(0,0,ScrWidth,ScrHeight);
end;

Procedure WText(x,y:byte; txt:String; attr:byte);
var o,k:word;
begin
  x:=x+LastWin^.x; y:=y+LastWin^.y;
  o:=(y*ScrWidth+x)*2;
  for k:=1 to length(txt) do memw[$b800:o+(k-1) shl 1]:=(attr shl 8)+Byte(txt[k]);
end;

Procedure NoTitle;
var c:word;
begin
  with LastWin^ do
    for c:=1 to xx-2 do begin
      mem[$b800:(y*ScrWidth+(x+c))*2]:=Border[CBorder,1];
      mem[$b800:((y+yy-1)*ScrWidth+(x+c))*2]:=Border[CBorder,5];
    end;
end;

Procedure NoTopTitle;
var c:word;
begin
  with LastWin^ do
    for c:=1 to xx-2 do begin
      mem[$b800:(y*ScrWidth+(x+c))*2]:=Border[CBorder,1];
    end;
end;

Procedure NoBottomTitle;
var c:word;
begin
  with LastWin^ do
    for c:=1 to xx-2 do begin
      mem[$b800:((y+yy-1)*ScrWidth+(x+c))*2]:=Border[CBorder,5];
    end;
end;

Procedure WColor(attr:byte);
begin
  LastWin^.Attr:=attr;
end;

Procedure RAllWindows;
begin
  while LastWin<>nil do RWindow;
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ                     Very simple menus routines                         ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

type ItemType = ^IT;
     IT       = record
                  name : string [80];
                  number : word;
                  shown : boolean;
                  next : ItemType;
                end;

     MenuType = ^MT;
     MT       = record
                  OwnWindow : WinType;
                  ActiveAttr : byte;
                  ActiveHigh : byte;
                  InactiveAttr : byte;
                  InactiveHigh : byte;
                  Item : ItemType;
                end;

var MenuLeftWith : char;

{±±± Menu routines: ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±}
{
procedure DefineMenu (var m:MenuType; x,y,xx,yy,wAttr,actAttr,inactAttr,
                      actHighlight, inactHighlight:byte; shadow:boolean);
procedure AddItem (var m:MenuType; name:string; shown:boolean);
function  ActivateMenu (var m:MenuType; InitItemNo:word):word;
procedure KillMenu (var m:MenuType);
procedure ToggleItem (var m:MenuType; itm:word; shown:boolean);
procedure ChangeItem (var m:MenuType; itm:word; s:string; shown:boolean);
}

procedure DefineMenu(var m:MenuType; x,y,xx,yy,wAttr,actAttr,inactAttr,
                     actHighlight, inactHighlight:byte; shadow:boolean);
begin
  m:=malloc(sizeof(mt));
  mwindow(x,y,xx,yy,wattr,shadow);
  m^.OwnWindow:=LastWin;
  with m^ do begin
    Item:=nil;
    activeAttr:=actAttr; activeHigh:=actHighlight;
    inactiveAttr:=inactAttr; inactiveHigh:=inactHighlight;
  end;
end;

procedure AddItem(var m:MenuType; name:string; shown:boolean);
var p,q:ItemType; nr:word;
begin
  q:=malloc(sizeof(IT));
  q^.name:=name; q^.shown:=shown; q^.next:=nil;
  p:=m^.item; nr:=1;
  while (p<>nil) and (p^.next<>nil) do begin p:=p^.next; inc(nr) end;
  if p=nil { first } then begin
    q^.number:=1;
    m^.item:=q;
  end else begin
    q^.number:=nr+1;
    p^.next:=q;
  end;
end;

procedure KillMenu(var m:MenuType);
var p,q:ItemType; x:pointer;
begin
  p:=m^.item;
  while p<>nil do begin  { free all items }
    q:=p^.next;
    x:=p; free(x); p:=q;
  end;
  rwindow;
  x:=m; free(x);
end;

procedure ItemParam(m:menutype; Nth:word; var Name:string; var shown:boolean);
var p:ItemType; nr:word;
begin
  nr:=1; p:=m^.item;
  if p=nil then begin
    name:=''; shown:=false
  end else begin
    while (nr<Nth) do begin p:=p^.next; inc(nr) end;
    Name:=p^.name; shown:=p^.shown
  end;
end;

function Items(m:menutype):word;
var nr:word; p:itemtype;
begin
  p:=m^.item; Items:=0;
  if p=nil then exit;
  nr:=0;
  while p<>nil do begin p:=p^.next; inc(nr) end;
  Items:=nr;
end;

procedure dispOpt(m:menutype; itm:word; high:boolean);
var s:string; sh:boolean;
begin
  ItemParam(m,itm,s,sh);
  if not high then
    if sh then
      WText(1,itm,s+space(m^.ownwindow^.xx-2-length(s)),m^.activeAttr)
    else
      WText(1,itm,s+space(m^.ownwindow^.xx-2-length(s)),m^.inactiveAttr)
  else
    if sh then
      WText(1,itm,s+space(m^.ownwindow^.xx-2-length(s)),m^.activeHigh)
    else
      WText(1,itm,s+space(m^.ownwindow^.xx-2-length(s)),m^.inactiveHigh);
end;

procedure showMenu(m:menutype);
var k:word;
begin
  for k:=1 to Items(m) do dispOpt(m,k,false);
end;

function ActivateMenu(var m:MenuType; InitItemNo:word):word;
var itms,itm:word; c:char;
    gata:boolean;
    s:string; sh:boolean;
begin
asm
  mov    ch,$20
  mov    ah,$01
  int    $10
end;
  itms:=items(m);
  showmenu(m); gata:=false;
  itm:=InitItemNo; if itm>itms then itm:=1;
  repeat
    dispOpt(m,itm,true);
    c:=readkey; if c=#0 then c:=readkey;
    MenuLeftWith:=c;
    dispOpt(m,itm,false);
    case c of
      #72 : {up} if itm>1 then dec(itm) else itm:=itms;
      #80 : {dn} if itm<itms then inc(itm) else itm:=1;
      #27 : begin ActivateMenu:=$FFFF; gata:=true end;
      #13,#32 : begin
        ItemParam(m,itm,s,sh);
        if sh then begin
          ActivateMenu:=itm;
          gata:=true
        end;
      end;
    end;
  until gata;
end;

procedure ToggleItem(var m:MenuType; itm:word; shown:boolean);
var i:itemtype; nr:word;
begin
  i:=m^.item; if i=nil then exit;
  nr:=1;
  while (nr<itm) and (i<>nil) do begin i:=i^.next; inc(nr) end;
  i^.shown:=shown;
end;

procedure ChangeItem(var m:MenuType; itm:word; s:string; shown:boolean);
var i:itemtype; nr:word;
begin
  i:=m^.item; if i=nil then exit;
  nr:=1;
  while (nr<itm) and (i<>nil) do begin i:=i^.next; inc(nr) end;
  i^.shown:=shown;
  i^.name:=s;
end;

{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}
{ЫЫ                            SDS Setup code                              ЫЫ}
{ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ}

procedure desktop;
var k:word;
begin
  clrscr;
  if (ScrWidth=132) and (ScrHeight=43) then
    asm
      mov ax,54h  {try to use vesa mode}
      int 10h
    end;
  asm
    mov ah,$10
    mov al,3
    mov bl,0
    int 10h  {use high intensity, do not blink}
  end;
  gotoxy(1,1);
  setbordertype(0);
{  mwindow(0,0,80,30,$7F,false);}
{  gwtext(0,0,space(80),$F0);
{  gwtext(0,0,,$F0);}
{  gwtext(0,1,space(80),$17);
  gwtext(0,1,sdsetup_txt2,$1B);}
  setbordertype(1);
  for k:=2 to 24 do gwtext(0,k,strng(80,176),$8F);{}
end;

procedure CloseDesktop;
begin
  RAllWindows;
  asm mov ax,3; int 10h end;{}
end;

procedure SDDet(var card_,irq_,dma_,base_,rate_:word);
var c:char;
begin
  setbordertype(2);
  mwindow(20,13,40,7,$4F,true);
  twindow('[ Warning ]',0);
  wtext(1,1,'  The detection of soundcard and its',$4E);
  wtext(1,2,' parameters could ocasionally cause',$4E);
  wtext(1,3,' the computer to freeze (not always)',$4E);
  wtext(1,4,' Press ESC to stop now, or any other',$4E);
  wtext(1,5,' key to continue detection...',$4E);
  c:=readkey;
  rwindow;
  if c<>#27 then begin
    card_:=DetectSoundCard(Base_,Irq_,Dma_);
    if card_=8 then begin
      mwindow(25,7,30,5,$AF,true);
      wctext(2,'No sound card found',$A0);
      delay(1000);
      rwindow;
    end else begin
      mwindow(25,7,30,5,$BF,true);
      wctext(2,'Successful detection',$B0);
      rate_:=44100;
      delay(1000);
      rwindow;
    end;
    while keypressed do readkey;
  end;
end;

procedure SelectSC(var card_:word);
var m:menutype; o:word;
begin
  setbordertype(4);
  definemenu(m,10,9,60,10,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' Sound Card Selection ',0);
  wcolor($1A);
  twindow('Tested',2);
  for o:=1 to 8 do additem(m,scNames[o],true);
  o:=activatemenu(m,card_);
  if not (o=$FFFF) then card_:=o;
  killmenu(m);
end;

procedure SelectIRQ(var irq_:word);
var m:menutype; o:word;
begin
  setbordertype(5);
  definemenu(m,30,8,20,15,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' IRQ list ',0);
  additem(m,'      IRQ0',false);
  additem(m,'      IRQ1',false);
  additem(m,'      IRQ2',true);
  additem(m,'      IRQ3',true);
  additem(m,'      IRQ4',false);
  additem(m,'      IRQ5',true);
  additem(m,'      IRQ6',false);
  additem(m,'      IRQ7',true);
  additem(m,'      IRQ8',false);
  additem(m,'      IRQ9',false);
  additem(m,'      IRQ10',true);
  additem(m,'      IRQ11',true);
  additem(m,'      IRQ12',true);
  o:=activatemenu(m,irq_+1);
  if not (o=$FFFF) then irq_:=o-1;
  killmenu(m);
end;

procedure SelectDMA(var dma_:word);
var m:menutype; o:word;
begin
  setbordertype(5);
  definemenu(m,30,12,20,10,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' DMA list ',0);
  additem(m,'      DMA #0',true);
  additem(m,'      DMA #1',true);
  additem(m,'      DMA #2',false);
  additem(m,'      DMA #3',true);
  additem(m,'      DMA #4',false);
  additem(m,'      DMA #5',true);
  additem(m,'      DMA #6',true);
  additem(m,'      DMA #7',true);
  o:=activatemenu(m,dma_+1);
  if not (o=$FFFF) then dma_:=o-1;
  killmenu(m);
end;

procedure SelectGain(var gain_:word);
var m:menutype; o:word;
const list : array[1..8] of word = (100,110,120,130,140,150,200,250);
function id(gain:word):word;
var k:word;
begin
  id:=1; for k:=1 to 8 do if gain=list[k] then begin id:=k; exit end;
end;
begin
  setbordertype(2);
  mwindow(1,3,42,13,$4F,true);
  twindow('[ Remark ]',4);
  wtext(1,1,' The gain (amplification level) shows',$4E);
  wtext(1,2,' SDS how to modify the intensity of',$4E);
  wtext(1,3,' the output sound. So, the greater the',$4E);
  wtext(1,4,' gain, the stronger the output will be.',$4E);
  wtext(1,5,' There are, though, some superior li-',$4E);
  wtext(1,6,' mits for this value, depending on the',$4E);
  wtext(1,7,' accuracy and intensity of the original',$4E);
  wtext(1,8,' sound. If the amplification level is',$4E);
  wtext(1,9,' too high, the sound will be distorted,',$4E);
  wtext(1,10,' noisy and unnatural. The best gain',$4E);
  wtext(1,11,' values are between 10% and 50%.',$4E);
  setbordertype(5);
  definemenu(m,41,12,20,10,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' Gain (%) ',0);
  additem(m,'         0 %',true);
  additem(m,'        10 %',true);
  additem(m,'        20 %',true);
  additem(m,'        30 %',true);
  additem(m,'        40 %',true);
  additem(m,'        50 %',true);
  additem(m,'       100 %',true);
  additem(m,'       150 %',true);
  o:=activatemenu(m,id(gain_));
  if not (o=$FFFF) then gain_:=list[o];
  killmenu(m);
  rwindow;
end;

procedure SelectBase(var card_,base_:word);
var m:menutype; o,u,itms:word;
const list : array[1..7,1..8] of word =
      ( ($210,$220,$230,$240,$250,$260,$270,$280), {SB/SB2}
        ($210,$220,$230,$240,$250,$260,$270,$280), {SB Pro}
        ($210,$220,$230,$240,$250,$260,$270,$280), {SB 16ASP}
        ($200,$210,$220,$230,$240,$250,$260,$270), {GUS}
        ($288,$280,$284,$28C,$388,$384,$38C,0),    {PAS}
        ($530,$604,$E80,$F40,0,0,0,0),             {CODEC}
        ($280,$290,$2A0,$2B0,0,0,0,0)              {ARIA});
function id(card_,port_:word):word;
var k:word;
begin
  id:=1; for k:=1 to 8 do if port_=list[card_,k] then begin id:=k; exit end;
end;
begin
  itms:=0;
  for u:=1 to 8 do if list[card_,u]<>0 then inc(itms);
  setbordertype(5);
  definemenu(m,30,12,20,itms+2,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' Base port ',0);
  for u:=1 to itms do additem(m,'       '+dec2hex(list[card_,u]),true);
  o:=activatemenu(m,id(card_,base_));
  if not (o=$FFFF) then base_:=list[card_,o];
  killmenu(m);
end;

procedure SelectRate(var card_,rate_:word);
var m:menutype; o:word;
const list : array[1..15] of word = (8000,10000,11025,15000,17000,19000,22050,25000,27000,29000,33000,37000,40000,44100,48000);
function id(frq:word):word;
var k:word;
begin
  id:=1; for k:=1 to 15 do if frq=list[k] then begin id:=k; exit end;
end;
var u:word; as:string;
begin
  setbordertype(2);
  mwindow(1,3,42,10,$4F,true);
  twindow('[ Remark ]',4);
  wtext(1,1,' The mixing rate directly affects the',$4E);
  wtext(1,2,' quality of the output sound, and',$4E);
  wtext(1,3,' therefore, the greater the rate, the',$4E);
  wtext(1,4,' better the sound quality will be. The',$4E);
  wtext(1,5,' best sound quality is given by a',$4E);
  wtext(1,6,' mixing rate of 48 kHz (CODEC only),',$4E);
  wtext(1,7,' though almost all sound cards support',$4E);
  wtext(1,8,' up to 44.1 kHz',$4E);
  setbordertype(5);
  definemenu(m,41,6,35,17,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' Mixing Rate (Hz) ',0);
  for u:=1 to 15 do begin
    if u=1 then as:='   (poor quality)' else
    if u=7 then as:='(medium quality)' else
    if u=11 then as:=' (good quality)' else
    if u=14 then as:=' (high quality)' else
    if u=15 then as:='    (excellent)' else as:='';
    additem(m,'    '+istr(list[u])+' Hz '+as,true);
    if list[u]>44100 then if card_<>6 then toggleitem(m,u,false);
  end;
  o:=activatemenu(m,id(rate_));
  if not (o=$FFFF) then rate_:=list[o];
  killmenu(m);
  rwindow;
end;

const plist : array [0..1] of string[5] = ('NTSC',' PAL');
      olist : array [0..1] of string[5] = (' Off','  On');
      ylist : array [0..1] of string[5] = ('  No',' Yes');

procedure SetSwitches(card_:word; var Pal:byte; var Surround,EMS_,UMB_:boolean);
var m:menutype;
    o:word; gata:boolean;
begin
  setbordertype(5);
  definemenu(m,20,10,40,6,$1F,$1B,$13,$F0,$78,true);
  wcolor($1E);
  twindow(' Switches ',0);
  additem(m,' Frequency mode                 '+plist[pal],(card_<>4) and (card<>8));
  additem(m,' SURROUND mode                  '+olist[byte(surround)],(card<>8) and (card_<>4));
  additem(m,' Use EMS for samples            '+ylist[byte(EMS_)],(card_<>4) and emsDetect);
  additem(m,' Use UMB for patterns           '+ylist[byte(UMB_)],true);
  gata:=false; o:=1;
  repeat
    o:=activatemenu(m,o);
    if (o=$FFFF) or (MenuLeftWith=#13) then gata:=true else begin
      case o of
        1 : begin Pal:=1-Pal; changeItem(m,o,' Frequency mode                 '+plist[pal],true); end;
        2 : begin Surround:=not Surround; changeItem(m,o,' SURROUND mode                  '+olist[byte(Surround)],true); end;
        3 : begin EMS_:=not EMS_; changeItem(m,o,' Use EMS for samples            '+ylist[byte(EMS_)],true); end;
        4 : begin UMB_:=not UMB_; changeItem(m,o,' Use UMB for patterns           '+ylist[byte(UMB_)],true); end;
      end;
    end;
  until gata;
  killmenu(m);
end;

function rname(s:string):string;
begin
  rname:=copy(s,1,length(s)-3);
end;

procedure SDS_Setup(var Card_,Irq_,Dma_,Base_,Rate_,Gain_:word; var Pal:byte;
                  var Surround, EMS_, UMB_ : boolean);
var m:menutype; gata:boolean;
    o:word;
begin
  desktop;
  setbordertype(4);
  mwindow(2,19,76,5,$1F,false);{ settings window }
  twindow('[ Settings ]',1);{checked ok}
  setbordertype(3);
  definemenu(m,15,5,50,11,lightblue,lightgreen,lightblue,$F2,$F9,true);
  twindow(' ю Sound Setup ю ',0);
  additem(m,'             Sound card detection',true);
  additem(m,'               Choose sound card',true);
  additem(m,'               Choose base port',true);
  additem(m,'                   Choose IRQ',true);
  additem(m,'               Choose DMA channel',true);
  additem(m,'                Set mixing rate',true);
  additem(m,'              Set real-time gain',true);
  additem(m,'                    Switches',true);
  additem(m,'          Save settings and Run Relativity',true);
  gata:=false;
  o:=2;
  { defaults }
  if (card_<1) or (card_>8) then card_:=8;
  if base_=0 then base_:=$378;
  if gain_<100 then gain_:=100;
  { uugghhh... }
  repeat
    gwtext(4,20,rname(scNames[card_])+space(73-length(rname(scNames[card_]))),$1A);
    gwtext(4,21,' Base port '+dec2hex(base_)+'h, using IRQ'+istr(irq_)+' and DMA channel #'+istr(dma_)+
                ', Mixing rate '+istr(rate_)+' Hz    ',$1E);
    gwtext(4,22,' Gain '+istr(gain_-100)+'%, SURROUND'+olist[byte(surround)]+', EMS usage'+olist[byte(ems_)]+
                ', UMB usage'+olist[byte(umb_)]+', '+plist[pal]+' mode.   ',$1E);

    toggleItem(m,3,not(card_=8));
    toggleItem(m,4,not(card_=8));
    toggleItem(m,5,not(card_=8));
    toggleItem(m,6,not(card_=4));
    toggleItem(m,7,not((card_=8) or (card_=4)));
    o:=activatemenu(m,o);
    gata:=(o=9) or (o=$FFFF);
    if not gata then begin
      case o of
        1 : SDDet(card_,irq_,dma_,base_,rate_);
        2 : SelectSC(card_);
        3 : SelectBase(card_,base_);
        4 : SelectIRQ(irq_);
        5 : SelectDMA(dma_);
        6 : SelectRate(card_,rate_);
        7 : SelectGain(gain_);
        8 : SetSwitches(card_,Pal,Surround,EMS_,UMB_);
      end;
      {inc(o);{} {avansare automata Њn jos...}
    end;
  until gata;
  killmenu(m);
  rwindow;
  closedesktop;
end;

begin
  asm
    mov ah,$10
    mov al,3
    mov bl,0
    int 10h  {use high intensity, do not blink}
  end;
  LastWin:=Nil;
  SetBorderType(1);
end.