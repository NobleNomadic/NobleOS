; boot.asm - Initial bootloader
ORG 0x7C00
BITS 16

%define STREND 0x0D, 0x0A, 0x00

; Entry
bootEntry:
  ; Setup segment
  push cs    ; Push segment to stack
  pop ax     ; Move segment into AX
  mov ds, ax ; Setup segment registers with AX value
  mov es, ax

  ; Clear video memory
  mov ah, 0x00
  mov al, 0x03
  int 0x10

  ; Print entry message
  mov si, bootEntryMessage
  call printString

  ; Load kernel
  call loadKernel

  ; Jump to kernel
  jmp 0x1000:0x0000

; Backup hang function
hang:
  jmp $

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

; Load kernel: Read filesystem entry and find kernel entry, then load code
loadKernel:
  pusha

.loadFat:
  ; Read FAT from sector 2
  ; Memory args
  mov ax, 0x0000 ; Segment
  mov es, ax
  mov bx, 0x3000 ; Offset

  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dl, 0x80   ; Read from first hard disk
  mov dh, 0      ; Head 0
  mov ch, 0      ; Cylinder 0
  mov cl, 2      ; Sector 2, start of FAT

  mov ah, 0x02   ; Setup BIOS read sectors
  int 0x13

; ==== FIND KERNEL FILE ====
.searchKernel:
  mov cx, 42              ; Max entries (512/12 = 42.67, so 42)
  mov si, kernelName      ; SI points to "KERNEL  "
.nextEntry:
  ; Compute current FAT entry offset
  mov di, 0x3000          ; FAT start
  mov dx, cx
  mov bx, 42
  sub bx, dx              ; number of entries already checked
  imul bx, 12             ; multiply by NEW FAT entry size (12 bytes)
  add di, bx              ; DI points to current entry

  xor bx, bx              ; Filename index
.compareLoop:
  mov al, [si + bx]       ; byte from kernelName
  mov dl, [di + bx]       ; byte from FAT (use DL instead of BL)
  cmp al, dl              ; Compare with DL
  jne .notMatch           ; Not a match, go to next entry
  inc bx
  cmp bx, 8
  jne .compareLoop
  ; Match found, get CHS and size
  mov ch, [di + 8]        ; Cylinder
  mov dh, [di + 9]        ; Head
  mov cl, [di + 10]       ; Sector
  mov al, [di + 11]       ; Size in sectors
  jmp .loadKernelSector
.notMatch:
  loop .nextEntry
  ; If not found, hang
  jmp hang

; Load kernel into memory once address is found
.loadKernelSector:
  ; Load kernel from disk with int 0x13
  ; AL already contains the size from the FAT entry
  push ax
  mov ax, 0x1000 ; Segment to load kernel
  mov es, ax
  mov bx, 0x0000 ; Offset to load kernel
  pop ax

  ; Disk args (AL already set with size)
  mov dl, 0x80   ; First hard disk
  mov ah, 0x02   ; Read sectors function
  int 0x13

; Clean up registers and return
.done:
  popa
  ret

; ==== DATA SECTION ====
bootEntryMessage db "[*] Bootable device found", STREND
kernelName db "KERNEL  "

; ==== BOOT SIGNATURE ====
times 510 - ($ - $$) db 0
dw 0xAA55
