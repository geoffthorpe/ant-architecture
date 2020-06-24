# $Id: e_st_2.asm,v 1.1 2001/03/14 16:57:30 ellard Exp $
#@ tests for invalid args to st.

	st	r3, r2, 0		# OK
	st	r3, r2, r0		# Not OK

