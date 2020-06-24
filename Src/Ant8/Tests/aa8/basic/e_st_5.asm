# $Id: e_st_5.asm,v 1.1 2001/03/14 16:57:31 ellard Exp $
#@ tests for invalid args to st.

	st	r3, r2, 0		# OK
	st	r3, 0			# Not OK

