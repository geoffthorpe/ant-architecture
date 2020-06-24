# stripcom, in ANT.
# regs:
#	r2	input char
#	r3	$s0
#	r4	$s1
#	r5	$s2
#	r6	$s3
#	r7	s0_1
#	r8	'/'
#	r9	'*'

	lc	r3, $s0
	lc	r4, $s1
	lc	r5, $s2
	lc	r6, $s3
	lc	r7, $s0_1
	lc	r8, '/'
	lc	r9, '*'

# top of input loop, outside of comment
s0:	sys	r2, 6		# r2 = getchar
	beq	r7, r1, r0	# if c != EOF
	jmp	$end  		# c == EOF, so => end

s0_1:	beq	r4, r2, r8	# if c == '/' => s1
	sys	r2, 3		# putchar(c)
	jmp	$s0   		# back to top

# seen a /, maybe starting a comment
s1:	sys	r2, 6		# r2 = getchar
	beq	r5, r2, r9	# goto s2 if *
	sys	r8, 3		# putchar('/')
	sys	r2, 3		# putchar(c)
	jmp	$s1   		# back to s1

# seen /*, inside a comment
s2:	sys	r2, 6		# r2 = getchar
	beq	r6, r2, r9	# goto s3 if '*'
	jmp	$s2  		# back to s2

# seen *, maybe ending a comment
s3:	sys	r2, 6		# r2 = getchar
	beq	r3, r2, r8	# back to top if '/'
	jmp	$s3 		# back to s3

end:	sys	r0, 0		# halt

