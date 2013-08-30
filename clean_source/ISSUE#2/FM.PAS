(****************************************************************************

(c) 1992 by Michelangelo Policarpo per Sound Blaster Digest Italia

Unit FM per la gestione diretta della sezione FM di una qualsiasi scheda
AdLib compatibile.

Versione 1.0        7/10/92       Primo rilascio al Pubblico Dominio

L'autore ha posto ogni cura (e tempo) nella realizzazione di queste routines,
testandole sotto svariate condizioni di uso.

A causa della varieta` delle condizioni e dell' hardware con cui queste pos-
sono essere utilizzate, non e` pero` possibile offrire alcuna garanzia sul
loro corretto funzionamento.

Chi usa questo pacchetto (o direttamente derivato) accetta implicitamente
tutte le le clausole qui riportate :
1.  L' utente si assume ogni responsabilita` per gli eventuali danni che le
    routines possono provocare, soprattutto a causa di un uso improprio del
    prodotto.
2.  L' utente deve riportare nella documentazione di accompagnamento del
    software da lui prodotto il copyright sopra riportato o equivalente nota
    di utilizzo di questo pacchetto.

QUESTO PACCHETTO VIENE RILASCIATO AL PUBBLICO DOMINIO E PERTANTO DEVE ESSERE
DISTRIBUITO LIBERAMENTE E GRATUITAMENTE. TALE PACCHETTO PUO` ANCHE ESSERE
MODIFICATO PURCHE` RIMANGA INTATTA LA NOTA DI COPYRIGHT E QUESTA PARTE DI
COMMENTO.

****************************************************************************)

unit FM;

interface

const
  Melodic = 0;
  Rhythmic = 1;
  Undefined = $FF;

  OFF = false;
  ON = true;

const
  FMErrorMsg : array[1..10] of string[31] =
    ('AdLib or SB card not present',
     'Invalid note',
     'Invalid voice',
     '',
     '',
     '',
     '',
     '',
     '',
     '' );

{.BNK entry file structure}

type
  Operator = record
    KSL,       FreqMult,  Feedback,  Attack,
    SustLevel, EG,        Decay,     Release,
    Output,    AM,        Vib,       KSR,       FM : byte
  end;

type
  InsDataPtr = ^InsData;
  InsData = record
    Mode, PercVoice : byte;
    Op0, Op1 : Operator;
    Wave0, Wave1 : byte
  end;

{.INS file structure}

type
  OPER = record
    KSL,       FreqMult,  Feedback,  Attack,
    SustLevel, EG,        Decay,     Release,
    Output,    AM,        Vib,       KSR,       FM : word
  end;

  INS = record
    Mode : byte;
    PercVoice : byte;
    OPER0,OPER1 : OPER;
  end;

  INSEXT = record
    INSBase : INS;
    Wave0,Wave1 : word;
    Pad : array[1..10] of word;
    One : word;
  end;

var
  FMError : integer;
  CurrentFMMode : byte;
  BaseReg : word;
  AdLibInstalled : boolean;
  WaveFormEnabled, CSMModeEnabled, KBDSplitEnabled, AMDepthEnabled,
  VIBDepthEnabled : boolean;

{Global variables}

procedure SetMelRhythm(State : boolean);

procedure SetWaveForm (State : boolean);
procedure SetCSMMode  (State : boolean);
procedure SetKBDSplit (State : boolean);
procedure SetAMDepth  (State : boolean);
procedure SetVIBDepth (State : boolean);

{Operator cells parameters}
          {For any}
procedure SetAM          (Ofs,Data : byte);
procedure SetVib         (Ofs,Data : byte);
procedure SetEG          (Ofs,Data : byte);
procedure SetKSR         (Ofs,Data : byte);
procedure SetFreqMult    (Ofs,Data : byte);
procedure SetKSL         (Ofs,Data : byte);
procedure SetOutput      (Ofs,Data : byte);
procedure SetAttack      (Ofs,Data : byte);
procedure SetDecay       (Ofs,Data : byte);
procedure SetSustLevel   (Ofs,Data : byte);
procedure SetRelease     (Ofs,Data : byte);
procedure SetWaveSel     (Ofs,Data : byte);
          {Only for modulator}
procedure SetFeedback    (Ofs,Data : byte);
procedure SetFM          (Ofs,Data : byte);

{For direct register access, CMF}

