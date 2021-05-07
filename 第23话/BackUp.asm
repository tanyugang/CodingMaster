LongModeCheck:
  mov eax, 0x80000000
  cpuid
LongModeNotSupport:
mov di, NoLongMode
call PrintString
;jbe LongModeNotSupport
;准备进入32位保护模式
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
    jmp dword ProtectModeLand
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
EnterLongMode:

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