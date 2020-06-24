#@ tests gts

	lc	r3, 2
	lc	r4, 1
	lc	r5, -2

	gts	r7, r3, r2	#should store 1 into r7
	gts	r8, r2, r3	#puts 0 into r8
	gts	r9, r5, r4	#should put 0 into r9
	gts	r10, r4, r5	#should load 1 into r10

	stop	
