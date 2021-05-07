section Initial align=16 vstart=0x9000
;你已经成功了一大半了
InitialStart:
  mov di, InitialLanded
  call PrintString

EnterProtectMode:
  ;禁用中断先
  DisableInterrupt:
    cli
    call CheckPoint
  SetupGDTDesc:
    mov ax, GDTEnd
    sub ax, GDTStart
    sub ax, 1
    ;GDT Limits
    mov [GDTStart], ax
    ;GDT Base
    mov ax, GDTStart
    mov [GDTStart+2], ax
    call CheckPoint
  ;加载临时GDT
  LoadGDT:
    lgdt [GDTStart]
    call CheckPoint
  %define SEC_DEFAULT_CR0  0x40000023
  %define SEC_DEFAULT_CR4  0x640

  EnableProtectBit:
    call CheckPoint
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
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  jmp $

;
; Macros for GDT entries
;

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
;数据段描述符
DataDescriptor equ $-GDTStart
  dw 0xffff ; 段界限，Limits 00
  dw 0 ; base:15~0 02
  db 0 ; base:23~16 04
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
LongModeCheck:
  mov eax, 0x80000000
  cpuid
  call PrintGeneralRegister
  ;cmp eax, 0x80000008
  ;sub eax, 0x80000000
  ;call PrintGeneralRegister
  ;mov eax, 0x80000008
  cmp eax, 0x80000000
  ;jbe LongModeNotSupport
  mov eax, 0x80000001
  cpuid
  call PrintGeneralRegister
  bt  ebx, 29
  jnc LongModeNotSupport

LongModeSupported:
  mov di, YesLongMode
  call PrintString
LongModeNotSupport:
  mov di, NoLongMode
  call PrintString
;打印寄存器数据
;eax/ebx/ecx/edx
;esi/edi/esp/ebp/eip/
;cs/ds/es/ss/gs/fs
PrintAllRegister:
  mov di, PrintGeneral
  call PrintString
  call PrintGeneralRegister
  mov di, PrintSegment
  call PrintString
  call PrintSegmentRegister
  ret
;打印通过寄存器
PrintGeneralRegister:
  call SaveRegisterToBuffer
  mov cx, 8
  mov bx, GeneralRegister
  StartPrintGeneralRegister:
    call PrintOneGeneralRegister
    add bx, 8
    loop StartPrintGeneralRegister
  ret
;按照固定格式打印一个通用寄存器  
PrintOneGeneralRegister:
  push bx
  push cx
  push di
  mov cx, 4
  GPrintPreffix:
    mov al, [bx]
    call PrintByteAscii
    inc bx
    loop GPrintPreffix
  mov cx, 4
  add bx, 3
  GPrintRegister:
    mov al, [bx]
    call PrintByteHex
    dec bx
    loop GPrintRegister
  mov cx, 2
  mov di, Suffix
  GPrintSuffix:
    mov al, [di]
    call PrintByteAscii
    inc di
    loop GPrintSuffix
  pop di
  pop cx
  pop bx
  ret
;打印段寄存器
PrintSegmentRegister:
  call SaveRegisterToBuffer
  mov cx, 6
  mov bx, SegmentRegister
  StartPrintSegmentRegister:
    call PrintOneSegmentRegister
    add bx, 5
    loop StartPrintSegmentRegister
  ret
PrintOneSegmentRegister:
  push bx
  push cx
  push di
  mov cx, 3
  SPrintPreffix:
    mov al, [bx]
    call PrintByteAscii
    inc bx
    loop SPrintPreffix
  mov cx, 2
  add bx, 1
  SPrintRegister:
    mov al, [bx]
    call PrintByteHex
    dec bx
    loop SPrintRegister
  mov cx, 2
  mov di, Suffix
  SPrintSuffix:
    mov al, [di]
    call PrintByteAscii
    inc di
    loop SPrintSuffix
  pop di
  pop cx
  pop bx
  ret
;保存所有寄存器到RegisterBuffer
SaveRegisterToBuffer:
  mov [geax], eax
  mov [gebx], ebx
  mov [gecx], ecx
  mov [gedx], edx
  mov [gesi], esi
  mov [gedi], edi
  mov [gesp], esp
  mov [gebp], ebp
  mov [scs], cs
  mov [sds], ds
  mov [ses], es
  mov [sss], ss
  mov [sfs], fs
  mov [sgs], gs
  ret

PrintByteHex:
  push ax
  shr al, 4
  call PrintHex
  pop ax
  and al, 0x0f
  call PrintHex
  ret
;打印一个值的Hex
;入参为al
PrintHex:
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
  ret
;打印一个普通字符，入参为al
PrintByteAscii:
  push ax
  mov ah, 0x0e
  int 0x10
  pop ax
  ret
CheckPoint:
  push di
  mov di, CheckByte
  call PrintString
  add byte [CheckNumber], 1
  pop di
  ret
;函数定义区，只能用在实模式下
;入参为di，0x0a结尾
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

InitialLanded db 'You are successfully entry Initial.bin, have some fun!'
              db 0x0d, 0x0a
NoLongMode    db 'Long Mode is not support on this computer.'
              db 0x0d, 0x0a
YesLongMode   db 'Long Mode is supported on this computer.'
ThingsAreGood db 'So far so good.'
              db 0x0d, 0x0a
PrintGeneral  db 'The 8 GPR are here:'
              db 0x0d, 0x0a
PrintSegment  db 'The 6 SEG are here:'
              db 0x0d, 0x0a
RegisterBuffer:
  GeneralRegister:
    db 'eax:'
    geax dd 0
    db 'ebx:'
    gebx dd 0
    db 'ecx:'
    gecx dd 0
    db 'edx:'
    gedx dd 0
    db 'esi:'
    gesi dd 0
    db 'edi:'
    gedi dd 0
    db 'esp:'
    gesp dd 0
    db 'ebp:'
    gebp dd 0
  SegmentRegister:
    db 'cs:'
    scs dw 0
    db 'ds:'
    sds dw 0
    db 'es:'
    ses dw 0
    db 'ss:'
    sss dw 0
    db 'fs:'
    sfs dw 0
    db 'gs:'
    sgs dw 0
Suffix:
    db 0x0d, 0x0a

CheckByte:
  db 'Num. '
  CheckNumber  db 0x30
  db ' Check Point is OK'
  db 0x0d, 0x0a
