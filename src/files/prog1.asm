; prog1.asm - Basic shell loaded by init system after login
ORG 0x2000 ; Most files load at 0ffset 0x2000
BITS 16

; Entry
programEntry:
  ; Setup segment registers
  push cs
  pop ax
  mov ds, ax
  mov es, ax

; Backup hang
hang:
  jmp $

; ==== DATA SECTION ===
; Pad to 1 sector
times 512 - ($ - $$) db 0
