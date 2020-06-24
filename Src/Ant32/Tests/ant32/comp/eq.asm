#@ tests eq

	lc 	r3, 4
	lc 	r4, 4
	eq 	r5, r4, r3 	#1 should be stored in r5
	lc 	r6, 5
	eq	r7, r5, r3	#0 should be stored in r7

	stop
