; fat.asm - Initial fat data
ORG 0x3000
BITS 16

; --- FAT ENTRIES ---
; One entry for KERNEL at CHS (0,0,3)
db "KERNEL  "     ; 8-byte filename, padded
db 0x00           ; cylinder
db 0x00           ; head
db 0x03           ; sector
db 0x04           ; sector count

times 512 - ($ - $$) db 0
