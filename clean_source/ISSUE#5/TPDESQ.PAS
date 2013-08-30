(******************************************************************************
*                                   tpDESQ                                    *
* Turbo-Pascal 6.0 DESQview interface unit, (c) 1991, Loewy Ron.              *
******************************************************************************)
unit tpDESQ;
{$ifdef ovl}
   {$F+}
{$endif}
interface

uses
   dos
{$ifndef cmdline}
   ,crt
{$endif}
   ;

const
   DESQviewActive : boolean = false; { true if running under DESQview }
   DESQviewMajor  : byte    = 0;
   DESQviewMinor  : byte    = 0;

procedure detectDESQview;
function getDESQviewTextBuffer : pointer;
procedure DESQviewApiCall(func : word);
procedure DESQviewPause;
procedure DESQviewBeginCritical;
procedure DESQviewEndCritical;
procedure makeDESQviewAware;
procedure DESQviewHercules43Lines(page : byte);
function  DESQviewCurrentWindow : byte;
function  DESQviewDirectScreenWrite : boolean;
function  extendedDESQview : boolean; { true if xdv }

implementation

var
   regs  : registers;

(******************************************************************************
*                               detectDESQview                                *
* Set DESQviewActive flag to TRUE if DV is active, and set Major and Minor    *
* DESQview version.                                                           *
******************************************************************************)
procedure detectDESQview;
begin
   regs.cx := $4445;
   regs.dx := $5351; { date cx = DE, dx = SQ }
   regs.ax := $2B01; { dos set date function }
   msdos(regs);
   if (regs.al = $ff) then
      DESQviewActive := false { if dos detected an error, no DV active }
   else begin
      DESQviewActive := true;
      DESQviewMajor  := regs.bh;
      DESQviewMinor  := regs.bl;
   end;
end; {detectDESQview}

(******************************************************************************
*                            getDESQviewTextBuffer                            *
******************************************************************************)
function getDESQviewTextBuffer;
begin
   regs.ah := $fe; { DESQview get buffer function API }
   intr($10, regs);
   getDESQviewTextBuffer := ptr(word(regs.es), word(regs.di));
end; {getDESQviewTextBuffer}

(******************************************************************************
*                               DESQviewApiCall                               *
******************************************************************************)
procedure DESQviewApiCall; assembler;
asm
   push ds
   push bp
   push sp
   push ss
   mov ax, $101A  ; { switch to DV stack }
   int $15
   mov ax, func   ; { perform API call }
   int $15
   mov ax, $1025  ; { switch off DV stack }
   int $15
   pop ss
   pop sp
   pop bp
   pop ds
end; {DESQviewApiCall}

(******************************************************************************
*                                DESQviewPause                                *
* give up programs time slice, (Waiting for an event ... )                    *
******************************************************************************)
procedure DESQviewPause;
begin
   DESQviewApiCall($1000);
end; {DESQviewPause}

(******************************************************************************
*                            DESQviewBeginCritical                            *
* Tell DV not to slice away until a DESQviewEndCritical is issued             *
******************************************************************************)
procedure DESQviewBeginCritical;
begin
   DESQviewApiCall($101B);
end; {DESQviewBeginCritical}

(******************************************************************************
*                             DESQviewEndCritical                             *
******************************************************************************)
procedure DESQviewEndCritical;
begin
   DESQviewApiCall($101C);
end; {DESQviewEndCritical}

(******************************************************************************
*                              makeDESQviewAware                              *
******************************************************************************)
procedure makeDESQviewAware;
begin
{$ifndef cmdline}
   directVideo := false;
{$endif}
end; {makeDESQviewAware}

(******************************************************************************
*                           DESQviewHercules43Lines                           *
* DV uses INT 10h, service 00 - set video mode to display more then 25 lines, *
* no errors are checked, use at your own risk.                                *
******************************************************************************)
procedure DESQviewHercules43Lines;
begin
   regs.ah := 0; { set video mode }
   regs.al := page + $21; 
   { an error will occur if other then page 0, or 1 is given, procedure does }
   { not check for this error !, check by your self !                        }
   intr($10, regs);
end; {DESQviewHercules43Lines}

(******************************************************************************
*                        DESQviewGetCurrentWindowInfo                         *
* internal DV 2.0+ window information service.                                *
******************************************************************************)
procedure DESQviewGetCurrentWindowInfo;
begin
   regs.ah := $82;
   regs.dx := $4456; { DV magic number }
   intr($10, regs);
end; {DESQviewGetCurrentWindowInfo}

(******************************************************************************
*                            DESQviewCurrentWindow                            *
* this function returns the number of the current window we run in            *
******************************************************************************)
function DESQviewCurrentWindow;
begin
   DESQviewGetCurrentWindowInfo;
   DESQviewCurrentWindow := regs.al;
end; {DESQviewCurrentWindow}

(******************************************************************************
*                          DESQviewDirectScreenWrite                          *
******************************************************************************)
function DESQviewDirectScreenWrite;
begin
   DESQviewGetCurrentWindowInfo;
   if (regs.bl = 1) then
      DESQviewDirectScreenWrite := true
   else
      DESQviewDirectScreenWrite := false;
end; {DESQviewDirectScreenWrite}

(******************************************************************************
*                              extendedDESQview                               *
******************************************************************************)
function extendedDESQview;
begin
   asm
      mov ax, $11DE
      mov @result, 0
      jnc @noXdv
      mov @result, 1
   @noXdv:
   end; { asm }
end; {extendedDESQview}

(******************************************************************************
*                                    MAIN                                     *
******************************************************************************)
begin
   detectDESQview;
end.

