; kerneldisk.asm - Read and load code for the main kernel binary
[bits 32]

; Global definition for disk read function
global CHSDiskRead

; Main disk read function
CHSDiskRead:
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
  test al, 0x08            ; DRQ = bit 3
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

