; keydriver.asm - Keybord driver for getting input
[org 0x1000] ; Hardware drivers load at offset 1000
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; If the module entry function runs, then install interrupt and return
driverEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Install interrupts
  call installInterrupts

  mov si, keyboardDriverEntryMessage
  call printString

  ; Return across segment to caller
  pop ds
  popa
  retf


; ==== INTERRUPT CATCH ====
; Code is run on int 0x61 to call current hardware driver
int0x61Handler:
  pusha
  sti

  ; Check for get string of input syscall
  cmp ah, 0x01
  je .getInput

  ; No valid syscall, jump straight to finish
  jmp .done

.getInput:
  mov ah, 0x0E
  mov al, "L"
  int 0x10
  jmp .done

.done:
  ; Return register state and return to caller
  popa
  iret

; ==== INSTALL INTERRUPTS ====
installInterrupts:
  push ax
  push ds
  cli
  xor ax, ax
  mov ds, ax
  mov word [0x61*4], int0x61Handler
  mov word [0x61*4 + 2], cs
  pop ds
  sti
  pop ax
  ret

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
keyboardDriverEntryMessage db "[+] Keyboard driver setup", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
