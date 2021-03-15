HDDPORT equ 0x1f0
section code align=16 vstart=0x7c00
  mov si, [READSTART]
  mov cx, [READSTART+2]
  mov al, [SECTORNUM]
  push ax
  ;Setup the destnation
  mov ax, [DESTMEN]
  mov dx, [DESTMEN+0x02]
  mov bx, 16
  div bx
  
  mov ds, ax
  xor di, di
  pop ax
  ;read the first sector
  call ReadHDD

  ResetSegment:
  mov bx, 0x04
  mov cl, [0x10]

  .reset:
  mov ax, [bx]
  mov dx, [bx+2]
  add ax, [cs:DESTMEN]
  adc dx, [cs:DESTMEN+2]

  mov si, 16
  div si
  mov [bx], ax
  add bx, 4
  loop .reset

  ResetEntry:
  mov ax, [0x13]
  mov dx, [0x15]
  add ax, [cs:DESTMEN]
  adc dx, [cs:DESTMEN+2]

  mov si, 16
  div si

  mov [0x13], ax

  jmp far [0x11]
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
  ;or ah, 0x00
  ;jnz .readword
  loop .readword
  .return:
  pop dx
  pop cx
  pop bx
  pop ax

  ret

READSTART dd 1
SECTORNUM db 1
DESTMEN   dd 0x10000

End: jmp End
times 510-($-$$) db 0
                 db 0x55, 0xaa