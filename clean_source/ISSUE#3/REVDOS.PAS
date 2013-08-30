unit revdos;
interface

function FileExists(FileName: String): Boolean;
procedure CheckForDat;

implementation
uses crt,dos;
const revsize=2650316;
      revfilename='REV.DAT';

procedure CheckForDat;
var
 DirInfo: SearchRec;
begin
     if fileexists(revfilename) then
     begin
          findfirst(revfilename,Archive, DirInfo);
          if dirinfo.size<> revsize then
          begin
          writeln('Relativity Emag''s Main Dat File Size is Wrong');
          writeln('Get Full Release From Http://revp.home.ml.org');
          halt;
          end;
     end
     else
     begin
          writeln('Relativity Emag''s Main Dat File is Missing');
          writeln('Get Full Release From Http://revp.home.ml.org');
          halt;
     end;
end;

function FileExists(FileName: String): Boolean;
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }





end.