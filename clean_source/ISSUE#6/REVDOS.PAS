unit revdos;
interface

function FileExists(FileName: String): Boolean;
procedure CheckForDat;

implementation
uses crt,dos;
const revsize=0;
      revfilename='REVDATA.MDB';

procedure CheckForDat;
var
 DirInfo: SearchRec;
begin
     if fileexists(revfilename) then
     begin
          findfirst(revfilename,Archive, DirInfo);
          if revsize <> 0 then
          begin
               if dirinfo.size<> revsize then
               begin
                    writeln;
                    writeln('Relativity Emag''s Main Dat File Size is Wrong');
                    writeln('Get Full Release From Http://relativity-emag.home.ml.org');
                    writeln;
                    halt;
               end;
          end;
     end
     else
     begin
          writeln;
          writeln('Relativity Emag''s Main Dat File is Missing');
          writeln('Get Full Release From Http://relativity-emag.home.ml.org');
          writeln;
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