# $Id: e_lc_1.asm,v 1.1 2001/03/14 16:57:29 ellard Exp $
#@ tests for underflow in lc.

	lc	r2, -128	# OK
	lc	r2, -129	# Not OK

