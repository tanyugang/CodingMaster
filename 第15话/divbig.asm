;被除数0x00090006
mov dx, 0x0009
mov ax, 0x0006
;除数0x0002
mov cx, 0x0002
push ax
mov ax, dx
mov dx, 0
;第一次除法，高位
div cx
mov bx, ax
;第二次除法，低位
pop ax
div cx

jmp $
times 510-($-$$) db 0
db 0x55, 0xaa