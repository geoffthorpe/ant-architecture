# $Id: e_ld_1.asm,v 1.1 2001/03/14 16:57:30 ellard Exp $
#@ tests for "underflow" in ld.

	ld	r3, r2, 0		# OK
	ld	r3, r2, -1		# Not OK


