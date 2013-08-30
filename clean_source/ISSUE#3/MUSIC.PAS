Program ADVHSC_Equalizer_Demo;

{ Little Example To Show The Use Of The Equalizer in the Antares HSC Player }
{ Coded By Access/ADV - 06/94 }
{ Modification By aCceSs/aNTaReS - 11/94 }

Uses Crt,ADVHSC;

Var xx,i,j:Byte;


Begin
ClrScr;

LOADSONG(paramstr(1));
PLAYSONG;
repeat
Until KeyPressed;

FADESONG; { Fade Out The Volume }
{Delay(2000); { Wait For 2 Seconds }
STOPSONG; { Stop The Player }
CLEARMEM; { Free Memory }
End.