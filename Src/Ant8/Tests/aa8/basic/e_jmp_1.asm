# $Id: e_jmp_1.asm,v 1.1 2001/03/14 16:57:29 ellard Exp $
#@ tests for "underflow" in jmp. (weird!)

	jmp	-100		# OK
	jmp	-200		# Not OK


