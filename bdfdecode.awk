#! /usr/bin/awk -f


$1 == "BBX" {
	bits = $2
	rows = $3
	bottom = $5
}

$1 == "ENDCHAR" {
	bm = 0
	while(row++ < rows)
		printf "%.*s", bits, ""
}

$1 == "ENCODING" {
	if($2 >= 32 && $2 < 127 && $2 != 34)
		printf "COMMENT \"Character '%c'\"\n", $2
}

bm { 
	if(row++ >= rows) next
	sp = " "
	if(row == rows + bottom) sp = "."
	for(i = 1; i <= length($1); i++) {
		n = index("123456789abcdef", 
			tolower(substr($1,i,1)))
		s = ""
		for(j = 0; j < 4; j++) {
			if(n % 2) s = "o" s
			else	  s = sp  s
			n = int(n/2)
		}
		printf "%s", substr(s, 1, bits - (i-1) * 4)
	}
	print ""
}

!bm { 
	print
}

$1 == "BITMAP" {
	bm = 1
	row = 0
}
