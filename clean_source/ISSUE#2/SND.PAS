{$F+}

unit snd;

interface

var
   sound_on  : boolean;
   snd_delay : longint;
   use_sb    : boolean;

procedure DetectFM;
procedure MakeNote(nota,attack,del : integer);
procedure Start_level;
procedure ball_block_sound(freq,duration : integer);
procedure Death_sound(w : integer);

implementation
uses crt,mouse,FM;

type
  InsArray = array[0..29] of byte;

const
  Piano1 : InsArray = ( 0,00,  1, 1, 3,15, 5, 0, 1, 3,15, 0, 0, 0, 0,  0, 1, 0,13, 7, 0, 2, 4,16, 0, 0, 1, 0,  0,0);
  BDrum1 : InsArray = ( 1,06,  0, 0, 0,10, 4, 0, 8,12,11, 0, 0, 0, 0,  0, 0,47,13, 4, 0, 6,15,16, 0, 0, 0, 1,  0,0);
  Snare1 : InsArray = ( 1,07,  0,12, 0,15,11, 0, 8, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);
  Tom1   : InsArray = ( 1,08,  0, 4, 0,15,11, 0, 7, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);
  Cymbal1: InsArray = ( 1,09,  0, 1, 0,15,11, 0, 5, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);
  HiHat1 : InsArray = ( 1,10,  0, 1, 0,15,11, 0, 7, 5,16, 0, 0, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,0);


procedure MakeNote(nota,attack,del : integer);
   begin
   if sound_on then sound(nota);
   mydelay(attack);
   nosound;
   mydelay(del);
   end;

procedure ball_block_sound(freq,duration : integer);
   begin
   if not use_sb then
      begin
      nosound;
      if sound_on then sound(freq);
      end
   else
      if sound_on then
         begin
         KeyOff(1);
         if(freq<700) then KeyOn(1,freq shr 3)
         else if freq=700 then KeyOn(1,70)
         else if freq=2000 then KeyOn(1,80);
         end;

   snd_delay:=duration;
   end;

procedure SB_note(voice,note,del : integer);
   begin
   KeyOn(voice,note);
   KeyOn(voice+1,note+4);
   KeyOn(voice+2,note+7);

   mydelay(del);

   KeyOff(voice);
   KeyOff(voice+1);
   KeyOff(voice+2);
   end;

procedure start_level;
const ottava = 3;

   begin
   if not use_sb then
      begin
      MakeNote(396,40,2);  { Sol }
      MakeNote(468,56,2);  { La# }
      MakeNote(440, 8,2);  { La  }
      MakeNote(396, 8,2);  { Sol }
      MakeNote(352, 8,2);  { Fa  }
      MakeNote(440, 8,2);  { La  }
      MakeNote(396,40,2);  { Sol }
      end
   else if sound_on then
      begin
      AllKeyOff;

      AssignVoice(1,InsData(Cymbal1));
      AssignVoice(2,InsData(Piano1));
      AssignVoice(3,InsData(Snare1));

      SB_note(1,6+ottava*12,40);
      SB_note(1,9+ottava*12,56);
      SB_note(1,8+ottava*12,12);
      SB_note(1,6+ottava*12,12);
      SB_note(1,4+ottava*12,12);
      SB_note(1,8+ottava*12,12);
      SB_note(1,6+ottava*12,40);

      AssignVoice(1,InsData(Tom1));
      end;
   end;

procedure DetectFM;

var
  SBP : word;

begin {DetectFm}
  use_sb:=TRUE;
  SBP := FindSBPBasePort;
  if not FindBasePort then use_sb:=FALSE;
end; {DetectFM}


procedure Death_sound(w : integer);
   begin
   if not use_sb then MakeNote(400-w*50,8,2)
   else if sound_on then SB_note(1,13-w,8);
   end;

end.