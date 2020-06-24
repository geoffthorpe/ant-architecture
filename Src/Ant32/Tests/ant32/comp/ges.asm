#@ tests ges

	lc	r3, 1
	lc	r4, 2
	lc	r5, -1
	lc	r6, -2

	ges 	r7, r4, r6	#loads 1 into r7
	ges	r8, r6, r4	#loads 0 into r8
	ges	r9, r4, r4	#loads 1 into r9
	ges 	r10, r3, r6	#loads 1 into r10
	ges	r11, r6, r3	#loads 0 into r11

	stop
