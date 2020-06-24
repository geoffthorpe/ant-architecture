#tests leh by forcing an exception and jumpin
#tests leh

#first, we have to generate an exception
#and then make the program try to junp to an
#illegal instruction

	leh	0
	cle
	lcl	r3, 54
	div	r0, r3, r0	#oops!

	stop

