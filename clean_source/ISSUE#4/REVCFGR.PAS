unit revcfgr;
interface
procedure read_config;
implementation
uses revconst,revtech,revinit,revdat;

var cfg_file: file of configure;

procedure read_config;
begin
extractfilefromdat('REV97.CFG');
assign(cfg_file,'REV97.CFG');
reset(cfg_file);
read(cfg_file,config^);
close(cfg_file);
deletedatfile('REV97.CFG');
end;
end.