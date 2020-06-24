#@tests div

	lc	r3, 5
	lc	r4, 10

	div	r5, r4, r3
	div	r6, r3, r5		#fractional
	div	r0, r3, r0		#div-by-0 exception
