UNIT extra;
interface
const
      length=80;
      depth=25;
type
     wrm=array[1..80,1..2] of integer;
     Fd=array [1..9,1..2] of integer;
     levmit=array[1..2000,1..2] of integer;
     sh=array[1..206,1..2] of integer;

var
   who:string[7];
   fif:boolean;
     startsecret,Secret:sh;
     levfile:text;
     levellimit:levmit;
     startworm,lastworm,worm:wrm;
     up,down,left,right:boolean;
     f,lastlevel,Level,Score,lives:integer;
     startfood,food:fd;
     speed:longint;


implementation

end.