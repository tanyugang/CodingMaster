;***********************************************
;代码作者：谭玉刚
;教程链接：
;https://www.bilibili.com/video/BV1Lp4y1h7vg/
;https://www.youtube.com/watch?v=wbeLHALXRPw
;不要错过：
;B站/微信/油管/头条/知乎/大鱼/企鹅：谭玉刚
;百度/微博：玉刚谈
;来聊天呀：1054728152（QQ群）
;***********************************************
NUL equ 0x00
SETCHAR equ 0x07
VIDEOMEM equ 0xb800
STRINGLEN equ 0xffff
section code align=16 vstart=0x7c00
  mov si, SayHello
  xor di, di
  call PrintString
  mov si, SayByeBye
  call PrintString
  jmp End
PrintString:
  .setup:
  mov ax, VIDEOMEM
  mov es, ax

  mov bh, SETCHAR
  mov cx, STRINGLEN

  .printchar:
  mov bl, [ds:si]
  inc si
  mov [es:di], bl
  inc di
  mov [es:di], bh
  inc di
  or bl, NUL
  jz .return
  loop .printchar
  .return:
  ret

SayHello db 'Hi there,I am Coding Master!'
         db 0x00
SayByeBye db 'I think you can handle it,bye!'
          db 0x00

End: jmp End
times 510-($-$$) db 0
                 db 0x55, 0xaa    