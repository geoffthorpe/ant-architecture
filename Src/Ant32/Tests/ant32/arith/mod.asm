#@tests mod

	lc	r3, 13
	lc	r4, 10
	mod	r5, r3, r4
	mod	r6, r4, r5
	mod	r7, r4, r4
	mod	r8, r0, r4
	
	stop
