; kernel.asm - Install interrupts and control userspace programs
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry function
kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print kernel entry message
  mov si, kernelEntryMessage
  call printString

  ; Install syscall interrupts
  call installInterrupts

  ; Hang kernel
  jmp hang

; Backup hang function
hang:
  jmp $

; ==== INTERRUPT HANDLERS ====
; Catch int 0x60
int60Handler:
  pusha ; Save registers
  
  ; Execute required syscall code

  popa  ; Return registers
  iret  ; Return from interrupt


; Interrupt installer to allow the OS to use syscalls
installInterrupts:
  ; Segment 0x0000
  xor ax, ax
  mov es, ax

  ; int 0x60 handler
  cli ; Don't allow interrupts during IVT editing
  mov word [es:0x60*4], int60Handler ; Offset fo handler
  mov word [es:0x60*4+2], cs         ; Segment of handler
  sti ; Allow interrupts again

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
kernelEntryMessage db "[+] Kernel loaded", STREND

; Pad to 6 sectors
times 3072 - ($ - $$) db 0
