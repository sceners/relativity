unit cdrom;
{Great Amazing CD player !!!}
{Great Amazing CD player !!!}

{
    this program will allow the control of multiple cd-rom audio drives
    simultaniously.
    I am not sure just yet what sort of an interface I'm going to provide
    but we will soon see eh?
    }

{ prototype #1, just get talking to an audio CD-ROM
}

interface

uses crt;

const
    MAX_TRACKS_PER_CD = 30;

type
    TAudioTrackRec = record
        code : byte;
        track : byte;
        startPoint : longint;
        trackInfo : byte;
        end;

    TAudioDiskRec = record
        code : byte;
        lowTrack : byte;
        highTrack : byte;
        startPoint : longint;
        end;

    TTrackRec = record
        number : byte;
        start : longint;
        finish : longint;
        end;

    TTrackArray = array[1 .. MAX_TRACKS_PER_CD] of TTrackRec;

var
    tracks : TTrackArray;
    lasttrack:byte;

{ This is a VERY simple CD-player. It only plays from the first
{ available CD, and only tracks from 1 - 9 and stops after every
{ track... but it will give you and idea!
}
procedure playATrack;

{Stop the CD player "drive", no errors, even when already stopped}
procedure stopCD( drive : word );

{ Play a track from the presumably already loaded tracks array
{ NO ERROR CHECKING ON THIS!. Programmer to make sure that
{ this procedured is proceeded at some point by calling of the
{ procedure "getAllTrackDetails"}
procedure playTrack( drive, track : word );

{ Play from sectors start to finish on drive.
{ NO ERROR CHECKING }
procedure playTrack2(drive : word; start, finish : longint);

{ If used after a STOPCD, this will resume play at where the CD
{ was stopped, assuming same drive }
procedure resumePlay( drive : word );


{ Gets all the track details for the currently loaded CD and places
{ it into the "TRACKS" array }
procedure getAllTrackDetails( drive : word );

{ Stops and causes the CD tray to eject (if supported) }
procedure ejectCD( drive : word );

{ Closes the CD tray (not supported under OS/2, and many CD players }
procedure closeCD( drive : word );

{ Locks the CD tray, prevents ejection from eject button pressing }
procedure lockCD( drive : word );

{ Unlocks the CD track, allows ejection from eject button pressing }
procedure unlockCD( drive : word );

{ Refreshes the buffers in the CD player, ensures the information is
{ correct }
procedure resetCD( drive : word );

{ Get the Universal Product code of the CD, not usually available }
procedure getUPC( drive : word; var upc : string );

{ Get the VTOC from the CD }
procedure readVTOC( drive : word );

{ Get the details of a particular track on the CD }
procedure getTrackDetails(     drive : word;
                            trk : byte;
                            var t : TAudioTrackRec
                            );

{ Get the number of CD players, and the first CD number }
function getNumberOfCDs( var sLetter : word ) : word;


function getUnique( drive : word ) : string;

{ Get the Details of the currently loaded CD }
function getCDDetails( drive : word; var t : TAudioDiskRec ) : word;

{ Get the number of tracks of the currently loaded CD }
function getNumberOfTracks( drive : word ) : word;

{ Get the running time of the currently playing track }
function getRunningTime( drive : word; var min,sec : byte ) : word;

{ Returns true if the CD player has been changed and no update of
{ information has occured }
function mediaChanged( drive : word ) : boolean;

{ Returns TRUE if the CD-tray is ejected }
function doorOpen(drive : word) : boolean;





implementation

const
    EJECT_TRAY     = 0;
    CLOSE_TRAY     = 5;
    PLAY_TRACK    = 132;
    STOP_TRACK    = 133;
    RESUME_TRACK = 136;
    RESET_CD    = 2;

    GET_TRACK_INFO     = 11;
    GET_DISK_INFO   = 10;

    READ_IOCTL     = 3;
    WRITE_IOCTL = 12;

    MAX_CDS = 10;

    UPC_CODE     = 14;
    LOCK_CODE     = 1;

    LOCK_CD     = 0;
    UNLOCK_CD     = 1;

    Q_INFO        = 12;
    MEDIA_CHANGE = 9;
    DEVICE_STATUS = 6;

type

    rHRec = record
        length : byte;
        subUnitCode : byte;
        commandCode : byte;
        status : word;
        reserved : array[1..8] of byte;
        end;

    IOCTLRec = record
        r : rHRec;
        MDB : byte;
        tAOfs : word;
        tASeg : word;
        bytesToTransfer : word;
        startingSector : word;
        error : longint;
        end;

    TLockRec = record
        r : rHRec;
        code : byte;
        lock : byte;
        end;

    TUPCRec = record
        code : byte;
        control : byte;
        UPC : array[1..7] of byte;
        zero : byte;
        aFrame : byte;
        end;

    TPlayAudioTrackRec = record
        r : rHRec;
        mode : byte;
        start : longint;
        sectors : longint;
        end;


    TQRec = record
        code : byte;
        ADR : byte;
        Track : byte;
        Point : byte;
        min : byte;
        sec : byte;
        frame : byte;
        zero : byte;
        pMin : byte;
        pSec : byte;
        pFrame : byte;
        end;

    TMediaRec = record
        code : byte;
        media : byte;
        end;

    TStatusRec = record
        code : byte;
        status : longint;
        end;


    TTrackNameArray = array[1 .. MAX_TRACKS_PER_CD] of string[40];

    TCDROMRec = record
        UPC : longint;
        cdName : string[40];
        trackNames : TTrackNameArray;
        maxTrack : byte;
        end;

    TCDRackRec = record
        status : array[1 .. MAX_CDS] of word;
        rack : array[1 .. MAX_CDS] of TTrackArray;
        info : array[1 .. MAX_CDS] of TCDROMRec;
        end;
var
    CDRack : TCDRackRec;
    result : word;
    startLetter : word;






{--------------------------------------------------------------------}
{Play A Track
{    This is a very simple CD player, which only plays the first
{    available CD, and only tracks 1-9. However, it does give
{    the idea.
}
procedure playATrack;

var
    k : char;
    trk : word;
    e : integer;
    drive : word;
    quit : boolean;
begin
    getNumberOfCDs(drive);
    getAllTrackDetails(drive);
    quit := FALSE;
    repeat
        repeat until keypressed;
        k := readKey;
        stopCD(drive);
        if (k >= '1') and (k <= '9') then begin
            write('Playing track : ',k,'  ');
            val(k,trk,e);
            playTrack(drive,trk);
            end
        else quit := TRUE;

    until quit;
    end;












{--------------------------------------------------------------------}
{
{
{
{
}
function getNumberOfCDs( var sLetter : word) : word;
var drives, startLetter : word;
begin
    asm
        mov ax,1500h
        int 2fh;
        mov startLetter,CX
        mov drives,BX
        end;
    sLetter := startLetter;
    getNumberOfCDs := drives;

    end;









{--------------------------------------------------------------------}
{
{
{
{
}
procedure setIOCTL( var i : IOCTLRec );
var index : byte;
begin
    with i do begin
        with r do begin
            length := 0;
            subUnitCode := 0;
            commandCode := 0;
            status := 0;
            for index := 1 to 8 do reserved[index] := 0;
            end;{with R}
        MDB := 0;
        tASeg := 0;
        tAOfs := 0;
        bytesToTransfer := 0;
        startingSector := 0;
        error := 0;
        end;{with i}
    end;










{--------------------------------------------------------------------}
{
{
{
{
}
procedure getTrackDetails(     drive : word;
                            trk : byte;
                            var t : TAudioTrackRec
                            );
var index : word;
    i : IOCTLRec;
    s,o : word;
begin

    setIOCTL(i);

    with i do begin
        bytesToTransfer := 7;
        tAOfs := ofs(t);
        tASeg := seg(t);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := READ_IOCTL;
        end;

    with t do begin
        track    := trk;
        code     := GET_TRACK_INFO;
        end;

    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
        { t will now contain the relevant information }

    end;











{--------------------------------------------------------------------}
{
{
{
{
}
function getCDDetails(     drive : word;
                            var t : TAudioDiskRec
                            ) : word;
var index : word;
    i : IOCTLRec;
    s,o : word;
begin

    setIOCTL(i);

    with i do begin
        bytesToTransfer := 7;
        tAOfs := ofs(t);
        tASeg := seg(t);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := READ_IOCTL;
        end;

    with t do begin
        code     := GET_DISK_INFO;
        lowTrack := 0;
        highTrack := 0;
        startPoint := 0;
        end;

    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
        { t will now contain the relevant information }
    getCDDetails := i.r.status;
    end;











{--------------------------------------------------------------------}
{
{
{
{
}
function redBookToSectors( red : longint ) : longint;
var
    frame, minute, second : byte;
    temp : longint;
begin
    frame     := (red AND $000000FF);
    second     := (red AND $0000FF00) shr 8;
    minute     := (red AND $00FF0000) shr 16;
    temp := minute *60;
    temp := temp *75;
    temp := temp + second *75;
    temp := temp + frame -150;
    redBookToSectors := temp;
    end;










{--------------------------------------------------------------------}
procedure getAllTrackDetails( drive : word );
var
    diskInfo : TAudioDiskRec;
    aTrack : TAudioTrackRec;
    firstCD : word;
    currentTrack : byte;
    index1, index2 : byte;
    pos1,pos2,pos3 : word;
begin
    getCDDetails(drive,diskInfo);
    lasttrack:=diskinfo.hightrack;
    for currentTrack := diskInfo.lowTrack to diskInfo.highTrack do begin
        getTrackDetails(drive,currentTrack,aTrack);
        with tracks[currentTrack] do begin
            number := currentTrack;
            start := aTrack.startPoint;
            if (currentTrack > 1) then begin
                tracks[currentTrack-1].finish := tracks[currentTrack].start-1;
                end;
            end;{with}
        end;{for}
    end;
{--------------------------------------------------------------------}
procedure stopCD(drive : word);
var r : rHRec;
    s,o : word;
begin
    r.commandCode := 133;
    r.length := sizeOf(r);
    s := seg(r);
    o := ofs(r);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
    end;
end;

{--------------------------------------------------------------------}
procedure playTrack(drive,track : word);
var index : word;
    p : TPlayAudioTrackRec;
    s,o : word;
    st,fi : longint;
begin

    p.r.subUnitCode := 0;
    p.r.status := 0;
    p.r.commandcode := 132;
    p.r.length := sizeOf(p);

    for index := 1 to 8 do begin
        p.r.reserved[index] := 0;
        end;


    p.start := tracks[track].start;
    fi := redBookToSectors(tracks[track].finish);
    st := redBookToSectors(tracks[track].start);
    p.sectors := fi-st;

    p.mode := 1;

    s := seg(p);
    o := ofs(p);

    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;


end;






{--------------------------------------------------------------------}
{
{
{
{
}
procedure playTrack2(drive : word;
                    start, finish : longint);

var index : word;
    p : TPlayAudioTrackRec;
    s,o : word;
    st,fi : longint;
begin

    p.r.subUnitCode := 0;
    p.r.status := 0;
    p.r.commandcode := 132;
    p.r.length := sizeOf(p);
    for index := 1 to 8 do begin
        p.r.reserved[index] := 0;
        end;

    p.start := start;
    fi := redBookToSectors(finish);
    st := redBookToSectors(start);
    p.sectors := fi-st;
    p.mode := 1;


    s := seg(p);
    o := ofs(p);

    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;


    end;










{--------------------------------------------------------------------}
{
{
{
{
}
procedure ejectCD( drive : word );
var index : word;

    ejRec : record
        code : byte;
        end;

    i : IOCTLRec;
    rq : rHRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 1;
        tAOfs := ofs(ejRec);
        tASeg := seg(ejRec);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := 12;
        end;

    ejRec.code := EJECT_TRAY;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
    end;











{--------------------------------------------------------------------}
{
{
{
{
}
procedure closeCD( drive : word );
var index : word;

    ejRec : record
        code : byte;
        end;

    i : IOCTLRec;
    rq : rHRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 1;
        tAOfs := ofs(ejRec);
        tASeg := seg(ejRec);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := 12;
        end;

    ejRec.code := CLOSE_TRAY;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
    end;






{--------------------------------------------------------------------}
{
{
{
{
}
procedure resetCD( drive : word );
var index : word;

    resetRec : record
        code : byte;
        end;

    i : IOCTLRec;
    rq : rHRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 1;
        tAOfs := ofs(resetRec);
        tASeg := seg(resetRec);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := 12;
        end;

    resetRec.code := RESET_CD;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
    end;






{--------------------------------------------------------------------}
{
{
{
{
}
procedure lockCD( drive : word );
var index : word;

    lockRec : record
        code : byte;
        lock : byte;
        end;

    i : IOCTLRec;
    rq : rHRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 2;
        tAOfs := ofs(lockRec);
        tASeg := seg(lockRec);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := 12;
        end;

    lockRec.code := LOCK_CODE;
    lockRec.lock := LOCK_CD;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
    end;






{--------------------------------------------------------------------}
{
{
{
{
}
procedure unlockCD( drive : word );
var index : word;

    lockRec : record
        code : byte;
        lock : byte;
        end;

    i : IOCTLRec;
    rq : rHRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 2;
        tAOfs := ofs(lockRec);
        tASeg := seg(lockRec);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := 12;
        end;

    lockRec.code := LOCK_CODE;
    lockRec.lock := LOCK_CD;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;
    end;







{--------------------------------------------------------------------}
{
{
{
{
}
function getUnique( drive : word ) : string;
var
    a : TAudioDiskRec;
    s : string;
begin
    getCDDetails(drive,a);
    Str(a.startPoint,s);
    getUnique := s;
    end;






{--------------------------------------------------------------------}
{
{
{
{
}
procedure getUPC( drive : word; var UPC : string );
var u : TUPCRec;
    s,o : word;
    index : integer;
    res : byte;
    i : IOCTLRec;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 11;
        tAOfs := ofs(u);
        tASeg := seg(u);
        end;

    with i.r do begin
        length := 23{sizeof(i);};
        commandCode := READ_IOCTL;
        end;

    u.code := UPC_CODE;
    u.control := 2;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;


    upc := '';

    for index := 1 to 7 do begin

        res := (u.upc[index] AND $0F);
        upc := concat(upc,chr(res+48));
        if (index < 7) then begin
            res := ((u.upc[index] AND $F0) SHR 4);
            upc := concat(upc,chr(res+48));
            end;
        end;{for}

    end;







{--------------------------------------------------------------------}
{
{
{
{
}
function getNumberOfTracks( drive : word ) : word;
var a : TAudioDiskRec;
begin
    getCDDetails(drive,a);
    getNumberOfTracks := a.highTrack;
    end;








{--------------------------------------------------------------------}
{
{
{
{
}
procedure readVTOC( drive : word );
var
    buffer : array[1..2048] of byte;
    s,o : word;
begin


    o := ofs(buffer);
    s := seg(buffer);
    asm
        mov ax,1508h;
        mov cx,drive;
        mov si,s    ;
        mov di,o    ;
        mov dx,1    ;
        int 2fh;
        end
    end;







{--------------------------------------------------------------------}
{
{
{
{
}
procedure resumePlay( drive : word );
var r : rHRec;
    o,s : word;
begin
    r.commandCode := RESUME_TRACK;
    r.length := 1;
    o := ofs(r);
    s := seg(r);
    asm
        mov ax,1510h;
        mov cx,drive;
        mov es,s    ;
        mov bx,o    ;
        int 2fh;
    end
end;
{--------------------------------------------------------------------}
function getRunningTime( drive : word; var min,sec : byte ) : word;
var q : TQRec;
    index : word;
    i : IOCTLRec;
    rq : rHRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 1;
        tAOfs := ofs(q);
        tASeg := seg(q);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := READ_IOCTL;
        end;

    q.code := Q_INFO;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;

    min := q.min;
    sec := q.sec;
    getRunningTime := i.r.status;
    end;







{--------------------------------------------------------------------}
{
{
{
{
}
function mediaChanged( drive : word ) : boolean;
var q : TMediaRec;
    index : word;
    i : IOCTLRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 2;
        tAOfs := ofs(q);
        tASeg := seg(q);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := READ_IOCTL;
        end;

    q.code := MEDIA_CHANGE;
    q.media := 0;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;

    if (q.media < 1) then
        mediaChanged := TRUE
    else mediaChanged := FALSE;
    end;








{--------------------------------------------------------------------}
{
{
{
{
}
function doorOpen( drive : word ) : boolean;
var q : TStatusRec;
    index : word;
    i : IOCTLRec;
    s,o : word;
begin

    setIOCTL(i);
    with i do begin
        bytesToTransfer := 5;
        tAOfs := ofs(q);
        tASeg := seg(q);
        end;

    with i.r do begin
        length := sizeof(i);
        commandCode := READ_IOCTL;
        end;

    q.code := DEVICE_STATUS;
    q.status := 0;
    s := seg(i);
    o := ofs(i);
    asm
        mov ax,1510h
        mov cx,drive
        mov es,S
        mov bx,O
        int 2fh
        end;

    if (q.status AND $01)=1 then
        doorOpen := TRUE
        else doorOpen := FALSE;

    end;








{--------------------------------------------------------------------}
{
{
{
{
}
procedure init;
var index : word;
begin

    { initially we start this unit by reading all the available
    { CD-ROMs and taking in their track details.
    }
    for index := 1 to MAX_CDS do begin
        with CDRack do begin
            status[index] := 0;
            info[index].maxTrack := 0;
            end;
        end;
    end;





{--------------------------------------------------------------------}
{
{
{
{
}
begin

    { initially we start this unit by reading all the available
    { CD-ROMs and taking in their track details.
    }
    init;
end.

{

Paul L Daniels
Software Development (DOS, OS/2)
jackdan@ibm.net
jackdan@ozemail.com.au
}
