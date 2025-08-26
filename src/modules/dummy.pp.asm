; dummy.asm - Dummy kernel module for testing
[org 0x1000]
[bits 16]

moduleEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print debug char
  mov ah, 0x0E
  mov al, "^"
  int 0x10

  pop ds
  popa
  retf

; Pad to 1 sector
times 512 - ($ - $$) db 0
