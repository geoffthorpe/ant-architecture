# Dan Ellard -- 01/20/2000
# loop.asm --
# Registers used:
# r2 - used to hold the character to print.
# r3 - used to hold the number of times to print the character.
# r4 - used to hold the address of the end of the loop.

	lc	r4, $endloop	# r4 is the address of the end of the loop.
	in	r2, ASCII	# Get the character to print
	in	r3, Hex		# Get the number of times to print it
loop:
	beq	r4, r0, r3	# if r3 is zero, branch to $endloop.
	bgt	r4, r0, r3	# if r3 < zero, branch to $endloop.
	out	r2, ASCII	# print the character.
	inc	r3, -1		# decrement r3.
	jmp	$loop		# jump to $loop, to repeat the process.

endloop:
	hlt	 		# Halt

# end of loop.asm
