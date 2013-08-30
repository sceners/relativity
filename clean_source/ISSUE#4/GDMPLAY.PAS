 {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
 {                     Bells, Whistles, and Sound Boards                    }
 {       Copyright (c) 1993-95, Edward Schlunder. All Rights Reserved.      }
 {ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}
 { GDMPLAY.PAS - Example GDM module player                                  }
 {               Written by Alex Chalfin (1994-95)                          }
 {                                                                          }
 {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
unit gdmplay;
interface
Procedure MainPlay;
implementation

Uses Crt, DOS, MSE_TP;

Var
  SoundCardName : String;
  DMA, IRQ : Byte;
  BaseIO : Word;
  SampleRate : Word;
  DMABuffer : Word;
  Handle : File;
  Header : GDMHeader;
  EMSFlag : Word;
  MusicChannels : Word;
  ChannelCount : Word;
  ExitProgram : Boolean;

Procedure EndProg(ErrorString : String);
{ Prints the error string and Halts the program }

Begin
  Writeln;
  Writeln(ErrorString);
  If IOResult <> 0 then Close(Handle);
  Halt(0);
End;

Function GetSoundCardName : String;

Begin
  Writeln;
  Writeln(' Select Sound Card: ');
  Writeln('   1. Gravis Ultrasound');
  Writeln('   2. Sound Blaster 1.0');
  Writeln('   3. Sound Blaster 2.0');
  Writeln('   4. Sound Blaster Pro');
  Writeln('   5. Sound Blaster 16');
  Writeln('   6. Pro Audio Spectrum');
  Case ReadKey of
    '1' : GetSoundCardName := 'GUS.MSE';
    '2' : GetSoundCardName := 'SB1X.MSE';
    '3' : GetSoundCardName := 'SB2X.MSE';
    '4' : GetSoundCardName := 'SBPRO.MSE';
    '5' : GetSoundCardName := 'SB16.MSE';
    '6' : GetSoundCardName := 'PAS.MSE';
  End;
End;

Function GetIRQNumber : Byte;

Begin
  Writeln;
  Writeln(' Select IRQ: ');
  Writeln('   1. IRQ 2');
  Writeln('   2. IRQ 3');
  Writeln('   3. IRQ 5');
  Writeln('   4. IRQ 7');
  Writeln('   5. IRQ 11');
  Writeln('   6. IRQ 12');
  Writeln('   Any other key for auto-detect.');
  Case ReadKey of
    '1' : GetIRQNumber := 2;
    '2' : GetIRQNumber := 3;
    '3' : GetIRQNumber := 5;
    '4' : GetIRQNumber := 7;
    '5' : GetIRQNumber := 11;
    '6' : GetIRQNumber := 12;
    Else GetIRQNumber := $FF;
  End;
End;

Function GetDMAChannel : Byte;

Begin
  Writeln;
  Writeln(' Select DMA Channel: ');
  Writeln('   1. DMA Channel 1');
  Writeln('   2. DMA Channel 2');
  Writeln('   3. DMA Channel 3');
  Writeln('   4. DMA Channel 5');
  Writeln('   Any other key for auto-detect.');
  Case ReadKey of
    '1' : GetDMAChannel := 1;
    '2' : GetDMAChannel := 2;
    '3' : GetDMAChannel := 3;
    '4' : GetDMAChannel := 5;
    Else GetDMAChannel := $FF;
  End;
End;

Function GetBaseIO : Word;

Begin
  Writeln;
  Writeln(' Select Base I/O Address: ');
  Writeln('   1. 210h');
  Writeln('   2. 220h');
  Writeln('   3. 230h');
  Writeln('   4. 240h');
  Writeln('   5. 250h');
  Writeln('   6. 260h');
  Writeln('   Any other key for auto-detect.');
  Case ReadKey of
    '1' : GetBaseIO := $210;
    '2' : GetBaseIO := $220;
    '3' : GetBaseIO := $230;
    '4' : GetBaseIO := $240;
    '5' : GetBaseIO := $250;
    '6' : GetBaseIO := $260;
    Else GetBaseIO := $FFFF;
  End;
End;

Function GetModuleName : String;

Var
  Temp : String;

Begin
  Writeln;
  Writeln('Sound Device: ', DeviceName);
  Write('Modulename: ');
  Readln(Temp);
  Writeln;
  GetModuleName := Temp;
End;

Function ToHex(Num : Word) : String;
{ Converts a decimal number to Hexidecimal }

Const
  HexChars : String = '0123456789ABCDEF';

Var
  Temp : String;

Begin
  Temp := '';
  Temp := Temp + HexChars[((Num Shr 8) And 15) + 1];
  Temp := Temp + HexChars[((Num Shr 4) And 15) + 1];
  Temp := Temp + HexChars[((Num Shr 0) And 15) + 1];
  ToHex := Temp + 'h';
End;

Procedure MainPlay;
Begin
  SoundCardName := GetSoundCardName; { Get the Sound card to be used      }
  BaseIO := GetBaseIO;               { Get the Base port address          }
  IRQ := GetIRQNumber;               { Get IRQ number                     }
  DMA := GetDMAChannel;              { Get DMA Channel                    }
  SampleRate := 45;                  { Initially set at 45Khz             }
  DMABuffer := 4096;                 { DMA Buffer of 4096 bytes           }
  Case LoadMSE(SoundCardName, 0, SampleRate, DMABuffer, BaseIO, IRQ, DMA) of
    1 : EndProg('Base I/O address autodetection failure');
    2 : EndProg('IRQ level autodetection failure');
    3 : EndProg('DMA channel autodetection failure');
    4 : EndProg('DMA channel not supported');
    6 : EndProg('Sound device does not respond');
    7 : EndProg('Memory control blocks destroyed');
    8 : EndProg('Insufficient memory for mixing buffers');
    9 : EndProg('Insufficient memory for MSE file');
    10: EndProg('MSE has invalid identification string');
    11: EndProg('MSE disk read failure');
    12: EndProg('MVSOUND.SYS not loaded');
  End;
  ExitProc := @FreeMSE;              { Call FreeMSE on abnormal program end }
  If EMSExist                      { Check for EMS }
    Then EMSFlag := 1              { Yes, EMS exists, so use it }
    Else EMSFlag := 0;             { EMS does not exist }

{$I-}                              { Turn off I/O checking }
  Assign(Handle, GetModuleName);   { Open the file for loading }
  Reset(Handle);
{$I+}                              { Turn I/O checking back on }
  If IOResult <> 0 Then
     EndProg('Module does not exist');    { File not found, exit program }

  Case LoadGDM(Handle, 0, EMSFlag, Header) of
    1 : EndProg('Module is corrupt');
    2 : EndProg('Could not autodetect module type (N/A)');
    3 : EndProg('Bad file format ID string');
    4 : EndProg('Insufficient memory to load module');
    5 : EndProg('Can not unpack samples');
    6 : EndProg('AdLib instruments not supported');
  End;
  Close(Handle);

  MusicChannels := 0;            { Calculate the number of channels in song }
  For ChannelCount := 1 to 32 do
    Begin
      If Header.PanMap[ChannelCount] <> $FF
        Then MusicChannels := MusicChannels + 1;
    End;
  SampleRate := StartOutput(MusicChannels, 0);
  StartMusic;

end;
End.
