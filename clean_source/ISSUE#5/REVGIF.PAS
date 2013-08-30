unit revgif;
interface

procedure DisplayGIF(GIFname:string);

implementation
uses gifutil9,revgfx;
procedure DisplayGIF(GIFname:string);
begin
if gifname<>'' then
begin
 hidecursor;
 general(gifname);
 FadedownRGBScreen;
end;
end;
end.