; disk.asm - Driver to read and write files from disk
ORG 0x0000
BITS 16

driverEntry:
  pusha

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print debug char
  mov ah, 0x0E
  mov al, "D"
  int 0x10

  popa
  retf
