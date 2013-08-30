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
Procedure CreatText;

implementation

uses crt,dos,revset,revinit,revconst,revpoint,arkanoid,revgame,revstr,revwin,
     REVFNT,revhard;

const max=5000;
type buf= array[1..max] of char;
var
    textprint:boolean;
Const DiskSizeNeeded='2';
      deffile='Issue-06.rev';

Procedure RevCommand;
var
    score,k,ii,i,j,lin:longint;
    precent:integer;
    par : string;

begin
textprint:=false;
for k:= 1 to paramcount do
begin
     par:=upstr(paramstr(k));
     if (par= '/?') then
     begin
          writeln; {make nice back}
          writeln('Relativity CommandLine Configuration');
          writeln;
          writeln('þ /? This Help');
          writeln('þ /B Removes The Bug That Crashes Win95');
          writeln('þ /M Ignores MEMORY warning at startup');
          writeln('þ /C Compiled on .. ?');
          writeln('þ /G Play Game Only');
          writeln('þ /WV Windows95 VMM Change ( Syntax REV97-XX /WV REV_EMAG )');
          writeln('þ /WA Windows95 APP Change ( Syntax REV97-XX /WA ISSUE_X )');
          writeln('þ /I Disable Intro (N/A Yet)');
          writeln('þ /H  Only Show Hardware & Software Detection');
          writeln('þ /NH Disable Hardware & Software Detection in Runtime');
          writeln('þ /NA Disable ADLIB Sound System in Runtime');
          writeln('þ /V Disable SFX Sound System ');
          writeln('þ /NV No Vga in Runtime');
          writeln('þ /NC No CD in Runtime');
          writeln('þ /NP No Printer in Runtime');
          writeln('þ /NM Disable Mouse in Runtime');
          writeln('þ /R RequireMents');
          writeln('þ /T Create Emag''s Text File ');
          writeln('þ /P Create Emag''s On Printer (RED ALERT !!)');
          writeln('þ /D Default Configuration (N/A Yet)');
          writeln('þ /S ReConfigure MOD/S3M Sound System (N/A Yet) ');
{          writeln;}
          killconfigpointer;
          halt;
     end;
     if (par= '/I') then
     begin
          intro:=false;
     end;
     if (par= '/V') then
     begin
          voc_start:=false;
          voc:=false;
     end;
     if (par= '/C') then
     begin
          writeln; {make nice back}
          writeln('Relativity Was Compiled On :');
          writeln;
          writeln('þ Packard Bell (Fackard Bell)');
          writeln('þ Pentium 120 Mhz');
          writeln('þ SoundBlaster 16');
          writeln('þ Microsoft Mouse');
          writeln('þ Hewlett Packard Deskjet 660c');
          writeln('þ 580K Base Memory Free');
          writeln('þ 24Mb Memory ');
          writeln('þ VESA Ver: 1.2, Cirrus Logic GD-54xx VGA ');
          writeln('þ Windows 96 Nashville');
          writeln('þ 1.5 Gig Harddisk');
          writeln('þ 4x CDROM');
          Writeln;
          writeln('And It Worked Perfectly !!!!!');
          writeln;
          killconfigpointer;
          halt;
     end;
     if (par= '/B') then
     bar:=false;
     if (par= '/R') then
     begin
          writeln; {make nice back}
          writeln('Relativity RequireMents Are');
          writeln;
          writeln('þ 486 or Above');
          writeln('þ SoundBlaster 16 or Better');
          writeln('þ Rodent Optional ');
          writeln('þ Printer Optional ');
          writeln('þ 8Mb Memory or More');
          writeln('þ Vga / Super Vga');
          writeln('þ Windows 96');
          writeln('þ ',DiskSizeNeeded,' Megz or More');
          writeln;
          killconfigpointer;
          halt;
     end;
     if (par= '/WV') then
     begin
          if config^.winon then
          begin
             Change_VMM_Title(paramstr(2)); { Max String Length = 29+Nul }
             writeln('Changed to ',paramstr(2));
          end;
              killconfigpointer;
             halt;
     end;
     if (par= '/WA') then
     begin
          if config^.winon then
          begin
             Change_APP_Title(paramstr(2)); { Max String Length = 29+Nul }
             writeln('Changed to ',paramstr(2));
          end;
              killconfigpointer;
             halt;
     end;
     if (par= '/NH') then
        hard:=false;
     if (par= '/NP') then
         printer:=false;
     if (par= '/NM') then
         mouse:=false;
     if (par= '/NV') then
         vga_:=false;
     if (par= '/NC') then
         cd:=false;
     if (par= '/NA') then
         adlib:=false;
     if (par= '/G') then
     begin
          if mouse then
          begin
               g:=false;
               readglobalindex;
               initpointers;
               extractgamefiles;
               startgame(score);
          end
          else
          begin
               killconfigpointer;
               writeln('NO Mouse NO GAME !!');
               halt;
          end;
     end;
     if (par= '/P') then
     begin
          textprint:=true;
          creattext;
     end;
     if (par= '/T') then
     begin
          creattext;
     end;
     if (par= '/H') then
     begin
          initpointers;
          hardwareinit;
          textbackground(black);
          textcolor(lightgray);
          clrscr;
          killconfigpointer;
          killpointers;
          halt;
     end;
end;
end;


Function ask:boolean;
var ch:char;
begin
     write('Are You Insane Enough to use so much Ink (Y/N) ??');
     ch:=' ';
     while (ch<>'n') and (ch<>'y') and (ch<>'N') and (ch<>'Y') do
     begin
          ch:=readkey;
     end;
     if upcase(ch) ='N' then halt;
end;

Procedure CreatText;
var
    f1:file;
    f2:text;
    i,j,ii:integer;
    lin:integer;
    b:buf;
    numread:word;

begin
          writeln;
          if not textprint then
          begin
               write('Creating Emag''s Text Version .. Please Wait !!');
               assign(f2,deffile);
          end;
          if textprint then
          begin
               if printer then
               begin
                    if ask then
                       assign(f2,'PRN')
                    else
                        halt;
               end
               else
               begin
               writeln('Printer Not Responding. Quiting..');
               halt;
               end;
          end;
          rewrite(f2);
          for i:= 1 to 17 do begin
              for j:= 1 to 18 do begin
if (config^.subfile[i][j]<>'') and (config^.subfile[i][j]<>'.BIN') and (pos('.GIF',config^.subfile[i][j])=0) then
                  begin
                       if (i=10) or (i=13) then
                       else
                       begin
                       write(config^.subfile[i][j]);
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
{----------------------------------------------------------------------}


{----------------------------------------------------------------------}
                      end;{hexen pics}
                  end;{if}
              end;{for}
              end;{for}
              close(f2);
              writeln; {make nice back}
              writeln('Relativity CommandLine Configuration');
              writeln;
              if not textprint then
              writeln('File ',deffile,' was saved with all the stuff');
              if textprint then
              writeln('Emag Was Printed on PRINTER');
              writeln;
              killconfigpointer;
              halt;
     end; {big if}


End.