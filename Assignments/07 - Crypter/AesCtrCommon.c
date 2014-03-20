#include <openssl/rand.h>
#include <openssl/sha.h>

#include <string.h>

#include "AesCtrCommon.h"

void
gen_random_bytes(unsigned char *buf, int len)
{
	do
	{
		RAND_bytes(buf, len);
	} while (memchr(buf, '\0', len) != NULL); 
}

void
set_aes_key(aes_ctr_t *state, const unsigned char *enc_key)
{
	int key_len = strlen(enc_key);
	int i;
	unsigned char hash[SHA256_DIGEST_LENGTH];
	unsigned char *key1 = hash, *key2 = hash + 8;
	SHA256_CTX sha256;

	SHA256_Init(&sha256);
	SHA256_Update(&sha256, enc_key, key_len);
	SHA256_Final(hash, &sha256);

	for(i = 0; i < 8; ++i)
	{
		key1[i] ^= key2[i];
	}

	AES_set_encrypt_key(key1, 128, &state->key);
}

void 
init_aes_ctr(aes_ctr_t *state, unsigned char (*iv)[8], const unsigned char *enc_key, int initIV)
{
	state->num = 0;

	memset(state->ecount_buf, 0, AES_BLOCK_SIZE);
	memset(state->ivec, 0, AES_BLOCK_SIZE);

	if( initIV )
	{
		unsigned char buf[8];

		gen_random_bytes(buf, 8);

		memcpy(iv, buf, 8);
	}

	memcpy(state->ivec, iv, 8);

	set_aes_key(state, enc_key);
}

void 
aes_ctr_enc(unsigned char *in, unsigned char *out, int len, aes_ctr_t *state)
{
	AES_ctr128_encrypt(in, out, len, &state->key, state->ivec, state->ecount_buf, &state->num);
}

void 
aes_ctr_enc_msg(unsigned char *msg, int len, aes_ctr_t *state)
{
	int i;
	unsigned char encrypted[AES_BLOCK_SIZE];

	for (i = 0; i < len; i+= AES_BLOCK_SIZE)
	{
		int size = (i + AES_BLOCK_SIZE) > len ? len % AES_BLOCK_SIZE : AES_BLOCK_SIZE;
		aes_ctr_enc( msg + i, encrypted, size, state );
		memcpy( msg + i, encrypted, size );
	}
}
