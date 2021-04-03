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

  call ClearScreen
  call PrintLines
  jmp $
PrintLines:
  mov cx, HelloEnd-Hello
  xor si, si
  .putc:
  mov al, [si]
  inc si
  mov ah, 0x0e
  int 0x10
  loop .putc
  ret

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