{$define UseTS}
{$m 64000,0,640000}
program Example;
uses Crt,Sound,Load,TS;

var
  Card   : DSMCard;
  Module : PDSM;
  Volume : Integer;
begin
  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    exit;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    exit;
  end;
  Module := DSMLoad('64MANIA.DSM',0);
  if Module = nil then begin
    case DSMStatus of
      ERR_NORAM:  writeln('Not enough system memory.');
      ERR_NODRAM: writeln('Not enough card memory.');
      ERR_NOFILE: writeln('File not found.');
      ERR_FORMAT: writeln('Invalid file format.');
      ERR_ACCESS: writeln('File damaged.');
    end;
    DSMDone;
    exit;
  end;
  writeln('Playing music.');
  DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
  DSMPlayMusic(Module);

{$ifdef UseTS}
  TSInit;
  TSSetRate(70);
  TSSetRoutine(DSMPoll);
{$endif}

  for Volume := 0 to 255 do begin
{$ifndef UseTS}
    DSMPoll;
{$endif}
    DSMSetMusicVolume(Volume);
    Delay(20);
  end;

  while not keypressed do begin
{$ifndef UseTS}
    DSMPoll;
{$endif}
  end;

  for Volume := 255 downto 0 do begin
{$ifndef UseTS}
    DSMPoll;
{$endif}
    DSMSetMusicVolume(Volume);
    Delay(20);
  end;

  DSMStopMusic;
  DSMFree(Module);
{$ifdef UseTS}
  TSDone;
  TSRestoreTime;
{$endif}
  DSMDone;
end.
