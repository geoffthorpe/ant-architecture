# larger.asm-- A program that finds the larger of two numbers
#       stored in registers g1 and g2, and copies it into g0.
# Registers used:
# g0 - the result.
# g1 - the first number.
# g2 - the second number.
# g3 - the result of comparing g1 and g2.
# g4 - the address of the label "g2_larger"
# g5 - the address of the label "endif"

        lc      g4, $g2_larger  # put the address of g2_larger into g4
        lc      g5, $endif      # put the address of endif into g5
 
        ges     g3, g1, g2      # g3 gets (g1 >= g2)
        jez     ze, g3, g4      # if g3 is zero, branch to g2_larger
        addi    g0, g1, 0       # Otherwise, "copy" g2 into g0
        jez     ze, ze, g5      # and then branch to endif
g2_larger:
        addi    g0, g2, 0       # "copy" g1 into g0
endif:
        halt                    # Halt
