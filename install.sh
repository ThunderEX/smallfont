#!/bin/sh
#
# Install small fonts
# FONTDIR should point to the "misc" fonts directory
#
if [ "${0%/*}" = "$0" ]
then	LDIR=$PWD
else	LDIR="${0%/*}"
fi

if [ "$1" != "" ]
then	FONTDIR="$1"
	test "$FONTDIR" = "${FONTDIR#/}" && FONTDIR="$PWD/$FONTDIR"
	if ! test -s "$FONTDIR/fonts.dir"
	then	echo "$FONTDIR/fonts.dir not found."
		exit 1
	fi
else	FONTDIR=
	for dir in /usr/share/X11/fonts/misc /usr/local/share/X11/fonts/misc \
		   /usr/lib/X11/fonts/misc   /usr/local/lib/x11/fonts/misc
	do	test -s "$dir/fonts.dir" && FONTDIR="$dir"
	done
	if [ "$FONTDIR" = "" ]
	then	echo "Could not find fonts/misc,  Supply full path."
		exit 1
	fi
fi

if ! test -w "$FONTDIR" -a -w "$FONTDIR/fonts.dir"
then	echo "Insufficient privilege to install fonts in $FONTDIR."
	exit 1
fi

echo "Installing PCF files into $FONTDIR ..."
bdftopcf "$LDIR/5x9.bdf"  | gzip > "$FONTDIR/5x9.pcf.gz"
bdftopcf "$LDIR/5x10.bdf" | gzip > "$FONTDIR/5x10.pcf.gz"

echo "Running mkfontdir $FONTDIR ..."
mkfontdir "$FONTDIR"

echo "Updating $FONTDIR/fonts.alias ..."
grep -q '^5x9 ' "$FONTDIR/fonts.alias" >/dev/null || 
					cat >>"$FONTDIR/fonts.alias" <<EOF
5x9          -gnu-fixed-medium-r-normal--9-100-75-75-c-50-iso8859-1
EOF
grep -q '^5x10 ' "$FONTDIR/fonts.alias" >/dev/null ||
					 cat >>"$FONTDIR/fonts.alias" <<EOF
5x10         -gnu-fixed-medium-r-normal--10-100-75-75-c-50-iso8859-1
EOF

echo ""
echo "Reload xfs and/or restart X session to complete install."

exit 0
