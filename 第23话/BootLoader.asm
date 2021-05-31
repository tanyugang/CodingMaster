;只有一个段，从0x7c00开始
section Initial vstart=0x7c00
;程序开始前的设置，先把段寄存器都置为0，后续所有地址都是相对0x00000的偏移
ZeroTheSegmentRegister:
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
;栈空间位于0x7c00及往前的空间，栈顶在0x7c00
SetupTheStackPointer:
  mov sp, 0x7c00
Start:
  mov si, BootLoaderStart
  call PrintString
;查看是否支持拓展int 13h
CheckInt13:
  mov ah, 0x41
  mov bx, 0x55aa
  mov dl, 0x80
  int 0x13
  cmp bx, 0xaa55
  mov byte [ShitHappens+0x06], 0x31
  jnz BootLoaderEnd
;寻找MBR分区表中的活动分区，看分区项第一个字节是否为0x80，最多4个分区
SeekTheActivePartition:
  ;分区表位于0x7c00+446=0x7c00+0x1be=0x7dbe的位置，使用di作为基地址
  mov di, 0x7dbe
  mov cx, 4
  isActivePartition:
    mov bl, [di]
    cmp bl, 0x80 
    ;如果是则说明找到了，使用jmp if equel指令跳转继续
    je ActivePartitionFound
    ;如果没找到，则继续寻找下一个分区项，si+16
    add di, 16
    loop isActivePartition
  ActivePartitionNotFound:
    mov byte [ShitHappens+0x06], 0x32
    jmp BootLoaderEnd
;找到活动分区后，di目前就是活动分区项的首地址
ActivePartitionFound:
  mov si, PartitionFound
  call PrintString
  ;ebx保存活动分区的起始地址
  mov ebx, [di+8]
  mov dword [BlockLow], ebx
  ;目标内存起始地址
  mov word [BufferOffset], 0x7e00
  mov byte [BlockCount], 1
  ;读取第一个扇区
  call ReadDisk
GetFirstFat:
  mov di, 0x7e00
  ;ebx目前为保留扇区数
  xor ebx, ebx
  mov bx, [di+0x0e]
  ;FirstFat起始扇区号=隐藏扇区+保留扇区
  mov eax, [di+0x1c]
  add ebx, eax
;获取数据区起始区扇区号
GetDataAreaBase:
  mov eax, [di+0x24]
  xor cx, cx
  mov cl, [di+0x10]
  AddFatSize:
    add ebx, eax
    loop AddFatSize
;读取数据区8个扇区/1个簇
ReadRootDirectory:
  mov [BlockLow], ebx
  mov word [BufferOffset], 0x8000
  mov di, 0x8000
  mov byte [BlockCount], 8
  call ReadDisk
  mov byte [ShitHappens+0x06], 0x34
SeekTheInitialBin:
  cmp dword [di], 'INIT'
  jne nextFile
  cmp dword [di+4], 'IAL '
  jne nextFile
  cmp dword [di+8], 'BIN '
  jne nextFile
  jmp InitialBinFound
  nextFile:
    cmp di, 0x9000
    ja BootLoaderEnd
    add di, 32
    jmp SeekTheInitialBin

InitialBinFound:
  mov si, InitialFound
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
    mov ax, [di+0x1a]
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
    call ReadDisk
    ;跳转到Initial.bin继续执行
    mov si, GotoInitial
    call PrintString
    jmp di
ReadDisk:
  mov ah, 0x42
  mov dl, 0x80
  mov si, DiskAddressPacket
  int 0x13
  test ah, ah
  mov byte [ShitHappens+0x06], 0x33
  jnz BootLoaderEnd
  ret

;打印以0x0a结尾的字符串
PrintString:
  push ax
  push cx
  push si
  mov cx, 512
  PrintChar:
    mov al, [si]
    mov ah, 0x0e
    int 0x10
    cmp byte [si], 0x0a
    je Return
    inc si
    loop PrintChar
  Return:
    pop si
    pop cx
    pop ax
    ret

BootLoaderEnd:
  mov si, ShitHappens
  call PrintString
  hlt
;使用拓展int 13h读取硬盘的结构体DAP
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
ImportantTips:
  
  BootLoaderStart   db 'Start Booting!'
                    db 0x0d, 0x0a
  PartitionFound    db 'Get Partition!'
                    db 0x0d, 0x0a
  InitialFound      db 'Get Initial!'
                    db 0x0d, 0x0a
  GotoInitial       db 'Go to Initial!'
                    db 0x0d, 0x0a
  ShitHappens       db 'Error 0, Shit happens, check your code!'
                    db 0x0d, 0x0a
;结束为止
  times 446-($-$$) db 0

  
