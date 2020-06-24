# Barney Titmouse -- 11/02/96
# add.asm-- A program that computes the sum of 1 and 2,
#       leaving the result in register r2.
# Registers used:
#       r2      - used to hold the result.
#       r3      - used to hold the constant 1.
#       r4      - used to hold the constant 2.
        
        lc      r3, 1           # r3 = 1
        lc      r4, 2           # r4 = 2
        add     r2, r3, r4      # r2 = r3 + r4.
			        
        sys     r0, 0           # Halt, end execution

# end of add.asm
