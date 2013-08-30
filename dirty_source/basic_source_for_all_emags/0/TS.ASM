;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; ts.asm - timer service routines
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

ideal
ifdef PASCAL
model   large,pascal
else
model   large,c
endif
p386

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Data segment
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dataseg

oldtimer        dd      ?               ; BIOS INT 08h routine
irqcallback     dd      ?               ; user defined callback routine
irqactive       dw      ?               ; callback routine active flag
irqenabled      dw      0               ; timer service enabled flag
timerspeed      dw      ?               ; timer speed in clock ticks
timercount      dw      ?               ; timer counter used to call the
                                        ; old BIOS timer interrupt service

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Code segment
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
codeseg

global  TSInit:proc                     ; initialize the routines
global  TSDone:proc                     ; deinitialize the routines
global  TSSetRate:proc                  ; set the callback rate in hertz
global  TSSetRoutine:proc               ; set the callback routine address
global  TSRestoreTime:proc              ; restore the time/date

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; TSInit - initialize the timer service routines
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
proc    TSInit
        cmp     [irqenabled],0          ; services already enabled? exit
        jne     tsinitd0
        lea     ax,[dummy]              ; set the default callback routine
        mov     [word low irqcallback],ax
        mov     [word high irqcallback],cs
        mov     ax,3508h                ; save the BIOS INT 08h vector
        int     21h
        mov     [word low oldtimer],bx
        mov     [word high oldtimer],es
        mov     [irqactive],0
        push    ds                      ; set our timer interrupt vector
        mov     ax,cs
        mov     ds,ax
        lea     dx,[timerhandler]
        mov     ax,2508h
        int     21h
        pop     ds
        cli                             ; reprogram the PIT timer0 rate
        mov     al,36h                  ; to 18.2 Hertz (default)
        out     43h,al
        xor     al,al
        out     40h,al
        out     40h,al
        sti
        mov     [timerspeed],0FFFFh
        inc     [irqenabled]
tsinitd0:
        ret
endp    TSInit

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; TSDone - deinitialize the timer services
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
proc    TSDone
        cmp     [irqenabled],0          ; services not enabled? exit
        je      tsdoned0
        cli                             ; restore the PIT timer0 rate
        mov     al,36h                  ; to 18.2 Hertz (normal)
        out     43h,al
        xor     al,al
        out     40h,al
        out     40h,al
        sti
        push    ds                      ; restore the BIOS INT 08h vector
        mov     dx,[word low oldtimer]
        mov     ds,[word high oldtimer]
        mov     ax,2508h
        int     21h
        pop     ds
        dec     [irqenabled]
tsdoned0:
        ret
endp    TSDone

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; TSRate - set the number of calls per seconds of the callback routine
; In:
;  Speed = speed in hertz
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
proc    TSSetRate Speed:word
        cmp     [irqenabled],0
        je      tssetrated0
        mov     dx,0012h                ; get the clock ticks using the
        mov     ax,34DEh                ; formula: tc = 1193182/speed
        div     [Speed]
        mov     [timerspeed],ax
        mov     dx,ax
        cli                             ; program the PIT timer 0 rate
        mov     al,36h
        out     43h,al
        mov     al,dl
        out     40h,al
        mov     al,dh
        out     40h,al
        sti
tssetrated0:
        ret
endp    TSSetRate

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; TSSetRoutine - set the callback routine address
; In:
;  Rout = address of the callback routine
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
proc    TSSetRoutine Rout:dword
        mov     eax,[Rout]              ; change the callback routine
        mov     [irqcallback],eax       ; address to the new one
        ret
endp

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; TSRestoreTime - restore the time/date using the CMOS
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
proc    TSRestoreTime
        mov     al,0                    ; get seconds
        out     70h,al
        in      al,71h
        mov     ah,al
        and     al,0Fh
        shr     ah,4
        aad
        mov     dh,al

        mov     al,2                    ; get minutes
        out     70h,al
        in      al,71h
        mov     ah,al
        and     al,0Fh
        shr     ah,4
        aad
        mov     cl,al

        mov     al,4                    ; get hours
        out     70h,al
        in      al,71h
        mov     ah,al
        and     al,0Fh
        shr     ah,4
        aad
        mov     ch,al

        xor     dl,dl                   ; set hour:minute:secs
        mov     ah,2Dh
        int     21h

        mov     al,7                    ; get day
        out     70h,al
        in      al,71h
        mov     ah,al
        and     al,0Fh
        shr     ah,4
        aad
        mov     dl,al

        mov     al,8                    ; get month
        out     70h,al
        in      al,71h
        mov     ah,al
        and     al,0Fh
        shr     ah,4
        aad
        mov     dh,al

        mov     al,4                    ; get year
        out     70h,al
        in      al,71h
        mov     ah,al
        and     al,0Fh
        shr     ah,4
        aad
        mov     cl,al

        xor     ch,ch                   ; set the month/day/year
        add     cx,1900
        mov     ah,2Bh
        int     21h
        ret
endp    TSRestoreTime

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; timerhandler - hardware timer interrupt routine
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
proc    timerhandler
        pushad
        push    ds
        push    es
        push    fs
        push    gs
        mov     ax,@data                ; get the DS data segment
        mov     ds,ax
        cmp     [irqactive],0           ; already active?
        jne     timerhandlerd0          ; exit, don't allow recursive calls
        inc     [irqactive]
        call    [irqcallback]           ; call the user callback routine
        dec     [irqactive]
timerhandlerd0:
        mov     ax,[timerspeed]
        add     [timercount],ax         ; call the old BIOS timer interrupt
        jnc     timerhandlerd1          ; service 18.2 times per second
        pushf
        call    [oldtimer]
        jmp     timerhandlerd2
timerhandlerd1:
        mov     al,20h                  ; send acknowledge to the PIC
        out     20h,al
timerhandlerd2:
        pop     gs
        pop     fs
        pop     es
        pop     ds
        popad
        iret
endp    timerhandler

proc    dummy
        ret
endp    dummy

end