function  ModOfs(channel : byte) : byte;
function  CarOfs(channel : byte) : byte;

procedure SetSC(Ofs, Data : byte);
procedure SetSO(Ofs, Data : byte);
procedure SetAD(Ofs, Data : byte);
procedure SetSR(Ofs, Data : byte);
procedure SetWS(Ofs, Data : byte);
procedure SetFC(Ofs, Data : byte);

{General routines}

procedure SetFMMode     (FMMode : byte);

procedure AssignVoice   (Voice : byte; Ins : InsData);

procedure AllKeyOff;

procedure KeyOn         (Voice, Note : byte);
procedure KeyOff        (Voice : byte);
procedure QuitVoices;
procedure QuitVoice     (Voice: byte);
procedure ResetVoice    (Voice: byte);
procedure ResetSynth;

function  FMStatus      (voice : byte) : InsDataPtr;
procedure FMInit(Base : word);

function  FindBasePort : boolean;
function  FindSBPBasePort : word;
function  IsAdLib : boolean;

implementation

type
  InsArray = array[0..29] of byte;

const
  FNumbers :
    array[0..11] of word = (363,385,408,432,458,485,514,544,577,611,647,686);

{Offsets in registers array}

  M_OpCell : array[1..9,0..1] of byte =
    (($00,$03),($01,$04),($02,$05),
    ($08,$0B),($09,$0C),($0A,$0D),
    ($10,$13),($11,$14),($12,$15));

  R_OpCell : array[1..11,0..1] of byte =
    (($00,$03),($01,$04),($02,$05),
    ($08,$0B),($09,$0C),($0A,$0D),
    ($10,$13),($14,$FF),($12,$FF),
    ($15,$FF),($11,$FF));

  Octave : array[0..95] of byte =
    (0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,
    4,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,
    6,6,6,6,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7);

  Semitone : array[0..95] of byte =
    (0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11,
    0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11,
    0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11,
    0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11);

                     {M/PV-1}                   {Op0}             {v--caution!}         {Op1}                  {WS}

  Piano1 : InsArray = ( 0,00,  1, 1, 3,15, 5, 0, 1, 3,15, 0, 0, 0, 0,  0, 1, 0,13, 7, 0, 2, 4,16, 0, 0, 1, 0,  0,0);
  BDrum1 : InsArray = ( 1,06,  0, 0, 0,10, 4, 0, 8,12,11, 0, 0, 0, 0,  0, 0,47,13, 4, 0, 6,15,16, 0, 0, 0, 1,  0,0);
  Snare1 : InsArray = ( 1,07,  0,12, 0,15,11, 0, 8, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);
  Tom1   : InsArray = ( 1,08,  0, 4, 0,15,11, 0, 7, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);
  Cymbal1: InsArray = ( 1,09,  0, 1, 0,15,11, 0, 5, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);
  HiHat1 : InsArray = ( 1,10,  0, 1, 0,15,11, 0, 7, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);

const

{Register offsets}                                        {Range}

{First group : general}

  R_TEST   : byte = $01;  {Test}                         {001h}
  R_TIM1   : byte = $02;  {Timer 1}                      {002h}
  R_TIM2   : byte = $03;  {Timer 2}                      {003h}
  R_TIMC   : byte = $04;  {Timer Control}                {004h}
  R_CSMK   : byte = $08;  {CSM Mode/Keyboard Split}      {008h}
  R_AVR    : byte = $BD;  {AM VIB-Depth/Rhythm}          {0BDh}

{Second group : for each operator cell}

  R_AVEKM  : byte = $20;  {AM/VIB/EG/KSR/MULTIPLE}       {020h-035h}
  R_KTL    : byte = $40;  {KSL/Total Level}              {040h-055h}
  R_ARDR   : byte = $60;  {Attack Rate/Decay Rate}       {060h-075h}
  R_SLRR   : byte = $80;  {Sustain Level/Release Rate}   {080h-095h}
  R_WS     : byte = $E0;  {Wave Select}                  {0E0h-0F5h}

{Third group : for each channel}

  R_FNUM   : byte = $A0;  {F-Number Low bits}            {0A0h-0A8h}
  R_BLK    : byte = $B0;  {F-Number High bits}           {0B0h-0B8h}
  R_FBC    : byte = $C0;  {Feedback/Connection}          {0C0h-0C8h}

var
  FMRegisters : array[0..$FF] of byte;
  MelRhythm : boolean;

  Install : boolean;
  TmpInsData : InsData;

