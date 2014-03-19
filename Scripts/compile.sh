#!/bin/bash

FILENAME=$(basename $1 .asm)

echo "[+] Assembling $1 with nasm ..."
nasm -f elf32 -o $FILENAME.o $FILENAME.asm
if [ "$?" -ne "0" ]; then
	exit $?
fi

echo "[+] Linking ..."
ld -melf_i386 -o $FILENAME $FILENAME.o
EXIT=$?
rm -rf $FILENAME.o
if [ "$EXIT" -ne "0" ]; then
	exit $EXIT
fi

echo "[+] Done"

