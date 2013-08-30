unit revgif;
interface

procedure DisplayGIF(GIFname:string; where,e,c:byte);

implementation
uses gifutil9,revgfx,revdat,revconst,revtech,crt,revmenu;

procedure DisplayGIF(GIFname:string; where,e,c:byte);
begin
  if gifname<>'' then
  begin
     if vga_ then
     begin
          if fileindat(GIFNAME,WHERE) then
          begin
          ExtractFileFromDat(gifname,where);
          hidecursor;
               if (e<>0) and (c<>0) then
                  add_tag(e,c);
               general(gifname);
               DeleteDatFile(gifname);
               FadedownRGBScreen;
          end;
     end;
  end;
end;

end.