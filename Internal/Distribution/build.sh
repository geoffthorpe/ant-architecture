#!/bin/csh -f
# $Id: build.sh,v 1.6 2002/04/16 14:45:17 ellard Exp $

# BSDI uses a painfully archaic version of make.

if ( $HOSTTYPE == "bsd386" ) then
	set MAKE = "gmake"
else
	set MAKE = "make"
endif

if ( $#argv != 0 ) then
	set VERSION = $argv[1]
else
	set VERSION = `cat ../../CurrVersion`
	echo ""
	echo -n "Type current version [default=$VERSION]: "
	set nv = $<
	if ("$nv" != "") then
		set VERSION = "$nv"
	endif
endif

set here = `pwd`

foreach dir ( AntCommon Ant8/Lib8 Ant8 Ant32/Lib32 Ant32  )

	cd "$here/../../Src/$dir"
	echo "Building in `pwd`"
	$MAKE clean
	$MAKE ANT_LIB_VERSION=-DANT_LIB_VERSION=\\\"$VERSION\\\"
	echo ".../AntCommon done "
	echo " "
end

exit $status

