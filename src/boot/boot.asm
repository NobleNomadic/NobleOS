; boot.asm - Initial bootloader
ORG 0x7C00
BITS 16

%define STREND 0x0D, 0x0A, 0x00

; Entry
bootEntry:
  ; Setup segment
  push cs    ; Push segment to stack
  pop ax     ; Move segment into AX
  mov ds, ax ; Setup segment registers with AX value
  mov es, ax

  ; Capture DL - contains boot drive
  mov [bootDrive], dl

  ; Clear video memory
  mov ah, 0x00
  mov al, 0x03
  int 0x10

; Backup hang function
hang:
  jmp $

bootDrive db 0

; ==== UTILITY FUNCTIONS ====
; Print string: print a string in SI with null terminator
printString:
  push ax         ; Preserve registers
  push si
.printLoop:       
  lodsb           ; Load next byte from SI -> AL
  or al, al       ; Check for null terminator
  jz .done        ; Finish if null
  mov ah, 0x0E    ; Setup BIOS tty print
  int 0x10        ; Call interrupt to print
  jmp .printLoop  ; Continue loop
.done:
  pop si          ; Return registers and return to caller
  pop ax
  ret

; Load kernel: Read filesystem entry and find kernel
loadKernel:
  pusha

; Clean up registers and return
.done:
  popa
  ret

bootEntryString db "[*] Bootable device found", STREND

; ==== BOOT SIGNATURE ====
times 510 - ($ - $$) db 0
dw 0xAA55