procedure OutCmd; assembler;            {al = Address; ah = Data}

asm {OutCmd}
  push  ax
  push  dx
  push  bx
  xor   bx,bx
  mov   bl,al
  mov   byte ptr FMRegisters[bx],ah     {UpDate buffer area}
  pop   bx
  cmp   Install,true
  je    @GoOn
  cmp   AdlibInstalled,true
  jne   @Exit
@GoOn:
  mov   dx,BaseReg
  out   dx,al
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx

  inc   dx
  mov   al,ah
  out   dx,al
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx

  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx

  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx

  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
  in    al, dx
@Exit:
  pop   dx
  pop   ax
end; {OutCmd}

procedure SetAM(Ofs,Data : byte); assembler;

asm {SetAM}
  mov   al,Data
  and   al,00000001b
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bl,20h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,01111111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetAM}

procedure SetVib(Ofs,Data : byte); assembler;

asm {SetVib}
  mov   al,Data
  and   al,00000001b
  ror   al,1
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,20h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,10111111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetVib}

procedure SetEG(Ofs,Data : byte); assembler;

asm {SetEG}
  mov   al,Data
  and   al,00000001b
  ror   al,1
  ror   al,1
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,20h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11011111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetEG}

procedure SetKSR(Ofs,Data : byte); assembler;

asm {SetKSR}
  mov   al,Data
  and   al,00000001b
  ror   al,1
  ror   al,1
  ror   al,1
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,20h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11101111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetKSR}

procedure SetFreqMult(Ofs,Data : byte); assembler;

asm {SetFreqMult}
  mov   al,Data
  and   al,00001111b
  xor   bx,bx
  mov   bl,Ofs
  add   bx,20h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11110000b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetFreqMult}

procedure SetKSL(Ofs,Data : byte); assembler;

asm {SetKSL}
  mov   al,Data
  and   al,00000011b
  ror   al,1
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,40h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,00111111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetKSL}

procedure SetOutput(Ofs,Data : byte); assembler;

asm {SetOutput}
  mov   al,Data
  and   al,00111111b
  xor   bx,bx
  mov   bl,Ofs
  add   bx,40h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11000000b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetOutput}

procedure SetAttack(Ofs,Data : byte); assembler;

asm {SetAttack}
  mov   al,Data
  and   al,00001111b
  ror   al,1
  ror   al,1
  ror   al,1
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,60h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,00001111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetAttack}

procedure SetDecay(Ofs,Data : byte); assembler;

asm {SetDecay}
  mov   al,Data
  and   al,00001111b
  xor   bx,bx
  mov   bl,Ofs
  add   bx,60h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11110000b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetDecay}

procedure SetSustLevel(Ofs,Data : byte); assembler;

asm {SetSustLevel}
  mov   al,Data
  and   al,00001111b
  ror   al,1
  ror   al,1
  ror   al,1
  ror   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,80h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,00001111b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetSustLevel}

procedure SetRelease(Ofs,Data : byte); assembler;

asm {SetRelease}
  mov   al,Data
  and   al,00001111b
  xor   bx,bx
  mov   bl,Ofs
  add   bx,80h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11110000b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetRelease}

procedure SetWaveSel(Ofs,Data : byte); assembler;

asm {SetWaveSel}
  mov   al,Data
  and   al,00000011b
  xor   bx,bx
  mov   bl,Ofs
  add   bx,0E0h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11111100b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetWaveSel}

procedure SetFeedback(Ofs,Data : byte); assembler;

asm {SetFeedback}
  mov   al,Data
  and   al,00000111b
  shl   al,1
  xor   bx,bx
  mov   bl,Ofs
  add   bx,0C0h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11110001b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetFeedback}

procedure SetFM(Ofs,Data : byte); assembler;

asm {SetFM}
  mov   al,Data
  and   al,00000001b
  xor   bx,bx
  mov   bl,Ofs
  add   bx,0C0h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11111110b
  or    ah,al
  mov   al,bl
  call  OutCmd
end; {SetFM}

procedure SetOpCellParameters(Offset : byte; Op : Operator; WaveSel : byte);

