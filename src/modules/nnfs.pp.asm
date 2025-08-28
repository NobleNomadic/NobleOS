; nnfs.asm - Basic filesystem kernel module
[org 0x2000] ; Filesystem modules are loaded at offset 2000
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
fsEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Install interrupts
  call installInterrupts

  mov si, filesystemDriverEntryMessage
  call printString

  ; Return to caller
  pop ds
  popa
  retf

; ==== INTERRUPT HANDLER ====
int0x62Handler:
  pusha
  sti

  ; Check syscalls
  cmp ah, 0x01 ; Syscall 1 read file
  je .readFile

  cmp ah, 0x02 ; Syscall 2 write file
  je .writeFile

  ; No valid syscall, exit
  jmp .done

.readFile:
  call readFile
  jmp .done

.writeFile:
  jmp .done

.done:
  popa
  iret

; ==== INSTALL INTERRUPTS ====
installInterrupts:
  push ax
  push ds
  cli
  xor ax, ax
  mov ds, ax
  mov word [0x62*4], int0x62Handler
  mov word [0x62*4 + 2], cs
  pop ds
  sti
  pop ax
  ret

; ==== UTILITY FUNCTIONS ====
; Read a file from the filesystem
; Inputs:
; CX = sector to read from
readFile:
  ; Setup memory args
  ; Initial segment
  mov ax, 0x2000
  mov es, ax

  cmp cx, 20 ; Check for sector 20 (shell program loaded at different address)
  je .loadShell
  mov bx, 0x2000
  jmp .continueLoad ; Else load regular file

.loadShell:
  mov bx, 0x0000

.continueLoad:
  mov al, 1    ; Load 1 sector
  mov dl, 0x00 ; Primary floppy drive
  mov dh, 0    ; Head 0
  mov ah, 0x02 ; Set BIOS read sectors

  ; Call BIOS
  int 0x13

  ; Read the first 4 bytes into the filename buffer unless shell is loaded 
  cmp cx, 20
  je .done

  push ds
  push si  
  push di
  push cx

  ; Set source: where the file was loaded
  mov ax, 0x2000          ; Source segment
  mov ds, ax              ; DS points to segment where file is loaded  
  mov si, 0x2000          ; SI points to offset 0x2000 (start of filename)

  ; Set destination: our filename buffer  
  mov ax, 0x1000          ; Our data segment
  mov es, ax              ; ES points to our data segment
  mov di, currentFilename ; DI points to our filename buffer

  ; Copy the 4 filename bytes
  mov cx, 4               ; Copy 4 bytes
  rep movsb               ; Copy from DS:SI to ES:DI

  ; Restore registers
  pop cx
  pop di  
  pop si
  pop ds

.done:
  ret

printString:
  push ax
  push si
.printLoop:
  lodsb
  or al, al
  jz .done
  mov ah, 0x0E
  int 0x10
  jmp .printLoop
.done:
  pop si
  pop ax
  ret

; DATA SECTION
filesystemDriverEntryMessage db "[+] Filesystem loaded", STREND

; Reserve buffer for current loaded filename
currentFilename times 4 db 0

; Pad to 1 sector
times 512 - ($ - $$) db 0
