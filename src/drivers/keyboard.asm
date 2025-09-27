; keyboard.asm - Keyboard driver
ORG 0x2000
BITS 16

driverEntry:
  pusha

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print debug char
  mov ah, 0x0E
  mov al, "K"
  int 0x10

  popa
  retf
