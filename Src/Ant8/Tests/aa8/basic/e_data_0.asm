# $Id: e_data_0.asm,v 1.1 2001/03/14 16:57:28 ellard Exp $
#@ tests that instructions in the data segment are illegal.

_data_:
	.byte	0, 1, 2, 3, 4, 5, 6, 7	# OK
	add	r2, r3, r3		# Not OK