begin {SetOpCellParameters}
  with Op do
    begin
      SetAM       (Offset,AM);
      SetVib      (Offset,Vib);
      SetEG       (Offset,EG);
      SetKSR      (Offset,KSR);
      SetFreqMult (Offset,FreqMult);
      SetKSL      (Offset,KSL);
      SetOutput   (Offset,Output);
      SetAttack   (Offset,Attack);
      SetDecay    (Offset,Decay);
      SetSustLevel(Offset,SustLevel);
      SetRelease  (Offset,Release);
      SetWaveSel  (Offset,WaveSel)
    end
end; {SetOpCellParameters}

procedure AssignVoice(Voice : byte; Ins : InsData);

begin {AssignVoice}
  if Voice<=0 then
     begin
       FMError := 3;
      Exit
    end;
  if (CurrentFMMode=Melodic) then
    begin
      if Voice>9 then
        begin
          FMError := 3;
          Exit
        end;
      SetOpCellParameters(M_OpCell[Voice][0],Ins.OP0,Ins.Wave0);
      with Ins.OP0 do
        begin
          SetFeedBack(Voice-1,FeedBack);
          SetFM(Voice-1,FM);
        end;
      SetOpCellParameters(M_OpCell[Voice][1],Ins.OP1,Ins.Wave1);
    end
  else    {Rhythmic}
    begin
      if Voice>11 then
        begin
          FMError := 3;
          Exit
        end;
      SetOpCellParameters(R_OpCell[Voice][0],Ins.OP0,Ins.Wave0);
      with Ins.OP0 do
        begin
          SetFeedBack(Voice-1,FeedBack);
          if Voice<=9 then
            SetFM(Voice-1,FM);
        end;
      if Voice<=7 then
        SetOpCellParameters(R_OpCell[Voice][1],Ins.OP1,Ins.Wave1);
    end
end; {AssignVoice}

procedure KeyOn(Voice, Note : byte); assembler;

{Note is the MIDI value for the note to play: note in [0..$5F]}

asm {KeyOn}
  xor   bx,bx
  mov   bl,Note
  cmp   bl,5Fh
  jbe   @NoteGood
  mov   FMError,2                    {Invalid note}
  jmp   @Done

@NoteGood:
  push  bx
  mov   bl,byte ptr Semitone[bx]        {bl = Semitone}
  shl   bx,1
  mov   bx,word ptr FNumbers[bx]        

  xchg  ax,bx                           {ax = FNumber}

  pop   bx
  mov   bl,byte ptr Octave[bx]          {bl = Octave}

  and   bl,07h;
  shl   bl,1
  shl   bl,1

  or    ah,bl                           {ax = Octave|F-Number}

  mov   dl,Voice
  cmp   dl,11
  ja    @BadVoice
  cmp   dl,0
  jle   @BadVoice

  cmp   dl,6                            {Exclude Bass Drum}
  jle   @Melodic
  cmp   CurrentFMMode,1                 {is Rhythmic?}
  jne   @Melodic                        {no, jump}

{@Rhythmic:}

  cmp   MelRhythm,1                     {is Rhythmic section melodic-enabled?}
  jne   @GoOn                           {no: skip frequency control}

  cmp   dl,7                            {is less than a Bass drum?}
  jl    @GoOn
  cmp   dl,11                           {is more than Tom-Tom?}
  jg    @GoOn

  xchg  ax,bx
  mov   al,dl
  dec   al                              {al=offset}
  add   al,0A0h                         {register}
  mov   ah,bl                           {data : Lo(F-Number)}
  call  OutCmd
  add   al,010h                         {register}
  mov   ah,bh                           {data : KeyOn|Block|Hi(F-Number)}
  call  OutCmd

@GoOn:
  mov   cx,11
  sub   cl,Voice

  mov   al,01h
  rol   al,cl
  mov   ah,byte ptr FMRegisters[0BDh]
  or    ah,al
  mov   al,0BDh
  call  OutCmd

  jmp   @Done
@Melodic:

  cmp   dl,9
  jg    @BadVoice

  or    ah,20h                          {add KeyOn}

  xchg  ax,bx
  mov   al,dl
  dec   al                              {al=offset}
  add   al,0A0h                         {register}
  mov   ah,bl                           {data : Lo(F-Number)}
  call  OutCmd
  add   al,010h                         {register}
  mov   ah,bh                           {data : KeyOn|Block|Hi(F-Number)}
  call  OutCmd
  jmp   @Done

@BadVoice:
  mov    FMError,3
@Done:
end; {KeyOn}

procedure KeyOff(Voice : byte); assembler;

