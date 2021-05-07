section Initial align=16 vstart=0x9000
InitialStart:
  mov di, InitialLanded
  call PrintString
  mov eax, 0x80000008
  cmp eax, 0x80000000
  jbe LongModeNotSupport
  hlt

InitialLanded db 'You are successfully entry Initial.bin, have some fun!'
              db 0x0d, 0x0a
LongModeSupported:
  mov di, YesLongMode
  call PrintString
  jmp $
LongModeNotSupport:
  mov di, NoLongMode
  call PrintString
  jmp $
PrintString:
  push ax
  push cx
  push di
  mov cx, 1024
  PrintOneChar:
    mov al, [di]
    mov ah, 0x0e
    int 0x10
    cmp byte [di], 0x0a
    je Return
    inc di
    loop PrintOneChar
  Return:
    pop di
    pop cx
    pop ax
    ret