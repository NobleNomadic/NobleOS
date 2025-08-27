; keydriver.asm - Keyboard driver for getting input
[org 0x1000] ; Hardware drivers load at offset 1000
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; ==== DRIVER ENTRY ====
driverEntry:
  pusha
  push ds

  ; Setup segment for driver
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Install interrupts
  call installInterrupts

  mov si, keyboardDriverEntryMessage
  call printString

  ; Return across segment to caller
  pop ds
  popa
  retf


; ==== INTERRUPT HANDLER ====
int0x61Handler:
  pusha
  sti

  cmp ah, 0x01        ; syscall: read line
  je .getInput

  jmp .done

.getInput:
  ; Inputs:
  ; DS:SI = pointer to buffer
  ; BX    = max length (not including CR/LF/NUL terminator)
  ; AH    = 0x01
  pusha
  call getInput
  popa
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
  mov word [0x61*4], int0x61Handler
  mov word [0x61*4 + 2], cs
  pop ds
  sti
  pop ax
  ret


; ==== UTILITY: PRINT STRING ====
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


; ==== GET INPUT ====
getInput:
  ; DS:SI = buffer pointer
  ; BX    = max length
  ; On return: buffer = text + CR LF NUL

  push ax
  push di
  push cx

  mov di, si      ; DI = buffer write ptr
  xor cx, cx      ; CX = count so far

.inputLoop:
  mov ah, 0x00    ; BIOS wait for key
  int 0x16        ; AL = char
  cmp al, 0x0D    ; Enter?
  je .doneInput

  cmp al, 0x08    ; Backspace?
  jne .notBackspace

  cmp cx, 0       ; if nothing typed, ignore
  je .inputLoop
  dec cx
  dec di

  ; erase char visually
  mov ah, 0x0E
  mov al, 0x08
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 0x08
  int 0x10
  jmp .inputLoop

.notBackspace:
  cmp cx, bx      ; max length reached?
  jae .inputLoop  ; ignore extra
  mov [di], al    ; store char
  inc di
  inc cx

  ; echo char
  mov ah, 0x0E
  int 0x10
  jmp .inputLoop

.doneInput:
  ; append CR, LF, NUL
  mov byte [di], 0x0D
  inc di
  mov byte [di], 0x0A
  inc di
  mov byte [di], 0x00
  inc di

  ; newline visually
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  pop cx
  pop di
  pop ax
  ret


; ==== DATA ====
keyboardDriverEntryMessage db "[+] Keyboard driver setup", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0