asm {KeyOff}
  push  cx
  mov   al,Voice
  cmp   al,6
  jle   @Melodic
  test  CurrentFMMode,1
  jz    @Melodic
  mov   cx,11
  sub   cl,al
  js    @Error
  mov   al,0FEh
  rol   al,cl
  mov   ah,byte ptr FMRegisters[0BDh]
  and   ah,al
  mov   al,0BDh
  call  OutCmd
  jmp   @Done
@Melodic:
  cmp   al,9
  jg    @Error
  dec   al
  cmp   al,0
  jl    @Error
  add   al,0B0h
  xor   bx,bx
  mov   bl,al
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11011111b
  call  OutCmd
  jmp   @Done
@Error:
  mov   FMError,3
@Done:
  pop   cx
end; {KeyOff}

procedure QuitVoice(Voice : byte);

begin {QuitVoice}
  SetRelease(R_OpCell[Voice][0],15);
  SetRelease(R_OpCell[Voice][1],15);
  KeyOff(Voice);
end; {QuitVoice}

procedure QuitVoices; assembler;

asm {QuitVoices}

  mov   cx,3
  mov   ax,40h

@NextN:

  push  cx
  mov   cx,3

@NextM:
  push  cx
  mov   ah,7Fh
  call  OutCmd
  add   al,40h
  mov   ah,5Fh
  call  OutCmd
  sub   al,40h
  add   al,3
  mov   ah,3Fh
  call  OutCmd
  add   al,40h
  mov   ah,7Fh
  call  OutCmd
  sub   ax,40h
  sub   ax,2
  pop   cx
  loop  @NextM

  add   ax,5
  pop   cx
  loop  @NextN

  mov   cx,9
@NextA:
  mov   bx,cx
  dec   bx
  add   bx,0B0h
  mov   ah,byte ptr FMRegisters[bx]
  and   ah,11011111b
  mov   al,bl
  call  OutCmd
  loop  @NextA
  mov   ah,byte ptr FMRegisters[0BDh]
  and   ah,11100000b
  mov   al,0BDh
  call  OutCmd
end; {QuitVoices}

procedure SetWaveForm(State : boolean); assembler;

var
  i : byte;

asm {SetWaveForm}
  mov   ah,State
  and   ah,1
  mov   WaveFormEnabled,ah
  ror   ah,1
  ror   ah,1
  ror   ah,1
  mov   al,1
  call  OutCmd
end; {SetWaveForm}

procedure AllKeyOff;

var
  i : byte;

begin {AllKeyOff}
  if CurrentFMMode=Melodic then
    for i:=1 to 9 do
      KeyOff(i)
  else
    for i:=1 to 11 do
      KeyOff(i)
end; {AllKeyOff}

procedure SetCSMMode(State : boolean); assembler;

asm {SetCSMMode}
  call  AllKeyOff
  mov   ah,State
  and   ah,00000001b
  mov   CSMModeEnabled,ah
  ror   ah,1
  mov   al,byte ptr FMRegisters[8]
  and   al,01111111b
  or    ah,al
  mov   al,8
  call  OutCmd
end; {SetCSMMode}

procedure SetKBDSplit(State : boolean); assembler;

asm {SetKBDSplit}
  mov   ah,State
  and   ah,00000001b
  mov   KBDSplitEnabled,ah
  ror   ah,1
  ror   ah,1
  mov   al,byte ptr FMRegisters[8]
  and   al,10111111b
  or    ah,al
  mov   al,8
  call  OutCmd
end; {SetKBDSplit}

procedure SetAMDepth(State : boolean); assembler;

asm {SetAMDepth}
  mov   ah,State
  and   ah,00000001b
  mov   AMDepthEnabled,ah
  ror   ah,1
  mov   al,byte ptr FMRegisters[0BDh]
  and   al,01111111b
  or    ah,al
  mov   al,0BDh
  call  OutCmd
end; {SetAMDepth}

procedure SetVIBDepth(State : boolean); assembler;

asm {SetVIBDepth}
  mov   ah,State
  and   ah,00000001b
  mov   VIBDepthEnabled,ah
  ror   ah,1
  ror   ah,1
  mov   al,byte ptr FMRegisters[0BDh]
  and   al,10111111b
  or    ah,al
  mov   al,0BDh
  call  OutCmd
end; {SetVIBDepth}

procedure SetFMMode(FMMode : byte); assembler;

