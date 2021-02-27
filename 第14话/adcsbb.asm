;bx:ax=0x0001f000
mov bx, 0x0001
mov ax, 0xf000
;dx:cx=0x00101000
mov dx, 0x0010
mov cx, 0x1000
;低位相加
add ax, cx
;高位相加
adc bx, dx
;和应该在bx:ax=0x00120000
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa