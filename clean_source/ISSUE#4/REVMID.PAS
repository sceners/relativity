unit revmid1;
interface
uses  crt,dos,MIDAS,mParser,Errors,mGlobals,mMem,SDevice,MPlayer,DMA,DSM,S3M,
      MODp,MTM,mFile,mConfig,revconst;

procedure toASCIIZ(dest : PChar; str : string);
function PlayModule(fileName : Pchar) : PmpModule;
procedure StartBackgroundMusic(filename : string);
procedure FreeModule(module : PmpModule);
procedure StopBackgroundMusic;

implementation
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - This Little Bitch Took Me 3 Hours To Get Working!!!!!!! *)
(****************************************************************************)

procedure toASCIIZ(dest : PChar; str : string);
var
    spos, slen : integer;
    i : integer;

begin
    spos := 0;                          { string position = 0 }
    slen := ord(str[0]);                { string length }

    { copy string to ASCIIZ conversion buffer: }
    while spos < slen do
    begin
        dest[spos] := str[spos+1];
        spos := spos + 1;
    end;

    dest[spos] := chr(0);               { put terminating 0 to end of string }
end;

function PlayModule(fileName : Pchar) : PmpModule;
var
    header : pointer;
    f : fileHandle;
    module : PmpModule;
    error, mpNum, recognized : integer;
begin
    { allocate memory for module header: }
    error := memAlloc(MPHDRSIZE, @header);
    if error <> OK then
        midasError(error);

    { open module file: }
    error := fileOpen(fileName, fileOpenRead, @f);
    if error <> OK then
        midasError(error);

    { read MPHDRSIZE bytes of module header: }
    error := fileRead(f, header, MPHDRSIZE);
    if error <> OK then
        midasError(error);

    error := fileClose(f);
    if error <> OK then
        midasError(error);

    { Search through all Module Players to find one that recognizes the
      file header: }
    mpNum := 0;
    {MP := NIL;}
{    while (mpNum < NUMMPLAYERS) and (MP = NIL) do}
    begin
{        error := modulePlayers[mpNum]^.Identify(header, @recognized);}
        if error <> OK then
            midasError(error);
        if recognized = 1 then
{            MP := modulePlayers[mpNum];}
        mpNum := mpNum + 1;
    end;

    { deallocate module header: }
    error := memFree(header);
    if error <> OK then
        midasError(error);

{    if MP = NIL then}
    begin
        midasClose;
        errErrorExit('Error: Unknown module format')
    end;

    { load the module file using correct Module Player: }
{$IFDEF REALVUMETERS}
    module := midasLoadModule(fileName, MP, @vuPrepare);
{$ELSE}
{    module := midasLoadModule(fileName, MP, NIL);}
{$ENDIF

    { play the module: }
    midasPlayModule(module, 0);

    PlayModule := module;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Initializes MIDAS And Plays Modules. IMPORTANT BELOW!!! *)
(****************************************************************************)

procedure StartBackgroundMusic(filename : string);
begin
  midasSetDefaults;                       { set MIDAS defaults }
  midasLoadConfig('REVSND.CFG');           { load MIDAS configuration }
  midasParseEnvironment;                  { parse "MIDAS" environment }
  ClrScr;
  GotoXY(1, 25);
  begin
    midasParseOption('b');
  end;
  midasInit;                              { initialize MIDAS }
{  SD := midasSD;}
  toASCIIZ(str1, filename);
{  module := PlayModule(str1);              { load and play module }
  {MP := midasMP;}
  StopPlay := false;
  while not StopPlay do
    begin
{      PhazePre;           ????????? what the hell is this ???????}
{      StartMainMenuPhase;}
    end;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Uninstalls The Module Loaded Into EMS Memory. (Handles) *)
(****************************************************************************)

procedure FreeModule(module : PmpModule);
var
    i, error : integer;
    insthdl : word;
begin
{$IFDEF REALVUMETERS}
    { Deallocate VU-meter information for all instruments: }
    for i := 0 to (module^.numInsts-1) do
    begin
        insthdl := module^.insts^[i].sdInstHandle;
        if insthdl <> 0 then
        begin
            error := vuRemove(insthdl);
            if error <> OK then
                midasError(error);
        end
    end;
{$ENDIF}
    midasFreeModule(module);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
(****************************************************************************)
(* Reserved Words - Stops The Background Music And Proceeds To FreeModule.  *)
(****************************************************************************)

procedure StopBackgroundMusic;
begin
{  midasStopModule(module);            { stop playing module }
{  FreeModule(module);                 { deallocate module }
  if error <> OK then
    midasError(error);
  midasClose;                         { uninitialize MIDAS Sound System }
{$IFDEF DEBUG}
   errPrintList;
{$ENDIF}
end;



end.