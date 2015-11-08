#!/bin/bash

function convert_to_hex() {
	local input=$1
	echo "obase=16;ibase=10;$input" | BC_LINE_LENGTH=9999 bc
}

function pad() {
	local len=$1
	local pad=$2
	local val=$3
	echo $val | awk -v len="$len" -v pad="$pad" '{ l = (len - length % len) % len; printf "%.*s%s\n", l, pad, $0}'
}

function push_fmt() {
	local input=$1
	echo $input | sed -E 's/(.{2})(.{2})/\\\\x\1\\\\x\2/g'
}

port_hex=$(convert_to_hex $1)
port_hex_pad=$(pad 4 "0000" $port_hex)
port_shell=$(push_fmt $port_hex_pad)

sed -E 's/PORTPORT/'"$port_shell"'/g' bindtcp_conf.shell
