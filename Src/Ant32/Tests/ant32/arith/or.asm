#@tests or

	lc	r3, 1
	or	r6, r3, r0
	or	r7, r3, r3
	or	r8, r0, r0

	lch	r3, 0xf0f0
	lch	r4, 0x0f0f

	or	r5, r4, r3

	stop



