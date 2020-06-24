# $Id: e_data_1.asm,v 1.1 2001/03/14 16:57:28 ellard Exp $
#@ tests that .bytes in the text segment are illegal.

	add	r2, r3, r3		# OK
	.byte	0, 1, 2, 3, 4, 5, 6, 7	# Not OK
_data_:
	.byte	0, 1, 2, 3, 4, 5, 6, 7	# OK


