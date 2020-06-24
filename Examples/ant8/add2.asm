# Dan Ellard -- 11/2/96
# add2.asm-- A program that computes and prints the sum
#       of two numbers specified at runtime by the user,
#       followed by a newline
# Registers used:
# r2 - used to hold the result.
# r3 - used to hold the first number.
# r4 - used to hold the second number.
# r5 - used to hold the constant '\n'.

	in	r3, Hex		# read first number into r3 (as hex).
	in	r4, Hex		# read second number into r4 (as hex).
        add     r2, r3, r4      # compute the sum r2 = r3 + r4.
        out	r2, Hex		# print contents of r2 (as hex).

        lc      r5, '\n'        # load a newline character into r5
        out     r5, ASCII       # print contents of r5, as ASCII
 
        hlt                     # Halt
        
# end of add2.asm.
