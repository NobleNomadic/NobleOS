; test.asm - Sample driver to load into 0x2000:0x0000
ORG 0x0000
BITS 16

driverEntry:
  pusha

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print char
  mov ah, 0x0E
  mov al, ":"
  int 0x10

  popa
  retf
