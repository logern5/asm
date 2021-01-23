# Bare Metal: Coding from scratch
## Chapter 1
Imagine you are in a room with a standard x86 PC, an old one from around
the 1990s. The computer has no drives except for a floppy drive, and no networking capabilities,
and you would like to program it. There is a floppy disk on the desk. Would it be 
possible to program it at all, without an operating system? What is the minimum 
software on that floppy needed to be able to program the computer? This
question was [asked](https://www.reddit.com/r/programming/comments/9x15g/programming_thought_experiment_stuck_in_a_room/)
on Reddit in 2010, and the answer is quite simple.

The minimum software a computer needs is a minimal "monitor" program to 
allow the user to enter machine code to run into the computer, which 
will be shown later in this next chapter.

In fact, many early computers were run just like this. The 1975 Altair 8800, regarded
as the first personal computer, took input from the front panel of switches, and flipping
the "DEPOSIT NEXT" switch inserted the code into memory. The 1976 Apple 1 and the original
1977 Apple II booted to a monitor program in ROM which allowed the user to view and change the
contents of memory, as well as running the code in memory.

This guide is made for x86 computers with BIOS, and not UEFI. As of 2020, Intel has deprecated
UEFI with CSM (legacy BIOS support), and new computers made from now forward will likely not
have BIOS support. However, a similar monitor program could be made to support UEFI.
A program similar in idea to this known as the UEFI Shell exists, which allows access to
FAT16 and FAT32 formatted filesystems. It allows NSH shell scripts, and includes a text
and hex editor (`hexedit`). The hex editor can edit files and memory. The `dmem` command
dumps memory. The `mm` command can modify and view addresses in memory also.

In this document I'll use some reference materials, namely:

* AMD64 Architechture Programmer's Manual Vol. 3 
* "x86 is an octal machine" by Mark Hopkins, available [here](https://gist.github.com/seanjensengrey/f971c20d05d4d0efc0781f2f3c0353da)
* Ralf Brown Interrupt List.

After we compile the initial monitor program, we won't need any additional software, compilers, 
or computers. I would highly recommend reading the essay "x86 is an octal
machine" as it explains the instruction set of the x86 very well.

With that in mind, let's start out with our initial monitor program.
The program will read octal bytes from the keyboard, store them in memory,
and execute them when a non-octal character is entered.

In the C programming language, the program would look something like this:

```
typedef void (*function)(); /* Define a function pointer type */
char program[64]; /* Area to store the program entered on the keyboard */
int main(void){
	char *ptr = program; /* Create a pointer to the program data storage */
	unsigned int i,n;
	/* Loop to read octal code from the keyboard */
	while(1){
		/* Read 3 octal numerals into one byte */
		for(i = 3; i > 0; i--){
			n = getchar() - '0'; /* Get one keypress and convert from ASCII char to number */
			if(n > 7) ((*function)program))(); /*If a numeral greater than 7 is entered, cast the program data to a function pointer and run the program */
			*t = *t * 8 + n; /* Incorporate numeral into the octal byte */
		}
		ptr++; /* Increment the pointer to store in the next byte */
	}
}	
```

Here is the monitor program, this time in NASM assembly. This will allow us to run any octal machine code
on the system. This code depends on the existence of BIOS on the system (or UEFI with CSM) as it uses
BIOS interrupt 0x10 to read input from the keyboard.:

```
[bits 16]		; use 16 bits
[org 0x7c00]		; set start address
 
jmp 0x0000:start	; make sure cs register is at 0x0000, not 0x7c00
start:			; initialize segment registers
xor ax, ax
mov ds, ax
mov es, ax
 
mov bx, program		; set pointer for program data
 
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
 
program:				; the program starts at 7c29
times 510-($-$$) db 0
dw 0xaa55				; magic number for bios
```
To compile the program on Linux, we can save this program as "monitor.asm" and run
`nasm monitor.asm -o monitor.bin`, and then create a blank floppy image with dd (`dd if=/dev/zero of=monitor.img count=1440 bs=1k`)
and write the monitor program to the boot sector (we are assuming the computer has BIOS)
with this dd command (`dd if=monitor.bin of=monitor.img conv=notrunc`). This floppy image can
be written to an actual disk or be ran in a virtual machine. This program can be written to a floppy disk,
or to a USB disk (which are emulated as hard disks from the BIOS). From now on, since we have a complete monitor program,
keeping with the spirit of the thought experiment, we won't be using any assembler programs on a seperate
computer.

We can test this program on the QEMU emulator, like so `qemu-system-i386 -fda monitor.img`.
We can also emulate the disk as as a hard disk (more realistically a USB drive) instead of a 
floppy: `qemu-system-i386 -hda monitor.img`.

We can start with a simple program. We can write a simple program that prints one character to
the screen. 

```
mov ah, 0x0e  ; set function to print character
mov al, 'Z' ; set character to print
int 0x10   ; print to screen
hlt  ; halt
```

This program can then be assembled into machine code, either using an assembler, or by assembling
by hand. For this program we will trying to assemble by hand. The first thing we need our program to do
is to move the value 0xE (octal 016) into register AH (high bit of register AX). According to the x86 octal
book, the instruction would be of the form `mov rb, db`, or move a defined byte into a byte register. Looking
at the octal reference, the opcode would be `26r Db`. The AH register's code is 4. So the full
instruction is `264 016`. Continuing on to the next instruction, we get an opcode of `260 132`.
The form of the code for an interrupt is `315 Db`, so for interrupt 0x10 (020), the opcode
would be `315 020`. Finally, the opcode for `hlt` is `364`.

If we want to test if our octal code, we can run these commands on linux to convert the octal to binary and
disassemble it.
```
printf "\264\016\260\132\315\020\364" > z.bin
objdump -b binary -D -Mintel,i8086 -m i386 z.bin
```

If we want to get the octal bytes back again, we can run od (octal dump) like so: `od -t o1 z.bin`.

Let's now test it out on our monitor. Boot up the floppy, and enter the assembled bytes, like so (without spaces):
```
264 016 260 132 315 020 364 8
```
If all goes well, a 'Z' should show up on the screen. The 8 at the end tells the monitor that we are done entering
octal code, and to go and execute our code. We successfully made a working program.

## Chapter 2: A more complex program

Now that we have printed a character to show that our octal monitor words, let's try a classic 'Hello World' program.
Now, think about the steps that the computer needs to do to print that 'Hello World' text. The computer needs to
retrieve each character from the string, and send it to the display. A pseudocode representation may look like this:

```
let pointer := string_addr
label loop_start
let a = *pointer
if a == 0 goto end
write_character(a)
incr pointer
goto loop_start
label end
halt
db 'Hello, world\0'
```
This is close to assembly, so we can can convert it. The octal reference is somewhat helpful for this, but the AMD
programmer's manual goes into more details, and the hex can be converted into octal:
```
[bits 16]
[org 0x7C29]
main:
mov ax, str 	                 ;Load the address of the string into reg AX
mov si, ax                      ;Load the source index register, commonly used as a pointer, with the contents from AX
lp:
lodsb			        ;Load String (lods) with contents of memory pointed to by SI (DS is 0x00), and increment SI automatically
mov ah, 0xe                     ;Set function to write string
int 0x10                        ;Call BIOS to write string
cmp al, 0x0                     ;Compare the contents of AL (the byte read) to 0 (end of string/null terminator)
je halt                         ;If we are at a null terminator, stop looping, jump to halt
jmp lp				;Otherwise, keep looping
halt:
hlt                             ;halt
str:
db 'Hello World',0x0              ;String to print
```

After assembling this (with a computer the addresses will automatically be calculated from labels, 
but by hand they need to be calculated manually), we can get an octal listing for this code:
```
0000000 270 071 174 211 306 254 264 016 315 020 074 000 164 002 353 365
0000020 364 110 145 154 154 157 040 127 157 162 154 144 000
0000035
```
Entering this into the monitor, with an '8' character at the end to start the program, the text 
'Hello World' should print.

## Disk I/O

Right now, we can only write programs by typing them in and loading them into RAM. We don't have any way
of saving programs yet to load them over and over again. Using the BIOS function INT 0x13, we can read and write
from disks, such as hard disks and floppy disks. We can create a program to write to the floppy disk.
The BIOS function INT 0x13 takes some parameters. When AH=3, this means that the function to write to disk
is chosen. AL is the number of sectors to write, CH is the cylinder number,CL is the sector number, DH is the head
number, DL is the drive number (0 for drive A), and ES:BX is the buffer for the data (in this case, we just have
the ES segment register set to 0, so we load the address of our buffer into BX).

We will be writing the program to write to the disk:
```
code
```

We can create another floppy image for storing our code with dd: `dd if=/dev/zero of=user.img bs=1k count=1440`.
Let's look at the octal listing of our code:

If we want to boot in qemu and allow writing to the boot floppy on block 0
(first 1024 bytes), we need to specify the raw format like so: `qemu-system-i386 -drive format=raw,media=floppy,file=monitor.img`.

And now we can boot our monitor program. Now, we don't want to overwrite our existing monitor program,
so after the monitor loads, we need to change our floppy disk to the one we created.
After booting up qemu, for example, we can change the floppy in the monitor (Ctrl-Alt-2) like so:
`change floppy0 user.img raw`. Now, we can press Ctrl-Alt-1 to switch back to our monitor. We can
now enter the octal code and run it.

The data now should have been written to the floppy, and it can be confirmed if you are using an emulated
machine, for example `hexdump -C user.img` and `objdump -b binary -D -Mintel,i8086 -m i386 user.img`.

Now, we need a program to read from the floppy and execute code. Let's write a program to load code from the
floppy to a specified address, let's say 0x4000 to make it easy. The code will be very similar to the writer code.
We can use some tricks to make the code shorter, such as moving to 16-bit registers instead of the 8 bit registers.
We can get a 16-byte loader program:
```
[bits 16]
[org 0x7C29]
mov ax, 0x0201  ; AH=2 (read), AL=1 (read 1 sector)
mov cx, 0x0001  ; CH=0 (track 0), CL=1 (sector 1
xor dx, dx      ; DL=0 (disk 0), DH=0 (head 0)
mov bx, 0x4000  ; Address of buffer for data to read. 0.5kb * 18 spt * 80 tph * 2 h = 1440 KB capacity
push bx         ; Save address for when we need to jump to it
int 0x13        ; Read the data
pop ax          ; Get address we saved
inc ax          ; Increment it as we ignore the first byte
jmp ax          ; Jump to the data
```

The octal code (from `od -t o1`):
```
0000000 270 001 002 271 001 000 061 322 273 000 100 123 315 023 130 100
0000020 377 340
0000022
```

Booting up the monitor, changing the disk to the previous written one, and then entering the octal code, we should get
the text 'Z' on the screen. We have now successfully written to and read from the disk.

## Conclusion
With this knowledge, and a monitor program, more and more complex programs can be made. Games, word processors,
operating systems. Anything that the system has the resources to run is possible by working up from here. There are x86
instructions to switch from the legacy 16-bit mode that the system boots up in, to 32-bit mode, and also to 64-bit mode.
