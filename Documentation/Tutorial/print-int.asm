# $Id: print-int.asm,v 1.3 2002/03/22 16:23:44 ellard Exp $
# print-int.asm - An Ant-8 program that reads a hex number and prints it
# as a signed decimal number.
# Register usage:
# r4 - holds the number
#

test_loop:

	in  r4, Hex	# Read the number

	# First, check for the special case of 0xff (-128).
	lc  r5, 0xff
	lc  r6, $normal
	bgt r6, r4, r5

	lc  r5, '-'
	out r5, ASCII
	lc  r5, '1'
	out r5, ASCII
	lc  r5, '2'
	out r5, ASCII
	lc  r5, '8'
	out r5, ASCII
	lc  r5, '\n'
	out r5, ASCII
	jmp $exit

normal:
	# Next, handle negative numbers.
	# If the number is negative, we print out '-' and
	# then negate the number and continue on.

	lc  r6, $positive
	bgt r6, r4, r0

	# If we get here, the number was negative.

	lc  r5, '-'
	out r5, ASCII	# print '-'
	sub r4, r0, r4	# and negate the number.

positive:
	# If the number is greater than or equal to 100,
	# print out '1', and then subtract 100.

	lc  r5, 100
	lc  r6, $smaller_than_100
	bgt r6, r5, r4

	lc  r5, '1'
	out r5, ASCII
	inc r4, 100

smaller_than_100:
	# Finally!
	# Now we're really hurting for division...

	lc  r6, $print_tens
	lc  r5, 9
	lc  r7, 10

tens_loop:
	mul r8, r7, r5
	inc r8, -1
	bgt r6, r4, r8
	inc r5, -1
	jmp $tens_loop

print_tens:
	lc  r6, $print_ones
	beq r6, r5, r0

	out r5, Hex
	mul r8, r7, r5
	sub r4, r4, r8

print_ones:
	out r4, Hex

	lc  r5, '\n'
	out r5, ASCII


	jmp $test_loop

exit:
	hlt
