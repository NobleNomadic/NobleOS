; disk and filesystem driver for reading and writing files
ORG 0x4000
BITS 16

driverEntry:
  pusha

  ; Setup segment
  push cs
  pop ax
  mov ds, ax
  mov es, ax

  ; Install interrupt handler for int 0x83
  call installInterruptHandler

  ; Return to caller
  popa
  retf

; Install int 0x83 handler
installInterruptHandler:
  pusha
  
  ; Set up data segment to 0 (IVT located at 0x0000)
  xor ax, ax            ; Set AX to 0
  mov ds, ax            ; Set DS to 0 to point to IVT base address
  
  ; Calculate the IVT entry for int 0x83
  mov bx, 0x83 * 4      ; Entry offset for int 0x83
  
  ; Store the offset of the handler in the IVT (low word)
  mov word [ds:bx], driverInterruptHandler   ; Offset of handler
  
  ; Store the segment of the handler in the IVT (high word)
  mov word [ds:bx + 2], 0x2000              ; Segment of handler
  
  popa
  ret

; ==== INTERRUPT HANDLER ====
; Handle int 0x83 interrupts
driverInterruptHandler:
  pusha

  ; Check syscall in AH and run required function
  ; SYSCALLS:
  ;  AH = 0x01: Read file
  ;    ES:BX = memory location to load into
  ;    AL = filename ID
  ;  AH = 0x02: Write buffer to file
  ;    ES:BX = memory location to source data
  ;    AL = target filename ID
  cmp ah, 0x01
  je .readFileDispatch

  cmp ah, 0x02
  je .writeFileDispatch

  ; No valid syscall, end
  jmp .done

; Dispatcher function calls required code and returns
.readFileDispatch:
  call readFile
  jmp .done

.writeFileDispatch:
  call writeFile
  jmp .done

.done:
  popa
  iret

; ==== UTILITY FUNCTIONS ====
; Read file ID in AL into memory at ES:BX
readFile:
  ; Check for init filename
  cmp al, 0x01
  je .loadInit

  ; Check for note filename
  cmp al, 0x02
  je .loadNote

  ; Check for programs
  cmp al, 0x03
  je .loadProg1

  cmp al, 0x04
  je .loadProg2

  cmp al, 0x05
  je .loadProg3

  ; No valid file ID
  jmp .done

.loadInit:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 14 ; Sector 14
  mov dl, 0  ; Read from first floppy drive
  mov al, 1  ; Read 1 sector
  ; Call BIOS to read disk
  mov ah, 0x02
  int 0x13
  jmp .done

.loadNote:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 15 ; Sector 15
  mov dl, 0  ; Read from first floppy drive
  mov al, 1  ; Read 1 sector
  ; Call BIOS to read disk
  mov ah, 0x02
  int 0x13
  jmp .done

.loadProg1:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 16 ; Sector 16
  mov dl, 0  ; Read from first floppy drive
  mov al, 1  ; Read 1 sector
  ; Call BIOS to read disk
  mov ah, 0x02
  int 0x13
  jmp .done

.loadProg2:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 17 ; Sector 17
  mov dl, 0  ; Read from first floppy drive
  mov al, 1  ; Read 1 sector
  ; Call BIOS to read disk
  mov ah, 0x02
  int 0x13
  jmp .done

.loadProg3:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 18 ; Sector 18
  mov dl, 0  ; Read from first floppy drive
  mov al, 1  ; Read 1 sector
  ; Call BIOS to read disk
  mov ah, 0x02
  int 0x13
  jmp .done
  
.done:
  ret

; Write buffer to target filename in SI
writeFile:
  ; Check for filenames
  ; Init file
  cmp al, 0x01
  je .writeInit

  cmp al, 0x02
  je .writeNote

  cmp al, 0x03
  je .writeProg1

  cmp al, 0x04
  je .writeProg2

  cmp al, 0x05
  je .writeProg3

.writeInit:
  ; Use BIOS int 0x13 to write data to file
  ; Disk args
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 14 ; Sector 14
  mov dl, 0  ; Write to first floppy drive
  mov al, 1  ; Write 1 sector 
  ; Call BIOS write disk
  mov ah, 0x03
  int 0x13
  jmp .done

.writeNote:
  ; Disk args
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 15 ; Sector 15
  mov dl, 0  ; Write to first floppy drive
  mov al, 1  ; Write 1 sector 
  ; Call BIOS write disk
  mov ah, 0x03
  int 0x13
  jmp .done
.hang:
  jmp $
.writeProg1:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 16 ; Sector 16
  mov dl, 0  ; Write to first floppy drive
  mov al, 1  ; Write 1 sector
  ; Call BIOS to write disk
  mov ah, 0x03
  int 0x13
  jmp .done

.writeProg2:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 17 ; Sector 17
  mov dl, 0  ; Write to first floppy drive
  mov al, 1  ; Write 1 sector
  ; Call BIOS to write disk
  mov ah, 0x03
  int 0x13
  jmp .done

.writeProg3:
  mov ch, 0  ; Cylinder 0
  mov dh, 0  ; Head 0
  mov cl, 18 ; Sector 18
  mov dl, 0  ; Read from first floppy drive
  mov al, 1  ; Read 1 sector
  ; Call BIOS to write disk
  mov ah, 0x03
  int 0x13
  jmp .done

.done:
  ret

; ==== DATA SECTION ====
; Pad to 1 sector
times 512 - ($ - $$) db 0
