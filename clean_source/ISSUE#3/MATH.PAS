Unit Math;

{
  Some "Math" routines, by Maple Leaf
  13 Nov 1996
  -------------------------------------------------------------------------
  no comments necessary...
}

interface

  type Complex = record
                   Re : Real; { real part }
                   Im : Real; { imaginary part, Z=(Re+i*Im) }
                 end;

function  Percent (cant1,cant2 : longint) : word;
{ Returns CANT1 percent of CANT2 (Cant1/Cant2 * 100) % }

function  Min (x,y : longint) : longint;
{ Returns minimal value between x and y }

function  Max (x,y : longint) : longint;
{ Returns maximal value between x and y }

function  RMin (x,y : real) : real;
{ Returns minimal value between x and y }

function  RMax (x,y : real) : real;
{ Returns maximal value between x and y }

implementation

function percent;
begin
  percent:=trunc(100*cant1/cant2);
end;

function min;
begin
  if x<y then min:=x else min:=y;
end;

function max;
begin
  if x>y then max:=x else max:=y;
end;

function rmin;
begin
  if x<y then rmin:=x else rmin:=y;
end;

function rmax;
begin
  if x>y then rmax:=x else rmax:=y;
end;

begin
end.
