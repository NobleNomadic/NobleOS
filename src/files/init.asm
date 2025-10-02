; init.asm - Initital program loaded by kernel to start userspace
ORG 0x0000

entry:
  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

  ; Print char
  mov ah, 0x0E
  mov al, "*"
  int 0x10

; Backup hang
hang:
  jmp $

; Pad to 1 sector
times 512 - ($ - $$) db 0
