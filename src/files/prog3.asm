; prog3.asm - Simple game, third program, fifth file
ORG 0x0000
BITS 16

; Entry function
entry:
  pusha
  
  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

; Common return point
.done:
  popa
  retf
