;***********************************************
;代码作者：谭玉刚
;教程链接：
;
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
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
  xor si, si
  call PrintString
  jmp $
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
  or bl, NUL
  jz .return
  cmp bl, 0x0d
  jz .putCR
  cmp bl, 0x0a
  jz .putLF
  inc si
  mov [es:di], bl
  inc di
  mov [es:di], bh
  inc di
  call SetCursor
  jmp .loopEnd

  .putCR:
  mov bl, 160
  mov ax, di
  div bl
  shr ax, 8
  sub di, ax
  call SetCursor
  inc si
  jmp .loopEnd

  .putLF:
  add di, 160
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
section data align=16 vstart=0
  Hello db 'Hello,I come from program on sector 1,loaded by bootloader!'
        db 0x0d, 0x0a
        db 'Haha, This is a new line!'
        db 0x0a
        db 'Just 0a'
        db 0x0d
        db 'Just 0d'
        db 0x0d, 0x0a
        db 0x00
section stack align=16 vstart=0
  times 128 db 0
  StackEnd:
section end align=16
  ProgramEnd: