 {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
 {                     Bells, Whistles, and Sound Boards                    }
 {       Copyright (c) 1993-95, Edward Schlunder. All Rights Reserved.      }
 {ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}
 { GDMSCOPE.PAS - Example GDM module player & oscilliscope                  }
 {                Written by Alex Chalfin (1994-95)                         }
 {                                                                          }
 {ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

{$M 16384,0,0}
{ Define Stack, Heap minimum, and Heap Maximum. REQUIRED! }
Program GDMScope;

Uses Crt, MSE_TP;

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

Procedure SetMode(Mode : Word); Assembler;
{ Sets the specified gfx mode }

Asm
  Mov  ax,Mode
  Int  10h;
End;

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
  Writeln('   1. Gravis UltraSound');
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
  Writeln(' Select Base IO port: ');
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
  Write('Modulename: ');
  Readln(Temp);
  Writeln;
  GetModuleName := Temp;
End;

Procedure VertBar(X, Height, Color : Word); Near; Assembler;
{ Draws a vertical bar at Position X, of Height centered around Y=100 }
{ Used for drawing the waveform }

Asm
  Mov ax,$A000   { Draw directly on VGA screen }
  Mov es,ax
  Mov cx,Height
  Shr cx,1
  Jz @Exit
  Mov bx,cx
  Mov ax,100
  Sub ax,bx
  Mov bx,320
  Mul bx
  Add ax,X
  Mov di,ax
  Mov ax,Color
 @Looper:
  Mov es:[di],al
  Mov es:[di+320],al
  Add di,640
  Dec cx
  Jnz @Looper
 @Exit:
End;

Procedure DoScope;
{ Draws a view Scope on the screen. }

Var
  Last : Array[0..319] of Byte;
  X : Integer;
  Left, Right : Word;
  LeftInt, RightInt : Integer;

Begin
  FillChar(Last, Sizeof(Last), 100);
  DirectVideo := False;
  Write('      Left                   Right');
  VertBar(160, 200, 2);
  X := 0;
  Repeat
    GetMainScope(Left, Right);
    LeftInt := Abs(Integer(Left Shr 8) - 128) + 2;   { Scale Left scope }
    RightInt := Abs(Integer(Right Shr 8) - 128) + 2; { Scale Right scope }
    Last[x] := LeftInt;
    Last[x+161] := RightInt;
    VertBar(x, LeftInt, 15);           { Draw Left value }
    VertBar(x+161, RightInt, 15);      { Draw right value }
    X := X + 1;
    If X > 159 Then X := 0;
    VertBar(x, Last[x], 0);         { Clear left value }
    VertBar(x+161, Last[x+161], 0); { Clear right value }
  Until KeyPressed;
End;


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
     EndProg('Module does not exist');   { File not found, exit program }
     
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
  SetMode($13); { Initialize graphics mode 13h }
  StartMusic;
  DoScope;      { Do the oscilliscope }
  StopOutput;
  SetMode($03); { Return to text mode }
  UnloadModule;
  FreeMse;
End.