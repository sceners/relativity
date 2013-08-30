unit revcfgr;
interface

Function read_config:boolean;

implementation
uses revconst,revtech,revinit,revdat;

var cfg_file: file of configure;

Function read_config:boolean;
begin
read_config:=true;
if fileindat(cfg_name,config_file) then
begin
     Extractpointerfromdat(cfg_name,config_file,cfg_ptr,size) ;
     move32fast(cfg_ptr^,config^,size);
end
else
    read_config:=false;
end;
end.