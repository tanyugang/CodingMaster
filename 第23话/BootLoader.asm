section Initial align=16 vstart=0x7c00
;跳过数据定义区转到代码部分开始执行
JumpToTheCode:
  jmp ZeroTheSegmentRegister
;定义程序所需的数据结构
FatStructure:
  SectorSize     dw 0x0000 ;每扇区字节数
  ClusterSize    db 0x00 ;每簇扇区数
  ReservedSector dw 0x0000 ;保留扇区数，是从Fat开始到数据区之前的部分
  FatNumber      db 0x00 ;Fat个数
  HiddenSector   dd 0x00000000 ;分区之前隐藏的扇区数
  FatSize        dd 0x00000000 ;每个Fat的扇区数
  FatOneBase     dd 0x00000000 ;Fat1的起始地址
  DataAreaBase   dd 0x00000000
ImportantTips:
  PartitionFound    db 'PART GET!'
                    db 0x0d, 0x0a
  InitialFound      db 'BIN GET!'
                    db 0x0d, 0x0a
  InitialLost     db 'No BIN!'
                    db 0x0d, 0x0a

;程序开始前的设置，先把段寄存器都置为0，后续所有地址都是相对0x00000的便宜
ZeroTheSegmentRegister:
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
;栈空间位于0x7c00及往前的空间，栈顶在0x7c00
SetupTheStackPointer:
  mov sp, 0x7c00
;寻找MBR分区表中的活动分区，看分区项第一个字节是否为0x80，最多4个分区项
SeekTheActivePartition:
;分区表位于0x7c00+446=0x7c00+0x1be=0x7dbe的位置，使用si作为基地址
  mov si, 0x7dbe
  mov cx, 4
  isActivePartition:
    mov bl, [si]
    cmp bl, 0x80 
    ;如果是则说明找到了，使用jmp if equel指令跳转继续
    je ActivePartiionFound
    ;如果没找到，则继续寻找下一个分区项，si+16
    add si, 16
    loop isActivePartition
;找到活动分区后，si目前就是活动分区项的首地址
ActivePartiionFound:
  push di
  mov di, PartitionFound
  call PrintString
  pop di
  ;定位到分区起始扇区的位置，即si+8开始的共4个字节
  ;接下来开始读取这个起始扇区，并保存到0x7e00开始的内存
  ;我们会采用LBA28的方式读取，通过in/out指令读写端口
  ;起始扇区号保存到ebx，作为ReadSector的入参
  mov ebx, [si+8]
  ;读取后保存的内存位置，也是ReadSector的入参
  mov di, 0x7e00
  ;设置读取扇区数，目前只需要读1个扇区，保存到al
  mov al, 1
  ;调用读取扇区函数
  call ReadSector
;获取FAT32文件系统的相关信息
GetTheFatInfo:
  ;每扇区字节数
  mov ax, [di+0x0b]
  mov [SectorSize], ax
  ;每扇区簇数
  mov al, [di+0x0d]
  mov [ClusterSize], al
  ;保留扇区数
  mov ax, [di+0x0e]
  mov [ReservedSector], ax
  ;Fat个数
  mov al, [di+0x10]
  mov [FatNumber], al
  ;隐藏扇区数
  mov eax, [di+0x1c]
  mov [HiddenSector], eax
  ;每个Fat的扇区数
  mov eax, [di+0x24]
  mov [FatSize], eax
;获取第一个Fat的相关信息
GetFatOneInfo:
  ;获取FatOne起始扇区号，为隐藏扇区+保留扇区
  mov eax, [HiddenSector]
  mov bx, [ReservedSector]
  and ebx, 0x0000ffff
  add eax, ebx
  mov [FatOneBase], eax
;获取数据区的起始扇区号，数据区位于Fat表之后
;等于FatOneBase+FatSize*FatNumber
;这里我们用加法代替乘法，速度快代码简单
GetDataAreaBase:
  xor cx, cx
  mov cl, [FatNumber]
  AddFatSize:
    add eax, [FatSize]
    loop AddFatSize
  mov [DataAreaBase], eax
;寻找Initial.bin文件，它位于根目录下
;而根目录就在DataAreaBase第一个扇区
;根目录的尺寸刚开始是一个簇，也就是8个扇区
;其簇号为2，那么我们需要循环8次
;根目录起始扇区号=DataAreaBase+(起始簇号-2)*每簇扇区数  
ReadTheRootDirectory:
  ;设置起始的扇区号
  mov ebx, eax
  ;设置读取的扇区数
  mov al, 8
  ;设置读取的目标内存地址，读8个扇区会占掉0x1000个字节
  mov di, 0x8000
  call ReadSector
