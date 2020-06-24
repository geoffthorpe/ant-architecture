# $Id: e_ld_0.asm,v 1.1 2001/03/14 16:57:30 ellard Exp $
#@ tests for "overflow" in ld.

	ld	r3, r2, 15		# OK
	ld	r3, r2, 16		# Not OK

