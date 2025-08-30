; shell.asm - Command line program for running other programs
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry function
shellEntry:
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Key driver needs to be loaded for shell to function
  mov ah, 0x01 ; Syscall 1 for kernel load module
  mov cx, 11   ; Read from sector 11
  mov dh, 0x01 ; Slot 1 for hardware driver
  int 0x60     ; Call kernel interrupt

  jmp shellLoop

; Main shell loop
shellLoop
  ; Print shell prompt
  mov si, shellPrompt
  call printString

  ; Use keyboard driver to get input
  mov si, inputBuffer ; Buffer to get input into
  mov ah, 0x01        ; Keyboard driver call 1, get input
  mov bx, 16          ; Max length 16 chars
  int 0x61            ; Hardware driver interrupt

  jmp shellLoop       ; Continue loop

; Backup hang
hang:
  jmp $

; ==== UTILITY FUNCTIONS ====
; Print string currently in SI
printString:
  push ax        ; Preserve registers
  push si
.printLoop:
  lodsb          ; Load next byte from SI into AL
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Setup BIOS tty print
  int 0x10       ; Call BIOS interrupt
  jmp .printLoop ; Continue loop
.done:
  ; Restore registers and return
  pop si
  pop ax
  ret



; DATA SECTION
shellPrompt db "[>]", STREND ; Prompt before getting input

; Buffer for getting string input
inputBuffer times 20 db 0

; Pad to 1 sector
times 512 - ($ - $$) db 0
