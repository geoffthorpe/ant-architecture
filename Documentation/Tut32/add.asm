# add.asm-- An Ant-32 program that computes the sum of 1 and 2,
#       leaving the result in register g0.
# g0 - used to hold the result.
# g1 - used to hold the constant 1.
# g2 - used to hold the constant 2.

        lc      g1, 1           # load 1 into g1.
        lc      g2, 2           # load 2 into g2.
        add     g0, g1, g2      # g0 = g1 + g2.

        halt                    # Halt - end execution.
