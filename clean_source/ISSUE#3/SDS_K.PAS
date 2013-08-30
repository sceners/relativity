unit SDS_K;
{
  Sound Deluxe System 5
  by Maple Leaf (a.k.a Gruian Radu), 1996-1997
  -------------------------------------------------------------------------
  SDS kernel
}

interface

procedure sds_init(Card, Base, Irq, Dma:word);far;
procedure sds_done;far;
procedure sds_startplay(module:pointer; InitSpd, MixSpeed, Pal:word);far;
procedure sds_stopplay;far;
procedure sds_setsurround(surroundmod:boolean);far;
procedure sds_setamplification(percent:word);far;
procedure sds_setpollmix(pollmode:boolean);far;
procedure sds_poll;far;
procedure sds_services;far;

implementation

{$L sds.obj}
procedure sds_init(Card, Base, Irq, Dma:word);external;
procedure sds_done;external;
procedure sds_startplay(module:pointer; InitSpd, MixSpeed, Pal:word);external;
procedure sds_stopplay;external;
procedure sds_setsurround(surroundmod:boolean);external;
procedure sds_setamplification(percent:word);external;
procedure sds_setpollmix(pollmode:boolean);external;
procedure sds_poll;external;
procedure sds_services;external;

begin
end.