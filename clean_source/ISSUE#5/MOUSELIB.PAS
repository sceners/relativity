(******************************************************************************
*                                  MouseLib                                   *
* Release 7.0 - Added demo program - Please refer to MOUSETST.PAS to                       *
* see a demo of the mouseLib unit usage.                                                                             *
******************************************************************************)
unit MouseLib;
{$ifdef ovl}
   {$F+}
{$endif}
interface

uses 
	dos
   ,tpDESQ { DESQview support unit }
   ,video  { video supprot unit }
	;

const
	MOUSEINT = $33; {mouse driver interrupt}
	LEFTBUTTON = 1; {bit 0}
	RIGHTBUTTON = 2; {bit 1}
	MIDDLEBUTTON = 4; {bit 2}

	CURSOR_LOCATION_CHANGED = 1; {event mask bits}
	LEFT_BUTTON_PRESSED = 2;
	LEFT_BUTTON_RELEASED = 4;
	RIGHT_BUTTON_PRESSED = 8;
	RIGHT_BUTTON_RELEASED = 16;
	MIDDLE_BUTTON_PRESSED = 32;
	MIDDLE_BUTTON_RELEASED = 64;

type
	mouseType = (twoButton,threeButton,another);
	buttonState = (buttonDown,buttonUp);
	direction = (moveRight,moveLeft,moveUp,moveDown,noMove);
	grCursorType = record
		xH,yH : byte; {x,y Hot Point}
		data  : pointer;  {cursor look pointer}
	end;
var
	mouse_present : boolean;
	mouse_buttons : mouseType;
	eventX,eventY,eventButtons : word; {any event handler should update}
	eventhappened : Boolean;	   {these vars to use getLastEvent }
	XMotions,YMotions : word;	   {per 8 pixels}
	mouseCursorLevel : integer;
	{if > 0 mouse cursor is visiable, otherwise not, containes the level
	 of showMouseCursor/hideMouseCursor}
   fontPoints : byte;
var
	maxMouseX 	: integer; 
	maxMouseY	: integer; 

const	LastMask : word = 0;
	lastHandler : pointer = Nil;

	{when changing the interrupt handler temporarily, save BEFORE the
		change these to variables, and restore them when neccessary}

	lastCursor : grCursorType = (
		xH : 0;
		yH : 0;
		data : nil );

	{when changing graphic cursor temporarily, save these values BEFORE
		the change, and restore when neccessary}

const
   click_repeat  = 10; { Recommended value for waitForRelease timeOut }
	mouseTextScale = 8;
(*****	mouse scale factor in text *****)
   vgaTextGraphicCursor : boolean = false; { this is not the default .. }

procedure initMouse; {when replacing mouse mode do that..!}
procedure showMouseCursor;
procedure hideMouseCursor;
function getMouseX : word;
function getMouseY : word;
function getButton(Button : Byte) : buttonState;
function buttonPressed : boolean;
procedure setMouseCursor(x,y : word);
function LastXPress(Button : Byte) : word;
function LastYPress(Button : Byte) : word;
function ButtonPresses(Button : Byte) : word; {from last last check}
function LastXRelease(Button : Byte) : word;
function LastYRelease(Button : Byte) : word;
function ButtonReleases(Button : Byte) : word; {from last last check}
procedure mouseBox(left,top,right,bottom : word); {limit mouse rectangle}
procedure graphicMouseCursor(xHotPoint,yHotPoint : byte; dataOfs : pointer);
procedure HardwareTextCursor(fromLine,toLine : byte);
procedure softwareTextCursor(screenMask,cursorMask : word);
function recentXmovement : direction;
function recentYmovement : direction;
procedure setArrowCursor;
procedure setWatchCursor;
procedure setUpArrowCursor;
procedure setLeftArrowCursor;
procedure setCheckMarkCursor;
procedure setPointingHandCursor;
procedure setDiagonalCrossCursor;
procedure setRectangularCrossCursor;
procedure setHourGlassCursor;
procedure setNewWatchCursor;
procedure setEventHandler(mask : word; handler	: pointer);
procedure setDefaultHandler(mask : word);
procedure enableLightPenEmulation;
procedure disableLightPenEmulation;
procedure defineSensetivity(x,y : word);
procedure setHideCursorBox(left,top,right,bottom : word);
procedure defineDoubleSpeedTreshHold(treshHold : word);
procedure disableTreshHold;
procedure defaultTreshHold;
procedure setMouseGraph;
procedure resetMouseGraph;
procedure waitForRelease(timeOut : word);
procedure swapEventHandler(mask : word; handler : pointer); 
{ return old in lastMask and lastHandler }
function getMouseSaveStateSize : word;
procedure interceptMouse; { get mouse from interrupted program, and stop it .. }
procedure restoreMouse;
procedure setVgaTextGraphicCursor;
procedure resetVgaTextGraphicCursor;

