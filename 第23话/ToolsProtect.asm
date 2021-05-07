PrintFLAGS:
  push eax
  push esi
  push cx
  mov esi, flagtip
  mov cx, 8
  call PrintNBytesAscii
  pushf
  mov eax, [esp+4]
  popf
  mov cx, 3
  cfb:
    mov esi, cf
    bt eax, 0
    jnc cfc
    add esi, 3
    cfc:    
      call PrintNBytesAscii
  zfb:
    mov esi, zf
    bt eax, 6
    jnc zfc
    add esi, 3
    zfc:    
      call PrintNBytesAscii
  mov al, 0x0d
  call PrintByteAscii
  mov al, 0x0a
  call PrintByteAscii
  pop cx
  pop esi
  pop eax
  ret

  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov cx, 52
  call PrintNBytesHex
  mov eax, 0x80000001
  cpuid
  ;call SaveCPUIDResult
  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov cx, 52
  call PrintNBytesHex
  mov esi, CPUIDResult
  mov cx, 52
  call PrintNBytesHex
  ;call PrintCPUIDResult
  mov eax, 0x80000002
  cpuid
  ;call PrintCPUIDResult
  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov cx, 52
  call PrintNBytesHex
  mov eax, 0x80000003
  cpuid
  ;call PrintCPUIDResult
  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov cx, 52
  call PrintNBytesHex
  mov eax, 0x80000004
  cpuid
  ;call PrintCPUIDResult
  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov cx, 52
  call PrintNBytesHex


TestClearLine:
  mov cx, 80
  TClearOneLine:
      mov word [es:di], 0x0720
      add di, 2
      loop TClearOneLine
  ret
TestMovsw:
  mov ax, es
  mov ds, ax
  cld
  mov esi, 0
  mov edi, 640
  mov cx, 80
  rep movsw
  ret

mov eax, 0x80000000
  cpuid
  call PrintCPUIDResult
  cmp eax, 0x80000000
  jbe NoLongMode
  mov eax, 0x80000001
  cpuid
  call PrintCPUIDResult
  bt edx, 29
  jnc NoLongMode

IsLongModeSupported:
  
  mov eax, 0x80000002
  cpuid
  call PrintCPUIDResult
  

  jmp $
NoLongMode:
  mov esi, TipNoLongMode
  mov dl, 0
  call PrintString
  jmp InitialEnd
YesLongMode:
  mov esi, TipYesLongMode
  mov dl, 0
  call PrintString
  jmp InitialEnd
  ;在开启64位之前，需要定义页表
  ;这个参考EDKII的代码，那是经过实战的
  ;我们使用内存的4级页表结构   
IsLongModeSupported:
 mov esi, TipYesLongMode
 mov dl, 0
 call PrintString
mov eax, 0x80000008
  cmp eax, 0x80000000
  ja YesLongMode
NoLongMode:
  mov esi, TipNoLongMode
  mov dl, 0
  call PrintString
  jmp InitialEnd
YesLongMode:
  mov esi, TipYesLongMode
  mov dl, 0
  call PrintString
;32位保护模式下打印字符串
;入参为esi，指向需要打印的字符串
;edi指向显存，0x0d,0x0a结束
PrintString:
  push ax
  push bx
  push cx
  push esi
  push di
  call GetCursor
  mov cx, 1024
  PrintOneChar:
    ;取一个字符
    mov bl, [esi]
    ;判断回车
    cmp bl, 0x0d
    jz PrintCR
    ;判断换行
    cmp bl, 0x0a
    jz PrintLF
    or bl, 0
    jz PrintStringEnd
    PrintNormal:
      mov [es:di], bl
      inc esi
      add di, 2
      call ShouldScreenRoll
      call SetCursor
      loop PrintOneChar

    PrintCR:
      mov dl, 160
      mov ax, di
      div dl
      shr ax, 8
      sub di, ax
      call SetCursor
      inc esi
      jmp PrintOneCharEnd
    PrintLF:
      add di, 160
      call ShouldScreenRoll
      call SetCursor
      inc esi
      jmp PrintOneCharEnd
    PrintOneCharEnd:
      loop PrintOneChar

  PrintStringEnd:
    pop di
    pop esi
    pop cx
    pop bx
    pop ax
    ret

PrintByteAscii:
  ;push ax
  ;push di
  ;call GetCursor
  ;mov [es:di], al
  ;add di, 2
  ;call ShouldScreenRoll
  ;call SetCursor
  ;pop di
  ;pop ax
  ;ret