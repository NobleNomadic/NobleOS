; kernel.asm - Main OS controller
ORG 0x0000
BITS 16

kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print debug char
  mov ah, 0x0E
  mov al, '!'
  int 0x10

; Backup hang
hang:
  jmp $


; Pad to 4 sectors
times 2048 - ($ - $$) db 0
