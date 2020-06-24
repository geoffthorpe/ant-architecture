# $Id: e_add_0.asm,v 1.1 2001/03/14 16:57:28 ellard Exp $
#@ tests for bogus registers in add.

	add	r0, r0, r0	# OK
	add	r1, r1, r1	# OK
	add	r2, r2, r2	# OK
	add	r3, r3, r3	# OK
	add	r4, r4, r4	# OK
	add	r5, r5, r5	# OK
	add	r6, r6, r6	# OK
	add	r7, r7, r7	# OK
	add	r8, r8, r8	# OK
	add	r9, r9, r9	# OK
	add	r10, r10, r10	# OK
	add	r11, r11, r11	# OK
	add	r12, r12, r12	# OK
	add	r13, r13, r13	# OK
	add	r14, r14, r14	# OK
	add	r15, r15, r15	# OK
	add	r16, r16, r16	# Not OK

