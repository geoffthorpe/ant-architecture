#@tests mul

	lc 	r3, 100

	mul	r4, r3, r3
	mul 	r5, r4, r4
	mul	r6, r5, r5

# this next should overflow

	mul	r7, r6, r6

	stop

