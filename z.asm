[bits 16]  ; use 16 bits

init:
	mov ah, 0x0e  ; set function to print character
	mov al, 'Z' ; set character to print
	int 0x10   ; print to screen
	hlt  ; halt

;264 mov ah, (26r, r=1)
;016	0xOe
;260 mov al, (26r, r=2)
;132	'Z'
;315 int
;020	0x10
;364 hlt

