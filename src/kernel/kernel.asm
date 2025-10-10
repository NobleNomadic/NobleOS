; kernel.asm - Main OS controller
ORG 0x0000
BITS 16

%define STREND 0x0D, 0x0A, 0x00

kernelEntry:
  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

  ; Print entry message
  mov si, kernelEntryMessage
  call printString

  ; Load drivers
  call loadDrivers

  ; Initialize drivers by calling them and letting them install interrupts
  call 0x2000:0x0000  ; Call screen driver
  call 0x2000:0x2000  ; Call keyboard driver
  call 0x2000:0x4000  ; Call disk driver

  ; Reset kernel segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Load userspace init program
  ; Setup memory target
  mov ax, 0x3000 ; Segment 0x3000 for userspace segment
  mov es, ax
  mov bx, 0x0000 ; Offset 0x0000, start of userspace
  ; Syscall args
  mov al, 0x01   ; First file, init program
  mov ah, 0x01   ; Sysclall 1, read file
  ; Call disk services
  int 0x83

  ; Give control to userspace, if code execution returns then kernel panic
  call 0x3000:0x0000

; Backup hang
hang:
  ; Restore kernel segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print kernel panic message
  mov si, kernelPanicNoInit
  call printString

  ; Hang system
  cli   ; Dont allow interrupts
  jmp $ ; Dont execute any code

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

; Load drivers from disk into memory
loadDrivers:
  pusha

  mov si, loadingDriversMessage
  call printString

.driver1:
  ; Use BIOS int 0x13 to read disk
  ; Memory args
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x0000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dl, 0x00   ; Read from first floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 11     ; Sector 11
  ; Call BIOS
  mov ah, 0x02
  int 0x13
  jc .error

.driver2:
  ; Use BIOS int 0x13 to read disk
  ; Memory args
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x2000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dl, 0x00   ; Read from first floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 12     ; Sector 12
  ; Call BIOS
  mov ah, 0x02
  int 0x13
  jc .error

.driver3:
  ; Use BIOS int 0x13 to read disk
  ; Memory args
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x4000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dl, 0x00   ; Read from first floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 13     ; Sector 13
  ; Call BIOS
  mov ah, 0x02
  int 0x13
  jc .error

.done:
  popa
  ret

.error:
  popa
  mov si,loadingDriversFail
  call printString
  jmp hang

; ==== DATA SECTION ====
; Messages
kernelEntryMessage db "[*] Kernel loaded", STREND
loadingDriversMessage db "[*] Loading drivers", STREND

loadingDriversFail db "[!] Failed to load drivers", STREND
kernelPanicNoInit db "[!] Kernel panic: No working init program", STREND

; Pad to 8 sectors
times 4096 - ($ - $$) db 0
