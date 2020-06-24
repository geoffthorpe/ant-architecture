# $Id: bigadd.asm,v 1.4 2001/03/22 00:41:28 ellard Exp $
#
# Dan Ellard -- 05/15/2000
#
# bigadd -
#
# Add large numbers, by using more than one byte to represent each
# number.  The method used is to use an array of bytes to represent
# each number.  In this implementation, each byte of the array
# represents a single decimal digit of the number.  (This is very
# inefficient, since each byte could be used to hold a much larger
# number, but this is enough to demonstrate the idea.) The number of
# digits in each array is currently 32, so we can find sums up to
# 99999999999999999999999999999999, which is pretty large.
#
# Halts when EOF is reached.
#
# Computes and prints a running total of decimal numbers (up to 32
# digits long) supplied by the user.
#
# An example session of the program would look like:
#
#	+ 10
#	10
#	+ 10
#	20
#	+ 1000
#	1020
#	+ 99999999990000
#	99999999991020
#
# General structure of the code:
#
# Main Loop:
#	Print the prompt "+ "
#	Clear out the temp number array.
#	Wait for the user to type a number, up to 32 characters
#		in length, and store it in the temp number array.
#	Add the temp number to the sum number, by adding digit-by-digit
#		and keeping track of the overflow from each digit.
#	Print the sum number, digit by digit.
#	Repeat Main Loop.
#
# General register usage (throughout the code):
#
# r2	- DIGITS: the number of decimal digits per number, currently 32.
# r3	- the base of the temp array.
# r4	- the base of the sum array.
# r12	- scratch register used for address calculations
# r13	- the BASE (currently the constant 10).
# r14	- scratch register, used to hold overflow.
# r15	- scratch register, used for most constants.

	lc	r2, 32 
	lc	r3, $temp
	lc	r4, $sum
	lc	r13, 10

main_loop:
	# prompt the user for a number:
	lc	r15, '\n'
	out	r15, ASCII
	lc	r15, '+'
	out	r15, ASCII
	lc	r15, ' '
	out	r15, ASCII

number_get:

	# Before reading in the new number into temp, we need to clear
	# out the old one (entirely).  To do so, just fill it with
	# zeros.

	# local register usage:
	# r5	- index into the temp number.

	lc	r5, 0

zero_loop:
	lc	r15, $end_zero_loop
	beq	r15, r5, r2

	add	r12, r3, r5
	st	r0, r12, 0

	inc	r5, 1

	jmp	$zero_loop

end_zero_loop:
	# local register usage:
	# r5	- index into the temp number.
	# r6	- the char read in from the user.
	# r7	- used to hold a constant newline.

	add	r5, r2, r0

getchar_loop:
	in	r6, ASCII

	lc	r15, $got_char
	beq	r15, r1, r0		# check for !EOF

	jmp	$exit

got_char:
	lc	r15, $end_getchar_loop
	lc	r7, '\n'		# check for newline
	beq	r15, r6, r7

	lc	r15, $overflow_error
	beq	r15, r5, r0		# did we see too many chars?

	inc	r5, -1			# decrement 

	lc	r15, '0'		# convert from ASCII to decimal.
	sub	r6, r6, r15

	add	r12, r3, r5
	st	r6, r12, 0		# store in temp.

	jmp	$getchar_loop

end_getchar_loop:

	# Now we have all the right digits, but they may be in the
	# wrong place.  We might have to shift them "down" by the
	# right number of spots.

	# local register usage:
	# r7	- offset to shift by.
	# r8	- pointer to next element to shift TO.
	# r9	- index of element to shift.

	add	r7, r5, r0
	add	r8, r3, r0
	add	r9, r5, r0

shift_loop:
	lc	r15, $end_shift_loop
	beq	r15, r9, r2

	add	r12, r8, r7
	ld	r6, r12, 0

	st	r0, r12, 0
	st	r6, r8, 0

	inc	r8, 1
	inc	r9, 1

	jmp	$shift_loop

end_shift_loop:

number_add:

	# Now we're ready for the big show: adding sum to temp, and
	# storing the result back in sum.  This is very
	# straightforward.

	# local register usage:
	#
	# r5	- index into the numbers (sum and temp)
	# r6	- digit from sum
	# r7	- digit from temp
	# r8	- carry
	# r9	- temp sum.

	lc	r5, 0
	lc	r8, 0

add_loop:
	lc	r15, $end_add_loop
	beq	r15, r5, r2		# have we done all the digits?

	add	r12, r4, r5
	ld	r6, r12, 0		# r6 = sum[r5]

	add	r12, r3, r5
	ld	r7, r12, 0		# r7 = temp[r5]

	add	r9, r6, r7		# compute sum of digits, 
	add	r9, r9, r8		# and toss in the carry.

	lc	r10, $no_carry
	bgt	r10, r13, r9

carry:
	lc	r8, 1
	inc	r9, -10
	jmp	$done_carry

no_carry:
	lc	r8, 0

done_carry:

	add	r12, r4, r5
	st	r9, r12, 0		# store the carry in sum[r5]

	inc	r5, 1			# increment r5.

	jmp	$add_loop		# iterate.

end_add_loop:

	lc	r15, $overflow_error	# check for overflow, and cope.
	bgt	r15, r8, r0

number_print:

	# Now it's time to print out the sum.

	# local register usage:
	#
	# r5	- index into the sum number.
	# r6	- the digit.

	add	r5, r2, r0
	inc	r5, -1

	# Loop down until we find a non-zero digit, or we run out of
	# digits (to avoid printing leading zeros).

find_dig_loop:
	add	r12, r4, r5
	ld	r6, r12, 0

	lc	r15, $print_loop
	bgt	r15, r6, r0

	inc	r5, -1

	lc	r15, $print_loop
	beq	r15, r5, r0

	jmp	$find_dig_loop

	# print everything left (which may be just a lonesome zero).
print_loop:
	add	r12, r4, r5
	ld	r6, r12, 0
	out	r6, Hex

	lc	r15, $end_print_loop
	beq	r15, r5, r0

	inc	r5, -1

	jmp	$print_loop

end_print_loop:
	jmp	$main_loop

overflow_error:
	lc	r15, 'X'
	out	r15, ASCII
	jmp	$exit

exit:
	hlt

_data_:

sum:	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0

temp:	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
end:
