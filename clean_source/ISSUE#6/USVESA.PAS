{$G+} { cut here
----------------------------------------------------------------------------
}

unit usvesa;
{
****************************************************************************

      Here is an other VESA unit !!!!!!

      It is based on various sources ( DVPEG,John Bridges VGAKIT,
    SWAG an many others ).
      You can use,modified an distribute this source as long as credit
    is given.


    Supported modes:
      - 256 colors
      - 32768 colors
      - 16 millions colors


    The demo program for this unit is DemoVesa.

                                              Lionel Cordesses
                                              From FRANCE.
                                              November 1994

****************************************************************************
}

{$f+}
interface

uses dos,crt;


var

  use_16,use_32:boolean;
  x_size:word;

function  write_fast(x1,y,x2:word;var entree):boolean;
procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);
procedure find_black(max_color:word;var black,white:byte);
function  setmode(mode:word):byte;  { return 0 if bad, 1 if OK }
procedure setpix(x,y,col:word);
procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
function  getpix(x,y:word):byte;
procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}


implementation


var
  reg:registers;
  vgran,curbank:word;
  add_bank:procedure;
  tps1,tps2:longint;
  heure,minute,seconde,sec100:word;

{$ifdef msdos}
procedure setbank(bank:byte);far;
var banque:word;
  begin
    banque:=bank*longint(64) div vgran;
    asm
      mov bl, 0
      mov dx, banque
      call  [add_bank]
    end;
    curbank:=bank;
end;

{$else}

procedure setbank(bank:byte{word});far;
var banque:word;

  begin
             reg.ax:=$4f05;
             reg.bx:=0;
             reg.dx:=bank*longint(64) div vgran;

             intr($10,reg);
             reg.ax:=$4f05;
             reg.bx:=1;
             intr($10,reg);

  curbank:=255;{bank;}
end;
{$endif}

function setvesa(mode:word):byte;

  begin
    asm
     mov ax,4F02h
     mov bx,mode
     int 10h
     sub ax,004Fh
(*     mov al,0
     cmp ah,1   { if ah=1 that is bad ==>false }
     je  @fin
     mov al,1  {false }
   @fin:*)

     mov @RESULT,al
   end;
{   reg.ax:=$4f02;
   reg.bx:=mode;
   intr($10,reg);
   setvesa:=reg.al;}
{  textmode(co80);
  write(reg.ah,' ',reg.al);
  readln;}

  end;

{$ifdef msdos}

function setmode(mode:word):byte;  { 0 if bad,1 if OK}
type type_vesarec=array[0..555] of byte;
     ves_ptr=^type_vesarec;

type
  long=record
         lo,hi:word;
       end;

var pro:byte;
    vesarec:ves_ptr;

    vesa_info:record
      debut:array[0..3] of byte;
      granularite:word;
      winsize,
      winaseg,
      winbseg:word;
      add_proc:procedure;
      bytes:word;
      width,
      height:word;
      reste:array[0..250] of byte;
    end;


  begin
    setmode:=1;
    getmem(vesarec,556);
    pro:=setvesa(mode);
    fillchar(vesarec^[0],256,0); { set all to zero  }

      reg.ax:=$4f01;
      reg.cx:=mode;
      reg.es:=long(vesarec).hi;
      reg.di:=long(vesarec).lo;

      intr($10,reg);
      if reg.ah=0 then
        begin
          setmode:=1;
          pro:=1;
        end
      else
        begin
          setmode:=0;
          pro:=0;
        end;

      move(vesarec^[0],vesa_info.debut[0],256);
      if reg.al=0 then
        begin
          setmode:=1;
          pro:=1;
        end;
      vgran:=vesa_info.granularite;
      x_size:=vesa_info.width;                 { nb pt per lines }
      add_bank:=vesa_info.add_proc;        { change bank far ptr }

    freemem(vesarec,556);

    use_16:=false;
    use_32:=false;
    if mode=$112 then use_16:=true;
    if mode=$110 then use_32:=true;
end;


{$endif}

procedure setpix(x,y,col:word);assembler;
var  decalage:word;
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax = bank }
        @nonew:

          mov bx,col
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl
      end;

procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);assembler;
var l:longint;
    provi:byte;
    couleur,decalage:word;

      asm
        mov al,use_16
        cmp al,0
        je @v32000

 mov bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
 mov ax,y {removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonewa
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax= bank }
        @nonewa:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,bleu
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew1:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,vert
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew2:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,rouge
          mov byte ptr [es:di],bl

          jmp @fin

      @v32000:
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 shl ax, 1
 shl bx, 1
 adc ax, 0   { pour untiliser un eventuel carry
                          positionne par precedent ADD }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew:


        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov bx,[es:di]
        mov al,bl
        and al,31
        shl al,3
        les di,bleu
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,vert
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,rouge
        mov byte ptr [es:di],al

        @fin:
      end;



procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
var l:longint;
    provi:byte;
    couleur,decalage:word;
  begin
    if use_16=true then
      asm

 mov bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
 mov ax,y {removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov bl,bleu
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew1:

          mov bl,vert
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew2:

          mov bl,rouge
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl


      end;

  if use_32=true then
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 shl ax, 1
 shl bx, 1
 adc ax, 0   { pour untiliser un eventuel carry
                          positionne par precedent ADD }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew:


        mov al,rouge
        shr al,3
        mov ah,0
        shl ax,10
        mov bl,vert
        shr bl,3
        mov bh,0
        shl bx,5
        add ax,bx
        mov bl,bleu
        shr bl,3
        mov bh,0
        add bx,ax
        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov [es:di],bx
      end;
  end;

Procedure Move16(Var Source,Dest;Count:Word); Assembler;
Asm
  PUSH DS
  LDS SI,SOURCE
  LES DI,DEST
  MOV AX,COUNT
  MOV CX,AX
  SHR CX,1
  REP MOVSW
  TEST AX,1
  JZ @end
  MOVSB
@end:POP DS
end;


function write_fast(x1,y,x2:word;var entree):boolean;

var coord1,coord2:longint;
    couleur:byte;
  begin
    write_fast:=false;
    coord1:=longint(y)*longint(x_size)+x1;
    coord2:=coord1+longint((x2-x1)+1);
    if (coord1 shr 16)<> curbank then  setbank(coord1 shr 16);
    if (coord1 shr 16)=(coord2 shr 16) then
      begin
         move16(entree,mem[sega000:(coord1 mod 65536)],(x2-x1+1));
         write_fast:=true;
      end;
  end;


function donne_heure:longint;
var heure,minute,seconde,sec100:word;
  begin
    gettime(heure,minute,seconde,sec100);
    donne_heure:=heure*3600*100+minute*60*100+seconde*100+sec100;
  end;




procedure find_black(max_color:word;var black,white:byte);
var luminance,n:byte;
    reg:registers;
    table:array[0..767] of byte;
    i,x,y:word;

  begin
       with reg do
         begin
           ah:=$10;
           al:=$17;
           bx:=0;
           cx:=max_color;
           es:=seg(table);
           dx:=ofs(table);
           intr($10,reg);
         end;
    i:=0;
    white:=0;
    black:=255;
    for n:=0 to max_color-1 do
      begin
        luminance:=round(((0.59*table[i+1])+(0.3*table[i])+
        (0.11*table[i+2])));
        if luminance>white then
          begin
            white:=luminance;
            x:=n;
          end;
        if luminance<black then
          begin
            black:=luminance;
            y:=n;
          end;
        inc(i,3);
      end;
    i:=0;
    black:=y;
    white:=x;
  end;


procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}
type
  pchar=array[char] of array[0..15] of byte;
var
  p:^pchar;
  c:char;
  i,j,z,b:integer;
  noir,blanc:byte;
begin
  reg.ax:=$1130;
  reg.bh:=6;
  intr($10,reg);
  p:=ptr(reg.es,reg.bp);
  if (use_16=false) and (use_32=false) then
    find_black(256,noir,blanc)
  else
    begin
      noir:=0;
      blanc:=255;
    end;
      for z:=1 to length(txt) do
      begin
        c:=txt[z];
        for j:=0 to 15 do
        begin
          b:=p^[c][j];
          for i:=x+7 downto x do
          begin
            if (use_16=false) and (use_32=false)  then
              begin
                if odd(b) then setpix(i,y+j,blanc)
                          else setpix(i,y+j,noir);
              end
            else
              begin
                if odd(b) then setpix_16(i,y+j,blanc,blanc,blanc)
                          else setpix_16(i,y+j,noir,noir,noir);
              end;

            b:=b shr 1;
          end;
        end;
        inc(x,8);
      end;

end;

function getpix(x,y:word):byte;assembler;
var  decalage:word;
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov al,[es:di]
      end;


end.


{
  This is the second part of a message for SWAG dealing with VESA
cards.

{