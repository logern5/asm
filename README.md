# Bare Metal: Coding from scratch
## Introduction
Imagine you are in a room with a standard x86 PC. The computer has
no drives except for a floppy drive, and no networking capabilities, and you
would like to program it. There is a floppy disk on the desk. Would it be 
possible to program it at all, without an operating system? What is the minimum 
software on that floppy needed to be able to program the computer? This
question was asked on Reddit in 2010, and the answer is quite simple.

The computer needs a minimal "monitor" program to allow the user to enter
machine code to run into the computer, which will be shown in the next
chapter.

Before we start, since I'm not going to lock myself in a room to do this
project, I'll set some guidelines for myself. I'll allow my self to use
some reference materials, namely:

* AMD64 Architechture Programmer's Manual Vol. 3 
* "Intel is an octal machine"

I however, will not use an assembler or anything that would require another
computer. I would highly recommend reading the essay "Intel is an octal
machine" as it explains the instruction set of the x86 very well.

With that in mind, let's start out with our initial monitor program.
The program will read octal bytes from the keyboard, store them in memory,
and execute them when a non-octal character is entered.

Here is the monitor program (in NASM assembly). This will allow us to run any octal machine code
on the system:
```
[bits 16]				; use 16 bits
[org 0x7c00]			; set start address
 
jmp 0x0000:start		; make sure cs register is at 0x0000, not 0x07c0
start:					; initialize segment registers
xor ax, ax
mov ds, ax
mov es, ax
 
mov bx, program		; set pointer for program data
 
main:
	mov cx, 3			; read 3 octal chars into one byte
	read_loop:
		mov ah, 00		; set function for keypress
		int 0x16			; get keypress and store in al
		sub al, '0'	; convert ASCII digit to integer
		cmp al, 8		; if an unvalid character,
		jge program	; then jump to the program, else,
		mov byte dl, [bx]	; get current byte from program
		shl dx, 3		; multiply by 8
		add dl, al		; add the current digit to it
		mov byte [bx], dl	; store back in the program
		loop read_loop		; if cx != 0, jmp to read_loop
	inc bx				; increment pointer of program data
	jmp main				; repeat for the next byte
 
program:
times 510-($-$$) db 0
dw 0xaa55				; magic number for bios
```

We can start with a simple program. We can write a simple program that prints one character to
the screen. 

```
mov ah, 0x0e  ; set function to print character
mov al, 'Z' ; set character to print
int 0x10   ; print to screen
hlt  ; halt
```

This program can then be assembled into machine code, either using an assembler, or by assembling
by hand. For example, the first instruction `mov ah, 0e` corresponds to