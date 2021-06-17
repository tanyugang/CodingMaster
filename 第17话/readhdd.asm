HDDPORT equ 0x1f0
NUL equ 0x00
SETCHAR equ 0x07
VIDEOMEM equ 0xb800
STRINGLEN equ 0xffff
section code align=16 vstart=0x7c00

mov si, [READSTART]
mov cx, [READSTART+0x02]
mov al, [SECTORNUM]
push ax

mov ax, [DESTMEN]
mov dx, [DESTMEN+0x02]
mov bx, 16
div bx

mov ds, ax
xor di, di
pop ax

call ReadHDD
xor si, si
call PrintString
jmp End

ReadHDD:
  push ax
  push bx
  push cx
  push dx

  mov dx, HDDPORT+2
  out dx, al

  mov dx, HDDPORT+3
  mov ax, si
  out dx, al

  mov dx, HDDPORT+4
  mov al, ah
  out dx, al

  mov dx, HDDPORT+5
  mov ax, cx
  out dx, al

  mov dx, HDDPORT+6
  mov al, ah
  mov ah, 0xe0
  or al, ah
  out dx, al

  mov dx, HDDPORT+7
  mov al, 0x20
  out dx, al

  .waits:
  in al, dx
  and al, 0x88
  cmp al, 0x08
  jnz .waits

  mov dx, HDDPORT
  mov cx, 256

  .readword:
  in ax, dx
  mov [ds:di], ax
  add di, 2
  or ah, 0x00
  jnz .readword

  .return:
  pop dx
  pop cx
  pop bx
  pop ax

  ret

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
  
READSTART dd 10
SECTORNUM db 1
DESTMEN   dd 0x10000

End: jmp End
times 510-($-$$) db 0
                 db 0x55, 0xaa