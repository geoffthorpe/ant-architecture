#!/bin/csh -f
#
# $Id: make-tests.csh,v 1.2 2001/03/19 16:21:47 ellard Exp $
#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Creates the .ant, .core and .out files used by the ad8 regression
# tests.
#
# Assumes that AA8_EXE and AD8_EXE both refer to a working and
# correct versions of aa8 and ad8.  If this is not true, then
# everything created is utter trash.

set	AA8_EXE		= "../../aa8"
set	AD8_EXE		= "../../ad8"

foreach a ( */*.asm )
	echo "$a"
	set p = "$a:r"
	rm -f "$p.out" "$p.ant" "$p.core" 

	"$AA8_EXE" "$a"
	if ($status != 0) then
		echo "WARNING: Test $p failed to assemble."
		echo "	(that's probably a bad thing)"
	else
		grep '#>>' $a | sed -e 's/^...//' | \
				"$AD8_EXE" -g "$p.ant" > "$p.out"
		if (-e ad.core) then
			mv ad.core "$p.core"
		else
			echo "WARNING: Test $p didn't leave a core file."
			echo "	(that's probably a bad thing)"
		endif
	endif
end

# end of make-tests.csh
