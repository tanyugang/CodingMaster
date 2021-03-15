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
  inc si
  mov [es:di], bl
  inc di
  mov [es:di], bh
  inc di
  or bl, NUL
  jz .return
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
section stack align=16 vstart=0
  resb 128
section end align=16
  ProgramEnd: