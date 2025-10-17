; prog2.asm - Second program on disk, file multitool
ORG 0x0000
BITS 16

%define STREND 0x0D, 0x0A, 0x00

; Entry function
entry:
  pusha
  ; Setup segment regsiters
  push cs ; Get code segment
  pop ax
  mov ds, ax
  mov es, ax

  ; Print entry message using video services
  mov si, programEntryMessage ; String to print
  mov ah, 0x01                ; Syscall 1, print string
  int 0x81                    ; Call video services

; Common return point in program for success
.done:
  clc  ; Clear carry flag, program had no errors
  popa
  retf

; ==== UTILITY FUNCTIONS ====
; Write note file
writeNoteEntry:
  ; Get string input into buffer with keyboard services
  mov si, inputBuffer ; Target buffer
  mov al, 64          ; 64 max chars input
  mov ah, 0x01        ; Syscall 1, read input
  int 0x82            ; Call keyboard services

  ; Write entry to note file with disk services
  mov bx, inputBuffer ; Buffer to write
  mov al, 0x02        ; File 2, note
  mov ah, 0x02        ; Syscall 2, write file
  int 0x83            ; Call disk services

; Common return point
.done:
  ret

; ==== DATA SECTION ====
; Messages
programEntryMessage db "[*] Noble file multitool", STREND

; Buffer for getting input
inputBuffer times 65 db 0 ; 64 chars + null

; Pad to 1 sector
times 512 - ($ - $$) db 0
