# $Id: e_lc_0.asm,v 1.1 2001/03/14 16:57:29 ellard Exp $
#@ tests for overflow in lc.

	lc	r2, 255		# OK
	lc	r2, 256		# Not OK


