;***********************************************
;代码作者：谭玉刚
;教程链接：
;https://www.bilibili.com/video/BV1AT4y1N71D/
;https://www.youtube.com/watch?v=Ar-q-k6KZJg
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
mov 0xb700, 0xb800
mov [0x01], 0xb800
mov byte [0x01], 0xb800
mov word [0x01], 0xb800
mov [0x01], [0x02]
mov ax, [0x02]
mov [0x03], ax
mov ds, [0x05]
mov [0x04], ds
mov ax, bx
mov cx, dl
mov cs, ds