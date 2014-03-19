#/bin/bash

FILENAME=$1
OUTPUT="$1.shell"

objdump -d $FILENAME | grep -E "^ [0-9a-fA-F]+:" | cut -f 2 | sed -e "s/ \+/ /g; s/ $/\"/g; s/^/\"\\\x/g; s/ /\\\x/g" > $OUTPUT
