(****************************************************************************)
(*                                                                          *)
(* REVGFX.PAS - The Relativity Emag (coded in Turbo Pascal 7.0)             *)
(*                                                                          *)
(* "The Relativity Emag" was originally written by En|{rypt, |MuadDib|,     *)
(* and IllumiTIE (for assembly routines). This source may not be copied,    *)
(* distributed or modified in any shape or form. Some of the code has been  *)
(* derived from various sources and units to help us produce a better       *)
(* quality electronic magazine to let the scene know we're boss.            *)
(*                                                                          *)
(* Program Notes : This program presents "The Relativity Emag"              *)
(*                                                                          *)
(* ASM/TP70 Coder : xxxxx xxxxxxxxx (En|{rypt)  - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* TP70 Coder     : xxxxx xxxxxxxxx (|MuadDib|) - xxxxxx@xxxxxxxxxx.xxx     *)
(* ------------------------------------------------------------------------ *)
(* Midas Cfg UNIT USED WITH REV97.PAS AND ABOVE. CODED IN TURBO PASCAL 7.0  *)
(****************************************************************************)
unit revset;
interface

Const ConfigFile='REVSND.CFG';
procedure SetMidasCfg;

implementation

{uses midas, mconfig, vgatext;}

{var
    configured : integer;}
procedure SetMidasCfg;
BEGIN
{    midasSetDefaults;                   { set MIDAS defaults }

    { Run MIDAS Sound System configuration: }
 {   configured := midasConfig;

    { Reset display mode: }
  {  vgaSetMode($03);

    if configured = 1 then
    begin
        { Configuration succesful - save configuration file: }
   {     midasSaveConfig(ConfigFile);
        WriteLn('Configuration written to ',ConfigFile);
    end
    else
    begin
        { Configuration unsuccessful: }
    {    WriteLn('Configuration NOT saved');
    end;}
end;
END.
