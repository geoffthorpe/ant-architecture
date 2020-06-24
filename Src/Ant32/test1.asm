	addi     r28, r29, 16702650	# fedcba
	addi     r28, r29, 16702650	# fedcba
label0:	addi     r28, r29, 65535	# ffff
	addi     r28, r29, $label4	# abcde
	subi     r28, r29, 16702650	# fedcba
	subi     r28, r29, 16702650	# fedcba
label1:	subi     r28, r29, 65535	# ffff
	subi     r28, r29, $label3	# abcde
	muli     r28, r29, 16702650	# fedcba
	muli     r28, r29, 16702650	# fedcba
label2:	muli     r28, r29, 65535	# ffff
	muli     r28, r29, $label2	# abcde
	divi     r28, r29, 16702650	# fedcba
	divi     r28, r29, 16702650	# fedcba
label3:	divi     r28, r29, 65535	# ffff
	divi     r28, r29, $label1	# abcde
	modi     r28, r29, 16702650	# fedcba
	modi     r28, r29, 16702650	# fedcba
label4:	modi     r28, r29, 65535	# ffff
	modi     r28, r29, $label0	# abcde
