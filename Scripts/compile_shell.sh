#!/bin/bash

FILENAME="$(tempfile --suffix .c)"

SHELL=$(readlink -f $1)
SHELL_OUT="$(basename $1 .shell)_shell"

cat > $FILENAME <<EOF
#include <stdio.h>
#include <string.h>

unsigned char code[] = 
#include "$SHELL"
;

int main(int argc, char *argv[])
{
	printf("Shellcode Length: %d\\n", (int)strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

	return 0;
}
EOF

gcc -m32 -fno-stack-protector -z execstack -o $SHELL_OUT $FILENAME

rm -rf $FILENAME
