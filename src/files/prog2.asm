; prog2.asm - Second program on disk, file multitool
ORG 0x0000
BITS 16

%define STREND 0x0D, 0x0A, 0x00
%define NEWLIN 0x0D, 0x0A

; Entry function
entry:
  pusha
  ; Setup segment regi; Entry functionstors
  push cs ; Get code segment
  pop ax
  mov ds, ax
  mov es, ax

  ; Print entry message using video services
  mov si, programEntryMessage ; String to print
  mov ah, 0x01                ; Syscall 1, print string
  int 0x81                    ; Call video services

  ; Print program options menu
  mov si, optionMenu
  int 0x81

  ; Get action
  mov ah, 0x00
  int 0x16     ; BIOS character input

  ; Check action
  cmp al, 0x31
  je .writeNote

  cmp al, 0x32
  je .viewNote

  ; No valid input
  jmp .done

.writeNote:
  call writeNoteEntry
  jmp .done

.viewNote:
  call viewNoteFile
  jmp .done

; Common return point in program
.done:
  popa
  retf

; ==== UTILITY FUNCTIONS ====
; Write note file
writeNoteEntry:
  ; Print prompt
  mov si, noteWritePrompt ; String to print
  mov ah, 0x01            ; Syscall 1, print string
  int 0x81                ; Call video services

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

; View the note file
viewNoteFile:
  ; Load into buffer
  ; Memory args
  mov bx, 0x2000
  ; Syscall args
  mov ah, 0x01 ; Syscall 1 read file
  mov al, 0x02 ; File 2, note file
  ; Call disk servies
  int 0x83

  ; Print the file contents
  ; Load content
  mov si, 0x2000
  ; Print using video services
  mov ah, 0x01 ; Syscall 1, print string
  int 0x81     ; Call video services

  ret


; ==== DATA SECTION ====
; Messages
programEntryMessage db "[*] Noble file multitool", STREND

optionMenu db "1: Write note", NEWLIN, \
              "2: View note", STREND

noteWritePrompt db "[>] Enter string: ", 0

; Buffer for getting input
inputBuffer times 65 db 0 ; 64 chars + null

; Pad to 1 sector
times 512 - ($ - $$) db 0
