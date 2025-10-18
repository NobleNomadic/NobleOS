; init.asm - Initital program loaded by kernel to start userspace
; Noble init, loads note file and prints it, 
; then loads program 1 and then calls it
ORG 0x0000
BITS 16

%define STREND 0x0D, 0x0A, 0x00

; Entry function
entry:
  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

  mov si, initEntryMessage
  call printString

  ; Get password and login
  call login

  ; Load program 1, shell
  mov si, loadingShellMessage
  call printString

  ; Print note file
  mov ax, 0x3000 ; Segment 0x3000
  mov es, ax
  mov bx, 0x2000 ; Offset 0x2000
  mov ah, 0x01   ; Disk syscall read file
  mov al, 0x02   ; File 2, Note file
  ; Call disk service
  int 0x83

  ; Print data
  mov si, 0x2000 ; Target buffer
  call printString

  ; Print newline
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  ; Load program 1 into memory using disk driver
  mov ax, 0x3000 ; Segment 0x3000
  mov es, ax
  mov bx, 0x2000 ; Offset 0x2000
  mov ah, 0x01 ; Disk syscall 1 to read file
  mov al, 0x03 ; File 3, first program
  ; Call disk services
  int 0x83

  ; Call loaded code
  call 0x3000:0x2000

  mov si, shellExitMessage
  call printString

  ; Return if reached this point
  retf

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

; Compare 2 strings, if equal set carry flag
strcmp:
.loop:
  mov al, [si]   ; Get byte from SI
  mov bl, [di]   ; Get byte from DI
  cmp al, bl     ; Check if equal
  jne .notequal  ; No, done
 
  cmp al, 0  ; Check if both are null
  je .done   ; Strings finished comparing and all are equal so far, exit set carry flag
 
  inc di     ; Increment DI
  inc si     ; Increment SI
  jmp .loop  ; Continue loop
 
.notequal:
  clc  ; Not equal, clear the carry flag
  ret
 
.done: 	
  stc  ; Equal, set the carry flag
  ret

; Login function
; Get password input, check if equal to password
login:
  ; Print prompt
  mov si, passwordPrompt
  call printString

  ; Get input using keyboard service
  mov ah, 0x01 ; Get input syscall
  mov al, 32   ; 32 chars max
  mov si, inputBuffer ; Buffer target
  int 0x82     ; Call keyboard services

  ; Check if same
  mov di, password ; Compare with password in memory
  call strcmp

  jc .equal
  jmp .notEqual

.equal:
  mov si, loginSuccessMessage
  call printString
  ret

; Password input not equal to password in memory, print failed message and continue
.notEqual:
  mov si, loginFailMessage
  call printString
  jmp login

; ==== DATA SECTION ====
; Messages
initEntryMessage db "[*] Noble init entered", STREND
loginSuccessMessage db "[+] Login success", STREND
loadingShellMessage db "[*] Loading shell", STREND
loginFailMessage db "[-] Login failed: Incorrect password", STREND
shellExitMessage db "[*] Shell exited, exiting init", STREND

; Password data
passwordPrompt db "[>] Password for user: ", 0
; Password required to enter system
password db "password", 0

; Buffer for input
inputBuffer times 32 db 0

; Pad to 1 sector
times 512 - ($ - $$) db 0
