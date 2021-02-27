;设定循环次数
mov cx, 100
;初始化ax
mov ax, 0x0000
;循环部分
sum:
    add ax, cx
    loop sum

jmp $
times 510-($-$$) db 0
db 0x55, 0xaa