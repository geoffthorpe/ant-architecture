# Barney Titmouse -- 11/2/96
# larger.asm-- A program that computes and prints the larger
#       of two numbers specified at runtime by the user.
# Registers used:
#       r2      - used to hold the first number.
#       r3      - used to hold the second number.  
#       r4      - used to hold the larger of the r2 and r3.
#       r5      - used to hold the address of the label "r2_bigger"
#       r6      - used to hold the a "newline" character

        ## Get first number from user, put into r2.
        sys     r2, 5		# read a number into r2

        ## Get second number from user, put into r3.
        sys     r3, 5           # read a number into r3

        ## put the larger of r2 and r3 into r4
        lc      r5, $r2_bigger  # put the address of r2_bigger into r5

        bgt     r5, r2, r3      # if r2 is larger, branch to r2_bigger
        add     r4, r3, r0      # "copy" r3 into r4
        jmp     $endif          # and then branch to endif
r2_bigger:
        add     r4, r2, r0      # "copy" r2 into r4
endif:

        ## Print out r4.
        sys     r4, 2           # print contents of r4.

        ## Print out a newline
newline:
        lc      r6, '\n'	# load a newline character into r6
        sys     r6, 3		# print contents of r6

        ## exit the program
        sys     r0, 0           # Halt

# end of larger.asm
