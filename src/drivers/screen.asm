; screen.asm - Screen driver loaded by kernel on startup, then called to install interrupts allowing code to be accessed through int 0x81
ORG 0x0000
BITS 16

driverEntry:
  pusha

  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

  ; Install interrupt handler for int 0x81
  call installInterruptHandler

  ; Return to caller
  popa
  retf

; Install int 0x81 handler
installInterruptHandler:
  pusha
  
  ; Point to IVT at 0x0000:0x0000
  xor ax, ax
  mov ds, ax
  
  ; Calculate IVT entry address (0x81 * 4 = 0x204)
  mov bx, 0x81 * 4
  
  ; Store offset (low word) - handler is at 0x2000:driverInterruptHandler
  mov word [ds:bx], driverInterruptHandler
  
  ; Store segment (high word)
  mov word [ds:bx + 2], 0x2000
  
  popa
  ret

; ==== INTERRUPT HANDLER ====
; Handle int 0x81 interrupts
driverInterruptHandler:
  pusha
  
  ; Check syscall in AH and run required function
  ; SYSCALLS:
  ;   AH = 0x01: Print string in SI
  cmp ah, 0x01
  je .printStringDispatch
  
  ; No valid syscall, end
  jmp .done

; Function dispatchers
; Call print string, then return from interrupt
.printStringDispatch:
  call printString
  jmp .done

.done:
  popa
  iret

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

; Pad to 1 sector
times 512 - ($ - $$) db 0
