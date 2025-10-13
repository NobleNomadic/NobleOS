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

; Main repeating shell loop
shellLoop:
  ; Print prompt using video services
  mov si, shellPrompt ; String to print
  mov ah, 0x01        ; Syscall 1 - print string
  int 0x81            ; Screen services

  ; Get string of input
  mov si, inputBuffer ; Target buffer for input
  mov ah, 0x01        ; Keyboard syscall 1 - get string
  mov al, 32          ; Max chars for input
  int 0x82            ; Call keyboard services

  ; Continue loop
  jmp shellLoop

; Backup hang
hang:
  jmp $

; ==== DATA SECTION ===
; Shell prompt
shellPrompt db "# ", 0

; Buffer for getting input, 32 chars + null
inputBuffer times 33 db 0

; Pad to 1 sector
times 512 - ($ - $$) db 0
