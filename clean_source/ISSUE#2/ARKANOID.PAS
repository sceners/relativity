
unit Arkanoid;
{$F+}
interface

uses crt,dos,graph,mouse,snd,service,FM;
procedure StartGame(var score1:longint);

implementation
uses revdat,revgif;
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

   sound_on:=False;      { per default all'inizio il suono e' attivo }
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
end.
