# $Id: e_jmp_3.asm,v 1.1 2001/03/14 16:57:29 ellard Exp $
#@ tests for register arg to jmp.

	jmp	2	# OK
	jmp	r2	# Not OK

