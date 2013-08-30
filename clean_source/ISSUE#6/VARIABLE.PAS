unit variable;

interface
type
    ar17 = array[1..19] of byte;
const enemies_in_data_base=13;
      memneeded = 270000;
      maxstars = 1000;
      maxbuf = 64000;
      max_sprites = 200;
      maxenemy = 20;
      enemy_speed = 2;
      maxshots = 10;
      maxshotsallowed = 4; {this is}
      shotspeed = 4;
{     starslayer = 3; {layer also speed}
      course = 25;
      sig : ar17 = (254,65,78,73,77,68,66,254,77,85,65,68,68,73,66,254,57,55,254);
      layer1color = 197;
      layer2color = 207;
      layer3color = 219;
      FireColor   = 6;
      xgrid = 10;
      ygrid = 8;
      goodguys = 1;

Const
  KEYBOARD_INT = $09;
  KEY_BUFFER   = $60;
  KEY_CONTROL  = $61;
  INT_CONTROL  = $20;

  MAKE_UP      = 72;
  MAKE_DOWN    = 80;
  MAKE_RIGHT   = 77;
  MAKE_LEFT    = 75;

  BREAK_UP     = 200;
  BREAK_DOWN   = 208;
  BREAK_RIGHT  = 205;
  BREAK_LEFT   = 203;

  INDEX_UP     = 0;
  INDEX_DOWN   = 1;
  INDEX_RIGHT  = 2;
  INDEX_LEFT   = 3;

Var
  Old_ISR   : Pointer;
  raw_key   : Integer;
  key_table : array[0..3] of Byte;
  Done      : Boolean;
  x         : Integer;
  y         : Integer;
  colour    : byte;

{const up    = #72;
      down  = #80;
      left  = #75;
      right = #77;
      pgup  = #73;
      pgdn  = #81;
      home  = #71;
      endk  = #79;
      esc   = #27;
      ins   = #82;}

const f1    = $bb;
      f2    = $bc;
      left  = $4b;
      right = $4d;
      home  = $47;
      endk  = $4f;
      pgup  = $49;
      pgdn  = $51;
      esc   = $01;
      up    = $48;
      down  = $50;
      ins   = $52;
      enter = $1c;
      space = $39;
      despace = $b9;
      plus  = $4e;
      minus = $4a;

type buff = array[1..maxbuf] of byte;
     buffer = ^buff;
     pal = array[0..255,1..3] of byte;
     img = record
         x : word;
         y : word;
         active : word;
         p : pointer;
     end;
     sprit = record
          images_num : byte;
          images : array [1..max_sprites] of img;
     end;
     sprt = sprit;
     enemy_rec = record
               enemy_type : byte;
               x      : integer;
               y      : integer;
               score  : byte;
               life   : integer;
               active : byte;
               sprite : byte;
     end;
     pos = record
         x,y:word;
     end;

var stars_vec       : array [1..maxstars] of word;
    stars_speed     : array [1..maxstars] of byte;
    grid            : array [1..xgrid,1..ygrid] of enemy_rec;
    buf,buf2        : buffer;
    side            : byte;
    key             : byte;
    xpos,ypos       : word;
    palette         : pal;
    frame           : byte;
    fireflag        : boolean;
    allenemy        : array[1..enemies_in_data_base] of sprt;

    fireball        : sprt;

    pop             : sprt;
    show            : byte;
    ptime           : byte;

    dead            : sprt;
    heart           : sprt;
    life            : byte;
    font            : sprt;
    num             : sprt;
    fury_image      : sprt;
    boom            : sprt;
    tiny            : sprt;
    arrow           : sprt;
    clock           : sprt;
    clockpos        : word;
    double          : byte;

    truetime,tmins,mins,secs,tsecs : integer;
    hardness        : byte;
    r               : byte;
    enemies_on      : byte;
    enemies_on2     : byte;
    enemy_time      : byte;
    patt1,patt2     : byte;
    score           : longint;
    curx,cury,image : integer;
    run             : byte;
    deadsign        :boolean;
    starslayer      : integer;
    {could have been a stracture/record }
    firetype        : byte;
    tail            : byte;
    boomtime        : byte;
    fire            : array [1..maxshots,1..4] of word; {1 original x 2 new x 3 y}
    goodies         : array [1..goodguys,1..4] of word;
    spacepushed     : boolean;
    high            : longint;
    oldscore        : longint;
    invinsible      : boolean;


implementation


end.