#ifndef _AESCTRCOMMON_H_
#define _AESCTRCOMMON_H_

#include <openssl/aes.h>

typedef struct
{
	unsigned char ivec[AES_BLOCK_SIZE];
	unsigned char ecount_buf[AES_BLOCK_SIZE];
	unsigned int  num;
	AES_KEY key;
} aes_ctr_t;

void init_aes_ctr(aes_ctr_t *, unsigned char (*iv)[8], const unsigned char *enc_key, int);
void aes_ctr_enc(unsigned char *in, unsigned char *out, int len, aes_ctr_t *);
void aes_ctr_enc_msg(unsigned char *msg, int len, aes_ctr_t *);

#endif //_AESCTRCOMMON_H_