;寻找Initial.bin，以32字节为单位，看文件名
SeekTheInitialBin:
  cmp byte [di], 'I'
  jne nextFile
  cmp byte [di+1], 'N'
  jne nextFile
  cmp byte [di+2], 'I'
  jne nextFile
  cmp byte [di+3], 'T'
  jne nextFile
  cmp byte [di+4], 'I'
  jne nextFile
  cmp byte [di+5], 'A'
  jne nextFile
  cmp byte [di+6], 'L'
  jne nextFile
  cmp byte [di+7], ' '
  jne nextFile
  cmp byte [di+8], 'B'
  jne nextFile
  cmp byte [di+9], 'I'
  jne nextFile
  cmp byte [di+10], 'N'
  jne nextFile
  ;如果以上都匹配到了，说明找到了文件，跳转粗去执行
  jmp InitialBinFound
  nextFile:
    ;看看是否已经超出了界限
    cmp di, 0x9000
    ;超界了就跳粗去，表示文件找不到
    ja InitialBinNotFound
    add di, 32
    jmp SeekTheInitialBin

;Initial.bin找到了，那就去读它的数据
InitialBinFound:
  push di
  mov di, InitialFound
  call PrintString
  pop di
  ;此处凸显了16位的限制，做个除法还得2个寄存器
  ;获取文件长度
  mov ax, [di+0x1c]
  mov dx, [di+0x1e]
  ;文件长度是字节为单位的，需要先除以512得到扇区数
  mov bx, 512
  div bx
  mov cx, ax
  ;如果余数不为0，则需要多读一个扇区
  cmp dx, 0
  je NoRemainder
  ;cx保存就是文件所占扇区数，其实我们的Initial不会超过4KB
  ;所以读取的时候只会读取cl个扇区
  inc cx
  NoRemainder:
    ;文件起始簇号，也是转为扇区号，乘以8即可
    mov ax, [di+0x1a]
    sub ax, 2
    mov bx, 8
    mul bx
    ;现在文件起始扇区号存在dx:ax，直接保存到ebx，这个起始是相对于DataBase 0x32,72
    ;所以待会计算真正的起始扇区号还需要加上DataBase
    mov bx, dx
    shl ebx, 16
    mov bx, ax
    and ebx, 0x0000ffff
  GetFileStart: 
    mov eax, [DataAreaBase]
    add ebx, eax
    mov al, cl
    mov di, 0x9000
    call ReadSector
    ;跳转到Initial.bin继续执行
    jmp di

InitialBinNotFound:
  mov di, InitialLost
  call PrintString
  hlt
PrintString:
  mov cx, 512
  PrintChar:
    mov al, [di]
    mov ah, 0x0e
    int 0x10
    cmp byte [di], 0x0a
    je Return
    inc di
    loop PrintChar
  Return:
    ret
;读取一个扇区函数，入参为
;ebx:要读取的扇区起始位置
;di:读取内容保存的内存位置
;al:读取的扇区数
;修改的寄存器：ax,ebx,cx,dx,di
ReadSector:
  push ax
  push ebx
  push cx
  push dx
  push di
  mov dx, 0x1f2

  out dx, al
  ;写入第0~7位，因为是小端字节序，所以低字节在后面
  mov dx, 0x1f3
  mov al, bl
  out dx, al
  ;写入第15~8位
  mov dx, 0x1f4
  mov al, bh
  out dx, al
  ;写入第23~16位
  shr ebx, 16
  mov dx, 0x1f5
  mov al, bl
  out dx, al
  ;写入第27~24位以及参数
  mov dx, 0x1f6
  mov al, bh
  mov ah, 0xe0
  or al, ah
  out dx, al
  ;写入0x20表示读硬盘
  mov dx, 0x1f7
  mov al, 0x20
  out dx, al
  ;从0x1f7读取状态
  Waits:
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz Waits
    ;等待结束开始读数据

  ;因为一次读1个字，也就是2个字节，1个扇区512字节，所以读256次 
  mov cx, 256
  mul cx
  mov cx, ax
  mov dx, 0x1f0
  ;循环读取
  readWord:
    in ax, dx
    mov [di], ax
    add di, 2
    loop readWord
  pop di
  pop dx
  pop cx
  pop ebx
  pop ax
  ret

  times 446-($-$$) db 0