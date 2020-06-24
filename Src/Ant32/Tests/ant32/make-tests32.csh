#!/bin/csh -f
#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Creates the .a32, .core and .out files used by the Ant32 regression
# tests.
#
# Assumes that AA8_EXE and ANT8_EXE both refer to a working and
# correct versions of aa8 and ant8.  If this is not true, then
# everything created is utter trash.

set	AA32_EXE	= "../../aa32"
set	ANT32_EXE	= "../../ant32"

foreach a ( */*.asm )
	echo "$a"
	set p = "$a:r"
	rm -f "$p.out" "$p.a32" "$p.core" 

	"$AA32_EXE" "$a"
	if ($status != 0) then
		echo "WARNING: Test $p failed to assemble."
		echo "	(that's probably a bad thing)"
	else
		"$ANT32_EXE" "-d" "$p.a32" > "$p.out"
		if (-e ant32.core) then
			mv ant32.core "$p.core"
		else
			echo "WARNING: Test $p didn't leave a core file."
			echo "	(that's probably a bad thing)"
		endif
	endif
end

# end of make-tests32.csh
