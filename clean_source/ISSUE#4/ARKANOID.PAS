
unit Arkanoid;
{$F+}
interface
uses crt,dos,graph,mouse,FM;

procedure StartGame(var score1:longint);
function  mainscreen : integer;
procedure fatal_error(err_type : string);
procedure load_all_walls;
procedure InitSVGA;
procedure initRowArray;
function  random_letter_drop : integer;
procedure start_game(players : integer);
procedure closeprogram;

implementation
uses revdat,revgif,revgfx,revansi,revconst,revmenu;
const
   SCRMIN     = 10;  { Coordinata X del bordo sinistro dell'area di gioco }
   SCRMAX     = 216; { Coordinata X del bordo destro dell'area di gioco }
   SCRTOP     = 12;  { Coordinata Y del bordo superiore dell'area di gioco }
   SCRBOT     = 200; { Coordinata Y del bordo inferiore dell'area di gioco }

   VAUS_W     = 34;  { Larghezza in pixel del VAUS }
   VAUS_H     = 4;   { Altezza in pixel del VAUS }
   VAUS_LINE  = 184; { Coordiana Y su cui scorre orizzontalmente il VAUS }
   EMP        = -1;  { Uso EMP (empty) al posto di -1 }
   BALLDIM    = 5;   { Diametro della pallina (in pixel) }
   BALLSPOT   = 3;   { Raggio della pallina (in pixel) = diametro/2 +1 }

   BALLARRAY  : array[0..4,0..4] of byte = ((0,1,1,1,0),
                                            (1,1,2,1,1),
                                            (1,2,1,1,1),
                                            (1,1,1,1,1),
                                            (0,1,1,1,0));
                                            { Disegno della pallina }


   BALLDEV    = 30; { Angolo di deviazione quando }
                    { urta i bordi rossi del VAUS }
   SPEEDFLASH = 10; { Numero di 50-esimi di secondo che deve aspettare }
                    { prima di cambiare il colore dei bordi del vaus }

   FLASH      : array[0..10] of byte = ( 255,212,211,210,209,
                                         208,207,206,205,204,203);

         { Colori che gli estremi del vaus assumono durante il lampeggio }

   SCORE_WALL : array[1..10] of integer = ( 10,20,30,40,50,100,200,250,500,1000 );


   EMERG_DEV  : array[1..8] of byte = ( $02,$13,$24,$35,$12,$23,$34,$45 );


   COLORBLOCK : array[0..9] of byte = ( 212,211,210,209,208,
                                        207,206,205,204,203 );
                                         { Colore dei mattoncini }



   GRAYDOWN   = 1;   { Numero di colpi-1 per abbattere un mattone grigio }
   STARTWALL  = 01;  { Livello di partenza }
   BALLSPEED  = 500; { Velocita' della pallina (256 = 70 pixel al secondo  }
   MAXSPEED   = 2000;{ Velocita' massima raggiungibile dalla pallina       }
   MAXBRWHIT  = 100; { Numero massimo di blocchi indistr. che puo' colpire }
                     { prima di schizzare via cambiando velocita'          }

   PATNUMBER  = 4;   { Numero dei fondali disponibili }

   POS_DIGIT  : array[1..3] of integer = (60,93,128);
   { Coordinata y dei tre punteggi (player 1, player 2, hiscore) }


   DIGITS     : array[0..10] of byte = ( 125,96,55,103,106,79,
                                          95,97,127,111,0 );
   { Dati per la visualizzazione delle cifre digitali nei punteggi }

   LEVEL      : array[1..5] of integer = (1000,300,100,60,35);

   SBDIR      = 600; { Cicli che deve fare prima che la palla devi (dev. regolare) }
   DEFLEVEL   = 3;   { Livello di gioco di default }

   LETTER_PROB= 300; { range in cui viene estratto il numero casuale della lettera }
   LETTER_DROP= 1000;{ numero che deve raggiungere la somma per far cadere la lettera }
   LETTER_NUMB= 8;   { numero di lettere+1 }
   LETTER_FRM = 8;   { numero dei frames che costituiscono l'animazione della lettera }
   LETTER_SBF = 5;   { numero di cicli che deve compiere prima di passare al frame }
                     { successivo }

   {Prob in % di caduta delle lettere }  {  L   E  B   D   S   C  P }
   LETTER_DIS : array[1..7] of integer = ( 16, 20, 3, 18, 20, 20, 3 );

   FLUXLEVEL  = 176;

type

   arr768   = array[0..767] of byte;   { per i 256 colori in RGB (x3) }
   arr64k   = array[0..64000] of byte; { per la schermata di 320x200  }

   BTMTYPE  = RECORD                   { per un disegno in fomrato BTM }
              width   : word;          { larghezza disegno       }
              height  : word;          { altezza                 }
              trasp   : byte;          { trasparenza (non usato) }
              palette : ^arr768;       { puntatore alla palette di colori }
              palused : boolean;       { flag TRUE = la palette esiste }
              map     : ^arr64k;       { dati contenenti il disegno }
              end;


   VAUSTYPE = RECORD                   { per i dati del vaus }
              x,y,                     { attuali coordinate x,y }
              oldx,                    { vecchie coordinate del vaus }
              oldy   : longint;
              oldlen : integer;        { e vecchia lunghezza }
              width,                   { larghezza }
              height : integer;        { spessore (o altezza) }
              flash  : byte;           { indica il colore attuale dei bordi }
              iflash : integer;        { contatore di ritardo per il }
                                       { il lampeggio dei bordi }
              letter : integer;
              end;


   BALLTYPE = RECORD                   { contiene i dati della pallina }
              x,y,                     { coordinate x,y attuali }
              finex,finey,             { sottomultipli delle coordinate }
              oldx,oldy,               { vecchie coordinate }
              speed  : longint;        { velocita' (256 = 70 pixel al sec. }
              finespeed : longint;     { velocita' (sottomultiplo) }
              speedx,                  { velocita' sull'asse x }
              speedy : longint;        { velocita' sull'asse y }
              sbd    : longint;        { per evitare i loop della pallina }
              brwhit : integer;        { n. di blocchi marroni colpiti di seguito }
              attrib : integer;        { atributi (non usato)  }
              inplay : boolean;        { flag, TRUE se la palla e' in gioco }
              launch : boolean;        { flag, TRUE se la palla deve essere }
                                       { ancora lanciata }
              onvaus : integer;        { larghezza in pixel del vaus }
              stm    : integer;        { contatore di calamita }
              end;

   WALLTYPE = array[0..12,-1..15] of byte; { per il muro (13x15 mattoncini) }

   WHOLEWALLS = array[0..33] of WALLTYPE; { per tutti e 33 i muri }

   SCORETYPE  = RECORD                           { tiene i punteggi }
                player : array[1..2] of longint; { player 1 e 2 }
                wall_n : array[1..2] of integer; { muro corrente }
                wall_p : array[1..2] of WALLTYPE;{ memoriz. del muro stesso }
                lives  : array[1..2] of integer; { vite rimaste }
                hiscore: longint;                { record }
                pl_numb: integer;                { giocatore corrente }
                roundsel : array[1..2] of boolean;
                abortplay : boolean;
                end;

   SHREC      = RECORD                 { per lo scintillio dei mattoncini }
                xb,yb,frame : integer;
                block       : integer;
                active      : boolean;
                end;

   LETTERREC  = RECORD                 { dati relativi alla lettera }
                x,y      : word;       { coord. }
                typ      : integer;    { Tipo, B,C,E,L,P,D,S }
                frame    : integer;    { numero del frame }
                subframe : integer;    { numero di cicli per ogni frame }
                active   : boolean;    { la lettera puo' essere attiva }
                incoming : longint;    { tiene la somma, >1000 la lettera cade }
                nextx,                 { coord di dove deve cadere se attivata }
                nexty,
                nexttype : word;       { tipo di lettera che dovra' cadere }
                last     : integer;    { ultima lettera caduta }
                end;

   FIRETYPE   = RECORD                 { per i laser }
                x,y  : word;           { coord. }
                shot : boolean;        { se il colpo e' partito }
                avl  : boolean;        { se e' dispoibile (grazie alla L) }
                nw   : boolean;        { se e' appena partito dal VAUS }
                end;
var
       success    : boolean;               { flag di stato per il caric. BTM }
       score      : SCORETYPE;                  { punteggio corrente }
       lv         : integer;                    { livello di gioco }



var
    playscreen : BTMTYPE;  { area di gioco (320x200) }
    playvaus   : BTMTYPE;  { vaus }
    normal     : BTMTYPE;  { vaus normale }
    enlarged   : BTMTYPE;  { allargato }
    lasers     : BTMTYPE;  { traformato per sparare }
    pattern    : BTMTYPE;  { sfondo }
    explosion  : BTMTYPE;  { esplosione vaus }
    newvaus    : BTMTYPE;  { sequenza di animazione di partenza }
    presents   : BTMTYPE;  { scritta ARKANOID }
    soundfx    : BTMTYPE;  { l'icona con la nota e la nota sbarrata }
    shinewall  : BTMTYPE;  { luccichio dei mattoncini grigi e beige }
    minivaus   : BTMTYPE;  { vaus piccolino che indica le vite }
    levelsel   : BTMTYPE;  { 5 frames dei numeri per scegliere il livello }
    letters    : BTMTYPE;  { le animazioni delle 7 lettere }
    shoots     : BTMTYPE;  { e il disegno dei laser }
    flux       : BTMTYPE;
    vaus       : VAUSTYPE; { dati relativi al vaus (vedi sopra) }
    row        : array[0..250] of word; { array (vedere initRowArray) }


    screen     : array[0..65530] of byte absolute $a000:0000;
               { forzatura della mappa di schermo all'indirizzo della VGA }
               { a000:0000 inerente alla modalita' grafica 320x200x256 col. }

    wall       : walltype;  { muro }
    cn         : integer;   { variabile di servizio usata qua e la' }
    modx       : array[0..319] of integer;
    mody       : array[0..199] of integer;
    all_walls  : WHOLEWALLS;                 { tutti i muri }
    remain_blk : integer;                    { mattoni ancora da abbattere }
    totalwall  : integer;                    { mattoni in tutto }
    cur_player : integer;                    { giocatore corrente }
    shinerec   : shrec;                      { tiene i dati dell'blocco }
                                             { che scintilla in questo }
                                             { momento }
    trainer    : integer;

    lett       : LETTERREC;                  { i parametri delle lettere }
    fire       : FIRETYPE;                   { e dei raggi laser         }
    balls_in_play : integer;                 { numero di palline in gioco }
    scrflux    : boolean;
    scrfluxcnt : integer;

procedure loadBTM(name : string; var BTMREC : BTMTYPE; pal : boolean);
var
  h1   : file;
  s    : array[0..10] of byte;   { carica un file in formato BTM }
  cnt  : word;
  size : longint;
  pl   : array[0..767] of byte;

  begin
  {$I-}
  assign(h1,name);               { apre il file }
  reset(h1,1);                   { e si pone all'inizio }

  blockread(h1,s,11,cnt);        { legge 11 bytes di intestazione }
  blockread(h1,pl,768,cnt);      { legge la palette dei colori }

  BTMREC.width :=s[6]+s[7]*256;  { legge la larghezza, byte 6 e 7 }
  BTMREC.height:=s[8]+s[9]*256;  { l'altezza, byte 8 e 9 }
  BTMREC.trasp :=s[10];          { e il colore di trasparenza }

  size:=(BTMREC.width)*(BTMREC.height); { calcola dimensione immagine }

  getmem(BTMREC.map,size);              { alloca la memoria per l'immagine }
  blockread(h1,BTMREC.map^,size,cnt);   { e si legge l'immagine da disco }

  if pal=TRUE then                 { se occorre tenere anche la palette }
     begin
     getmem(BTMREC.palette,768);   { alloca la mem. per la palette }
     for cnt:=0 to 767 do
         BTMREC.palette^[cnt]:=pl[cnt]; { e ci copia la palette appena }
                                        { caricata che altrimenti verrebbe }
                                        { perduta al termine della proc. }
     BTMREC.palused:=TRUE; { quindi setta a TRUE il flag PALETTE USATA }
     end

  else BTMREC.palused:=FALSE; { altrimenti lo setta a false }

  close(h1);  { e chiude il file letto da disco }
  {$I+}

  if IOResult<>0 then success:=FALSE;
  end;



procedure StartGame(var score1:longint);
begin

   { Questa porzione contiene solo il caricamento in memoria dei files dati }

{  DetectFM;}
   success:=TRUE;  { Success viene messo a FALSE se si verifica un errore da disco }

   load_all_walls; { Carica i 32 muri di gioco }

   initSVGA;       { Attiva la modalita grafica 320x200x256 col. }
   initRowArray;   { Inizializza un array utile per evitare le moltiplicazioni }
                   { per 320. }


   { Carica uno dopo l'altro tutti i disegni grafici di cui necessita }

   loadBTM('PLAYGR.BTM'  ,playscreen,TRUE);  { lo schermo virtuale }
   loadBTM('EXPLODE.BTM' ,explosion,FALSE);  { l'esplosione del vaus }
   loadBTM('NEWVAUS.BTM' ,newvaus,FALSE);    { la creazione del vaus }
   loadBTM('SOUNDFX.BTM' ,soundfx,FALSE);    { l'icona sound on/off  }
   loadBTM('SHINEWAL.BTM',shinewall,FALSE);  { il lucchichio dei mattoni }
   loadBTM('MINIVAUS.BTM',minivaus,FALSE);   { i vaus che indicano le vite }
   loadBTM('LEVELSEL.BTM',levelsel,FALSE);   { l'icona del livello di gioco }
   loadBTM('DROPS.BTM'   ,letters,FALSE);    { le 7 lettere }
   loadBTM('VAUS.BTM'    ,normal,FALSE);     { il vaus }
   loadBTM('LASERS.BTM'  ,lasers,FALSE);     { i raggi laser sparati dal vaus }
   loadBTM('ENLARGED.BTM',enlarged,FALSE);   { il vaus allargato }
   loadBTM('FIRE.BTM'    ,shoots,FALSE);     { il vaus coi laser montati }
   loadBTM('SCRFLUX.BTM' ,flux,FALSE);       { l'onda di flusso (per la lett. B) }

   if not success then fatal_error('Program can''t find some BTM files');

   score.hiscore:=100000;
   { il punteggio record viene settato inizialmente a 50000 per default }

{   sound_on:=False;      { per default all'inizio il suono e' attivo }
   lv:=DEFLEVEL;        { e il livello viene settato a DEFLEVEL     }

   repeat

      mousereset;

      { mainscreen restituisce 1,2 (numero gioc. ) o -1 = quit }
      score.pl_numb:=mainscreen;
      if score.pl_numb>0 then start_game(score.pl_numb);

   until score.pl_numb<1; { cicla finche' non vale -1 = quit }

   closegraph; { Chiude la grafica }
   closeprogram;

end;

Procedure DeleteGameFiles;
begin
     DELETEDATFILE('PATTERN0.BTM');
     DELETEDATFILE('PATTERN1.BTM');
     DELETEDATFILE('PATTERN2.BTM');
     DELETEDATFILE('PATTERN3.BTM');
     DELETEDATFILE('PATTERN4.BTM');
     DELETEDATFILE('PLAYGR.BTM');
     DELETEDATFILE('PRESENT.BTM');
     DELETEDATFILE('EXPLODE.BTM');
     DELETEDATFILE('NEWVAUS.BTM');
     DELETEDATFILE('SOUNDFX.BTM');
     DELETEDATFILE('SHINEWAL.BTM');
     DELETEDATFILE('MINIVAUS.BTM');
     DELETEDATFILE('LEVELSEL.BTM');
     DELETEDATFILE('DROPS.BTM');
     DELETEDATFILE('VAUS.BTM');
     DELETEDATFILE('LASERS.BTM');
     DELETEDATFILE('ENLARGED.BTM');
     DELETEDATFILE('FIRE.BTM');
     DELETEDATFILE('SCRFLUX.BTM');
     DELETEDATFILE('WHWALLS.DTA');
end;

procedure closeprogram;
var score1:longint;
  begin
  deletegamefiles;
       hidecursor;
       score1:=score.player[score.pl_numb];
               if score1>=100000  then
               begin
               extractfilefromdat(config^.passgif);
               displaygif(config^.passgif);
               DELETEdatfile(config^.passgif);
               end;
               Reset80x25VideoScreen;
       hidecursor;
       Displayansi(config^.defmenufile);
       StartMainMenuPhase;
  end;

{ ritorna il massimo fra a e b }
function max(a,b : integer) : integer;
  begin
  if(a>b) then max:=a
  else max:=b;
  end;

{ idem per il minimo }
function min(a,b : integer) : integer;
  begin
  if(a<b) then min:=a
  else min:=b;
  end;


{ chiara, no? }
procedure fatal_error(err_type : string);
   begin
   deletegamefiles;
   nosound;
   closegraph;
   hidecursor;
   displayansi(config^.defmenufile);
   StartMainMenuPhase;
   end;

function inkey : word;   { restituisce il codice del tasto premuto }
var ch,ch2: char;        { 0 = nessun tasto premuto }
    begin
    ch:=#0;
    ch2:=#0;

    if keypressed then
       begin
       ch:=readkey;
       if ch=#0 then ch2:=readkey;
       end;

    inkey:=(ord(ch2)*256)+ord(ch);
    end;

procedure initRowArray;  { inizializza l'array ROW; row[n]:=320*n }
var y : word;
  begin
  for y:=0 to 199 do
    row[y]:=y*320;

  for y:=200 to 250 do
    row[y]:=64000;

  end;

{ quanto segue fa parte della procedura per installare un driver esterno }
{ come da esempio nell'help di Turbo Pascal.                             }

procedure svgadrv; external; {$L SVGADRV.OBJ}

function DetectVGA : Integer;
  begin
  DetectVGA := 0;
  end;

procedure InitSVGA; { Inizializza il driver della SuperVGA come da esempio }
var
   AutoDetect : pointer;
   GraphMode, GraphDriver, ErrCode: integer;

   begin
	GraphDriver := InstallUserDriver('SVGA256',@DetectVGA);
   if RegisterBGIDriver(@svgadrv)<0 then
      fatal_error('Unable to register driver');

	ErrCode:=GraphResult;
	if ErrCode <> grOk then
		begin
                hidecursor;
                Displayansi(config^.defmenufile);
                StartMainMenuPhase;
	        end;
	GraphDriver:=Detect;
	InitGraph(GraphDriver,GraphMode,'');
	ErrCode := GraphResult;
	if ErrCode <> grOk then
		begin
                       hidecursor;
                     Displayansi(config^.defmenufile);
                     StartMainMenuPhase;
		end;

   end; { Fine della procedura InitSVGA }

{ ------------------------------------------------------------------------ }

procedure shine_block;    { esegue lo scintillio di un blocco }
var
    xb,yb,                { i parametri del blocco sono contenuti nella }
    frame : word;         { variabile globale SHINEREC }
    x,y,
    xf,yf,
    fr,og : word;

    begin
    xb   :=shinerec.xb;   { mette in xb,yb le coordinate del blocco }
    yb   :=shinerec.yb;

    if wall[xb,yb]>8 then { se il blocco e grigio o marrone }
       begin
       frame:=(shinerec.frame shr 1);        { calcola il n. del frame }
       if wall[xb,yb]<>10 then inc(frame,5);

       xf:= 9+(xb shl 4);  { trova le coordinate sullo shermo del blocco }
       yf:=22+(yb shl 3);  { da far scintillare }
       fr:=frame  shl 7;   { si calcola la posizione del n-esimo frame }

       for y:=0 to 7 do    { e copia il frame n-esimo sullo schermo }
           begin
           og:=y shl 4;      { equivale ad y*16, ma piu' veloce }
           memcpy(addr(shinewall.map^[fr+og]),addr(screen[xf+row[yf+y]]),16);
           end;
       end;

    inc(shinerec.frame);  { incrementa il frame counter }
    if shinerec.frame=10 then shinerec.active:=FALSE;
    { e quando il frame e' l'ultimo allora lo scintillio e' finito }

    end;

procedure unshine_block; { interrompe lo scintillio di un blocco se la }
                         { palla urtandone un altro causa lo scintillio }
                         { di un altro blocco }
    begin
    shinerec.frame:=9;   { cioe' setta il frame come ultimo }
    shine_block;         { ed esegue lo scintillio del blocco con l'ultimo }
                         { frame, cioe' il blocco torna normale }
    end;

procedure shine(xb,yb : integer);   { questa procedura imposta lo }
                                    { scintillio di un blocco }
var t : integer;
    begin
    if shinerec.active then unshine_block;

    shinerec.xb    :=xb;  { coordinate del blocco }
    shinerec.yb    :=yb;  { x,y }
    shinerec.frame :=0;   { frame di partenza }
    shinerec.active:=TRUE;        { scintillio attivo }
    shinerec.block :=wall[xb,yb]; { tipo di blocco (marrone o grigio) }
    end;

procedure checkshine; { se lo scintillio e' attivato allora lo esegue }
                      { passando al frame successivo }
    begin
    if shinerec.active=TRUE then shine_block;
    end;


function random_letter_drop : integer;
var rn,sum,letter : integer;
   begin
   repeat
      rn:=random(100);  { Tira a caso un numero fra 0 e 99 }
      sum:=0;           { pone la somma a zero             }
      letter:=0;        { e la lettera corrente a 0        }

      repeat


         inc(letter);                   { Incrementa la lettera corrente }
         inc(sum,LETTER_DIS[letter]);   { Incrementa somma della percentuale di }
                                        { probabilita' della lettera corrente }

      until sum>rn; { Se la somma oltrepassa il numero casuale scelto }
                    { il programma fa cadere la lettera corrente      }
                    { altrimenti passa alla lettera dopo.             }

   until (letter-1)<>lett.last;

   random_letter_drop:=(letter-1);
   end;

procedure put_letter;
var xl,yl,fl,fw,cl : word;

    begin
    fl:=(lett.typ shl 10)+(lett.frame shl 4);

    for yl:=0 to 7 do
        begin
        fw:=yl shl 7;
        memzerocpy(addr(letters.map^[fw+fl]),addr(screen[lett.x+row[lett.y+yl]]),16);
        end;
    end;

procedure remove_letter;
var ad,yl : word;

    begin
    if (lett.x>=0) and (lett.x<320) and (lett.y>0) and (lett.y<240) then
       begin
       for yl:=0 to 7 do
           begin
           ad:=lett.x+row[lett.y+yl];
           if ad<64000 then
              memcpy(addr(playscreen.map^[ad]),addr(screen[ad]),16);
           end;
       end;
    end;

procedure disable_letter;
   begin
   remove_letter;
   lett.active:=FALSE;
   end;

procedure start_letter(xl,yl,letter : word);
   begin
   if lett.active then disable_letter;

   with lett do
      begin
      x       :=xl;
      y       :=yl;
      typ     :=letter;
      frame   :=0;
      subframe:=0;
      active  :=TRUE;
      end;
   end;

procedure check_letter;
   begin
   if lett.active then
      begin
      remove_letter;
      inc(lett.y);
      if lett.y>=200 then disable_letter
      else
        begin
        put_letter;
        inc(lett.subframe);
        if lett.subframe=LETTER_SBF then
           begin
           lett.subframe:=0;
           inc(lett.frame);
           end;

        if lett.frame=LETTER_FRM then lett.frame:=0;

        if (vaus.x<(lett.x+16)) and ((vaus.x+vaus.width)>lett.x) and
           (vaus.y<(lett.y+8))  and ((vaus.y+vaus.height)>lett.y) then
           begin
{           ball_block_sound(100,10);}
           vaus.letter:=lett.typ+1;
           inc(score.player[cur_player],SCORE_WALL[10]);
           disable_letter;
           end;
        end;

      lett.incoming:=0;
      end
   else if (lett.incoming>LETTER_DROP) then
        with lett do start_letter(nextx,nexty,nexttype);
   end;

{ Copia sullo schermo a partire dalla coordinata 0,0 il disegno specificato }
procedure showBTMpicture(BTM : BTMTYPE);
var x,y,ofst : word;

  begin
  for y:=0 to BTM.height-1 do   { la y varia da 0 all'altezza-1 del disegno }
     begin
     ofst:=y*BTM.width;         { calcola l'indirizzo nella matrice del dis.}
     for x:=0 to BTM.width-1 do
        screen[x+row[y]]:=BTM.map^[x+ofst]; { mette il disegno sullo schermo }
     end;
  end;

procedure setpalette(var BTM : BTMTYPE);
var regs : REGISTERS;

  begin
  regs.ax:=$1012;               { setta i colori usando l'interrupt 10h }
  regs.bx:=0;                   { del BIOS }
  regs.cx:=256;
  regs.es:=SEG(BTM.palette^);
  regs.dx:=OFS(BTM.palette^);
  intr($10,regs);
  end;


{ disegna la palla sullo schermo, le coordinate sono specificate in }
{ BALL.x e BALL.y, BALLSPOT.x = BALLSPOT.y e' il raggio della palla }
{ in pixel }
procedure place_ball(var ball : BALLTYPE);
var xp,yp,adr : longint;
  begin
  for yp:=0 to BALLDIM-1 do
     begin
     adr:=ball.x-BALLSPOT+row[yp-BALLSPOT+ball.y];
     memzerocpy(addr(BALLARRAY[yp,0]),addr(screen[adr]),BALLDIM);
     end;
  end;

{ Cancella la palla dallo schermo, viene chiamata un istante prima di }
{ place_ball }
procedure remove_ball(var ball: BALLTYPE);
var
  xp,
  yp   : longint;
  temp : longint;

  begin
  for yp:=0 to BALLDIM-1 do
      begin
      temp:=ball.oldx-BALLSPOT+row[yp-BALLSPOT+ball.oldy];
      if (temp>0) and (temp<64000) then
         memcpy(addr(playscreen.map^[temp]),addr(screen[temp]),BALLDIM);
      end;
  end;

procedure Wait_VBL;
label ALTO,BASSO;
   begin
      { questa porzione di codice assembler attende che il pennello }
      { elettronico del monitor sia nella posizione di vertical blank }
      { in modo da evitare lo sfarfallamento dell'immagine. }

      { provvede anche a temporizzare la CPU regolando la velocita' di }
      { esecuzione del programma indipendentemente dal tipo di processore }

      { ogni scheda VGA in modalita' 320x200x256 col. lavora ad una }
      { frequenza di 70Hz. }

      asm
      mov  dx,$03da

      BASSO:
      in   al,dx
      test al,8
      jz   BASSO

      ALTO:
      in   al,dx
      test al,8
      jnz  ALTO
      end;

   end;

procedure set_ball(var ball : BALLTYPE);
  begin
  if((ball.oldx<>EMP) and (ball.oldy<>EMP)) and
    ((ball.oldx<>ball.x) or (ball.oldy<>ball.y)) then
      remove_ball(ball); { appena ha inizio il VB si sposta la palla alle }

  place_ball(ball);  { nuove coordinate }

  ball.oldx:=ball.x; { si settano le vecchie coordinate uguali a quelle }
  ball.oldy:=ball.y; { correnti, le correnti verrano modificate poi }
  end;

procedure set_ball_speed(var ball : BALLTYPE; speed : longint);
var
  sx,sy : longint;  { imposta la velocita' della palla in base al modulo }
  vm    : real;     { del vettore velocita' passato in SPEED : longint.  }

  begin
  sx:=ball.speedx;  { memorizza le componenti x e y della velocita' }
  sy:=ball.speedy;  { rispettivamente in sx ed sy }

  vm:=speed / sqrt(sx*sx+sy*sy); { calcola il coef. di proporzionalita'  }
                                 { fra la vecchia e la nuova velocita'   }
                                 { (la direzione non cambia, cambia solo }
                                 { il modulo). }

  ball.speedx:=round(sx * vm);   { e quindi moltiplica per tale coef. }
  ball.speedy:=round(sy * vm);   { le due proiezioni della velocita'. }

  end;

procedure set_ball_direction(var ball : BALLTYPE; angle : integer);
var w : real;
  begin                  { imposta l'angolo di traiettoria della palla }
  w:=angle*3.14/180.0;   { w viene espresso in gradi }

  ball.speedx:=round(256*cos(w));  { la velocita' si suppone unitaria }
  ball.speedy:=-round(256*sin(w)); { v=256 equivale a 70 pixel al sec. }
  end;

function get_ball_direction(var ball : BALLTYPE): integer;
var w : integer; { restituisce la direzione in cui si muove la palla }
  begin
  if ball.speedx=0 then w:=-90*(ball.speedy div abs(ball.speedy))
  else
    begin
    { calcola l'arcotangente e aggiunge multipli di 90 gradi a seconda dei }
    { segni di ball.speedx e ballspeed.y }

    w:=round(arctan(-ball.speedy/ball.speedx)*180.0/3.14);
    if(ball.speedx<0) then inc(w,180);
    inc(w,360);
    w:=w mod 360;
    end;

  get_ball_direction:=w;
  end;

procedure start_ball(var ball : BALLTYPE);
  begin
  { inizializza i parametri della palla quando questa deve essere }
  { lanciata dal vaus. }

  ball.x:=vaus.x+ball.onvaus;

                     { la coord. di partenza e' quella del vaus+16 }
                     { cioe' essendo il vaus di 34 pixel, la palla deve }
                     { partire al centro del vaus, cioe' vaus.x+16 }

  ball.y:=vaus.y-BALLSPOT;
                           { chiaramente il centro della palla sara' sulla }
                           { linea dove scorre il vaus, meno il raggio }
                           { della palla }

  ball.finex:=0;   { e i due sottomultipli della posizione sono 0 }
  ball.finey:=0;

  ball.inplay:=TRUE; { setta il flag che memorizza se la palla e' in gioco }

  ball.sbd:=0;
  ball.brwhit:=0;
  end;

function ball_speed(ball : BALLTYPE): integer;
  begin
  { restituisce il modulo della velocita' della palla, usa il teorema di }
  { pitagora (v=sqrt(x^2+y^2)) }

  ball_speed:=round(sqrt(ball.speedx*ball.speedx+ball.speedy*ball.speedy));
  end;

procedure move_ball(var ball : BALLTYPE);
var
  x,y,z : longint;
  angle : integer;

  begin
  { muove la palla sommando alle coordinate x,y i due vettori velocita' }
  { prima di eseguire tale somma viene moltiplicato tutto per 256 in modo }
  { da avere un numero di posizioni piu' elevato. }

  x:=(ball.x shl 8)+ball.finex+ball.speedx;
  y:=(ball.y shl 8)+ball.finey+ball.speedy;

  ball.x:=x shr 8;
  ball.y:=y shr 8;

  ball.finex:=x and $ff;
  ball.finey:=y and $ff;

  { controlla se avviene un urto della pallina sulla parete di destra }
  { in caso d'urto inverte il segno }

  if(ball.x>SCRMAX) then
     begin
     ball.speedx:=-ball.speedx;  { inverte il vettore x della velocita' }
     ball.x:=2*SCRMAX-ball.x;    { riflette sull'asse x=SCRMAX la palla }
     ball.finex:=255-ball.finex; { aggiusta i sottomultipli della velocita' }
{     ball_block_sound(240,5);    { emette il suono dell'urto sulla la parete }
     end;

  { idem per la parete di sinistra }

  if(ball.x<SCRMIN) then
     begin
     ball.speedx:=-ball.speedx;
     ball.x:=2*SCRMIN-ball.x;
     ball.finex:=255-ball.finex;
{     ball_block_sound(240,5);}
     end;

  { ... e per quella superiore }

  if(ball.y<SCRTOP) then
     begin
     ball.speedy:=-ball.speedy;
     ball.y:=2*SCRTOP-ball.y;
     ball.finey:=255-ball.finey;
{     ball_block_sound(240,5);}
     end;


  { se la palla si trova sull'ordinata del vaus, se la velocita' vy e'
    maggiore di 0 (cioe' la palla si muove verso il basso), e se la
    palla prima si trovava al di sopra del vaus, allora ...}

  if(ball.y+BALLSPOT>VAUS_LINE) and (ball.speedy>0) and (ball.oldy<=VAUS_LINE) then
     begin
     { se un qualsiasi punto della palla si trova sul vaus ... }

     if(ball.x>vaus.x-BALLSPOT) and (ball.x<vaus.x+vaus.width+BALLSPOT) then
        begin
        { inverte il vettore vy della velocita' della palla }
        ball.speedy:=-ball.speedy;

        if (vaus.letter=6) and (not ball.launch) then
           begin
           ball.stm:=0;
           ball.launch:=TRUE;
           ball.onvaus:=ball.x-vaus.x;
           end;

{        ball_block_sound(300,6);}
        { emette il suono d'urto palla-vaus }



        { se la palla urta il cilindretto rosso di sinistra del vaus }
        if (ball.x<vaus.x+10) then
           begin
           { inverte il vettore vx, velocita' x della palla }
           ball.speedx:=-ball.speedx;

           { mette nella variabile angle l'angolo di movimento della palla
             piu' un valore casuale di deviasione compreso fra 0 e BALLDEV }
           angle:=get_ball_direction(ball)+random(BALLDEV);

           { re-imposta secondo questo nuovo angolo la direzione di movimento
             della pallina. Comunque sia' l'angolo e' compreso fra 120 e 160
             gradi. Valori superiori o inferiori a questo range vengono auto
             maticamente riportati ai valori estremi del range stesso.
             Ad esempio 175 gradi viene riportato a 160 gradi. }

           set_ball_direction(ball,max(120,min(160,angle)));

           { re-imposta la velocita' della palla, perche' cambiando l'angolo
             di movimento la velocita' viene perduta. }

           set_ball_speed(ball,ball.speed);
           end;

        { del tutto simile al precedente con la differenza che il discorso
          viene fatto per il cilindretto rosso di destra. }

        if (ball.x>vaus.x+vaus.width-10) then
           begin
           ball.speedx:=-ball.speedx;
           angle:=get_ball_direction(ball)-random(BALLDEV);
           set_ball_direction(ball,min(60,max(20,angle)));
           set_ball_speed(ball,ball.speed);
           end;

        end;
     end;

  { se la palla supera il vaus, senza che avvenga una collisione, vale
    a dire: se entrambe, la vecchia e la nuova coordinata y sono maggiori
    della dell'ordinata su cui scorre il vaus e la velocita' y della palla
    e maggiore di 0, cioe' la palla si muove verso il basso, allora la palla
    e' persa e il vaus viene fatto esplodere.}

  if (ball.oldy>VAUS_LINE) and (ball.y>SCRBOT) and (ball.speedy>0) then
     begin
     ball.inplay:=FALSE; { per adesso viene solo settato il flag, palla non
                           piu' in gioco. }
     remove_ball(ball);  { e si cancella la palla dallo schermo }
     end;

  end;

procedure modify_vaus;
  begin
  vaus.oldlen:=vaus.width;
  vaus.width :=playvaus.width;   { larghezza del vaus }
  vaus.height:=playvaus.height;  { altezza del vaus   }
  end;

procedure set_vaus; { setta i parametri iniziali (di partenza) del vaus }
  begin
  vaus.x:=((SCRMAX-SCRMIN) shr 1)-8;
  vaus.y:=VAUS_LINE;

  vaus.oldx:=EMP;                { le vecchie coordinate vengono poste a EMP }
  vaus.oldy:=EMP;                { poiche' il vaus non si e' spostato }
  vaus.iflash:=0;                { Questo viene incrementato ogni 1/70 sec. }
                                 { e quando arriva ad un certo valore viene }
                                 { azzerato e viene incrementato vaus.flash }

  vaus.flash:=0;                 { Da questa var. dipende il colore dei }
                                 { dei bordini del vaus. }
                                 { (che cambia in continuazione) }

  vaus.width :=playvaus.width;   { larghezza del vaus }
  vaus.height:=playvaus.height;  { altezza del vaus   }
  vaus.oldlen:=vaus.width;
  vaus.letter:=EMP;
                                 { entrambi sono contenuti nel file .BTM }

  end;

procedure start_vaus;
  begin
  mouse_x_limit(SCRMIN*2,(SCRMAX-vaus.width-1) shl 1);
  mousemove((SCRMAX-SCRMIN)-16,VAUS_LINE);
  vaus.x:=((SCRMAX-SCRMIN) shr 1)-8;
  vaus.y:=VAUS_LINE;

  { imposta il vaus al centro dell'area di gioco  }
  { x=(x1+x2)/2 media fra il massimo e il minimo  }
  { anche la freccina del mouse (che non si vede) }
  { viene portato al centro }

  end;

procedure remove_vaus;
label L1,L2,L3;
var y,cnt : word;
  begin
  { Toglie il vaus e disegna al suo posto lo sfondo          }

  for y:=vaus.oldy to (vaus.oldy+vaus.height) do
     memcpy(addr(playscreen.map^[vaus.oldx+row[y]]),
            addr(screen[vaus.oldx+row[y]]),vaus.oldlen);

  vaus.oldlen:=vaus.width;
  end;

procedure place_vaus;
var
  x,y,cnt : word;

  begin
  inc(vaus.iflash);        { viene incrementato ogni ciclo (1/70 sec.) }

  if vaus.iflash>SPEEDFLASH then  { se raggiunge il valore SPEEDFLASH... }
     begin
     inc(vaus.flash);             { viene incrementato vaus.flash  }
     vaus.iflash:=0;              { e viene riazzerato vaus.iflash }
     end;

  if vaus.flash>10 then vaus.flash:=0;
  { 10 sono i diversi colori che possono assumere i bordini del vaus }
  { dopodiche' il ciclo si ripete dall'inizio (cioe' da 0) }

  { Disegna il vaus facendo attenzione che i bordini (che hanno colore 255 }
  { nel disegno .BTM) devono essere sostituiti dal colore specificato da }
  { flash[vaus.flash], dove ovviamente flash[] e' una funzione dipendente da }
  { vaus.flash di cui sopra. Per esempio flash[2]:=211 (vedi all'inizio nella }
  { dichiarazione delle costanti. }

  for y:=0 to vaus.height-1 do
     begin
     { questa moltiplicazione viene fatta qui per non ripeterla }
     { vaus.width volte }
     cnt:=y * vaus.width;
     memzerocpy(addr(playvaus.map^[cnt]),addr(screen[vaus.x+row[y+vaus.y]]),vaus.width);

     if (y>=2) and (y<(vaus.height-2)) then
        begin
        screen[vaus.x+row[y+vaus.y]]:=FLASH[vaus.flash];
        screen[vaus.x+vaus.width-1+row[y+vaus.y]]:=FLASH[vaus.flash];
        end;
     end;
  end;

{ muove il vaus alle coordinate x,y }
procedure move_vaus(x,y : integer);
  begin

  { se le coordinate oldx,oldy sono valide allora bisogna cancellarlo }
  { da quella posizione }
  if(vaus.oldx<>EMP) and (vaus.oldx<>vaus.x) or (vaus.width<>vaus.oldlen) then
     remove_vaus;

  vaus.oldx:=vaus.x; { le nuove coordinate diventano le vecchie }
  vaus.oldy:=vaus.y;

  { le coordinate x,y diventano le nuove }
  { viene eseguito un clipping delle coordinate, cioe' se i valori ad }
  { esempio sono troppo alti, vengono settate al massimo valore accettabile }
  { analogamente per il minimo }

  vaus.x:=max(SCRMIN,min(x,(SCRMAX-vaus.width)));
  vaus.y:=max(SCRTOP,min(y,(SCRBOT-vaus.height)));

  place_vaus;  { chiama la funzione placevaus di cui sopra }
  end;


{ togli un mattoncino dallo schermo }
procedure remove_block(xa,ya : integer);
var
    x,y,
    xs,ys : word;
    yh,cl : integer;
    shadow: integer;

    begin
    xs:=(xa shl 4)+9;      { si calcola le coordinate sullo schermo }
    ys:=(ya shl 3)+22;     { del mattoncino es. 0,0 ---schermo---> 9,22 }

    for y:=0 to 7 do
        begin
        yh:=pattern.width*mody[ys+y]; { calcola la coord. y relativa alla }
                                      { mattonella di sfondo che deve rim-  }
                                      { piazzare il mattoncino che non c'e' }
                                      { piu' }
        { il mattoncino viene rimpiazzato col fondale, tuttavia il fondale }
        { potrebbe essere inscurito da un ombra proiettata da un altro }
        { mattoncino }

        for x:=0 to 15 do
            if (x+xs)<SCRMAX then
               begin
               { calocla l'eventuale ombra proiettata da un altro mattoncino }
               { shadow:=128 nessuna ombra, shadow:=0 c'e' l'ombra }
               shadow:=playscreen.map^[x+xs+row[y+ys]] and 128;

               { prende il pixel di sfondo e ci aggiunge l'ombra se necessario }
               cl:=(pattern.map^[modx[x+xs]+yh] and 127) or shadow;

               { dopodiche' mette il colore sia sullo schermo della VGA sia }
               screen[x+xs+row[y+ys]]:=cl;

               { sullo schermo ausiliario dove sono presenti solo gli oggetti }
               { statici e non quelli in movimento tipo pallina o vaus.}
               playscreen.map^[x+xs+row[y+ys]]:=cl;
               end;
        end;

    { In ogni modo, con il mattoncino deve sparire anche la sua ombra }
    { l'ombra non e' altro che un rettangolino delle stesse dimensioni del }
    { mattoncino ma spostato rispetto a questo di 8 pixel sulla asse x, e 4 }
    { pixel sull'asse y, in altre parole lo spigolo dell'ombra coincide con }
    { il centro del mattoncino }

    for y:=ys+4 to ys+12 do
        for x:=xs+8 to xs+24 do

            { Occorre controllare che le coordinate non siano superiori a }
            { quelle del campo di gioco poiche' in tal caso non c'e' nessuna }
            { ombra da rimuovere poiche' l'ultimo mattoncino proietta un }
            { ombra parziale che non si riflette sul muro di lato }
            { Quindi sul muro di lato non c'e' da togliere nessuna ombra }

            { Lo stesso discorso non viene fatto per il minimo, poiche' }
            { l'ombra e' sempre piu' a destra e piu' in basso del mattone }
            { che la proietta, quindi nessun mattoncino puo' proiettare un }
            { ombra sulla parete di sinistra. Nondimeno nessun mattoncino }
            { e' talmente basso da proiettare un ombra sul vaus. }

            { Dunque il caso da tenere in considerazione e' solo x<SCRMAX }

            if x<SCRMAX then
               begin
               { prende il colore di sfondo e toglie l'ombra }
               cl:=playscreen.map^[x+row[y]] or 128;

               { e lo memorizza sia sullo schermo fisico ...}
               screen[x+row[y]]:=cl;

               { che su quello virtuale (cioe' quello che tiene solo }
               { gli oggetti fissi }
               playscreen.map^[x+row[y]]:=cl;
               end;


    end;

procedure place_block(xa,ya,block : integer);
var
    x,y,
    xs,ys : word;
    cl,cl2: integer;
    shadow: integer;

    begin
    xs:=(xa shl 4)+9;   { calcola le coordinate sullo schermo relativa }
    ys:=(ya shl 3)+22;  { al mattoncino xa,ya }

    for y:=0 to 7 do
        for x:=0 to 15 do
            begin
            { controlla se alle coordinate specificate qualche mattoncino }
            { proietta un ombra }
            shadow:=playscreen.map^[xs+x+row[ys+y]] and 128;

            if (y<7) and (x<15) then
                begin
                { se si tratta dell'interno del mattoncino, lo disegna del }
                { colore specificato in block }

                cl:=(COLORBLOCK[(block-1) and 15] and 127) or shadow;
                screen[xs+x+row[ys+y]]:=cl;
                playscreen.map^[xs+x+row[ys+y]]:=cl;
                end
            else
               begin
               { nel caso le coordinate si trovino sul bordo destro o }
               { inferiore, disegna i pixel in nero }

               screen[xs+x+row[ys+y]]:=shadow; { sarebbe shadow or 0 }
               playscreen.map^[xs+x+row[ys+y]]:=shadow; {...quindi shadow }
               end;
            end;

    { adesso disegna l'ombra del mattoncino }
    for y:=ys+4 to ys+12 do
        for x:=xs+8 to xs+24 do
            if x<SCRMAX then  { controlla come in remove_block che le coord }
                              { non siano oltre alla parete di destra, poiche' }
                              { l'ombra non viene proiettata su tale parete }
               begin
               { preleva il pixel x,y dallo schermo e ci proietta sopra }
               { l'ombra. }
               cl:=playscreen.map^[x+row[y]] and 127;

               { dopo di che lo rimette sullo schermo fisico... }
               screen[x+row[y]]:=cl;

               { e su quello virtuale }
               playscreen.map^[x+row[y]]:=cl;
               end;

    if block>8 then { ma se il blocco e' grigio (=9) o marrone (=10) ... }
       begin
       cl2:=0;
       if (block and 15)=9 then
          begin
          cl2:=202; { il colore del mattoncino e' quello grigio }
          wall[xa,ya]:=9+(GRAYDOWN shl 4); { e il numero del mattone e 9+16*n }
          { dove n+1 e' il numero di colpi necessari per abbatterlo }
          { es. wall[1,2]=9+(1*16)=25 significa che il mattoncino alle }
          { coord. 1,2 cade se colpito 2 volte }
          end

       else if block=10 then cl2:=201;
       { se il blocco e marrone il colore e' il n.201 }

       { disegna il bordo superiore del mattoncino }
       for y:=0 to 6 do
           begin

           { preleva il pixel xs,y+ys dallo schermo, ci mette l'ombra }
           { cioe' fa in modo che il colore sia di tonalita' scura }
           cl:=playscreen.map^[xs+row[y+ys]] and 128;
           cl2:=(cl2 and 127) or cl;

           { ... e lo rimette sullo schermo fisico }
           screen[xs+row[ys+y]]:=cl2;

           { ... e su quello virtuale }
           playscreen.map^[xs+row[ys+y]]:=cl2;
           end;

       { disegna il bordo destro del mattoncino }
       for x:=0 to 14 do
           begin
           { commenti analoghi a sopra }
           cl:=playscreen.map^[xs+x+row[ys]] and 128;
           cl2:=(cl2 and 127) or cl;

           screen[xs+x+row[ys]]:=cl2;
           playscreen.map^[xs+x+row[ys]]:=cl2;
           end;
       end;
    end;

procedure put_wall;  { mette sullo schermo il muro contenuto in wall[x,y] }
var
    x,y : integer;

    begin
    for y:=0 to 14 do
        for x:=0 to 12 do
            if wall[x,y]<>0 then place_block(x,y,wall[x,y]);
    end;

procedure set_wall;             { imposta il muro }
var x,y,wl  : integer;
    name    : string;

    begin
    remain_blk:=0;                { sono i blocchi da distruggere }
    wl:=score.wall_n[cur_player]; { questo e' il muro a cui e' fermo il }
                                  { giocatore cur_player }

    for y:=0 to 14 do             { conta i blocchi distruttibili }
        for x:=0 to 12 do         { cioe' il blocco deve essere <>0 e <>10 }
                                  { poiche' 0 = nessun blocco, 10 = marrone }

            if (wall[x,y]<>0) and (wall[x,y]<>10) then inc(remain_blk);

    name:='PATTERN'+chr(48+((wl-1) mod PATNUMBER))+'.BTM';
    { name e' una stringa che contiene il nome del file di sfondo da caricare }

    loadBTM(name,pattern,FALSE);
    if not success then
       fatal_error('Some Background files seems to be missing');

    { e quindi carica il file in questione }
    end;

{ prende in entrata le coordinate di due punti e calcola i punti in cui il }
{ reticolo di mattoncini interseca il segmento congiungente i due punti.   }

{ i punti di intersezione possono essere 1 o 2 }

function split_line(var x1,y1,x2,y2 : integer) : integer;
var
    x,y,
    xk,yk,
    xj,yj,
    xh,yh,
    xn,yn,
    xp1,yp1,
    xp2,yp2,
    xp,yp,
    xa,ya,
    collision : integer;

    px1,px2,py1,py2 : longint;

    s1,s : string;

    begin
    inc(x1,16);         { incrementa le coordinate di tutti i punti }
    inc(y1,24);         { per evitare che nel corso delle operazioni }
    inc(x2,16);         { qualche coordinata diventi negativa }
    inc(y2,24);         { prima di terminare la proc. li rimette a posto }

    collision:=0;       { numero di intersezioni fra segmento e reticolo }

    xp1:=x1 shr 4;      { si calcola all'interno di quale mattoncino stanno }
    yp1:=y1 shr 3;      { i due punti in questione }
    xp2:=x2 shr 4;
    yp2:=y2 shr 3;

    xk:=x1;             { copia temporaneamente le coord. dei due punti }
    yk:=y1;             { in due vettori in modo da poter operare liberamente }
    xj:=x2;             { le coord. iniziali vengono passate per indirizzo }
    yj:=y2;             { e quindi non devono perdersi i valori }

    xh:=x1;
    yh:=y1;
    xn:=x2;
    yn:=y2;


    { Se e' vero questo "if" vuol dire che c'e' un baco nel programma    }
    { e quindi il gioco quit-ta all'istante segnalando l'errore.         }
    { Tale errore si verifica facilmente se si pone MAXSPEED >> 2000     }

    if (abs(x1-x2)>16) or (abs(y2-y1)>8) then
       fatal_error('Ball speed exceed program capability');

    if (xp1<>xp2) or (yp1<>yp2) then   { se i due punti non coincidono... }
       begin
       if (yp1<>yp2) then    { se i due punti hanno diversa y }
          begin
          collision:=collision or 1; { il bit piu' basso viene messo a 1 }

          while ((yn and 7)<>0) and ((yn and 7)<>7) do
            begin
            x:=(xh+xn) shr 1; { dopo di che continua a dividere il segmento }
            y:=(yh+yn) shr 1; { (x1,y1)-(x2,y2) finche non trova un inter- }
                              { sezione con un reticolo }
            yp:=y shr 3;

            if yp=yp1 then    { dei tre punti (due sono gli estremi del }
               begin          { segmento) ne scarta uno con lo stesso   }
               xh:=x;         { principio del teorema di Weierstrass.   }
               yh:=y;
               end;

            if yp=yp2 then    { Il punto di mezzo sostituisce cioe' uno }
               begin          { dei due estremi in modo che il segmento }
               xn:=x;         { sia ancora a cavallo del reticolo.      }
               yn:=y;
               end;
            end;

          end;

       if (xp1<>xp2) then   { se i due punti hanno diversa coord. x ... }
          begin
          collision:=collision or 2; { in questo caso setta il secondo bit }

          while ((xj and 15)<>0) and ((xj and 15)<>15) do
            begin
            x:=(xk+xj) shr 1;    { e i passi sono analoghi per le x }
            y:=(yk+yj) shr 1;

            xp:=x shr 4;

            if xp=xp1 then
               begin
               xk:=x;
               yk:=y;
               end;

            if xp=xp2 then
               begin
               xj:=x;
               yj:=y;
               end;

            end;

          end;


       { vengono ri-assegnati i valori agli estremi a seconda di quali }
       { porzioni del programma sono state eseguite sopra }

       if collision=1 then  { ovvero le due x uguali, le due y diverse }
          begin
          x2:=xn;
          y2:=yn;
          end
       else if collision=2 then  { le due x diverse, le due y uguali }
          begin
          x2:=xj;
          y2:=yj;
          end
       else if collision=3 then  { sia le due x che le due y diverse }
          begin
          x1:=xj;         { in questo caso le intersezioni sono 2    }
          y1:=yj;         { e la procedura li restituisce in (x1,y1) }
          x2:=xn;         { (x2,y2).                                 }
          y2:=yn;
          end;

       end

    else fatal_error('Ball seems to be still');
    { altrimenti qualcosa e' andato storto! }

    dec(x1,16);   { ripristina le vecchie coordinate }
    dec(y1,24);
    dec(x2,16);
    dec(y2,24);


    x1:=min(207,max(0,x1));
    x2:=min(207,max(0,x2));

    { per la y non vengono tagliate le coordinate <0 e >120 poiche' la   }
    { matrice che li contiene e' virtualmente piu' lunga per ragioni di  }
    { sicurezza e per coord. non valide non si trova alcun mattoncino da }
    { urtare. Il clipping in questo caso e' piu' semplice.               }

    split_line:=collision;
    end;

{ Considera colpito il blocco xb,yb: se e' un blocco normale lo toglie,
  se e' un grigio che resiste a piu' colpi ne decrementa la resistenza.
  Se il blocco non viene abbattuto allora lo fa luccicare. }

procedure shoot_block(xb,yb : integer; var ball : BALLTYPE);

    begin
    { Controlla che le coordinate del blocco siano numeri validi... }
    if (xb>=0) and (xb<=12) and (yb>=0) and (yb<=14) then
       begin
       if wall[xb,yb]<>0 then { ... che ci sia un blocco da colpire... }
          begin
          if wall[xb,yb]<10 then { se il blocco puo' essere abbattuto... }
             begin
             remove_block(xb,yb); { ..lo toglie dallo schermo }
             dec(remain_blk);     { ..decrementa il numero di blocchi che restano }

             { Incrementa lo SCORE del giocatore attuale a seconda }
             { del blocco colpito (i punti sono nell'array in SCORE_WALL) }
             inc(score.player[cur_player],SCORE_WALL[wall[xb,yb]]);

             inc(lett.incoming,random(LETTER_PROB));

             with lett do
                  begin
                  nextx:=(xb shl 4)+9;
                  nexty:=((yb+1) shl 3)+22;
                  nexttype:=random_letter_drop;
                  end;

             wall[xb,yb]:=0;          { il blocco viene cancellato        }
{             ball_block_sound(440,3); { emette un LA (nota musicale)      }
             ball.sbd:=0;             { azzera il contatore di deviazione }
             ball.brwhit:=0;          { e il cont. di dev. di emergenza   }
             end

          else    { se il blocco e marrone, o un grigio che non cade subito }
             begin
             if (wall[xb,yb] and 15)=9 then { ...se e' grigio... }
                begin
                ball.brwhit:=0;      { azzera il cont. di dev. di emergenza }
                dec(wall[xb,yb],16); { decrementa la resistenza del blocco  }

{                ball_block_sound(370,4);{ Emette un Fa# (nota musicale)    }
                shine(xb,yb);           { e imposta il luccichio del blocco }
                end
             else
                begin
                inc(ball.brwhit); { incrementa il cont. di dev. di emergenza }
                shine(xb,yb);     { imposta il luccichio }

{                ball_block_sound(200,7); { ed emette una nota piuttosto bassa }
                end;
             end;
          end;
       end;
    end;

{ Simile a quella prima ma per la collisione fire_blocco }
procedure shoot_block_with_fire(xb,yb : integer);

    begin
    if (xb>=0) and (xb<=12) and (yb>=0) and (yb<=14) then
       begin
       if wall[xb,yb]<>0 then { ... che ci sia un blocco da colpire... }
          begin
          if wall[xb,yb]<10 then { se il blocco puo' essere abbattuto... }
             begin
             remove_block(xb,yb); { ..lo toglie dallo schermo }
             dec(remain_blk);     { ..decrementa il numero di blocchi che restano }
             inc(score.player[cur_player],SCORE_WALL[wall[xb,yb]]);
             wall[xb,yb]:=0;          { il blocco viene cancellato        }
{             ball_block_sound(440,3); { emette un LA (nota musicale)      }
             end

          else    { se il blocco e marrone, o un grigio che non cade subito }
             begin
             if (wall[xb,yb] and 15)=9 then { ...se e' grigio... }
                begin
                dec(wall[xb,yb],16); { decrementa la resistenza del blocco  }
{                ball_block_sound(370,4);{ Emette un Fa# (nota musicale)    }
                shine(xb,yb);           { e imposta il luccichio del blocco }
                end
             else
                begin
                shine(xb,yb);     { imposta il luccichio }
{                ball_block_sound(200,7); { ed emette una nota piuttosto bassa }
                end;
             end;
          end;
       end;
    end;


procedure ball_hit_block(var ball : BALLTYPE);
var x,y,z    : integer;
    xb,yb    : integer;
    x1,y1    : array[0..4] of integer;
    a,b,
    ox,oy,
    lx,ly,
    mx,my,
    nx,ny,
    f1,f2,
    collision: integer;
    betaflag : boolean;
    touch    : integer;
    adjw     : array[0..2,0..2] of integer;
    deflect,
    around,
    emergency,
    mimax,
    angle,
    myx,myy  : integer;

    begin
    emergency:=EMP;    { l'indicatore di rimbalzo di emergenza }

    nx:=ball.x-9;      { nx,ny hanno le coordinate della palla rispetto }
    ny:=ball.y-22;     { all'origine fissata nell'angolo Nord-Ovest del }
                       { campo di gioco (entro cui si muove la palla).  }

    ox:=ball.oldx-9;   { idem per le vecchie coordinate, l'origine e'   }
    oy:=ball.oldy-22;  { quindi il punto dello schermo (9,22).          }

    xb:=nx shr 4;     { xb,yb sono le coordinate del blocco (eventualmente  }
    yb:=ny shr 3;     { ipotetico) su cui si trova ora la pallina.          }
                      { Ricordarsi che (0,0) e' il blocco in altro a destra }

    if wall[xb,yb]<>0 then  { ...se il blocco non e' ipotetico ma esiste }
       begin
       collision:=split_line(ox,oy,nx,ny);
       { calcola l'intersezione del segmento che unisce le vecchie alle    }
       { nuove coordinate. "Collision" contiene un valore che dipende dal  }
       { tipo di intersezioni riscontrate fra il segmento e la griglia dei }
       { blocchi.                                                          }

       if collision=3 then     { se sono avvenute due collisioni... }
          begin
          lx:=ball.oldx-ox-9;  { si calcola la distanza della vecchia }
          ly:=ball.oldy-oy-22; { coordinata dal punto di intersezione 1 }

          mx:=ball.oldx-nx-9;  { e dal punto di intersezione 2 }
          my:=ball.oldy-ny-22;

          f1:=lx*lx+ly*ly;     { indi sceglie fra i due il punto di }
          f2:=mx*mx+my*my;     { intersezione piu' vicino alle vecchie coord. }

          if (f1<f2) then      { f1 e f2 sono il quadrato del modulo del }
                               { vettore distanza (vedi sopra) }

             { Si considera il caso in cui l'intersezione piu' vicina sia }
             { la numero 1. }

             begin
             xb:=min(12,max(ox shr 4,0));  { Vengono assegnate le coord. }
             yb:=((oy+24) shr 3)-3;        { del blocco relative a tale  }
                                           { intersezione.               }

             if wall[xb,yb]=0 then         { Se non vi e' alcun blocco   }
                begin
                xb:=min(12,max(0,nx shr 4)); { Allora l'urto avviene sull' }
                yb:=((ny+24) shr 3)-3;       { altra intersezione. La n.2  }
                end
             else
                begin                        { Se invece il blocco esiste  }
                nx:=ox;                      { allora alle nuove coord. si }
                ny:=oy;                      { assegna il punto di inter-  }
                                             { sezione contenuto nelle vec-}
                                             { chie.                       }
                end;
             end
          else
             begin
             { Nel caso sia la seconda intersezione piu' vicina alle }
             { vecchie coord. si procede analogamente.               }

             xb:=min(12,max(0,nx shr 4)); { Si calcolano le coord. del blocco }
             yb:=((ny+24) shr 3)-3;       { sull'intersezione nx,ny (la seconda) }

             if wall[xb,yb]=0 then        { Se il blocco non c'e'... }
                begin
                nx:=ox;                   { allora l'intersezione valida e' }
                ny:=oy;                   { l'altra, e si procede... }

                xb:=min(12,max(0,nx shr 4)); { ...riassegnando alle nuove }
                yb:=((ny+24) shr 3)-3;       { coord. l'intersezione n.1  }
                end;
             end;

          end;

       ball.x:=nx+9;    { Le nuove coordinate della palla sono quelle      }
       ball.y:=ny+22;   { contentenute nelle variabili nx,ny, ritraslando  }
                        { gli assi. nx,ny avevano i relativi assi centrati }
                        { in (9,22).                                       }

       shoot_block(xb,yb,ball);  { abbatte il blocco in questione }

       x:=(nx and 15) shr 1;     { si calcola il punto d'urto della palla }
       y:=(ny and 7);            { rispetto al mattoncino.                }

       { Dividendo per 2 la coord. x dell'urto si ottiene una sezione d'urto }
       { su di un mattone quadrato invece che rettangolare che semplifica in }
       { seguito i calcoli. Il mattone e' infatti di 16x8 pixel dividendo    }
       { per 2 diventa di 8x8 pixel, e i calcoli sulle diagonali sono piu'   }
       { semplici. }


       { Se l'urto non avviene su uno dei bordi del mattone allora vuole }
       { dire che qualcosa e' andato storto. In teoria non dovrebbe mai  }
       { verificarsi.                                                    }
       if (x<>0) and (x<>7) and (y<>0) and (y<>7) then
          fatal_error('Ball hit a block not on its surface');


       { Questi sono i valori che assume EMERGENCY a seconda del punto d'urto }

       {                     5     1     8                               }
       {                      -----------                                }
       {                    2 | mattone | 4                              }
       {                      -----------                                }
       {                     6     3     7                               }



       { Se la palla urta il bordo superiore del mattoncino... }

       if (y<x) and (x<7-y) then
          begin
          ball.speedy:=-ball.speedy;   { Si inverte la coord. y della vel. }
          emergency:=1;                { e segna l'eventiale punto di contatto }
          end;

       { ...il bordo inferiore... }
       if (7-y<x) and (x<y) then
          begin
          ball.speedy:=-ball.speedy;   { inverte la y della vel. }
          emergency:=3;
          end;

       { ...il bordo sinistro... }
       if (x<y) and (y<7-x) then
          begin
          ball.speedx:=-ball.speedx;   { inverte la x della vel. }
          emergency:=2;
          end;

       { ... e quello destro ... }
       if (7-x<y) and (y<x) then
          begin
          ball.speedx:=-ball.speedx;   { inverte la x della vel. }
          emergency:=4;
          end;

       { ... se invece avviene su uno dei quattro spigoli ... }
       if (x=y) or (x=7-y) then
          begin
          deflect:=$00;
          touch:=0;

          { touch assume valori diversi a seconda dello spigolo         }
          { Segue la tabella (per es. 0 = angolo in alto a sinistra)    }

          { 0 1 }
          { 2 3 }

          if x>4 then touch:=touch or 1;
          if y>4 then touch:=touch or 2;


          { Qui riempie una matrice 3x3 con degli 1 o degli 0 a seconda che }
          { attorno al blocco urtato rispettivamente vi siano o no altri    }
          { mattoncini }

          { I bordi sinistro e destro del campo di gioco vengono considerati }
          { come mattoncini indistruttibili in questo caso.                  }

          for lx:=-1 to 1 do
              for ly:=-1 to 1 do
                  begin
                  mx:=max(min(xb+lx,12),0); { quando si fa rif. alla x la }
                  my:=yb+ly;                { coord deve essere compresa  }
                                            { fra 0 e 12.                 }

                  if ((xb+lx)<0 ) or
                     ((xb+lx)>12) or
                     (wall[mx,my]<>0) then
                        adjw[lx+1,ly+1]:=1   { Vi sono mattoncini }
                  else
                     adjw[lx+1,ly+1]:=0;     { Non vi sono mattoncini }

                  end;

          { Around contiene un valore che in binario rappresenta lo stato }
          { dei mattoncini che stanno attorno al mattone urtato.          }

          {        -------------                      }
          {        | 1 | 2 | 4 |                      }
          {        -------------                      }
          {        |128| U | 8 |   U = mattone urtato }
          {        -------------                      }
          {        | 64| 32| 16|                      }
          {        -------------                      }

          { Es. se attorno ad U si trovano i mattoncini 1,2,128 il valore }
          { di around e' 1+2+128=131.                                     }

          around:=adjw[0,0]+(adjw[1,0] shl 1)+
                            (adjw[2,0] shl 2)+(adjw[2,1] shl 3)+
                            (adjw[2,2] shl 4)+(adjw[1,2] shl 5)+
                            (adjw[0,2] shl 6)+(adjw[0,1] shl 7);

          { Deflect contiene un valore che in esadecimale rappresenta le }
          { modifiche da apportare alla vx (prima cifra esadec.) e alla  }
          { y (seconda cifra esadec.). Secondo la seguente tabella.      }

          { 0 = coordinata inalterata }
          { 1 =     ''     negativa   }
          { 2 =     ''     positiva   }
          { 3 =     ''     invertita  }

          { Es. Deflect:=$13 significa poni vx negativo e inverti vy }
          {     Deflect:=$20 significa poni vx positivo e lascia stare vy }

          { ------------------------------------------------------------- }

          { Seguono le combinazioni caso per caso dello spigolo urtato, dei   }
          { mattoni che questo a attorno e di conseguenza ricava la direzione }
          { della palla.                                                      }

          { l'and logico significa considera solo i mattoni la cui somma }
          { da il numero che segue. }

          { Per es. "and 131" significa considera solo i mattoni 1+2+128 }
          { gli altri se ci sono o no non importa.        }

          if touch=0 then       { spigolo in alto a sinistra }
             begin
             if (around and 131)=0   then deflect:=$11;
             if (around and 131)=1   then deflect:=$33;
             if (around and 131)=2   then deflect:=$10;
             if (around and 131)=3   then deflect:=$12;
             if (around and 131)=128 then deflect:=$01;
             if (around and 131)=129 then deflect:=$21;
             if (around and 131)=130 then deflect:=$11;

             emergency:=5;
             shoot_block(xb-1,yb-1,ball);
             end;

          { "and 14" sono i mattoni 2+4+8, gli altri non importa }

          if touch=1 then       { spigolo in altro a destra  }
             begin
             if (around and 14)=0    then deflect:=$21;
             if (around and 14)=2    then deflect:=$20;
             if (around and 14)=4    then deflect:=$33;
             if (around and 14)=6    then deflect:=$22;
             if (around and 14)=8    then deflect:=$01;
             if (around and 14)=10   then deflect:=$21;
             if (around and 14)=12   then deflect:=$11;

             emergency:=8;
             shoot_block(xb+1,yb-1,ball);
             end;

          if touch=2 then       { Spigolo in basso a sinistra }
             begin
             if (around and 224)=0    then deflect:=$12;
             if (around and 224)=32   then deflect:=$10;
             if (around and 224)=64   then deflect:=$33;
             if (around and 224)=96   then deflect:=$11;
             if (around and 224)=128  then deflect:=$02;
             if (around and 224)=160  then deflect:=$12;
             if (around and 224)=192  then deflect:=$22;

             emergency:=6;
             shoot_block(xb-1,yb+1,ball);
             end;

          if touch=3 then       { Spigolo in basso a destra   }
             begin
             if (around and 56)=0    then deflect:=$22;
             if (around and 56)=8    then deflect:=$02;
             if (around and 56)=16   then deflect:=$33;
             if (around and 56)=24   then deflect:=$12;
             if (around and 56)=32   then deflect:=$20;
             if (around and 56)=40   then deflect:=$22;
             if (around and 56)=48   then deflect:=$21;

             emergency:=7;
             shoot_block(xb+1,yb+1,ball);
             end;

          { La prima cifra hex (esadecimale) viene messa in myx }
          { e la seconda in myy. }

          myx:=deflect shr 4;
          myy:=deflect and 15;

          if myx=1 then ball.speedx:=-abs(ball.speedx);
          if myx=2 then ball.speedx:= abs(ball.speedx);
          if myx=3 then ball.speedx:=-    ball.speedx ;

          if myy=1 then ball.speedy:=-abs(ball.speedy);
          if myy=2 then ball.speedy:= abs(ball.speedy);
          if myy=3 then ball.speedy:=-    ball.speedy ;

          end;

       end;


    { Nel caso che il numero di mattoni indistruttibili urtati consecutivamente }
    { prima di urtare un mattone di un altro tipo superi una determinata soglia }

    if ball.brwhit>MAXBRWHIT then
       begin
       { Se emergency e' rimasto a EMP significa che qualcosa e' andato storto }
       if emergency=EMP then fatal_error('No collisions detected');

       mimax:=EMERG_DEV[emergency]; { Altrimenti si calcola la deviazione }
                                    { massima e minima del mattoncino.    }

       { e a seconda di quale spigolo viene urtato e di come sono i mattoni }
       { attorno a tale spigolo, la deviazione viene modificata. }

       { Per quanto il rimbalzo finale possa essere strano, questo controllo }
       { viene fatto per evitare che la palla si incastri in un loop infinito }

       { ovviamente il caso vale per i mattoni indistruttibili perche' gli }
       { altri prima o poi cadono e quindi non possono bloccare la palla   }
       { per un tempo infinito.                                            }

       { Ogni cifra hex di mimax esprime un angolo a multipli di 90 gradi  }
       { la prima cifra e' l'angolo minimo, la seconda quello massimo.     }

       { Es. MIMAX:=$03; singifica angolo minimo 0*90 = 0 gradi, angolo max }
       { 3*90 = 270 gradi, e cosi' via...                                   }

       { una scrittura del tipo "mimax:=mimax and $0f or 10" significa }
       { metti a 1 la prima cifra di mimax indipendentemente da quanto }
       { vale adesso, lasciando inalterata la seconda.                 }

       { Analogo il ragionamento per "... and $f0 or $03" che agisce   }
       { sulla seconda cifra invece che sulla prima...                 }

       case emergency of

         5: begin
            if adjw[1,0]=0 then mimax:=mimax and $0f or $00;
            if adjw[0,1]=0 then mimax:=mimax and $f0 or $03;
            end;

         6: begin
            if adjw[0,1]=0 then mimax:=mimax and $0f or $10;
            if adjw[1,2]=0 then mimax:=mimax and $f0 or $04;
            end;

         7: begin
            if adjw[1,2]=0 then mimax:=mimax and $0f or $20;
            if adjw[2,1]=0 then mimax:=mimax and $f0 or $05;
            end;

         8: begin
            if adjw[2,1]=0 then mimax:=mimax and $0f or $30;
            if adjw[1,0]=0 then mimax:=mimax and $f0 or $06;
            end;

         end;

       repeat

          lx:=90*(mimax shr 4);    { la prima cifra di mimax viene posta in }
          mx:=90*(mimax and 15);   { lx e la seconda in mx.                 }
          angle:=random(mx-lx)+lx; { L'angolo e' una variabile casuale fra  }
                                   { lx e mx }

       until ((angle mod 90)>30) and ((angle mod 90)<60);
       { e questo ciclo si ripete finche' la palla ha un inclinazione }
       { compresa fra i 30 e i 60 gradi piu' multipli di 90 gradi.    }

       set_ball_direction(ball,angle mod 360);
       set_ball_speed(ball,ball.speed);

       ball.brwhit:=0; { Azzera il contatore di emergenza }
       end;

    end;


{ Disegna il fondale sul terreno di gioco }
procedure fill_picture_with_pattern(var patt : BTMTYPE);
var x,y,
    cl,
    shadow,
    yb      : integer;

    begin
    { Si calcola a priori tutti i valori di x mod patt.width }
    { patt.width = larghezza del quadrattino che definisce lo sfondo }

    for x:=0 to 319 do
        modx[x]:=x mod patt.width;

    { analogamente per y mod patt.height }

    for y:=0 to 199 do
        mody[y]:=y mod patt.height;

    { Esegue il ciclo principale e il ciclo secondario che riempiono lo }
    { schermo con tanti quadretti di sfondo quanti sono necessari }

    for y:=SCRTOP-2 to SCRBOT-2 do
        begin
        yb:=mody[y]*patt.width;
        for x:=SCRMIN-1 to SCRMAX-1 do
            begin
            cl:=patt.map^[modx[x]+yb]; { Prende il pixel dallo sfondo }
            shadow:=128;               { Shadow = 128 -> ombra non presente }

            { Fa l'ombra sul fianco sinistro e superiore dello schermo  }
            { E' l'ombra proiettata dal bordo metallico sullo sfondo di }
            { gioco.                                                    }
            if (y<16) or (x<18) then shadow:=0; { Shadow=0 -> ombra presente }

            { Disegna il pixel sullo schermo con l'eventuale ombra }
            playscreen.map^[x+row[y]]:=(cl and 127) or shadow;
            end;
        end;

    end;

{ Carica tutti i muri contenuti nel file WHWALLS.BTM }
procedure load_all_walls;
var
    s    : string;
    f1   : text;
    x,
    y,
    z,
    w    : integer;
    loop : boolean;

    begin
    loop:=TRUE;
    assign(f1,'whwalls.dta');    { Apre il file }
    reset(f1);                   { si porta all'inizio dello stesso }

    x:=0;  { coordinata x del mattoncino attuale-3 }
    y:=0;  { coordinata y del mattoncino attuale }
    z:=0;  { numero del muro attuale-1 }

    while(loop) do
       begin
       s:='                                      ';
       readln(f1,s);
       if s[1]='*' then { Se il primo carattere della riga e' un asterisco }
          begin
          if (y>14) then fatal_error('Too many blocks');

          for x:=3 to 15 do    { Allora dal terzo al 15 vi sono i 13 blocchi }
              begin            { che costituiscono la fila }
              w:=ord(s[x])-96; { Se e' un "a" (codice 97) allora w:=1 }
              if w<0 then w:=0;
              all_walls[z][x-3,y]:=w;  { Quindi all_walls contiene tutti }
              end;                     { i muri. z=numerod del muro.     }

          inc(y); { Passa alla fila successiva }

          for x:=0 to 12 do           { Le due file estreme sono sempre vuote }
              begin                   { vale a dire [x,-1] e [x,15]           }
              all_walls[z][x,-1]:=0;
              all_walls[z][x,15]:=0;
              end;
          end

       else if s[1]=';' then   { Il ";" indica che si intende passare al }
          begin                { prossimo muro. }
          x:=0;
          y:=0;

          if (z>32) then fatal_error('Too many walls');
          inc(z);
          end
       else if s[1]='/' then loop:=false;
       { lo slash indica la fine logica del file, tutto cio' che segue }
       { viene ignorato.                                               }

       { Qualunque riga incominci con un carattere diverso da ";" "*" "/"  }
       { viene considerata una linea di commento e viene pertanto ignorata }

       end;

     close(f1);
     totalwall:=z;
     end;

procedure write_round_level;
var x,y : integer;            { Stampa la scritta ROUND xx, READY.        }
    s,r,                      { eventualmente anche il nome del giocatore }
    sc  : string[20];         { cioe' PLAYER ONE o PLAYER TWO.            }

    begin
    settextstyle(DefaultFont,HorizDir,1);
    str(score.wall_n[cur_player]:2,s);
    r:='Round '+s;
    sc:='';
    if score.pl_numb=2 then   { Nel caso di 2 giocatori, occorre anche }
       begin                                       { dire a chi tocca. }
       if cur_player=1 then sc:='Player One'
       else sc:='Player Two';
       end;

    setcolor(0);                            { Stampa le scritte in nero }
    for x:=0 to 2 do                        { come contorno spostandole }
        for y:=0 to 2 do                    { di una coordinata in tutte }
            begin                           { le direzioni.              }
            outtextxy(72+x,129+y,sc);
            outtextxy(80+x,139+y,r);
            outtextxy(90+x,149+y,'Ready');
            end;

    setcolor(1);                  { E poi centrata, in bianco stampa }
    outtextxy(73,130,sc);         { la scritta vera e propria.       }
    outtextxy(81,140,r);
    outtextxy(91,150,'Ready');
    end;

procedure remove_round_level;  { Togli la scritta ROUND xx, READY }
var x,y : word;                { copiandoci sopra il fondale.     }
    begin
    for y:=129 to 160 do
        memcpy(addr(playscreen.map^[72+row[y]]),
               addr(screen[72+row[y]]),88);
    end;


{ Stampa la scitta GAME OVER }
procedure Game_over;
var x,y : integer;
    sc  : string[20];

    begin
    settextstyle(DefaultFont,HorizDir,1);  { Setta la font di default }

    sc:='';
    if score.pl_numb=2 then                  { Se vi sono 2 giocatori  }
       begin                                 { deve dire quale dei due }
       if cur_player=1 then sc:='Player One' { ha finito.              }
       else sc:='Player Two';                { E mette in sc "PLAYER ... " }
       end;                                  { altrimenti sc rimane vuoto  }

    setcolor(0);
    for x:=0 to 2 do
        for y:=0 to 2 do
            begin                                { Disegna la scritta in    }
            outtextxy(72+x,129+y,sc);            { nero spostata di una     }
            outtextxy(76+x,139+y,'Game Over');   { coord. in tutte le direz.}
            end;

    setcolor(1);                    { E poi al centro delle scritte in nero }
    outtextxy(73,130,sc);           { stampa quella in bianco.              }
    outtextxy(77,140,'Game Over');

    mydelay(500);
    remove_round_level; { in questo caso rimuove la scritta GAME OVER }
    closeprogram;                        { invece della scritta ROUND xx, READY.       }
    end;


{ Mostra in sequenza i fotogrammi del vaus che si distrugge. }
procedure destroy_vaus;
var x,y,z,w : word;
    a,b     : word;

    begin
    playvaus:=normal;
    modify_vaus;

    move_vaus(vaus.x,vaus.y);

    a:=vaus.x-4;     { Si calcola uno spostamento dovuto al brush  }
    b:=vaus.y-5;     { dell'animazione che e' leggermente spostato }
                     { dall'origine degli assi.                    }

    for w:=0 to 6 do  { w = fotogramma da mostrare, li cicla tutti da 0 a 6 }
        begin
        for y:=0 to 15 do
            begin
            z:=y*explosion.width+w*(explosion.width shl 4);
            for x:=0 to explosion.width-1 do
                begin
                { Se il colore e' trasparente o il fotogramma e' il 6 }
                { allora viene usato il colore del fondale.           }
                if (w=6) or (explosion.map^[x+z]=0) then
                   screen[x+a+row[y+b]]:=playscreen.map^[x+a+row[y+b]]
                else
                   screen[x+a+row[y+b]]:=explosion.map^[x+z];
                end;
            end;

{        death_sound(w);   { Il cicalino di quando il vaus viene distrutto }
                          { per ogni valore di w c'e' una nota diversa    }
        end;

{    death_sound(7);}
    mydelay(150);         { attende qualche istante. }
    disable_letter;       { se nel frattempo stava scendendo una lettera, }
                          { la toglie.                                    }
    end;

{ E' esattamente come quella di prima, soltanto che mostra l'animazione }
{ del vaus che si costruisce.                                           }
procedure create_vaus;
var x,y,z,w : word;
    a,b     : word;

    begin
    nosound;
    a:=((SCRMAX-SCRMIN) div 2)-12;
    b:=vaus_line-5;

    for w:=11 downto 0 do
        begin
        for y:=0 to 15 do
            begin
            z:=y*newvaus.width+w*(newvaus.width*16);
            for x:=0 to newvaus.width-1 do
                begin
                if (newvaus.map^[x+z]=0) then
                   screen[x+a+row[y+b]]:=playscreen.map^[x+a+row[y+b]]
                else
                   screen[x+a+row[y+b]]:=newvaus.map^[x+z];
                end;
            end;

        mydelay(1);
        end;
    end;

procedure put_digit(px,py,num : word);  { Stampa la cifra digitale num }
                                        { alle coord. px,py.           }
var x,y,a : word;

    begin
    a:=222; { Il colore 222 e' il rosso scuro che viene usato se il led }
            { in questione deve apparire spento.                        }
            { Mentre il colore 223 e' il rosso vivo di quando il led e' }
            { acceso.                                                   }

    { ----------------- }
    { |       0       | }
    { ----------------- }
    { |   |       |   | }
    { | 3 |       | 5 | }
    { |   |       |   | }
    { |   |       |   | }
    { ----------------- }
    { |       1       | }
    { ----------------- }
    { |   |       |   | }
    { | 4 |       | 6 | }
    { |   |       |   | }
    { |   |       |   | }
    { ----------------- }
    { |       2       | }
    { ----------------- }

    { Bit 0 }
    if (DIGITS[num] and 1)=1 then a:=223;   { Se il bit 0 e' 1 allora    }
    for x:=1 to 4 do                        { il colore del led in altro }
        screen[px+x+row[py]]:=a;            { e' rosso vivo, altrimenti  }
                                            { rosso scuro.               }

    { Bit 1 }
    a:=222;                             { "a" viene assunto come rosso scuro }
    if (DIGITS[num] and 2)=2 then a:=223; { eventualmente viene poi cambiato }
    for x:=1 to 4 do
        screen[px+x+row[py+5]]:=a;    { py+5 perche' il trattino in mezzo }
                                      { e' 5 pixel piu' sotto di quello   }
                                      { in altro.                         }
    { Bit 2 }
    a:=222;
    if (DIGITS[num] and 4)=4 then a:=223;
    for x:=1 to 4 do
        screen[px+x+row[py+10]]:=a;

    { Bit 3 }
    a:=222;
    if (DIGITS[num] and 8)=8 then a:=223;
    for y:=1 to 4 do
        screen[px+row[py+y]]:=a;

    { Bit 4 }
    a:=222;
    if (DIGITS[num] and 16)=16 then a:=223;
    for y:=1 to 4 do
        screen[px+row[py+y+5]]:=a;

    { Bit 5 }
    a:=222;
    if (DIGITS[num] and 32)=32 then a:=223;
    for y:=1 to 4 do
        screen[px+5+row[py+y]]:=a;

    { Bit 6 }
    a:=222;
    if (DIGITS[num] and 64)=64 then a:=223;
    for y:=1 to 4 do
        screen[px+5+row[py+y+5]]:=a;

    end;


{ Stampa le 5 cifre del punteggio alle coordinate px,py }
procedure write_score(px,py : integer; sc : longint);
var n1 : longint;
    f  : boolean;

   begin
   f:=false; { Finche' questo rimane a false, gli 0 non vengono stampati  }
             { Questo per far si che' all'inizio il punteggio sia 0 e non }
             { 000000 che sta male.                                       }

   { prima cifra digitale }
   n1:=(sc div 100000) mod 10;
   if n1>0 then f:=true;          { Se la prima cifra e' >0 allora }
   if f then put_digit(px,py,n1)  { occorre stamparla }
   else put_digit(px,py,10);      { altrimenti stampa un numero spento }

   { seconda cifra digitale }
   n1:=(sc div 10000) mod 10;     { Idem per i restanti blocchi }
   if n1>0 then f:=true;
   if f then put_digit(px+7,py,n1)
   else put_digit(px+7,py,10);

   { terza cifra digitale }
   n1:=(sc div 1000) mod 10;
   if n1>0 then f:=true;
   if f then put_digit(px+14,py,n1)
   else put_digit(px+14,py,10);

   { quarta cifra digitale }
   n1:=(sc div 100) mod 10;
   if n1>0 then f:=true;
   if f then put_digit(px+21,py,n1)
   else put_digit(px+21,py,10);

   { quinta cifra digitale }
   n1:=(sc div 10) mod 10;
   put_digit(px+28,py,n1);

   { sesta e ultima cifra digitale (che ovviamente e' sempre 0 perche' }
   { il punteggio viaggia a multipli di 10 punti.                      }
   put_digit(px+35,py,0);
   end;

{ Quando si richiama la pausa il controllo passa a questa procedura }
procedure pause_game;
var x,y,z : integer;

    begin
    nosound;                    { disattiva qualunque suono del cicalino }
    setcolor(0);                { Stampa la scritta in nero spostandola  }
    for x:=0 to 2 do            { in tutte le direzioni.                 }
        for y:=0 to 2 do
            outtextxy(66+x,129+y,'Game Paused');

    setcolor(1);                      { Indi stampa quella in bianco }
    outtextxy(67,130,'Game Paused');

    repeat
    z:=inkey;                        { e aspetta finche' non viene premuto }
    until (z=ord('p')) or (z=32);    { o la "p" o lo spazio (z=32)         }


    { Cancella la scritta ricopiandoci sopra il fondale }
    for y:=129 to 140 do
        memcpy(addr(playscreen.map^[66+row[y]]),
               addr(screen[66+row[y]]),textwidth('Game Paused')+1);

    { textwidth('Game Paused') e' una funziona che ritorna la lunghezza }
    { in pixel della scritta 'Game Paused'.                             }
    end;


{ Stampa i vaus piccolini in basso a sinistra che indicano il numero di }
{ vite che restano disponibili (senza contare quella in gioco).         }
procedure plot_lives(lives : integer);

const XLIVES = 11;
      YLIVES = 192;

var x,y,cn,
    xp,yp,
    xl,yl   : word;
    shadow  : integer;

    begin
    dec(lives); { Il numero di vite deve essere decrementato di uno }
                { perche' non va contata quella in gioco.           }

    for cn:=0 to 7 do                       { al massimo ne disegna 8 }
        for y:=0 to minivaus.height-1 do
            for x:=0 to minivaus.width-1 do
                begin
                xl:=x+XLIVES+cn*minivaus.width;
                yl:=y+YLIVES;

                xp:=modx[xl];
                yp:=mody[yl]*pattern.width;

                { se il numero di vite e maggiore del contatore }
                { allora disegna un vaus.                       }
                if (lives>cn) and (minivaus.map^[x+y*minivaus.width]<>0) then
                   begin
                   screen[xl+row[yl]]:=minivaus.map^[x+y*minivaus.width];
                   playscreen.map^[xl+row[yl]]:=minivaus.map^[x+y*minivaus.width];
                   end

                { altrimenti ricopia il fondale dello schermo in modo che }
                { se il vaus era presente viene ora cancellato.           }
                else
                  begin
                  shadow:=playscreen.map^[xl+row[yl]] and 128;
                  screen[xl+row[yl]]:=(pattern.map^[xp+yp] and 127) or shadow;
                  playscreen.map^[xl+row[yl]]:=(pattern.map^[xp+yp] and 127) or shadow;
                  end;
                end;
    end;

procedure place_fire;
var y,fw : word;
    begin
    for y:=0 to shoots.height-1 do
        begin
        fw:=shoots.width*y;
        memzerocpy(addr(shoots.map^[fw]),
                   addr(screen[fire.x+row[y+fire.y]]),shoots.width);
        end;
    end;

procedure remove_fire;
var y,fw : word;
    begin
    for y:=0 to shoots.height-1 do
        begin
        fw:=shoots.width*y;
        memcpy(addr(playscreen.map^[fire.x+row[y+fire.y]]),
               addr(screen[fire.x+row[y+fire.y]]),shoots.width);
        end;
    end;

procedure check_fire;
var x1,x2,y1,y2 : word;
    begin
    if (fire.avl) then
       begin
       if (mouseclick=1) and (fire.avl) and (not fire.shot) then
          begin
          fire.x:=vaus.x+(vaus.width-shoots.width) shr 1;
          fire.y:=vaus.y-shoots.height;
          fire.shot:=TRUE;
          fire.nw  :=FALSE;
{          ball_block_sound(700,5);}
          end;

       if fire.shot then
          begin
          if fire.nw then remove_fire;
          fire.nw:=TRUE;

          dec(fire.y,4);
          if fire.y<22 then fire.shot:=FALSE
          else
              begin
              place_fire;

              if ((fire.y-22)>=0) and ((fire.y-22)<120) then
                 begin
                 x1:=(fire.x-9 ) shr 4;
                 y1:=(fire.y-22) shr 3;

                 x2:=(fire.x+shoots.width-9) shr 4;
                 y2:=y1;

                 if (wall[x1,y1]<>0) or (wall[x2,y2]<>0) then
                    begin
                    remove_fire;
                    fire.shot:=FALSE;

                    shoot_block_with_fire(x1,y1);
                    shoot_block_with_fire(x2,y2);
                    end;
                 end;
              end;
          end;
       end;
    end;

procedure remove_flux;
var y : word;
    begin
    for y:=0 to 19 do
        memcpy(addr(playscreen.map^[217+row[y+FLUXLEVEL]]),
               addr(screen[217+row[y+FLUXLEVEL]]),8);
    end;

procedure check_flux;
var y,fx  : word;

   begin
   fx:=scrfluxcnt;
   if scrflux then
      begin
      for y:=0 to 19 do
          memcpy(addr(flux.map^[(y+fx) shl 3]),
                 addr(screen[217+row[y+FLUXLEVEL]]),8);

      inc(scrfluxcnt);
      if scrfluxcnt>20 then scrfluxcnt:=0;
      end;
   end;

procedure vaus_out;
var x,y,z : word;
    begin
    nosound;

    inc(score.player[cur_player],10000);
    remain_blk:=0;

    z:=vaus.x;

    wait_vbl;
    remove_vaus;
    place_vaus;

    for x:=z to z+44 do
        begin
        Wait_VBL;

        vaus.oldx:=vaus.x;
        vaus.x:=x;
        remove_vaus;
        check_flux;
        place_vaus;

        for y:=vaus.y to vaus.y+vaus.height do
            memcpy(addr(playscreen.map^[225+row[y]]),
                   addr(screen[225+row[y]]),40);


        end;

    end;


procedure check_bonus_type(var b1,b2,b3 : BALLTYPE);
var x,y : longint;
    begin
      if vaus.letter>0 then
         begin
         lett.last:=vaus.letter-1;
         if b2.inplay then remove_ball(b2);
         if b3.inplay then remove_ball(b3);
         b2.inplay:=FALSE;
         b3.inplay:=FALSE;
         scrflux:=FALSE;
         remove_flux;

         if vaus.letter<>6 then
            begin
            b1.launch:=FALSE;
            b2.launch:=FALSE;
            b3.launch:=FALSE;
            end;
         end;

      case vaus.letter of

        1: begin                              { Lettera L }
           if fire.shot then remove_fire;
           playvaus:=lasers;
           modify_vaus;
           vaus.letter:=0;
           fire.avl:=TRUE;
           fire.shot:=FALSE;
           end;

        2: begin                              { Lettera E }
           if fire.shot then remove_fire;
           playvaus:=enlarged;
           modify_vaus;
           vaus.letter:=0;
           fire.avl:=FALSE;
           end;

        3: begin                              { Lettera B }
           if fire.shot then remove_fire;
           playvaus:=normal;
           modify_vaus;
           vaus.letter:=0;
           fire.avl:=FALSE;
           scrflux:=TRUE;
           end;

        4: begin                              { Lettera D }
           if fire.shot then remove_fire;
           playvaus:=normal;
           modify_vaus;
           fire.avl:=FALSE;
           end;

        5: begin                              { Lettera S }
           if fire.shot then remove_fire;
           playvaus:=normal;
           modify_vaus;
           vaus.letter:=0;
           x:=max(b1.speed-500,BALLSPEED);
           set_ball_speed(b1,x);
           fire.avl:=FALSE;
           end;

        6: begin                              { Lettera C }
           if fire.shot then remove_fire;
           playvaus:=normal;
           modify_vaus;
           fire.avl:=FALSE;
           end;

        7: begin                              { Lettera P }
           if fire.shot then remove_fire;
           playvaus:=normal;
           modify_vaus;
           vaus.letter:=0;
           inc(score.lives[cur_player]);
           plot_lives(score.lives[cur_player]);
{           ball_block_sound(2000,10);}
           fire.avl:=FALSE;
           end;

        end;
     end;

procedure deviate_ball(var ball : BALLTYPE);
var temp : integer;

   begin
   repeat
   temp:=get_ball_direction(ball)+random(BALLDEV)-(BALLDEV shr 1);
   until ((temp mod 90)>30) and ((temp mod 90)<60);

   set_ball_direction(ball,temp);
   set_ball_speed(ball,ball.speed);
   ball.sbd:=0;
   end;

{ ------------------------------------------------------------------------ }

{ Questa e' la procedura principale che durante il gioco chiama tutte le  }
{ altre. Finche' la palla non viene persa o il quadro viene terminato     }
{ (o eventualmente viene abortita la partita) la procedura mantiene il    }
{ controllo. Termina in uno solo in uno dei casi sopra citati o in caso   }
{ si verifichi un fatal_error a causa del quale il programma e' costretto }
{ a quittare automaticamente e inevitabilmente.                           }


function Bounceball : boolean;
var
  x,y  : integer;
  key  : integer;
  ball : array[1..3] of BALLTYPE;
  stm  : integer;
  temp : integer;
  t1,t2: longint;

  begin
  scrfluxcnt:=0;
  scrflux:=FALSE;

  balls_in_play:=1;

  fire.avl:=FALSE;
  playvaus:=normal;

  lett.last:=EMP;
  lett.active:=FALSE;

  { Mette lo sfondo giusto a seconda del muro }
  fill_picture_with_pattern(pattern);

  { Disegna il quadro di gioco con lo sfondo pocanzi settato}
  showBTMpicture(playscreen);

  { Stampa il numero delle vite del giocatore corrente }
  { cur_player=1 o 2 a seconda di quale giocatore deve giocare }
  plot_lives(score.lives[cur_player]);

  { regola i colori, in teoria dovrebbero gia' essere a posto. }
  setpalette(playscreen);

  { Stampa il punteggio dei 2 giocatori e l'hi-score. }
  write_score(253,POS_DIGIT[1],score.player[1]);
{  write_score(253,POS_DIGIT[2],score.player[2]);}
  write_score(253,POS_DIGIT[3],score.hiscore);

  { Disegna i mattoncini }
  put_wall;

  { Esegue un reset nel caso il mouse abbia qualche problema, alle volte }
  { succede. }
  mousereset;

  { La palla e' in gioco e deve essere lanciata }
  ball[1].inplay:=TRUE;
  ball[1].launch:=TRUE;

  { Setta le coordinate iniziali della palla }
  ball[1].x:=((SCRMAX+SCRMIN) shr 1)-2;
  ball[1].y:=VAUS_LINE-BALLSPOT;

  { annulla quelle vecchie }
  ball[1].oldx:=EMP;
  ball[1].oldy:=EMP;

  { La deviazione avviene quando questo valore supera una certa soglia }
  ball[1].sbd:=0;

  { La distanza iniziale della palla quando si trova sul vaus dal bordo }
  { sinistro del vaus stesso.                                           }
  ball[1].onvaus:=16;

  { Tiene il numero di vertical-blank che passano da quando appare   }
  { il vaus con la pallina a quando essa viene lanciata.              }
  { Se il valore supera le 2000 unita' la palla parte automaticamente }
  ball[1].stm:=0;

  { Alla partenza la variabile lett.incoming assume un valore casuale }
  { fra 0 e LETTER_DROP (costante definita all'inizio della unit.     }
  lett.incoming:=random(LETTER_DROP);

  { Mostra l'animazione del vaus che si materializza dal nulla }
  create_vaus;

  { e stampa la scritta ROUND xx, READY. }
  write_round_level;

  set_vaus;                       { Regola i parametri iniziali del vaus. }
  start_vaus;
  move_vaus(vaus.x,VAUS_LINE);    { lo porta al centro dell'area di gioco }
{  start_level;                    { Se il suono e' attivo fa la musichetta }
  start_vaus;
  remove_round_level;             { Toglie la scritta ROUND xx, READY }
  set_ball(ball[1]);

  { Questo e' il ciclo principale, puo' uscire da esso solo se : }
  { - la palla viene persa,                                      }
  { - il quadro viene terminato (cioe' non restano piu' mattoni  }
  {   da distruggere.                                            }
  { - la partita viene in qualche modo abortita.                 }

  set_ball_direction(ball[1],random(15)+60); { angolo di partenza casuale }
                                             { 60 e 75 gradi }
  set_ball_speed(ball[1],BALLSPEED);

  { velocita' iniziale = BALLSPEED costante }
  ball[1].finespeed:=0; { i sottomultipli della velocita' sono 0  }

  ball[2].inplay:=FALSE;
  ball[3].inplay:=FALSE;

  while(ball[1].inplay) and (remain_blk>0) and (not score.abortplay) do
     begin
     Wait_VBL; { Attende il vertical blank }

     mousecoords(x,y);  { legge le coordinate del mouse }

     { se il trainer (vaus in modalita' automatica) non e' attiva }
     { muove il vaus alla coord.x del mouse.                      }
     if trainer=0 then move_vaus(x,VAUS_LINE)

     { se invece e' attivo impone che la x del vaus sia uguale alla x della }
     { palla, con un opportuno coefficiente di traslazione per far si che   }
     { la palla batta al centro del vaus e non sul bordo sinistro.          }
     else if trainer=1 then
          move_vaus(min(SCRMAX-32,max(ball[1].x-ball[1].onvaus,SCRMIN)),VAUS_LINE);

     { ball[1].launch vale TRUE se la palla e' attaccata al vaus e deve }
     { essere lanciata. Altrimenti quando e' in gioco vale false.       }
     if ball[1].launch=TRUE then
        begin
        inc(ball[1].stm);  { se la palla e' attaccata il contatore di scatti }
                           { viene continuamente incrementato.               }


        { Quando raggiunge quota 250 la palla parte automaticamente }
        if ball[1].stm=250 then ball[1].launch:=FALSE;

        { Fa in modo che la palla segua il vaus se questo viene spostato }
        start_ball(ball[1]);

        { Se si preme il tasto del mouse allora la palla parte }
        if mouseclick=1 then ball[1].launch:=FALSE;
        end

     else
        { altrimenti se la palla non e' attaccata occorre semplicemente   }
        { muoverla. Chiaramente se le palle sono 3 bisogna muoverle tutte }
        { e tre.                                                          }
        for cn:=1 to 3 do
            if ball[cn].inplay then move_ball(ball[cn]);

     { Se le coord. della pallina cn sono comprese fra 22 e 142 (rispettivamente }
     { massima e minima coord. in cui si puo' urtare un mattoncino) allora }
     { occorre controllare se la palla ha effettivamente urtato un mattoncino }
     { oppure no. }

     for cn:=1 to 3 do
         begin
         if (ball[cn].inplay) then   { tutte le considerazioni valgono se }
                                     { la palla e' in gioco.              }
            begin
            if (ball[cn].y>=22) and (ball[cn].y<142) then
               ball_hit_block(ball[cn]);

            set_ball(ball[cn]);
            ball[cn].speed:=ball_speed(ball[cn]);
            end;
         end;

     checkshine;     { controlla se c'e' da far scintillare un mattoncino }
     check_letter;   { se sta scendendo una lettera }
     check_bonus_type(ball[1],ball[2],ball[3]); { se viene raccolta una lettera }
     check_fire;     { se e' stato sparato un colpo di laser }
     check_flux;

     if ((vaus.x+vaus.width)=(SCRMAX-1)) and (scrflux) then vaus_out;

     if vaus.letter=4 then   { nel caso sia stata raccolta una D le palle }
        begin                { diventano 3.                               }
        balls_in_play:=3;

        ball[2]:=ball[1];    { la palla 2 e 3 vengono poste uguale alla 1 }
        ball[3]:=ball[1];

        t1:=get_ball_direction(ball[1]) div 90;
        { si il quadrante in cui si trova il vettore velocita' }
        t2:=ball[1].speed;  { nonche' il modulo del vettore stesso }

        { si impone un inclinazione di 30 gradi rispetto al quadrante alla }
        { prima palla, di 45 alla seconda e di 60 alla terza.              }

        { A questo punto le tre palle sono costrette a dividersi. }

        set_ball_direction(ball[1],(t1*90+30));
        set_ball_direction(ball[2],(t1*90+45));
        set_ball_direction(ball[3],(t1*90+60));


        { Le tre velocita' invece rimangono quella della prima palla }
        set_ball_speed(ball[1],t2);
        set_ball_speed(ball[2],t2);
        set_ball_speed(ball[3],t2);

        vaus.letter:=0;
        end;

     { finche' c'e' piu' di una palla in gioco, nessuna lettera deve arrivare }
     if balls_in_play>1 then lett.incoming:=0;

     { Aggiorna lo score del giocatore }
     write_score(253,POS_DIGIT[cur_player],score.player[cur_player]);

     { Se lo score del giocatore e maggiore dell'hi-score }
     if score.player[cur_player]>score.hiscore then
        begin
        { pone l'hi-score uguale allo score del giocatore }
        score.hiscore:=score.player[cur_player];
        { e stampa l'hi-score sullo schermo }
        write_score(253,POS_DIGIT[3],score.hiscore);
        end;

     { Questo ciclo aumenta la velocita' di tutte le palle in gioco        }
     { il valore di LEVEL[lv] dipende ovviamente dal lv, cioe' dal livello }
     { selezionato prima di cominciare la partita.                         }

     for cn:=1 to 3 do
         begin
         if ball[cn].inplay then
            begin
            inc(ball[cn].finespeed);
            if ball[cn].finespeed>LEVEL[lv] then
               begin
               ball[cn].finespeed:=0;

               { se la velocita' e' inferiore a quella massima }
               if ball[cn].speed<MAXSPEED then
                  begin
                  inc(ball[cn].speed,10);  { la si incrementa }
                  set_ball_speed(ball[cn],ball[cn].speed); { e la si aggiorna }
                  end;
               end;

            inc(ball[cn].sbd); { questo e' il contatore di deviazione regolare }

            { se supera una certa soglia (SBDIR) viene imposta una deviazione }
            { casuale di un angolo compreso fra i -BALLDEV/2 e +BALLDEV/2 }
            if (ball[cn].sbd>=SBDIR) and (ball[cn].speedy<0) then
               deviate_ball(ball[cn]);
            end;
         end;

     { Questo ciclo fa in modo che la palla n.1 sia sempre in gioco }
     { (a meno che non vengano perse tutte e tre) }

     { Se si pedre la n.1, la n.2 prende il posto della n.1, la n.3 prende }
     { il posto nella n.2, infine la n.3 viene disattivata                 }

     { poiche' le tre palle sono uguali, il processo avviene senza che il  }
     { giocatore percepisca materialmente la sostituzione.                 }

     { in questo modo se terminato il ciclo la palla n.1 risulta non essere }
     { in gioco, significa che tutte e tre sono cadute. }

     for cn:=1 to 3 do
         if not ball[1].inplay then
            begin
            ball[1]:=ball[2];
            ball[2]:=ball[3];
            ball[3].inplay:=FALSE;
            end;

     balls_in_play:=0;  { Si ricalcola ogni volta il numero delle palle in }
     for cn:=1 to 3 do  { gioco. }
         if ball[cn].inplay then inc(balls_in_play);


     if (not ball[1].inplay) then   { Se la palla n.1 non e' piu' in gioco }
        begin
        ball[1].launch:=TRUE;
        remove_ball(ball[1]);         { la si toglie dallo schermo }
        destroy_vaus;                 { mostra la sequenza di distruzione }
        dec(score.lives[cur_player]); { decrementa di 1 il numero delle vite }
        score.wall_p[cur_player]:=wall; { memorizza il una variabile assegnata }
                                        { al giocatore il muro corrente }
        { Questo accade perche' se i giocatori sono due, occorre passare }
        { all'altro giocatore che probabilmente non si trovera nella stessa }
        { posizione. I mattoncini devono poi essere riportati tali e quali }
        { quando il turno passa di nuovo al giocatore che ora a perso una  }
        { vita. }

        nosound; { e disabilita' il suono }
        end;


     { Se la nota corrente dura finche' snd_delay non diventa 0 }
{     if snd_delay>0 then dec(snd_delay)
     else nosound;

     { ---------------------- Trainer Options -------------------- }

     key:=inkey;  { si guarda se viene premuto un tasto }

     if (key=ord('p')) or (key=32) then pause_game; { Il tasto P pausa il gioco }

     if key=7680 then
     begin
     score.abortplay:=TRUE;  { ALT+A, la partita e' abortita }
     end;

     if (key=ord('T')) then { Se si preme la T (maiuscola) viene generata }
        begin               { una fila di mattoncini. }
        for cn:=0 to 12 do
            begin
            { Chiaramente se il mattoncino indistruttibile deve sostituire }
            { un altro mattoncino distruttibile, bisogna che il numero totale }
            { di mattoncini da abbattere per finire il quadro diminuisca di 1 }
            if (wall[cn,14]>0) and (wall[cn,14]<>10) then
               dec(remain_blk);

            wall[cn,14]:=10;  { e il mattoncino in questione diventa indistruttibile }
            end;

        put_wall; { e viene fatto l'aggiornamento sullo schermo }
        end;

     { La 'R' maiuscola abilita la modalita' automatica del vaus }
     if key=ord('R') then trainer:=1;

     { La 'r' minuscola la disabilita }
     if key=ord('r') then trainer:=0;

     { Se il tasto e' una a,b,c,d,e,f,g: viene fatta cadere una lettera }
     if (key>=97) and (key<(97+LETTER_NUMB-1)) then { Fa cadere la lettera }
        start_letter(104,30,key-97);

     if key=11520 then                        { ALT+X, quit-ta }
        begin
        closegraph;
        nosound;
        closeprogram;
        end;

     end;

  { BounceBall esce con false se la palla e' stata persa, con true se }
  { il quadro e' stato finito. }

  Bounceball:=FALSE;
  if remain_blk=0 then Bounceball:=TRUE;
  end;

{ ------------------------------------------------------------- }

function choose_start_wall : integer;
const px = 70;
      py = 100;
      dx = 34;
      dy = 35;
      ddx= 19;
      ddy= 14;

var x,y,z : longint;
    st    : integer;
    oldx,
    oldy,
    newx,
    newy  : integer;
    sc    : string[20];

    begin
    st:=1;  { Si comincia a scegliere partendo dal muro n.1 }

    settextstyle(DefaultFont,HorizDir,1);
    setcolor(0);

    { Stampa PLAYER xxx se il numero di giocatori e' 2 }
    if cur_player=1 then sc:='Player One'
    else sc:='Player Two';

    { stampa le scritte CHOOSE YOER WALL, ecc... }
{    for x:=-1 to 1 do
        for y:=-1 to 1 do
            begin
            outtextxy(px+5+x,py+y,sc);
            outtextxy(px+x,py+y+10,'Choose your');
            outtextxy(px+6+x,py+y+20,'start wall');

            outtextxy(px-39+x,py+58+y,'Move mouse to select;');
            outtextxy(px-45+x,py+68+y,'left button to confirm');
            end;}

{    setcolor(1);
    outtextxy(px+5,py,sc);
    outtextxy(px,py+10,'Choose your');
    outtextxy(px+6,py+20,'start wall');

    outtextxy(px-39,py+58,'Move mouse to select;');
    outtextxy(px-45,py+68,'left button to confirm');}

    { Disegna il quadrato nero in cui devono apparire i numeri del muro }
    { da scegliere.                                                     }
{    for y:=py+dy to py+dy+ddy do
        for x:=px+dx to px+dx+ddx do
            screen[x+row[y]]:=0;

    mousecoords(oldx,oldy);  { rileva le coordinate del mouse }

{    while(mouseclick=1) do;
    while(mouseclick<>1) do
       begin
       put_digit(px+dx+3,py+dy+2,st div 10); { Scrive il numero del quadro }
{       put_digit(px+dx+11,py+dy+2,st mod 10);
{
       mousecoords(newx,newy);       { Se le coord. sono diverse: }
{       if newx>oldx then inc(st);    { se la x e' maggiore il quadro aumenta }
 {      if newx<oldx then dec(st);    { se e' munore diminuisce.              }

       { Se supera il massimo selezionabile torna al n.1 }
{       if st>totalwall then st:=st-totalwall;

       { se supera il minimo selezionabile torna al massimo (n.32) }
{       if st<1 then st:=st+totalwall;

       oldx:=newx; { le nuove coord. diventano le vecchie. }
{       oldy:=newy;

       end;}

    choose_start_wall:=1;  { e ritorna il numero selezionato }
    end;

procedure set_start_parameters;
var x : integer;
   begin
   { Imposta i parametri del giocatore 1 e 2 }

   for x:=1 to 2 do
       begin
       score.player[x]:=1;
       score.lives[x] :=5;
       score.wall_n[x]:=STARTWALL;
       score.wall_p[x]:=all_walls[STARTWALL-1];
       score.roundsel[x]:=FALSE;
       end;

   cur_player:=1;
   end;

procedure soundicon;
var x,y,fl,fw,h : word;

    begin
    { Altezza dell'icona (l'icona e' alta il doppio perche' il brush }
    { e' composto dall'icona con la nota e l'icona con la X una sopra l'altra }
    h:=soundfx.height div 2;

    fl:=0; { se sound_on non e' false, cioe' e' TRUE allora fl:=0 }
           { punto in cui inizia il disegno dell'icona con la nota }


    { altrimenti fl viene spostato al punto in cui c'e' l'icona con la X }
{    if sound_on=FALSE then
       fl:=soundfx.width*h;}

    { e quindi copia uno dei due disegni sullo schermo }
    for y:=0 to h-1 do
        begin
        fw:=y*soundfx.width;
        for x:=0 to soundfx.width-1 do
            screen[320-soundfx.width+x+row[y+200-h]]:=soundfx.map^[x+fw+fl];
        end;
    end;

procedure level_selection;
var x,y,fl,fw,h : word;

    begin
    { Disegna sullo schermo uno dei 5 numeri a seconda del valore di lv }
     h:=levelsel.height div 5;    { I frames sono 5 quindi l'altezza di un }
                                 { frame e' l'altezza totale del disegno/5 }

     fl:=(lv-1)*h*levelsel.width; { fl contiene l'indirizzo del frame da }
                                 { copiare sullo schermo.               }

     for y:=0 to h-1 do
        begin
        fw:=y*levelsel.width;
        for x:=0 to levelsel.width-1 do
            screen[x+row[y+200-h]]:=levelsel.map^[x+fw+fl];
        end;
end;

function mainscreen : integer;
var x,y,z : word;
    ps    : integer;
    srow  : array[0..100] of word;
    k,ik  : integer;

    begin
    nosound;                { spegne il cicalino }
    score.abortplay:=FALSE; { e' imposta il flag di partita abortita a FALSE }

    for x:=0 to 63999 do    { Cancella lo schermo }
        screen[x]:=0;

    setpalette(playscreen); { Imposta i colori }

    { E copia la pagina di presentazione con la scritta ARKANOID sullo schermo }
    { tramite la procedura scritta in assembler. }
{    memcpy(addr(presents.map^),addr(screen),64000);}

{    soundicon;         { disegna l'icona del suono }
{    level_selection;   { e quella del livello }
     mousereset;        { resetta il mouse per precauzione }

{    repeat             { cicla finche' non viene fatto qualcosa }
       { k tiene lo stato del mouse, ik gli eventuali tasti premuti }

{      k:=mouseclick;
{     ik:=inkey;

       if ik=11520 then k:=-1;   { ALT+X = quit }  { k<>0 interrompe il ciclo }


{    if ik=32 then             { SPACE BAR = switch del suono on/off }
{      begin
{          sound_on:=sound_on XOR TRUE;    { x xor 1 inverte il valore di x }
{          soundicon; { e disegna l'icona} { 0 xor 1 = 1; 1 xor 1 = 0 }
{     end;

{       if ik=15104 then    { se si preme F1 il livello aumenta }
{        begin
{          inc(lv);
           if lv>5 then lv:=1;   { se e' superiore a 5 torna ad 1 }
{          level_selection;      { e stampa il numero sullo schermo }
{        end;

       if ik=15360 then    { se si preme F2 il livello diminuisce }
{        begin
{         dec(lv);
          if lv<1 then lv:=5;  { se e' inferiore a 1 torna a 5 }
       {   level_selection;     { e stampa il numero sullo schermo }
        {  end;}

{    until k<>0;    { il ciclo si interrompe se k e' diverso da 0 }

{    mainscreen:=k; { ritorna dunque: -1=quit, 1=un giocatore, 2=due giocatori }
     mainscreen:=1;
end;

procedure start_game(players : integer);
var nwall : boolean;

    begin
    set_start_parameters;                 { imposta i parametri di partenza }
    if players=1 then score.lives[2]:=0;  { se c'e' un solo giocatore il }
                                          { seconda non ha neanche una vita }
    trainer:=0;                           { il trainer viene disattivato }
    wall:=score.wall_p[cur_player];       { si copia nel muro corrente }
                                          { quello del giocatore corrente }
    set_wall;                             { e lo si disegna }
{   fill_picture_with_pattern(pattern);   { si imposta lo sfondo }
    showBTMpicture(playscreen);           { e si disegna tutto quanto sullo }
                                          { schermo }
    setpalette(playscreen);               { si impostano i colori. }
    { si stampano i tre punteggi, player 1, 2 e hi-score }
    write_score(253,POS_DIGIT[1],score.player[1]);
{   write_score(253,POS_DIGIT[2],);}
    write_score(253,POS_DIGIT[3],score.hiscore);
    { e si disegnano i mattoncini del muro }
    put_wall;
    repeat
          repeat
             { se non e' ancora stato scelto il muro da cui partire }
             { viene fatto scegliere al giocatore (cur_player) ora  }
             if not score.roundsel[cur_player] then
                begin
                score.wall_n[cur_player]:=choose_start_wall;
                { viene assegnato il muro scelto al giocatore }
                score.wall_p[cur_player]:=all_walls[score.wall_n[cur_player]-1];
                { a questo punto e' stato scelto il muro }
                score.roundsel[cur_player]:=TRUE;
                end;
             { viene messo il muro del giocatore nel muro corrente }
             wall:=score.wall_p[cur_player];
             set_wall;
             { Si parte, questa assegnazione chiama bounceball, che non }
             { termina finche ho vieen perso il vaus o viene terminato  }
             { il quadro.                                               }
             nwall:=BounceBall;


             { Se viene terminato il quadro nwall vale TRUE }
             if nwall then
                begin
                { quindi si incrementa il numero del muro a cui si trova }
                { il giocatore cur_player }
                inc(score.wall_n[cur_player]);
                { e se viene superato il numero massimo si riparte dal n.1 }
                if score.wall_n[cur_player]>totalwall then
                   score.wall_n[cur_player]:=1;
                { e viene prelevato in nuovo muro dalla matrice generale }
                score.wall_p[cur_player]:=
                      all_walls[score.wall_n[cur_player]-1];
                end
             else
                 { se non e' stato completato il muro si guarda se il numero }
                 { delle vite e' sceso a zero }
                 { nel qual caso si stampa la scritta GAME OVER }
                 if score.lives[cur_player]=0 then Game_Over;

          { il ciclo si ripete finche bounceball dice che non e' stato }
          { completato il muro (nwall=FALSE) il che significa che e' stata }
          { persa una vita }
          until nwall=FALSE;
          { allora il controllo passa all'altro giocatore }
          inc(cur_player);
           if cur_player>players then cur_player:=1;
          { a meno che un giocatore non abbia terminato il numero di vite    }
          { a disposizione, nel qual caso il controllo resta del giocatore   }
          { che ha perso la vita. Notare che questo funziona benissimo anche }
          { se c'e' un giocatore solo, poiche' l'altro giocatore ha le vite  }
          { a 0.                                                             }
          if score.lives[cur_player]=0 then cur_player:=3-cur_player;
    { il ciclo si ripete finche entrambi i giocatori non esauriscono le vite }
    { o la partita viene abortita con ALT+A }
    until ((score.lives[1]=0) and (score.lives[2]=0)) or (score.abortplay);

    end;
end.
