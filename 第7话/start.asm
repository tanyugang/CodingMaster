;***********************************************
;代码作者：谭玉刚
;教程链接：
;https://www.bilibili.com/video/BV1s5411n7Tr/
;https://www.youtube.com/watch?v=YGdjmX-ZgDQ
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
mov ax, 0b800h
mov ds, ax

mov byte [0x00],'2'
mov byte [0x02],'0'
mov byte [0x04],'2'
mov byte [0x06],'1'
mov byte [0x08],'，'
mov byte [0x0a],'H'
mov byte [0x0c],'a'
mov byte [0x0e],'p'
mov byte [0x10],'p'
mov byte [0x12],'y'
mov byte [0x14],' '
mov byte [0x16],'N'
mov byte [0x18],'i'
mov byte [0x1a],'u'
mov byte [0x1c],' '
mov byte [0x1e],'Y'
mov byte [0x20],'e'
mov byte [0x22],'a'
mov byte [0x24],'r'
mov byte [0x26],'!'

jmp $

times 510-($-$$) db 0
db 0x55,0xaa






