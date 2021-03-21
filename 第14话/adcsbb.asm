;***********************************************
;代码作者：谭玉刚
;教程链接：
;https://www.bilibili.com/video/BV1py4y1a7C1/
;https://www.youtube.com/watch?v=UjKnA1EhVco
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
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