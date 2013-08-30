Program Set_KeyBoard_Speed;
 uses Crt;

   var
     speed :byte;

Begin
  Clrscr;
  write('Enter the KeyBoard Speed  ');
  write('Slow 30 ---> 1 Fast  :');
  read(speed);
   Port[$60]:=$F3;
   Delay(0);
   Port[$60]:=speed;

End.