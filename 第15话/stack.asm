;设置ss寄存器
mov bx, 0x0000
mov ss, bx
;设置sp寄存器
mov sp, 0x0000
;ax压入栈
push ax
;ax弹出栈
pop ax
;循环及补0
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa