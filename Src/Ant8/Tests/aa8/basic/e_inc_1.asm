# $Id: e_inc_1.asm,v 1.1 2001/03/14 16:57:28 ellard Exp $
#@ tests for "underflow" in inc.

	inc	r2, -128	# OK
	inc	r2, -129	# Not OK

