# $Id: e_jmp_2.asm,v 1.1 2001/03/14 16:57:29 ellard Exp $
#@ tests for undefined symbol jmp.

	jmp	$foo	# OK
foo:
	jmp	$bar	# Not OK

