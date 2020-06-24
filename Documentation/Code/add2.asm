# Barney Titmouse -- 11/02/96
# add2.asm-- A program that computes and prints the sum
#       of two numbers specified at runtime by the user.
# Registers used:
#       r2      - used to hold the result.
#       r3      - used to hold the first number.
#       r4      - used to hold the second number.
#       r5      - used to hold the constant '\n'.
 
        # Get first number from user, put into r3.
        sys     r3, 5           # read a number into r3
 
        # Get second number from user, put into r4.
        sys     r4, 5           # read a number into r4
 
        add     r2, r3, r4      # compute the sum.
 
        # Print out r2.
        sys     r2, 2           # print contents of r2.

	# Print out a newline
	lc	r5, '\n'	# load a newline character into r5
	sys	r5, 3		# print contents of r5

        sys     r0, 0           # Halt
 
# end of add2.asm.
