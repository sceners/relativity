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
(* CommandLine UNIT USED WITH REV97.PAS AND ABOVE. CODED IN TURBO PASCAL 7.0*)
(****************************************************************************)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(****************************************************************************)
(* Compiler Directives - These Directives Are Not Meant To Be Modified.     *)
(****************************************************************************)

unit revcom; {Command Line Options..}
interface

USES revdat;

Procedure RevCommand;

implementation

uses crt,dos,revset,revinit,revconst,revpoint;

const max=5000;
type buf= array[1..max] of char;

Const DiskSizeNeeded='2';
      deffile='relativi.ty3';

Procedure RevCommand;
var b:buf;
    f1:file;
    f2:text;
    k,ii,i,j,lin:longint;
    numread:word;
begin
for k:= 1 to paramcount do
begin
     if (paramstr(k)='/?') then
     begin
          writeln; {make nice back}
          writeln('Relativity CommandLine Configuration');
          writeln;
          writeln('ş /? This Help');
          writeln('ş /A Disable ADLIB Sound System ');
          writeln('ş /V No Vga ');
          writeln('ş /C No CD ');
          writeln('ş /D Default Configuration (N/A Yet)');
          writeln('ş /S ReConfigure MOD/S3M Sound System (N/A Yet) ');
          writeln('ş /F Disable SFX Sound System (N/A Yet)');
          writeln('ş /I Disable Intro (N/A Yet)');
          writeln('ş /M Disable Mouse (N/A Yet)');
          writeln('ş /R RequireMents');
          writeln('ş /T Create Emag''s Text File ');
          writeln;
          killconfigpointer;
          halt;
     end;
     if  (paramstr(k)='/R') then
     begin
          writeln; {make nice back}
          writeln('Relativity RequireMents Are');
          writeln;
          writeln('ş 486 or Above');
          writeln('ş SoundBlaster 16 or Better');
          writeln('ş 8Mb Memory or More');
          writeln('ş Vga / Super Vga');
          writeln('ş ',DiskSizeNeeded,'Megz or More');
          writeln;
          killconfigpointer;
          halt;
     end;
{     if (paramcount=1) and (paramstr(1)='/S') then
     begin
          SetMidasCfg;
          writeln;
          halt;
     end;}
     if ((paramstr(k)='/V') or (paramstr(k)='/v')) then
         vga:=false;
     if ((paramstr(k)='/C') or (paramstr(k)='/c')) then
        cd:=false;
     if ((paramstr(k)='/A') or (paramstr(k)='/a')) then
         adlib:=false;
     if ((paramstr(k)='/T') or (paramstr(k)='/t')) then
     begin
          write('Creating Emag''s Text Version .. Please Wait !!');
          assign(f2,deffile);
          rewrite(f2);
          for i:= 1 to 17 do begin
              for j:= 1 to 18 do begin
                  if config^.subfile[i][j]<>'' then
                  begin
                       ExtractFileFromDat(config^.subfile[i][j]);
{                       write(config^.subfile[i][j]);}
                       lin:=0;
                       assign(f1,config^.subfile[i][j]);
                       reset(f1,1);
                       repeat
                       BlockRead(F1,b, SizeOf(b), NumRead);
                       if numread <> 0 then
                       begin
                       for ii:= 1 to NUMREAD do
                       begin
                            if (ii mod 2) <> 0 then
                            begin
                                 if lin=79 then
                                 begin
                                      lin:=0;
                                      writeln(f2,b[ii]);
                                 end
                                 else
                                 begin
                                      lin:=lin+1;
                                      write(f2,b[ii]);
                                 end;
                            end;
                       end;
                       end;
                       until (NumRead = 0) ;
                       close(f1);
                       DeleteDatFile(config^.subfile[i][j]);
                  end;{if}
              end;{for}
              end;{for}
              close(f2);
              writeln; {make nice back}
              writeln('Relativity CommandLine Configuration');
              writeln;
              write('File ',deffile,' was saved with all the stuff');
              writeln;
              killconfigpointer;
              halt;
     end; {big if}
end;
end;

End.