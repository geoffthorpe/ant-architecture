	addio     r28, r29, 16702650	# fedcba
	addio     r28, r29, 16702650	# fedcba
label0:	addio     r28, r29, 65535	# ffff
	addio     r28, r29, $label0	# abcde
	subio     r28, r29, 16702650	# fedcba
	subio     r28, r29, 16702650	# fedcba
label1:	subio     r28, r29, 65535	# ffff
	subio     r28, r29, $label2	# abcde
	mulio     r28, r29, 16702650	# fedcba
	mulio     r28, r29, 16702650	# fedcba
label2:	mulio     r28, r29, 65535	# ffff
	mulio     r28, r29, $label1	# abcde
