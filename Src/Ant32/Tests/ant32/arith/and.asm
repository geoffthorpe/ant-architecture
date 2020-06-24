#@tests and

	lc	r3, 1
	and	r6, r3, r0
	and	r7, r3, r3
	and	r8, r0, r0

	lch	r3, 0xf0f0
	lch	r4, 0x0f0f

	and	r5, r4, r3

	stop



