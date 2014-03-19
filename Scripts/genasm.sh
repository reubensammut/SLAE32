#!/bin/bash

cat > $1.asm <<EOF
; Filename: $1.asm
; Author:   Reuben Sammut
; SLAE ID:  510

global _start

section .text

_start:


EOF
vim $1.asm
