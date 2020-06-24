#tests leh by forcing an exception and jumpin
#tests leh

#first, we have to generate an exception

	leh	$handler
	cle
	lcl	r3, 54
	div	r0, r3, r0	#oops!

	stop

handler:

# we will know from the core if we ever got here or not

	lcl 	r10, 10

