# $Id: e_inc_0.asm,v 1.1 2001/03/14 16:57:28 ellard Exp $
#@ tests for "overflow" in inc.

	inc	r2, 255		# OK
	inc	r2, 256		# Not OK


