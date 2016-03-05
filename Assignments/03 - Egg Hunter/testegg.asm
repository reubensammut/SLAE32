; Filename: testegg.asm
; Author:   Reuben Sammut
; SLAE ID:  510

global _start

section .text

_start:
	xor eax, eax
	mov ebx, eax
	cdq

	mov al, 0x4
	mov bl, 0x1
	
	push 0x0a
	push word 0x293a
	push 0x2021656d
	push 0x20646e75
	push 0x6f662075
	push 0x6f59202e
	push 0x6574656c
	push 0x706d6f63
	push 0x20736920
	push 0x746e7568
	push 0x20676765
	push 0x20656854
	mov ecx, esp

	mov dl, 0x2B
	int 0x80

	mov al, 0x1
	xor ebx,ebx
	int 0x80


	


