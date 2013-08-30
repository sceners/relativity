unit revgame;
interface
procedure extractgamefiles;
implementation
uses revdat;
procedure extractgamefiles;
begin
               Extractfilefromdat('PATTERN0.BTM');
               Extractfilefromdat('PATTERN1.BTM');
               Extractfilefromdat('PATTERN2.BTM');
               Extractfilefromdat('PATTERN3.BTM');
               Extractfilefromdat('PATTERN4.BTM');
               Extractfilefromdat('PLAYGR.BTM');
               Extractfilefromdat('EXPLODE.BTM');
               Extractfilefromdat('NEWVAUS.BTM');
               Extractfilefromdat('SOUNDFX.BTM');
               Extractfilefromdat('SHINEWAL.BTM');
               Extractfilefromdat('MINIVAUS.BTM');
               Extractfilefromdat('LEVELSEL.BTM');
               Extractfilefromdat('DROPS.BTM');
               Extractfilefromdat('VAUS.BTM');
               Extractfilefromdat('LASERS.BTM');
               Extractfilefromdat('ENLARGED.BTM');
               Extractfilefromdat('FIRE.BTM');
               Extractfilefromdat('SCRFLUX.BTM');
               Extractfilefromdat('WHWALLS.DTA');
end;
end.