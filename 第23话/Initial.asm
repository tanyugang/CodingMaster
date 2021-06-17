section Initial align=16 vstart=0x9000
EnterProtectMode:
  ;禁用中断先
  DisableInterrupt:
    cli
  SetupGDTDesc:
    mov ax, GDTEnd
    sub ax, GDTStart
    sub ax, 1
    ;GDT Limits
    mov [GDTStart], ax
    ;GDT Base
    mov ax, GDTStart
    mov [GDTStart+2], ax
    
  ;加载临时GDT
  LoadGDT:
    lgdt [GDTStart]
    
  %define SEC_DEFAULT_CR0  0x40000023
  %define SEC_DEFAULT_CR4  0x640

  EnableProtectBit:
    mov eax, SEC_DEFAULT_CR0
    mov cr0, eax
    jmp dword CodeDescriptor:ProtectModeLand
BITS 32
ProtectModeLand:
  mov eax, SEC_DEFAULT_CR4
  mov cr4, eax
ResetSegmentRegister:
  mov ax, DataDescriptor
  mov ds, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov ax, VideoDescriptor
  mov es, ax
NowUnderProtected:
  mov esi, TipProtectedMode
  mov dl, 0
  call PrintString  
  mov edi, 0x00008000

IsLongModeSupported:
  mov eax, 0x80000000
  cpuid
  cmp eax, 0x80000000
  jbe NoLongMode
  mov eax, 0x80000001
  cpuid
  bt edx, 29
  jnc NoLongMode
;支持Long Mode，那就开启分页，进入64位
YesLongMode:
  mov esi, TipYesLongMode
  mov dl, 0
  call PrintString
  ;在开启64位之前，需要定义页表
  ;这个参考EDKII的代码，那是经过实战的
  

  
  jmp InitialEnd
;不支持Long Mode/IA-32e，就按照正常的32位CPU初始化
SeekTheKernelElf:
  cmp dword [edi], 'INIT'
  jne nextFile
  cmp dword [edi+4], 'IAL '
  jne nextFile
  cmp dword [edi+8], 'BIN '
  jne nextFile
  jmp KernelElfFound
  nextFile:
    cmp edi, 0x9000
    ja NoKernelElf
    add edi, 32
    jmp SeekTheKernelElf
KernelElfFound:
  mov esi, TipKernelFound
  mov dl, 0
  call PrintString
  ;获取文件长度
  mov ax, [di+0x1c]
  mov dx, [di+0x1e]
  ;文件长度是字节为单位的，需要先除以512得到扇区数
  mov cx, 512
  div cx
  ;如果余数不为0，则需要多读一个扇区
  cmp dx, 0
  je NoRemainder
  ;ax是要读取的扇区数
  inc ax
  mov [BlockCount], ax
  NoRemainder:
    ;文件起始簇号，也是转为扇区号，乘以8即可
    mov ax, [edi+0x1a]
    sub ax, 2
    mov cx, 8
    mul cx
    ;现在文件起始扇区号存在dx:ax，直接保存到ebx，这个起始是相对于DataBase 0x32,72
    ;所以待会计算真正的起始扇区号还需要加上DataBase
    and eax, 0x0000ffff
    add ebx, eax
    mov ax, dx
    shl eax, 16
    add ebx, eax
    mov [BlockLow], ebx
    mov word [BufferOffset], 0x9000
    mov di, 0x9000
;    call ReadDisk
    ;跳转到Initial.bin继续执行
    mov si, TipGotoKernel
    mov dl, 0
    call PrintString
    jmp di
NoKernelElf:
  mov esi, TipNoKernelElf
  mov dl, 0
  call PrintString
  hlt
NoLongMode:
  mov esi, TipNoLongMode
  mov dl, 0
  call PrintString
  jmp InitialEnd
InitialEnd:
  hlt

;打印CPUID结果
PrintCPUIDResult:
  push ecx
  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov ecx, 52
  call PrintNBytesAscii
  pop ecx
  ret
PrintCPUIDResultHex:
  push ecx
  call SaveCPUIDResult
  mov esi, CPUIDResult
  mov ecx, 4
  StartPrintCPUIDHex:
    call PrintOneRegister
    add esi, 13
    loop StartPrintCPUIDHex
  pop ecx
  ret

PrintOneRegister:
  push ecx
  push esi;0
  mov ecx, 7
  call PrintNBytesAscii
  add esi, 10;10
  mov ecx, 4
  call PrintNBytesHexTop
  add esi, 1;
  mov ecx, 2
  call PrintNBytesAscii
  pop esi
  pop ecx
  ret
;保存CPUID指令的查询结果
SaveCPUIDResult:
  mov [reax], eax
  mov [rebx], ebx
  mov [recx], ecx
  mov [redx], edx
  ret
;打印N个字节的16进制表示，从高到低
PrintNBytesHexTop:
  push ax
  push esi
  StartPrintByteHexTop:
    mov al, [esi]
    call PrintByteHex
    dec esi
  loop StartPrintByteHexTop
  PrintNBytesHexTopEnd:
  pop esi
  pop ax
  ret
