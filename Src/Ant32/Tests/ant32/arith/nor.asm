#@tests nor

	lc	r3, 1
	nor	r6, r3, r0
	nor	r7, r3, r3
	nor	r8, r0, r0

	lch	r3, 0xf0f0
	lch	r4, 0x0f0f

	nor	r5, r4, r3

	stop



