; kernel.asm - Manage modules and syscalls
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; ==== Kernel Entry ====
kernelEntry:
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  mov si, kernelEntryMessage
  call printString

  ; Run interrupt installer to make int 0x60 work
  call installInterrupts

  ; Load keyboard driver module
  mov dh, 0x01
  mov cx, 10
  mov ah, 0x01
  int 0x60
  call 0x1000:0x1000

  mov ah, 0x01
  int 0x61

  ; Hang
  jmp $

; ==== Interrupt Handler - Run After int 0x60 ====
int60Handler:
  pusha
  ; safe handler: enable interrupts if BIOS calls are needed
  sti

  ; Load module syscall
  cmp ah, 0x01
  je .loadModule

  ; No valid syscall, end
  jmp .done

.loadModule:
  ; Use int 0x13 to load from the disk
  mov ax, 0x1000
  mov es, ax
  ; Set slot
  cmp dh, 1
  je .slot1
  cmp dh, 2
  je .slot2
  cmp dh, 3
  je .slot3
  jmp .done
.slot1:
  mov bx, 0x1000
  jmp .callBIOS
.slot2:
  mov bx, 0x2000
  jmp .callBIOS
.slot3:
  mov bx, 0x3000

.callBIOS:
  mov ah, 0x02    ; BIOS read sectors
  mov al, 1
  mov dh, 0
  mov dl, 0x00
  int 0x13

.done:
  cli
  popa
  iret

; ==== Install Interrupts ====
installInterrupts:
  push ax
  push ds
  cli
  xor ax, ax
  mov ds, ax
  mov word [0x60*4], int60Handler
  mov word [0x60*4 + 2], cs
  pop ds
  sti
  pop ax
  ret

; ==== Utility Functions ====
printString:
  push ax         ; Preserve registerss
  push si
.printLoop:
  lodsb           ; Load next byte into AL
  or al, al       ; Check for null terminator
  jz .done        ; Finish if null
  mov ah, 0x0E    ; Setup BIOS tty print
  int 0x10        ; Call BIOS
  jmp .printLoop  ; Continue loop
.done:
  ; Return register state and return
  pop si
  pop ax
  ret

; DATA SECTION
kernelEntryMessage db "[+] Kernel loaded", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
