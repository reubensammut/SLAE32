#/bin/bash

FILENAME=$1
OUTPUT="$1.shell"

objdump -d $FILENAME | grep -E '^ [0-9a-f]*:' | cut -f 2 | paste -s -d' ' | sed -E 's/\ +/ /g; s/\ $//g; s/\ /\\x/g; s/^/\\x/g;' | sed -E 's/(.{80})/\1\n/g' | sed -E 's/^/"/g; s/$/"/g' > $OUTPUT
