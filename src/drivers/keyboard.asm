; keyboard.asm - Keyboard driver loaded and called by kernel to install 0x82 interrupt handler
ORG 0x2000
BITS 16

driverEntry:
  pusha

  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

  ; Install interrupt handler for int 0x82
  call installInterruptHandler

  ; Return to caller
  popa
  retf

; Install int 0x82 handler
installInterruptHandler:
  pusha
  
  ; Point to IVT at 0x0000:0x0000
  xor ax, ax
  mov ds, ax
  
  ; Calculate IVT entry address
  mov bx, 0x82 * 4
  
  ; Store offset (low word) - handler is at 0x2000:driverInterruptHandler
  mov word [ds:bx], driverInterruptHandler
  
  ; Store segment (high word)
  mov word [ds:bx + 2], 0x2000
  
  popa
  ret

; ==== INTERRUPT HANDLER ====
; Handle int 0x82 interrupts
driverInterruptHandler:
  pusha

  ; Check syscall in AH
  ; SYSCALLS:
  ;   AH = 0x01: Get string of input into buffer in SI
  ;     SI = target buffer
  ;     AL = Max chars
  cmp ah, 0x01
  je .getInputDispatch

  ; No valid syscall, end
  jmp .done

.getInputDispatch:
  call getInput
  jmp .done

.done:
  popa
  iret
  
; Get string of blocking input into buffer in SI with echoing, AL is max chars of input
getInput:
  push ax
  push bx
  push cx
  push dx
  push si

  xor bx, bx              ; BX = character counter
  mov cl, al              ; CL = max characters

.readChar:
  ; Wait for key press
  mov ah, 0x00
  int 0x16                ; Read key into AL

  ; Check for Enter (ASCII 13)
  cmp al, 13
  je .doneInput

  ; Check for Backspace (ASCII 8)
  cmp al, 8
  je .handleBackspace

  ; Ignore non-printable if limit reached
  cmp bx, cx
  jae .readChar

  ; Store character in buffer
  mov [si + bx], al

  ; Echo to screen
  mov ah, 0x0E
  int 0x10

  ; Advance buffer
  inc bx
  jmp .readChar

.handleBackspace:
  cmp bx, 0
  je .readChar            ; Nothing to delete

  ; Move back
  dec bx

  ; Echo backspace (move cursor back, overwrite with space, move back again)
  mov al, 8
  mov ah, 0x0E
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 8
  int 0x10
  jmp .readChar

.doneInput:
  ; Null-terminate string
  mov byte [si + bx], 0

  ; Echo newline
  mov al, 13
  mov ah, 0x0E
  int 0x10
  mov al, 10
  int 0x10

  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  ret

; Pad to 1 sector
times 512 - ($ - $$) db 0
