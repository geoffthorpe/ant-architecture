# $Id: e_st_1.asm,v 1.1 2001/03/14 16:57:30 ellard Exp $
#@ tests for "underflow" in st.

	st	r3, r2, 0		# OK
	st	r3, r2, -1		# Not OK


