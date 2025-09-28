; boot.asm - Initial bootloader
ORG 0x7C00
BITS 16

%define STREND 0x0D, 0x0A, 0x00

; Entry
bootEntry:
  ; Setup segment
  xor ax, ax ; Segment 0x0000
  mov ds, ax
  mov es, ax

  ; Reset video to clear screen
  mov ah, 0x00
  mov al, 0x03
  int 0x10     ; BIOS video services

  ; Print entry message
  mov si, bootEntryMessage
  call printString

  call loadKernel

; Backup hang function
hang:
  jmp $

; ==== UTILITY FUNCTIONS ====
; Print string in SI to screen
printString:
  push ax        ; Preserve registers
  push si
.printLoop:
  lodsb          ; Load next byte into AL
  or al, al      ; Check for null terminator in current byte
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Setup BIOS tty print
  int 0x10       ; Call interrupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Return registers and return
  pop ax
  ret

; Load kernel into memory
loadKernel:
  pusha

  push cx
  ; Use BIOS int 0x13 to load from disk
  ; Memory args
  mov ax, 0x1000 ; Segment to load data into
  mov es, ax
  mov bx, 0x0000 ; Offset
  ; Disk args
  mov al, 4      ; Read 4 sectors
  mov dl, 0x00   ; Read from first floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 2      ; Second sector

  ; Call BIOS
  mov ah, 0x02
  int 0x13

  ; Check for errors by running error function if carry flag set
  jc .diskReadError
  jmp .done

.diskReadError:
  mov si, kernelLoadFailMessage
  call printString
  jmp hang

; Finish and return to caller
.done:
  popa
  ret

; ==== DATA SECTION ====
bootEntryMessage db "[*] NobleOS booting", STREND
kernelLoadFailMessage db "[!] Bootloader failed to load kernel", STREND

; Pad and give boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