asm {SetFMMode}
  call  QuitVoices
  mov   al,FMMode
  and   al,00000001b
  mov   CurrentFMMode,al
  shl   al,1
  shl   al,1
  shl   al,1
  shl   al,1
  shl   al,1                            {Shift bit to D5}
  mov   ah,byte ptr FMRegisters[0BDh]
  and   ah,11000000b
  or    ah,al
  mov   al,0BDh
  call  OutCmd
end; {SetFMMode}

procedure SetMelRhythm(State : boolean);

begin {SetMelRhythm}
  MelRhythm := State
end; {SetMelRhythm}

{* compatibility with CMF modes *}

procedure SetSC(Ofs, Data : byte); assembler;

asm {SetSC}
  mov   ah,Data
  mov   al,Ofs
  add   al,020h
  call  OutCmd
end; {SetSC}

procedure SetSO(Ofs, Data : byte); assembler;

asm {SetSO}
  mov   ah,Data
  mov   al,Ofs
  add   al,040h
  call  OutCmd
end; {SetSO}

procedure SetAD(Ofs, Data : byte); assembler;

asm {SetAD}
  mov   ah,Data
  mov   al,Ofs
  add   al,060h
  call  OutCmd
end; {SetAD}

procedure SetSR(Ofs, Data : byte); assembler;

asm {SetSR}
  mov   ah,Data
  mov   al,Ofs
  add   al,080h
  call  OutCmd
end; {SetSR}

procedure SetWS(Ofs, Data : byte); assembler;

asm {SetWS}
  mov   ah,Data
  mov   al,Ofs
  add   al,0E0h
  call  OutCmd
end; {SetWS}

procedure SetFC(Ofs, Data : byte); assembler;

asm {SetFC}
  mov   ah,Data
  mov   al,Ofs
  add   al,0C0h
  call  OutCmd
end; {SetFC}

function ModOfs(channel : byte) : byte;

begin {ModOfs}
  case CurrentFMMode of
    Melodic :
      ModOfs := M_OpCell[channel+1,0];
    Rhythmic:
      if channel<6 then
        ModOfs := R_OpCell[channel+1,0]
      else
        ModOfs := R_OpCell[channel-5,0]
  end
end; {ModOfs}

function CarOfs(channel : byte) : byte;

begin {CarOfs}
  case CurrentFMMode of
    Melodic :
      CarOfs := M_OpCell[channel+1,1];
    Rhythmic:
      if channel<6 then
        CarOfs := R_OpCell[channel+1,1]
    else
        CarOfs := R_OpCell[channel-5,1]
  end
end; {CarOfs}

{* end of compatibility with CMF modes *}

procedure ResetTimers; assembler;

asm {ResetTimers}
  mov   ah,60h
  mov   al,04h
  call  OutCmd                          {Mask T1 & T2}

  mov   ah,80h
  mov   al,04h
  call  OutCmd                          {Reset IRQ}
end; {ResetTimers}

procedure ResetRegisters; assembler;

asm {ResetRegisters}
  mov   cx,0F5h

@NextReg:
  mov   ax,cx
  call  OutCmd
  loop  @NextReg
end; {ResetRegisters}

procedure ResetVariables;

begin {ResetVariables}
  SetWaveForm(ON);
  SetCSMMode(OFF);
  SetKBDSplit(ON);
  SetAMDepth(OFF);
  SetVIBDepth(OFF)
end; {ResetVariables}

procedure ResetPitch; assembler;

asm {ResetPitch}
  mov   al,CurrentFMMode
  cmp   al,0
  jne   @Rhythm

  mov   cx,9
  mov   bx,57A0h
  mov   dx,01B0h

@NextVoice:
  mov   ax,bx
  call  OutCmd
  inc   bx
  mov   ax,dx
  call  OutCmd
  inc   dx

  loop  @NextVoice
  jmp   @RPExit

