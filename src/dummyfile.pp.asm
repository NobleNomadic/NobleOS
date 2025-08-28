; dummyfile.asm - Test file for filesystem debugging
[org 0x2000]
[bits 16]

; Header file filesystem (DUMB in hex codes)
filename db "DUMB"

; Entry
fileEntry:
  pusha
  push ds

  mov ah, 0x0E
  mov al, "*"
  int 0x10

  ; Return to caller
  pop ds
  popa
  retf
