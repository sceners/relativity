program getver;

uses dos;

procedure id_version;

var regs : registers;

begin
  regs.ah := $30;
  msdos( regs);
  write( 'DOS version = ', regs.al,'.' );
  IF ( regs.ah < 10 ) THEN write( '0' );
  writeln( regs.ah );
end;
 
begin
  id_version;
end.

