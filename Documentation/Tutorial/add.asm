# Dan Ellard -- 11/2/96
# add.asm-- An Ant-8 program that computes the sum of 1 and 2,
#       leaving the result in register r2.
# Registers used:
# r2 - used to hold the result.
# r3 - used to hold the constant 1.
# r4 - used to hold the constant 2.

        lc      r3, 1           # load 1 into r3.
        lc      r4, 2           # load 2 into r4.
        add     r2, r3, r4      # r2 = r3 + r4.

        hlt                     # Halt - end execution.

# end of add.asm
