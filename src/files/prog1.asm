; prog1.asm - Basic shell loaded by init system after login
ORG 0x2000 ; Most files load at 0ffset 0x2000
BITS 16

%define STREND 0x0D, 0x0A, 0x00

; Entry
programEntry:
  ; Setup segment registers
  push cs
  pop ax
  mov ds, ax
  mov es, ax

; Main repeating shell loop
shellLoop:
  ; Print prompt using video services
  mov si, shellPrompt ; String to print
  mov ah, 0x01        ; Syscall 1 - print string
  int 0x81            ; Screen services

  ; Get string of input
  mov si, inputBuffer ; Target buffer for input
  mov ah, 0x01        ; Keyboard syscall 1 - get string
  mov al, 32          ; Max chars for input
  int 0x82            ; Call keyboard services

  ; Check command
  ; Clear command
  mov si, inputBuffer
  mov di, clearCommandString
  call strcmp
  jc .clear

  ; Help command
  mov si, inputBuffer
  mov di, helpCommandString
  call strcmp
  jc .help

  ; Fetch command
  mov si, inputBuffer
  mov di, fetchCommandString
  call strcmp
  jc .fetch

  ; Run program 1 command
  mov si, inputBuffer
  mov di, runProgram1String
  call strcmp
  jc .runProgram1

  ; Run program 2 command
  mov si, inputBuffer
  mov di, runProgram2String
  call strcmp
  jc .runProgram2

  ; Exit command
  mov si, inputBuffer
  mov di, exitString
  call strcmp
  jc .exit

  ; No valid command, continue
  jmp .done

; Clear command
.clear:
  ; Clear screen by resetting video mode
  mov ah, 0x00
  mov al, 0x03
  int 0x10
  jmp .done

; Help command
.help:
  mov si, helpMessage
  mov ah, 0x01
  int 0x81
  jmp .done

; Fetch command
.fetch:
  jmp .done

.runProgram1:
  jmp .done

.runProgram2:
  jmp .done

.exit:
  retf

.done:
  ; Continue loop
  jmp shellLoop

; Backup hang
hang:
  jmp $

; ==== UTILUTY FUNCTIONS ====
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

; ==== DATA SECTION ====
; Messages
; Shell prompt
shellPrompt db "# ", 0
helpMessage db "clear, help, fetch, run 1, run 2, exit", STREND

; Buffer for getting input, 32 chars + null
inputBuffer times 33 db 0

; Command strings
clearCommandString db "clear", 0
helpCommandString db "help", 0
fetchCommandString db "fetch", 0
runProgram1String db "run 1", 0
runProgram2String db "run 2", 0
exitString db "exit", 0

; Pad to 1 sector
times 512 - ($ - $$) db 0
