unit revcol;
interface

Procedure GetPal(Color:byte; var R,G,B : Byte);
procedure changecol(s,d:byte);
procedure setpal(nr,r,g,b: byte);  { set rgb val to color nr }

implementation
Procedure SetPal1(Color,R,G,B : Byte);
{ this set's the RGB intensities of COLOR }
Begin
   Port[$3c8] := Color;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;

procedure changecol(s,d:byte);
var  r1,g1,b1,r2,g2,b2:byte;
begin
     getpal(s,r1,g1,b1);
     getpal(d,r2,g2,b2);
     setpal1(s,r2,g2,b2);
end;

Procedure GetPal(Color:byte; var R,G,B : Byte);
{ this get's the RGB intensities of COLOR }
Begin
   Port[$3c7] := Color;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;

procedure setpal(nr,r,g,b: byte); assembler; { set rgb val to color nr }
asm
 mov dx,3c8h
 mov al,nr
 out dx,al
 inc dx
 mov al,r
 out dx,al
 mov al,g
 out dx,al
 mov al,b
 out dx,al
end;

end.