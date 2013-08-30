
unit DetectSo;

interface

function DetSoundBlaster:boolean;

implementation

Uses DOS, CRT;

Function hex(a : Word; b : Byte) : String;
Const digit : Array[$0..$F] Of Char = '0123456789ABCDEF';
Var i : Byte;
  xstring : String;
Begin
  xstring:='';
  For i:=1 To b Do
  Begin
    Insert(digit[a And $000F], xstring, 1);
    a:=a ShR 4
  End;
  hex:=xstring
End; {hex}

function DetSoundBlaster:boolean;
Var xbyte1, xbyte2, xbyte3, xbyte4: Byte;
  xword, xword1, xword2, temp, sbport: Word;
  sbfound,portok: Boolean;


Begin
DetSoundBlaster:=false;
  sbfound:=False;
  xbyte1:=1;
  While (xbyte1 < 7) And (Not sbfound) Do
  Begin
    sbport:=$200 + ($10 * xbyte1);
    xword1:=0;
    portok:=False;
    While (xword1 < $201) And (Not portok) Do
    Begin
      If (Port[sbport + $0C] And $80) = 0 Then
        portok:=True;
      Inc(xword1)
    End;
    If portok Then
    Begin
      xbyte3:=Port[sbport + $0C];
      Port[sbport + $0C]:=$D3;
      For xword2:=1 To $1000 Do {nothing};
      xbyte4:=Port[sbport + 6];
      Port[sbport + 6]:=1;
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      Port[sbport + 6]:=0;
      xbyte2:=0;
      Repeat
        xword1:=0;
        portok:=False;
        While (xword1 < $201) And (Not portok) Do
        Begin
          If (Port[sbport + $0E] And $80) = $80 Then
            portok:=True;
          Inc(xword1)
        End;
        If portok Then
          If Port[sbport + $0A] = $AA Then
            sbfound:=True;
        Inc(xbyte2);
      Until (xbyte2 = $10) Or (portok);
      If Not portok Then
      Begin
        Port[sbport + $0C]:=xbyte3;
        Port[sbport + 6]:=xbyte4;
      End;
    End;
    If sbfound Then
    Begin
    DetSoundBlaster:=true;
    End
    Else
      Inc(xbyte1);
  End;
End;{soundport}
end.