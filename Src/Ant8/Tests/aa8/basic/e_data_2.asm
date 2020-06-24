# $Id: e_data_2.asm,v 1.1 2001/03/14 16:57:28 ellard Exp $
#@ tests that _data_ cannot be redefined.
#@ This should be handled as a label redefinition.

_data_:
	.byte	0, 1, 2, 3, 4, 5, 6, 7	# OK
_data_:					# Ooops!
	.byte	0, 1, 2, 3, 4, 5, 6, 7	# OK