;打印N个字节的16进制表示
PrintNBytesHex:
  push ax
  push esi
  StartPrintByteHex:
    mov al, [esi]
    call PrintByteHex
    inc esi
  loop StartPrintByteHex
  PrintNBytesHexEnd:
  pop esi
  pop ax
  ret
;打印AL寄存器的16进制形式
PrintByteHex:
  push bx
  mov bl, al
  shr al, 4
  call PrintHalfByteHex
  mov al, bl
  and al, 0x0f
  call PrintHalfByteHex
  mov al, bl
  pop bx
  ret
;打印半个字节的Hex
;入参为al
PrintHalfByteHex:
  push ax
  ;比较当前值与0x09，如果大则表示应该是A~F
  cmp al, 0x09
  ;打印一个值的Ascii
  ja PrintAF
  ;打印0~9之间的数字
  PrintNum:
    add al, 48
    call PrintByteAscii
    jmp PrintHexEnd
  ;打印A~F之间的字母
  PrintAF:
    add al, 55
    call PrintByteAscii
    jmp PrintHexEnd
  PrintHexEnd:
  pop ax
  ret
;打印普通字符串
;dl:结束符字节
PrintString:
  push ax
  push cx
  push dx
  push esi
  mov cx, 65535
  StartPrintString:
    mov al, [esi]
    cmp al, dl
    je PrintStringEnd
    call PrintByteAscii
    inc esi
    loop StartPrintString
  PrintStringEnd: 
  pop esi
  pop dx
  pop cx
  pop ax
  ret
  

;打印N个普通字符，入参为
;cx:打印的字符长度，也即N
;esi:需要打印的内存起始地址
PrintNBytesAscii:
  push ax
  push cx
  push esi
  StartPrintByteAscii:
    mov al, [esi]
    call PrintByteAscii
    inc esi
  loop StartPrintByteAscii
  PrintNBytesAsciiEnd:
  pop esi
  pop cx
  pop ax
  ret

;打印一个普通字符，入参为al
PrintByteAscii:
  push ax
  push dx
  push di
  push esi
  call GetCursor
  ;判断回车
  cmp al, 0x0d
  jz PrintCR
  ;判断换行
  cmp al, 0x0a
  jz PrintLF
  PrintNormal:
    mov [es:di], al
    inc esi
    add di, 2
    call ShouldScreenRoll
    call SetCursor
    jmp PrintByteAsciiEnd
  PrintCR:
    mov dl, 160
    mov ax, di
    div dl
    shr ax, 8
    sub di, ax
    call SetCursor
    inc esi
    jmp PrintByteAsciiEnd
  PrintLF:
    add di, 160
    call ShouldScreenRoll
    call SetCursor
    inc esi
    jmp PrintByteAsciiEnd
  PrintByteAsciiEnd:
    pop esi
    pop di
    pop dx
    pop ax
    ret
;判断是否需要滚动屏幕
ShouldScreenRoll:
  cmp di, 4000
  ;超出屏幕，需要滚动，jae=jump if equal or above
  jb NoScreenroll
  RollScreen:
    push ax
    push cx
    push ds
    push si
    cld
    mov ax, es
    mov ds, ax
    mov si, 0xa0
    mov di, 0x00
    mov cx, 1920
    rep movsw
    mov di, 3840
    call ClearOneLine
    pop si
    pop ds
    pop cx
    pop ax
  ;不超出屏幕
  NoScreenroll:
  ret
;滚动屏幕，movsw mov from ds:si to es:di
ClearOneLine:
  push di
  mov cx, 80
  PrintBlackSpace:
    mov word [es:di], 0x0720
    add di, 2
    loop PrintBlackSpace
  sub di, 160
  pop di
  ret

GetCursor:
  push ax
  push dx
  mov dx,0x3d4
  mov al,0x0e
  out dx,al
  mov dx,0x3d5
  in al,dx                        ;高8位 
  mov ah,al

  mov dx,0x3d4
  mov al,0x0f
  out dx,al
  mov dx,0x3d5
  in al,dx                        ;低8位 
  add ax, ax
;  mov [CursorNow], ax 
  mov di, ax
  pop dx
  pop ax
  ret
;设置光标位置
SetCursor:
  push dx
  push bx
  push ax
  
;  mov [CursorNow], di
  mov ax, di
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

; Macros for GDT entries
%define  PRESENT_FLAG(p) (p << 7)
%define  DPL(dpl) (dpl << 5)
%define  SYSTEM_FLAG(s) (s << 4)
%define  DESC_TYPE(t) (t)

