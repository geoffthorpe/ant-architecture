#@tests add

	lc	r3, 15
	lc	r4, 3

	add	r5, r4, r3
	
	lcl 	r3, 0xffff
	lch	r3, 0xffff
	lcl	r4, 1
	
	add	r6, r4, r3

	stop