@Rhythm:

  mov   ax,57A0h                        {Voice 1}
  call  OutCmd
  mov   ax,11B0h
  call  OutCmd
  mov   ax,57A1h                        {Voice 2}
  call  OutCmd
  mov   ax,01B1h
  call  OutCmd
  mov   ax,57A2h                        {Voice 3}
  call  OutCmd
  mov   ax,01B2h
  call  OutCmd
  mov   ax,57A3h                        {Voice 4}
  call  OutCmd
  mov   ax,01B3h
  call  OutCmd
  mov   ax,57A4h                        {Voice 5}
  call  OutCmd
  mov   ax,01B4h
  call  OutCmd
  mov   ax,57A5h                        {Voice 6}
  call  OutCmd
  mov   ax,01B5h
  call  OutCmd

  mov   ax,57A6h                        {Bass drum}
  call  OutCmd
  mov   ax,09B6h                        {Warning!!! was : 01B6}
  call  OutCmd

  mov   ax,03A7h                        {Snare drum & Hi-Hat}
  call  OutCmd
  mov   ax,0AB7h
  call  OutCmd

  mov   ax,57A8h                        {Tom & Cymbal}
  call  OutCmd
  mov   ax,09B8h
  call  OutCmd

@RPExit:
end; {ResetPitch}

procedure ResetVoice(Voice:byte);

begin {ResetVoice}
  if (CurrentFMMode=Melodic) or (Voice<=6) then
    AssignVoice(Voice,InsData(Piano1))
  else
    case Voice of
      7 : AssignVoice(7,InsData(BDrum1));
      8 : AssignVoice(8,InsData(Snare1));
      9 : AssignVoice(9,InsData(Tom1));
      10: AssignVoice(10,InsData(Cymbal1));
      11: AssignVoice(11,InsData(HiHat1))
    end;
end; {ResetVoice}

procedure ResetSynth;

begin {ResetSynth}
  ResetVariables;
  AssignVoice(1,InsData(Piano1));
  AssignVoice(2,InsData(Piano1));
  AssignVoice(3,InsData(Piano1));
  AssignVoice(4,InsData(Piano1));
  AssignVoice(5,InsData(Piano1));
  AssignVoice(6,InsData(Piano1));
  if CurrentFMMode=Melodic then
    begin
      AssignVoice(7,InsData(Piano1));
      AssignVoice(8,InsData(Piano1));
      AssignVoice(9,InsData(Piano1));
    end
  else
    begin
      AssignVoice(7,InsData(BDrum1));
      AssignVoice(8,InsData(Snare1));
      AssignVoice(9,InsData(Tom1));
      AssignVoice(10,InsData(Cymbal1));
      AssignVoice(11,InsData(HiHat1))
    end;
  ResetPitch
end; {ResetSynth}

function FMStatus(voice : byte) : InsDataPtr;

begin {FMStatus}
  with TmpInsData do
    begin
      Mode := 0;
      PercVoice := 0;
      if (Voice in [7..11]) and (CurrentFMMode=Rhythmic) then
        begin
          Mode := 1;
          PercVoice := Voice-1
        end;
      with Op0 do
        begin
          FreqMult :=   (FMRegisters[$20+R_OpCell[Voice][0]] and $0F);
          KSR :=        (FMRegisters[$20+R_OpCell[Voice][0]] and $10) shr 4;
          EG :=         (FMRegisters[$20+R_OpCell[Voice][0]] and $20) shr 5;
          Vib :=        (FMRegisters[$20+R_OpCell[Voice][0]] and $40) shr 6;
          AM :=         (FMRegisters[$20+R_OpCell[Voice][0]] and $80) shr 7;
          Output :=     (FMRegisters[$40+R_OpCell[Voice][0]] and $3F);
          KSL :=        (FMRegisters[$40+R_OpCell[Voice][0]]) shr 6;
          Decay :=      (FMRegisters[$60+R_OpCell[Voice][0]] and $0F);
          Attack :=     (FMRegisters[$60+R_OpCell[Voice][0]]) shr 4;
          Release :=    (FMRegisters[$80+R_OpCell[Voice][0]] and $0F);
          SustLevel :=  (FMRegisters[$80+R_OpCell[Voice][0]]) shr 4;
          if (Mode=0) or (Voice<=7) then
            begin
              FM :=       (FMRegisters[$C0+Voice-1] and $01);
              FeedBack :=   (FMRegisters[$C0+Voice-1] and $0E) shr 1;
            end
          else
            begin
              FM := 0;
              Feedback := 0;
            end;
        end;
      Wave0 := (FMRegisters[$E0+R_OpCell[Voice][0]] and $03);
      if (Voice in [8..11]) and (CurrentFMMode=Rhythmic) then
        with Op1 do
          begin
            Attack    := 15;
            SustLevel := 15;
            Decay     := 15;
            Release   := 15;
            KSL       := 0;
            FreqMult  := 0;
            FeedBack  := 0;
            EG        := 0;
            Output    := 63;
            AM        := 0;
            Vib       := 0;
            KSR       := 0;
            FM        := 0;
            Wave1     := 0
          end
      else
        with Op1 do
           begin
            FreqMult  := (FMRegisters[$20+M_OpCell[Voice][1]] and $0F);
            KSR       := (FMRegisters[$20+M_OpCell[Voice][1]] and $10) shr 4;
            EG        := (FMRegisters[$20+M_OpCell[Voice][1]] and $20) shr 5;
            Vib       := (FMRegisters[$20+M_OpCell[Voice][1]] and $40) shr 6;
            AM        := (FMRegisters[$20+M_OpCell[Voice][1]] and $80) shr 7;
            Output    := (FMRegisters[$40+M_OpCell[Voice][1]] and $3F);
            KSL       := (FMRegisters[$40+M_OpCell[Voice][1]]) shr 6;
            Decay     := (FMRegisters[$60+M_OpCell[Voice][1]] and $0F);
            Attack    := (FMRegisters[$60+M_OpCell[Voice][1]]) shr 4;
            Release   := (FMRegisters[$80+M_OpCell[Voice][1]] and $0F);
            SustLevel := (FMRegisters[$80+M_OpCell[Voice][1]]) shr 4;
            FM        := 0;
            Feedback  := 0;
            Wave1     := (FMRegisters[$E0+M_OpCell[Voice][1]] and $03)
          end
    end;
  FMStatus := @TmpInsData
