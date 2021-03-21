;***********************************************
;代码作者：谭玉刚
;教程链接：
;https://www.bilibili.com/video/BV1dh411D7nV/
;https://www.youtube.com/watch?v=lq6DSk3QoAU
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
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