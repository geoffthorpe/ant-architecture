#@tests xor

	lc	r3, 1
	xor	r6, r3, r0
	xor	r7, r3, r3
	xor	r8, r0, r0

	lch	r3, 0xf0f0
	lch	r4, 0x0f0f

	xor	r5, r4, r3

	stop



