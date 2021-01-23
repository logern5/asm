[bits 16]
[org 0x7C29]
main:
mov ax, 0x0301 	; AH=03 (write), AL=01 (write 1 sector)
mov cx, 0x0001	; CH=0 (track 0), CL=1 (sector 1, sectors start at 1)
xor dx, dx	; DH=0 (head 0), DL=0 (drive 0)
mov bx, data	; Address of data to write. 0.5kb * 18 spt * 80 tph * 2 h = 1440 KB capacity.
int 0x13	; Write the data
data_m1:	; This is needed because INT 0x13,AH=02 (read data) modifies the first byte
nop
data:
mov ah, 0xe
mov al, 'Z'
int 0x10
hlt
