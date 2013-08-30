(*  ts.pas - Digital Sound Interface Kit V1.01a timer service routines.

    Copyright 1993,94 Carlos Hasan
*)

unit TS;

interface

type
  TTimerProc = procedure;

procedure TSInit;
procedure TSDone;
procedure TSSetRate(Speed:integer);
procedure TSSetRoutine(Rout:TTimerProc);
procedure TSRestoreTime;

implementation

{$L TS.OBJ}

procedure TSInit; external;
procedure TSDone; external;
procedure TSSetRate(Speed:integer); external;
procedure TSSetRoutine(Rout:TTimerProc); external;
procedure TSRestoreTime; external;

end.
