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

; Backup hang
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

; Print last 4 bytes from loaded driver as ASCII
; ES:BX points to the loaded driver, CX = size in bytes
printDriverLoaded:
  pusha
  
  ; Print the message prefix
  mov si, driverLoadedMessage
  call printString
  
  ; Calculate address of last 4 bytes
  ; Address = ES:BX + size - 4
  mov di, bx
  add di, cx
  sub di, 4
  
  ; Print 4 ASCII characters
  mov cx, 4
.printLoop:
  mov al, es:[di]
  mov ah, 0x0E
  int 0x10
  inc di
  loop .printLoop
  
  ; Print newline
  mov si, newline
  call printString
  
  popa
  ret

; Read drivers from disk into memory
loadDrivers:
  pusha

  ; Print loading drivers message
  mov si, loadingDriversMessage
  call printString

.firstDriver:
  ; Memory args
  mov ax, 0x2000 ; Segment 0x2000
  mov es, ax
  mov bx, 0x0000 ; Offset 0x0000
  ; Disk args
  mov al, 2      ; 2 sectors
  mov dl, 0x00   ; First floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 11     ; Sector 11

  ; Call BIOS
  mov ah, 0x02   ; Setup BIOS disk read sectors
  int 0x13
  jc .error
  
  ; Print loaded message
  mov cx, 1024   ; 2 sectors = 1024 bytes
  call printDriverLoaded

.secondDriver:
  ; Memory args
  mov ax, 0x2000 ; Segment 0x2000
  mov es, ax
  mov bx, 0x2000 ; Offset 0x2000
  ; Disk args
  mov al, 2      ; 2 sectors
  mov dl, 0x00   ; First floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 13     ; Sector 13

  ; Call BIOS
  mov ah, 0x02   ; Setup BIOS disk read sectors
  int 0x13
  jc .error
  
  ; Print loaded message
  mov cx, 1024   ; 2 sectors = 1024 bytes
  call printDriverLoaded

.thirdDriver:
  ; Memory args
  mov ax, 0x2000 ; Segment 0x2000
  mov es, ax
  mov bx, 0x4000 ; Offset 0x4000
  ; Disk args
  mov al, 2      ; 2 sectors
  mov dl, 0x00   ; First floppy drive
  mov ch, 0      ; Cylinder 0
  mov dh, 0      ; Head 0
  mov cl, 15     ; Sector 15

  ; Call BIOS
  mov ah, 0x02   ; Setup BIOS disk read sectors
  int 0x13
  jc .error
  
  ; Print loaded message
  mov cx, 1024   ; 2 sectors = 1024 bytes
  call printDriverLoaded

.done:
  popa
  ret

.error:
  popa
  mov si, driverLoadingFailedMessage
  call printString
  jmp hang


; ==== DATA SECTION ====
kernelEntryMessage db "[*] Kernel loaded", STREND
loadingDriversMessage db "[*] Loading drivers", STREND
driverLoadingFailedMessage db "[!] Driver loading failed", STREND
driverLoadedMessage db "  [+] Loaded: ",0
newline db 0x0D, 0x0A, 0

; Pad to 8 sectors
times 4096 - ($ - $$) db 0
