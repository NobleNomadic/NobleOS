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

  call installInterrupts

  ; Call dummy module via direct syscall
  mov ah, 0x01    ; syscall number = 1 (load module)
  mov cx, 10      ; sector
  mov dl, 0x00    ; drive
  mov dh, 1       ; slot 1
  int 0x60        ; handler runs immediately

  ; Call the module code
  call 0x1000:0x1000

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
  int 0x13

.done:
  cli
  popa
  iret

; ==== Install Interrupts ====
installInterrupts:
  cli
  xor ax, ax
  mov ds, ax
  mov word [0x60*4], int60Handler
  mov word [0x60*4 + 2], cs
  sti
  ret

; ==== Utility Functions ====
printString:
  push ax
  push si
.printLoop:
  lodsb
  or al, al
  jz .donePS
  mov ah, 0x0E
  int 0x10
  jmp .printLoop
.donePS:
  pop si
  pop ax
  ret

; DATA SECTION
kernelEntryMessage db "[+] Kernel loaded", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
