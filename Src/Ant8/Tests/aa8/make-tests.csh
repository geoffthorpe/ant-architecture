#!/bin/csh -f
#
# $Id: make-tests.csh,v 1.2 2001/03/14 17:04:04 ellard Exp $
#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Creates the .ant and .out files used by the regression tests.
#
# Assumes that AA8_EXE refers to a working and correct aa8.
# If this is not true, then everything created is utter trash.

set	AA8_EXE		= "../../aa8"

foreach a ( */*.asm )
	echo "$a"
	set p = "$a:r"
	rm -f "$p.out" "$p.ant"
	"$AA8_EXE" "$a" | sed -e 's/^.*\/\([^:/]*\):/\1:/' > "$p.out"
end

# end of make-tests.csh

