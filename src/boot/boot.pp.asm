; boot.asm - Initial bootloader
[org 0x7C00]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry function
bootEntry:
  ; Setup segment
  xor ax, ax
  mov ds, ax
  mov es, ax

  ; Clear screen by resetting BIOS video mode
  mov ah, 0x00
  mov al, 0x03
  int 0x10

  ; Print entry message
  mov si, bootEntryMessage
  call printString

  ; Load the kernel and give it control
  ; LOAD_kernel
  mov cx, 2
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x1000
  mov es, ax
  mov ah, 0x02
  mov al, 6
  int 0x13
  ; JUMP_kernel
  jmp 0x1000:0x0000

; Backup hang function
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
bootEntryMessage db "[*] Bootable device found", STREND

; Pad to 1 sector with boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
