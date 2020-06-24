# Dan Ellard -- 11/2/96
# add2.asm-- A program that computes and prints the sum
#       of two numbers specified at runtime by the user.
# Registers used:
# r2 - used to hold the result.
# r3 - used to hold the first number.
# r4 - used to hold the second number.
# r5 - used to hold the constant '\n'.

        sys     r3, SysGetInt   # read first number into r3
        sys     r4, SysGetInt   # read second number into r4
        add     r2, r3, r4      # compute the sum r2 = r3 + r4.
        sys     r2, SysPutInt   # print contents of r2.

        # Print out a newline
        lc      r5, '\n'        # load a newline character into r5
        sys     r5, SysPutChar  # print contents of r5
 
        sys     r0, SysHalt     # Halt
        
# end of add2.asm.
