[bits 16]  ; use 16 bits
[org 0x7c00]  ; set start address

init:
	mov ah, 0x0e  ; set function to print character
	mov al, 'H' ; set character to print
	int 0x10   ; print 'H' to screen
	hlt  ; halt

times 510-($-$$) db 0
dw 0xaa55 ; magic number for bios
