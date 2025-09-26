; kernel.asm - Main OS controller
ORG 0x0000
BITS 16
%define STREND 0x0D, 0x0A, 0x00

kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax
  ; Print kernel entry message
  mov si, kernelEntryMessage
  call printString

  ; Load FAT into kernel segment
  call loadFAT

  ; Load test driver
  mov si, testDriverName
  call loadDriver
  call 0x2000:0x0000

; Backup hang
hang:
  jmp $

; Load FAT from disk into current segment at offset 0x3000
loadFAT:
  pusha
  
  ; Load FAT from sector 2
  mov bx, 0x3000    ; Offset in current segment
  mov al, 1         ; Read 1 sector
  mov dl, 0x80      ; First hard disk
  mov dh, 0         ; Head 0
  mov ch, 0         ; Cylinder 0
  mov cl, 2         ; Sector 2 (FAT location)
  mov ah, 0x02      ; Read sectors
  int 0x13
  
  popa
  ret

; ==== UTILITY FUNCTIONS ====
; Print string: print a string in SI with null terminator
printString:
  push ax         ; Preserve registers
  push si
.printLoop:
  lodsb           ; Load next byte from SI -> AL
  or al, al       ; Check for null terminator
  jz .done        ; Finish if null
  mov ah, 0x0E    ; Setup BIOS tty print
  int 0x10        ; Call interrupt to print
  jmp .printLoop  ; Continue loop
.done:
  pop si          ; Return registers and return to caller
  pop ax
  ret

; Load driver function
; Input: SI = pointer to 8-character driver name
; Loads driver into segment 0x2000
loadDriver:
  pusha

  ; Simple linear search through FAT entries
  mov cx, 4               ; Check first 4 entries
  mov di, 0x3000          ; Start of FAT
  
.searchLoop:
  push cx
  push di
  push si
  
  ; Compare 8 bytes manually
  xor bx, bx              ; Index for comparison
.compareLoop:
  mov al, [si + bx]       ; Byte from search string
  mov dl, [di + bx]       ; Byte from FAT entry
  cmp al, dl
  jne .noMatch
  inc bx
  cmp bx, 8               ; Compare 8 bytes
  jl .compareLoop
  
  ; Match found!
  pop si
  pop di
  pop cx
  jmp .loadFound

.noMatch:
  pop si
  pop di
  pop cx
  add di, 12              ; Move to next FAT entry (12 bytes each)
  loop .searchLoop
  
  ; Not found
  jmp .done

.loadFound:
  ; DI points to the matching FAT entry
  ; Extract CHS and size
  mov ch, [di + 8]        ; Cylinder
  mov dh, [di + 9]        ; Head
  mov cl, [di + 10]       ; Sector
  mov al, [di + 11]       ; Size in sectors
  
  ; Load driver into segment 0x2000
  push ax                 ; Save sector count
  mov ax, 0x2000         ; Target segment
  mov es, ax
  mov bx, 0x0000         ; Target offset
  pop ax                 ; Restore sector count

  mov dl, 0x80           ; First hard disk
  mov ah, 0x02           ; Read sectors
  int 0x13

.done:
  ; Restore ES to kernel segment
  mov ax, 0x1000
  mov es, ax
  popa
  ret

; ==== DATA SECTION ====
; Kernel messages
kernelEntryMessage db "[*] Kernel loaded", STREND

; Driver names
testDriverName db "TEST    "

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
