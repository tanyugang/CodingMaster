NUL equ 0x00
SETCHAR equ 0x07
VIDEOMEM equ 0xb800
STRINGLEN equ 0xffff
section head align=16 vstart=0
  Size dd ProgramEnd;4B 0x00
  SegmentAddr:
  CodeSeg dd section.code.start;4B 0x04
  DataSeg dd section.data.start;4B 0x08
  StackSeg dd section.stack.start;4B 0x0c
  SegmentNum:
  SegNum db (SegmentNum-SegmentAddr)/4;1B 0x10
  Entry dw CodeStart;2B 0x11
        dd section.code.start;4B 0x13
        
section code align=16 vstart=0
CodeStart:
  mov ax, [DataSeg]
  mov ds, ax
  mov ax, [StackSeg]
  mov ss, ax
  mov sp, StackEnd
  xor si, si
  ;mov cx, HelloEnd-Hello
  call ClearScreen
  call PrintString
  jmp $
ClearScreen:
  mov ax, VIDEOMEM
  mov es, ax
  xor di, di
  mov bl, ' '
  mov bh, SETCHAR
  mov cx, 2000
  .putspace:
  mov [es:di], bl
  inc di
  mov [es:di], bh
  inc di
  loop .putspace
  ret
  ;mov cx, STRINGLEN
PrintString:
  .setup:
  push ax
  push bx
  push cx
  push dx
  mov ax, VIDEOMEM
  mov es, ax
  xor di, di

  mov bh, SETCHAR
  mov cx, STRINGLEN
  
  .printchar:
  mov bl, [ds:si]
  ;判断并输出回车
  cmp bl, 0x0d
  jz .putCR
  ;判断并输出换行
  cmp bl, 0x0a
  jz .putLF
  ;实际输出字符
  or bl, NUL
  jz .return
  inc si
  mov [es:di], bl
  inc di
  mov [es:di], bh
  inc di;2
  call SetCursor
  jmp .loopEnd
  
  .putCR:;输出回车
  mov bl, 160;80
  mov ax, di;10
  div bl
  shr ax, 8;10
  sub di, ax
  call SetCursor
  inc si
  jmp .loopEnd
  .putLF:;输出换行
  add di, 160;80
  call SetCursor
  inc si
  jmp .loopEnd

  .loopEnd:
  loop .printchar

  .return:
  mov bx, di
  pop dx
  pop cx
  pop bx
  pop ax
  ret
SetCursor:
  push dx
  push bx
  push ax
  
  mov ax, di;2
  mov dx, 0
  mov bx, 2
  div bx

  mov bx, ax
  mov dx, 0x3d4
  mov al, 0x0e
  out dx, al
  mov dx, 0x3d5
  mov al, bh
  out dx, al
  mov dx, 0x3d4
  mov al, 0x0f
  out dx, al
  mov al, bl
  mov dx, 0x3d5
  out dx, al
  pop ax
  pop bx
  pop dx
  ret

section data align=16 vstart=0
  Hello db 'Hello,I come from program on sector 1,loaded by bootloader!'
        db 0x0d, 0x0a
        db 'Haha,This is a new line!'
        db 0x0a
        db 'Just 0a'
        db 0x0d
        db 'Just 0d'
        db 0x0d, 0x0a
        db 0x00
  HelloEnd:
section stack align=16 vstart=0
  times 128 db 0
  StackEnd:
section end align=16
  ProgramEnd: