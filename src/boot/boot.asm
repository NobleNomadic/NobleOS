; boot.asm - Initial bootloader
; Switches to 32 bit mode then uses ATA disk read function to load kernel
[bits 16]
[org 0x7C00]

start:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00

  ; Enable A20 line for memory access above 1MB
  in al, 0x92
  or al, 2
  out 0x92, al

  ; Load Global Descriptor Table (GDT) and enter protected mode
  lgdt [gdtDesc]
  cli
  mov eax, cr0
  or eax, 1
  mov cr0, eax

  ; Far jump to flush instruction pipeline and enter protected mode
  jmp 0x08:pmStart

[BITS 32]
pmStart:
  ; Set up segment registers with data segment selector (0x10)
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x90000         ; Set up stack

  ; Prepare CHS values and buffer address for ATA read
  mov ebx, 0x00000002      ; CHS: Cylinder 0, Head 0, Sector 2
  mov ch, 18               ; Number of sectors to read
  mov edi, 0x10000         ; Buffer address to load sectors into
  call ataChsDiskRead

  ; Jump to the loaded kernel at 0x10000
  jmp 0x10000

; ----------------------------------------
; ATA CHS Disk Read Function - 32 bit version of the code found at https://wiki.osdev.org/ATA_read/write_sectors
; Reads 'ch' sectors from CHS address in EBX into buffer at EDI
; CHS format: EBX = [Cylinder:16][Head:8][Sector:8]
; ----------------------------------------
ataChsDiskRead:
  pushfd
  push eax
  push ebx
  push ecx
  push edx
  push edi

  ; Select drive/head
  mov dx, 0x1F6
  mov al, bh                ; Get head (bits 8–15 of EBX)
  and al, 0x0F              ; Mask to 4 bits
  or al, 0xA0               ; Drive 0, CHS mode
  out dx, al

  ; Set sector count
  mov dx, 0x1F2
  mov al, ch
  out dx, al

  ; Set sector number (1-based)
  mov dx, 0x1F3
  mov al, bl
  out dx, al

  ; Set cylinder low byte
  mov dx, 0x1F4
  mov eax, ebx
  shr eax, 16
  out dx, al

  ; Set cylinder high byte
  mov dx, 0x1F5
  mov eax, ebx
  shr eax, 24
  out dx, al

  ; Send ATA read command (0x20 = read sectors)
  mov dx, 0x1F7
  mov al, 0x20
  out dx, al

  ; Read sectors into buffer
  xor eax, eax
  mov al, ch                ; Number of sectors to read
  mov ebx, eax              ; Sector counter

.readSectorLoop:
  ; Wait for drive to be ready (DRQ bit set)
.waitReady:
  mov dx, 0x1F7
  in al, dx
  test al, 0x08             ; DRQ = bit 3
  jz .waitReady

  ; Read one sector (256 words = 512 bytes)
  mov ecx, 256
  mov dx, 0x1F0
  rep insw                 ; Read from port into [EDI]

  dec ebx
  jnz .readSectorLoop      ; Loop until all sectors are read

  ; Restore registers
  pop edi
  pop edx
  pop ecx
  pop ebx
  pop eax
  popfd
  ret

; ----------------------------------------
; Global Descriptor Table (GDT)
; ----------------------------------------
gdtStart:
  dq 0                      ; Null descriptor

gdtCode:
  dw 0xFFFF                 ; Limit (low)
  dw 0x0000                 ; Base (low)
  db 0x00                   ; Base (middle)
  db 10011010b              ; Access byte (code segment)
  db 11001111b              ; Flags + Limit (high)
  db 0x00                   ; Base (high)

gdtData:
  dw 0xFFFF                 ; Limit (low)
  dw 0x0000                 ; Base (low)
  db 0x00                   ; Base (middle)
  db 10010010b              ; Access byte (data segment)
  db 11001111b              ; Flags + Limit (high)
  db 0x00                   ; Base (high)

gdtDesc:
  dw gdtDesc - gdtStart - 1 ; Size of GDT
  dd gdtStart               ; Address of GDT

; Boot sector padding and signature
times 510 - ($ - $$) db 0
dw 0xAA55

