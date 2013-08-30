unit revprint;
interface

Function PrinterOnLine : Boolean;

implementation
uses crt,dos;

Function PrinterOnLine : Boolean;
  Const
    PrnStatusInt  : Byte = $17;    (*  Dos interrupt *)
    StatusRequest : Byte = $02;    (*  Interrupt Function Call *)

    PrinterNum    : Word = 0;  { 0 for LPT1, 1 for LPT2, etc. }
  Var
    Regs : Registers ;         { Type is defined in Dos Unit }

    Begin  (* PrinterOnLine*)
      Regs.AH := StatusRequest;
      Regs.DX := PrinterNum;
      Intr(PrnStatusInt, Regs);
      PrinterOnLine := (Regs.AH and $80) = $80;
    End;

    end.