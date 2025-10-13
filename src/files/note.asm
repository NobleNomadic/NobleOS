; Note file for storing a small text document. Can be edited and printed on boot by Noble init
%define STREND 0x0D, 0x0A

db "Welcome to NobleOS!", STREND
db "Version 0.0.1", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
