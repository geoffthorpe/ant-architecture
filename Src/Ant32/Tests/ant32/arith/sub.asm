#@tests sub

	lc	r3, 15
	lc	r4, 3

	sub	r5, r4, r3

	lcl	r3, 0xffff
	lch	r3, 0xffff
	lc	r4, 1
	
	sub	r6, r3, r4

	stop
