;***********************************************
;代码作者：谭玉刚
;教程链接：
;https://www.bilibili.com/video/BV1Kz4y1U7Mj/
;https://www.youtube.com/watch?v=EJgdGTAixVg&t=5s
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
mov ax, 0x7c00
mov ds, ax
mov bx, 0x353637
mov byte [0xf1], 'H'
mov byte [0xf2], 0x3839
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa