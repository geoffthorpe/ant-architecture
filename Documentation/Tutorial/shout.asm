# Dan Ellard - 05/10/2000
#	An Ant-8 program that echos input until EOI is reached,
# converting from lowercase to uppercase.
# Register usage:
# r2 - holds each character read in
# r3 - address of $process
# r4 - address of $print
# r5 - address of $uppercase
# r6 - 'a', the smallest lowercase ASCII value (0x61)
# r7 - 'z', the largest lowercase ASCII value (0x7A)
# r8 - the mask to convert from lowercase to uppercase

        lc      r3, $process
        lc      r4, $print
	lc	r5, $uppercase
	lc	r6, 'a'
	lc	r7, 'z'

	lc	r8, 1		# set r8 to 1.
	lc	r9, 5
	shf	r8, r8, r9	# slide over the 1 by 5 positions
	nor	r8, r8, r8	# and then use nor to flip all the bits

loop:
        in      r2, ASCII       # r2 = getchar ();
        beq     r3, r1, r0      # if not at EOF, go to $process.
        jmp     $exit           # otherwise, go to $exit.
process:
	bgt	r4, r2, r7	# if the char is > 'z', just print it
	beq	r5, r2, r6	# else if the char is 'a', uppercase it
	bgt	r5, r2, r6	# else if the char is > 'a', uppercase it
	jmp	$print		# else the char is < 'a', so just print it
uppercase:
	and	r2, r2, r8	# zero the fifth bit of r2
print:
        out     r2, ASCII	# putchar (r2);
        jmp     $loop           # iterate, go back to $loop.
exit:
        hlt                     # Exit

# end of shout.asm