(******************************************************************************
*                                  MouseLib                                   *
*                                                                             *
* mouseLib     -      Release 2	and above                  *
* 								*
*  because of quirks in hercules graphic mode that is not detectable          *
*   by the mouse driver we have to know when we initMouse if we want          *
*   to check for graphic mode or not, if we do we must perform a*
*   setMouseGraph before initGraph, to initGraph in text mode we must         *
*   resetMouseGraph before.. , if these calling conventions are not           *
*   taken we might have problems in hercules cards!			*
* *
*  each call to hideMouseCursor must be balanced by a matching call           *
*   to showMouseCursor, 2 calls to hideMou.. and only 1 to showM..	      *
*   will not show the mouse cursor on the screen!						            *
* *
*  if we want to use the text "graphic" mouse, we must perform a              *
*   setVgaTextGraphicCursor call before we call initMouse ...                 *
******************************************************************************)

implementation

{$ifdef ver60}
const
   seg0040 = $40; { needed - in Ver7.0 points to bios area, 
                             needed so protected mode will not crash on
                             RT-error 216 (exception 13 }
   segB800 = $b800;
   segA000 = $a000;
{$endif}   

const watchData : array [0..31] of word =
	($E007,$C003,$8001,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$8001,$C003,$E007,
	 $0,$1FF8,$318C,$6186,$4012,$4022,$4042,$718C,$718C,$4062,$4032,
	 $4002,$6186,$318C,$1FF8,$0);

const arrowData : array [0..31] of word =
	($FFFF,$8FFF,$8FFF,$87FF,$83FF,$81FF,$80FF,$807F,$803F,$801F,$800F,
	 $801F,$807F,$887F,$DC3F,$FC3F,
	 $0,$0,$2000,$3000,$3800,$3C00,$3E00,$3F00,$3F80,$3FC0,
	 $3FE0,$3E00,$3300,$2300,$0180,$0180);

const UpArrowCursor : array [0..31] of word =
         ($f9ff,$f0ff,$e07f,$e07f,$c03f,$c03f,$801f,$801f,
          $f,$f,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,
          $0,$600,$f00,$f00,$1f80,$1f80,$3fc0,$3fc0,
          $7fe0,$600, $600, $600, $600, $600, $600, $600);

const  LeftArrowCursor : array [0..31] of word
       = ($fe1f,$f01f,$0,   $0,   $0,   $f01f,$fe1f,$ffff,
          $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $c0,  $7c0, $7ffe,$7c0, $c0,  $0,   $0,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);

const  CheckMarkCursor : array [0..31] of word
       = ($fff0,$ffe0,$ffc0,$ff81,$ff03,$607, $f,   $1f,
          $c03f,$f07f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $6,   $c,   $18,  $30,  $60,  $70c0,$1d80,
          $700, $0,   $0,   $0,   $0,   $0,   $0,   $0);

const  PointingHandCursor : array [0..31] of word
       = ($e1ff,$e1ff,$e1ff,$e1ff,$e1ff,$e000,$e000,$e000,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0,
          $1e00,$1200,$1200,$1200,$1200,$13ff,$1249,$1249,
          $f249,$9001,$9001,$9001,$8001,$8001,$8001,$ffff);

const  DiagonalcrossCursor : array [0..31] of word
       = ($7e0, $180, $0,   $c003,$f00f,$c003,$0,   $180,
          $7e0, $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $700e,$1c38,$660, $3c0, $660, $1c38,$700e,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);

const  
   RectangularCrossCursor : array [0..31] of word
       = ($fc3f,$fc3f,$fc3f,$0,$0,   $0,   $fc3f,$fc3f,
          $fc3f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $180, $180, $180, $7ffe,$180, $180, $180,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);

const  
   HourglassCursor : array [0..31] of word
       = ($0,   $0,   $0,   $0,   $8001,$c003,$e007,$f00f,
          $e007,$c003,$8001,$0,   $0,   $0,   $0,   $ffff,
          $0,   $7ffe,$6006,$300c,$1818,$c30, $660, $3c0,
          $660, $c30, $1998,$33cc,$67e6,$7ffe,$0,   $0);

const 
   newWatchCursor : array [0..31] of word
       = ( $ffff, $c003, $8001, $0, $0, $0, $0, $0, $0, 
           $0, $0, $0, $0, $8001, $c003, $ffff, $0, $0, 
           $1ff8, $2004, $4992, $4022, $4042, $518a, $4782, 
           $4002, $4992, $4002, $2004, $1ff8, $0, $0 );

(* these are the screen and cursor masks for vgaTextGraphicCursor mode, we
   save them in screen (16 .. ) cursor (16 .. ) order *)

const 
   vgaArrowData : array [ 0 .. 31 ] of longint = 
   ( $3fffffff, $1fffffff, $0fffffff, $07ffffff, $03ffffff, $01ffffff,
     $00ffffff, $007fffff, $003fffff, $007fffff, $01ffffff, $10ffffff,
     $b0ffffff, $f87fffff, $f87fffff, $fcffffff, (* now cursor *)
     $00000000, $40000000, $60000000, $70000000, $78000000, $7c000000,
     $7e000000, $7f000000, $7f800000, $7f000000, $7c000000, $46000000,
     $06000000, $03000000, $03000000, $00000000);

type
   vgaTextGraphicArrayPtr = ^ vgaTextGraphicArray;
   vgaTextGraphicArray = array [ 0 .. 31 ] of longint;

const 
   vgaTextGraphicPtr : vgaTextGraphicArrayPtr = @vgaArrowData;

const 
   mouseGraph : boolean = false; {assume text mode upon entry}

type box = record
		left,top,right,bottom : word;
	end; {Do not change field order !!!}

   charDefsTypePtr = ^ charDefsType;
   charDefsType = array[0 .. (32 * 8)] of byte;

var 
   hideBox : box;
   reg : registers;  {general registers used}
   grMode,
   grDrv : integer; {detect graphic mode if any}
   grCode : integer;     {return initgraph code in here}
   interceptX, 
   interceptY : word;
   VGAStoredArray : array [ 1 .. 3, 1 .. 3 ] of byte; 
   { in vgaTextGraphicCursor mode we change up to 9 characters, on the fly .. 
     here we save them }
   lastEventX, lastEventY : word; { in vgaTextGraphicCursor mode, we need 
                                    the last ... }
   hasStoredArray : boolean; { true when need to restore screen in vgaGrTxtCrsr mode }

const
   charDefs : charDefsTypePtr = nil;

   charHeight = 16;  { character height }
   defChar    = $d0; { character range that will be changed on the fly .. }

(******************************************************************************
*                                  callMouse                                  *
*                                                                             *
* used to call mouse interrupt with global data reg - used as parameters      *
******************************************************************************)
procedure callMouse;
begin
		intr(MOUSEINT,REG);
end; {callMouse}

(******************************************************************************
*                                  initMouse                                  *
* For some reason grCode is assigned a value of -11,($FFF5) in the second time*
*  we call initmouse after we allready are in graphics mode, override.. was   *
*  born because of that situation.                                            *
******************************************************************************)
procedure initMouse;
var
    overRideDriver : boolean; { true if we over-ridden stupid driver hercules bug }
    tempVideoMode  : byte;
begin
   overRideDriver := false;
   if (mouseGraph and (mem[seg0040:$49] = 7)) then begin { assume no mda - hercules }
	   mem[seg0040:$49] := 6;
      overRideDriver := true;
   end; {trick stupid mouse driver to know we are in graphic mode}
   if (vgaTextGraphicCursor) then begin
      tempVideoMode := mem[seg0040:$49];
	   mem[seg0040:$49] := 6; { pixel movements of 1 ... }
   end; { vgaTextGraphicCursor .. }
	with reg do begin
		ax:=0; {detect genius mouse}
		bx:=0; {be sure what mode we get}
		callMouse;
		mouse_present := (ax <> 0); {not an iret..}
		if ((bx and 2) <> 0)
			then mouse_buttons := twoButton
		else if ((bx and 3) <> 0)
			then mouse_buttons := threeButton
		else mouse_buttons := another; {unknown to us}
	end; {with}
   if (overRideDriver) then
	   mem[seg0040:$49] := 7; {restore the stupid situation}
   if (vgaTextGraphicCursor) then begin
      mem[seg0040:$49] := tempVideoMode; { restore for later use ... }
   end;
   if (not vgaTextGraphicCursor) then
      fontPoints := mouseTextScale { bios rows }
   else
      fontPoints := mem[seg0040:$85];
   maxMouseX := maxX * mouseTextScale;
   maxMouseY := maxY * fontPoints;
   mouseBox(0, 0, visibleX * mouseTextScale - 1, visibleY * fontPoints -1);
   eventButtons := 0;
   eventhappened := False;
   XMotions := 8;
   YMotions := 16;
   mouseCursorLevel := 0; { not visiable, one show to appear }
   hasStoredArray := false; { we have no saved array for vgaTextGraphicCursor mode }
   setMouseCursor(visibleX * mouseTextScale div 2, visibleY * fontPoints div 2);
   eventX := getMouseX;
   eventY := getMouseY;
   lastEventX := eventX;
   lastEventY := eventY;
(*   setMouseCursor(0, 0); *)
end; {initMouse}

(******************************************************************************
*                               VGAscreen2Array                               *
* copy our screen saved array, before fonts are changed ..                    *
* if newPosition is true, use eventX, eventY, otherwise - use lastEventX and  *
* lastEventY                                                                  *
* defaultRange = true -> draw changed on the fly, otherwise , regard s2a ..   *
* s2a = screen2Array if true, array to screen otherwise ..                    *
******************************************************************************)
procedure VGAscreen2Array(newPosition, s2a, defaultRange : boolean);
var
   x, y : word;
   w, h : word; { width and height of array .. }
   o, l : word; { o - offset into screen, l = line size in bytes, in display }
   i, j : byte;
begin
   if (newPosition) then begin
      x := eventX div mouseTextScale;
      y := eventY div fontPoints;
   end else begin
      x := lastEventX  div mouseTextScale;
      y := lastEventY div fontPoints;
   end;
   w := visibleX - x;
   if (w > 3) then
      w := 3; { just double checking ... }
   h := visibleY - y;
   if (h > 3) then
      h := 3;
   o := 2 * x + 2 * visibleX * y; { 2 bytes per character -> char + attribute }
   l := 2 * visibleX - 2 * w; { add when screen line overlap ... }
   if (defaultRange) then begin
      for i := 0 to h - 1 do begin
         for j := 0 to w - 1 do begin
            mem[segb800:o] := defChar + i * 3 + j;
            inc(o, 2);
         end; { for j .. }
         inc(o, l); { next line .. }
      end; { for i }
   end else 
      if (s2a) then begin { copy screen 2 array }
         for i := 1 to h do begin
            for j := 1 to w do begin
               VGAStoredArray[i, j] := mem[segb800:o];
               inc(o, 2); { next character }
            end; { for j .. }
            inc(o, l); { next line .. }
         end; { for i .. }
      end else begin {copy array 2 screen }
         for i := 1 to h do begin
            for j := 1 to w do begin
               mem[segb800:o] := VGAStoredArray[i, j];
               inc(o, 2); { next character }
            end; { for j .. }
            inc(o, l); { next line .. }
         end; { for i .. }
      end; { if s2a .. }
end; {VGAscreen2Array}

(******************************************************************************
*                          drawVGATextGraphicCursor                           *
* here we do the black magic of putting it on the screen !                    *
* this code is based on the code presented by Dave Kirsch, in his MOU code,   *
* which was ported by Duncan Murdoch. This code was changed to be integrated  *
* into the mouseLib unit, and enhanced where possible.                        *
******************************************************************************)
procedure drawVGATextGraphicCursor;
type
   lp = ^ longint;
const
   sequencerPort     = $3c4;
   sequencerAddrMode = $704;
   sequencerAddrNrml = $302; { write maps 0, 1 }
   vgaControlerPort  = $3ce;
   cpuReadMap2       = $204;
   cpuWriteMap2      = $402;
   mapStartAddrA000  = $406;
   mapStartAddrB800  = $e06;
   oddEvenAddr       = $304;
var
   o, s        : word;
   i, j        : integer;
   s1, s2, s3  : word;
   a           : longint;
   d, mc, ms   : lp;
begin
{ we already have stored in vgaStoredArray what we have to store .. }
   asm
      pushf;
      cli;   { disable interrupts }
      mov dx, sequencerPort;
      mov ax, sequencerAddrMode;
      out dx, ax;

      mov dx, vgaControlerPort;
      mov ax, cpuReadMap2;
      out dx, ax

      mov ax, 5
      out dx, ax { disable odd-even addr mode }
      mov ax, mapStartAddrA000;
      out dx, ax;
      popf;
   end; { asm }

   (* now copy character def. tables for the characters changed on the fly *)

   o := 0;
   for i := 1 to 3 do begin
      s1 := VGAStoredArray[i, 1] * 32;
      s2 := VGAStoredArray[i, 2] * 32;
      s3 := VGAStoredArray[i, 3] * 32;
      for j := 1 to fontPoints do begin
         inc(o); { skip 4th byte }
         charDefs^[o] := mem[segA000:s3]; 
            { this code is changed to minimize DS variable space ! - RL }
         inc(o);
         charDefs^[o] := mem[segA000:s2];
         inc(o);
         charDefs^[o] := mem[segA000:s1];
         inc(o);
         inc(s1);
         inc(s2);
         inc(s3);
      end; { for j }
   end; { for i } 

   (* now we are Drawing the cursor by ANDing with the screenMask, 
      and ORing with the cursor mask *)

   s := eventX mod mouseTextScale; { shift calc .. }
   a := $ff000000 shl (mouseTextScale - s);

   (* now we have the shift and additive mask .. *)

   d := @chardefs^[(eventY mod fontPoints) * sizeof(longint)];
   ms := @vgaTextGraphicPtr^;
   mc := @vgaTextGraphicPtr^[charHeight];
   for i := 1 to charHeight do begin
      d^ := (d^ and ((ms^ shr s) or a)) or (mc^ shr s);
      inc(word(d), sizeof(longint)); { we change only the offset of the pointer }
      inc(word(mc), sizeof(longint)); { we change only the offset of the pointer }
      inc(word(ms), sizeof(longint)); { we change only the offset of the pointer }
   end; { for i .. } 
   (* here we ANDed with the screen mask, and ORed with the cursor mask *)

   asm
      mov dx, sequencerPort;
      mov ax, cpuWriteMap2;
      out dx, ax
   end;

   o := 0;
   for i := 0 to 2 do begin
      s1 := (defChar + 3 * i    ) * 32;
      s2 := (defChar + 3 * i + 1) * 32;
      s3 := (defChar + 3 * i + 2) * 32;
      for j := 1 to fontPoints do begin
         inc(o); { skip 4th byte }
         mem[segA000:s3] := charDefs^[o]; 
            { this code is changed to minimize DS variable space ! - RL }
         inc(o);
         mem[segA000:s2] := charDefs^[o];
         inc(o);
         mem[segA000:s1] := charDefs^[o];
         inc(o);
         inc(s1);
         inc(s2);
         inc(s3);
      end; { for j }
   end; { for i }

   (* now we will return the graphic adapter back to normal *)

   asm
      pushf;
      cli; { disable intr .. }
      mov dx, sequencerPort;
      mov ax, sequencerAddrNrml;
      out dx, ax;
      mov ax, oddEvenAddr;
      out dx, ax;

      mov dx, vgaControlerPort;
      mov ax, 4; { map 0 for cpu reads }
      out dx, ax;
      mov ax, $1005;
      out dx, ax;
      mov ax, mapStartAddrB800;
      out dx, ax
      popf;
   end; { asm }

   vgaScreen2Array(true, false, true); { go ahead and paint it .. }

end; {drawVGATextGraphicCursor}

(******************************************************************************
*                               showMouseCursor                               *
******************************************************************************)
procedure showMouseCursor;

begin
	inc(mouseCursorLevel);
   if (not vgaTextGraphicCursor) then begin
	   reg.ax:=1; {enable cursor display}
	   callMouse;
   end else if ((mouseCursorLevel = 1) and mouse_present) then begin
      vgaScreen2Array(true, true, false);
      hasStoredArray := true;
      drawVGATextGraphicCursor;
   end;
end; {showMouseCursor}

(******************************************************************************
*                               hideMouseCursor                               *
******************************************************************************)
procedure hideMouseCursor;

begin
	dec(mouseCursorLevel);
   if (not vgaTextGraphicCursor) then begin
	   reg.ax:=2; {disable cursor display}
	   callMouse;
   end else if ((mouseCursorLevel = 0) and (hasStoredArray)) then begin
      vgaScreen2Array(false, false, false);
      hasStoredArray := false;
   end;
end; {hideMouseCursor}

(******************************************************************************
*                                  getMouseX                                  *
******************************************************************************)
function getMouseX : word;

begin
	reg.ax := 3;
	callMouse;
	getMouseX := reg.cx;
end; {getMouseX}

(******************************************************************************
*                                  getMouseY                                  *
******************************************************************************)
function getMouseY : word;

begin
	reg.ax := 3;
	callMouse;
	getMouseY := reg.dx;
end; {getMouseX}

(******************************************************************************
*                                  getButton                                  *
******************************************************************************)
function getButton(Button : Byte) : buttonState;

begin
	reg.ax := 3;
	callMouse;
	if ((reg.bx and Button) <> 0) then
		getButton := buttonDown
		{bit 0 = left, 1 = right, 2 = middle}
	else getButton := buttonUp;
end; {getButton}

(******************************************************************************
*                                buttonPressed                                *
******************************************************************************)
function buttonPressed : boolean;

begin
	reg.ax := 3;
	callMouse;
	if ((reg.bx and 7) <> 0) then
		buttonPressed := True
	else buttonPressed := False;
end; {buttonPressed}

(******************************************************************************
*                               setMouseCursor                                *
******************************************************************************)
procedure setMouseCursor(x,y : word);

begin
	with reg do begin
		ax := 4;
		cx := x;
		dx := y; {prepare parameters}
		callMouse;
	end; {with}
end; {setMouseCursor}

(******************************************************************************
*                                 lastXPress                                  *
******************************************************************************)
function lastXPress(Button : Byte) : word;

begin
	reg.ax := 5;
	reg.bx := Button;
	callMouse;
	lastXPress := reg.cx;
end; {lastXpress}

(******************************************************************************
*                                 lastYPress                                  *
******************************************************************************)
function lastYPress(Button : Byte) : word;

begin
	reg.ax := 5;
	reg.bx := Button;
	callMouse;
	lastYPress := reg.dx;
end; {lastYpress}

(******************************************************************************
*                                buttonPresses                                *
******************************************************************************)
function buttonPresses(Button : Byte) : word; {from last check}

begin
	reg.ax := 5;
	reg.bx := Button;
	callMouse;
	buttonPresses := reg.bx;
end; {buttonPresses}

(******************************************************************************
*                                lastXRelease                                 *
******************************************************************************)
function lastXRelease(Button : Byte) : word;

begin
	reg.ax := 6;
	reg.bx := Button;
	callMouse;
	lastXRelease := reg.cx;
end; {lastXRelease}

(******************************************************************************
*                                lastYRelease                                 *
******************************************************************************)
function lastYRelease(Button : Byte) : word;

begin
	reg.ax := 6;
	reg.bx := Button;
	callMouse;
	lastYRelease := reg.dx;
end; {lastYRelease}

(******************************************************************************
*                               buttonReleases                                *
******************************************************************************)
function buttonReleases(Button : Byte) : word; {from last check}

begin
	reg.ax := 6;
	reg.bx := Button;
	callMouse;
	buttonReleases := reg.bx;
end; {buttonReleases}

(******************************************************************************
*                                    swap                                     *
******************************************************************************)
procedure swap(var a,b : word);

var c : word;

begin
	c := a;
	a := b;
	b := c; {swap a and b}
end; {swap}

(******************************************************************************
*                                  mouseBox                                   *
******************************************************************************)
procedure mouseBox(left,top,right,bottom : word);

begin
	if (left > right) then swap(left,right);
	if (top > bottom) then swap(top,bottom); {make sure they are ordered}
	reg.ax := 7;
	reg.cx := left;
	reg.dx := right;
	callMouse; {set x range}
	reg.ax := 8;
	reg.cx := top;
	reg.dx := bottom;
	callMouse; {set y range}
end; {mouseBox}

(******************************************************************************
*                             graphicMouseCursor                              *
******************************************************************************)
procedure graphicMouseCursor(xHotPoint,yHotPoint : byte; dataOfs : pointer);

{define 16*16 cursor mask and screen mask, pointed by data,
	dataOfs is pointer to data of the masks.}

begin
	reg.ax := 9;
	reg.bx := xHotPoint;
	reg.cx := yHotPoint;
	reg.dx := ofs(dataOfs^);	{DS:DX point to masks}
	reg.es := seg(dataOfs^);
	callMouse;
	lastCursor.xH := xHotPoint;
	lastCursor.yH := yHotPoint;
	lastCursor.data := dataOfs;
	{save it in lastCursor, if someone needs to change cursor temporary}
end; {graphicMouseCursor}

(******************************************************************************
*                             HardwareTextCursor                              *
******************************************************************************)
procedure HardwareTextCursor(fromLine,toLine : byte);

{set text cursor to text, using the scan lines from..to,
	same as intr 10 cursor set in bios :
	color scan lines 0..7, monochrome 0..13 }

begin
	reg.ax := 10;
	reg.bx := 1; {hardware text}
	reg.cx := fromLine;
	reg.dx := toLine;
	callMouse;
end; {hardwareTextCursor}

(******************************************************************************
*                             softwareTextCursor                              *
******************************************************************************)
procedure softwareTextCursor(screenMask,cursorMask : word);

{ when in this mode the cursor will be achived by ANDing the screen word
	with the screen mask (Attr,Char in high,low order) and
	XORing the cursor mask, ussually used by putting the screen attr
	we want preserved in screen mask (and 0 into screen mask character
	byte), and character + attributes we want to set into cursor mask}

begin
	reg.ax := 10;
	reg.bx := 0;	{software cursor}
	reg.cx := screenMask;
	reg.dx := cursorMask;
	callMouse;
end; {softwareMouseCursor}

(******************************************************************************
*                               recentXmovement                               *
******************************************************************************)
function recentXmovement : direction;

{from recent call to which direction did we move ?}

var d : integer;

begin
	reg.ax := 11;
	callMouse;
	d := reg.cx;
	if (d > 0)
		then recentXmovement := moveRight
	else if (d < 0)
		then recentXmovement := moveLeft
	else recentXmovement := noMove;
end; {recentXmovement}

(******************************************************************************
*                               recentYmovement                               *
******************************************************************************)
function recentYmovement : direction;

{from recent call to which direction did we move ?}

var 
   d : integer;
begin
	reg.ax := 11;
	callMouse;
	d := reg.dx;
	if (d > 0)
		then recentYmovement := moveDown
	else if (d < 0)
		then recentYmovement := moveUp
	else recentYmovement := noMove;
end; {recentYmovement}

(******************************************************************************
*                               setWatchCursor                                *
******************************************************************************)
procedure setWatchCursor;
begin
	graphicMouseCursor(0,0,@watchData);
end; {setWatchCursor}

(******************************************************************************
*                              setNewWatchCursor                              *
******************************************************************************)
procedure setNewWatchCursor; 
begin
   graphicMouseCursor(0, 0, @newWatchCursor);
end; {setNewWatchCursor}

(******************************************************************************
*                              setUpArrowCursor                               *
******************************************************************************)
procedure setUpArrowCursor;
begin
	graphicMouseCursor(5, 0, @upArrowCursor);
end; {setUpArrowCursor}

(******************************************************************************
*                             setLeftArrowCursor                              *
******************************************************************************)
procedure setLeftArrowCursor;
begin
	graphicMouseCursor(0, 3, @leftArrowCursor);
end; {setLeftArrowCursor}

(******************************************************************************
*                             setCheckMarkCursor                              *
******************************************************************************)
procedure setCheckMarkCursor;
begin
	graphicMouseCursor(6, 7, @checkMarkCursor);
end; {setCheckMarkCursor}

(******************************************************************************
*                            setPointingHandCursor                            *
******************************************************************************)
procedure setPointingHandCursor;
begin
	graphicMouseCursor(5, 0, @pointingHandCursor);
end; {setPointingHandCursor}

(******************************************************************************
*                           setDiagonalCrossCursor                            *
******************************************************************************)
procedure setDiagonalCrossCursor;
begin
	graphicMouseCursor(7, 4, @diagonalCrossCursor);
end; {setDiagonalCrossCursor}

(******************************************************************************
*                          setRectangularCrossCursor                          *
******************************************************************************)
procedure setRectangularCrossCursor;
begin
	graphicMouseCursor(7, 4, @rectangularCrossCursor);
end; {setRectangularCrossCursor}

(******************************************************************************
*                             setHourGlassCursor                              *
******************************************************************************)
procedure setHourGlassCursor;
begin
	graphicMouseCursor(7, 7, @hourGlassCursor);
end; {setHourGlassCursor}

(******************************************************************************
*                               setArrowCursor                                *
******************************************************************************)
procedure setArrowCursor;
begin
	graphicMouseCursor(1,1,@arrowData);
end; {setArrowCursor}

(******************************************************************************
*                               setEventHandler                               *
******************************************************************************)
procedure setEventHandler(mask : word; handler	: pointer);

{handler must be a far interrupt routine }

begin
	reg.ax := 12; {set event handler function in mouse driver}
	reg.cx := mask;
	reg.es := seg(handler^);
	reg.dx := ofs(handler^);
	callMouse;
	lastMask := mask;
	lastHandler := handler;
end; {set event Handler}

(******************************************************************************
*                               defaultHandler                                *
******************************************************************************)
{$F+} procedure defaultHandler; assembler; {$F-}
asm
   push ds; { save TP mouse driver }
   mov ax, SEG @data;
   mov ds, ax; { ds = TP:ds, not the driver's ds }
   mov eventX, cx; { where in the x region did it occur }
   mov eventY, dx;
   mov eventButtons, bx;
   mov eventHappened, 1; { eventHapppened := true }
   pop ds; { restore driver's ds }
   ret;
end;

{   this is the default event handler , it simulates :

      begin
	       eventX := cx;
	       eventY := dx;
	       eventButtons := bx;
	       eventhappened := True;
      end;

}

(******************************************************************************
*                                doPascalStuff                                *
* this is the pascal stuff that is called when vgaTextGraphicCursor mode has  *
* to update the screen.                                                       *
******************************************************************************)
procedure doPascalStuff; far;
begin
   if (mouseCursorLevel > 0) then begin
      if (hasStoredArray) then begin
         VGAscreen2Array(false, false, false); { move old array to screen - restore }
         hasStoredArray := false;
      end;
      if (mouseCursorLevel > 0) then begin
         VGAscreen2Array(true, true, false); { move new - from screen to array }
         hasStoredArray := true; { now we have a stored array }
         drawVGATextGraphicCursor; { do the low level stuff here }
         lastEventX := eventX;
         lastEventY := eventY; { this is the old location }
      end; { go ahead and draw it ... }
   end; { cursorLevel > 0 }
end; {doPascalStuff}

(******************************************************************************
*                            vgaTextGraphicHandler                            *
* this is the same as default handler, only we do the mouse location movement *
* ourself. Notice - if you use another handler, for mouse movement with       *
* VGA text graphic cursor - do the same !!!                                   *
******************************************************************************)
procedure vgaTextGraphicHandler; far; assembler;
label
   noCursorMove;
asm
   push ds; { save TP mouse driver }
   push ax;
   mov ax, SEG @data;
   mov ds, ax; { ds = TP:ds, not the driver's ds }
   pop ax; { ax has the reason .. }
   mov eventX, cx; { where in the x region did it occur }
   mov eventY, dx;
   mov eventButtons, bx;
   mov eventHappened, 1; { eventHapppened := true }
   and ax, CURSOR_LOCATION_CHANGED; { o.k., do we need to handle mouse movement ? }
   jz noCursorMove;
   call doPascalStuff;
   mov eventHappened, 0; 
   { NOTICE - no movement events are detected in the out world ! - this is a
     wintext consideration - It might be needed to track mouse movements, 
     and then it should be changed ! - but this is MY default handler ! }
noCursorMove: { no need for cursor movement handling }
   pop ds; { restore driver's ds }
end; {vgaTextGraphicHandler}

(******************************************************************************
*                                GetLastEvent                                 *
******************************************************************************)
function GetLastEvent(var x,y : word;
	var left_button,right_button,middle_button : buttonState) : boolean;

begin
	getLastEvent := eventhappened; {indicate if any event happened}
	eventhappened := False; {clear to next read/event}
	x := eventX;
	y := eventY;
	if ((eventButtons and LEFTBUTTON) <> 0) then
		left_button := buttonDown
	else left_button := buttonUp;
	if ((eventButtons and RIGHTBUTTON) <> 0) then
		right_button := buttonDown
	else right_button := buttonUp;
	if ((eventButtons and MIDDLEBUTTON) <> 0) then
		middle_button := buttonDown
	else middle_button := buttonUp;
end; {getLastEvent}

(******************************************************************************
*                              setDefaultHandler                              *
******************************************************************************)
procedure setDefaultHandler;

{get only event mask, and set event handler to defaultHandler}

begin
   if (vgaTextGraphicCursor) then begin
      mask := mask or CURSOR_LOCATION_CHANGED; { we MUST detect cursor movement }
	   setEventHandler(mask,@vgaTextGraphicHandler);
   end else
	   setEventHandler(mask,@defaultHandler);
end; {setDefaultHandler}

(******************************************************************************
*                           enableLightPenEmulation                           *
******************************************************************************)
procedure enableLightPenEmulation;

begin
	reg.ax := 13;
	callMouse;
end; {enableLightPenEmulation}

(******************************************************************************
*                          disableLightPenEmulation                           *
******************************************************************************)
procedure disableLightPenEmulation;

begin
	reg.ax := 14;
	callMouse;
end;  {disableLightPenEmulation}

(******************************************************************************
*                              defineSensetivity                              *
******************************************************************************)
procedure defineSensetivity(x,y : word);

begin
	reg.ax := 15;
	reg.cx := x; {# of mouse motions to horizontal 8 pixels}
	reg.dx := y; {# of mouse motions to vertical 8 pixels}
	callMouse;
	XMotions := x;
	YMotions := y; {update global unit variables}
end; {defineSensetivity}

(******************************************************************************
*                              setHideCursorBox                               *
******************************************************************************)
procedure setHideCursorBox(left,top,right,bottom : word);

begin
	reg.ax := 16;
	reg.es := seg(HideBox);
	reg.dx := ofs(HideBox);
	HideBox.left := left;
	HideBox.right := right;
	HideBox.top := top;
	HideBox.bottom := bottom;
	callMouse;
end; {setHideCursorBox}

(******************************************************************************
*                         defineDoubleSpeedTreshHold                          *
******************************************************************************)
procedure defineDoubleSpeedTreshHold(treshHold : word);

begin
	reg.ax := 17;
	reg.dx := treshHold;
	callMouse;
end; {defineDoubleSpeedTreshHold - from what speed to double mouse movement}

(******************************************************************************
*                              disableTreshHold                               *
******************************************************************************)
procedure disableTreshHold;

begin
	defineDoubleSpeedTreshHold($7FFF);
end; {disableTreshHold}

(******************************************************************************
*                              defaultTreshHold                               *
******************************************************************************)
procedure defaultTreshHold;

begin
	defineDoubleSpeedTreshHold(64);
end; {defaultTreshHold}

(******************************************************************************
*                                setMouseGraph                                *
******************************************************************************)
procedure setMouseGraph;

begin
	mouseGraph := True;
   vgaTextGraphicCursor := false; { this must be turned off ! }
end; {setMouseGraph}

(******************************************************************************
*                               resetMouseGraph                               *
******************************************************************************)
procedure resetMouseGraph;

begin
	mouseGraph := False;
end; {resetMouseGraph}


(******************************************************************************
*                               waitForRelease                                *
* Wait until button is release, or timeOut 1/100 seconds pass. (might miss a  *
* tenth (1/10) of a second.						       							      *
******************************************************************************)
procedure waitForRelease;
var
    sHour, sMinute, sSecond, sSec100 : word;	{ Time at start }
    cHour, cMinute, cSecond, cSec100 : word;	{ Current time	}
    stopSec			     : longInt;
    currentSec			  : longInt;
    Delta			     : longInt;
begin
    getTime(sHour, sMinute, sSecond, sSec100);
    stopSec := (sHour*36000 + sMinute*600 + sSecond*10 + sSec100 + timeOut) mod
	            (24*360000);
    repeat
	   getTime(cHour, cMinute, cSecond, cSec100);
	   currentSec := (cHour*36000 + cMinute*600 + cSecond*10 + cSec100);
	   Delta := currentSec - stopSec;
    until (not ButtonPressed) or (Delta >=0) and (Delta < 36000);
end; {waitForRelease}

(******************************************************************************
*                              swapEventHandler                               *
* handler is a far routine.                                                   *
******************************************************************************)
procedure swapEventHandler;
begin
   reg.ax := $14;
   reg.cx := mask;
	reg.es := seg(handler^);
	reg.dx := ofs(handler^);
	callMouse;
   lastMask := reg.cx;
   lastHandler := ptr(reg.es,reg.dx);
end; {swapEventHandler}

(******************************************************************************
*                            getMouseSaveStateSize                            *
******************************************************************************)
function getMouseSaveStateSize;
begin
   reg.ax := $15;
   callMouse;
   getMouseSaveStateSize := reg.bx;
end; {getMouseSaveStateSize}

(******************************************************************************
*                               interceptMouse                                *
******************************************************************************)
procedure interceptMouse;
begin
   with reg do begin
      ax := 3;
      callMouse; { get place .. }
      interceptX := cx;
      interceptY := dx;
      ax := 31;
      callMouse;
   end; { disable mouse driver .. }
end; {interceptMouse}

(******************************************************************************
*                                restoreMouse                                 *
******************************************************************************)
procedure restoreMouse;
begin
   with reg do begin
      ax := 32; { restore mouse driver .. }
      callMouse;
      ax := 4;
      cx := interceptX;
      dx := interceptY;
      callMouse;
   end; { with .. }
end; {restoreMouse}

(******************************************************************************
*                           setVgaTextGraphicCursor                           *
******************************************************************************)
procedure setVgaTextGraphicCursor;
begin
   vgaTextGraphicCursor := false; { assume we can not .. }
   if (DESQviewActive) then
      exit; { tpDESQ tells us - DV is up, and we can not do anything about it .. }
   if (queryAdapterType <> vgaColor) then
      exit;
   vgaTextGraphicCursor := true; 
end; {setVgaTextGraphicCursor}

(******************************************************************************
*                          resetVgaTextGraphicCursor                          *
******************************************************************************)
procedure resetVgaTextGraphicCursor;
begin
   vgaTextGraphicCursor := false; { assume we can not .. }
end; {resetVgaTextGraphicCursor}

var
    OldExitProc : pointer;

(******************************************************************************
*                                 MyExitProc                                  *
******************************************************************************)
{$f+}procedure MyExitProc;
begin
    ExitProc := OldExitProc;
    if (vgaTextGraphicCursor and hasStoredArray) then
      vgaScreen2Array(false, false, false);
    dispose(charDefs);
    resetMouseGraph;
    resetVGATextGraphicCursor;
    initMouse;
end; { myExitProc }

{ if this unit is used with a graphic unit that is loaded and executed after
     this unit in the Uses clause, the mouse initialization will not be
     correct, be sure to call initMouse in your program start to work
     properly }

begin	{unit initialization}
   eventX := 0;
   eventY := 0;
   eventHappened := false; { initialize ... }
   new(charDefs);
	initMouse; {detect in global variables}
	setArrowCursor; {start like that in graphic mode}
	OldExitProc := ExitProc;
	ExitProc    := @MyExitProc;
end. {mouseLib}
