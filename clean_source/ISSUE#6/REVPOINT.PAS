unit revpoint;
interface

procedure InitConfigPointer;
procedure KillConfigPointer;
implementation
uses revconst;
procedure InitConfigPointer;
begin
{-----------------------------------------------------------------------}
{all the 15k of the vars i use.. lots!!}
  getmem(config,sizeof(configure));
{-----------------------------------------------------------------------}
end;

procedure KillConfigPointer;
begin
freemem(config,sizeof(configure));
end;
end.