[bits 16]
[org 0x7C29]
main:
mov ax, str		;Load the address of the string into reg AX
mov si, ax		;Load the source index register, commonly used as a pointer, with the contents from AX
lp:
loadsb 			;Load String (lods) with contents of memory pointed to by SI (DS is 0x00), and increment SI automatically
mov ah, 0xe		;Set function to write string
int 0x10		;Call BIOS to write string
cmp al, 0x0		;Compare the contents of AL (the byte read) to 0 (end of string/null terminator)
je halt			;If we are at a null terminator, stop looping, jump to halt
jmp lp			;Otherwise, keep looping
halt:
hlt			;halt
str:
db 'Hello World',0x0	;String to print
