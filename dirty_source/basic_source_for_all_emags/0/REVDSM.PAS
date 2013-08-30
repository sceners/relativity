unit revdsm;
interface

procedure loaddsm(name:string);
Procedure deloaddsm;
procedure killdsm;

implementation
uses Sound,Load,TS,revconst,revdat;

procedure loaddsm(name:string);
begin

{  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    halt;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    halt;
  end;   }
{  if Module = nil then begin
    case DSMStatus of
      ERR_NORAM:  writeln('Not enough system memory.');
      ERR_NODRAM: writeln('Not enough card memory.');
      ERR_NOFILE: writeln('File not found.');
      ERR_FORMAT: writeln('Invalid file format.');
      ERR_ACCESS: writeln('File damaged.');
    end;
    DSMDone;
    exit;
  end;}

  extractfilefromdat(name,dsm_file);
  Module := DSMLoad(name,0);
  deletedatfile(name);
  DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
  DSMPlayMusic(Module);

{$ifdef UseTS}
  TSInit;
  TSSetRate(70);
  TSSetRoutine(DSMPoll);
{$endif}

{$ifndef UseTS}
    DSMPoll;
{$endif}
    DSMSetMusicVolume(Volume);

{$ifndef UseTS}
    DSMPoll;
{$endif}

end;

Procedure deloaddsm;
begin
  DSMStopMusic;
  DSMFree(Module);
end;

procedure killdsm;
begin
{$ifdef UseTS}
  TSDone;
  TSRestoreTime;
{$endif}
  DSMDone;
end;

end.