end; {FMStatus}

procedure FMInit(Base : word);

begin {FMInit}
  BaseReg := Base;
  Install := true;
  AdLibInstalled := IsAdLib;
  Install := false;
  if not(AdLibInstalled) then
    FMError := 1
  else
    begin
      FMError := 0;
      ResetRegisters;
      ResetTimers;
      SetFMMode(Rhythmic);
      SetMelRhythm(OFF);
      ResetSynth
    end
end; {FMInit}

function IsAdLib : boolean; assembler;

asm {IsAdLib}
  call  ResetTimers

  mov   dx,BaseReg
  in    al,dx                           {Read T1}

  push  ax                              {Save T1}

  mov   ah,0FFh
  mov   al,02h
  call  OutCmd                          {Set Timer 1 latch}

  mov   ah,21h
  mov   al,04h
  call  OutCmd                          {Unmask & start T1}

  mov   dx,BaseReg
  mov   cx,200
@Again:
  in    al,dx
  loop  @Again                          {100 uSec delay for timer-1 overflow}
                                        {al = T2}

  push  ax
  call  ResetTimers

  pop   bx                              {T2 in bl}
  pop   ax                              {T1 in al}

  and   bl,0E0h
  cmp   bl,0C0h
  jnz   @AdLibNotFound

  and   al,0E0h
  cmp   al,0
  jnz   @AdLibNotFound

  mov   ax,1                            {return true}
  jmp   @IsAdLibExit

@AdLibNotFound:
  xor   ax,ax                           {return false}

@IsAdLibExit:
end; {IsAdLib}

function FindBasePort : boolean;

const
  BasePort : array[1..9] of word = ($388,$318,$218,$228,$238,$248,$258,$268,$288);

var
  i : byte;

begin {FindBasePort}
  i := 1;
  repeat
    FMInit(BasePort[i]);
    inc(i)
  until (FMError=0) or (i>9);
  FindBasePort := FMError=0;
end; {FindBasePort}

function FindSBPBasePort : word;

const
  BasePort : array[1..2] of word = ($248,$228);

var
  i : byte;
  J,K : byte;

begin {FindSBPBasePort}
  i := 1;
  repeat
    FMInit(BasePort[i]);
    if FMError=0 then
      begin
        Port[BaseReg-4] := $06;
        J := Port[BaseReg-3];

        Port[BaseReg-4] := $06;
        Port[BaseReg-3] := $26;

        Port[BaseReg-4] := $06;
        K := Port[BaseReg-3];

        if K<>$37 then
          FMError := 8
        else
          Port[BaseReg-3] := J;
      end;
    inc(i)
  until (FMError=0) or (i>2);
  if FMError=0 then
    FindSBPBasePort := BaseReg
  else
    FindSBPBasePort := 0
end; {FindSBPBasePort}

begin {FM}
  FMError := 0;
  BaseReg := $0388;
  CurrentFMMode := Undefined
end. {FM}
