# Dan Ellard -- 11/2/96
# larger.asm-- An Ant-8 program that computes and prints the larger
#       of two numbers specified at runtime by the user.
#	The algorithm used here is to put the larger of r2 and r3
#	into r4, and then print r4.
# Registers used:
# r2 - used to hold the first number.
# r3 - used to hold the second number.
# r4 - used to hold the larger of r2 and r3.
# r5 - used to hold the address of the label "r2_larger"
# r6 - used to hold the a "newline" character

        in     r2, Hex		# read a hexadecimal number into r2
        in     r3, Hex		# read a hexadecimal number into r3

        lc      r5, $r2_larger  # put the address of r2_larger into r5
 
        bgt     r5, r2, r3      # if r2 is larger, branch to r2_larger
        add     r4, r3, r0      # "copy" r3 into r4
        jmp     $endif          # and then branch to endif
r2_larger:
        add     r4, r2, r0      # "copy" r2 into r4
endif:
        out     r4, Hex		# print contents of r4 (in hex).
        lc      r6, '\n'        # load a newline character into r6
        out     r6, ASCII	# print contents of r6 (in ASCII).
        hlt                     # Halt

# end of larger.asm.