; Type: data, expand-up, writable, accessed
%define  DATA32_TYPE 3
; Type: execute, readable, expand-up, accessed
%define  CODE32_TYPE 0xb
; Type: execute, readable, expand-up, accessed
%define  CODE64_TYPE 0xb
; Macros for GDT defination
%define  GRANULARITY_FLAG(g) (g << 7)
%define  DEFAULT_SIZE32(d) (d << 6)
%define  CODE64_FLAG(l) (l << 5)
%define  UPPER_LIMIT(l) (l)
GDTStart:
;空描述符，实际可以有比较好的用途，把gdt描述那48位放过来
NullDescriptor equ $-GDTStart
  dw 0 ; 段界限，Limits 00
  dw 0 ; base:15~0 02
  db 0 ; base:23~16 04
  db 0 ; sys flag, dpl, type 05
  db 0 ; limit 19:16, flags 05
  db 0 ; base 31:24
;数据段描述符，用于字符模式下写入信息
DataDescriptor equ $-GDTStart
  dw 0xffff ; 段界限，Limits 00
  dw 0 ; base:15~0 02
  db 0 ; base:23~16 04
  db PRESENT_FLAG(1)|DPL(0)|SYSTEM_FLAG(1)|DESC_TYPE(DATA32_TYPE)
  db GRANULARITY_FLAG(1)|DEFAULT_SIZE32(1)|CODE64_FLAG(0)|UPPER_LIMIT(0xf)
  db 0 ; base 31:24
VideoDescriptor equ $-GDTStart
  dw 0xffff ; 段界限，Limits 00
  dw 0x8000 ; base:15~0 02
  db 0x0b ; base:23~16 04
  db PRESENT_FLAG(1)|DPL(0)|SYSTEM_FLAG(1)|DESC_TYPE(DATA32_TYPE)
  db GRANULARITY_FLAG(1)|DEFAULT_SIZE32(1)|CODE64_FLAG(0)|UPPER_LIMIT(0xf)
  db 0 ; base 31:24
;32位代码段描述符
CodeDescriptor equ $-GDTStart
  dw 0xffff ; 段界限，Limits 00
  dw 0 ; base:15~0 02
  db 0 ; base:23~16 04
  db PRESENT_FLAG(1)|DPL(0)|SYSTEM_FLAG(1)|DESC_TYPE(CODE32_TYPE)
  db GRANULARITY_FLAG(1)|DEFAULT_SIZE32(1)|CODE64_FLAG(0)|UPPER_LIMIT(0xf)
  db 0 ; base 31:24
;长模式代码段描述符
LongDescriptor equ $-GDTStart
  dw 0xffff ; 段界限，Limits 00
  dw 0 ; base:15~0 02
  db 0 ; base:23~16 04
  db PRESENT_FLAG(1)|DPL(0)|SYSTEM_FLAG(1)|DESC_TYPE(CODE64_TYPE)
  db GRANULARITY_FLAG(1)|DEFAULT_SIZE32(0)|CODE64_FLAG(1)|UPPER_LIMIT(0xf)
  db 0 ; base 31:24
GDTEnd:

TipProtectedMode db 'Now you are under 32 bits Protected Mode!'
                 db 0x0d, 0x0a, 0
TipNoLongMode    db 'No, Long Mode is not supported on this computer.'
                 db 0x0d, 0x0a, 0
TipYesLongMode   db 'Yes! Long Mode is supported on this computer.'
                 db 0x0d, 0x0a, 0
TipKernelFound   db 'Yes! Kernel.elf is found, good for you!'
                 db 0x0d, 0x0a, 0
TipNoKernelElf   db 'Kernel.elf is not found on the disk, sad'
                 db 0x0d, 0x0a, 0                 
TipGotoKernel    db 'Now we are going to jump to Kernel.elf, yes!'
                 db 0x0d, 0x0a, 0
DiskAddressPacket:
  ;包大小，目前恒等于16/0x10，0x00
  PackSize      db 0x10
  ;保留字节，恒等于0，0x01
  Reserved      db 0
  ;要读取的数据块个数，0x02
  BlockCount    dw 0
  ;目标内存地址的偏移，0x04
  BufferOffset  dw 0
  ;目标内存地址的段，让它等于0，0x06
  BufferSegment dw 0
  ;磁盘起始绝对地址，扇区为单位，这是低字节部分，0x08
  BlockLow      dd 0
  ;这是高字节部分，0x0c
  BlockHigh     dd 0
;CursorNow dw 0
FlagsTip:
  flagtip db 'EFLAGS: '
  cf db 'cf '
     db 'CF '
  pf db 'pf '
     db 'PF ' 
  af db 'af '
     db 'AF '
  zf db 'zf '
     db 'ZF '
  sf db 'sf '
     db 'SF '
  tf db 'tf '
     db 'TF '
  if db 'if '
     db 'IF '
  df db 'df '
     db 'DF '
  of db 'of '
     db 'OF '
CPUIDResult:
  teax db 'EAX: 0x';0x00
  reax dd 0 ;0x07
       db '  ';0x11
  tebx db 'EBX: 0x'
  rebx dd 0
       db '  '
  tecx db 'ECX: 0x'
  recx dd 0
       db '  '
  tedx db 'EDX: 0x'
  redx dd 0
       db 0x0d, 0x0a


