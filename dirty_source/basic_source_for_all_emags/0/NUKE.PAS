procedure dospin;assembler;

asm
  mov    ax,$B800
  mov    es,ax
  mov    word ptr [$0828],$000C
  mov    word ptr [$0820],$00D0
@gloop:  mov    ax,[$0820]
  mov    [$0822],ax
@eloop:  mov    word ptr [$0824],$0039
  mov    word ptr [$0826],$0001
  mov    di,$0798
  mov    ax,[$0828]
  mov    [$081E],ax
@cloop:  mov    cx,[$0824]
  dec    cx
  push   ds
  push   es
  pop    ds
  mov    si,di
  add    si,$0002
  cld
  rep movsw
  pop    ds
  mov    cx,[$0826]
  push   ds
  push   es
  pop    ds
  mov    si,di
  sub    si,$00A0
  mov    ax,$00A2
  cld
@aloop:  movsw
  sub    di,ax
  sub    si,ax
  loop   @aloop
  pop    ds
  mov    cx,[$0824]
  push   ds
  push   es
  pop    ds
  mov    si,di
  sub    si,$0002
  std
  rep movsw
  pop    ds
  mov    cx,[$0826]
  inc    cx
  push   ds
  push   es
  pop    ds
  mov    si,di
  add    si,$00A0
  mov    ax,$00A2
  std
@bloop:  movsw
  add    di,ax
  add    si,ax
  loop   @bloop
  pop    ds
  add    word ptr [$0824],$0002
  add    word ptr [$0826],$0002
  dec    word ptr [$081E]
  jne    @cloop
  dec    word ptr [$0822]
  je     @dloop
  jmp    @eloop
@dloop:  sub    word ptr [$0820],$0008
  dec    word ptr [$0828]
  je     @floop
  jmp    @gloop
@floop:
end;

begin
     dospin;
end.