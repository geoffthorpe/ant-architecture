# Penny Ellard - 11/04/96
# read in numbers until a 0 is entered, then print the (integer) average
# r2 is the sum
# r3 is the count
# r4 is 1, the increment
# r5 is used for the number read in
# r6 is used for the average
# r7 is used to hold addresses to branch to.

start:				# "start" is where registers are initialized
	lc 	r2, 0		# the sum is set to 0
	lc 	r3, 0		# the count is set to 0
	lc	r4, 1		# the increment is 1

read_loop:			# "read_loop" is the loop to read in numbers
	sys	r5, 5		# read in the number, put it in r5
	lc	r7, $end_loop
	beq	r7, r5, r0	# if the number read in is 0, finish
	add	r2, r2, r5	# else, add the new number to the sum
	add	r3, r3, r4	#       and increment the counter
	jmp	$read_loop	#	and go back to the top of the loop

end_loop:

	lc	r7, $zero
	beq	r7, r3, r0	# is the count equal to zero? if so branch

	div	r6, r2, r3	# otherwise, do the division to get average
	jmp	$print		# skip over the case where count is 0

zero:				# "zero" only runs to avoid division by zero 
	lc	r6, 0		# pretend that the average is zero.

print:				
	sys	r6, 2		# print out the average

	lc	r8, '\n'
	sys	r8, 3

exit:
	sys	r0, 0
