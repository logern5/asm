[bits 16]				; use 16 bits
[org 0x7c00]				; set start address

jmp 0x0000:start  			; make sure cs register is at 0x0000, not 0x7c00. Changes addr from 7c00:0000 to 0000:7c00
start:					; initialize segment registers
xor ax, ax
mov ds, ax
mov es, ax

mov bx, program				; set pointer for program data

main:
	mov cx, 3			; read 3 octal chars into one byte
	read_loop:
		mov ah, 00		; set function for keypress
		int 0x16		; get keypress and store in al
		sub al, '0'		; convert ASCII digit to integer
		cmp al, 8		; if an unvalid character,
		jge program		; then jump to the program, else,
		mov byte dl, [bx]	; get current byte from program
		shl dx, 3		; multiply by 8
		add dl, al		; add the current digit to it
		mov byte [bx], dl	; store back in the program
		loop read_loop		; if cx != 0, jmp to read_loop
	inc bx				; increment pointer of program data
	jmp main			; repeat for the next byte

program:
times 510-($-$$) db 0
dw 0xaa55				; magic number for bios
