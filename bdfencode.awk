#! /usr/bin/awk -f
#
# Encode a font.  Standard input or command line file name is input, output
# to standard output.
#
# Source font should be in BDF format, but with ASCII characters representing
# bits between BITMAP and ENDCHAR lines.  Any char <= 0 will be taken as a 0
# bit, anything > '0' a 1.  Only bits inside the bounds defined by the 
# preceding BBX line are considered counted and missing characters or lines
# are padded out.
#
# Use bdfdecode.awk to decode an existing font file to the above format.
#
# CHARS is recomputed, so that characters can be inserted into a decoded
# font file.  (Remember to set the ENCODING line for each new character.)
#

$1 == "ENDCHAR"	{ 
	bm = 0
	if(row != rows) print "Character", char, "bad size" >"/dev/stderr"
	while(row++ < rows) {
		for(i = 0; i < bits; i += 8)
			out = out "00"
		out = out "\n"
	}
}

$1 == "CHARS" {
	body = 1
	next
}

$1 == "BBX" {
	bits = $2
	rows = $3
}

$1 == "STARTCHAR" {
	c = $2
	chars++
}
$1 == "ENCODING" {
	char = $2
}

bm { 
	if(row++ >= rows) next
	for(i = 0; i < bits ; i += 8) {
		n = 0
		for(j = 1; j <= 8; j++) {
			n = n * 2
			if(substr($0, i+j, 1) > "0") n++
		}
		out = sprintf("%s%02x", out, n)
	}
	out = out "\n"
}

!bm { 
	if(body) out = out $0 "\n"
	else	 print
}

$1 == "BITMAP" {
	bm = 1
	row = 0
}

END {
	printf "CHARS %d\n%s", chars, out
}
