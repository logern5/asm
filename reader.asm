[bits 16]
[org 0x7C29]
mov ax, 0x0201	; AH=2 (read), AL=1 (read 1 sector)
mov cx, 0x0001	; CH=0 (track 0), CL=1 (sector 1
xor dx, dx	; DL=0 (disk 0), DH=0 (head 0)
mov bx, 0x4000	; Address of buffer for data to read. 0.5kb * 18 spt * 80 tph * 2 h = 1440 KB capacity
push bx		; Save address for when we need to jump to it
int 0x13	; Read the data
pop ax		; Get address we saved
inc ax		; Increment it as we ignore the first byte
jmp ax		; Jump to the data
