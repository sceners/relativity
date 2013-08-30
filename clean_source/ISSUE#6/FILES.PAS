unit files;
interface
function FileExists(FileName: String): Boolean;
implementation

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