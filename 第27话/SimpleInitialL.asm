section Initial align=16 vstart=0x9000
mov si, InitialLandHere
call PrintString
jmp InitialEnd
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
InitialEnd:
  hlt
InitialLandHere db 'I come from Initial.bin!'
                db 0x0d, 0x0a